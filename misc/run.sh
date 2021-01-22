#!/bin/bash
# Main server runscript

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
export LD_LIBRARY_PATH=".:bin:$LD_LIBRARY_PATH"

export WORKSHOP_COLLECTION=177294269

cd "$HOME/s"

upgrade_addon() {
    pushd "garrysmod/addons/$1"
    git pull
    popd
}

upgrade_addon spaceage
upgrade_addon spacebuild
upgrade_addon sbep
upgrade_addon smartsnap

steamcmd +runscript "$HOME/s/garrysmod/addons/spaceage/misc/install.txt"

"$HOME/s/garrysmod/addons/spaceage/misc/grabaddons.sh"

exec ./srcds_linux -usercon -autoupdate -tickrate 20 -game garrysmod +ip 0.0.0.0 +maxplayers 32 +map sb_gooniverse_v4 +host_workshop_collection "$WORKSHOP_COLLECTION" +gamemode spaceage -disableluarefresh -console
