FROM ruby:3.3.1-alpine3.19 as builder1

ARG NAROU_VERSION=3.9.0

RUN apk add make g++ && \
    gem install narou -v ${NAROU_VERSION} --no-document

FROM ruby:3.3.1-bookworm as builder2

ARG AOZORAEPUB3_VERSION=1.1.1b24Q
ARG AOZORAEPUB3_FILE=AozoraEpub3-${AOZORAEPUB3_VERSION}

RUN wget https://github.com/kyukyunyorituryo/AozoraEpub3/releases/download/v${AOZORAEPUB3_VERSION}/${AOZORAEPUB3_FILE}.zip && \
    unzip ${AOZORAEPUB3_FILE} -d ${AOZORAEPUB3_FILE} && \
    mv ${AOZORAEPUB3_FILE} /opt/aozoraepub3 

FROM alpine:3.19.1 as jre

RUN apk update && \
    apk add openjdk21-jdk libjpeg-turbo && \
    jlink --no-header-files --no-man-pages --compress=2 \
    --add-modules java.base,java.datatransfer,java.desktop \
    --output /opt/jre

FROM ruby:3.3.1-alpine3.19

ARG UID=1000
ARG GID=1000

COPY --from=builder1 /usr/local/bundle /usr/local/bundle
COPY --from=builder2 /opt/aozoraepub3 /opt/aozoraepub3
COPY --from=jre /opt/jre /opt/jre
COPY --from=jre /usr/lib/libjpeg* /usr/lib/
COPY init.sh /usr/local/bin

ENV JAVA_HOME=/opt/jre
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV NAROU_PORT=33000

RUN addgroup -g ${GID} narou && \
    adduser -u ${UID} -G narou -D narou && \
    chmod +x /usr/local/bin/init.sh

USER narou

WORKDIR /home/narou/novel

EXPOSE 33000-33001

ENTRYPOINT ["init.sh"]
CMD ["narou", "web"]
