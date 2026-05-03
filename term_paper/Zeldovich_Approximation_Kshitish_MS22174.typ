#import "@preview/catppuccin:1.1.0": catppuccin, flavors
#import "@preview/physica:0.9.8": *;
#import "@preview/equate:0.3.2": equate
#import "@preview/unify:0.8.0": num, numrange, qty, qtyrange

#show: catppuccin.with(flavors.latte)
#let flavor = flavors.latte
#show: equate.with(breakable: true, sub-numbering: true)


#let text-size = 10pt
#set text(font: "Maple Mono NF", size: text-size)
#show heading.where(level: 1): set align(center)
#show heading.where(level: 1): set text(size: 1.5 * text-size, weight: "bold")


#show heading.where(level: 2): set text(
  size: 1.25 * text-size,
  weight: "regular",
)
#show heading.where(level: 2): underline
#set quote(block: true)

#show link: set text(fill: flavor.colors.blue.rgb, style: "oblique")
#show link: underline

#set math.equation(numbering: "(1.1)")
#show math.equation: set text(size: 1.25 * text-size)

#let cover-page = {
  set align(center + horizon)

  image("images/my_simulation.png")
  v(2em)

  text(size: 4 * text-size, weight: "extrabold")[Zel'dovich Approximation]
  linebreak()
  v(2em)
  text(size: 1.25 * text-size, weight: "semibold")[
    An attempt at understanding the large scale structure of the universe.
  ]

  v(2 * text-size)
  text(size: 1.5 * text-size)[Kshitish Kumar Ratha]
  linebreak()
  text(size: 1.25 * text-size)[MS22174]
  linebreak()
  datetime.today().display()
  v(2em)
  text(
    size: 0.9 * text-size,
  )[All the code, source files and visualizations can be accessed on my #link("https://github.com/pseudofractal/CosmicWebs/")[GitHub].]
  pagebreak()
}

#cover-page
#set page(
  paper: "a4",
  header: align(
    right + horizon,
    context document.title,
  ),
  numbering: "1",
  columns: 2,
)

= Introduction

The large-scale structure of the Universe is not a collection of isolated galaxies, but a cosmic web of voids, sheets, filaments, and clusters. The basic problem is to understand how this web grew from the nearly homogeneous early Universe. Linear perturbation theory explains the early growth of small density contrasts, but it does not explain the geometry of the first nonlinear structures. The Zel'dovich approximation gives a simple geometrical answer: matter collapses anisotropically, first along one principal direction, forming flattened caustics called pancakes @zeldovich_gravitational_1970.

This paper follows that idea from its original Lagrangian form to its later physical and observational consequences. In the Zel'dovich approximation, the deformation tensor maps initial particle positions to later positions. Its eigenvalues determine the compression along three principal axes. Since one eigenvalue generally reaches the collapse condition before the others, the first singular structures are sheets rather than spherical objects.

The formal density divergence at a pancake is not meant to describe a literal infinite-density object. It marks shell crossing. After this point, collisionless dark matter forms multistream regions, while gas can shock, heat, cool, and fragment. This gives possible observational signatures such as thermal distortions of the relic radiation, Ly$alpha$ emission, and redshifted 21-cm signals @sunyaev_formation_1972.

The paper then connects the original approximation to the adhesion model, where collapsed matter is kept concentrated after shell crossing, producing a persistent network of sheets, filaments, and knots @shandarin_large-scale_1989. It also discusses how transfer functions set the initial fluctuation spectrum for this nonlinear evolution @eisenstein_power_1999, and how observational searches and modern caustic-skeleton methods try to identify pancakes as genuine multistream wall-like structures @uson_radio_1991 @hertzsch_new_2025.


= Zel'dovich Approximation

Zel'dovich's approximation treats gravitational instability in an expanding, pressureless medium by following particles rather than density values at fixed positions @zeldovich_gravitational_1970. Let $vb(q)$ be the initial Lagrangian position of a particle, and let $vb(r)(t, vb(q))$ be its physical position at time $t$. The approximation writes

$ vb(r)(t, vb(q)) = a(t) vb(q) + b(t) vb(p)(vb(q)) . $

The first term is the Hubble expansion, while the second is the growing displacement produced by the initial perturbation field. The vector $vb(p)(vb(q))$ is fixed by the initial conditions, so the later density field is obtained from how this map deforms volumes.

The deformation tensor of the map is

