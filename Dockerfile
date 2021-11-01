FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

COPY rsync.conf /etc
COPY entrypoint.sh /root


RUN apt update && apt upgrade && \
    apt install -y --no-install-recommends \
    tzdata openssh-server rsync curl wget git software-properties-common pkg-config && \
    apt install -y --no-install-recommends \
    build-essential cmake gdb && \
    apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* && \
    chmod +x /root/entrypoint.sh && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' \
    /etc/ssh/sshd_config && \
    mkdir /run/sshd
    
RUN apt update && apt upgrade && \
    apt install -y --no-install-recommends neovim && \
    apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

    
RUN \
    OPENCV_VERSION=4.5.4 && \
    add-apt-repository "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main" && \
    apt update && apt upgrade && \
    apt install -y libgtk2.0-dev libavcodec-dev \
    libavformat-dev libswscale-dev python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev \
    libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev \
    libopenexr-dev libxvidcore-dev libx264-dev libatlas-base-dev gfortran ffmpeg && \
    git clone https://github.com/opencv/opencv.git $HOME/install/opencv --branch ${OPENCV_VERSION} --progress && \
    git clone https://github.com/opencv/opencv_contrib.git $HOME/install/opencv_contrib --branch ${OPENCV_VERSION} --progress && \
    mkdir $HOME/install/opencv/build && \
    cd $HOME/install/opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=Release -D OPENCV_ENABLE_NONFREE=ON -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_EXTRA_MODULES_PATH=$HOME/install/opencv_contrib/modules .. && \
    make -j$(nproc) && make install && \
    echo "/usr/local/opencv4/lib" > /etc/ld.so.conf.d/opencv4.conf && ldconfig && \
    echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opencv4/lib/pkgconfig" >> /etc/bash.bashrc && \
    echo "export PKG_CONFIG_PATH" >> /etc/bash.bashrc && \
    rm -rf $HOME/install/opencv/ $HOME/install/opencv_contrib/ && \
    apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN mkdir -p /root/.vscode-server/extensions \
        /root/.vscode-server-insiders/extensions \
    && chown -R root \
        /root/.vscode-server \
        /root/.vscode-server-insiders
        
RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    code-server --extensions-dir /root/.vscode-server/extensions --install-extension ms-vscode.cpptools-extension-pack && \
    rm -rf ~/.local/share/code-server ~/.config/code-server && \
    rm -rf ~/.local/lib/code-server-*
        
EXPOSE 22
CMD [ "/root/entrypoint.sh" ]
