# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit vcs-snapshot eutils

DESCRIPTION="Jpeg2000 Image Tools"
HOMEPAGE="http://kakadusoftware.com/"

LICENSE="closed source"
SLOT="0"
KEYWORDS="amd64"
IUSE="-static-libs -tiff"
REQUIRED_USE="tiff? ( !static-libs )"
RESTRICT=fetch
RDEPEND="tiff? ( media-libs/tiff )"
DEPEND="${RDEPEND}"

#S=${WORKDIR}/${P}
#S="${WORKDIR}/v7_9-01574L"
PATCHES=(
#	"${FILESDIR}/use_tiff.patch"
#	"${FILESDIR}/apps_addltiff.patch"
)

SRC_URI="${DISTDIR}/kakadu-7.9.1.tar.gz"
src_unpack() {
        vcs-snapshot_src_unpack
}

src_prepare() {
	default

	sed -i 'i2 DEFINES = -DKDU_INCLUDE_TIFF' make/Makefile-Linux-x86-64-gcc || die
#        mv make/Makefile-Linux-x86-64-gcc make/Makefile || die
	cp "${FILESDIR}/Makefile" Makefile
	use static-libs && epatch "${FILESDIR}/use_static.patch"
        use tiff && epatch "${FILESDIR}/use_tiff.patch"

}

#src_configure() {
#	econf --with-posix-regex
#}
#src_compile(){
#	cd make && make
#}
src_install() {
#	emake DESTDIR="${D}" install
	dobin  bin/Linux-x86-64-gcc/*
	dolib  lib/Linux-x86-64-gcc/*
}
