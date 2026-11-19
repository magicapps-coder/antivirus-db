# antivirus-db

Databases for the Antivirus Cleaner app (`com.magic.apps.antivirus.cleaner`).

## Signature databases (GitHub Releases)

- Each release tag is a date (`2026.11.02`) and contains `manifest.json` and three Bloom-filter files:
  `sig-md5.bin`, `sig-sha1.bin`, `sig-sha256.bin`.
- The app downloads `https://github.com/magicapps-coder/antivirus-db/releases/latest/download/manifest.json`
  and then the files listed in it (each checked by size and SHA-256).
- The databases are built and published by a separate private repository (daily); this repository only holds the
  data the app downloads.

## Link database (`links/`)

- `links/link-domains.bin`, `links/link-urls.bin`, `links/links-manifest.json`: dangerous sites and links for Web
  protection and Link check, built by `tools/build_link_db.py` from URLhaus (malware-filter mirror, CC0) and
  Phishing.Database (MIT).
- The app reads `https://raw.githubusercontent.com/magicapps-coder/antivirus-db/main/links/`.

## History

- [HISTORY.md](HISTORY.md): every published database with its date, version, size and a download link, newest first.
- Signature releases are never deleted. Every changed link database is also published as a release `links-<version>`
  (not marked "latest", so `releases/latest` always stays the newest signature database).
- The app always takes the newest: signatures from `releases/latest`, links from `links/` on `main`.
