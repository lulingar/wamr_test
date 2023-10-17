#! /bin/sh

TRIPLET=$(${CC} -dumpmachine)
case ${TRIPLET} in
    x86_64-*)
        WAMR_BUILD_TARGET=X86_64
        ;;
    aarch64-*)
        WAMR_BUILD_TARGET=AARCH64
        ;;
    armv7l-*-*-gnueabihf|armv7-*-*-musleabihf)
        WAMR_BUILD_TARGET=ARMV7
        ;;
    *)
        echo "unknown triplet ${TRIPLET}"
        exit 1
        ;;
esac
echo ${WAMR_BUILD_TARGET}
