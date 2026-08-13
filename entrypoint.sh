#!/bin/bash
set -euo pipefail

cd /home/container

# Install the game using SteamCMD with retry logic
install_game() {
  local attempt=1
  local max_attempts=5

  while [ "$attempt" -le "$max_attempts" ]; do
    echo "[Startup] Steam install attempt ${attempt}/${max_attempts}"

    if steamcmd \
      +force_install_dir "${STEAMAPPDIR}" \
      +login anonymous \
      +app_update "${STEAMAPPID}" \
      +quit; then
      if [ -x "$STEAMAPPDIR/Holdfast NaW" ]; then
        echo "[Startup] Steam app ${STEAMAPPID} installed successfully."
        # Create symbolic links for steamclient.so in sdk32 and sdk64 directories
        mkdir -p "${STEAMDIR}/sdk32/" "${STEAMDIR}/sdk64/"
        ln -sfnT "${STEAMAPPDIR}/steamclient.so" "${STEAMDIR}/sdk32/steamclient.so"
        ln -sfnT "${STEAMAPPDIR}/linux64/steamclient.so" "${STEAMDIR}/sdk64/steamclient.so"
        return 0
      fi
    fi

    attempt=$((attempt + 1))
    if [ "$attempt" -le "$max_attempts" ]; then
      echo "[Startup] Steam install not ready yet, retrying..."
    fi
  done

  echo "[Startup] ERROR: Steam app ${STEAMAPPID} failed to install after ${max_attempts} attempts."
  return 1
}

install_game

# Create directories
mkdir -p \
  "${CONFIG_DIR}" \
  "${ADMIN_DIR}" \
  "${LOGS_DIR}" \
  "${WORKSHOP_DIR}"
touch \
  "${ADMIN_DIR}/bannedplayers.txt" \
  "${ADMIN_DIR}/bannedmachines.txt" \
  "${ADMIN_DIR}/mutedplayersvoip.txt" \
  "${ADMIN_DIR}/mutedplayerschat.txt" \
  "${ADMIN_DIR}/micspammers.txt" \
  "${ADMIN_DIR}/serverAdmins.txt" \
  "${ADMIN_DIR}/serverVIPs.txt"

# Set the config path and logs path based on the provided config
LOGS_PATH="${LOGS_DIR}/${CONFIG_NAME%.*}"
CONFIG_PATH="${CONFIG_DIR}/${CONFIG_NAME}"
echo "[Startup] Starting Holdfast: NaW server with the following parameters:"
echo "  - Config file: ${CONFIG_PATH}"
echo "  - Admin config files: ${ADMIN_DIR}"
echo "  - Logs directory: ${LOGS_DIR}"

# Replace ports in the config file and check if the config file exists
if [ -f "${CONFIG_PATH}" ]; then
  sed -i "s/server_port .*/server_port ${GAME_PORT}/" "${CONFIG_PATH}"
  sed -i "s/steam_query_port .*/steam_query_port ${STEAM_QUERY_PORT}/" "${CONFIG_PATH}"
  sed -i "s/maximum_players .*/maximum_players ${MAX_PLAYERS}/" "${CONFIG_PATH}"
else
  echo "[Startup] ERROR: Config file ${CONFIG_PATH} does not exist."
  exit 1
fi

# Start the server with the specified parameters
tail -F "${LOGS_PATH}_outputlog.txt" & exec "${STEAMAPPDIR}/Holdfast NaW" \
  -startserver \
  -serverheadless \
  -batchmode \
  -nographics \
  -screen-width 640 \
  -screen-height 480 \
  -screen-quality "Fastest" \
  -serverConfigFilePath "${CONFIG_PATH}" \
  -bannedPlayersFilePath "${ADMIN_DIR}/bannedplayers.txt" \
  -bannedMachinesFilePath "${ADMIN_DIR}/bannedmachines.txt" \
  -mutedVoipPlayersFilePath "${ADMIN_DIR}/mutedplayersvoip.txt" \
  -mutedChatPlayersFilePath "${ADMIN_DIR}/mutedplayerschat.txt" \
  -micSpammersPlayersFilePath "${ADMIN_DIR}/micspammers.txt" \
  -serverAdminsFilePath "${ADMIN_DIR}/serverAdmins.txt" \
  -vipPlayersFilePath "${ADMIN_DIR}/serverVIPs.txt" \
  -logFile "${LOGS_PATH}_outputlog.txt" \
  -logArchivesDirectory "${LOGS_PATH}_logs_archive/" \
  -adminCommandsLogFilePath "${LOGS_PATH}_adminactions.txt" \
  -playersLogFilePath "${LOGS_PATH}_playerlogin.txt" \
  -scoreboardLogFilePath "${LOGS_PATH}_scorelog.txt" \
  -chatLogFilePath "${LOGS_PATH}_chatlog.txt" \
  -vacLogFilePath "${LOGS_PATH}_vaclog.txt" \
  -workshopDataPath "${WORKSHOP_DIR}"