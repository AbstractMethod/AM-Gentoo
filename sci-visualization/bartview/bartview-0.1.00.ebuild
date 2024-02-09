# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cuda

DESCRIPTION="Image viewer for multi-dimensional files from BART"
HOMEPAGE="https://github.com/mrirecon/view"
SRC_URI="https://github.com/mrirecon/view/archive/v${PV}.zip -> ${P}.zip"
#SRC_URI="http://deb.debian.org/debian/pool/main/b/bart-view/bart-view_${PV}.orig.tar.gz" -> "${PN}-${PV}.tar.gz"

LICENSE="Custom"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cuda"

DEPEND="
	x11-libs/gtk+:3
	x11-libs/pango
	media-libs/harfbuzz
	sci-libs/bart[srclib]
	cuda? (
		|| (
			( <dev-util/nvidia-cuda-toolkit-11 <sys-devel/gcc-9 )
			( =dev-util/nvidia-cuda-toolkit-11* =sys-devel/gcc-9* )
		)
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-makefile.patch"
	)

S="${WORKDIR}/view-${PV}"
MY_DEST="/opt/bart"
MY_D="${D}/${MY_DEST}"

src_prepare() {
	eapply ${PATCHES}

	if use cuda; then
		eapply "${FILESDIR}/${PN}-cuda.patch"
	fi

	eapply_user
}

src_install() {
	dodir "${MY_DEST}/bin"
	exeinto "${MY_DEST}/bin"
	newexe view bview
}
