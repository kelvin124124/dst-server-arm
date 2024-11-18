#!/bin/bash
set -e

log() {
    printf '\033[1;36m[%s] %s\033[0m\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

cd "${STEAMAPPDIR}/bin64"

log "Current working directory: $(pwd)"

# Setup params
params="-cluster MyDediServer -persistent_storage_root ${STEAMAPPDIR}/.klei"

# Launch the server
log "Starting DST dedicated server..."
./dontstarve_dedicated_server_nullrenderer_x64 $params

# Keep container running
while true; do sleep 3600; done
