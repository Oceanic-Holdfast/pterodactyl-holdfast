FROM steamcmd/steamcmd:ubuntu-24

LABEL author="Lucas Berry" maintainer="lucas@luckinber.com"

# Install runtime dependencies commonly required by Steam/Unity dedicated servers.
RUN apt-get update \
	&& apt full-upgrade -y \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		file \
		iproute2 \
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

ENV CONFIG_DIR="${STEAMAPPDIR}/configs"
ENV ADMIN_DIR="${CONFIG_DIR}/admin"
ENV LOG_DIR="${STEAMAPPDIR}/logs"
ENV WORKSHOP_DIR="${STEAMAPPDIR}/workshop"
RUN mkdir -p "${CONFIG_DIR}" "${ADMIN_DIR}" "${LOG_DIR}" "${WORKSHOP_DIR}"

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
