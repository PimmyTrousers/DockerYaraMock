FROM golang:latest as buildContainer

ARG YARA_SRC_PATH=/tmp/yara

RUN mkdir /app /go/src/dockeryaramock
COPY ./ /go/src/dockeryaramock

WORKDIR /go/src/dockeryaramock

# steps required to install Yara and remove the source files
RUN git clone https://github.com/VirusTotal/yara.git /tmp/yara
WORKDIR ${YARA_SRC_PATH}
RUN \
    apt update && \
    apt install automake libtool make pkg-config flex bison libjansson-dev libmagic-dev libssl-dev -y && \
    ./bootstrap.sh && \
    ./configure --enable-cuckoo --enable-magic --enable-debug --enable-dotnet --enable-macho --enable-dex  && \
    make && \
    make install && \
    rm -rf ${YARA_SRC_PATH}

WORKDIR /go/src/dockeryaramock

RUN \
    go get && \
    # build the app with the correct build parameters
    # CGO_ENABLED, statically links the dependencies, necessary for alpine
    # -a forces all the packages to be built into the binary
    GOOS=linux CGO_ENABLED=1 go build -a -o /app/dockeryaramock .


FROM ubuntu:19.04
EXPOSE 8000

ARG YARA_RULES_DIR=/app/shared/rules
ARG YARA_SRC_PATH=/tmp/yara

RUN \
    mkdir /app /app/shared && \
    apt update && \
    apt install -y ca-certificates git

COPY --from=buildContainer /app /app

# steps required to install Yara and remove the source files
RUN git clone https://github.com/VirusTotal/yara.git /tmp/yara
WORKDIR ${YARA_SRC_PATH}
RUN \
    apt update && \
    apt install automake libtool make pkg-config flex bison libjansson-dev libmagic-dev libssl-dev -y && \
    ./bootstrap.sh && \
    ./configure --enable-cuckoo --enable-magic --enable-debug --enable-dotnet --enable-macho --enable-dex && \
    make && \
    make install && \
    rm -rf ${YARA_SRC_PATH}

RUN ldconfig

RUN git clone https://github.com/Yara-Rules/rules.git ${YARA_RULES_DIR}

# Compile the Yara rules and place in /app/compiled_rules.yarc for deployment use
WORKDIR ${YARA_RULES_DIR}
RUN yarac ./index.yar /app/index.yarc && \
    rm -rf ${YARA_RULES_DIR}

ENTRYPOINT [ "/app/dockeryaramock", "-yaramasterpath", "/app/index.yarc" ]