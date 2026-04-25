from pathlib import Path

import numpy as np
import plotly.graph_objects as go
from plotly.subplots import make_subplots

try:
  from .generate_docs_index import write_index
except ImportError:
  from generate_docs_index import write_index

DATA_DIR = Path("data")
DOCS_DIR = Path("docs")

PAPER_BG = "#020617"
PLOT_BG = "#030712"
GRID = "rgba(148, 163, 184, 0.12)"
TEXT = "#e2e8f0"
SUBTLE = "#94a3b8"
COSMIC_SCALE = [
  [0.0, "#020617"],
  [0.18, "#172554"],
  [0.38, "#4c1d95"],
  [0.62, "#7c3aed"],
  [0.82, "#22d3ee"],
  [1.0, "#f8fafc"],
]
ISOSURFACE_SCALE = [
  [0.0, "#312e81"],
  [0.45, "#7c3aed"],
  [0.78, "#22d3ee"],
  [1.0, "#facc15"],
]


def load_field(name: str, prefix: str = "") -> np.ndarray:
  return np.load(DATA_DIR / f"{prefix}{name}.npy")


def load_config(prefix: str = "") -> dict[str, float]:
  box_size, n_mesh, n_particles, growth_factor, ic_amplitude = load_field(
    "config", prefix
  )
  return {
    "box_size": float(box_size),
    "n_mesh": int(round(n_mesh)),
    "n_particles": int(round(n_particles)),
    "growth_factor": float(growth_factor),
    "ic_amplitude": float(ic_amplitude),
  }


def make_coordinates(shape, box_size: float):
  nx, ny, nz = shape
  dx = box_size / nx

  x = (np.arange(nx) + 0.5) * dx
  y = (np.arange(ny) + 0.5) * dx
  z = (np.arange(nz) + 0.5) * dx

  return np.meshgrid(x, y, z, indexing="ij")


def percentile_limits(
  field: np.ndarray, low: float, high: float
) -> tuple[float, float]:
  zmin = float(np.percentile(field, low))
  zmax = float(np.percentile(field, high))
  if np.isclose(zmin, zmax):
    zmin -= 1.0
    zmax += 1.0
  return zmin, zmax


def style_figure(fig: go.Figure):
  fig.update_layout(
    paper_bgcolor=PAPER_BG,
    plot_bgcolor=PLOT_BG,
    font=dict(color=TEXT),
    title_font=dict(color=TEXT, size=24),
    margin=dict(l=24, r=24, b=24, t=72),
  )


def add_heatmap(
  fig: go.Figure,
  row: int,
  col: int,
  field: np.ndarray,
  x: np.ndarray,
  y: np.ndarray,
  x_label: str,
  y_label: str,
  colorbar_title: str,
  zmin: float,
  zmax: float,
  show_colorbar: bool,
):
  fig.add_trace(
    go.Heatmap(
      x=x,
      y=y,
      z=field.T,
      colorscale=COSMIC_SCALE,
      zmin=zmin,
      zmax=zmax,
      showscale=show_colorbar,
      colorbar=dict(title=colorbar_title, tickcolor=SUBTLE, tickfont=dict(color=TEXT)),
      hovertemplate="x=%{x:.1f}<br>y=%{y:.1f}<br>δ=%{z:.3f}<extra></extra>",
    ),
    row=row,
    col=col,
  )
  fig.update_xaxes(
    title_text=x_label,
    row=row,
    col=col,
    showgrid=False,
    zeroline=False,
    color=SUBTLE,
  )
  fig.update_yaxes(
    title_text=y_label,
    row=row,
    col=col,
    showgrid=False,
    zeroline=False,
    color=SUBTLE,
    scaleanchor=f"x{col}",
    scaleratio=1,
  )


def plot_density_slices(
  box_size: float,
  growth_factor: float,
  data_prefix: str = "",
  html_prefix: str = "",
  subtitle_suffix: str = "",
):
  xy = load_field("final_delta_xy_slice", data_prefix)
  xz = load_field("final_delta_xz_slice", data_prefix)
  yz = load_field("final_delta_yz_slice", data_prefix)
  x = np.linspace(0.0, box_size, xy.shape[0], endpoint=False)
  y = np.linspace(0.0, box_size, xy.shape[1], endpoint=False)
  z = np.linspace(0.0, box_size, xz.shape[1], endpoint=False)
  zmin, zmax = percentile_limits(
    np.concatenate([xy.ravel(), xz.ravel(), yz.ravel()]), 3.0, 99.0
  )

  fig = make_subplots(
    rows=1,
    cols=3,
    subplot_titles=("XY Central Slice", "XZ Central Slice", "YZ Central Slice"),
    horizontal_spacing=0.05,
  )
  add_heatmap(fig, 1, 1, xy, x, y, "x", "y", "δ", zmin, zmax, False)
  add_heatmap(fig, 1, 2, xz, x, z, "x", "z", "δ", zmin, zmax, False)
  add_heatmap(fig, 1, 3, yz, y, z, "y", "z", "δ", zmin, zmax, True)
  fig.update_layout(
    title=(
      f"Cosmic Web Cross-Sections"
      f"<br><sup>Central density slices at D={growth_factor:.1f}{subtitle_suffix}</sup>"
    ),
    height=560,
    width=1480,
  )
  fig.update_annotations(font=dict(color=TEXT, size=16))
  style_figure(fig)

  outpath = DOCS_DIR / f"{html_prefix}density_slices.html"
  fig.write_html(outpath, include_plotlyjs="cdn")
  print(f"Saved {outpath}")