$
  D_(i k) = frac(partial r_i, partial q_k)
  = a(t) delta_(i k) + b(t) frac(partial p_i, partial q_k) .
$

At any point one can choose axes along the principal directions of deformation. Then

$
  D = mat(
    a(t) - alpha b(t), 0, 0;
    0, a(t) - beta b(t), 0;
    0, 0, a(t) - gamma b(t)
  ) .
$

The quantities $alpha$, $beta$, and $gamma$ are the local eigenvalues of the deformation field. They depend on position and measure the compression or stretching of a small fluid element along its three principal axes. Mass conservation gives

$ rho (a - alpha b)(a - beta b)(a - gamma b) = overline(rho) a^3 . $

Therefore the density becomes singular when one of the three factors vanishes. Since the three eigenvalues are not generally equal, the first collapse occurs along only one axis, usually the one with the largest eigenvalue. This is the basic reason the approximation predicts sheets, or pancakes, before filaments or compact objects.

This Lagrangian description is better behaved than simply extrapolating the Eulerian linear density field, for example

$ rho(vb(r), t) = overline(rho)(t) [1 + f(t) delta(vb(r) / a(t))] . $

Such an expression agrees with linear theory, but in the nonlinear regime it can even give negative densities. The Zel'dovich approximation instead assigns trajectories to particles and derives the density from the Jacobian of the map. The density can still diverge at shell crossing, but the potential and acceleration remain finite. Thus the approximation remains physically useful up to the first caustic.

For small perturbations, the density expression reduces to the linear result

$
  rho(vb(q), t) = overline(rho) [1 + (alpha + beta + gamma) b(t) / a(t)] \
  = overline(rho) [1 + S(vb(q)) f(t)] .
$

In the linear regime only the sum $alpha + beta + gamma$ matters. In the nonlinear regime, however, the individual eigenvalues matter separately, because they decide which axis collapses first.

Zel'dovich applied this picture to the post-recombination Universe. On sufficiently large scales the matter can be treated as pressureless, since for perturbations of mass $M ~ 10^12 M_sun$ the Jeans mass after recombination is much smaller than the perturbation mass. The perturbation scale is also below the horizon scale, so a Newtonian treatment is adequate. Under these assumptions, collapse is controlled not by spherical symmetry, but by the local deformation tensor and tidal field.

The first pancake is a caustic of the Lagrangian-to-Eulerian map. In one dimension,

$ rho prop (dv(r, q))^(-1) , $

so the first singularity occurs when $dv(r, q) = 0$. Near the first collapse point, expanding the trajectory gives

$ r - r_c prop (q - q_c)^3, quad rho prop (r - r_c)^(-2"/"3) . $

The infinite density is therefore a formal result of the cold, single-stream approximation. Physically, it signals shell crossing. After this point the dust description is no longer single-valued: cold matter develops streams, and gas can shock, convert kinetic energy into heat, and form a compressed layer of finite surface density.

The important point is not that the pancake has infinite volume density, but that gravitational instability first produces a thin collapsed sheet. Galaxies and more compact bound systems can then form later inside or around these compressed regions. In this sense, the approximation gives a physical sequence: perturbations grow, one axis collapses into a pancake, shell crossing and shocks occur, and later fragmentation or further collapse produces smaller bound structures.

This also shows the limitation of spherical collapse. The nonlinear evolution is not determined only by the initial density contrast. It depends on the full deformation tensor, especially on the relative sizes of its eigenvalues.

= Observational Appearance of Pancakes

Sunyaev and Zel'dovich extended the pancake model by asking what the collapsed gas should look like observationally @sunyaev_formation_1972. Once a pancake forms, the infalling gas is not expected to remain cold and single-streaming. It shocks, converts part of its kinetic energy into heat, and produces a compressed intergalactic layer. Some gas remains hot and ionized, while some can cool and condense into protogalaxies or protoclusters.

One important signature comes from hot electrons scattering the relic radiation field. If the electron temperature is $T_e$ and the electron column density is $N_e$, inverse-Compton scattering gives a Rayleigh--Jeans temperature decrement

$ frac(Delta T, T) = - 2 sigma_T N_e frac(k T_e, m_e c^2) . $

The reason is that CMB photons gain energy from the hot electrons. Low-frequency photons are depleted, while higher-frequency photons are enhanced. This is the thermal Sunyaev--Zel'dovich effect. In the pancake picture, such distortions would trace extended regions of hot shocked intergalactic gas, rather than only relaxed galaxy clusters.

