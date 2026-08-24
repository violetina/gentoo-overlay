# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_P="opentelemetry-python-${PV}"
DESCRIPTION="OpenTelemetry Collector Protobuf over HTTP Exporter"
HOMEPAGE="
	https://opentelemetry.io/
	https://pypi.org/project/opentelemetry-exporter-otlp-proto-http/
	https://github.com/open-telemetry/opentelemetry-python/
"
# Same monorepo tarball ::gentoo's opentelemetry-{api,sdk,semantic-conventions}
# use, so this shares their distfile rather than pulling a second copy.
SRC_URI="
	https://github.com/open-telemetry/opentelemetry-python/archive/refs/tags/v${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"

S="${WORKDIR}/${MY_P}/exporter/opentelemetry-exporter-otlp-proto-http"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/googleapis-common-protos-1.52[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-api-1.15[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-exporter-otlp-proto-common-${PV}[${PYTHON_USEDEP}]
	~dev-python/opentelemetry-proto-${PV}[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-sdk-1.44.0[${PYTHON_USEDEP}]
	<dev-python/opentelemetry-sdk-1.45.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.7[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.5.0[${PYTHON_USEDEP}]
"
# Tests are not wired up: the OTLP exporter suite needs a live collector.
