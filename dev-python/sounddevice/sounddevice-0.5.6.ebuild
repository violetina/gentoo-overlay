# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Play and record sound with Python"
HOMEPAGE="
	https://python-sounddevice.readthedocs.io/
	https://github.com/spatialaudio/python-sounddevice/
	https://pypi.org/project/sounddevice/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+numpy"

RDEPEND="
	dev-python/cffi[${PYTHON_USEDEP}]
	media-libs/portaudio
	numpy? ( dev-python/numpy[${PYTHON_USEDEP}] )
"
BDEPEND="$(python_gen_cond_dep '
	dev-python/cffi[${PYTHON_USEDEP}]
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
')"

# Upstream tests require working audio devices and are not packaged for the
# distro build path.
