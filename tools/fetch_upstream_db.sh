#!/usr/bin/env bash
# Downloads the latest upstream signature databases, verifies their detached GPG signatures and writes them under
# our own file names (sig-md5.bin, sig-sha1.bin, sig-sha256.bin) together with manifest.json. Signatures and the
# key are used only here; they are not written to the output.
# Usage: tools/fetch_upstream_db.sh <output-dir>
set -euo pipefail
OUT="${1:?output dir}"
BASE="${UPSTREAM_BASE:-https://maintainteam.github.io/HypatiaDatabases/}"
KEY_ID="${UPSTREAM_KEY_ID:-5298C0C0C3E73288}"
# Cross-platform stat helpers (GNU vs BSD)
if stat --version >/dev/null 2>&1; then
  file_mtime() { stat -c %Y "$1"; }
  fmt_epoch()  { date -u -d "@$1" "$2"; }
else
  file_mtime() { stat -f %m "$1"; }
  fmt_epoch()  { date -u -r "$1" "$2"; }
fi
# upstream name -> our name
UPSTREAM=(hypatia-md5-bloom.bin hypatia-sha1-bloom.bin hypatia-sha256-bloom.bin)
OURS=(sig-md5.bin sig-sha1.bin sig-sha256.bin)
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUT"
curl -fsSL -o "$TMP/gpg.key" "${BASE}gpg.key"
newest=0
for f in "${UPSTREAM[@]}"; do
  curl -fsSL -R -o "$TMP/$f" "${BASE}$f"
  curl -fsSL -o "$TMP/$f.sig" "${BASE}$f.sig"
  lm=$(file_mtime "$TMP/$f")
  (( lm > newest )) && newest=$lm
done
if command -v gpg >/dev/null; then
  export GNUPGHOME="$TMP/gnupg"; mkdir -p "$GNUPGHOME"; chmod 700 "$GNUPGHOME"
  gpg --quiet --import "$TMP/gpg.key"
  for f in "${UPSTREAM[@]}"; do
    gpg --quiet --verify "$TMP/$f.sig" "$TMP/$f" 2>&1 | grep -q "$KEY_ID" || { echo "GPG verification failed for $f" >&2; exit 1; }
  done
  echo "GPG signatures OK"
else
  echo "WARNING: gpg not installed, signatures not verified" >&2
fi
for i in "${!UPSTREAM[@]}"; do mv "$TMP/${UPSTREAM[$i]}" "$OUT/${OURS[$i]}"; done
GEN=$(fmt_epoch "$newest" +%Y-%m-%dT%H:%M:%SZ)
VERSION="${VERSION:-$(fmt_epoch "$newest" +%Y.%m.%d)}"
"$(dirname "$0")/make_manifest.sh" "$OUT" "$VERSION" "$GEN"
echo "Fetched $VERSION (generated $GEN) into $OUT"
