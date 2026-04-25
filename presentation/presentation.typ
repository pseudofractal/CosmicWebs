#import "@preview/polylux:0.4.0": *
#import "@preview/pinit:0.2.2": *
#import "@preview/physica:0.9.8": *
#set page(paper: "presentation-16-9", fill: rgb("#1e1e2e"))

#let text-size = 20pt
#let heading-size = 1.5 * text-size
#let important-size = 1.2 * text-size
#let funsies-size = 0.8 * text-size

#set text(size: text-size, fill: rgb("#cdd6f4"), font: "Maple Mono")
#show figure: set text(size: text-size * 0.8)
#show heading: set text(fill: rgb("#74c7ec"))
#show heading: set align(center)
#show link: set text(fill: rgb("#94e2d5"), style: "oblique")

#let emph(term) = text(fill: rgb("#94e2d5"), term)
#let important(term, size: important-size) = text(
  fill: rgb("#b4befe"),
  size,
  align(
    center,
    box(
      stroke: 0.1 * text-size + rgb("#94e2d5"),
      outset: important-size * 0.75,
    )[#term],
  ),
)

#let funsies(term) = place(
  bottom + center,
  dx: 0pt,
  dy: heading-size,
  block(
    width: 100%,
    align(center)[#text(size: funsies-size, fill: rgb("#fab387"), term)],
  ),
)

#slide[
  #set align(horizon)
  #heading[#text(
    fill: rgb("#eba0ac"),
    size: 42pt,
  )[Making Comsic Pancakes!]]

  #v(2em)

  Kshitish Kumar Ratha\

  #v(1em)

  #text(
    size: 18pt,
    fill: rgb("#74c7ec"),
  )[And one of the most frustrating weeks of my 21 years existence.]

  #funsies[Look out for these fun bits]
]

#slide[
  = Cosmic Webs
  #v(1em)
  #figure(
    image("images/cosmic-web.jpg", width: 100%),
    caption: [Cosmic Webs by Davis et al. @noauthor_zeldovich_nodate],
  )
]

#slide[
  = The Paper That Started It All
  #v(1em)

  #columns(
    2,
    [#align(center)[#figure(
        image(
          "images/Zeldovich.jpg",
          width: 50%,
        ),
        caption: [Yakov "Ya" Zel'dovich],
      ) #colbreak() #figure(
        image(
          "images/zeldovich-first-paper.png",
          width: 66%,
        ),
        caption: [Paper from 1969],
      )]],
    gutter: 1em,
  )

]

#slide[
  == Original Form of Zel'dovich Approximation @zeldovich_gravitational_1970
  #v(1em)
  #align(center + horizon)[
    #text(size: 30pt)[$ vb(r) = a(t) vb(q) + b(t) vb(p(vb(q))) $]
  ]
  #v(1em)
  - $a(t) vb(q)$: Describes Cosmological Expansion
  - $b(t)$ grows more rapidly than $a(t)$ which causes #emph("gravitational instability").
  - #emph("Extrapolate") the above formula in regions where perturbations $(delta rho) / rho$ are #emph("not small").
  - $ a(Z) = 1/(1+Z) #h(1em) b(Z) = 2/5 1/(1+Z)^2 $
  #funsies(
    "Mentions the formula in appendix and refuses to elaborate about b(t)",
  )
]

#slide[
  = Connection with Caustics @shandarin_large-scale_1989
  #align(center + horizon)[
    #text(size: 30pt)[$ vb(x) = vb(q) + tau vb(v(vb(q))) $]
  ]
  - Spectrum of density perturbations $arrow.long.r$ affects the formation of structure $arrow.long.r$ #emph("top-down") or #emph("bottom-up") scenario.
  - Collapse of matter into #emph("caustics") which take the form of #emph("sheets, filaments and nodes").
  - The displacement field $vb(v)$ can be complex.
  - Rotations #emph("difficult to see") because of #emph("expansion").

  #text(size: 25pt, $ vb(v) = gradient Phi $)

]

#slide[
  = Cosmic Pancakes ?!
  #v(1em)
  #figure(
    image("images/my_ideal_pancakes.png", height: 78%),
    caption: [Pancakes in my head...],
  )
]

#slide[
  = Seeing Zel'dovich Approximation in Action
  #v(1em)
  Compared to the general simulations and computations that physicists do, calculation for Zel'dovich approximation is #emph("trivial").
  === Steps
  #v(1em)
  1. Generate a gaussian random field for density $delta$.
  2. Calculate the change in position $vb(v)$ using the formula $vb(v) = gradient Phi$ where $Phi$ is the potential related to $delta$.
  3. Assume all particles started uniformly spaced at $t=0$.
  4. Calculate the new position of particles using $vb(x) = vb(q) + tau vb(v(vb(q)))$ where $tau$ is some constant.

  #funsies("stonks?!!")
]

#slide[
  = Not so fast
  #v(1em)
  #figure(
    image("images/no_power.png"),
    caption: [Gaussian Random Delta #link("https://pseudofractal.github.io/CosmicWebs/no_powa_density_isosurfaces.html")[(Click Me)]],
  )
]

#slide[
  = Uhhh.. Did it work? @eisenstein_power_1999
  #v(1em)
  #figure(
    image("images/k_power.png"),
    caption: [Esienstein Form #link("https://pseudofractal.github.io/CosmicWebs/k_powa_density_isosurfaces.html")[(Click Me)]],
  )
]

#slide[
  = Magic Spectrum
  #v(1em)
  #figure(
    image("images/pancake_slices.png"),
    caption: [Some visible structure? #link("https://pseudofractal.github.io/CosmicWebs/pancakes_density_isosurfaces.html")[(Click Me)]],
  )
]

#slide[
  = Where is my pancake!!!!
  #v(1em)
  - Is the power spectrum still not working?
  - Do I really need to go through old CAMB code?
  - Should I ask Prof. Bagla?
  - Do I bite the bullet and read the Esienstein and Hu paper?
  - Should I keep falling prey to Sunk Cost Fallacy?

  #v(3em)

  #important[Are pancakes even real?]
]

#slide[
  = The Search For Pancakes @lindholmer_catalogue_nodate
  #v(1em)
  #figure(
    image("images/pancakes_by_others.png", height: 78%),
    caption: [This is a pancake?],
  )
]

#slide[
  = Maybe Pancakes Are The Blobs We Made Along The Way

  #v(0.5em)

  - Void fraction:     0.2078399658203125
  - Pancake fraction: 0.5223960876464844
  - Filament fraction:0.2500762939453125
  - Knot fraction:    0.019687652587890625

  #v(1em)
  #set text(size: 22pt)
  #set align(center + horizon)
  Does my code compile? #h(2em) #emph[Yes]\
  Does my code work? #h(2em) #emph[Probably]\
  Is the underlying physics correct? #h(2em) #emph[Who Knows?]\
  Are these Zel'dovich's pancakes? #h(2em) #emph[I don't think so]\
]

#slide[
  #bibliography("references.bib", title: "References")
]
