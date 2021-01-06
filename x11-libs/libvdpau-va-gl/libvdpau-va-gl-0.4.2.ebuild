# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake cmake-multilib git-r3

DESCRIPTION="VDPAU driver with VA-API OpenGL backend"
HOMEPAGE="https://github.com/i-rinat/libvdpau-va-gl"
#SRC_URI="https://github.com/i-rinat/libvdpau-va-gl.git"
EGIT_REPO_URI="https://github.com/i-rinat/libvdpau-va-gl.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	x11-libs/libva[${MULTILIB_USEDEP}]
	media-libs/mesa[${MULTILIB_USEDEP}]
"
RDEPEND="${DEPEND}"
BDEPEND=""
