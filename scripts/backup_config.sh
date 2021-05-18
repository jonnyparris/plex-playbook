#!/bin/bash -x

# Configure
# https://github.com/andreafabrizi/Dropbox-Uploader

# Currently using 7z version
# 7-Zip [64] 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
# p7zip Version 16.02 (locale=en_CA.UTF-8,Utf16=on,HugeFiles=on,64 bits,ASM,AES-NI)

cd ~/plex
rm -rf duvplex_config && mkdir duvplex_config
rsync -a --exclude="radarr" --exclude="sonarr" ~/plex/config duvplex_config

DIR="$HOME/plex/config/radarr/Backups/scheduled/"
LATEST=$(ls -Art $DIR | tail -n 1)
rsync -a $DIR$LATEST duvplex_config

DIR="$HOME/plex/config/sonarr/Backups/scheduled/"
LATEST=$(ls -Art $DIR | tail -n 1)
rsync -a $DIR$LATEST duvplex_config

PASSWORD_7z="<REPLACED BY ANSIBLE>"

# The options used are:
#      a: Add files to archive
#     -p: Prompt for a password
#     -mx=9: Level of compression (9 being ultra)
#     -mhe: Encrypt file names
#     -t7z: Generate a 7z archive
rm -rf duvplex_config.7z
7z -p$PASSWORD_7z -mx=9 -mhe -t7z a duvplex_config ~/plex/duvplex_config

~/plex/dropbox_uploader.sh upload duvplex_config.7z Backup/duvplex_config.7z
