# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="https://github.com/bavc/qctools.git"
inherit qmake-utils git-r3
DESCRIPTION="MediaConch"
HOMEPAGE="https://mediaarea.net/MediaConch/"
LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc qt5 static-libs"
RDEPEND="
	media-video/mediainfo
	media-libs/libzen
	media-video/ffmpeg
	net-misc/curl
	dev-libs/jansson
	x11-libs/qwt:5
"
DEPEND="${RDEPEND}"
S="${WORKDIR}/${P}/Project/QtCreator"
BINQMAKE="qmake -qt=qt5"
src_compile() {
	cd "${WORKDIR}" 
	sh "${P}/Project/BuildAllFromSource/init_ffmpeg.sh"
	BINQMAKE="qmake -qt=qt5" sh "${P}/Project/BuildAllFromSource/init_qwt.sh"
	sh "${P}/Project/BuildAllFromSource/init_blackmagic.sh"

	TARGETS="qctools-lib qctools-cli qctools-gui"
	for target in ${TARGETS}; do
	    cd $S/${target}
	    eqmake5
		emake
	done
	eqmake5
	emake
}
src_install() {
        TARGETS="qctools-lib qctools-cli qctools-gui"
        for target in ${TARGETS}; do
            	cd $S/${target}
		emake INSTALL_ROOT="${ED}" install
       done
	emake INSTALL_ROOT="${ED}" install

}
