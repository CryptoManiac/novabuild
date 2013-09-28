#!/usr/bin/env bash
#

LINK=`readlink -f $0`
if [[ -z ${LINK} ]]; then
LINK=$0
fi
DIRNAME=`dirname ${LINK}`

exit_error() {
    echo $1;
    exit 1;
}

procParmL()
{ 
   [ -z "$1" ] && return 1 
   if [ "${2#$1=}" != "$2" ] ; then 
      cRes="${2#$1=}" 
      return 0 
   fi 
   return 1 
}

while [ 1 ] ; do 
   if procParmL "--threads" "$1" ; then 
      THREADS="$cRes" 
   elif [ -z "$1" ] ; then 
      break
   else 
      exit_error "Error: Invalid key"
   fi 
   shift 
done

if [ "${!THREADS[@]}" ]; then
    JOB_FLAG="-j"
    if [ $THREADS ]; then
        echo "Build using $THREADS threads"
    else
        echo "Build using MAX threads"
    fi
else
    echo "Build using single thread."
fi

RELEASE_VERSION="0.7.4.5"
SOURCE_DESTDIR=${DIRNAME}/dependencies
RELEASE_PUBLISH_DIR=releases
TARGET_PLATFORMS=("i686")
WORKSPACE=${DIRNAME}

