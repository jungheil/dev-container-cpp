FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C

WORKDIR /workspaces

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
    sed -i 's/#Port 22/Port 10822/' \
    /etc/ssh/sshd_config && \
    mkdir /run/sshd

RUN apt update && apt upgrade && \
    apt install -y --no-install-recommends neovim x11-apps net-tools && \
    apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# RUN mkdir -p /root/.vscode-server/extensions \
#     /root/.vscode-server-insiders/extensions \
#     && chown -R root \
#     /root/.vscode-server \
#     /root/.vscode-server-insiders && \
#     curl -fsSL https://code-server.dev/install.sh | sh && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension ms-vscode.cpptools && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension austin.code-gnu-global && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension twxs.cmake && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension ms-vscode.cmake-tools && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension xaver.clang-format && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension vsciot-vscode.vscode-arduino && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension formulahendry.code-runner && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension ajshort.include-autocomplete && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension streetsidesoftware.code-spell-checker &&\
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension oderwat.indent-rainbow && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension coenraads.bracket-pair-colorizer-2 && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension hookyqr.beautify && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension mhutchie.git-graph && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension eamodio.gitlens && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension wayou.vscode-todo-highlight && \
#     code-server --extensions-dir /root/.vscode-server/extensions --install-extension gruntfuggly.todo-tree &&\
#     rm -rf ~/.local/share/code-server ~/.config/code-server && \
#     rm -rf ~/.local/lib/code-server-* && \
#     rm -rf ~/install

EXPOSE 10822
CMD [ "/root/entrypoint.sh" ]
