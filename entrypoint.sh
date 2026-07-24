#!/bin/bash
cd /home/container

# Install/Update game using steamcmd
steamcmd \
	+force_install_dir ${STEAMAPPDIR} \
	+login anonymous \
	+app_update ${STEAMAPPID} validate \
	+quit

if [ ! -f "$CONFIG_FILE" ]; then
  cp "$STEAMAPPDIR/serverconfig_default.txt" "$CONFIG_DIR/serverconfig_default.txt"
  CONFIG_FILE="serverconfig_default.txt"
fi

"$STEAMAPPDIR/Holdfast NaW" \
-startserver \
-serverheadless \
-batchmode \
-nographics \
-screen-width 640 \
-screen-height 480 \
-screen-quality "Fastest" \
-serverConfigFilePath "$CONFIG_DIR/$CONFIG_FILE" \
-bannedPlayersFilePath "$ADMIN_DIR/bannedplayers.txt" \
-bannedMachinesFilePath "$ADMIN_DIR/bannedmachines.txt" \
-mutedVoipPlayersFilePath "$ADMIN_DIR/muteplayersvoip.txt" \
-micSpammersPlayersFilePath "$ADMIN_DIR/micspammers.txt" \
-mutedChatPlayersFilePath "$ADMIN_DIR/muteplayerschat.txt" \
-serverAdminsFilePath "$ADMIN_DIR/serverAdmins.txt" \
-logFile "$LOG_DIR/outputlog.txt" \
-logArchivesDirectory "$LOG_DIR/logs_archive/" \
-adminCommandsLogFilePath "$LOG_DIR/adminactions.txt" \
-playersLogFilePath "$LOG_DIR/playerlogin.txt" \
-scoreboardLogFilePath "$LOG_DIR/scorelog.txt" \
-chatLogFilePath "$LOG_DIR/chatlog.txt" \
-vacLogFilePath "$LOG_DIR/vaclog.txt" \
-workshopDataPath "$WORKSHOP_DIR"