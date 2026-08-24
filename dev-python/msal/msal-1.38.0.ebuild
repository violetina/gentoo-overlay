# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Microsoft Authentication Library (MSAL) for Python"
HOMEPAGE="
	https://github.com/AzureAD/microsoft-authentication-library-for-python/
	https://pypi.org/project/msal/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Upstream asks for PyJWT[crypto]; dev-python/pyjwt carries cryptography only
# as a test dep (it is an optfeature there), so depend on it directly or
# msal's RSA/certificate client-credential flows fail at import.
RDEPEND="
	>=dev-python/cryptography-2.5[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.0.0[${PYTHON_USEDEP}]
"

# Tests are not wired up: most of the suite talks to live AAD endpoints.
