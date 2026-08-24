# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="The official Python library for the OpenAI API"
HOMEPAGE="
	https://github.com/openai/openai-python/
	https://pypi.org/project/openai/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Deliberately 2.x, not the 3.x series: app-misc/hermes-agent is the only
# consumer here and it is developed against the 2.x API surface.
RDEPEND="
	>=dev-python/anyio-3.5.0[${PYTHON_USEDEP}]
	>=dev-python/distro-1.7.0[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.23.0[${PYTHON_USEDEP}]
	>=dev-python/jiter-0.10.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.9.0[${PYTHON_USEDEP}]
	dev-python/sniffio[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.11[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/hatch-fancy-pypi-readme[${PYTHON_USEDEP}]
"

# The aiohttp, datalib, realtime and voice-helpers extras are not expressed
# here; nothing in the tree needs them and hermes-agent depends on the
# packages it actually uses (e.g. dev-python/websockets) directly.
#
# Upstream's build-system pins hatchling==1.26.3. Portage supplies the
# backend itself and gpep517 ignores build-system.requires, so the newer
# hatchling in the tree is used and no patching is needed.
#
# Tests are not wired up: they need respx plus a recorded-mock harness that
# is not shipped in a usable form in the sdist.
