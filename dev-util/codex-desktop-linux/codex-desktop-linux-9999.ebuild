# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop git-r3 xdg

DESCRIPTION="Unofficial Linux wrapper for OpenAI's Codex/ChatGPT Desktop app"
HOMEPAGE="https://github.com/ilysenko/codex-desktop-linux"
EGIT_REPO_URI="https://github.com/ilysenko/codex-desktop-linux.git"
EGIT_BRANCH="main"

LICENSE="MIT all-rights-reserved"
SLOT="0"
KEYWORDS=""

# install.sh downloads OpenAI's official (mutable, unversioned) Codex.dmg plus
# a managed Node.js/Electron runtime, npm modules and Cargo crates at build
# time. None of that is fetchable up front via SRC_URI, so the network
# sandbox has to stay off for this package and results can't be mirrored.
RESTRICT="network-sandbox mirror strip test"

# Tools install.sh shells out to while building the app payload.
BDEPEND="
	app-arch/7zip
	app-arch/tar
	app-arch/unzip
	dev-build/make
	>=net-misc/curl-7.71.0
	sys-apps/util-linux
	sys-devel/gcc
	|| ( dev-lang/rust dev-lang/rust-bin )
"

# Electron/Chromium + native module deps. The generated app tree bundles its
# own managed Node.js runtime under /opt/${PN}, so no dev-lang/nodejs dep.
RDEPEND="
	app-accessibility/at-spi2-core
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	x11-apps/xprop
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"
DEPEND="${RDEPEND}"

# Everything under /opt is upstream's own prebuilt Electron/Node/native payload.
QA_PREBUILT="opt/${PN}/*"
QA_SONAME="*"

src_compile() {
	local curl_bin
	curl_bin=$(type -P curl) || die "curl executable not found"

	# Keep every cache/state write inside ${T}; the live checkout in ${S}
	# stays writable so upstream can drop its Cargo target/ and build state
	# next to the source, same as a normal (non-sandboxed) build would.
	export HOME="${T}/home"
	export XDG_CACHE_HOME="${T}/cache"
	export XDG_CONFIG_HOME="${T}/config"
	export XDG_DATA_HOME="${T}/share"
	export CARGO_HOME="${T}/cargo-home"
	export npm_config_cache="${T}/npm-cache"
	export CODEX_MANAGED_NODE_CACHE_DIR="${T}/node-runtime-cache"
	export CODEX_INSTALL_DIR="${WORKDIR}/codex-app"
	export PACKAGE_WITH_UPDATER=0
	mkdir -p "${HOME}" "${XDG_CACHE_HOME}" "${XDG_CONFIG_HOME}" \
		"${XDG_DATA_HOME}" "${CARGO_HOME}" "${npm_config_cache}" \
		"${CODEX_MANAGED_NODE_CACHE_DIR}" "${T}/curl-bin" || die

	# install.sh treats one dropped connection as fatal; wrap curl with
	# retries instead of patching the live source tree.
	cat > "${T}/curl-bin/curl" <<-EOF || die
		#!/bin/sh
		exec "${curl_bin}" --retry 3 --retry-delay 2 --retry-all-errors "\$@"
	EOF
	chmod 0755 "${T}/curl-bin/curl" || die
	export PATH="${T}/curl-bin:${PATH}"

	einfo "Downloading OpenAI's current Codex.dmg and building the Linux payload"
	./install.sh --fresh || die "install.sh failed"
}

src_install() {
	local appdir="${WORKDIR}/codex-app"
	[[ -x ${appdir}/start.sh ]] || die "generated launcher missing: ${appdir}/start.sh"

	dodir "/opt/${PN}"
	cp -a "${appdir}"/. "${ED}/opt/${PN}/" || die "install app tree failed"
	chmod -R a+rX "${ED}/opt/${PN}" || die "normalize app tree permissions failed"
	fperms 0755 "/opt/${PN}/start.sh"

	dodir /usr/bin
	cat > "${T}/codex-desktop" <<-EOF || die
		#!/usr/bin/env bash
		exec /opt/${PN}/start.sh "\$@"
	EOF
	dobin "${T}/codex-desktop"

	if [[ -f ${appdir}/.codex-linux/codex-desktop.png ]]; then
		newicon -s 256 "${appdir}/.codex-linux/codex-desktop.png" codex-desktop.png
	fi
	make_desktop_entry codex-desktop "Codex Desktop" codex-desktop "Development;Utility;"

	local d
	for d in README.md CHANGELOG.md; do
		[[ -f ${d} ]] && dodoc "${d}"
	done
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Installed as /usr/bin/codex-desktop."
	elog "This is a live ebuild: every emerge re-downloads OpenAI's current"
	elog "Codex.dmg and rebuilds against whatever upstream main does with it."
	elog "Re-emerge whenever the app or OpenAI's Codex Desktop changes."
	elog
	elog "The Codex CLI itself is not installed by this ebuild. First launch"
	elog "can install @openai/codex with the app's bundled Node/npm, or you"
	elog "can manage the CLI yourself (e.g. dev-util/codex-bin if packaged)."
}

pkg_postrm() {
	xdg_pkg_postrm
}
