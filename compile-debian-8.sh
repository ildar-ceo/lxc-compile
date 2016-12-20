#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPT_PATH=`dirname $SCRIPT`

DIR_SOURCE=${SCRIPT_PATH}/src
DIR_TMP=${SCRIPT_PATH}/tmp
DIR_BUILD=${SCRIPT_PATH}/build
DIR_INSTALL=/opt/lxc

VERSION="2.0.6-2"

echo "Install started"
step="$1"

case "$1" in
    debian)
		aptitude install linux-kernel-headers xz-utils zlib1g-dev make gcc gcc-multilib wget bridge-utils net-tools libvirt-bin libtool automake build-essential autoconf pkg-config docbook2x libapparmor-dev libselinux1-dev libcgmanager-dev libpython3-dev python3-dev libcap-dev lintian
	;;
	
	prepare)
		pushd ${DIR_SOURCE}
		
		./autogen.sh
		./configure --prefix=/usr --sysconfdir=/etc/lxc --localstatedir=/var \
			--enable-python --enable-doc --disable-rpath --disable-lua --disable-selinux  \
			--enable-tests --enable-cgmanager --disable-apparmor --enable-capabilities \
			--with-distro=debian
		
		popd
	;;
	
	compile)
		pushd ${DIR_SOURCE}
		
		mkdir -p ${DIR_TMP}
		make clean && make
		
		popd
	;;
	
	build)
		pushd ${DIR_SOURCE}
		mkdir -p ${DIR_TMP}
		
		make install DESTDIR=${DIR_TMP}
		
		cp -f ${SCRIPT_PATH}/archive/etc/lxc ${DIR_TMP}/etc/lxc/default/lxc
		cp -f ${SCRIPT_PATH}/archive/etc/default.conf ${DIR_TMP}/etc/lxc/lxc/default.conf
		cp -f ${SCRIPT_PATH}/archive/lxc.sh ${DIR_TMP}/usr/bin/lxc
		cp -f ${SCRIPT_PATH}/archive/restart.sh ${DIR_TMP}/usr/bin/restart
		cp -rf ${SCRIPT_PATH}/archive/DEBIAN ${DIR_TMP}
		
		chmod +x ${DIR_TMP}/usr/bin/lxc
		chmod +x ${DIR_TMP}/usr/bin/restart
		
		popd
	;;
		
	makedeb)
		pushd ${SCRIPT_PATH}
		mkdir -p ${DIR_BUILD}
		
		FILE="lxc_${VERSION}_amd64"
		
		rm -f ./build/*.deb
		rm -f ./build/*.rpm

		fakeroot dpkg-deb --build ./tmp ./build/${FILE}.deb
		
		cd build
		#lintian ./${FILE}.deb
		
		popd
	;;
	
*)
	echo "Usage: $0 {debian|prepare|compile|build|makedeb}"
	;;
esac
