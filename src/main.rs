use std::f64::consts::PI;

use ndarray::{Array1, Array2, Array3, ArrayBase, Data, Dimension};
use ndarray_npy::write_npy;
use rand::{RngExt, SeedableRng, rngs::StdRng};
use rand_distr::StandardNormal;
use rustfft::{FftPlanner, num_complex::Complex};

const REALIZATION_SEED: u64 = 4;

#[derive(Debug)]
struct Config {
  n_particles: usize,
  n_mesh: usize,
  box_size: f64,
  growth_factor: f64,
  ic_amplitude: f64,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum WebType {
  Void = 0,
  Pancake = 1,
  Filament = 2,
  Knot = 3,
}

fn classify_from_d_eigenvalues(l1: f64, l2: f64, l3: f64, growth_factor: f64) -> WebType {
  let threshold = -1.0 / growth_factor;

  let mut n_collapsed = 0;

  if l1 < threshold {
    n_collapsed += 1;
  }
  if l2 < threshold {
    n_collapsed += 1;
  }
  if l3 < threshold {
    n_collapsed += 1;
  }

  match n_collapsed {
    0 => WebType::Void,
    1 => WebType::Pancake,
    2 => WebType::Filament,
    3 => WebType::Knot,
    _ => unreachable!(),
  }
}

fn classify_web_from_eigenvalues(
  eig1: &Array3<f64>,
  eig2: &Array3<f64>,
  eig3: &Array3<f64>,
  growth_factor: f64,
) -> Array3<u8> {
  let (nx, ny, nz) = eig1.dim();
  let mut web = Array3::<u8>::zeros((nx, ny, nz));

  for i in 0..nx {
    for j in 0..ny {
      for k in 0..nz {
        let web_type = classify_from_d_eigenvalues(
          eig1[[i, j, k]],
          eig2[[i, j, k]],
          eig3[[i, j, k]],
          growth_factor,
        );

        web[[i, j, k]] = web_type as u8;
      }
    }
  }

  web
}

fn web_fractions(web: &Array3<u8>) -> [f64; 4] {
  let mut counts = [0usize; 4];

  for &v in web.iter() {
    counts[v as usize] += 1;
  }

  let total = web.len() as f64;

  [
    counts[0] as f64 / total,
    counts[1] as f64 / total,
    counts[2] as f64 / total,
    counts[3] as f64 / total,
  ]
}

fn create_particles(config: &Config) -> Array2<f64> {
  let n = config.n_particles;
  let n_total = n * n * n;
  let dq = config.box_size / n as f64;

  let mut particles = Array2::<f64>::zeros((n_total, 3));

  for i in 0..n {
    for j in 0..n {
      for k in 0..n {
        let idx = i * n * n + j * n + k;
        particles[[idx, 0]] = (i as f64) * dq;
        particles[[idx, 1]] = (j as f64) * dq;
        particles[[idx, 2]] = (k as f64) * dq;
      }
    }
  }

  particles
}

fn ifft3d(field: &mut Array3<Complex<f64>>) {
  let (nx, ny, nz) = field.dim();
  let mut planner = FftPlanner::<f64>::new();

  let ifft_x = planner.plan_fft_inverse(nx);
  let ifft_y = planner.plan_fft_inverse(ny);
  let ifft_z = planner.plan_fft_inverse(nz);

  for j in 0..ny {
    for k in 0..nz {
      let mut line = Vec::with_capacity(nx);
      for i in 0..nx {
        line.push(field[[i, j, k]]);
      }
      ifft_x.process(&mut line);
      for i in 0..nx {
        field[[i, j, k]] = line[i];
      }
    }
  }

  for i in 0..nx {
    for k in 0..nz {
      let mut line = Vec::with_capacity(ny);
      for j in 0..ny {
        line.push(field[[i, j, k]]);
      }
      ifft_y.process(&mut line);
      for j in 0..ny {
        field[[i, j, k]] = line[j];
      }
    }
  }

  for i in 0..nx {
    for j in 0..ny {
      let mut line = Vec::with_capacity(nz);
      for k in 0..nz {
        line.push(field[[i, j, k]]);
      }
      ifft_z.process(&mut line);
      for k in 0..nz {
        field[[i, j, k]] = line[k];
      }
    }
  }

  let norm = (nx * ny * nz) as f64;
  for v in field.iter_mut() {
    *v /= norm;
  }
}

fn conjugate_index(i: usize, n: usize) -> usize {
  (n - i) % n
}

fn k_index(i: usize, n: usize) -> isize {
  if i < n / 2 {
    i as isize
  } else {
    i as isize - n as isize
  }
}

fn power_spectrum(k: f64, box_size: f64) -> f64 {
  let k_fund = 2.0 * PI / box_size;
  let k_min = 2.0 * k_fund;
  let k_max = 8.0 * k_fund;
  let spectral_index = -1.0;

  if k < k_min || k > k_max {
    return 0.0;
  }
  let low_k_taper = 1.0 - (-(k / k_min).powi(4)).exp();
  let high_k_taper = (-(k / k_max).powi(2)).exp();

  k.powf(spectral_index) * low_k_taper * high_k_taper
}

fn create_delta_k(n: usize, box_size: f64, ic_amplitude: f64) -> Array3<Complex<f64>> {
  let mut rng = StdRng::seed_from_u64(REALIZATION_SEED);
  let mut delta_k = Array3::<Complex<f64>>::zeros((n, n, n));

  for i in 0..n {
    let ii = conjugate_index(i, n);
    let ki = k_index(i, n);

    for j in 0..n {
      let jj = conjugate_index(j, n);
      let kj = k_index(j, n);

      for k in 0..n {
        let kk = conjugate_index(k, n);
        let kz_index = k_index(k, n);

        if (i, j, k) > (ii, jj, kk) {
          continue;
        }

        if (i, j, k) == (0, 0, 0) {
          delta_k[[i, j, k]] = Complex::new(0.0, 0.0);
          continue;
        }

        let kx = 2.0 * PI * ki as f64 / box_size;
        let ky = 2.0 * PI * kj as f64 / box_size;
        let kz = 2.0 * PI * kz_index as f64 / box_size;
        let k2 = kx * kx + ky * ky + kz * kz;
        let self_conjugate = i == ii && j == jj && k == kk;
        let amp = ic_amplitude * power_spectrum(k2.sqrt(), box_size).sqrt();

        if self_conjugate {
          let re: f64 = rng.sample(StandardNormal);
          delta_k[[i, j, k]] = Complex::new(re * amp, 0.0);
        } else {
          let re: f64 = rng.sample(StandardNormal);
          let im: f64 = rng.sample(StandardNormal);
          let sigma = amp / 2.0_f64.sqrt();
          let z = Complex::new(re * sigma, im * sigma);

          delta_k[[i, j, k]] = z;
          delta_k[[ii, jj, kk]] = z.conj();
        }
      }
    }
  }

  delta_k
}

fn complex_to_real(field: &Array3<Complex<f64>>) -> Array3<f64> {
  let (nx, ny, nz) = field.dim();
  let mut out = Array3::<f64>::zeros((nx, ny, nz));

  for i in 0..nx {
    for j in 0..ny {
      for k in 0..nz {
        out[[i, j, k]] = field[[i, j, k]].re;
      }
    }
  }

  out
}

/// ψᵢ(k) = (ikᵢ/k²)δₖ
fn compute_displacement_from_delta_k(
  delta_k: &Array3<Complex<f64>>,
  box_size: f64,
) -> (Array3<f64>, Array3<f64>, Array3<f64>) {
  let (nx, ny, nz) = delta_k.dim();

  let mut psi_kx = Array3::<Complex<f64>>::zeros((nx, ny, nz));
  let mut psi_ky = Array3::<Complex<f64>>::zeros((nx, ny, nz));
  let mut psi_kz = Array3::<Complex<f64>>::zeros((nx, ny, nz));

  for i in 0..nx {
    let kx = 2.0 * PI * k_index(i, nx) as f64 / box_size;

    for j in 0..ny {
      let ky = 2.0 * PI * k_index(j, ny) as f64 / box_size;

      for k in 0..nz {
        let kz = 2.0 * PI * k_index(k, nz) as f64 / box_size;
        let k2 = kx * kx + ky * ky + kz * kz;

        if k2 == 0.0 {
          continue;
        }

        let prefactor = Complex::new(0.0, 1.0) * delta_k[[i, j, k]] / k2;
        let kx_eff = if nx % 2 == 0 && i == nx / 2 { 0.0 } else { kx };
        let ky_eff = if ny % 2 == 0 && j == ny / 2 { 0.0 } else { ky };
        let kz_eff = if nz % 2 == 0 && k == nz / 2 { 0.0 } else { kz };

        psi_kx[[i, j, k]] = prefactor * kx_eff;
        psi_ky[[i, j, k]] = prefactor * ky_eff;
        psi_kz[[i, j, k]] = prefactor * kz_eff;
      }
    }
  }

  ifft3d(&mut psi_kx);
  ifft3d(&mut psi_ky);
  ifft3d(&mut psi_kz);

  (
    complex_to_real(&psi_kx),
    complex_to_real(&psi_ky),
    complex_to_real(&psi_kz),
  )
}

/// x = q + Dψ(q)
fn displace_particles(
  config: &Config,
  particles: &Array2<f64>,
  psi_x: &Array3<f64>,
  psi_y: &Array3<f64>,
  psi_z: &Array3<f64>,
) -> Array2<f64> {
  let n = config.n_particles;
  let n_total = n * n * n;
  let mut displaced = Array2::<f64>::zeros((n_total, 3));

  for i in 0..n {
    for j in 0..n {
      for k in 0..n {
        let idx = i * n * n + j * n + k;

        displaced[[idx, 0]] = (particles[[idx, 0]] + config.growth_factor * psi_x[[i, j, k]])
          .rem_euclid(config.box_size);
        displaced[[idx, 1]] = (particles[[idx, 1]] + config.growth_factor * psi_y[[i, j, k]])
          .rem_euclid(config.box_size);
        displaced[[idx, 2]] = (particles[[idx, 2]] + config.growth_factor * psi_z[[i, j, k]])
          .rem_euclid(config.box_size);
      }
    }
  }

  displaced
}

/// CIC deposit
fn deposit_cic(config: &Config, particles: &Array2<f64>) -> Array3<f64> {
  let n = config.n_mesh;
  let dx = config.box_size / n as f64;
  let mut density = Array3::<f64>::zeros((n, n, n));
  let n_total = particles.dim().0;

  for p in 0..n_total {
    let x = particles[[p, 0]] / dx;
    let y = particles[[p, 1]] / dx;
    let z = particles[[p, 2]] / dx;

    let i0 = x.floor() as usize % n;
    let j0 = y.floor() as usize % n;
    let k0 = z.floor() as usize % n;

    let i1 = (i0 + 1) % n;
    let j1 = (j0 + 1) % n;
    let k1 = (k0 + 1) % n;

    let tx = x - x.floor();
    let ty = y - y.floor();
    let tz = z - z.floor();

    let wx0 = 1.0 - tx;
    let wx1 = tx;
    let wy0 = 1.0 - ty;
    let wy1 = ty;
    let wz0 = 1.0 - tz;
    let wz1 = tz;

    density[[i0, j0, k0]] += wx0 * wy0 * wz0;
    density[[i1, j0, k0]] += wx1 * wy0 * wz0;
    density[[i0, j1, k0]] += wx0 * wy1 * wz0;
    density[[i1, j1, k0]] += wx1 * wy1 * wz0;
    density[[i0, j0, k1]] += wx0 * wy0 * wz1;
    density[[i1, j0, k1]] += wx1 * wy0 * wz1;
    density[[i0, j1, k1]] += wx0 * wy1 * wz1;
    density[[i1, j1, k1]] += wx1 * wy1 * wz1;
  }

  density
}

/// δ = ρ/ρ̄ - 1
fn density_to_contrast(density: &Array3<f64>) -> Array3<f64> {
  let (nx, ny, nz) = density.dim();
  let mut sum = 0.0;

  for i in 0..nx {
    for j in 0..ny {
      for k in 0..nz {
        sum += density[[i, j, k]];
      }
    }
  }

  let mean = sum / (nx * ny * nz) as f64;
  let mut contrast = Array3::<f64>::zeros((nx, ny, nz));

  for i in 0..nx {
    for j in 0..ny {
      for k in 0..nz {
        contrast[[i, j, k]] = density[[i, j, k]] / mean - 1.0;
      }
    }
  }

  contrast
}

fn central_slice_xy(field: &Array3<f64>) -> Array2<f64> {
  let (nx, ny, nz) = field.dim();
  let k = nz / 2;
  let mut slice = Array2::<f64>::zeros((nx, ny));

  for i in 0..nx {
    for j in 0..ny {
      slice[[i, j]] = field[[i, j, k]];
    }
  }

  slice
}

fn central_slice_xz(field: &Array3<f64>) -> Array2<f64> {
  let (nx, ny, nz) = field.dim();
  let j = ny / 2;
  let mut slice = Array2::<f64>::zeros((nx, nz));

  for i in 0..nx {
    for k in 0..nz {
      slice[[i, k]] = field[[i, j, k]];
    }
  }

  slice
}

fn central_slice_yz(field: &Array3<f64>) -> Array2<f64> {
  let (nx, ny, nz) = field.dim();
  let i = nx / 2;
  let mut slice = Array2::<f64>::zeros((ny, nz));

  for j in 0..ny {
    for k in 0..nz {
      slice[[j, k]] = field[[i, j, k]];
    }
  }

  slice
}

fn sort3_ascending(mut a: f64, mut b: f64, mut c: f64) -> (f64, f64, f64) {
  if a > b {
    std::mem::swap(&mut a, &mut b);
  }
  if b > c {
    std::mem::swap(&mut b, &mut c);
  }
  if a > b {
    std::mem::swap(&mut a, &mut b);
  }
  (a, b, c)
}

/// Eigenvalues of a real symmetric 3x3 matrix:
///
/// [ a00  a01  a02 ]
/// [ a01  a11  a12 ]
/// [ a02  a12  a22 ]
///
/// Returns eigenvalues sorted ascending.
fn symmetric_3x3_eigenvalues(
  a00: f64,
  a01: f64,
  a02: f64,
  a11: f64,
  a12: f64,
  a22: f64,
) -> (f64, f64, f64) {
  let p1 = a01 * a01 + a02 * a02 + a12 * a12;

  if p1 < 1.0e-30 {
    return sort3_ascending(a00, a11, a22);
  }

  let q = (a00 + a11 + a22) / 3.0;

  let b00 = a00 - q;
  let b11 = a11 - q;
  let b22 = a22 - q;

  let p2 = b00 * b00 + b11 * b11 + b22 * b22 + 2.0 * p1;
  let p = (p2 / 6.0).sqrt();

  if p < 1.0e-30 {
    return sort3_ascending(a00, a11, a22);
  }

  let c00 = b00 / p;
  let c01 = a01 / p;
  let c02 = a02 / p;
  let c11 = b11 / p;
  let c12 = a12 / p;
  let c22 = b22 / p;

  let det_c =
    c00 * (c11 * c22 - c12 * c12) - c01 * (c01 * c22 - c12 * c02) + c02 * (c01 * c12 - c11 * c02);

  let r = (det_c / 2.0).clamp(-1.0, 1.0);
  let phi = r.acos() / 3.0;

  let eig_a = q + 2.0 * p * phi.cos();
  let eig_c = q + 2.0 * p * (phi + 2.0 * PI / 3.0).cos();
  let eig_b = 3.0 * q - eig_a - eig_c;

  sort3_ascending(eig_a, eig_b, eig_c)
}

/// Computes eigenvalues of d_ik(q).
/// d_ik(k) = - k_i k_k delta(k) / k^2
/// Then each component is inverse-FFT'd to real space.
/// Finally, the local symmetric 3x3 tensor is diagonalized at every grid cell.
/// Returns:
/// eig1 <= eig2 <= eig3
fn compute_deformation_eigenvalues_from_delta_k(
  delta_k: &Array3<Complex<f64>>,
  box_size: f64,
) -> (Array3<f64>, Array3<f64>, Array3<f64>) {
  let (nx, ny, nz) = delta_k.dim();

  let mut dxx_k = Array3::<Complex<f64>>::zeros((nx, ny, nz));
  let mut dxy_k = Array3::<Complex<f64>>::zeros((nx, ny, nz));
  let mut dxz_k = Array3::<Complex<f64>>::zeros((nx, ny, nz));
  let mut dyy_k = Array3::<Complex<f64>>::zeros((nx, ny, nz));
  let mut dyz_k = Array3::<Complex<f64>>::zeros((nx, ny, nz));
  let mut dzz_k = Array3::<Complex<f64>>::zeros((nx, ny, nz));

  for i in 0..nx {
    let kx = 2.0 * PI * k_index(i, nx) as f64 / box_size;
    let kx_eff = if nx % 2 == 0 && i == nx / 2 { 0.0 } else { kx };

    for j in 0..ny {
      let ky = 2.0 * PI * k_index(j, ny) as f64 / box_size;
      let ky_eff = if ny % 2 == 0 && j == ny / 2 { 0.0 } else { ky };

      for k in 0..nz {
        let kz = 2.0 * PI * k_index(k, nz) as f64 / box_size;
        let kz_eff = if nz % 2 == 0 && k == nz / 2 { 0.0 } else { kz };

        let k2 = kx * kx + ky * ky + kz * kz;

        if k2 == 0.0 {
          continue;
        }

        let delta = delta_k[[i, j, k]];

        dxx_k[[i, j, k]] = delta * (-(kx_eff * kx_eff) / k2);
        dxy_k[[i, j, k]] = delta * (-(kx_eff * ky_eff) / k2);
        dxz_k[[i, j, k]] = delta * (-(kx_eff * kz_eff) / k2);

        dyy_k[[i, j, k]] = delta * (-(ky_eff * ky_eff) / k2);
        dyz_k[[i, j, k]] = delta * (-(ky_eff * kz_eff) / k2);

        dzz_k[[i, j, k]] = delta * (-(kz_eff * kz_eff) / k2);
      }
    }
  }

  ifft3d(&mut dxx_k);
  ifft3d(&mut dxy_k);
  ifft3d(&mut dxz_k);
  ifft3d(&mut dyy_k);
  ifft3d(&mut dyz_k);
  ifft3d(&mut dzz_k);

  let dxx = complex_to_real(&dxx_k);
  let dxy = complex_to_real(&dxy_k);
  let dxz = complex_to_real(&dxz_k);
  let dyy = complex_to_real(&dyy_k);
  let dyz = complex_to_real(&dyz_k);
  let dzz = complex_to_real(&dzz_k);

  let mut eig1 = Array3::<f64>::zeros((nx, ny, nz));
  let mut eig2 = Array3::<f64>::zeros((nx, ny, nz));
  let mut eig3 = Array3::<f64>::zeros((nx, ny, nz));

  for i in 0..nx {
    for j in 0..ny {
      for k in 0..nz {
        let (l1, l2, l3) = symmetric_3x3_eigenvalues(
          dxx[[i, j, k]],
          dxy[[i, j, k]],
          dxz[[i, j, k]],
          dyy[[i, j, k]],
          dyz[[i, j, k]],
          dzz[[i, j, k]],
        );

        eig1[[i, j, k]] = l1;
        eig2[[i, j, k]] = l2;
        eig3[[i, j, k]] = l3;
      }
    }
  }

  (eig1, eig2, eig3)
}

fn save_npy<S, D>(name: &str, array: &ArrayBase<S, D>) -> Result<(), Box<dyn std::error::Error>>
where
  S: Data<Elem = f64>,
  D: Dimension,
{
  write_npy(format!("data/{}.npy", name), array)?;
  Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
  let config = Config {
    n_particles: 64,
    n_mesh: 64,
    box_size: 1600.0,
    growth_factor: 55.0,
    ic_amplitude: 90.0,
  };

  assert_eq!(config.n_particles, config.n_mesh);

  let particles = create_particles(&config);
  let delta_k = create_delta_k(config.n_mesh, config.box_size, config.ic_amplitude);
  let (eig1, eig2, eig3) = compute_deformation_eigenvalues_from_delta_k(&delta_k, config.box_size);
  let web = classify_web_from_eigenvalues(&eig1, &eig2, &eig3, config.growth_factor);
  let fractions = web_fractions(&web);
  println!("Void fraction:     {}", fractions[0]);
  println!("Pancake fraction: {}", fractions[1]);
  println!("Filament fraction:{}", fractions[2]);
  println!("Knot fraction:    {}", fractions[3]);
  let (psi_x, psi_y, psi_z) = compute_displacement_from_delta_k(&delta_k, config.box_size);
  let displaced_particles = displace_particles(&config, &particles, &psi_x, &psi_y, &psi_z);
  let density = deposit_cic(&config, &displaced_particles);
  let final_delta = density_to_contrast(&density);

  let final_delta_xy_slice = central_slice_xy(&final_delta);
  let final_delta_xz_slice = central_slice_xz(&final_delta);
  let final_delta_yz_slice = central_slice_yz(&final_delta);
  let config_metadata = Array1::from_vec(vec![
    config.box_size,
    config.n_mesh as f64,
    config.n_particles as f64,
    config.growth_factor,
    config.ic_amplitude,
  ]);

  save_npy("config", &config_metadata)?;
  save_npy("final_delta", &final_delta)?;
  save_npy("final_delta_xy_slice", &final_delta_xy_slice)?;
  save_npy("final_delta_xz_slice", &final_delta_xz_slice)?;
  save_npy("final_delta_yz_slice", &final_delta_yz_slice)?;

  println!("Saved density field and central slices with seed {REALIZATION_SEED}");

  Ok(())
}
