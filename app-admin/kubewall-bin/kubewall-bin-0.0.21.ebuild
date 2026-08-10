# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Web UI to manage/visualize Kubernetes resources (prebuilt release binary)"
HOMEPAGE="https://github.com/kubewall/kubewall"

MY_PV="${PV}"
SRC_URI="
	amd64? ( https://github.com/kubewall/kubewall/releases/download/v${MY_PV}/kubewall_Linux_x86_64.tar.gz -> ${P}-linux-amd64.tar.gz )
	arm64? ( https://github.com/kubewall/kubewall/releases/download/v${MY_PV}/kubewall_Linux_arm64.tar.gz -> ${P}-linux-arm64.tar.gz )
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 arm64"

S="${WORKDIR}"

RESTRICT="strip mirror"

QA_PREBUILT="usr/bin/kubewall"

src_unpack() {
	# Both arch tarballs extract a flat "kubewall" binary (+ LICENSE/README) at
	# the archive root - same layout either way, just unpack whichever the
	# arch-conditional SRC_URI fetched.
	local archive
	if use amd64; then
		archive="${P}-linux-amd64.tar.gz"
	elif use arm64; then
		archive="${P}-linux-arm64.tar.gz"
	else
		die "no supported ARCH USE flag enabled for ${P}"
	fi
	unpack "${archive}"
}

src_install() {
	dobin kubewall

	local d
	for d in LICENSE LICENSE.md README.md; do
		[[ -f ${d} ]] && dodoc "${d}"
	done
}

pkg_postinst() {
	elog "Installed as /usr/bin/kubewall."
	elog "Run 'kubewall' and open http://localhost:7080 - it reads \$KUBECONFIG /"
	elog "~/.kube/config the same way kubectl does."
}
