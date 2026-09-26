FROM texlive/texlive:latest

ENV DEBIAN_FRONTEND noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -eux; \
    sed -i 's/Components: main/Components: main contrib non-free/g' /etc/apt/sources.list.d/debian.sources; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        make \
        git \
        fontconfig \
        cabextract \
        xfonts-utils \
        debconf-utils \
        imagemagick; \
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections; \
    apt-get install -y --no-install-recommends ttf-mscorefonts-installer; \
    fc-cache -f; \
    rm -rf /var/cache/fontconfig/*
