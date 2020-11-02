# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python 2_7 )

DESCRIPTION="Media platform with a decentralized system of delivering and storing multimedia data."
HOMEPAGE="http://acestream.org"
SRC_URI="http://download.acestream.media/linux/acestream_${PV}_ubuntu_18.04_x86_64.tar.gz -> ${P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	dev-python/setuptools[python_targets_python2_7]
	<=dev-python/apsw-3.23.1-r1[python_targets_python2_7]
"
RDEPEND="
	${DEPEND}
	media-video/vlc
"
#dev-python/m2crypto

src_unpack() {
	unpack "${A}"
	S="${WORKDIR}"
	einfo "${S}"
}

src_install() {
	DEST="/opt/acestream"
	einfo "${D}"
	einfo "${DEST}"

	dodir "${DEST}"
	cp -R "${WORKDIR}/." "${D}${DEST}/"

	DEST1="/usr/bin"
	dodir "${DEST1}"

	local shell
	shell="${D}/${DEST1}/acestream_play.sh"
	echo '#!/bin/sh' > ${shell}
	echo '' >> ${shell}

	echo "aid=\`echo \$1 | grep -oP \"(?<=acestream://).*$\"\`" >> ${shell}

	echo "if [ -z \$aid ]; then" >> ${shell}
	echo "    echo \"Cannot parse URL\"" >> ${shell}
	echo "    exit" >> ${shell}
	echo "fi" >> ${shell}

	echo "vlc http://127.0.0.1:6878/ace/getstream?id=\$aid" >> ${shell}
	fperms 755 "${DEST1}/acestream_play.sh"

	shell="${D}/${DEST1}/acestream_console.sh"
	echo '#!/bin/sh' > ${shell}
	echo '' >> ${shell}
	echo "${DEST}/start-engine --client-console" >> ${shell}
	fperms 755 "${DEST1}/acestream_console.sh"

	# vlc http://127.0.0.1:6878/ace/getstream?id=XXXXXXXXXXXXXX
	# acestream://c71988a56c42a549dbe33a9ca75525046879e9bf
}
