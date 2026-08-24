EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Cross-platform REST/GraphQL/gRPC API client"
HOMEPAGE="https://insomnia.rest/"
SRC_URI="https://github.com/Kong/insomnia/releases/download/core@${PV}/Insomnia.Core-${PV}.deb -> ${P}.deb"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core
	dev-libs/libappindicator:3
	dev-libs/nss
	media-libs/alsa-lib
	net-print/cups
	sys-apps/dbus
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-misc/xdg-utils
	virtual/libudev:0
"

S="${WORKDIR}"
QA_PREBUILT="opt/Insomnia/*"

src_unpack() {
	unpack_deb "${A}"
}

src_install() {
	local appdir="/opt/Insomnia"

	insinto "${appdir}"
	doins -r opt/Insomnia/.
	fperms 0755 "${appdir}/insomnia"

	cat <<EOS > "${T}/${PN}"
#!/bin/sh
exec ${appdir}/insomnia "$@"
EOS
	fperms 0755 "${T}/${PN}"
	newbin "${T}/${PN}" "${PN}"

	domenu usr/share/applications/insomnia.desktop

	if [[ -d usr/share/icons ]]; then
		insinto /usr/share
		doins -r usr/share/icons
	fi

	local changelog="usr/share/doc/insomnia/changelog.gz"
	if [[ -f ${changelog} ]]; then
		gunzip -c "${changelog}" > "${T}/changelog"
		docompress -x /usr/share/doc/${PF}/changelog
		dodoc "${T}/changelog"
	fi
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
