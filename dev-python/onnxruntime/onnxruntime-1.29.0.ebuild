# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# cp314-cp314 wheel: only the 3.14 interpreter can load it, so this package is
# pinned to a single Python target.
PYTHON_COMPAT=( python3_14 )

inherit python-r1

DESCRIPTION="Cross-platform ML inferencing accelerator (ONNX Runtime Python bindings)"
HOMEPAGE="
	https://onnxruntime.ai/
	https://github.com/microsoft/onnxruntime/
	https://pypi.org/project/onnxruntime/
"

# The importable `onnxruntime` Python module is not produced by GURU's
# sci-libs/onnxruntime[-python] without a very large C++/CMake compile (onnx,
# re2, nanobind, cpuinfo ...). Upstream's cp314 manylinux wheel bundles the
# prebuilt libonnxruntime .so, so we install that instead of building the
# engine from source.
MY_WHL="onnxruntime-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl"
SRC_URI="
	https://files.pythonhosted.org/packages/65/54/9f197c578d3d3d7bea16971e233e5483981228eec73748585cf7b5933403/${MY_WHL}
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-python/coloredlogs[${PYTHON_USEDEP}]
	dev-python/flatbuffers[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.21.6[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	>=dev-python/protobuf-4.25.8[${PYTHON_USEDEP}]
	dev-python/sympy[${PYTHON_USEDEP}]
"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/gpep517[${PYTHON_USEDEP}]
"

QA_PREBUILT="*/site-packages/onnxruntime/capi/*.so*"

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
