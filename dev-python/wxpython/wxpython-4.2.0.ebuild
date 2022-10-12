# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{8..10} )
WX_GTK_VER="3.2"

DISTUTILS_IN_SOURCE_BUILD="1"

inherit distutils-r1 multiprocessing virtualx wxwidgets

MY_PN="wxPython"
#MY_PV="${PV}.post2"
MY_PV="${PV}"

DESCRIPTION="A blending of the wxWindows C++ class library with Python"
HOMEPAGE="https://www.wxpython.org/"
SRC_URI="mirror://pypi/${P:0:1}/${MY_PN}/${MY_PN}-${PV}.tar.gz"
#SRC_URI="https://files.pythonhosted.org/packages/d9/33/b616c7ed4742be6e0d111ca375b41379607dc7cc7ac7ff6aead7a5a0bf53/wxPython-${PV}.tar.gz -> 

LICENSE="wxWinLL-3"
SLOT="4.0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~sparc ~x86"
IUSE="test webkit"
# Tests broken: #726812, #722716
RESTRICT="test"
#RESTRICT="!test? ( test )"

# wxPython doesn't seem to be able to optionally disable features. webkit is
# optionally patched out because it's so huge, but other elements are not,
# which makes us have to require all features from wxGTK
RDEPEND="
	>=x11-libs/wxGTK-3.2.1:${WX_GTK_VER}=[gstreamer,libnotify,opengl,sdl,tiff,webkit?,X]
	media-libs/libpng:0=
	media-libs/tiff:0
	media-libs/libjpeg-turbo:0"

BDEPEND="${RDEPEND}
	app-doc/doxygen
	dev-python/appdirs
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/sip
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/wheel
	dev-python/twine
	dev-python/requests
	dev-python/cython
	dev-python/sphinx
	dev-python/jinja
	dev-python/markupsafe
	dev-python/beautifulsoup4
	dev-python/attrdict3
	test? (
		${VIRTUALX_DEPEND}
		dev-python/appdirs[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
	)"

S="${WORKDIR}/${MY_PN}-${MY_PV}"

PATCHES=(
	"${FILESDIR}/${P}-skip-broken-tests.patch"
)

python_prepare_all() {
	if ! use webkit; then
		eapply "${FILESDIR}/${P}-no-webkit.patch"
		rm unittests/test_webview.py || die
	fi
	# Most of these tests disabled below fail because of the virtx/portage
	# environment, but some fail for unknown reasons.
	rm unittests/test_uiaction.py \
		unittests/test_notifmsg.py \
		unittests/test_mousemanager.py \
		unittests/test_display.py \
		unittests/test_pi_import.py \
		unittests/test_lib_agw_thumbnailctrl.py \
		unittests/test_sound.py || die

	distutils-r1_python_prepare_all
}

src_configure() {
	setup-wxwidgets
}

python_compile() {
	DOXYGEN=/usr/bin/doxygen ${PYTHON} build.py dox etg --nodoc || die
	${PYTHON} build.py build_py \
		--use_syswx \
		--no_magic \
		--jobs=$(makeopts_jobs) \
		--release || die
}

python_install() {
	distutils-r1_python_install --skip-build
}

python_test() {
	virtx epytest unittests
}
