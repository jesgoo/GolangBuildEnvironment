#!/bin/bash
SCRIPT_VERSION=1.0.0

pushd `dirname $0` > /dev/null

IMAGE_TAG=build
CLEAN_OLD_IMAGE=0

function build_bin {
    echo -e "\033[33m编译程序\033[0m"
    if [[ ! -e bin ]]; then
        mkdir bin
    fi
    docker run docker.jesgoo.com/gbe:last -v `pwd`:/src build -o bin/rcv-mergecpm bitbucket.org/chenxing/rcv-mergecpm
    BUILD_CODE=$?
    if [[ $BUILD_CODE -ne 0 ]]; then
        echo -e "\033[31m编译失败: $BUILD_CODE\033[0m"
        exit 1
    fi
    echo -e "\033[32m编译成功\033[0m"
}

function build_image {
    #删除旧镜像
    if [[ $CLEAN_OLD_IMAGE -eq 1 ]]; then
        docker rmi $IMAGE_NAME:$IMAGE_TAG
        echo -e "\033[33m删除镜像$IMAGE_NAME:$IMAGE_TAG\033[0m"
    fi

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
}

function print_usage {
    echo "Usage: `basename $0` [OPTIONS] [all|bin|image]"
    echo "  -t TAG: image tag"
    echo "  -h:     print usage message"
    echo "  -v:     print version"
    echo "  -a APP: app name"
    echo "  -c:     clean old image"
    echo "  -b BIN: bin name"
}

while getopts 'hvt:ca:' OPT; do
    case $OPT in
    h)
        print_usage
        exit 0
        ;;
    v)
        echo "`basename $0` $SCRIPT_VERSION"
        exit 0
        ;;
    t)
        IMAGE_TAG="$OPTARG"
        ;;
    c)
        CLEAN_OLD_IMAGE=1
        ;;
    a)
        APP_NAME="$OPTARG"
        ;;
    b)
        BIN_NAME="$OPTARG"
        ;;
    esac
done

shift $(($OPTIND - 1))

# 校验参数
if [[ -z "$APP_NAME" ]]; then
    echo -e "\033[31m缺少应用名称\033[0m"
fi
if [[ -z "$BIN_NAME" ]]; then
    BIN_NAME=APP_NAME
fi
IMAGE_NAME=docker.jesgoo.com/$APP_NAME:$IMAGE_TAG

if [[ $# -eq 0 ]]; then
    build_bin
    build_image
elif [[ $1 = "bin" ]]; then
    build_bin
elif [[ $1 = "image" ]]; then
    build_image
elif [[ $1 = "all" ]]; then
    build_bin
    build_image
else
    echo "usage: `basename $0` [all|image]"
fi

popd > /dev/null