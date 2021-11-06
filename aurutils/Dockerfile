FROM archlinux:base-devel AS build

RUN pacman --noconfirm -Sy git signify jq pacutils devtools
RUN useradd -m builder
RUN cd /home/builder && su builder -c '/usr/sbin/git clone https://aur.archlinux.org/aurutils.git'
RUN cd /home/builder/aurutils && su builder makepkg

FROM archlinux:base-devel
RUN mkdir /tmp/pkgs
COPY --from=build /home/builder/aurutils/*zst /tmp/pkgs/
RUN pacman --noconfirm -Sy sudo signify rsync openssh
RUN useradd -u 1000 -m builder && mkdir /home/builder/.ssh && chown builder:builder /home/builder/.ssh && chmod 700 /home/builder/.ssh && echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder
RUN pacman --noconfirm -U /tmp/pkgs/*zst
RUN rm -rf /tmp/pkgs && rm -rf /var/lib/pacman/sync/* && rm -rf /var/cache/pacman/pkg/*
COPY vond-aur.conf /tmp/vond-aur.conf
RUN cat /tmp/vond-aur.conf >> /etc/pacman.conf && rm /tmp/vond-aur.conf
USER 1000
WORKDIR /home/builder
