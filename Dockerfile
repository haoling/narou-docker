FROM ruby:3.4.1-alpine3.21 as builder1

ARG NAROU_VERSION=3.9.1

RUN apk add make g++ && \
    gem install narou -v ${NAROU_VERSION} --no-document

FROM ruby:3.4.1-bookworm as builder2

ARG AOZORAEPUB3_VERSION=1.1.1b24Q
ARG AOZORAEPUB3_FILE=AozoraEpub3-${AOZORAEPUB3_VERSION}

RUN wget https://github.com/kyukyunyorituryo/AozoraEpub3/releases/download/v${AOZORAEPUB3_VERSION}/${AOZORAEPUB3_FILE}.zip && \
    unzip ${AOZORAEPUB3_FILE} -d ${AOZORAEPUB3_FILE} && \
    mv ${AOZORAEPUB3_FILE} /opt/aozoraepub3 

FROM ruby:3.4.1-bookworm as builder3
RUN apt update && \
    curl -LO https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6%2B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.6_7.tar.gz && \
    mkdir jdk-21 && tar zxf OpenJDK21U-jdk_x64_linux_hotspot_21.0.6_7.tar.gz -C ./jdk-21 --strip-components 1 &&\
    mv jdk-21 /usr/local/jdk-21 && \
    export JAVA_HOME=/usr/local/jdk-21 && \
    export PATH=$PATH:$JAVA_HOME/bin && \
    jlink --no-header-files --no-man-pages --compress=2 --add-modules java.base,java.datatransfer,java.desktop --output /opt/jre

FROM ruby:3.4.1-slim-bookworm

ARG UID=1000
ARG GID=1000

COPY --from=builder1 /usr/local/bundle /usr/local/bundle
COPY --from=builder2 /opt/aozoraepub3 /opt/aozoraepub3
COPY --from=builder3 /lib/x86_64-linux-gnu/libjpeg* /lib/x86_64-linux-gnu/
COPY --from=builder3 /usr/lib/x86_64-linux-gnu/libjpeg* /usr/lib/x86_64-linux-gnu/
COPY --from=builder3 /opt/jre /opt/jre
COPY ncode.syosetu.com.yaml /usr/local/bundle/gems/narou-3.9.1/webnovel/
COPY novel18.syosetu.com.yaml /usr/local/bundle/gems/narou-3.9.1/webnovel/
COPY init.sh /usr/local/bin

ENV JAVA_HOME=/opt/jre
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV NAROU_PORT=33000

RUN groupadd -g ${GID} narou && \
    adduser narou --shell /bin/bash --uid ${UID} --gid ${GID} && \
    chmod +x /usr/local/bin/init.sh

USER narou

WORKDIR /home/narou/novel

EXPOSE 33000-33001

ENTRYPOINT ["init.sh"]
CMD ["narou", "web"]
