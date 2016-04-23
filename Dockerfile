# 使用公开源构建，部分依赖库可能需要翻墙，请在本机构建后推送至docker.jesgoo.com
# 版本号：Golang版本号.累进编译号
FROM golang:1.6.2
MAINTAINER jedidiahyang@jesgoo.com

ENTRYPOINT ["go"]

ENV GOPATH="/builtin-dep:/dep:/src" GOOS=linux GOARCH=amd64 CGO_ENABLED=0
RUN mkdir /builtin-dep
VOLUME /dep /src

# 安装官方文本编码库
RUN mkdir -p /builtin-dep/src/golang.org/x
RUN git clone https://github.com/golang/text.git /builtin-dep/src/golang.org/x/text
# 安装MySQL驱动
RUN go get github.com/go-sql-driver/mysql
# 安装Macaron
RUN go get gopkg.in/macaron.v1 github.com/go-macaron/session github.com/go-macaron/cache
# 安装influxdb客户端
RUN go get github.com/influxdata/influxdb/client/v2
# 安装toml解析库
RUN go get github.com/BurntSushi/toml
# 安装proto库
RUN go get github.com/golang/protobuf/proto
