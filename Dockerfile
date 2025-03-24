FROM debian:bullseye-slim

# Install Whisper
WORKDIR /usr/src
ARG WYOMING_WHISPER_VERSION='2.4.0'

RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  build-essential \
  python3 \
  python3-dev \
  python3-pip \
  \
  && pip3 install --no-cache-dir -U \
  setuptools \
  wheel \
  && pip3 install --no-cache-dir \
  --extra-index-url https://www.piwheels.org/simple \
  "wyoming-faster-whisper @ https://github.com/rhasspy/wyoming-faster-whisper/archive/refs/tags/v${WYOMING_WHISPER_VERSION}.tar.gz" \
  \
  && apt-get purge -y --auto-remove \
  build-essential \
  python3-dev \
  && rm -rf /var/lib/apt/lists/*

# Install cuda dependencies for GPU support
RUN apt-get update && apt-get install -y wget software-properties-common \
  && wget https://developer.download.nvidia.com/compute/cudnn/9.1.0/local_installers/cudnn-local-repo-debian11-9.1.0_1.0-1_amd64.deb \
  && dpkg -i cudnn-local-repo-debian11-9.1.0_1.0-1_amd64.deb \
  && cp /var/cudnn-local-repo-debian11-9.1.0/cudnn-*-keyring.gpg /usr/share/keyrings/ \
  && wget https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/cuda-keyring_1.1-1_all.deb \
  && dpkg -i cuda-keyring_1.1-1_all.deb \
  && add-apt-repository contrib && apt --allow-releaseinfo-change update \
  && apt -y install libcudnn9-cuda-12 libcublas-12-0 \
  && rm cudnn-local-repo-debian11-9.1.0_1.0-1_amd64.deb

WORKDIR /
COPY run.sh ./

EXPOSE 10300

ENTRYPOINT ["bash", "/run.sh"]