for CUR_PLATFORM in ${TARGET_PLATFORMS}; do
    if [ -z ${CUR_PLATFORM} ]; then
        exit_error "NO target platform given."
    fi

    # ensure platform base directory exist:
    platform_src_dir=${SOURCE_DESTDIR}/$CUR_PLATFORM
    [ -d ${platform_src_dir} ] || exit_error "INVALID platform given, or missing platformdir"

    mkdir -p ${WORKSPACE}/release
    
    # quite ugly case...
    case "${CUR_PLATFORM}" in
        i686)
            rm -f ${WORKSPACE}/release-i686/novacoin-qt.exe
            rm -f ${WORKSPACE}/release-i686/novacoind.exe
        
            # qt client:
            echo "Building novacoin qt client..."
            cd ${WORKSPACE} || exit_error "Failed to change to workspace dir"
            make distclean
            make -C novacoin-i686/src -f makefile.unix clean
            make -C novacoin-i686/src -f makefile.linux-mingw clean
            echo "goto ${WORKSPACE}"
            cd ${WORKSPACE}/novacoin-i686 || exit_error "Failed to change to workspace dir"
            PATH=${platform_src_dir}/qt/bin:$PATH ${platform_src_dir}/qt/bin/qmake -makefile -spec unsupported/win32-g++-cross MINIUPNPC_LIB_PATH=${platform_src_dir}/miniupnpc-1.6 MINIUPNPC_INCLUDE_PATH=${platform_src_dir} BDB_LIB_PATH=${platform_src_dir}/db-4.8.30.NC/build_unix BDB_INCLUDE_PATH=${platform_src_dir}/db-4.8.30.NC/build_unix BOOST_LIB_PATH=${platform_src_dir}/boost_1_50_0/stage/lib BOOST_INCLUDE_PATH=${platform_src_dir}/boost_1_50_0 BOOST_LIB_SUFFIX=-mt BOOST_THREAD_LIB_SUFFIX=_win32-mt OPENSSL_LIB_PATH=${platform_src_dir}/openssl-1.0.1c OPENSSL_INCLUDE_PATH=${platform_src_dir}/openssl-1.0.1c/include QRENCODE_LIB_PATH=${platform_src_dir}/qrencode-3.4.2/.libs QRENCODE_INCLUDE_PATH=${platform_src_dir}/qrencode-3.4.2 USE_UPNP=1 USE_QRCODE=1 INCLUDEPATH=${platform_src_dir} DEFINES=BOOST_THREAD_USE_LIB QMAKE_LRELEASE=lrelease USE_BUILD_INFO=1 BITCOIN_NEED_QT_PLUGINS=1 RELEASE=1 USE_LEVELDB=1 || exit_error "qmake failed"
            PATH=${platform_src_dir}/qt/bin:$PATH make $JOB_FLAG $THREADS || exit_error "Make failed"
            cp -f ${WORKSPACE}/novacoin-i686/release/novacoin-qt.exe ${WORKSPACE}/release-i686

            # novacoin headless daemon:
            echo "Building novacoin headless daemon..."
            cd ${WORKSPACE}/novacoin-i686/src/ || exit_error "Failed to change to novacoin src/"
            make distclean
            make -f makefile.unix clean
            make -f makefile.linux-mingw clean
            cd ${WORKSPACE}/novacoin-i686/src/ || exit_error "Failed to change to src/"
            export MINGW_EXTRALIBS_DIR=${platform_src_dir}
            make $JOB_FLAG $THREADS -f makefile.linux-mingw USE_LEVELDB=1 DEPSDIR=${platform_src_dir} || exit_error "make failed"
            i686-w64-mingw32-strip novacoind.exe || exit_error "strip failed"
            [ -f ${WORKSPACE}/novacoin-i686/src/novacoind.exe ] || exit_error "UNABLE to find generated novacoind.exe"
            echo "novacoind compile success."
            cp -f ${WORKSPACE}/novacoin-i686/src/novacoind.exe ${WORKSPACE}/release-i686

        ;;

        x86_64)
            rm -f ${WORKSPACE}/release-x86_64/novacoin-qt.exe
            rm -f ${WORKSPACE}/release-x86_64/novacoind.exe
        
            # qt client:
            echo "Building novacoin qt client..."
            cd ${WORKSPACE} || exit_error "Failed to change to workspace dir"
            make distclean
            make -C novacoin-x86_64/src -f makefile.unix clean
            make -C novacoin-x86_64/src -f makefile.linux-mingw clean
            echo "goto ${WORKSPACE}"
            cd ${WORKSPACE}/novacoin-x86_64 || exit_error "Failed to change to workspace dir"
            PATH=${platform_src_dir}/qt/bin:$PATH ${platform_src_dir}/qt/bin/qmake -makefile -spec unsupported/win32-g++-cross MINIUPNPC_LIB_PATH=${platform_src_dir}/miniupnpc-1.6 MINIUPNPC_INCLUDE_PATH=${platform_src_dir} BDB_LIB_PATH=${platform_src_dir}/db-4.8.30.NC/build_unix BDB_INCLUDE_PATH=${platform_src_dir}/db-4.8.30.NC/build_unix BOOST_LIB_PATH=${platform_src_dir}/boost_1_50_0/stage/lib BOOST_INCLUDE_PATH=${platform_src_dir}/boost_1_50_0 BOOST_LIB_SUFFIX=-mt BOOST_THREAD_LIB_SUFFIX=_win32-mt OPENSSL_LIB_PATH=${platform_src_dir}/openssl-1.0.1c OPENSSL_INCLUDE_PATH=${platform_src_dir}/openssl-1.0.1c/include QRENCODE_LIB_PATH=${platform_src_dir}/qrencode-3.4.2/.libs QRENCODE_INCLUDE_PATH=${platform_src_dir}/qrencode-3.4.2 USE_UPNP=1 USE_QRCODE=1 INCLUDEPATH=${platform_src_dir} DEFINES=BOOST_THREAD_USE_LIB QMAKE_LRELEASE=lrelease USE_BUILD_INFO=1 BITCOIN_NEED_QT_PLUGINS=1 RELEASE=1 || exit_error "qmake failed"
            PATH=${platform_src_dir}/qt/bin:$PATH make $JOB_FLAG $THREADS || exit_error "Make failed"
            cp -f ${WORKSPACE}/novacoin-x86_64/release/novacoin-qt.exe ${WORKSPACE}/release-x86_64

            # novacoin headless daemon:
            echo "Building novacoin headless daemon..."
            cd ${WORKSPACE}/novacoin-x86_64/src/ || exit_error "Failed to change to novacoin src/"
            make distclean
            make -f makefile.unix clean
            make -f makefile.linux-mingw clean
            cd ${WORKSPACE}/novacoin-x86_64/src/ || exit_error "Failed to change to src/"
            export MINGW_EXTRALIBS_DIR=${platform_src_dir}
            make $JOB_FLAG $THREADS -f makefile.linux-mingw DEPSDIR=${platform_src_dir} TARGET_PLATFORM=x86_64 || exit_error "make failed"
            x86_64-w64-mingw32-strip novacoind.exe || exit_error "strip failed"
            [ -f ${WORKSPACE}/novacoin-x86_64/src/novacoind.exe ] || exit_error "UNABLE to find generated novacoind.exe"
            echo "novacoind compile success."
            cp -f ${WORKSPACE}/novacoin-x86_64/src/novacoind.exe ${WORKSPACE}/release-x86_64

        ;;


        *)
            exit_error "Not Yet Implemented"
        ;;
    esac

done