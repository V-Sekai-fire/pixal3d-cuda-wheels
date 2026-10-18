#!/usr/bin/env bash
# Fails unless every CUDA extension in every wheel holds SASS (cuobjdump --list-elf) that runs on each
# of REQUIRED_ARCHS: sm_XY runs on sm_XZ for Z >= Y; arch-specific sm_XYa runs only on itself.
# Strings in the binary are not evidence: nvdiffrast prints sm_20..sm_120 and carries sm_120 SASS only.
set -euo pipefail
REQUIRED_ARCHS=$(grep "^REQUIRED_ARCHS=" "$(dirname "$0")/pins.env" | cut -d= -f2-)
[ -n "$REQUIRED_ARCHS" ] || { echo "REQUIRED_ARCHS not found in pins.env"; exit 1; }
CUOBJDUMP=${CUOBJDUMP:-cuobjdump}
command -v "$CUOBJDUMP" > /dev/null || { echo "cuobjdump not found"; exit 1; }
runs_on() {  # runs_on <have list> <want>
  local want=${2#sm_} b n
  for b in $1; do
    case "$b" in *a) [ "$b" = "$2" ] && return 0; continue;; esac
    n=${b#sm_}
    if [ $((n / 10)) -eq $((want / 10)) ] && [ "$n" -le "$want" ]; then return 0; fi
  done
  return 1
}
dir=$1; fail=0; n=0
for whl in "$dir"/*.whl; do
  tmp=$(mktemp -d); python3 -m zipfile -e "$whl" "$tmp"
  while IFS= read -r so; do
    archs=$( { "$CUOBJDUMP" --list-elf "$so" 2>/dev/null | grep -oE 'sm_[0-9]+a?' || true; } | sort -u | tr '\n' ' ')
    if [ -z "$archs" ]; then echo "host-only $(basename "$whl"):${so#$tmp/}"; continue; fi
    n=$((n+1)); miss=""
    for a in $REQUIRED_ARCHS; do runs_on "$archs" "$a" || miss="$miss $a"; done
    if [ -n "$miss" ]; then echo "MISSING$miss in $(basename "$whl"):${so#$tmp/} [$archs]"; fail=1
    else echo "ok $(basename "$whl"):${so#$tmp/} [$archs]"; fi
  done < <(find "$tmp" -name '*.so')
  rm -rf "$tmp"
done
[ "$n" -gt 0 ] || { echo "no CUDA extensions found"; exit 1; }
exit $fail
