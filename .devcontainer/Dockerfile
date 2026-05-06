FROM cirrusci/flutter:stable

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       git \
       curl \
       unzip \
       xz-utils \
       zip \
       libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

RUN flutter config --enable-web
RUN flutter doctor -v