def plot_density_isosurfaces(
  field: np.ndarray,
  box_size: float,
  growth_factor: float,
  html_prefix: str = "",
  subtitle_suffix: str = "",
):
  X, Y, Z = make_coordinates(field.shape, box_size)
  values = field.ravel()
  isomin = float(np.percentile(values, 94.0))
  isomax = float(np.percentile(values, 99.8))

  fig = go.Figure(
    data=go.Isosurface(
      x=X.ravel(),
      y=Y.ravel(),
      z=Z.ravel(),
      value=values,
      isomin=isomin,
      isomax=isomax,
      surface_count=3,
      opacity=0.22,
      colorscale=ISOSURFACE_SCALE,
      caps=dict(x_show=False, y_show=False, z_show=False),
      colorbar=dict(title="δ", tickcolor=SUBTLE, tickfont=dict(color=TEXT)),
      hovertemplate="x=%{x:.1f}<br>y=%{y:.1f}<br>z=%{z:.1f}<br>δ=%{value:.3f}<extra></extra>",
    )
  )

  fig.update_layout(
    title=(
      f"Cosmic Web Volume"
      "<br><sup>Interactive high-density isosurfaces "
      f"at D={growth_factor:.1f}{subtitle_suffix}</sup>"
    ),
    scene=dict(
      xaxis=dict(
        title="x",
        color=SUBTLE,
        gridcolor=GRID,
        zerolinecolor=GRID,
        showbackground=True,
        backgroundcolor="rgba(15, 23, 42, 0.85)",
      ),
      yaxis=dict(
        title="y",
        color=SUBTLE,
        gridcolor=GRID,
        zerolinecolor=GRID,
        showbackground=True,
        backgroundcolor="rgba(9, 9, 24, 0.88)",
      ),
      zaxis=dict(
        title="z",
        color=SUBTLE,
        gridcolor=GRID,
        zerolinecolor=GRID,
        showbackground=True,
        backgroundcolor="rgba(10, 25, 47, 0.86)",
      ),
      aspectmode="cube",
      camera=dict(eye=dict(x=1.95, y=1.75, z=1.35)),
      bgcolor=PLOT_BG,
    ),
  )
  style_figure(fig)

  outpath = DOCS_DIR / f"{html_prefix}density_isosurfaces.html"
  fig.write_html(outpath, include_plotlyjs="cdn")
  print(f"Saved {outpath}")
  print(f"isomin = {isomin:.6g}, isomax = {isomax:.6g}")


def render_dataset(
  data_prefix: str = "",
  html_prefix: str = "",
  subtitle_suffix: str = "",
):
  config = load_config(data_prefix)
  field = load_field("final_delta", data_prefix)

  print(
    "Loaded config:",
    f"prefix={data_prefix or 'default'}",
    f"n_mesh={config['n_mesh']}",
    f"n_particles={config['n_particles']}",
    f"box_size={config['box_size']}",
    f"growth_factor={config['growth_factor']}",
    f"ic_amplitude={config['ic_amplitude']}",
  )

  plot_density_slices(
    config["box_size"],
    config["growth_factor"],
    data_prefix,
    html_prefix,
    subtitle_suffix,
  )
  plot_density_isosurfaces(
    field,
    config["box_size"],
    config["growth_factor"],
    html_prefix,
    subtitle_suffix,
  )


def main():
  DOCS_DIR.mkdir(parents=True, exist_ok=True)

  render_dataset()
  render_dataset(
    data_prefix="no_powa_",
    html_prefix="no_powa_",
    subtitle_suffix=", white-noise initial field",
  )
  render_dataset(
    data_prefix="k_powa_",
    html_prefix="k_powa_",
    subtitle_suffix=", P(k)=k initial field",
  )
  outpath = write_index()
  print(f"Saved {outpath}")


if __name__ == "__main__":
  main()
