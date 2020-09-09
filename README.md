# docker-wkhtmltopdf

This repo contains scripts to create docker images which will be available in multiple variants.

The purpose is to publish docker images with a working and patched wkhtmltopdf installation and keep them as small as possible while delivering all functions.

## Naming

The published images follow a naming convention.

### Image name

The image name follows the format:

`surnet/<os>-<base>-wkhtmltopdf` or `surnet/<os/base>-wkhtmltopdf`

- `<os>` matches the underlaying os.
- `<base>` matches the used base image.
- `<os/base>` matches the used base image if the os and base image are the same.

e.g. `surnet/alpine-node-wkhtmltopdf` or `surnet/alpine-wkhtmltopdf`

### Tags

The tags represent version numbers which follow the format:

`<1>-<2>-<3>`

- `<1>` matches the version of the base image.
- `<2>` matches the wkhtmltopdf version.
- `<3>` matches the Edition (see next chapter).

e.g. `3.6-0.12.4-small`

## Editions

There are two editions available for each version.

- `small` contains only wkhtmltopdf. This should be sufficient for most use-cases
- `full` contains wkhtmltopdf, wkhtmltoimage and the libraries.

## Available Images

### surnet/alpine-wkhtmltopdf

[![Docker Stars](https://img.shields.io/docker/stars/surnet/alpine-wkhtmltopdf.svg)](https://hub.docker.com/r/surnet/alpine-wkhtmltopdf/)
[![Docker Pulls](https://img.shields.io/docker/pulls/surnet/alpine-wkhtmltopdf.svg)](https://hub.docker.com/r/surnet/alpine-wkhtmltopdf/)

This image can be used as a base for your project or directly used via bash.

For a list of available versions please click [here](https://hub.docker.com/r/surnet/alpine-wkhtmltopdf/tags/).
If a version you would like is missing please open an issue on this repo.

```yaml
FROM surnet/alpine-wkhtmltopdf:<version>
```

```bash
docker run surnet/alpine-wkhtmltopdf:<version> google.com - > test.pdf
```

### surnet/alpine-node-wkhtmltopdf

[![Docker Stars](https://img.shields.io/docker/stars/surnet/alpine-node-wkhtmltopdf.svg)](https://hub.docker.com/r/surnet/alpine-node-wkhtmltopdf/)
[![Docker Pulls](https://img.shields.io/docker/pulls/surnet/alpine-node-wkhtmltopdf.svg)](https://hub.docker.com/r/surnet/alpine-node-wkhtmltopdf/)

This image can be used as a base for your NodeJS project.

For a list of available versions please click [here](https://hub.docker.com/r/surnet/alpine-node-wkhtmltopdf/tags/).
If a version you would like is missing please open an issue on this repo.

```yaml
FROM surnet/alpine-node-wkhtmltopdf:<version>
```

### surnet/alpine-python-wkhtmltopdf

[![Docker Stars](https://img.shields.io/docker/stars/surnet/alpine-python-wkhtmltopdf.svg)](https://hub.docker.com/r/surnet/alpine-python-wkhtmltopdf/)
[![Docker Pulls](https://img.shields.io/docker/pulls/surnet/alpine-python-wkhtmltopdf.svg)](https://hub.docker.com/r/surnet/alpine-python-wkhtmltopdf/)

This image can be used as a base for your Python project.

For a list of available versions please click [here](https://hub.docker.com/r/surnet/alpine-python-wkhtmltopdf/tags/).
If a version you would like is missing please open an issue on this repo.

```yaml
FROM surnet/alpine-python-wkhtmltopdf:<version>
```

## Other Images

If you are using another image based on alpine you can use the following Dockerfile as a starting point.
Just replace the `openjdk:8-jdk-alpine3.9` with the alpine based image you would like to use.
If you do not need wkhtmltoimage or the libs omit the last two lines.

```Dockerfile
FROM surnet/alpine-wkhtmltopdf:3.9-0.12.5-full as wkhtmltopdf
FROM openjdk:8-jdk-alpine3.9

# Install dependencies for wkhtmltopdf
RUN apk add --no-cache \
  libstdc++ \
  libx11 \
  libxrender \
  libxext \
  libssl1.1 \
  ca-certificates \
  fontconfig \
  freetype \
  ttf-dejavu \
  ttf-droid \
  ttf-freefont \
  ttf-liberation \
  ttf-ubuntu-font-family \
&& apk add --no-cache --virtual .build-deps \
  msttcorefonts-installer \
\
# Install microsoft fonts
&& update-ms-fonts \
&& fc-cache -f \
\
# Clean up when done
&& rm -rf /tmp/* \
&& apk del .build-deps

# Copy wkhtmltopdf files from docker-wkhtmltopdf image
COPY --from=wkhtmltopdf /bin/wkhtmltopdf /bin/wkhtmltopdf
COPY --from=wkhtmltopdf /bin/wkhtmltoimage /bin/wkhtmltoimage
COPY --from=wkhtmltopdf /bin/libwkhtmltox* /bin/
```

## Contribute

Please feel free to open a issue or pull request with suggestions.

Keep in mind that the build process of these container takes some (a lot of) time.

## Credits

Based upon the following repos/inputs:
- https://github.com/nodejs/docker-node
- https://github.com/alloylab/Docker-Alpine-wkhtmltopdf
- https://github.com/wkhtmltopdf/wkhtmltopdf/issues/1794
- https://github.com/aantonw/docker-alpine-wkhtmltopdf-patched-qt
