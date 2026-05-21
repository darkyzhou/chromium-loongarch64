#!/bin/bash
export CC=clang
export CXX=clang++
export LDFLAGS="-Wl,-O1,--sort-common,--as-needed -Wl,-build-id=sha1 -Wl,-z,relro -Wl,-z,now -fPIC -fPIE -fno-lto -Wl,-z,pack-relative-relocs"
export CGO_LDFLAGS="-Wl,-O1,--sort-common,--as-needed -Wl,-build-id=sha1 -Wl,-z,relro -Wl,-z,now -fPIC -fPIE -fno-lto -Wl,-z,pack-relative-relocs"
export CFLAGS="-pipe -Wno-error -fstack-protector-strong --param=ssp-buffer-size=4 -fexceptions -fPIC -fPIC -ggdb -O2 -fno-omit-frame-pointer -fno-lto -mabi=lp64d -mno-strict-align -march=la64v1.0 -mtune=la664"
export CGO_CFLAGS="-pipe -Wno-error -fstack-protector-strong --param=ssp-buffer-size=4 -fexceptions -fPIC -fPIC -ggdb -O2 -fno-omit-frame-pointer -fno-lto -mabi=lp64d -mno-strict-align -march=la64v1.0 -mtune=la664"
export CPPFLAGS="-D_GLIBCXX_ASSERTIONS -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -O2"
export CGO_CPPFLAGS="-D_GLIBCXX_ASSERTIONS -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 -O2"
export CXXFLAGS="-ggdb -fno-permissive -pipe -Wno-error -fstack-protector-strong --param=ssp-buffer-size=4 -fexceptions -fPIC -fPIC -ggdb -O2 -fno-omit-frame-pointer -fno-lto -mabi=lp64d -mno-strict-align -march=la64v1.0 -mtune=la664"
export CGO_CXXFLAGS="-ggdb -fno-permissive -pipe -Wno-error -fstack-protector-strong --param=ssp-buffer-size=4 -fexceptions -fPIC -fPIC -ggdb -O2 -fno-omit-frame-pointer -fno-lto -mabi=lp64d -mno-strict-align -march=la64v1.0 -mtune=la664"
export OBJCFLAGS="-pipe -Wno-error -fstack-protector-strong --param=ssp-buffer-size=4 -fexceptions -fPIC -fPIC -ggdb -O2 -fno-omit-frame-pointer -fno-lto -mabi=lp64d -mno-strict-align -march=la64v1.0 -mtune=la664"
export OBJCXXFLAGS="-fno-permissive -ggdb -fno-permissive -pipe -Wno-error -fstack-protector-strong --param=ssp-buffer-size=4 -fexceptions -fPIC -fPIC -ggdb -O2 -fno-omit-frame-pointer -fno-lto -mabi=lp64d -mno-strict-align -march=la64v1.0 -mtune=la664"
export RUSTFLAGS="-Ccodegen-units=1 -Copt-level=3 -Cdebuginfo=line-tables-only -Cforce-frame-pointers=yes -Cembed-bitcode=yes -Clinker=clang -Clink-arg=-fno-lto -Clink-arg=-fuse-ld=lld -Clink-arg=-Wl,-build-id=sha1 -Clink-arg=-Wl -Ctarget-cpu=generic-la64 -Ctarget-feature=+lsx,+d -Clink-arg=-mabi=lp64d"

export CMAKE_AFTER="
    -DINSTALL_BINDIR=lib/qt6/bin \
    -DINSTALL_DOCDIR=share/doc/qt-6 \
    -DINSTALL_INCLUDEDIR=include/qt6 \
    -DINSTALL_ARCHDATADIR=lib/qt6 \
    -DINSTALL_MKSPECSDIR=lib/qt6/mkspecs \
    -DINSTALL_DATADIR=share/qt6 \
    -DINSTALL_SYSCONFDIR=/etc/xdg \
    -DLLVM_INSTALL_DIR=/usr/lib/llvm-20 \
    -DINSTALL_EXAMPLESDIR=share/doc/qt-6/examples \
    -DBUILD_SHARED_LIB=ON \
    -DCMAKE_SKIP_RPATH=OFF \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
    -DQT_BUILD_TESTS=OFF \
    -DQT_FEATURE_use_gold_linker=OFF \
    -DQT_FEATURE_reduce_relocations=OFF \
    -DQT_FEATURE_system_sqlite=ON \
    -DQT_FEATURE_system_harfbuzz=ON \
    -DQT_FEATURE_system_png=ON \
    -DQT_FEATURE_system_pcre2=ON \
    -DQT_FEATURE_system_jpeg=ON \
    -DQT_FEATURE_system_zlib=ON \
    -DINPUT_dbus=linked \
    -DINPUT_openssl=linked \
    -DQT_FEATURE_sql_psql=ON \
    -DQT_FEATURE_sql_sqlite=ON \
    -DQT_FEATURE_sql_odbc=ON \
    -DQT_FEATURE_accessibility=ON \
    -DQT_FEATURE_fontconfig=ON \
    -DQT_FEATURE_glib=ON \
    -DQT_FEATURE_icu=ON \
    -DQT_FEATURE_journald=ON \
    -DQT_FEATURE_libinput=ON \
    -DQT_FEATURE_libproxy=ON \
    -DQT_FEATURE_vulkan=ON \
    -DQT_FEATURE_qtpdf_build=ON \
    -DQT_FEATURE_webengine_full_debug_info=ON \
    -DQT_FEATURE_webengine_extensions=ON \
    -DQT_FEATURE_webengine_system_ffmpeg=OFF \
    -DQT_FEATURE_webengine_system_libevent=ON \
    -DQT_FEATURE_webengine_system_libxslt=ON \
    -DQT_FEATURE_webengine_proprietary_codecs=ON \
    -DQT_FEATURE_webengine_kerberos=ON \
    -DQT_FEATURE_webengine_webrtc=ON \
    -DQT_FEATURE_webengine_webrtc_pipewire=ON
"
echo "Preparing build environment ..."
export QTDIR=`pwd`
export LD_LIBRARY_PATH="${QTDIR}/qtbase/lib:${QTDIR}/qttools/lib:${LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="${QTDIR}/qtbase/plugins"

# FIXME: Somehow FindPostgreSQL.cmake can't figure out the root path of
# our new PostgreSQL installation.
echo "Finding PostgreSQL ..."
pgroot=$(pg_config --libdir)
if [ ! -d "$pgroot" ] ; then
	echo "Failed to fetch the root path of the PostgreSQL installation."
	exit 1
fi
export PostgreSQL_ROOT=$(realpath "$pgroot"/..)

echo  "Tweaking compiler flags for loongarch64 ..."
export CFLAGS+=" -mcmodel=medium"
export CXXFLAGS+=" -mcmodel=medium"
export LDFLAGS+=" -mcmodel=medium"

mkdir cmake-build
cd cmake-build

echo "Building Qt6 ..."
set -x
cmake .. -G Ninja -DQT_BUILD_EXAMPLES=ON -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DBUILD_qtquick3dphysics=OFF ${CMAKE_AFTER}
set +x

ninja
