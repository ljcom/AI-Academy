#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECTIONS_DIR="$ROOT_DIR/manuscript/sections"
BUILD_DIR="$ROOT_DIR/build"
DIAGRAM_DIR="$ROOT_DIR/manuscript/diagrams"
OUTPUT_PDF="${1:-$BUILD_DIR/ai-academy-split.pdf}"
PDF_ENGINE="${PDF_ENGINE:-/Library/TeX/texbin/xelatex}"

if ! command -v pandoc >/dev/null 2>&1; then
  echo "Error: pandoc tidak ditemukan. Install dulu: brew install pandoc" >&2
  exit 1
fi

mkdir -p "$BUILD_DIR"

files=(
  "$SECTIONS_DIR/00-title-abstract.md"
  "$SECTIONS_DIR/01-introduction.md"
  "$SECTIONS_DIR/02-limitations-of-current-conversational-ai-learning.md"
  "$SECTIONS_DIR/03-learning-progression-in-traditional-education.md"
  "$SECTIONS_DIR/04-concept-of-ai-academy-engine.md"
  "$SECTIONS_DIR/05-conversational-entry-and-adaptive-learning-pathways.md"
  "$SECTIONS_DIR/06-reflective-dialogue-and-mastery-evaluation.md"
  "$SECTIONS_DIR/07-ethical-and-privacy-considerations.md"
  "$SECTIONS_DIR/08-conclusion-and-future-research-directions.md"
  "$SECTIONS_DIR/09-references.md"
)

diagram_sources=(
  "$DIAGRAM_DIR/figure-1-conceptual-framework.mmd"
  "$DIAGRAM_DIR/figure-2-layered-architecture.mmd"
)

diagram_outputs=(
  "$DIAGRAM_DIR/figure-1-conceptual-framework.png"
  "$DIAGRAM_DIR/figure-2-layered-architecture.png"
)

for f in "${files[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "Error: file section tidak ditemukan: $f" >&2
    exit 1
  fi
done

for s in "${diagram_sources[@]}"; do
  if [[ ! -f "$s" ]]; then
    echo "Error: source diagram tidak ditemukan: $s" >&2
    exit 1
  fi
done

if command -v mmdc >/dev/null 2>&1; then
  mmdc -i "${diagram_sources[0]}" -o "${diagram_outputs[0]}" -b transparent
  mmdc -i "${diagram_sources[1]}" -o "${diagram_outputs[1]}" -b transparent
else
  for p in "${diagram_outputs[@]}"; do
    if [[ ! -f "$p" ]]; then
      echo "Error: mmdc tidak tersedia dan PNG diagram belum ada: $p" >&2
      echo "Install: npm i -g @mermaid-js/mermaid-cli" >&2
      exit 1
    fi
  done
fi

if [[ ! -x "$PDF_ENGINE" ]]; then
  echo "Error: PDF_ENGINE tidak valid atau tidak executable: $PDF_ENGINE" >&2
  echo "Set path valid, contoh:" >&2
  echo "  PDF_ENGINE=/Library/TeX/texbin/xelatex ./build.sh" >&2
  exit 1
fi

pandoc \
  "${files[@]}" \
  --from markdown \
  --toc \
  --standalone \
  --metadata title="From Knowledge Engines to AI Academy Engines" \
  --pdf-engine="$PDF_ENGINE" \
  -o "$OUTPUT_PDF"

echo "PDF berhasil dibuat: $OUTPUT_PDF"
