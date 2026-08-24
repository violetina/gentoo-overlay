# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python SDK for the Firecrawl web scraping and crawling API"
HOMEPAGE="
	https://github.com/firecrawl/firecrawl/
	https://pypi.org/project/firecrawl-py/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/aiohttp[${PYTHON_USEDEP}]
	dev-python/httpx[${PYTHON_USEDEP}]
	dev-python/nest-asyncio[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.0[${PYTHON_USEDEP}]
	dev-python/python-dotenv[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/websockets[${PYTHON_USEDEP}]
"

src_prepare() {
	# [tool.setuptools.packages.find] has no include/exclude, so discovery
	# picks up the top-level tests/ package and the wheel installs it as
	# site-packages/tests. Portage rejects that (stray top-level file), and
	# rightly so -- it would collide with every other package doing the same.
	sed -i -e '/^\[tool\.setuptools\.packages\.find\]$/a include = ["firecrawl*"]' \
		pyproject.toml || die
	grep -q '^include = \["firecrawl\*"\]$' pyproject.toml ||
		die "packages.find include patch did not apply"

	distutils-r1_src_prepare
}

# Tests are not wired up: they hit the live Firecrawl API and need a key.
# Note that setup.py's install_requires lists pytest and asyncio; pyproject's
# [project.dependencies] overrides it (setuptools says so at build time), and
# RDEPEND above follows pyproject.
