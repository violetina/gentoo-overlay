EAPI=8

PYTHON_COMPAT=( python3_12 python3_13 python3_14 )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

MY_PV="2026.8.18"

# The web dashboard and the TUI are npm workspaces built with vite and
# esbuild. There is no vendored node_modules tarball, so building them means
# running `npm ci` against the registry from src_compile -- hence the
# network-sandbox restriction below. Turn both flags off for a fully sandboxed
# build of just the Python side.
#
# System npm cannot be used: upstream's .npmrc sets engine-strict=true and
# package.json requires npm "<11.10.0 || >=11.17.0". net-libs/nodejs-26.3.0
# ships npm 11.16.0, squarely inside the excluded range -- that range exists
# because those npm versions honour min-release-age but do not understand
# min-release-age-exclude, so they reject the packages .npmrc deliberately
# exempts. Fetch the npm that upstream's Nix build pins instead.
NPM_PV="12.0.2"
NPM_TARBALL="npm-${NPM_PV}.tgz"

DESCRIPTION="Self-improving Hermes AI agent"
HOMEPAGE="https://github.com/NousResearch/hermes-agent"
SRC_URI="
	https://github.com/NousResearch/${PN}/archive/refs/tags/v${MY_PV}.tar.gz
		-> ${PN}-${PV}.tar.gz
	web? ( https://registry.npmjs.org/npm/-/${NPM_TARBALL} )
	tui? ( https://registry.npmjs.org/npm/-/${NPM_TARBALL} )
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+tui +web"

RESTRICT="
	web? ( network-sandbox )
	tui? ( network-sandbox )
"

# Upstream exact-pins every dependency (==X.Y.Z) as a PyPI supply-chain
# measure; see the rationale in pyproject.toml. Those pins are deliberately
# not reproduced here -- the tree is the trusted source of versions, and
# several pins are already behind it. Only upstream's security-motivated
# floors are kept.
#
# Not reproduced from [project.dependencies]:
#   tzdata, pywinpty, pywin32, concurrent-log-handler
#     -- all marked sys_platform == 'win32'
#   nemo-relay -- published as wheels only, marker-gated, and upstream
#     documents a no-op Relay host fallback when it is absent
#
# dev-python/openai and dev-python/fire are unconditional core imports and
# are not in ::gentoo; they live in this overlay alongside dev-python/jiter,
# which openai needs.
RDEPEND="$(python_gen_cond_dep '
	dev-python/certifi[${PYTHON_USEDEP}]
	dev-python/croniter[${PYTHON_USEDEP}]
	>=dev-python/cryptography-50.0.0[${PYTHON_USEDEP}]
	dev-python/fastapi[${PYTHON_USEDEP}]
	dev-python/fire[${PYTHON_USEDEP}]
	dev-python/httpx[${PYTHON_USEDEP}]
	dev-python/jinja2[${PYTHON_USEDEP}]
	dev-python/markdown[${PYTHON_USEDEP}]
	dev-python/openai[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/pathspec[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/prompt-toolkit[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/ptyprocess[${PYTHON_USEDEP}]
	dev-python/pydantic[${PYTHON_USEDEP}]
	dev-python/pyjwt[${PYTHON_USEDEP}]
	dev-python/python-dotenv[${PYTHON_USEDEP}]
	dev-python/python-multipart[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
	dev-python/ruamel-yaml[${PYTHON_USEDEP}]
	dev-python/socksio[${PYTHON_USEDEP}]
	dev-python/tenacity[${PYTHON_USEDEP}]
	>=dev-python/urllib3-2.7.0[${PYTHON_USEDEP}]
	dev-python/uvicorn[${PYTHON_USEDEP}]
	dev-python/websockets[${PYTHON_USEDEP}]
')"
# The TUI bundle is a single self-contained entry.js, but it is still run as
# `node .../dist/entry.js` at runtime. The web dashboard is static assets
# served by uvicorn, so it needs no Node once built.
RDEPEND+="
	tui? ( >=net-libs/nodejs-22.22.0 )
"
BDEPEND="
	web? ( >=net-libs/nodejs-22.22.0 )
	tui? ( >=net-libs/nodejs-22.22.0 )
"

S="${WORKDIR}/${PN}-${MY_PV}"

# ${WORKDIR}/npm, not ${WORKDIR}/package: the npm tarball unpacks to
# package/, which would collide with anything else doing the same.
NPM_DIR="${WORKDIR}/npm"

src_unpack() {
	unpack "${PN}-${PV}.tar.gz"

	if use web || use tui; then
		mkdir -p "${NPM_DIR}" || die
		tar -xzf "${DISTDIR}/${NPM_TARBALL}" -C "${NPM_DIR}" \
			--strip-components=1 || die "failed to unpack ${NPM_TARBALL}"
	fi
}

src_prepare() {
	# Upstream caps requires-python at <3.14 because uv would otherwise pick
	# 3.14 and source-build Rust transitives that lack cp314 wheels. Under
	# portage the interpreter and all transitives come from the tree, so the
	# cap only blocks the profile's python3_14. Widen it.
	sed -i -e 's/^requires-python = ">=3\.11,<3\.14"$/requires-python = ">=3.12,<3.15"/' \
		pyproject.toml || die
	grep -q 'requires-python = ">=3.12,<3.15"' pyproject.toml ||
		die "requires-python patch did not apply"

	# Drop uv's exclude-newer/exclude-newer-package cutoffs; version selection
	# is the package manager's job here. Inert under portage (setuptools never
	# reads [tool.uv]) but keeps the tree honest about intent.
	sed -i '/^exclude-newer/d' pyproject.toml || die "failed to relax uv exclude-newer"

	default
}

python_compile() {
	# setup.py subclasses bdist_wheel/sdist and raises unless
	# HERMES_NIX_BUILD=1, because a bare wheel omits the bundled asset trees
	# (locales, skills, optional-skills, optional-mcps) that are resolved at
	# runtime. We install those from ${S} in python_install_all and point the
	# runtime at them via /etc/env.d, so the refusal does not apply here.
	local -x HERMES_NIX_BUILD=1
	distutils-r1_python_compile
}

src_compile() {
	distutils-r1_src_compile

	use web || use tui || return 0

	# npm insists on a writable HOME and cache; keep both inside ${T} so
	# nothing lands in the builder's real home.
	local -x HOME="${T}/npm-home"
	local -x npm_config_cache="${T}/npm-cache"
	mkdir -p "${HOME}" "${npm_config_cache}" || die

	local npm=( node "${NPM_DIR}/bin/npm-cli.js" )

	einfo "Installing node workspace dependencies (npm ci, needs network)"
	CI=true "${npm[@]}" ci --no-fund --no-audit || die "npm ci failed"

	if use web; then
		einfo "Building the web dashboard"
		# Build from web/ so vite.config.ts and the tsconfig project
		# references resolve; the workspace node_modules/ is at ../.
		cd web || die
		node ../node_modules/typescript/bin/tsc -b || die "web tsc failed"
		# vite.config.ts points outDir at ../hermes_cli/web_dist for the
		# monorepo layout; override it so the output stays under web/.
		node ../node_modules/vite/bin/vite.js build --outDir dist ||
			die "web vite build failed"
		cd "${S}" || die
	fi

	if use tui; then
		einfo "Building the TUI bundle"
		# esbuild bundles everything into a single dist/entry.js; must run
		# from the workspace root where node_modules/ lives.
		node ui-tui/scripts/build.mjs || die "TUI esbuild failed"
	fi
}

python_install_all() {
	distutils-r1_python_install_all

	# Asset trees that [tool.setuptools.package-data] does not cover. The
	# bundled plugins/ tree is *not* listed: packages.find installs it as a
	# real package next to hermes_cli, which is exactly where
	# get_bundled_plugins_dir() looks by default.
	insinto /usr/share/hermes-agent
	doins -r locales skills optional-skills optional-mcps

	# Upstream's supported packaging interface for out-of-tree assets -- the
	# same env vars nix/hermes-agent.nix sets on its makeWrapper call, and
	# documented in hermes_cli/tips.py as "used by Homebrew and Nix
	# packaging".
	#
	# env.d rather than a patch to the in-code fallbacks: the skills and
	# optional-mcps lookups take a caller-supplied `default` argument (every
	# caller passes a source-checkout path), which wins over the fallback we
	# could patch. Only the env var takes precedence over that default.
	local envd="${T}/99hermes-agent"
	cat > "${envd}" <<-EOF || die
		HERMES_BUNDLED_LOCALES="${EPREFIX}/usr/share/hermes-agent/locales"
		HERMES_BUNDLED_SKILLS="${EPREFIX}/usr/share/hermes-agent/skills"
		HERMES_OPTIONAL_SKILLS="${EPREFIX}/usr/share/hermes-agent/optional-skills"
		HERMES_OPTIONAL_MCPS="${EPREFIX}/usr/share/hermes-agent/optional-mcps"
	EOF

	if use web; then
		# Renamed rather than doins'd into a differently-named insinto:
		# keeps the whole tree (including any dotfiles) in one copy.
		mv web/dist web/web_dist || die
		insinto /usr/share/hermes-agent
		doins -r web/web_dist
		echo "HERMES_WEB_DIST=\"${EPREFIX}/usr/share/hermes-agent/web_dist\"" \
			>> "${envd}" || die
	fi

	if use tui; then
		# Layout mirrors nix's $out/ui-tui: dist/entry.js plus the
		# package.json that gives node the "type": "module" resolution it
		# needs to run entry.js.
		insinto /usr/share/hermes-agent/ui-tui
		doins ui-tui/package.json
		doins -r ui-tui/dist
		{
			echo "HERMES_TUI_DIR=\"${EPREFIX}/usr/share/hermes-agent/ui-tui\""
			echo "HERMES_NODE=\"${EPREFIX}/usr/bin/node\""
		} >> "${envd}" || die
	fi

	doenvd "${envd}"

	dodoc README.md SECURITY.md
}

pkg_postinst() {
	if ! use web || ! use tui; then
		ewarn "Built without:$(usev !web ' web')$(usev !tui ' tui'). Both need"
		ewarn "'npm ci' against the npm registry during src_compile, which is"
		ewarn "why they carry RESTRICT=network-sandbox. Enable the flags to"
		ewarn "build them."
	fi

	elog "Bundled locales, skills, optional-skills and optional-mcps are"
	elog "installed under ${EROOT}/usr/share/hermes-agent and wired up via"
	elog "/etc/env.d/99hermes-agent. Run 'env-update && source /etc/profile'"
	elog "or start a new login shell before first use."
	elog ""
	elog "Those env vars take precedence over a source checkout's own asset"
	elog "trees. If you also develop against a hermes-agent git clone, unset"
	elog "HERMES_BUNDLED_*, HERMES_OPTIONAL_* and HERMES_TUI_DIR in that shell."
	elog ""
	elog "Hermes Agent expects many optional providers and skills." \
		"Ensure the corresponding Python packages are installed."
}
