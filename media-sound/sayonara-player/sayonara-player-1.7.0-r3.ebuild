# Copyright 1999-2019 Lucio Carreras
# Distributed under the terms of the GNU General Public License v3

EAPI=8

CMAKE_BUILD_TYPE=None
inherit gnome2-utils xdg-utils cmake

DESCRIPTION="Small, clear and fast audio player for Linux"
HOMEPAGE="https://sayonara-player.com/"
#SRC_URI="https://sayonara-player.com/sw/sayonara-player-1.7.0-stable3.tar.gz"
SRC_URI="https://sayonara-player.com/files/source/1.7.0-stable3/sayonara-player-1.7.0-stable3.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

MIN_QT_VERSION=5.3

RDEPEND="
	dev-libs/glib:2
	dev-python/pydbus
	>=dev-qt/qtcore-${MIN_QT_VERSION}:5
	>=dev-qt/qtdbus-${MIN_QT_VERSION}:5
	>=dev-qt/qtgui-${MIN_QT_VERSION}:5
	>=dev-qt/qtnetwork-${MIN_QT_VERSION}:5
	>=dev-qt/qtsql-${MIN_QT_VERSION}:5[sqlite]
	>=dev-qt/qtwidgets-${MIN_QT_VERSION}:5
	>=dev-qt/qtxml-${MIN_QT_VERSION}:5
	media-libs/gst-plugins-base:1.0
	media-libs/gstreamer:1.0
	media-libs/taglib
	media-plugins/gst-plugins-soundtouch:1.0
	sys-libs/zlib
	"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	"

S="${WORKDIR}/${PN}-1.7.0-stable3"

pkg_postinst() {
	elog "Optionally, install as well:"
	elog "  media-sound/lame"
	elog "  media-libs/gst-plugins-good:1.0"
	elog "  media-libs/gst-plugins-bad:1.0"

	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
