#!/bin/bash
set -euo pipefail

cd /home/container

install_game() {
  local attempt=1
  local max_attempts=5

  while [ "$attempt" -le "$max_attempts" ]; do
    echo "[startup] Steam install attempt ${attempt}/${max_attempts}"

    if steamcmd \
      +force_install_dir "${STEAMAPPDIR}" \
      +login anonymous \
      +app_update "${STEAMAPPID}" validate \
      +quit; then
      if [ -x "$STEAMAPPDIR/Holdfast NaW" ]; then
        echo "[startup] Steam app ${STEAMAPPID} installed successfully."
        return 0
      fi
    fi

    attempt=$((attempt + 1))
    if [ "$attempt" -le "$max_attempts" ]; then
      echo "[startup] Steam install not ready yet, retrying..."
    fi
  done

  echo "[startup] ERROR: Steam app ${STEAMAPPID} failed to install after ${max_attempts} attempts."
  return 1
}

install_game

# Create directories and move default config file to config directory
mkdir -p \
  "${CONFIG_DIR}" \
  "${ADMIN_DIR}" \
  "${LOGS_DIR}" \
  "${WORKSHOP_DIR}"
touch \
  "${ADMIN_DIR}/bannedplayers.txt" \
  "${ADMIN_DIR}/bannedmachines.txt" \
  "${ADMIN_DIR}/bannednames.txt" \
  "${ADMIN_DIR}/muteplayersvoip.txt" \
  "${ADMIN_DIR}/micspammers.txt" \
  "${ADMIN_DIR}/muteplayerschat.txt" \
  "${ADMIN_DIR}/serverAdmins.txt"
mv "$STEAMAPPDIR/serverconfig_default.txt" "$CONFIG_DIR/serverconfig_default.txt"
CONFIG_PATH="${CONFIG_PATH:-serverconfig_default.txt}"
# Remove unnecessary files to reduce clutter
rm -rf \
  "${STEAMAPPDIR}/logs_*" \
  "${STEAMAPPDIR}/example_map_rotations" \
  "${STEAMAPPDIR}/serverconfig*" \
  "${STEAMAPPDIR}/LaunchServer.sh"

# Start the server with the specified parameters
"${STEAMAPPDIR}/Holdfast NaW" \
  -startserver \
  -serverheadless \
  -batchmode \
  -nographics \
  -screen-width 640 \
  -screen-height 480 \
  -screen-quality "Fastest" \
  -serverConfigFilePath "$CONFIG_DIR/$CONFIG_PATH" \
  -bannedPlayersFilePath "$ADMIN_DIR/bannedplayers.txt" \
  -bannedMachinesFilePath "$ADMIN_DIR/bannedmachines.txt" \
  -mutedVoipPlayersFilePath "$ADMIN_DIR/muteplayersvoip.txt" \
  -micSpammersPlayersFilePath "$ADMIN_DIR/micspammers.txt" \
  -mutedChatPlayersFilePath "$ADMIN_DIR/muteplayerschat.txt" \
  -serverAdminsFilePath "$ADMIN_DIR/serverAdmins.txt" \
  -logFile "$LOGS_DIR/outputlog.txt" \
  -logArchivesDirectory "$LOGS_DIR/logs_archive/" \
  -adminCommandsLogFilePath "$LOGS_DIR/adminactions.txt" \
  -playersLogFilePath "$LOGS_DIR/playerlogin.txt" \
  -scoreboardLogFilePath "$LOGS_DIR/scorelog.txt" \
  -chatLogFilePath "$LOGS_DIR/chatlog.txt" \
  -vacLogFilePath "$LOGS_DIR/vaclog.txt" \
  -workshopDataPath "$WORKSHOP_DIR"