#FROM adoptopenjdk/openjdk11:x86_64-alpine-jdk-11.0.4_11 as packager

# ENV JAVA_MINIMAL="/opt/java-minimal"
#
# # build minimal JRE
# RUN jlink \
#     --verbose \
#     --add-modules \
#         java.base,java.sql,java.naming,java.desktop,java.management,java.security.jgss,java.instrument,jdk.crypto.ec \
#     --compress 2 --strip-debug --no-header-files --no-man-pages \
#     --output "$JAVA_MINIMAL"
#
# FROM alpine:latest

# magic to make Java binaries work in Alpine
# https://github.com/AdoptOpenJDK/openjdk-docker/blob/master/11/jdk/alpine/Dockerfile.hotspot.releases.slim#L24-L54
# RUN apk add --no-cache --virtual .build-deps curl binutils \
#     && GLIBC_VER="2.29-r0" \
#     && ALPINE_GLIBC_REPO="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
#     && GCC_LIBS_URL="https://archive.archlinux.org/packages/g/gcc-libs/gcc-libs-9.1.0-2-x86_64.pkg.tar.xz" \
#     && GCC_LIBS_SHA256="91dba90f3c20d32fcf7f1dbe91523653018aa0b8d2230b00f822f6722804cf08" \
#     && ZLIB_URL="https://archive.archlinux.org/packages/z/zlib/zlib-1%3A1.2.11-3-x86_64.pkg.tar.xz" \
#     && ZLIB_SHA256=17aede0b9f8baa789c5aa3f358fbf8c68a5f1228c5e6cba1a5dd34102ef4d4e5 \
#     && curl -LfsS https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
#     && SGERRAND_RSA_SHA256="823b54589c93b02497f1ba4dc622eaef9c813e6b0f0ebbb2f771e32adf9f4ef2" \
#     && echo "${SGERRAND_RSA_SHA256} */etc/apk/keys/sgerrand.rsa.pub" | sha256sum -c - \
#     && curl -LfsS ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-${GLIBC_VER}.apk > /tmp/glibc-${GLIBC_VER}.apk \
#     && apk add /tmp/glibc-${GLIBC_VER}.apk \
#     && curl -LfsS ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk > /tmp/glibc-bin-${GLIBC_VER}.apk \
#     && apk add /tmp/glibc-bin-${GLIBC_VER}.apk \
#     && curl -Ls ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-i18n-${GLIBC_VER}.apk > /tmp/glibc-i18n-${GLIBC_VER}.apk \
#     && apk add /tmp/glibc-i18n-${GLIBC_VER}.apk \
#     && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true \
#     && echo "export LANG=$LANG" > /etc/profile.d/locale.sh \
#     && curl -LfsS ${GCC_LIBS_URL} -o /tmp/gcc-libs.tar.xz \
#     && echo "${GCC_LIBS_SHA256} */tmp/gcc-libs.tar.xz" | sha256sum -c - \
#     && mkdir /tmp/gcc \
#     && tar -xf /tmp/gcc-libs.tar.xz -C /tmp/gcc \
#     && mv /tmp/gcc/usr/lib/libgcc* /tmp/gcc/usr/lib/libstdc++* /usr/glibc-compat/lib \
#     && strip /usr/glibc-compat/lib/libgcc_s.so.* /usr/glibc-compat/lib/libstdc++.so* \
#     && curl -LfsS ${ZLIB_URL} -o /tmp/libz.tar.xz \
#     && echo "${ZLIB_SHA256} */tmp/libz.tar.xz" | sha256sum -c - \
#     && mkdir /tmp/libz \
#     && tar -xf /tmp/libz.tar.xz -C /tmp/libz \
#     && mv /tmp/libz/usr/lib/libz.so* /usr/glibc-compat/lib \
#     && apk del --purge .build-deps glibc-i18n \
#     && rm -rf /tmp/*.apk /tmp/gcc /tmp/gcc-libs.tar.xz /tmp/libz /tmp/libz.tar.xz /var/cache/apk/*

# ENV JAVA_HOME=/opt/java-minimal
# ENV PATH="$PATH:$JAVA_HOME/bin"

# COPY --from=packager "$JAVA_HOME" "$JAVA_HOME"

FROM adoptopenjdk/openjdk11:jre-11.0.14.1_1-alpine
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
# ENV JAVA_OPTS="-Xmx32m -XX:+UseContainerSupport"
ENTRYPOINT ["java","-jar","/app.jar"]
