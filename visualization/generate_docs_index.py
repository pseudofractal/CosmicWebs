from html import escape
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DOCS_DIR = PROJECT_ROOT / "docs"
INDEX_PATH = DOCS_DIR / "index.html"

PAPER_BG = "#020617"
SURFACE_BG = "rgba(15, 23, 42, 0.82)"
BORDER = "rgba(148, 163, 184, 0.18)"
TEXT = "#e2e8f0"
SUBTLE = "#94a3b8"
ACCENT = "#22d3ee"
ACCENT_ALT = "#7c3aed"


def iter_docs_pages() -> list[Path]:
  return sorted(
    (path for path in DOCS_DIR.glob("*.html") if path.name != INDEX_PATH.name),
    key=lambda path: path.stem.lower(),
  )


def display_name(path: Path) -> str:
  return path.stem.replace("_", " ").replace("-", " ").title()


def build_index_html(pages: list[Path]) -> str:
  page_count = len(pages)
  cards = "\n".join(
    f"""
        <a class=\"doc-card\" href=\"{escape(path.name, quote=True)}\">
          <span class=\"doc-title\">{escape(display_name(path))}</span>
          <span class=\"doc-file\">{escape(path.name)}</span>
        </a>""".rstrip()
    for path in pages
  )

  if not cards:
    cards = """
        <div class=\"empty-state\">
          No HTML files were found in <code>docs/</code> yet.
        </div>""".rstrip()

  return f"""<!DOCTYPE html>
<html lang=\"en\">
<head>
  <meta charset=\"utf-8\" />
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
  <title>Cosmic Web Docs</title>
  <style>
    :root {{
      color-scheme: dark;
      --paper-bg: {PAPER_BG};
      --surface-bg: {SURFACE_BG};
      --border: {BORDER};
      --text: {TEXT};
      --subtle: {SUBTLE};
      --accent: {ACCENT};
      --accent-alt: {ACCENT_ALT};
      --shadow: 0 24px 80px rgba(2, 6, 23, 0.42);
    }}

    * {{
      box-sizing: border-box;
    }}

    body {{
      margin: 0;
      min-height: 100vh;
      font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont,
        \"Segoe UI\", sans-serif;
      color: var(--text);
      background:
        radial-gradient(circle at top, rgba(124, 58, 237, 0.18), transparent 32%),
        radial-gradient(circle at 85% 10%, rgba(34, 211, 238, 0.16), transparent 26%),
        linear-gradient(180deg, #020617 0%, #030712 100%);
    }}

    main {{
      width: min(960px, calc(100% - 32px));
      margin: 0 auto;
      padding: 48px 0 64px;
    }}

    .hero {{
      padding: 32px;
      border: 1px solid var(--border);
      border-radius: 24px;
      background: linear-gradient(145deg, rgba(15, 23, 42, 0.9), rgba(2, 6, 23, 0.72));
      box-shadow: var(--shadow);
    }}

    .eyebrow {{
      display: inline-flex;
      margin-bottom: 16px;
      padding: 6px 12px;
      border: 1px solid rgba(34, 211, 238, 0.22);
      border-radius: 999px;
      color: var(--accent);
      letter-spacing: 0.08em;
      text-transform: uppercase;
      font-size: 0.78rem;
      font-weight: 700;
    }}

    h1 {{
      margin: 0;
      font-size: clamp(2.2rem, 5vw, 3.8rem);
      line-height: 1.05;
    }}

    .hero p {{
      max-width: 46rem;
      margin: 18px 0 0;
      color: var(--subtle);
      font-size: 1.02rem;
      line-height: 1.7;
    }}

    .meta {{
      margin-top: 22px;
      color: var(--subtle);
      font-size: 0.95rem;
    }}

    .meta strong {{
      color: var(--text);
    }}

    .docs-grid {{
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
      gap: 18px;
      margin-top: 28px;
    }}

    .doc-card,
    .empty-state {{
      position: relative;
      display: block;
      min-height: 132px;
      padding: 22px;
      border: 1px solid var(--border);
      border-radius: 20px;
      background: linear-gradient(
        180deg,
        rgba(15, 23, 42, 0.92),
        rgba(15, 23, 42, 0.72)
      );
      box-shadow: var(--shadow);
    }}

    .doc-card {{
      text-decoration: none;
      transition: transform 140ms ease, border-color 140ms ease, box-shadow 140ms ease;
    }}

    .doc-card:hover,
    .doc-card:focus-visible {{
      transform: translateY(-2px);
      border-color: rgba(34, 211, 238, 0.42);
      box-shadow: 0 24px 80px rgba(2, 6, 23, 0.56);
      outline: none;
    }}

    .doc-card::after {{
      content: \"\";
      position: absolute;
      inset: 0;
      border-radius: inherit;
      background: linear-gradient(
        135deg,
        rgba(34, 211, 238, 0.08),
        rgba(124, 58, 237, 0.02)
      );
      pointer-events: none;
    }}

    .doc-title {{
      position: relative;
      display: block;
      z-index: 1;
      color: var(--text);
      font-size: 1.08rem;
      font-weight: 700;
      line-height: 1.45;
    }}

    .doc-file {{
      position: relative;
      display: block;
      z-index: 1;
      margin-top: 12px;
      color: var(--subtle);
      font-family: \"SFMono-Regular\", ui-monospace, SFMono-Regular, Menlo, monospace;
      font-size: 0.84rem;
      word-break: break-word;
    }}

    code {{
      color: var(--text);
      font-family: \"SFMono-Regular\", ui-monospace, SFMono-Regular, Menlo, monospace;
    }}

    @media (max-width: 640px) {{
      main {{
        width: min(100% - 20px, 960px);
        padding-top: 20px;
      }}

      .hero {{
        padding: 24px;
        border-radius: 20px;
      }}
    }}
  </style>
</head>
<body>
  <main>
    <section class=\"hero\">
      <h1>Zel'dovich Approximation Plots</h1>
    </section>
    <section class=\"docs-grid\">
{cards}
    </section>
  </main>
</body>
</html>
"""


def write_index() -> Path:
  DOCS_DIR.mkdir(parents=True, exist_ok=True)
  INDEX_PATH.write_text(build_index_html(iter_docs_pages()), encoding="utf-8")
  return INDEX_PATH


def main() -> None:
  outpath = write_index()
  print(f"Saved {outpath}")


if __name__ == "__main__":
  main()