Cooler gas gives different signatures. As shocked gas cools to $T ~ 10^4 "K"$, much of the emitted radiation can come out in Ly$alpha$, with additional continuum and helium-line emission. If these objects form at redshifts $z_c ~ 3-5$, the radiation would be observed in redshifted ultraviolet or optical bands. Compressed neutral hydrogen could also be visible through redshifted 21-cm emission, especially when its spin temperature is higher than the relic radiation temperature.

This connects pancakes to the formation of protogalaxies and protoclusters. For perturbation masses $M ~ 10^12-10^14 M_sun$, shock heating and radiative cooling naturally produce a multiphase medium. A hot ionized component remains diffuse, a cooler component condenses into dense objects, and only part of the matter becomes gravitationally bound at first. Large pancakes can therefore be associated with protocluster-scale objects, while smaller condensations inside them may later become galaxies or galactic nuclei.

These signatures make the model observationally testable. Hot gas should contribute to X-ray and ultraviolet backgrounds, produce spectral distortions of the cosmic microwave background, and generate spatial fluctuations in the relic radiation. Cooler neutral or partly ionized gas should appear through redshifted Ly$alpha$ or 21-cm emission. At the same time, the observed X-ray background limits how much gas can be shock-heated to very high temperatures, so the model is constrained by the thermal history of the intergalactic medium.

The physical chain is therefore: anisotropic gravitational collapse forms a pancake; shell crossing drives shocks; shocks heat and ionize the gas; cooling allows fragments to condense; and the remaining gas leaves observable radiative signatures.

= Adhesion Model

Shandarin and Zel'dovich later used the pancake picture as part of a broader description of nonlinear large-scale structure @shandarin_large-scale_1989. The main idea is that gravitational instability does not only increase density contrasts. It reorganizes matter into an intermittent pattern: most of the volume becomes underdense, while much of the mass collects in thin sheets, filaments, and compact clumps. This is why the nonlinear density field is often compared with intermittency in turbulence.

The starting point is again a Lagrangian map. For freely moving particles one can write

$ vb(x)(t, vb(q)) = vb(q) + t vb(v)(vb(q)) $

while the Zel'dovich approximation in an expanding self-gravitating universe has the form

$ vb(r)(t, vb(q)) = a(t) [vb(q) - b(t) vb(s)(vb(q))] $

where $vb(s) = grad Phi$ is fixed by the initial perturbation field. The similarity between these two equations is important. It means that many features of gravitational collapse can be understood through the geometry of a map from initial positions to final positions. When this map becomes singular, shell crossing, caustics, and multistream regions appear.

The original Zel'dovich approximation works well up to the first caustic, but it fails after shell crossing. It allows particles to pass too freely through the collapsed sheet. Real matter behaves differently. Collisionless dark matter forms multistream flows, gas forms shocks, and an idealized sticky medium would remain concentrated after collapse. Shandarin and Zel'dovich used this last limit as a useful model for the cosmic web. In the adhesion model, a small effective viscosity or sticking prescription is added, giving a Burgers-type dynamics that prevents collapsed matter from dispersing after shell crossing @burgers_hopf-cole_1974.

The physical interpretation is simple. The Zel'dovich approximation predicts where matter first collapses, while adhesion keeps that collapsed matter in place. Multistream regions are replaced by thin persistent structures: sheets, filaments, and knots. In this way the first pancake is extended into a connected cosmic web, rather than being treated as a temporary caustic through which particles simply stream.

The geometry is still controlled by the eigenvalues of the deformation tensor. In three dimensions the density can be written as

$ rho = frac(rho_0, (1 - b alpha)(1 - b beta)(1 - b gamma)) $

The first vanishing factor gives collapse along one axis and forms a sheet. Later collapse along a second and third axis gives filaments and compact clumps. The nonlinear sequence is therefore

$ "Sheet" arrow "Filament" arrow "Clump" $

This hierarchy is geometric rather than spherical. It depends on the relative eigenvalues of the deformation field, not only on the initial overdensity.

Shandarin and Zel'dovich also connected this picture with catastrophe theory and geometrical optics. Caustics in the matter distribution are like the bright caustic curves produced when light is reflected or refracted by a rippled surface. In both cases, a smooth initial distribution is folded into a sharply concentrated pattern. This analogy makes the cosmic web appear less like a random collection of overdensities and more like the singular structure of a continuous mapping.

