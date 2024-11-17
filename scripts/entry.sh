#!/bin/bash
set -e

log() {
    printf '\033[1;36m[%s] %s\033[0m\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

# Check directory permissions
for dir in "${STEAMAPPDIR}" "${STEAMAPPDATADIR}"; do
    if [ ! -d "${dir}" ]; then
        log "Creating directory: ${dir}"
        mkdir -p "${dir}"
    fi
    if ! [ -w "${dir}" ]; then
        echo "Error: ${dir} is not writable. Current permissions: $(ls -ld ${dir})" >&2
        while true; do sleep 3600; done
    fi
done

# Download server files if needed
log "Checking DST Dedicated Server files..."
if [ ! -f "${STEAMAPPDIR}/bin64/dontstarve_dedicated_server_nullrenderer_x64" ] || /opt/depotdownloader/DepotDownloader -app ${STEAMAPPID} -dir "${STEAMAPPDIR}" -validate -verify-only 2>&1 | grep -q "Update required"; then
    log "Downloading DST Dedicated Server files..."
    /opt/depotdownloader/DepotDownloader -app ${STEAMAPPID} -dir "${STEAMAPPDIR}" -validate > /dev/null
fi

if [ ! -f "${STEAMAPPDIR}/bin64/dontstarve_dedicated_server_nullrenderer_x64" ]; then
    log "DST server not found. Download may have failed."
    while true; do sleep 3600; done
fi

if [ -f "${STEAMAPPDIR}/.klei/DoNotStarveTogether/MyDediServer.zip" ]; then
    log "Extracting MyDediServer.zip..."
    unzip "${STEAMAPPDIR}/.klei/DoNotStarveTogether/MyDediServer.zip" -d "${STEAMAPPDIR}/.klei/DoNotStarveTogether/" && rm "${STEAMAPPDIR}/.klei/DoNotStarveTogether/MyDediServer.zip"
fi

chmod +x "${STEAMAPPDIR}/bin64/dontstarve_dedicated_server_nullrenderer_x64"

mkdir -p ~/.steam/sdk32/ ~/.steam/sdk64/
ln -sf "${STEAMAPPDIR}/linux32/steamclient.so" ~/.steam/sdk32/steamclient.so
ln -sf "${STEAMAPPDIR}/linux64/steamclient.so" ~/.steam/sdk64/steamclient.so

exec bash "${SCRIPTSDIR}/launch.sh"