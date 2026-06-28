# unicode/

ucode's Unicode-only artifacts. Synced from
`fontist/ucode`'s publish workflow (TODO.full/09 + TODO.new/41).

## Contents

- `block-feed/` — compact per-block feed consumed by fontist.org
  - `unicode-blocks.json` — top-level block index
  - `unicode-version.json` — version + counts
  - `unicode/blocks/<slug>.json` — per-block codepoint lists
- `universal-glyph-set/` — one SVG per codepoint (ucode's universal set)
  - `manifest.json` — version + per-tier breakdown
  - `entries/U+XXXX.json` — per-glyph provenance
  - `glyphs/U+XXXX.svg` — actual SVG glyphs
- `codepoints-{version}.tar.zst` — per-codepoint detailed JSONs (release asset)
- `codepoints-index.json` — quick lookup index

## Sync

Triggered by `fontist/ucode` workflow_run on the
`publish-unicode-archive.yml` workflow.
