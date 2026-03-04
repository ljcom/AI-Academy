#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECTIONS_DIR="$ROOT_DIR/manuscript/sections"
DIAGRAM_DIR="$ROOT_DIR/manuscript/diagrams"
BUILD_DIR="$ROOT_DIR/build"
OUTPUT_PDF="${1:-$BUILD_DIR/whitepaper-ai-academy-engine.pdf}"
PDF_ENGINE="${PDF_ENGINE:-/Library/TeX/texbin/xelatex}"

if ! command -v pandoc >/dev/null 2>&1; then
  echo "Error: pandoc tidak ditemukan. Install dulu: brew install pandoc" >&2
  exit 1
fi

mkdir -p "$BUILD_DIR"

files=(
  "$SECTIONS_DIR/00-title.md"
  "$SECTIONS_DIR/01-executive-summary.md"
  "$SECTIONS_DIR/02-problem-statement.md"
  "$SECTIONS_DIR/03-vision-from-knowledge-engines-to-learning-engines.md"
  "$SECTIONS_DIR/04-ai-academy-engine-framework.md"
  "$SECTIONS_DIR/05-conversational-learning-model.md"
  "$SECTIONS_DIR/06-reflective-dialogue-and-mastery-detection.md"
  "$SECTIONS_DIR/07-360-degree-conceptual-evaluation.md"
  "$SECTIONS_DIR/08-system-architecture.md"
  "$SECTIONS_DIR/09-implementation-model-ai-open-academy.md"
  "$SECTIONS_DIR/10-ethical-and-governance-considerations.md"
  "$SECTIONS_DIR/11-roadmap-for-implementation.md"
  "$SECTIONS_DIR/12-future-research-directions.md"
  "$SECTIONS_DIR/13-conclusion.md"
)

for f in "${files[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "Error: file section tidak ditemukan: $f" >&2
    exit 1
  fi
done

diagram_sources=(
  "$DIAGRAM_DIR/figure-1-conceptual-learning-graph.mmd"
  "$DIAGRAM_DIR/figure-2-system-architecture-overview.mmd"
  "$DIAGRAM_DIR/figure-3-implementation-roadmap.mmd"
)

diagram_outputs=(
  "$DIAGRAM_DIR/figure-1-conceptual-learning-graph.png"
  "$DIAGRAM_DIR/figure-2-system-architecture-overview.png"
  "$DIAGRAM_DIR/figure-3-implementation-roadmap.png"
)

for s in "${diagram_sources[@]}"; do
  if [[ ! -f "$s" ]]; then
    echo "Error: source diagram tidak ditemukan: $s" >&2
    exit 1
  fi
done

if command -v mmdc >/dev/null 2>&1; then
  mmdc -i "${diagram_sources[0]}" -o "${diagram_outputs[0]}" -b transparent
  mmdc -i "${diagram_sources[1]}" -o "${diagram_outputs[1]}" -b transparent
  mmdc -i "${diagram_sources[2]}" -o "${diagram_outputs[2]}" -b transparent
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
  echo "  PDF_ENGINE=/Library/TeX/texbin/xelatex ./whitepaper/build.sh" >&2
  exit 1
fi

pandoc \
  "${files[@]}" \
  --from markdown \
  --toc \
  --standalone \
  --resource-path="$SECTIONS_DIR:$ROOT_DIR/manuscript:$DIAGRAM_DIR:$ROOT_DIR" \
  --metadata title="AI Academy Engine Whitepaper" \
  --pdf-engine="$PDF_ENGINE" \
  -o "$OUTPUT_PDF"

echo "PDF berhasil dibuat: $OUTPUT_PDF"
