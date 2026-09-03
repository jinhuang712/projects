#!/usr/bin/env bash
# Assemble every project site listed in sites.json into _site/<name>/.
# Usage: scripts/assemble.sh [output-dir]   (default: _site)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/_site}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

rm -rf "$OUT"
mkdir -p "$OUT"
cp -R "$ROOT/site/." "$OUT/"

count=$(jq length "$ROOT/sites.json")
for i in $(seq 0 $((count - 1))); do
  name=$(jq -r ".[$i].name" "$ROOT/sites.json")
  repo=$(jq -r ".[$i].repo" "$ROOT/sites.json")
  ref=$(jq -r ".[$i].ref" "$ROOT/sites.json")
  path=$(jq -r ".[$i].path" "$ROOT/sites.json")
  echo "==> $name  ($repo@$ref:/$path)"
  git clone --quiet --depth 1 --branch "$ref" "https://github.com/$repo.git" "$WORK/$name"
  src="$WORK/$name/$path"
  [ -d "$src" ] || { echo "missing $path in $repo" >&2; exit 1; }
  mkdir -p "$OUT/$name"
  cp -R "$src/." "$OUT/$name/"
  while IFS= read -r ex; do
    [ -n "$ex" ] && rm -rf "$OUT/$name/$ex"
  done < <(jq -r ".[$i].exclude[]?" "$ROOT/sites.json")
  rm -rf "$OUT/$name/.git"
  # Pin the upstream commit so a deploy is traceable.
  git -C "$WORK/$name" rev-parse HEAD > "$OUT/$name/.source-commit"
done

touch "$OUT/.nojekyll"
echo
echo "Assembled into $OUT:"
find "$OUT" -maxdepth 1 -mindepth 1 | sort
