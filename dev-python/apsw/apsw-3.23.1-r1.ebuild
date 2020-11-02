# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python2_7 python3_{6..9} )

inherit distutils-r1 flag-o-matic

MY_PV="${PV}-r1"
MY_P=${PN}-${MY_PV}

einfo $MY_P

DESCRIPTION="APSW - Another Python SQLite Wrapper"
HOMEPAGE="https://github.com/rogerbinns/apsw/"
SRC_URI="https://github.com/rogerbinns/apsw/archive/${MY_PV}.zip -> ${P}.zip"

#https://github.com/rogerbinns/apsw/archive/3.23.1-r1.tar.gz
#https://github.com/rogerbinns/apsw/archive/3.23.1-r1.zip

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="amd64 ~arm ~ppc64 x86"
IUSE="doc"

RDEPEND=">=dev-db/sqlite-${PV%_p*}"
DEPEND="${RDEPEND}
	app-arch/unzip"

S=${WORKDIR}/${MY_P}

PATCHES=( "${FILESDIR}/${PN}-3.6.20.1-fix_tests.patch" )

python_compile() {
	distutils-r1_python_compile --enable=load_extension
}

python_test() {
	"${PYTHON}" setup.py build_test_extension || die "Building of test loadable extension failed"
	"${PYTHON}" tests.py -v || die "Tests failed under ${EPYTHON}"
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/. )
	distutils-r1_python_install_all
}
