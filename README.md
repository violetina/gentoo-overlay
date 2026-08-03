# gentoo-overlay

Tina's personal [Gentoo overlay](https://wiki.gentoo.org/wiki/Ebuild_repository) —
`repo_name` is `violetina-overlay`. Ebuilds here are unpolished on purpose:
whatever it takes to get a package installed, not upstream-Gentoo QA quality.
Don't expect Bugzilla-grade patches or long-term stable-keyword support.

## Add it to a machine

```sh
sudo mkdir -p /etc/portage/repos.conf
sudo tee /etc/portage/repos.conf/violetina-overlay.conf >/dev/null <<'EOF'
[violetina-overlay]
location = /var/db/repos/violetina-overlay
sync-type = git
sync-uri = https://github.com/violetina/gentoo-overlay.git
auto-sync = yes
EOF
sudo emaint sync --repo violetina-overlay
```

Or, equivalently: `sudo eselect repository add violetina-overlay git https://github.com/violetina/gentoo-overlay.git`
then `sudo emaint sync --repo violetina-overlay`.

Live ebuilds (`*-9999`) need `ACCEPT_KEYWORDS="**"` for that package, e.g. in
`/etc/portage/package.accept_keywords`:

```
=dev-util/codex-desktop-linux-9999 **
```

## What's in here

| Package | What | Notes |
|---|---|---|
| `dev-util/codex-desktop-linux` | OpenAI Codex/ChatGPT Desktop, repackaged for Linux | live (`-9999`); downloads OpenAI's `Codex.dmg` at build time, see below |
| `dev-util/insomnia` | Insomnia REST client | packaged from upstream `.deb` |
| `dev-python/pyjq` | Python bindings for `jq` | |
| `media-libs/kakadu` | JPEG2000 tools | linked against `libtiff`, TODO on the rest |
| `media-video/lwks` | Lightworks NLE | |
| `media-video/mediaconch` | MediaConch conformance checker | live (`-9999`) |
| `media-video/qctools` | QCTools QC/video analysis | live (`-9999`) |
| `net-misc/synology-assistant` | Synology Assistant | for DiskStation setup |

### `dev-util/codex-desktop-linux`

Wraps [ilysenko/codex-desktop-linux](https://github.com/ilysenko/codex-desktop-linux),
which does *not* ship OpenAI's app — its `install.sh` downloads the current,
unversioned `Codex.dmg` straight from OpenAI and converts it into a runnable
Linux Electron app at build time. That's why this is a `-9999` (live) ebuild
with `RESTRICT="network-sandbox"` instead of a normal SRC_URI-pinned one: the
DMG isn't a stable, checksum-pinnable artifact, so there's nothing sane to put
in a `Manifest`. Every `emerge` re-fetches whatever OpenAI is currently
serving and re-runs the upstream build (Rust + Node/Electron + npm), which
means it's slow and needs real build tooling (`rustc`, `node`, `7zip`, ...).
You need your own authorized access to Codex Desktop; nothing OpenAI-owned is
redistributed by this repo or by upstream.

If you'd rather not build it locally, other overlays carry the same app:
[`jczhang02/jc_overlay`](https://github.com/jczhang02/jc_overlay) has an
equivalent live ebuild, and
[`gkowal/acrux-overlay`](https://github.com/gkowal/acrux-overlay) has a
version-pinned `chatgpt-desktop-bin` that hash-pins the DMG per release (goes
stale each time OpenAI ships an update, so it needs a revbump then, but skips
rebuilding Rust/Node from scratch every emerge).

## Adding a package later

1. `mkdir -p <category>/<package>`, drop in `<package>-<version>.ebuild` (or
   `-9999.ebuild` for a live/git ebuild) + `metadata.xml`.
2. Generate the `Manifest`: `ebuild <category>/<package>/<package>-<version>.ebuild manifest`
   (run from the repo root, after the repo is registered via `repos.conf` as
   above — `pkgdev manifest` works too if installed).
3. Sanity-check before committing: `ebuild ... digest`, then
   `emerge -pv <category>/<package>` to confirm dependency resolution, and
   ideally `pkgcheck scan` (`app-portage/pkgcheck`) if you have it installed.
4. `category/` must be a category `gentoo` (our `masters`) already knows —
   check `/var/db/repos/gentoo/profiles/categories` before inventing a new one.
5. Commit ebuild + `metadata.xml` + `Manifest` together, push.

`metadata/layout.conf` sets `masters = gentoo` (so category names and the
base profile come from the main tree) and `auto-sync = false` (this repo
doesn't self-update from anything; it only tracks whatever's pushed here).
