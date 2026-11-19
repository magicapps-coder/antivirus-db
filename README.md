# antivirus-db

Databases for the Antivirus Cleaner app (`com.magic.apps.antivirus.cleaner`).

## Signature databases (GitHub Releases)

- Each release tag is a date (`2026.11.02`) and contains `manifest.json` and three Bloom-filter files:
  `sig-md5.bin`, `sig-sha1.bin`, `sig-sha256.bin`.
- The app downloads `https://github.com/magicapps-coder/antivirus-db/releases/latest/download/manifest.json`
  and then the files listed in it (each checked by size and SHA-256).
- `.github/workflows/build-db.yml` builds the database every day from open sources (ClamAV, ESET, abuse.ch
  MalwareBazaar and ThreatFox, Signature-Base, ThreatView, stalkerware indicators, Sanesecurity, targeted threats) with
  the open-source Hypatia generator, checks it (minimum size, filter capacity, not much smaller than the last release)
  and publishes a release. abuse.ch needs the free Auth-Key in the secret `ABUSECH_AUTH_KEY`. Started by hand
  (Actions → Build signature database → Run workflow) it only builds, unless "Publish" is ticked.
- `.github/workflows/update-db.yml` (manual only) mirrors the upstream Hypatia files, which stopped updating on 2026-09-27.

## Link database (`links/`)

- `links/link-domains.bin`, `links/link-urls.bin`, `links/links-manifest.json`: dangerous sites and links for Web
  protection and Link check, built by `tools/build_link_db.py` from URLhaus (malware-filter mirror, CC0) and
  Phishing.Database (MIT).
- `.github/workflows/update-links.yml` rebuilds it every day and commits only when the lists changed.
- The app reads `https://raw.githubusercontent.com/magicapps-coder/antivirus-db/main/links/`.

## History

- [HISTORY.md](HISTORY.md): every published database with its date, version, size and a download link, newest first.
- Signature releases are never deleted. Every changed link database is also published as a release `links-<version>`
  (not marked "latest", so `releases/latest` always stays the newest signature database).
- The app always takes the newest: signatures from `releases/latest`, links from `links/` on `main`.

## Keep alive

`.github/workflows/keepalive.yml` commits `LAST_RUN.md` every Monday (time of the run and the last results of both
update workflows). GitHub pauses scheduled workflows in public repos after 60 days without commits; this prevents it.

## Safe packages

`safe_packages.json`: packages that are never reported as suspicious, read by the app from
`https://raw.githubusercontent.com/magicapps-coder/antivirus-db/main/safe_packages.json`.
