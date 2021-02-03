# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES=""

inherit cargo git-r3

DESCRIPTION="Get LazyMan stream links"
HOMEPAGE="https://github.com/tarkah/lazystream"
EGIT_REPO_URI="https://github.com/tarkah/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	media-video/vlc
	net-misc/streamlink
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/rust"

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_install() {
	cargo_src_install

	DEST="/usr/local/bin"
	dodir ${DEST}

	local script
	script="${D}/${DEST}/lazystream_nhl.sh"
	echo '#!/bin/sh' > ${script}

	echo '' >> ${script}
	echo "if [ \$# -lt 1 ]; then" >> ${script}
	echo "    echo 1>&2 \"$0: need video quality argument (i.e. 720p, 540p etc.)\"" >> ${script}
	echo "    exit 2" >> ${script}
	echo "fi" >> ${script}

	echo '' >> ${script}
	echo "if [ \$# -gt 1 ]; then" >> ${script}
	echo "    echo \"$0: Using first argument as quality.  Extras ignored.\"" >> ${script}
	echo "fi" >> ${script}

	echo '' >> ${script}
	echo "lazystream --sport nhl --quality \$1 play select --custom-player 'vlc \"--sout=#http{mux=ts,dst=:8080/stream}\"'" >> ${script}

	fperms 755 "${DEST}/lazystream_nhl.sh"
}

