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

# Renaming Sources
#
# Sometimes the upstream URI uses generic names that can easily clash with other 
# packages when creating a single mirror.
# 
# Using the -> syntax allows you to rename the file when it's fetched from 
# upstream for storing on mirrors and in the local distdir.
#
# Here we download a file from upstream which has a plain name like 1.0.tar.gz 
# and save/mirror it with a better name like thepackage-1.0.tar.gz.
#
# SRC_URI="http://example.com/files/${PV}.tar.gz -> ${P}.tar.gz"

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

