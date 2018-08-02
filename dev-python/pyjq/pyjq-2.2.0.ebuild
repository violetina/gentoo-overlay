# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

# The selftests fail with pypy, and urlgrabber segfaults for me.
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="python binding for jq"
HOMEPAGE="https://github.com/doloopwhile/pyjq/releases"
#SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
SRC_URI="https://github.com/doloopwhile/pyjq/archive/v2.2.0.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm arm64 hppa ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE=""

# Depend on a curl with curl_ssl_* USE flags.
# libcurl must not be using an ssl backend we do not support.
# If the libcurl ssl backend changes pycurl should be recompiled.
# If curl uses gnutls, depend on at least gnutls 2.11.0 so that pycurl
# does not need to initialize gcrypt threading and we do not need to
# explicitly link to libgcrypt.
RDEPEND="(
	app-misc/jq
	)"

DEPEND="${RDEPEND}"
# Needed for individual runs of testsuite by python impls.
DISTUTILS_IN_SOURCE_BUILD=1

python_prepare_all() {
	distutils-r1_python_prepare_all
}

#python_configure_all() {
	# Override faulty detection in setup.py, bug 510974.
#	export PYCURL_SSL_LIBRARY=${CURL_SSL/libressl/openssl}
#}

python_compile() {
	python_is_python3 || local -x CFLAGS="${CFLAGS} -fno-strict-aliasing"
	distutils-r1_python_compile
}


python_install_all() {
	distutils-r1_python_install_all
}
