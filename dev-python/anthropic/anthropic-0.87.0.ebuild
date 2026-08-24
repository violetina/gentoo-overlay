# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="The official Python library for the Anthropic API"
HOMEPAGE="
	https://github.com/anthropics/anthropic-sdk-python/
	https://pypi.org/project/anthropic/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Deliberately 0.87.0 rather than the 1.x series. Two reasons:
#   - app-misc/hermes-agent pins exactly this in tools/lazy_deps.py, flagged
#     there as the fix for CVE-2026-34450 and CVE-2026-34452.
#   - 1.0.0 switched its HTTP stack to dev-python/httpx2, so it is not a
#     drop-in for consumers built against the httpx-based client.
RDEPEND="
	>=dev-python/anyio-3.5.0[${PYTHON_USEDEP}]
	>=dev-python/distro-1.7.0[${PYTHON_USEDEP}]
	>=dev-python/docstring-parser-0.15[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.25.0[${PYTHON_USEDEP}]
	>=dev-python/jiter-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.9.0[${PYTHON_USEDEP}]
	dev-python/sniffio[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/hatch-fancy-pypi-readme[${PYTHON_USEDEP}]
"

# The bedrock and vertex extras are not expressed here; they pull the AWS and
# Google Cloud SDKs and nothing in this overlay uses them.
#
# Upstream's build-system pins hatchling==1.26.3. Portage supplies the backend
# and gpep517 ignores build-system.requires, so the tree's hatchling is used.
#
# Tests are not wired up: they need respx plus a recorded-mock harness that is
# not usable from the sdist.
