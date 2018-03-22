# References:
# https://github.com/agustinhenze/zephyr-docker-core/blob/master/Dockerfile
# https://github.com/agustinhenze/zephyr-arm/blob/master/Dockerfile

FROM ubuntu:latest

LABEL maintainer="daniel.samrocha@gmail.com"
LABEL version="0.1"

RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
  apt-utils \
  wget

RUN apt-get install --no-install-recommends -y \
  git \
  ninja-build \
  gperf \
  ccache \
  doxygen \
  dfu-util \
  device-tree-compiler \
  python3-ply \
  python3-pip \
  python3-setuptools \
  python3-wheel \
  xz-utils \
  file \
  make \
  gcc-multilib \
  autoconf \
  automake \
  libtool

# Install CMake 3.10.3
ENV CMAKE_VERSION 3.10.3

RUN mkdir $HOME/cmake \
  && cd $HOME/cmake \
  && wget https://cmake.org/files/v3.10/cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
  && yes | sh cmake-${CMAKE_VERSION}-Linux-x86_64.sh | cat \
  && echo "export PATH=$PWD/cmake-${CMAKE_VERSION}-Linux-x86_64/bin:\$PATH" >> $HOME/.zephyrrc \
  && rm cmake-${CMAKE_VERSION}-Linux-x86_64.sh

RUN cd $HOME \
  && git clone https://github.com/zephyrproject-rtos/zephyr.git \
  && cd zephyr \
  && git checkout tags/v1.11.0 \
  && chmod u+x zephyr-env.sh \
  && pip3 install --user -r $HOME/zephyr/scripts/requirements.txt

ENV ZEPHYR_SDK_VERSION 0.9.2
ENV ZEPHYR_GCC_VARIANT zephyr
ENV ZEPHYR_TOOLCHAIN_VARIANT zephyr
ENV ZEPHYR_SDK_INSTALL_DIR $HOME/zephyr-sdk
ENV PATH $PWD/cmake-${CMAKE_VERSION}-Linux-x86_64/bin:$PATH

RUN cd $HOME \
  && wget https://github.com/zephyrproject-rtos/meta-zephyr-sdk/releases/download/${ZEPHYR_SDK_VERSION}/zephyr-sdk-${ZEPHYR_SDK_VERSION}-setup.run \
  && sh zephyr-sdk-${ZEPHYR_SDK_VERSION}-setup.run --quiet -- -d $HOME/zephyr-sdk \
  && rm zephyr-sdk-${ZEPHYR_SDK_VERSION}-setup.run \
  && echo "export ZEPHYR_GCC_VARIANT=zephyr" >> $HOME/.zephyrrc \
  && echo "export ZEPHYR_TOOLCHAIN_VARIANT=zephyr" >> $HOME/.zephyrrc \
  && echo "export ZEPHYR_SDK_INSTALL_DIR=$HOME/zephyr-sdk" >> $HOME/.zephyrrc

# Nordic setup

RUN mkdir $HOME/nordic \
  && cd $HOME/nordic \
  && wget -O nRF5x-Command-Line-Tools_9_7_2_Linux-x86_64.tar https://www.nordicsemi.com/eng/nordic/download_resource/51386/27/66897008/94917 \
  && tar -xf nRF5x-Command-Line-Tools_9_7_2_Linux-x86_64.tar \
  && rm nRF5x-Command-Line-Tools_9_7_2_Linux-x86_64.tar

COPY --chown=1000:1000 JLink_Linux_V630h_x86_64.deb /root/nordic

RUN dpkg -i $HOME/nordic/JLink_Linux_V630h_x86_64.deb \
  && rm $HOME/nordic/JLink_Linux_V630h_x86_64.deb
