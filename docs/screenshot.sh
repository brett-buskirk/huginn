#!/usr/bin/env bash
# screenshot.sh — regenerate the README hero image (docs/huginn-status.png).
#
# Renders `huginn status` against a throwaway demo estate (fake acme-* repos, so
# no real repo names leak) into a clean terminal-window PNG.
#
# Dev-only. Needs huginn on PATH, plus:  pip3 install --user rich cairosvg
# Usage:  docs/screenshot.sh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="$HERE/huginn-status.png"
EMAIL="dev@acme.example"
DEMO="$(mktemp -d)"; trap 'rm -rf "$DEMO"' EXIT
mkdir -p "$DEMO/.remotes"

# 1. a throwaway estate of fake repos, one per dashboard state
new(){ local n="$1" days="${2:-1}" d
  d="$(date -d "$days days ago" '+%Y-%m-%dT%H:%M:%S' 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"
  git init -q --bare "$DEMO/.remotes/$n.git"
  git clone -q "$DEMO/.remotes/$n.git" "$DEMO/$n" 2>/dev/null
  git -C "$DEMO/$n" config user.email "$EMAIL"; git -C "$DEMO/$n" config user.name "Acme Dev"
  git -C "$DEMO/$n" checkout -q -b main
  printf '# %s\n' "$n" > "$DEMO/$n/README.md"; git -C "$DEMO/$n" add .
  GIT_AUTHOR_DATE="$d" GIT_COMMITTER_DATE="$d" git -C "$DEMO/$n" commit -q -m "initial commit"
  git -C "$DEMO/$n" push -q -u origin main; }
g(){ git -C "$DEMO/$1" "${@:2}"; }
new acme-web    18
new acme-api     2; printf 'wip\n' >> "$DEMO/acme-api/README.md"                                   # dirty
new acme-infra   5; g acme-infra checkout -q -b feat/terraform-vpc                                  # feature branch
new acme-mobile 40; printf 'x' > "$DEMO/acme-mobile/app.txt"; g acme-mobile add .; g acme-mobile commit -q -m "add screen"          # ahead
new acme-cli     9; printf 'y' > "$DEMO/acme-cli/y.txt"; g acme-cli add .; g acme-cli commit -q -m "release"; g acme-cli push -q origin main; g acme-cli reset -q --hard HEAD~1   # behind
new acme-docs   70; g acme-docs branch draft; g acme-docs branch review; printf 'z' >> "$DEMO/acme-docs/README.md"; g acme-docs stash -q   # +2 br, stash

# 2. capture huginn status WITH color (pty via `script`, so [ -t 1 ] is true);
#    rewrite the temp path to a realistic-looking estate root for the shot
ANSI="$DEMO/out.ansi"
script -qec "env HUGINN_ROOT=$DEMO HUGINN_EMAIL=$EMAIL COLUMNS=80 huginn status" /dev/null \
  | sed 's/\r$//' | sed "s#$DEMO#~/github-repos#g" > "$ANSI"

# 3. render the captured ANSI → terminal-window SVG → PNG
python3 - "$ANSI" "$OUT" <<'PY'
import sys, os, tempfile
from rich.console import Console
from rich.text import Text
import cairosvg
ansi_path, out = sys.argv[1], sys.argv[2]
txt = Text.from_ansi(open(ansi_path, encoding="utf-8", errors="replace").read().strip("\n"))
width = max((len(l) for l in txt.plain.splitlines()), default=80) + 2
con = Console(record=True, width=width)
con.print(txt)
svg = tempfile.mktemp(suffix=".svg")
con.save_svg(svg, title="huginn status")
cairosvg.svg2png(url=svg, write_to=out, scale=2)
os.unlink(svg)
print("wrote", out)
PY
