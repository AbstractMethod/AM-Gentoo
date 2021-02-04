# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cuda eutils toolchain-funcs

DESCRIPTION="Berkely Advanced Reconstruction Toolbox for Computational MRI"
HOMEPAGE="http://mrirecon.github.io/bart/"
SRC_URI="https://github.com/mrirecon/bart/archive/v${PV}.tar.gz"

LICENSE="Custom"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cuda doc debug fpic ismrmrd nolapacke matlab memcfl openmp parallel python srclib"

DEPEND="
	>=app-admin/eselect-1.4.9-r100
	sci-libs/openblas
	nolapacke? ( sci-libs/openblas[lapack] )
	!nolapacke? ( sci-libs/lapack[lapacke] )
	openmp? (
		sys-devel/gcc[fortran,openmp]
		sci-libs/fftw[threads,fortran,openmp]
	)
	!openmp? (
		sys-devel/gcc[fortran]
		sci-libs/fftw[threads,fortran]
	)
	cuda? (
		|| (
			( <dev-util/nvidia-cuda-toolkit-11 <sys-devel/gcc-9 )
			( =dev-util/nvidia-cuda-toolkit-11* =sys-devel/gcc-9* )
		   )
	)
"
RDEPEND="${DEPEND}"

RESTRICT="debug? ( strip )"

MY_DEST="/usr/local/bart"
MY_D="${D}/${MY_DEST}"

src_prepare() {
	einfo "${S}"
	ver=`gcc-major-version`
	einfo "GCC major version: ${ver}"

	eapply "${FILESDIR}/bart-matlab_char16_t.patch"
	eapply "${FILESDIR}/bart-matplotlib-2.2.2.patch"
	eapply "${FILESDIR}/bart-linkopenblas.patch"

	if use debug; then
		eapply "${FILESDIR}/${PN}-debug.patch"
	fi

	if use parallel; then
		eapply "${FILESDIR}/${PN}-parallel.patch"
		eapply "${FILESDIR}/${PN}-nufft_parallel.patch"
		eapply "${FILESDIR}/${PN}-grid_parallel.patch"
	fi

	if use openmp; then
		eapply "${FILESDIR}/${PN}-openmp.patch"
	fi

	if use cuda; then
		einfo
		cuda_gcc=`cuda_gccdir`
		cuda_NVCC_flags=`cuda_gccdir -f`
		einfo "Using CUDA compatible gcc: ${cuda_gcc}"
		
		eapply "${FILESDIR}/${PN}-cuda.patch"

		sed -i \
			-e "s:@@GENTOO_NVCC_FLAGS@@:${cuda_NVCC_flags}:" \
			Makefiles/Makefile.cuda|| die

		cuda_sanitize
	fi

	eapply_user
}

src_install() {
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

	# src and lib directories
	if use srclib ; then
		dodir "${MY_DEST}/src"
		dodir "${MY_DEST}/lib"
	
		cp -R "${S}/src" "${MY_D}/"
		
		insinto "${MY_DEST}/lib"
		doins lib/libbox.a lib/libcalib.a lib/libdfwavelet.a lib/libgrecon.a lib/libiter.a lib/liblinops.a lib/liblowrank.a lib/libmisc.a lib/libmoba.a lib/libnlops.a lib/libnoir.a lib/libnoncart.a lib/libnum.a lib/libsake.a lib/libsense.a lib/libsimu.a lib/libwavelet.a
		#cp "${S}/lib" "${MY_D}/"
	fi

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

	doman "${S}/doc/bart.1"

	dodir "${MY_DEST}/bin"
	exeinto ${MY_DEST}/bin
	doexe bart
}

pkg_postinst() {
	elog
	elog "bart has been installed into: ${MY_DEST}"
	elog "bart binaries are in: ${MY_DEST}/bin.  You might want to add "
	elog "this to your PATH, but be wary of filename collisions."

	if use srclib ; then
		elog
		elog "bart libraries are source code have been installed in: "
		elog "${MY_DEST}/lib and ${MY_DEST}/src respectively."
	fi
}
