# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-r1

DESCRIPTION="Fast state-of-the-art tokenizers optimized for research and production"
HOMEPAGE="
	https://github.com/huggingface/tokenizers/
	https://pypi.org/project/tokenizers/
"

# Rust-compiled extension. No cp314 wheel is published upstream, but the
# cp310-abi3 manylinux wheel targets the stable ABI and loads on CPython 3.14.
# Installing that prebuilt wheel avoids vendoring the tokenizers Cargo crate
# tree (huggingface/tokenizers bindings/python) for a from-source build.
MY_WHL="tokenizers-${PV}-cp310-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
SRC_URI="
	https://files.pythonhosted.org/packages/0d/d5/1353e5f677ec27c2494fb6a6725e82d56c985f53e90ec511369e7e4f02c6/${MY_WHL}
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/huggingface-hub-0.16.4[${PYTHON_USEDEP}]
"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/gpep517[${PYTHON_USEDEP}]
"

QA_PREBUILT="*/site-packages/tokenizers/*.so"

S="${WORKDIR}"

src_unpack() {
	cp "${DISTDIR}/${MY_WHL}" "${WORKDIR}/" || die
}

src_install() {
	python_foreach_impl _install_wheel
}

_install_wheel() {
	gpep517 install-wheel \
		--destdir="${D}" \
		--interpreter="${PYTHON}" \
		--prefix="${EPREFIX}/usr" \
		--optimize=all \
		"${WORKDIR}/${MY_WHL}" || die "install-wheel failed for ${EPYTHON}"
}