They also used this framework to compare hot and cold dark matter models. Hot dark matter suppresses small-scale perturbations by free streaming, so nonlinear evolution is more top-down and large pancakes form first. Cold dark matter preserves small-scale power, producing more bottom-up clustering. The distinction is not absolute, however. Depending on the slope and cutoff of the initial power spectrum, nonlinear structure formation can contain both hierarchical clustering and large-scale cellular structure.

= Power Spectra and Transfer Functions

#place(top + center, float: true, scope: "parent", clearance: 2em)[
  #columns(2, gutter: 8pt)[
    #figure(
      caption: [Eisenstein and Hu Power Spectrum @eisenstein_power_1999],
    )[#image(
      "images/esienstein-and-hu-power-spectrum.png",
    )]
    #colbreak()
    #figure(caption: [Cosmic Pancakes @hertzsch_new_2025])[#image(
      "images/density_isosurfaces.png",
    )]
  ]
]

The Zel'dovich and adhesion models describe how matter collapses once the initial perturbations are specified. The remaining question is what spectrum of perturbations enters this nonlinear evolution. Eisenstein and Hu provide a useful linear-theory description through fitting formulae for the matter transfer function in cosmologies with cold dark matter, baryons, and massive neutrinos @eisenstein_power_1999.

The late-time matter power spectrum may be written as

$ P(k, z) = A k^n T^2(k, z) D^2(z) $

where $A k^n$ is the primordial power spectrum, $T(k, z)$ is the transfer function, and $D(z)$ is the linear growth factor. In dimensionless form, Eisenstein and Hu write

$
  k^3 P(k, z)/(2 pi^2) = delta_H^2
  ( (c k)/ H_0)^(3+n)
  T^2(k, z)
  (D_1^2(z))/(D_1^2(0))
$

The important point is that the primordial spectrum is not the spectrum that directly enters late-time structure formation. It is modified by early-Universe physics before the perturbations grow into the nonlinear regime.

For a mixture of cold dark matter, baryons, and massive neutrinos, the transfer function is written using a time-independent master function and a scale-dependent growth factor:

$ T_(c b)(k, z) = T_("master")(k) (D_(c b)(k, z))/(D_1(z)) $

$ T_(c b nu)(k, z) = T_("master")(k) (D_(c b nu)(k, z))/(D_1(z)) $

Here $T_(c b)$ describes the density-weighted cold dark matter plus baryon perturbation, while $T_(c b nu)$ also includes the massive neutrino component.

The relevant physical scales are the horizon at matter-radiation equality, the baryon sound horizon, and the neutrino free-streaming scale. Equality produces the broad turnover in $P(k)$. Baryon-photon coupling suppresses small-scale baryonic power and leaves acoustic features. Massive neutrinos suppress growth below their free-streaming scale. Thus baryons and neutrinos both reduce small-scale power, but through different mechanisms.

This matters for pancakes because the transfer function determines which Fourier modes survive with significant amplitude. The power spectrum sets the initial deformation field, while the Zel'dovich and adhesion approximations describe how that field later collapses into sheets, filaments, and knots.

= Numerical Illustration

#place(top + center, float: true, scope: "parent", clearance: 2em)[
  #figure(
    image("images/density_slices.png"),
    caption: [Density Slices @pseudofractal_cosmic_webs],
  )
]<density-slices>

To connect the analytic discussion with something concrete, I wrote a simple Rust code to generate a Zel'dovich realization. The code begins with a Gaussian density field in Fourier space and imposes Hermitian symmetry so that the corresponding real-space field is real. From the density contrast it computes the Zel'dovich displacement field,

$ vb(psi)(vb(k)) = (i vb(k))/k^2 delta(vb(k)) $

and then displaces particles from their initial Lagrangian positions according to

$ vb(x) = vb(q) + D vb(psi)(vb(q)) $

The displaced particles are deposited back onto a mesh using cloud-in-cell interpolation, which gives an evolved density contrast field.

The code also computes the deformation tensor in Fourier space,

$ d_(i j)(vb(k)) = - (k_i k_j)/k^2 delta(vb(k)) $

transforms it back to real space, and diagonalizes the resulting symmetric tensor at each cell. Each cell is then classified by the number of collapsed axes. If zero, one, two, or three eigenvalues cross the collapse threshold, the cell is labelled as a void, pancake, filament, or knot respectively. This gives a direct numerical picture of the Zel'dovich collapse hierarchy.

