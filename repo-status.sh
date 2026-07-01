#!/usr/bin/env bash
# repo-status.sh — at-a-glance status of every git repo in this directory.
#
#   ./repo-status.sh            fast, local (no network)
#   ./repo-status.sh --fetch    git fetch each repo first → fresh ahead/behind (network)
#
# STATUS legend: ✓ clean · ● N changed · ↑ ahead · ↓ behind · ⚑ stashes · +N br (extra local
# branches) · ✉? no local email · ✉ <addr> (local email ≠ business address)
set -uo pipefail
ROOT="${HUGINN_ROOT:-$HOME/github-repos}"
BIZ_EMAIL="${HUGINN_EMAIL:-$(git config user.email 2>/dev/null)}"   # set by huginn; else your git email
FETCH=0; case "${1:-}" in --fetch|-f) FETCH=1;; --help|-h) sed -n '2,9p' "$0"; exit 0;; esac

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  R=$'\e[31m'; G=$'\e[32m'; Y=$'\e[33m'; C=$'\e[36m'; M=$'\e[35m'; DIM=$'\e[2m'; BD=$'\e[1m'; X=$'\e[0m'
else R=; G=; Y=; C=; M=; DIM=; BD=; X=; fi

short(){ sed -E 's/ years?/y/;s/ months?/mo/;s/ weeks?/w/;s/ days?/d/;s/ hours?/h/;s/ minutes?/m/;s/ seconds?/s/;s/ ago//;s/ //g' <<<"$1"; }
rule(){ printf "${DIM}%s${X}\n" "$(printf '─%.0s' $(seq 1 "$1"))"; }

mapfile -t DIRS < <(cd "$ROOT" && for d in */; do [ -d "${d}.git" ] && echo "${d%/}"; done | sort)
[ "${#DIRS[@]}" -eq 0 ] && { echo "No git repos under $ROOT"; exit 0; }

names=(); brs=(); brdef=(); lasts=(); stats=()
maxN=4; maxB=6; maxL=4
tot=0; nclean=0; ndirty=0; nfeat=0; nattn=0

[ "$FETCH" = 1 ] && printf "${DIM}fetching…${X}\n"
for d in "${DIRS[@]}"; do
  tot=$((tot+1)); GD="$ROOT/$d"
  [ "$FETCH" = 1 ] && git -C "$GD" fetch -q --all 2>/dev/null

  br=$(git -C "$GD" symbolic-ref --short HEAD 2>/dev/null); [ -z "$br" ] && br="detached"
  def=$(git -C "$GD" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##'); def=${def:-main}
  chg=$(git -C "$GD" status --porcelain 2>/dev/null | grep -c . || true)
  if ab=$(git -C "$GD" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null); then
    behind=${ab%%[[:space:]]*}; ahead=${ab##*[[:space:]]}
  else behind=x; ahead=x; fi
  last=$(short "$(git -C "$GD" log -1 --format='%cr' 2>/dev/null || echo '-')")
  stash=$(git -C "$GD" stash list 2>/dev/null | grep -c . || true)
  nbr=$(git -C "$GD" for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null | grep -c . || true)
  email=$(git -C "$GD" config --local user.email 2>/dev/null)

  isdef=0; if [ "$br" = "$def" ]; then isdef=1; else nfeat=$((nfeat+1)); fi

  st=""
  if [ "$chg" -eq 0 ]; then st="${G}✓ clean${X}"; nclean=$((nclean+1)); else st="${Y}● ${chg} changed${X}"; ndirty=$((ndirty+1)); fi
  if [ "$ahead" != x ]; then
    [ "$ahead" -gt 0 ]  && st+="  ${Y}↑${ahead}${X}"
    [ "$behind" -gt 0 ] && st+="  ${Y}↓${behind}${X}"
  else st+="  ${DIM}(no upstream)${X}"; fi
  [ "$stash" -gt 0 ] && st+="  ${M}⚑${stash}${X}"
  [ "$nbr" -gt 1 ]   && st+="  ${DIM}+$((nbr-1)) br${X}"
  if [ -z "$email" ]; then st+="  ${Y}✉?${X}"
  elif [ "$email" != "$BIZ_EMAIL" ]; then st+="  ${R}✉ ${email}${X}"; nattn=$((nattn+1)); fi

  names+=("$d"); brs+=("$br"); brdef+=("$isdef"); lasts+=("$last"); stats+=("$st")
  (( ${#d} > maxN )) && maxN=${#d}
  (( ${#br} > maxB )) && maxB=${#br}
  (( ${#last} > maxL )) && maxL=${#last}
done

W=$((maxN + maxB + maxL + 22))
printf "\n${BD}  git estate${X}  ${DIM}·  %s  ·  %s${X}\n\n" "$ROOT" "$(date '+%a %b %-d, %H:%M')"
printf "  ${BD}%-${maxN}s  %-${maxB}s  %-${maxL}s  %s${X}\n" "REPO" "BRANCH" "LAST" "STATUS"
printf "  "; rule "$W"
for i in "${!names[@]}"; do
  rp=$(printf "%-${maxN}s" "${names[$i]}")
  bp=$(printf "%-${maxB}s" "${brs[$i]}")
  lp=$(printf "%-${maxL}s" "${lasts[$i]}")
  if [ "${brdef[$i]}" = 1 ]; then bpc="${G}${bp}${X}"; else bpc="${C}${BD}${bp}${X}"; fi
  printf "  ${BD}%s${X}  %s  ${DIM}%s${X}  %s\n" "$rp" "$bpc" "$lp" "${stats[$i]}"
done
printf "  "; rule "$W"
printf "  ${BD}%d repos${X}  ${DIM}·${X}  ${G}%d clean${X}  ${DIM}·${X}  ${Y}%d dirty${X}  ${DIM}·${X}  ${C}%d on a feature branch${X}" \
  "$tot" "$nclean" "$ndirty" "$nfeat"
[ "$nattn" -gt 0 ] && printf "  ${DIM}·${X}  ${R}%d wrong email${X}" "$nattn"
printf "\n\n"
