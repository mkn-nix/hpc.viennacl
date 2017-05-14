#!/usr/bin/env bash

set -e

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

[ -z "$(which cmake)" ] && echo "cmake is required to build viennacl" && exit 1;
[ -z "$(which mkn)" ]   && echo "mkn is required to build viennacl" && exit 1;

mkdir -p inc lib

GIT_URL="https://github.com/viennacl/viennacl-dev"
GIT_BNC="master"
GIT_OPT="--depth 1"

MKN_REPO="$(mkn -G MKN_REPO)"
MKN_CXXR="-O2 -fPIC"
MKN_CXXR=${CXXFLAGS:-$MKN_CXXR}

VER_BOOST="$(mkn -G org.boost.version)"

THREADS="$(nproc --all)"

rm -rf v
git clone $GIT_OPT $GIT_URL -b $GIT_BNC v --recursive

KLOG=3 mkn clean build -dtSa "${MKN_CXXR[@]}" -p boost

mkdir -p v/build
cd v/build
cmake -DBOOST_INCLUDEDIR=$MKN_REPO/org/boost/$VER_BOOST/b \
   -DBOOST_LIBRARYDIR=$MKN_REPO/org/boost/$VER_BOOST/lib \
   -DCMAKE_INSTALL_PREFIX=$PWD -DCMAKE_BUILD_TYPE=Release ..

set +e
make -j$THREADS
make install
set -e

cd $CWD
if [ ! -f "$CWD/v/build/libviennacl/libviennacl.so" ]; then
	echo "Building viennacl failed, library not found"
	exit 1
fi

rm -rf lib/*
mv $CWD/v/build/libviennacl/libviennacl.so lib
rm -rf inc/*
cp -r v/viennacl inc

echo "Finished successfully"
exit 0
