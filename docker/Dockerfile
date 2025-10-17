FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ARG UID=1000
ARG GID=1000

RUN apt-get update && apt-get install -y \
    software-properties-common \
    make \
    git \
    wget \
    texlive-full && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/jgm/pandoc/releases/download/3.7.0.2/pandoc-3.7.0.2-1-amd64.deb
RUN dpkg -i pandoc-3.7.0.2-1-amd64.deb

RUN groupadd -g ${GID} latex && \
    useradd -m -u ${UID} -g latex latex

# Accept EULA non-interactively and install Microsoft core fonts
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        fontconfig cabextract xfonts-utils debconf-utils; \
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections; \
    apt-get install -y --no-install-recommends ttf-mscorefonts-installer; \
    fc-cache -f; \
    rm -rf /var/lib/apt/lists/* /var/cache/fontconfig/*