The code and the resulting visualizations are available on my webpage @pseudofractal_cosmic_webs and the 2D central slices are shown above.

= Observational Searches for Pancakes

#place(center + top, float: true, scope: "parent", clearance: 2em)[
  #figure(
    caption: [Typical Observed Pancakes. Sparser (left) and Denser (right) @hertzsch_new_2025],
  )[#image("images/typical_observational_pancake.png")]
]

One direct observational test of the pancake picture was made by Uson, Bagri, and Cornwell using the VLA. They searched for redshifted 21-cm emission and absorption from neutral hydrogen at $z approx 3.4$ toward the radio source 0902+343 @uson_radio_1991. The motivation came from the Sunyaev--Zel'dovich picture: a massive protocluster-scale pancake should contain a large amount of neutral gas and could appear as a broad 21-cm emission feature, with a velocity width of order $~ 200 "km s"^(-1)$.

They detected 21-cm absorption at $z = 3.3968 plus.minus 0.0004$ against the radio galaxy, and a separate emission feature at $z = 3.3970 plus.minus 0.0003$ offset by $33'$ on the sky. The emission had a velocity width of about $180 plus.minus 40 "km s"^(-1)$. From the inferred gas mass, transverse scale, and surface density, they interpreted the object as neutral hydrogen in a massive, not yet virialized protocluster. In this sense it was proposed as a candidate Zel'dovich pancake.

A more modern way to identify pancakes is not to look only for flattened overdensities, but for caustics in the dark-matter flow. In the caustic-skeleton picture, the cosmic web forms when the Lagrangian dark-matter sheet folds into Eulerian space. A wall is then a three-stream region bounded by cusp caustics. The relevant physical condition is therefore shell crossing and multistreaming, not just high projected density.

In the Zel'dovich approximation,

$ vb(x)(vb(q), t) = vb(q) - b(t) grad Psi(vb(q)) $

so the deformation tensor is related to the Hessian of the primordial displacement potential. The fold condition

$ lambda_1 = b_c^(-1) $

marks shell crossing, while the wall condition is associated with the cusp caustic,

$ vb(v)_1 dot grad lambda_1 = 0 $

In this framework, Zel'dovich pancakes are proto-walls of the cosmic web: the first multistream wall-like structures from which filaments and knots later develop @hertzsch_new_2025.

= Conclusion

The Zel'dovich approximation is useful because it gives a simple geometric picture of the first nonlinear stage of structure formation. Instead of treating collapse as spherical, it follows particles in Lagrangian coordinates and relates collapse to the eigenvalues of the deformation tensor. Since one eigenvalue usually reaches the collapse condition first, the first nonlinear structures are flattened caustics: Zel'dovich pancakes.

The approximation is most reliable up to shell crossing. After that point, it correctly indicates where collapse begins, but it lets streams pass through one another too freely. The adhesion model repairs this at a phenomenological level by keeping collapsed matter concentrated, turning the first pancakes into a persistent network of sheets, filaments, and knots.

Pancakes are also not only mathematical objects. If baryons take part in the collapse, shocks, heating, cooling, and neutral hydrogen can produce observable signatures such as CMB spectral distortions, Ly$alpha$ emission, and redshifted 21-cm signals. Observational searches connect this idea to data, while modern caustic-skeleton methods make the definition sharper: a true pancake should be a wall-like multistream region produced by the folding of the dark-matter sheet, not merely a flat overdensity.

Overall, the Zel'dovich approximation links the primordial power spectrum, Lagrangian deformation, shell crossing, and the geometry of the cosmic web. Even when full simulations are needed for detailed evolution, it remains a useful language for understanding why cosmic structure naturally separates into voids, sheets, filaments, and knots.

= Acknowledgements

I would like to thank you sir for teaching us over the past year. I greatly enjoyed the courses, and will never forget this past year.

I am also grateful to Prof. Bagla for his help with the numerical part of this work. His guidance was very useful while I was implementing the Zel'dovich approximation, and I also compiled his old Fortran code for a two-dimensional Zel'dovich calculation. I have included this version, along with visualizations for different values of the scale parameter, on the project webpage: #link("https://pseudofractal.github.io/CosmicWebs/docs/prof_bagla_zeldovich.html")[Prof. Bagla's Zel'dovich calculation].

= References
#bibliography("references.bib", title: "")

