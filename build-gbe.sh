#!/bin/bash
SCRIPT_VERSION=1.0.0

IMAGE_NAME=docker.jesgoo.com/gbe
IMAGE_TAG=build

pushd `dirname $0` > /dev/null

while getopts 'hvt:r' OPT; do
    case $OPT in
    h)
        echo "Usage: `basename $0` [OPTIONS] [all|bin|image]"
        echo "  -t: image tag"
        echo "  -h: print usage message"
        echo "  -v: print version"
        exit 0
        ;;
    v)
        echo "`basename $0` $SCRIPT_VERSION"
        exit 0
        ;;
    t)
        IMAGE_TAG="$OPTARG"
        ;;
    esac
done

shift $(($OPTIND - 1))

#构造新镜像
echo -e "\033[33m构造镜像$IMAGE_NAME:$IMAGE_TAG\033[0m"
docker build -t $IMAGE_NAME:$IMAGE_TAG .
BUILD_CODE=$?
if [[ $BUILD_CODE -ne 0 ]]; then
    echo -e "\033[31m构造镜像失败: $BUILD_CODE\033[0m"
    exit 1
fi

echo -e "\033[32m构造镜像成功\033[0m"
docker images $IMAGE_NAME:$IMAGE_TAG

popd > /dev/null
