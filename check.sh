#!/usr/bin/env bash
# Fails unless every CUDA extension in every wheel has kernels for each of REQUIRED_ARCHS.
set -euo pipefail
REQUIRED_ARCHS=$(grep "^REQUIRED_ARCHS=" pins.env | cut -d= -f2-)
dir=$1; fail=0; n=0
for whl in "$dir"/*.whl; do
  tmp=$(mktemp -d); python3 -m zipfile -e "$whl" "$tmp"
  while IFS= read -r so; do
    archs=$(strings -a "$so" | grep -oE 'sm_[0-9]{2,3}a?' | sort -u | tr '\n' ' ')
    case "$archs" in "") continue;; esac
    n=$((n+1))
    miss=""
    for a in $REQUIRED_ARCHS; do grep -qw "$a" <<<"$archs" || miss="$miss $a"; done
    if [ -n "$miss" ]; then echo "MISSING$miss in $(basename "$whl"):${so#$tmp/} [$archs]"; fail=1
    else echo "ok $(basename "$whl"):${so#$tmp/} [$archs]"; fi
  done < <(find "$tmp" -name '*.so')
  rm -rf "$tmp"
done
[ "$n" -gt 0 ] || { echo "no CUDA extensions found"; exit 1; }
exit $fail
