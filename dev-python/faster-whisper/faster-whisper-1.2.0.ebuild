# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
# ctranslate2 + onnxruntime here are prebuilt cp314-only wheels, so the whole
# stack is single-impl on 3.14.
PYTHON_COMPAT=( python3_14 )

inherit distutils-r1 pypi

DESCRIPTION="Faster Whisper transcription with CTranslate2"
HOMEPAGE="
	https://github.com/SYSTRAN/faster-whisper/
	https://pypi.org/project/faster-whisper/
"

# PyPI still serves this project's sdist under the legacy hyphenated name
# (faster-whisper-X.tar.gz), not the PEP 503 normalized faster_whisper-X the
# pypi eclass derives, so point SRC_URI at the real artifact.
SRC_URI="$(pypi_sdist_url --no-normalize "${PN}" "${PV}")"
S="${WORKDIR}/${P}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/ctranslate2-4.0[${PYTHON_USEDEP}]
	<dev-python/ctranslate2-5[${PYTHON_USEDEP}]
	>=dev-python/huggingface-hub-0.13[${PYTHON_USEDEP}]
	>=dev-python/tokenizers-0.13[${PYTHON_USEDEP}]
	<dev-python/tokenizers-1[${PYTHON_USEDEP}]
	>=dev-python/onnxruntime-1.14[${PYTHON_USEDEP}]
	<dev-python/onnxruntime-2[${PYTHON_USEDEP}]
	>=dev-python/av-11[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
"

# Tests download model weights from the Hugging Face Hub and decode audio.
