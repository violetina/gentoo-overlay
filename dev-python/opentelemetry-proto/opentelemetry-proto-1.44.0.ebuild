# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_P="opentelemetry-python-${PV}"
DESCRIPTION="OpenTelemetry Python Proto"
HOMEPAGE="
	https://opentelemetry.io/
	https://pypi.org/project/opentelemetry-proto/
	https://github.com/open-telemetry/opentelemetry-python/
"
# Same monorepo tarball ::gentoo's opentelemetry-{api,sdk,semantic-conventions}
# use, so this shares their distfile rather than pulling a second copy.
SRC_URI="
	https://github.com/open-telemetry/opentelemetry-python/archive/refs/tags/v${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"

S="${WORKDIR}/${MY_P}/opentelemetry-proto"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	<dev-python/protobuf-8.0[${PYTHON_USEDEP}]
	>=dev-python/protobuf-5.0[${PYTHON_USEDEP}]
"
