FROM alpine:3.19.1 as jre

RUN apk update && \
    apk add openjdk21-jdk libjpeg-turbo && \
    jlink --no-header-files --no-man-pages --compress=2 \
    --add-modules java.base,java.datatransfer,java.desktop \
    --output /opt/jre

FROM ruby:3.3.4-bullseye

ARG NAROU_VERSION=3.9.0
ARG AOZORAEPUB3_VERSION=1.1.1b24Q
ARG AOZORAEPUB3_FILE=AozoraEpub3-${AOZORAEPUB3_VERSION}

ARG UID=1000
ARG GID=1000

RUN gem install narou -v ${NAROU_VERSION} --no-document && \
    wget https://github.com/kyukyunyorituryo/AozoraEpub3/releases/download/v${AOZORAEPUB3_VERSION}/${AOZORAEPUB3_FILE}.zip && \
    unzip ${AOZORAEPUB3_FILE} -d ${AOZORAEPUB3_FILE} && \
    mv ${AOZORAEPUB3_FILE} /opt/aozoraepub3 

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
CMD ["narou", "web", "-np", "${NAROU_PORT}"]
