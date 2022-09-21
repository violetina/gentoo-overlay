# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Depends: libgtk-3-0, libnotify4, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libuuid1, libappindicator3-1, libsecret-1-0

EAPI=7

inherit eutils pax-utils gnome2-utils xdg-utils
# 2022.5.0
# https://github.com/Kong/insomnia/releases/download/core%402022.5.0/Insomnia.Core-2022.5.0.tar.gz
DESCRIPTION="The most intuitive cross-platform REST API Client"
HOMEPAGE="https://insomnia.rest/"
SRC_URI="https://github.com/Kong/insomnia/releases/download/core%40${PV}/Insomnia.Core-${PV}.deb"
#LICENSE="Insomnia"
RESTRICT="mirror"

SLOT="0"
KEYWORDS="~amd64"
IUSE=""


DEPEND=""
RDEPEND="
	gnome-base/gconf
        x11-libs/gtk+:3
        app-crypt/libsecret
        dev-python/pyatspi
        x11-misc/xdg-utils
	x11-libs/libnotify
	dev-libs/libappindicator
	x11-libs/libXtst
	dev-libs/nss
"

S="${WORKDIR}"

src_unpack() {
	ar x "${DISTDIR}/${A}" || die
	unpack "${WORKDIR}/data.tar.xz"
}


src_install() {
	unpack usr/share/doc/insomnia/*.gz
	dodoc changelog

	insinto /usr/share
	doins -r usr/share/icons
	doins -r usr/share/applications

	cp -a opt "${D}" || die
	pax-mark rm "${ED}/opt/Insomnia/insomnia"
	make_wrapper "${PN}" "/opt/Insomnia/insomnia"
}

pkg_postinst() {
    gnome2_icon_cache_update
    xdg_desktop_database_update
}

pkg_postrm() {
    gnome2_icon_cache_update
    xdg_desktop_database_update
}
