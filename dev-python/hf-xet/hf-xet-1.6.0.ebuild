# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-r1

DESCRIPTION="Fast transfer of large files with the Hugging Face Hub (Xet, Rust core)"
HOMEPAGE="
	https://github.com/huggingface/xet-core/
	https://pypi.org/project/hf-xet/
"

# Upstream ships a Rust-compiled extension. No cp314 wheel is published, but the
# cp38-abi3 manylinux wheel is forward-compatible with every CPython >=3.8 under
# the stable ABI, so we install that prebuilt wheel rather than vendoring the
# whole xet-core Cargo workspace + crate tree for a from-source build.
MY_WHL="hf_xet-${PV}-cp38-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
SRC_URI="
	https://files.pythonhosted.org/packages/67/4e/a28359bf1c1ecf11eba22123168c138698f7cb576ac678f5a2e16cd5da08/${MY_WHL}
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/gpep517[${PYTHON_USEDEP}]
"

# Prebuilt binary wheel; nothing to compile or QA-preserve beyond the .so.
QA_PREBUILT="*/site-packages/hf_xet/*.so"

S="${WORKDIR}"

src_unpack() {
	# The wheel is a zip; keep it in DISTDIR and install it per-impl below.
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
