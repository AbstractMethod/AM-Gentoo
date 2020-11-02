# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

MY_PN="mango_unix"
MY_P="${MY_PN}.zip"

DESCRIPTION="Multi-Image Analysis GUI (MANGO) for medical image volumes"
HOMEPAGE="http://ric.uthscsa.edu/mango/"
SRC_URI="http://ric.uthscsa.edu/mango/downloads/${MY_P} -> ${P}.zip"

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="
	>=virtual/jre-1.5.0
	"
RDEPEND="${DEPEND}"

S="${WORKDIR}/Mango"

src_install() {
	einfo ${S}
	einfo ${D}

	mangodir="/usr/local/mango"
	mangobin="/usr/bin/mango"
	mangosrcdir="${D}${mangodir}"
	mangosrcbin="${D}usr/bin/mango"

	echo $mangodir
	echo $mangosrcdir
	echo $mangosrcbin

	dodir "${mangodir}"
	dodir /usr/bin
	dodir "${mangodir}/Library"
	dodir "${mangodir}/Plugins"

	cp -R "${S}"/* "${mangosrcdir}" || die "install failed!"
	echo "#!/bin/bash" > "${mangosrcbin}"
	echo "java -Xms64M -Xmx2000M -XX:MaxDirectMemorySize=4g -jar ${mangodir}/Mango.jar "'$@' >> "${mangosrcbin}"
	fperms 755 "${mangobin}"
}

