# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Persistent, encrypted token cache for MSAL"
HOMEPAGE="
	https://github.com/AzureAD/microsoft-authentication-extensions-for-python/
	https://pypi.org/project/msal-extensions/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/msal-1.29[${PYTHON_USEDEP}]
"

# portalocker was dropped as a hard dependency in 1.3.x -- the file lock is
# implemented in-tree now. Tests are not wired up (they exercise Windows
# DPAPI and macOS Keychain paths).
