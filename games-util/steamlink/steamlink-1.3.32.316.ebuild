EAPI=8

inherit desktop xdg

DESCRIPTION="Standalone Steam Link client for Linux"
HOMEPAGE="https://store.steampowered.com/app/353380/Steam_Link/"
SRC_URI="https://repo.steampowered.com/steamlink/${PV}/steamlink-${PV}.tgz -> ${P}.tgz"

LICENSE="ValveSteamLink"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

RDEPEND="
	media-libs/alsa-lib
	media-libs/libsdl3
	media-libs/sdl3-image
	media-libs/sdl3-mixer
	media-libs/sdl3-ttf
	>=media-video/ffmpeg-7.0
	media-video/pipewire
	media-libs/libva
	x11-libs/libvdpau
	media-libs/libvpx
	dev-qt/qtbase:6[dbus,evdev,gui,network,opengl,udev,widgets]
	dev-qt/qtsvg:6
	dev-qt/qtwayland:6
	gui-libs/libdecor
	media-libs/libpulse
	virtual/jack
	virtual/libusb:1
	virtual/libudev:0
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	sys-apps/dbus
	sys-libs/zlib
"

S="${WORKDIR}/package"

QA_PREBUILT="opt/${PN}/bin/steamlink opt/${PN}/lib/*.so*"

src_install() {
	local instdir="/opt/${PN}"

	insinto "${instdir}"
	doins -r bin lib

	exeinto "${instdir}/bin"
	fperms 0755 "${instdir}/bin/steamlink"

	dodoc README.txt ThirdPartyLegalNotices.html ThirdPartyLegalNotices.css

	cat <<-EOF > "${T}/${PN}"
		#!/bin/sh
		export LD_LIBRARY_PATH="${instdir}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
		exec "${instdir}/bin/steamlink" "$@"
	EOF
	newbin "${T}/${PN}" "${PN}"

	make_desktop_entry \
		"${PN}" \
		"Steam Link" \
		"" \
		"Game;Utility;RemoteAccess;" \
		"StartupWMClass=steamlink"
}

pkg_postinst() {
	einfo "Steam Link streams games from another PC running Steam."
	einfo "This package installs Valve's official binary downloaded at build time."
}
