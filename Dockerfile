FROM steamcmd/steamcmd:ubuntu

LABEL author="Lucas Berry" maintainer="lucas@luckinber.com"

# Install runtime dependencies commonly required by Steam/Unity dedicated servers.
RUN apt update \
	&& apt full-upgrade -y \
	&& apt install -y --no-install-recommends \
		ca-certificates \
		curl \
		file \
		libc6-i386 \
		lib32gcc-s1 \
		lib32stdc++6 \
		libsdl2-2.0-0 \
		tzdata \
	&& rm -rf /var/lib/apt/lists/*

# Create the Pterodactyl container user and home.
RUN useradd -d /home/container -m container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

ENV STEAMAPPID=1424230
ENV STEAMAPP=holdfastnaw
ENV STEAMAPPDIR="${HOME}/${STEAMAPP}-dedicated"
ENV STEAMDIR="${HOME}/.steam"

ENV CONFIG_DIR="${HOME}/configs"
ENV ADMIN_DIR="${CONFIG_DIR}/admin"
ENV LOGS_DIR="${HOME}/logs"
ENV WORKSHOP_DIR="${STEAMAPPDIR}/workshop"

COPY --chown=container:container --chmod=0755 ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
