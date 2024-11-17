#!/bin/bash
set -e

# Create directories
mkdir -p "${STEAMAPPDATADIR}/DoNotStarveTogether/MyDediServer"

# Set permissions
chown -R ${PUID}:${PGID} "${STEAMAPPDIR}" "${STEAMAPPDATADIR}" "${SCRIPTSDIR}"

# Start the server
exec gosu steam bash "${SCRIPTSDIR}/entry.sh"