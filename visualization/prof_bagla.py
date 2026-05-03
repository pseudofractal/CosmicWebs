from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

import numpy as np
import plotly.graph_objects as go

try:
  from .generate_docs_index import write_index
  from .plots import GRID, PLOT_BG, SUBTLE, TEXT, style_figure
except ImportError:
  from generate_docs_index import write_index
  from plots import GRID, PLOT_BG, SUBTLE, TEXT, style_figure

PROJECT_ROOT = Path(__file__).resolve().parent.parent
PROF_BAGLA_DIR = PROJECT_ROOT / "prof_bagla"
DOCS_DIR = PROJECT_ROOT / "docs"
OUTPATH = DOCS_DIR / "prof_bagla_zeldovich.html"

NBOX = 256
EXPECTED_ROWS = NBOX * NBOX
UNITS = tuple(range(11, 16))
SNAPSHOT_FILES = tuple(PROF_BAGLA_DIR / f"fort.{unit}" for unit in UNITS)


def initial_lattice() -> np.ndarray:
  axis = np.arange(NBOX, dtype=float)
  x, y = np.meshgrid(axis, axis, indexing="ij")
  return np.column_stack((x.ravel(), y.ravel()))


def build_and_run_prof_bagla() -> None:
  if shutil.which("gfortran") is None:
    raise RuntimeError(
      "`gfortran` is not installed, so `prof_bagla/init.x` cannot be built in this environment."
    )

  subprocess.run(["make"], cwd=PROF_BAGLA_DIR, check=True)
  subprocess.run(["./init.x"], cwd=PROF_BAGLA_DIR, check=True)


def snapshot_files_exist() -> bool:
  return all(path.exists() for path in SNAPSHOT_FILES)


def load_snapshot(path: Path) -> np.ndarray:
  if not path.exists():
    raise FileNotFoundError(f"Missing Fortran output file: {path}")

  points = np.loadtxt(path)
  if points.ndim != 2 or points.shape[1] != 2:
    raise ValueError(f"Expected a 2-column point cloud in {path}, got shape {points.shape}")
  if points.shape[0] != EXPECTED_ROWS:
    raise ValueError(
      f"Expected {EXPECTED_ROWS} rows in {path}, got {points.shape[0]}"
    )

  return points


def load_snapshots() -> list[tuple[int, np.ndarray]]:
  snapshots: list[tuple[int, np.ndarray]] = []
  for a_value, path in zip(range(1, 6), SNAPSHOT_FILES, strict=True):
    snapshots.append((a_value, load_snapshot(path)))
  return snapshots


def make_slider_steps() -> list[dict]:
  steps = []
  for a_value in range(1, 6):
    frame_name = f"a={a_value}"
    steps.append(
      {
        "args": [[frame_name], {"frame": {"duration": 0, "redraw": True}, "mode": "immediate"}],
        "label": frame_name,
        "method": "animate",
      }
    )
  return steps


def build_figure(snapshots: list[tuple[int, np.ndarray]]) -> go.Figure:
  lattice = initial_lattice()
  first_a, first_snapshot = snapshots[0]

  fig = go.Figure(
    data=[
      go.Scattergl(
        x=lattice[:, 0],
        y=lattice[:, 1],
        mode="markers",
        name="Initial lattice",
        marker=dict(size=1.3, color="rgba(148, 163, 184, 0.20)"),
        hoverinfo="skip",
      ),
      go.Scattergl(
        x=first_snapshot[:, 0],
        y=first_snapshot[:, 1],
        mode="markers",
        name=f"Displaced particles (a={first_a})",
        marker=dict(size=2.1, color="#22d3ee", opacity=0.62),
        hovertemplate="x=%{x:.2f}<br>y=%{y:.2f}<extra></extra>",
      ),
    ],
    frames=[
      go.Frame(
        name=f"a={a_value}",
        data=[
          go.Scattergl(x=lattice[:, 0], y=lattice[:, 1]),
          go.Scattergl(
            x=points[:, 0],
            y=points[:, 1],
            name=f"Displaced particles (a={a_value})",
          ),
        ],
      )
      for a_value, points in snapshots
    ],
  )

  fig.update_layout(
    title=(
      "Bagla Zel'dovich Approximation"
      "<br><sup>2D displaced particle positions for growth factor a = 1..5</sup>"
    ),
    width=1100,
    height=980,
    xaxis=dict(
      title="x",
      range=[0.0, float(NBOX)],
      color=SUBTLE,
      gridcolor=GRID,
      zeroline=False,
    ),
    yaxis=dict(
      title="y",
      range=[0.0, float(NBOX)],
      color=SUBTLE,
      gridcolor=GRID,
      zeroline=False,
      scaleanchor="x",
      scaleratio=1,
    ),
    plot_bgcolor=PLOT_BG,
    legend=dict(
      x=0.01,
      y=0.99,
      bgcolor="rgba(2, 6, 23, 0.55)",
      bordercolor="rgba(148, 163, 184, 0.18)",
      borderwidth=1,
      font=dict(color=TEXT),
    ),
    sliders=[
      {
        "active": 0,
        "currentvalue": {"prefix": "Growth factor ", "font": {"color": TEXT}},
        "pad": {"t": 22},
        "steps": make_slider_steps(),
      }
    ],
    updatemenus=[
      {
        "type": "buttons",
        "direction": "left",
        "x": 0.01,
        "y": 1.12,
        "showactive": False,
        "buttons": [
          {
            "label": "Play",
            "method": "animate",
            "args": [
              None,
              {"frame": {"duration": 800, "redraw": True}, "fromcurrent": True},
            ],
          },
          {
            "label": "Pause",
            "method": "animate",
            "args": [[None], {"frame": {"duration": 0, "redraw": False}, "mode": "immediate"}],
          },
        ],
      }
    ],
  )
  style_figure(fig)
  return fig


def main() -> None:
  DOCS_DIR.mkdir(parents=True, exist_ok=True)

  try:
    build_and_run_prof_bagla()
  except RuntimeError as exc:
    if not snapshot_files_exist():
      raise RuntimeError(
        f"{exc} No existing `fort.11` .. `fort.15` files were found to visualize."
      ) from exc
    print(f"Using existing Fortran outputs because build/run was unavailable: {exc}")

  snapshots = load_snapshots()
  fig = build_figure(snapshots)
  fig.write_html(OUTPATH, include_plotlyjs="cdn")
  print(f"Saved {OUTPATH}")
  index_path = write_index()
  print(f"Saved {index_path}")


if __name__ == "__main__":
  main()
