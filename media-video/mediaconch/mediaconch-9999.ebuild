# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="https://github.com/MediaArea/MediaConch_SourceCode.git"
inherit autotools qmake-utils git-r3
DESCRIPTION="MediaConch"
HOMEPAGE="https://mediaarea.net/MediaConch/"
LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc qt5 static-libs server"
RDEPEND="
  media-video/mediainfo
  media-libs/libzen
  net-misc/curl
  dev-libs/jansson
"
DEPEND="${RDEPEND}"
S="${WORKDIR}/${P}"

pkg_setup() {
  TARGETS="GNU/CLI"
  use qt5 && TARGETS+=" Qt"
  use server && TARGETS+=" GNU/Server"
}

src_prepare() {
  eapply_user
  cd "${S}"/Project/GNU/CLI
  eautoreconf
  cd "${S}"/Project/GNU/Server
  eautoreconf
}

src_configure() {
  local target
  for target in ${TARGETS}; do
    if	[[ ${target} == "GNU/CLI" ]]; then
      cd "${S}"/Project/GNU/CLI
      econf \
      --disable-dependency-tracking \
      --enable-shared \
      $(use_enable debug) \
      $(use_enable static-libs static)
    elif [[ ${target} == "GNU/Server" ]]; then
      cd "${S}"/Project/${target}
      econf
    fi
  done
}
src_compile() {
  local target
  for target in ${TARGETS}; do
    if	[[ ${target} == "GNU/CLI" ]]; then
      cd "${S}"/Project/${target}
      default
    elif [[ ${target} == "GNU/Server" ]]; then
      cd "${S}"/Project/${target}
      default
    elif [[ ${target} == "Qt" ]]; then
      cd "${S}"/Project/Qt
    eqmake5
    fi
  done
}
src_install() {
  local target
  for target in ${TARGETS}; do
    if [[ ${target} == "GNU/CLI" ]]; then
      cd "${S}"/Project/${target}
      default
    elif [[ ${target} == "GNU/Server" ]]; then
      cd "${S}"/Project/${target}
      default
    elif [[ ${target} == "Qt" ]]; then
      cd "${S}"/Project/${target}
      emake INSTALL_ROOT="${ED}" install
    fi
  done
}

