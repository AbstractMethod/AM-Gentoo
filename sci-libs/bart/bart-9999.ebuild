# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils git-r3 versionator

MY_PV="${PV}"
MY_PN="${PN}"
INIT_N="v"

DESCRIPTION="Berkely Advanced Reconstruction Toolbox for Computational MRI"
HOMEPAGE="http://mrirecon.github.io/bart/"
EGIT_REPO_URI="https://github.com/mrirecon/bart"
#SRC_URI="https://github.com/mrirecon/bart/archive/${INIT_N}${MY_PV}.tar.gz"
#https://github.com/mrirecon/bart/archive/v0.5.00.tar.gz

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
#IUSE="cuda doc debug fpic ismrmrd nolapacke matlab memcfl openmp python"
IUSE="cuda doc debug nolapacke openmp parallel"

DEPEND="
	>=app-admin/eselect-1.4.9-r100
	sci-libs/fftw
	sci-libs/openblas
	nolapacke? ( sci-libs/openblas[lapack] )
	!nolapacke? ( sci-libs/lapack[lapacke] )
	cuda? ( dev-util/nvidia-cuda-toolkit )
"
RDEPEND="${DEPEND}"

RESTRICT="debug? ( strip )"

MY_DEST="/usr/local/bart"
MY_D="${D}/${MY_DEST}"

src_prepare() {
	einfo "${S}"

	epatch "${FILESDIR}/bart-matlab_char16_t.patch"
	epatch "${FILESDIR}/bart-matplotlib-2.2.2.patch"
#	epatch "${FILESDIR}/bart-findopenblas-0.3.5.patch"
	epatch "${FILESDIR}/bart-linkopenblas.patch"

	if use debug; then
		eapply "${FILESDIR}/${PN}-debug.patch"
	fi

	if use parallel; then
		eapply "${FILESDIR}/${PN}-parallel.patch"
	fi

	if use openmp; then
		eapply "${FILESDIR}/${PN}-openmp.patch"
	fi

	if use cuda; then
		eapply "${FILESDIR}/${PN}-cuda.patch"
	fi

	eapply_user

#	CMAKE_VERBOSE="ON"
#	CMAKE_WARN_UNUSED_CLI="yes"

#	cmake-utils_src_prepare
}

#src_configure() {
#	local mycmakeargs
#
#	if use nolapacke; then 
#		mycmakeargs=(
#			-DCMAKE_INSTALL_PREFIX="${MY_DEST}"
#			#-DOpenBLAS_CBLAS_INCLUDE_DIR="/usr/include/openblas"
#			#-DOpenBLAS_LIB="/usr/lib/libopenblas_threads.so"
#			#-DOpenBLAS_PARALLEL_LIB="/usr/lib/libopenblas_threads.so"
##			#-DLAPACK_LIB="/usr/lib/libopenblas_threads.so"
#			-DLAPACKE_BLAS_LIB="/usr/lib/libopenblas_threads.so"
#			-DLAPACKE_CBLAS_LIB="/usr/lib/libopenblas_threads.so"
#			#-DLAPACKE_LAPACKE_LIB="/usr/lib/libopenblas_threads.so"
#			-DLAPACKE_LAPACK_LIB="/usr/lib/libopenblas_threads.so"
#			-DLAPACKE_CBLAS_INCLUDE_DIR="/usr/include/openblas/"
#			#-DLAPACKE_LAPACKE_INCLUDE_DIR="/usr/include/openblas/"
#			$(cmake-utils_use nolapacke BART_NO_LAPACKE)
#			$(cmake-utils_use ismrmrd BART_ISMRMRD)
#			$(cmake-utils_use fpic BART_FPIC)
#			$(cmake-utils_use memcfl BART_ENABLE_MEM_CFL)
#			$(cmake-utils_use doc BART_GENERATE_DOC)
#			$(cmake-utils_use openmp USE_OPENMP)
#			$(cmake-utils_use cuda USE_CUDA)
#		)
#	else
#		mycmakeargs=(
#			-DCMAKE_INSTALL_PREFIX="${MY_DEST}"
#			$(cmake-utils_use nolapacke BART_NO_LAPACKE)
#			$(cmake-utils_use ismrmrd BART_ISMRMRD)
#			$(cmake-utils_use fpic BART_FPIC)
#			$(cmake-utils_use memcfl BART_ENABLE_MEM_CFL)
#			$(cmake-utils_use doc BART_GENERATE_DOC)
#			$(cmake-utils_use openmp USE_OPENMP)
#			$(cmake-utils_use cuda USE_CUDA)
#		)
#	fi
#
#	if use debug; then
#		CMAKE_BUILD_TYPE='Debug'
#	fi
#
#	cmake-utils_src_configure
#}

#src_compile() {
#	emake || die
#	cmake-utils_src_compile
#}

src_install() {
#	einstall
#	emake DESTDIR="${MY_DEST}" install
#	cmake-utils_src_install
#
	dodir "${MY_DEST}"

	cp "${S}/startup.sh" "${MY_D}/startup.sh"
	cp "${S}/startup.m" "${MY_D}/startup.m"
	cp "${S}/startup.py" "${MY_D}/startup.py"

	if use doc; then
		dodir "${MY_DEST}/share/doc/BART"
		cp "${S}/doc/commands.txt" "${MY_D}/share/doc/BART/"
		fperms a+r "${MY_DEST}/share/doc/BART/commands.txt"
	fi

	cp -R "${S}/matlab" "${MY_D}/"
	cp -R "${S}/python" "${MY_D}/"


	# do bartview shortcuts
	dodir /usr/local/bin
	exeinto /usr/local/bin
	local bartview

	bartview="${D}/usr/local/bin/bartview"
	echo '#!/bin/sh' > ${bartview}
	echo '' >> ${bartview}
	echo "python3 ${MY_DEST}/python/bartview3.py \$1" >> ${bartview}
	fperms 0755 /usr/local/bin/bartview

	bartview="${D}/usr/local/bin/bartview2"
	echo '#!/bin/sh' > ${bartview}
	echo '' >> ${bartview}
	echo "python2 ${MY_DEST}/python/bartview.py \$1" >> ${bartview}
	fperms 0755 /usr/local/bin/bartview2

	dodir "${MY_DEST}/bin"
	exeinto ${MY_DEST}/bin
	doexe bart
}

pkg_postinst() {
	elog
	elog "bart has been installed into: ${MY_DEST}"
	elog "bart binaries are in: ${MY_DEST}/bin.  You might want to add "
	elog "this to your PATH, but be wary of filename collisions."
}
