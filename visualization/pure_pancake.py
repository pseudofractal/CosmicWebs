from pathlib import Path

import numpy as np
import plotly.graph_objects as go

try:
  from .generate_docs_index import write_index
  from .plots import GRID, PLOT_BG, SUBTLE, style_figure
except ImportError:
  from generate_docs_index import write_index
  from plots import GRID, PLOT_BG, SUBTLE, style_figure

DOCS_DIR = Path("docs")
OUTPATH = DOCS_DIR / "pure-pancake.html"
BOX_SIZE = 180.0
SLAB_COUNT = 5

SLAB_COLORS = [
  "#312e81",
  "#5b21b6",
  "#7c3aed",
  "#22d3ee",
  "#facc15",
]


def make_surface_grid(samples: int = 90) -> tuple[np.ndarray, np.ndarray]:
  axis = np.linspace(0.0, BOX_SIZE, samples)
  return np.meshgrid(axis, axis, indexing="xy")


def slab_height(
  x: np.ndarray,
  y: np.ndarray,
  base_height: float,
  phase: float,
  amplitude_scale: float,
) -> np.ndarray:
  broad_bend = 8.0 * np.sin(2.0 * np.pi * x / BOX_SIZE + 0.35)
  broad_bend += 6.0 * np.sin(2.0 * np.pi * y / BOX_SIZE - 0.4)

  wave_pattern = amplitude_scale * 5.2 * np.sin(4.0 * np.pi * x / BOX_SIZE + phase)
  wave_pattern += (
    amplitude_scale * 3.8 * np.sin(3.0 * np.pi * y / BOX_SIZE - 0.6 * phase)
  )
  wave_pattern += (
    amplitude_scale * 2.4 * np.sin(2.0 * np.pi * (x + 0.7 * y) / BOX_SIZE + 1.4 * phase)
  )

  return base_height + broad_bend + wave_pattern


def add_pancake_slabs(fig: go.Figure) -> None:
  x, y = make_surface_grid()
  z_levels = np.linspace(44.0, 132.0, SLAB_COUNT)

  for index, (base_height, color) in enumerate(zip(z_levels, SLAB_COLORS, strict=True)):
    phase = 0.55 * index
    amplitude_scale = 0.92 + 0.12 * index
    z = slab_height(x, y, base_height, phase, amplitude_scale)
    surface_color = np.full_like(z, index, dtype=float)

    fig.add_trace(
      go.Surface(
        x=x,
        y=y,
        z=z,
        surfacecolor=surface_color,
        cmin=index,
        cmax=index + 1,
        colorscale=[[0.0, color], [1.0, color]],
        showscale=False,
        opacity=0.58,
        hovertemplate=(
          "x=%{x:.1f}<br>y=%{y:.1f}<br>z=%{z:.1f}<br>slab=%{customdata}<extra></extra>"
        ),
        customdata=np.full_like(z, index + 1, dtype=int),
        contours={
          "x": {"show": False},
          "y": {"show": False},
          "z": {"show": False},
        },
        lighting={
          "ambient": 0.58,
          "diffuse": 0.85,
          "specular": 0.18,
          "roughness": 0.74,
          "fresnel": 0.08,
        },
        lightposition={"x": 160, "y": -120, "z": 260},
      )
    )


def build_figure() -> go.Figure:
  fig = go.Figure()
  add_pancake_slabs(fig)
  fig.update_layout(
    title="A cosmic pancake!",
    scene=dict(
      xaxis=dict(
        title="x",
        range=[0.0, BOX_SIZE],
        color=SUBTLE,
        gridcolor=GRID,
        zerolinecolor=GRID,
        showbackground=True,
        backgroundcolor="rgba(15, 23, 42, 0.85)",
      ),
      yaxis=dict(
        title="y",
        range=[0.0, BOX_SIZE],
        color=SUBTLE,
        gridcolor=GRID,
        zerolinecolor=GRID,
        showbackground=True,
        backgroundcolor="rgba(9, 9, 24, 0.88)",
      ),
      zaxis=dict(
        title="z",
        range=[0.0, BOX_SIZE],
        color=SUBTLE,
        gridcolor=GRID,
        zerolinecolor=GRID,
        showbackground=True,
        backgroundcolor="rgba(10, 25, 47, 0.86)",
      ),
      aspectmode="cube",
      camera=dict(eye=dict(x=1.85, y=1.65, z=1.1)),
      bgcolor=PLOT_BG,
    ),
    width=1220,
    height=980,
  )
  style_figure(fig)
  return fig


def main() -> None:
  DOCS_DIR.mkdir(parents=True, exist_ok=True)
  fig = build_figure()
  fig.write_html(OUTPATH, include_plotlyjs="cdn")
  print(f"Saved {OUTPATH}")
  index_path = write_index()
  print(f"Saved {index_path}")


if __name__ == "__main__":
  main()
