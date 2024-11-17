FROM arm64v8/debian:bullseye-slim

# Environmental variables
ENV DEBIAN_FRONTEND=noninteractive \
    # User config
    PUID=1000 \
    PGID=1000 \
    USER=steam \
    HOMEDIR=/home/steam \
    # Steam config
    STEAMAPPID=343050 \
    STEAMAPPDIR="/home/steam/dst-dedicated" \
    STEAMAPPDATADIR="/home/steam/dst-data" \
    SCRIPTSDIR="/home/steam/scripts" \
    BOX64_LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu" \
    BOX86_LD_LIBRARY_PATH="/usr/lib/i386-linux-gnu:/lib/i386-linux-gnu" \
    # Box86/64 Optimizations
    BOX86_DYNAREC_BIGBLOCK=1 \
    BOX86_DYNAREC_FASTNAN=1 \
    BOX64_DYNAREC_BIGBLOCK=1 \
    BOX64_DYNAREC_FASTNAN=1

# Install all dependencies
RUN dpkg --add-architecture amd64 && \
    dpkg --add-architecture armhf && \
    dpkg --add-architecture i386 && \
    apt-get update -o Acquire::http::Pipeline-Depth=10 \
        -o Acquire::http::Parallel-Queue-Size=10 \
        -o Acquire::Languages=none && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        gpg \
        unzip \
        gosu \
        # Base libraries needed for box64/86
        libglib2.0-0 \
        libatomic1 \
        libc6:amd64 \
        libstdc++6:amd64 \
        lib32gcc-s1:amd64 \
        libc6:armhf \
        lib32stdc++6 \
        libcurl4-gnutls-dev:i386 \
        # Additional libraries needed by DST
        libsdl2-2.0-0:amd64 \
        libcurl4-gnutls-dev:amd64 \
        libssh2-1:amd64 \
        libgcrypt20:amd64 \
        libbrotli1:amd64 \
        libldap-2.4-2:amd64 && \
    # Setup Box86/64
    wget -qO- https://pi-apps-coders.github.io/box64-debs/KEY.gpg | gpg --dearmor -o /usr/share/keyrings/box64-archive-keyring.gpg && \
    echo "Types: deb\nURIs: https://Pi-Apps-Coders.github.io/box64-debs/debian\nSuites: ./\nSigned-By: /usr/share/keyrings/box64-archive-keyring.gpg" | tee /etc/apt/sources.list.d/box64.sources && \
    wget -qO- https://pi-apps-coders.github.io/box86-debs/KEY.gpg | gpg --dearmor -o /usr/share/keyrings/box86-archive-keyring.gpg && \
    echo "Types: deb\nURIs: https://Pi-Apps-Coders.github.io/box86-debs/debian\nSuites: ./\nSigned-By: /usr/share/keyrings/box86-archive-keyring.gpg" | tee /etc/apt/sources.list.d/box86.sources && \
    apt-get update && \
    apt-get install -y box64-generic-arm box86-generic-arm:armhf && \
    # Create lib directory symlinks if needed
    mkdir -p /lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu && \
    # Setup DepotDownloader
    mkdir -p /opt/depotdownloader && \
    wget -q https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_2.7.4/DepotDownloader-linux-arm64.zip && \
    unzip DepotDownloader-linux-arm64.zip -d /opt/depotdownloader && \
    rm DepotDownloader-linux-arm64.zip && \
    # Cleanup
    rm -rf /var/lib/apt/lists/*

# Setup user and directories
RUN groupadd -g ${PGID} steam && \
    useradd -u ${PUID} -g steam -m steam && \
    mkdir -p "${STEAMAPPDIR}" "${SCRIPTSDIR}" && \
    mkdir -p "${STEAMAPPDIR}/.klei/DoNotStarveTogether" && \
    chown -R steam:steam /home/steam "${STEAMAPPDIR}" "${SCRIPTSDIR}" && \
    chmod -R 755 "${STEAMAPPDIR}" "${SCRIPTSDIR}"

COPY ./MyDediServer.zip "${STEAMAPPDIR}/.klei/DoNotStarveTogether/"

COPY --chown=root:root ./scripts/* ${SCRIPTSDIR}/
RUN chmod +x ${SCRIPTSDIR}/*

WORKDIR /home/steam

CMD ["bash", "scripts/setup.sh"]