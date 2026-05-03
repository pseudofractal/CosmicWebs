import numpy as np
import plotly.graph_objects as go


def transfer_function(k, omega_m=0.3, h=0.7, theta_cmb=2.728 / 2.7):
  k_mpc = k * h
  q = k_mpc * theta_cmb**2 / (omega_m * h**2)

  L = np.log(np.e + 1.84 * q)
  C = 14.4 + 325.0 / (1.0 + 60.5 * q**1.08)

  return L / (L + C * q**2)


def plot_power_spectrum(
  output="linear_matter_power_spectrum.png",
  omega_m=0.3,
  h=0.7,
  n_s=1.0,
  k_min=1e-3,
  k_max=10.0,
):
  k = np.logspace(np.log10(k_min), np.log10(k_max), 600)

  T = transfer_function(k, omega_m=omega_m, h=h)
  P_primordial = k**n_s
  P_linear = P_primordial * T**2

  # Normalize for visual comparison
  P_primordial /= np.max(P_linear)
  P_linear /= np.max(P_linear)

  fig = go.Figure()

  fig.add_trace(
    go.Scatter(
      x=k,
      y=P_primordial,
      mode="lines",
      name="Primordial spectrum: kⁿ",
      line=dict(dash="dash"),
    )
  )

  fig.add_trace(
    go.Scatter(
      x=k,
      y=T**2,
      mode="lines",
      name="Transfer suppression: T²(k)",
      line=dict(dash="dot"),
    )
  )

  fig.add_trace(
    go.Scatter(
      x=k,
      y=P_linear,
      mode="lines",
      name="Linear matter power: P(k) ∝ kⁿT²(k)",
      line=dict(width=3),
    )
  )

  fig.update_layout(
    template="plotly_white",
    width=1100,
    height=700,
    title="Linear Matter Power Spectrum Shaped by the Transfer Function",
    xaxis=dict(title="Wavenumber k [h Mpc⁻¹]", type="log"),
    yaxis=dict(title="Normalized amplitude", type="log"),
    legend=dict(x=0.02, y=0.98),
  )

  fig.write_image(output, scale=3)  # requires: pip install kaleido
  fig.write_html(output.replace(".png", ".html"))

  return fig


plot_power_spectrum("linear_matter_power_spectrum.png")
