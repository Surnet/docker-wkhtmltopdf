#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

# Image
FROM alpine:3.6 as builder

# Environment variables
ENV WKHTMLTOX_VERSION=0.12.5

# Copy patches
RUN mkdir -p /tmp/patches
COPY conf/* /tmp/patches/

# Install needed packages
RUN apk add --no-cache \
  libstdc++ \
  libx11 \
  libxrender \
  libxext \
  libssl1.0 \
  ca-certificates \
  fontconfig \
  freetype \
  ttf-dejavu \
  ttf-droid \
  ttf-freefont \
  ttf-liberation \
  ttf-ubuntu-font-family \
&& apk add --no-cache --virtual .build-deps \
  g++ \
  git \
  gtk+ \
  gtk+-dev \
  make \
  mesa-dev \
  openssl-dev \
  patch \
  fontconfig-dev \
  freetype-dev \
\
# Download source files
&& git clone --recursive https://github.com/wkhtmltopdf/wkhtmltopdf.git /tmp/wkhtmltopdf \
&& cd /tmp/wkhtmltopdf \
&& git checkout tags/$WKHTMLTOX_VERSION \
\
# Apply patches
&& cd /tmp/wkhtmltopdf/qt \
&& patch -p1 -i /tmp/patches/qt-musl.patch \
&& patch -p1 -i /tmp/patches/qt-musl-iconv-no-bom.patch \
&& patch -p1 -i /tmp/patches/qt-recursive-global-mutex.patch \
&& patch -p1 -i /tmp/patches/qt-gcc6.patch \
\
# Modify qmake config
&& sed -i "s|-O2|$CXXFLAGS|" mkspecs/common/g++.conf \
&& sed -i "/^QMAKE_RPATH/s| -Wl,-rpath,||g" mkspecs/common/g++.conf \
&& sed -i "/^QMAKE_LFLAGS\s/s|+=|+= $LDFLAGS|g" mkspecs/common/g++.conf \
\
# Prepare optimal build settings
&& NB_CORES=$(grep -c '^processor' /proc/cpuinfo) \
\
# Install qt
&& ./configure -confirm-license -opensource \
  -prefix /usr \
  -datadir /usr/share/qt \
  -sysconfdir /etc \
  -plugindir /usr/lib/qt/plugins \
  -importdir /usr/lib/qt/imports \
  -silent \
  -release \
  -static \
  -webkit \
  -script \
  -svg \
  -exceptions \
  -xmlpatterns \
  -openssl-linked \
  -no-fast \
  -no-largefile \
  -no-accessibility \
  -no-stl \
  -no-sql-ibase \
  -no-sql-mysql \
  -no-sql-odbc \
  -no-sql-psql \
  -no-sql-sqlite \
  -no-sql-sqlite2 \
  -no-qt3support \
  -no-opengl \
  -no-openvg \
  -no-system-proxies \
  -no-multimedia \
  -no-audio-backend \
  -no-phonon \
  -no-phonon-backend \
  -no-javascript-jit \
  -no-scripttools \
  -no-declarative \
  -no-declarative-debug \
  -no-mmx \
  -no-3dnow \
  -no-sse \
  -no-sse2 \
  -no-sse3 \
  -no-ssse3 \
  -no-sse4.1 \
  -no-sse4.2 \
  -no-avx \
  -no-neon \
  -no-rpath \
  -no-nis \
  -no-cups \
  -no-pch \
  -no-dbus \
  -no-separate-debug-info \
  -no-gtkstyle \
  -no-nas-sound \
  -no-opengl \
  -no-openvg \
  -no-sm \
  -no-xshape \
  -no-xvideo \
  -no-xsync \
  -no-xinerama \
  -no-xcursor \
  -no-xfixes \
  -no-xrandr \
  -no-mitshm \
  -no-xinput \
  -no-xkb \
  -no-glib \
  -no-icu \
  -nomake demos \
  -nomake docs \
  -nomake examples \
  -nomake tools \
  -nomake tests \
  -nomake translations \
  -graphicssystem raster \
  -qt-zlib \
  -qt-libpng \
  -qt-libmng \
  -qt-libtiff \
  -qt-libjpeg \
  -optimized-qmake \
  -iconv \
  -xrender \
  -fontconfig \
  -D ENABLE_VIDEO=0 \
&& make --jobs $(($NB_CORES*2)) --silent \
&& make install \
\
# Install wkhtmltopdf
&& cd /tmp/wkhtmltopdf \
&& qmake \
&& make --jobs $(($NB_CORES*2)) --silent \
&& make install \
&& make clean \
&& make distclean \
\
# Uninstall qt
&& cd /tmp/wkhtmltopdf/qt \
&& make uninstall \
&& make clean \
&& make distclean \
\
# Clean up when done
&& rm -rf /tmp/* \
&& apk del .build-deps

# Image
FROM node:9.11.2-alpine

RUN apk add --no-cache \
  libstdc++ \
  libx11 \
  libxrender \
  libxext \
  libssl1.0 \
  ca-certificates \
  fontconfig \
  freetype \
  ttf-dejavu \
  ttf-droid \
  ttf-freefont \
  ttf-liberation \
  ttf-ubuntu-font-family

COPY --from=builder /bin/wkhtmltopdf /bin/wkhtmltopdf
COPY --from=builder /bin/wkhtmltoimage /bin/wkhtmltoimage
COPY --from=builder /lib/libwkhtmltox* /bin/

