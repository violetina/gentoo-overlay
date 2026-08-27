# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# cp314-cp314 wheel: only the 3.14 interpreter can load it, so this package is
# pinned to a single Python target.
EAPI=8

PYTHON_COMPAT=( python3_14 )

inherit python-r1

DESCRIPTION="Fast inference engine for Transformer models (CTranslate2 Python bindings)"
HOMEPAGE="
	https://github.com/OpenNMT/CTranslate2/
	https://pypi.org/project/ctranslate2/
"

# CTranslate2 is a C++ inference engine; upstream publishes NO sdist for the
# Python package (source builds require the full CMake project + a BLAS
# backend). The cp314 manylinux wheel bundles libctranslate2 and its runtime
# .so libs, so we install that prebuilt wheel rather than reproducing the C++
# build here.
MY_WHL="ctranslate2-${PV}-cp314-cp314-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"
SRC_URI="
	https://files.pythonhosted.org/packages/ee/d0/9816494d5ff0745bdf9abe5af04e57a103a416444e604cbe83a6eb0aed7b/${MY_WHL}
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.3[${PYTHON_USEDEP}]
"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/gpep517[${PYTHON_USEDEP}]
"

QA_PREBUILT="*/site-packages/ctranslate2/*.so*"

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
