#import "@preview/catppuccin:1.1.0": catppuccin, flavors
#import "@preview/physica:0.9.8": *;
#import "@preview/equate:0.3.2": equate
#import "@preview/unify:0.8.0": num, numrange, qty, qtyrange

#show: catppuccin.with(flavors.latte)
#let flavor = flavors.latte
#show: equate.with(breakable: true, sub-numbering: true)
#set math.equation(numbering: "(1.1)")


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


#let cover-page = {
  set align(center + horizon)
  text(size: 4 * text-size, weight: "extrabold")[Zel'dovich Approximation]
  linebreak()
  v(2em)
  text(size: 1.25 * text-size, weight: "semibold")[
    An attempt at understanding the large scale structure of the universe.
  ]

  v(5 * text-size)
  text(size: 1.5 * text-size)[Kshitish Kumar Ratha]
  linebreak()
  text(size: 1.25 * text-size)[MS22174]
  linebreak()
  datetime.today().display()
  v(5 * text-size)
  text(
    size: 0.75 * text-size,
  )[All the code, source files and visualizations can be accessed on this #link("https://pseudofractal.github.io/CosmicWebs/")[webpage].]
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

The large-scale structure of the Universe is not a random collection of isolated galaxies, but a connected web of voids, sheets, filaments, and clusters. A central problem in cosmology is to understand how such structure emerged from the nearly homogeneous early Universe. The Zel'dovich approximation provides one of the simplest and most physically transparent answers: small initial perturbations evolve through anisotropic gravitational collapse, with matter first compressing along one principal direction to form flattened caustics known as pancakes @zeldovich_gravitational_1970.

This term paper follows the development of that idea from its original Lagrangian formulation to its later physical and observational implications. The first part discusses how the deformation tensor determines the geometry of collapse and why pancakes arise generically before filaments and knots. The next part considers how shocked gas in pancakes could produce observable signatures, including spectral distortions, Ly$alpha$ emission, and redshifted 21-cm signals @sunyaev_formation_1972. The review then connects the original approximation to the adhesion model, where post-shell-crossing matter remains concentrated in a web-like network of sheets, filaments, and clumps @shandarin_large-scale_1989.

Finally, the discussion moves from dynamics to initial conditions and observations. Transfer functions determine which primordial modes survive into the nonlinear regime, while observational searches attempt to identify pancakes either through high-redshift neutral hydrogen or through wall-like structures around galaxy clusters @eisenstein_power_1999 @uson_radio_1991. Modern caustic-skeleton methods sharpen the interpretation by defining pancakes not merely as flattened overdensities, but as multistream caustic structures in the dark-matter flow @hertzsch_new_2025.

= Zel'dovich Approximation

Zel'dovich proposed an approximate treatment of gravitational instability in an expanding, pressureless medium, extending linear perturbation theory beyond the small density contrast regime @zeldovich_gravitational_1970. The method describes particle motion using Lagrangian coordinates, where $vb(q)$ is the initial position of a particle and $vb(r)(t, vb(q))$ is its position at time $t$:

$ vb(r)(t, vb(q)) = a(t) vb(q) + b(t) vb(p)(vb(q)) . $

The term $a(t) vb(q)$ represents cosmological expansion, while $b(t) vb(p)(vb(q))$ gives the growing displacement caused by the initial perturbation field. Since $vb(p)$ is fixed by the initial conditions, the mapping from $vb(q)$ to $vb(r)$ entirely determines the later velocity and density fields.

The local deformation of a fluid element is described by

$
  D_(i k) = frac(partial r_i, partial q_k)
  = a(t) delta_(i k) + b(t) frac(partial p_i, partial q_k) .
$

Choosing axes along the principal directions of deformation gives

$
  D = mat(
    a(t) - alpha b(t), 0, 0;
    0, a(t) - beta b(t), 0;
    0, 0, a(t) - gamma b(t)
  ) .
$

Thus an initially cubic volume element is stretched or compressed along three principal axes. Conservation of mass then gives the density as

$ rho (a - alpha b)(a - beta b)(a - gamma b) = overline(rho) a^3 . $

The quantities $alpha$, $beta$, and $gamma$ are the local eigenvalues of the deformation field and vary with the Lagrangian position $vb(q)$. The density becomes singular when one of the factors in the denominator vanishes. Since an exact equality between two or three eigenvalues is non-generic, collapse first occurs along a single principal axis, usually the one corresponding to the largest eigenvalue. Thus the Zel'dovich approximation predicts the formation of flattened sheet-like structures, or pancakes, rather than spherical collapse.

Zel'dovich emphasizes that the Lagrangian approximation is preferable to a purely Eulerian extrapolation of linear theory, such as
$ rho(vb(r), t) = overline(rho)(t) [1 + f(t) delta(vb(r) / a(t))] . $
While such a form agrees with linear theory, it can behave unphysically in the nonlinear regime, even predicting negative densities. In contrast, the Zel'dovich mapping assigns a trajectory to each particle, so the density is obtained from the deformation of volume elements. Even when the density formally diverges at shell crossing, the gravitational potential and acceleration remain finite, so the approximation retains a controlled qualitative meaning at the onset of collapse.

For small perturbations, the Zel'dovich density reduces to the linear result
$
  rho(vb(q), t) = overline(rho) [1 + (alpha + beta + gamma) b(t) / a(t)]
  = overline(rho) [1 + S(vb(q)) f(t)] .
$
Thus the initial linear growth depends only on the sum $alpha + beta + gamma$. However, the later nonlinear evolution depends separately on the three deformation eigenvalues $alpha$, $beta$, and $gamma$.

Zel'dovich applied the approximation to the post-recombination Universe, where matter can be treated as effectively pressureless on sufficiently large scales. For perturbations with characteristic mass $M ~ 10^12 M_sun$, the Jeans mass after recombination is much smaller, while the perturbation scale remains below the horizon scale. Thus pressure and relativistic effects may be neglected, making the Newtonian, pressureless approximation applicable. Under these assumptions, the dominant nonlinear outcome is not spherical collapse but anisotropic collapse along the direction of maximum deformation.

The key result is the formation of a caustic, or "pancake", when the Lagrangian-to-Eulerian map first becomes singular. In one dimension, the density is inversely proportional to the deformation factor,
$ rho prop (dv(r, q))^(-1) , $
so the first singularity occurs when $dv(r, q) = 0$. Expanding the trajectory near the first collapse point gives
$ r - r_c prop (q - q_c)^3, quad rho prop (r - r_c)^(-2"/"3) . $
Thus the approximation predicts a formally infinite density at the caustic, corresponding physically to shell crossing and compression of matter into a thin sheet.

Zel'dovich argued that after shell crossing the cold matter streams cannot remain described by the single-valued dust solution. The infalling matter shocks, converts kinetic energy into heat, and forms a compressed layer with finite surface density. Although the volume density diverges in the idealized approximation, the surface density of the pancake remains finite. This makes the singularity physically meaningful: it marks the onset of nonlinear structure formation rather than a literal infinite-density object.

The broader implication is that large-scale structure formation begins through flattened, sheet-like condensations rather than isolated spherical objects. Within this picture, galaxies and related systems form later inside or around these compressed layers, while only part of the matter becomes gravitationally bound at first. Zel'dovich therefore proposed a hierarchical physical sequence: initial perturbations grow gravitationally, collapse first along one axis into pancakes, undergo shocks and heating, and later fragment or condense into smaller bound structures.

This argument also shows why the spherical-collapse model is limited. The nonlinear evolution depends not only on the initial density amplitude, but also on the full deformation tensor and the surrounding tidal field.

= Observational Appearance of Pancakes

Sunyaev and Zel'dovich @sunyaev_formation_1972 extended the pancake picture by asking how the compressed intergalactic gas produced during nonlinear collapse could be observed. In their model, the formation of pancakes is accompanied by shock waves. These shocks heat a fraction of the intergalactic gas to high temperatures, while other regions cool and condense into protogalaxies or protoclusters.

A major observational consequence is the interaction of hot shocked gas with the relic radiation field. Electrons with temperature $T_e$ inverse-Compton scatter background photons, producing a decrement in the Rayleigh--Jeans part of the spectrum,

$ frac(Delta T, T) = - 2 sigma_T N_e frac(k T_e, m_e c^2) $

Physically, photons gain energy from the hot electrons, so the low frequency part of the radiation field is depleted while higher frequency photons are enhanced (thermal SZ effect). In the pancake scenario, such temperature fluctuations in the relic radiation would trace large inhomogeneous regions of hot intergalactic gas.

Sunyaev and Zel'dovich also emphasized line and continuum signatures from cooler gas. As shocked pancake gas cools to $T ~ 10^4 "K"$, much of its radiation is expected to emerge in the Ly$alpha$ line, with additional continuum and helium-line emission. Since these regions form at redshifts of order $z_c ~ 3-5$, the radiation would be observed in redshifted ultraviolet or optical bands. They also suggested that compressed neutral hydrogen could be detectable through redshifted 21-cm emission, especially because its spin temperature would exceed the temperature of the relic radiation.

The paper further connects pancakes to the origin of protogalaxies and clusters. For perturbation masses $M ~ 10^12-10^14 M_sun$, shock heating and radiative cooling produce a multiphase medium: part of the gas remains hot and ionized, part cools to form dense objects, and only a fraction becomes gravitationally bound immediately. This picture naturally associates large pancakes with protoclusters, while smaller condensations within them may later become galaxies or galactic nuclei. The model therefore gives a physical route from primordial perturbations to a network of heated gas, cooled fragments, and bound structures.

The observational implications are important because they make the pancake model testable. Hot gas should contribute to X-ray and ultraviolet backgrounds, produce spectral distortions of the cosmic microwave background, and generate spatial fluctuations in the relic radiation. Cooler neutral or partially ionized gas should appear through redshifted Ly$alpha$ or 21-cm signatures. At the same time, the observed X-ray background limits how much gas can be shock-heated to very high temperatures, so the pancake model is constrained by the thermal history of the intergalactic medium.

The pancake model thus has some gravitational instability first creating anisotropic collapse; shell crossing producing shocks; shocks heating and ionizing the gas; radiative cooling allowing fragments to form; and the remaining hot gas leaving observable signatures in the cosmic radiation fields.

= Adhesion Model

Shandarin and Zel'dovich later placed the pancake model in a broader theory of nonlinear large-scale structure formation @shandarin_large-scale_1989. Their central point was that gravitational instability does not merely amplify the initial density field; it reorganizes matter into an intermittent spatial pattern. Initially small, nearly Gaussian perturbations evolve into a network of dense sheets, filaments, and compact clumps separated by extended low-density regions. In this sense, the nonlinear density field resembles intermittency in turbulence: most of the volume becomes underdense, while a large fraction of the mass is concentrated in geometrically thin structures.

The starting point is the same Lagrangian picture used in the Zel'dovich approximation. For inertial motion one may write

$ vb(x)(t, vb(q)) = vb(q) + t vb(v)(vb(q)) , $

while in an expanding self-gravitating universe the Zel'dovich form becomes

$ vb(r)(t, vb(q)) = a(t) [vb(q) - b(t) vb(s)(vb(q))] , $

where $vb(s) = grad Phi$ is determined by the initial perturbation field. This formal similarity explains why the geometry of gravitational collapse can be studied using the simpler problem of freely moving cold matter. Shell crossing, caustics, and multistream regions arise naturally when the Lagrangian to Eulerian map becomes singular.

The behavior after shell crossing depends on the type of matter. Collisionless matter develops multistream flows, gas develops shocks, and idealized "sticky dust" collapses into singular mass concentrations. Shandarin and Zel'dovich emphasized that the sticky-dust limit is especially useful because it captures the tendency of matter to remain concentrated after collapse. This Burgers-type description underlies the adhesion model, where an effective sticking prescription keeps collapsed matter concentrated after shell crossing @burgers_hopf-cole_1974.

This idea leads to the adhesion model. The original Zel'dovich approximation is accurate up to the formation of caustics, but after shell crossing it allows particles to stream too far through the pancake. In a self-gravitating system, however, gravity slows the streams and partially confines them. The adhesion approximation models this "gravitational sticking" by replacing multistream regions with thin sheets, filaments, and knots. It therefore extends the Zel'dovich picture from the first pancake to a connected cosmic web.

In two and three dimensions, the geometry is governed by the eigenvalues of the deformation tensor. The density may be written as,

$ rho = frac(rho_0, (1 - b alpha)(1 - b beta)(1 - b gamma)) $

The first collapse occurs along the direction associated with the largest eigenvalue. Subsequent collapse along a second and third axis produces filaments and compact clumps. Therefore the nonlinear sequence is

$ "Sheet" arrow "Filament" arrow "Clump" $

This hierarchy is geometric rather than purely spherical: sheets form first by one-axis collapse, filaments by two-axis collapse, and knots by three-axis collapse.

This is also the paper that connects this structure to catastrophe theory and geometrical optics. Caustics in the matter distribution are analogous to bright caustic patterns produced by light reflected or refracted from rippled water. In both cases, a smooth initial field is mapped into a sharply concentrated pattern by the folding of trajectories. This analogy clarifies why the cosmic web is not a random collection of isolated overdensities, but a connected network produced by the singularities of a continuous mapping.

Cosmologically, Shandarin and Zel'dovich used this framework to compare hot and cold dark matter scenarios. Hot dark matter erases small-scale perturbations by free streaming, producing a more top-down evolution in which large pancakes form first. Cold dark matter preserves small-scale fluctuations, leading to bottom-up clustering. However, the paper argues that the distinction is not absolute: depending on the slope and cutoff of the initial power spectrum, nonlinear evolution may contain both hierarchical clustering and large-scale cellular structure.

= Power Spectra and Transfer Functions

The next question is what initial fluctuation spectrum is supplied to this nonlinear evolution. Eisenstein and Hu give a compact linear-theory description of this input by fitting the matter transfer function for cosmologies containing cold dark matter, baryons, and massive neutrinos @eisenstein_power_1999.

The late-time matter power spectrum can be written as

$ P(k, z) = A k^n T^2(k, z) D^2(z), $

where $A k^n$ is the primordial spectrum, $T(k, z)$ is the transfer function, and $D(z)$ is the linear growth factor. Eisenstein and Hu use the dimensionless form

$ k^3 P(k, z)/(2 pi^2)
= delta_H^2
  ( (c k)/ H_0)^(3+n)
  T^2(k, z)
  (D_1^2(z))/(D_1^2(0)) $

Thus the primordial spectrum is not observed directly: it is reshaped by the microphysics of the early Universe before entering the nonlinear Zel'dovich or adhesion stage.

For cold dark matter with baryons and massive neutrinos, Eisenstein and Hu write the transfer function as a product of a time-independent master function and a scale-dependent growth factor,

$ T_(c b)(k, z) = T_("master")(k) (D_(c b)(k, z))/(D_1(z)) $

$ T_(c b nu)(k, z) = T_("master")(k) (D_(c b nu)(k, z))/(D_1(z)) $

Here $T_(c b)$ describes the density weighted CDM along baryon perturbations, while $T_(c b nu)$ includes the massive neutrino component.

The relevant physical scales are the horizon at matter-radiation equality, the baryon sound horizon, and the neutrino free-streaming scale. Equality sets the broad turnover of $P(k)$; baryon-photon coupling suppresses small-scale baryonic power and produces acoustic structure; massive neutrinos damp power below their free-streaming scale. Consequently, baryons and neutrinos both reduce small-scale power, but for different physical reasons.\
The transfer function determines which Fourier modes survive with significant amplitude, while the Zel'dovich and adhesion approximations describe how those modes later collapse anisotropically. In this sense, the power spectrum fixes the initial conditions for the formation of pancakes, filaments, and knots.

= Numerical Illustration

To connect the analytic discussion with a visual example, I implemented a simple Zel'dovich-realization code in Rust. The code generates an initial Gaussian density field in Fourier space and imposes Hermitian symmetry so that the real-space field is real. From the density contrast it computes the Zel'dovich displacement field,

$ vb(psi)(vb(k)) = (i vb(k))/k^2  delta(vb(k)) $

and moves particles from their initial Lagrangian grid positions according to

$ vb(x) = vb(q) + D vb(psi)(vb(q)) . $

The displaced particles are then deposited back onto a mesh using cloud-in-cell interpolation, giving an evolved density contrast field. In parallel, the code computes the deformation tensor in Fourier space,

$ d_(i j)(vb(k)) = - (k_i k_j)/k^2 delta(vb(k)) $

transforms it to real space, diagonalizes the local symmetric tensor, and classifies each cell by the number of collapsed axes. Cells are labelled as voids, pancakes, filaments, or knots depending on whether zero, one, two, or three deformation eigenvalues cross the collapse threshold. This gives a direct numerical visualization of the sequence emphasized by the Zel'dovich approximation: one-axis collapse forms pancakes, two-axis collapse forms filaments, and three-axis collapse forms compact knots.

The code for the same can be found on my webpage @pseudofractal_cosmic_webs, along with the resulting visualizations of the density field.

= Observational Searches for Pancakes

Uson, Bagri, and Cornwell reported a VLA search for redshifted 21-cm emission and absorption from neutral hydrogen at $z approx 3.4$ toward the radio source 0902+343. Their observational criterion followed the expectation of Sunyaev and Zel'dovich: a massive protocluster-scale pancake should contain a large reservoir of neutral gas and appear as a broad redshifted 21-cm emission feature, with a characteristic velocity width of order $~ 200 "km s"^(-1)$ @uson_radio_1991.

They detected 21-cm absorption at $z = 3.3968 +- 0.0004$ against the known radio galaxy and a separate emission feature at $z = 3.3970 +- 0.0003$, offset by $33'$ on the sky. The emission feature had a velocity width of about $180 plus.minus 40 "km s"^(-1)$ and was interpreted as neutral hydrogen associated with a massive, not yet virialized protocluster. From the inferred gas mass, transverse scale, and surface density, the authors argued that the object was consistent with the Sunyaev-Zel'dovich pancake picture and identified it as a candidate Zel'dovich pancake.

A more modern criterion for identifying pancakes treats them not merely as flattened overdensities, but as caustics in the dark matter flow. In the caustic skeleton framework, the cosmic web is described by the folding of the Lagrangian dark matter sheet into Eulerian space. A wall corresponds to a three stream region bounded by cusp caustics, so the physically relevant signature is shell crossing and multistreaming, not simply high projected density. In the Zel'dovich approximation, where $vb(x)(vb(q), t) = vb(q) - b(t) grad Psi(vb(q))$, the deformation tensor is proportional to the Hessian of the primordial displacement potential. The wall condition is associated with the cusp caustic,
$ vb(v)_1 dot grad lambda_1 = 0, $
while the fold condition $lambda_1 = b_c^(-1)$ marks shell crossing. Thus, in this framework, Zel'dovich pancakes are the proto-walls of the cosmic web: the first multistream structures from which filaments and knots later develop @hertzsch_new_2025.

= Conclusion

The Zel'dovich approximation is powerful because it captures the first nonlinear step of gravitational structure formation while remaining analytically simple. By following particles in Lagrangian coordinates, it shows that collapse is controlled by the eigenvalues of the deformation tensor. Since the largest eigenvalue generically reaches the collapse condition first, the first nonlinear objects are not spherical condensations but flattened caustics: Zel'dovich pancakes.

The later development of the theory clarifies both the strength and the limitation of the approximation. It correctly identifies the geometry and timing of first shell crossing, but after shell crossing it allows streams to pass through one another too freely. The adhesion model modifies this behavior by introducing effective sticking, turning the first pancakes into a persistent network of sheets, filaments, and knots. In this way, the original pancake picture becomes part of the broader cosmic-web description.

The observational importance of the model lies in the fact that pancakes are not only mathematical caustics. If baryonic gas participates in the collapse, shocks, heating, cooling, and neutral hydrogen can produce observable signatures. Searches for redshifted 21-cm emission or absorption, and later attempts to identify cold sheet-like structures around galaxy clusters, show how the theory can be connected to data. However, modern work also shows that a convincing identification should go beyond projected overdensity alone: a true pancake is best understood as a wall-like multistream region produced by the folding of the dark-matter sheet.

Overall, the Zel'dovich approximation remains a foundational model because it links three levels of structure formation: the primordial power spectrum sets the initial perturbations, Lagrangian deformation determines anisotropic collapse, and shell crossing creates the first elements of the cosmic web. Even where more detailed simulations are required, the approximation provides the geometric language in which sheets, filaments, knots, and voids can be understood as parts of one continuous gravitational process.

= References
#bibliography("references.bib", title: "")
