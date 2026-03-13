#!/bin/bash

# SPDX-License-Identifier: MIT

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/eventheocean"
cd "$GAMEDIR"

# Logging
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Create gamedata directory if needed
mkdir -p "$GAMEDIR/gamedata"

# Check for game assets
if [ ! -d "$GAMEDIR/gamedata/assets" ]; then
  echo "Error: Game assets not found."
  echo "Please copy the 'assets' folder and 'manifest' file from your Even the Ocean"
  echo "installation (Windows version from Steam, or the open-source GitHub repo)"
  echo "into $GAMEDIR/gamedata/"
  sleep 5
  pm_finish
  exit 1
fi

# Save directory - bind game saves
mkdir -p "$GAMEDIR/conf/.EvenTheOcean"
bind_directories ~/.config/EvenTheOcean "$GAMEDIR/conf/.EvenTheOcean"

# --- Apply port patches (first run or after update) ---
PATCH_VERSION="1"
if [ ! -f "$GAMEDIR/.patched" ] || [ "$(cat "$GAMEDIR/.patched")" != "$PATCH_VERSION" ]; then
  echo "Applying Even the Ocean port patches (v${PATCH_VERSION})..."

  # Install game binary and runtime (cross-compiled for aarch64)
  for f in EventheOcean regexp.dso std.dso zlib.dso; do
    if [ -f "$GAMEDIR/eventheocean/gamedata/$f" ]; then
      cp "$GAMEDIR/eventheocean/gamedata/$f" "$GAMEDIR/gamedata/$f"
      echo "  - Installed $f"
    fi
  done

  # Install patched lime-legacy.ndll (custom build with handheld fixes)
  if [ -f "$GAMEDIR/eventheocean/lime-legacy.ndll" ]; then
    cp "$GAMEDIR/eventheocean/lime-legacy.ndll" "$GAMEDIR/gamedata/lime-legacy.ndll"
    echo "  - Installed patched lime-legacy.ndll"
  fi

  # Install storyteller_small.png (half-size version for handheld resolution)
  if [ -f "$GAMEDIR/eventheocean/patches/storyteller_small.png" ]; then
    cp "$GAMEDIR/eventheocean/patches/storyteller_small.png" \
       "$GAMEDIR/gamedata/assets/sprites/bg/intro/storyteller_small.png"
    echo "  - Installed storyteller_small.png"
  fi

  # Patch cutscene scripts (add scrollFactor=0 for correct rendering at handheld resolution)
  for script in "$GAMEDIR/eventheocean/patches/cutscene/"*.txt; do
    if [ -f "$script" ]; then
      scriptname=$(basename "$script")
      target="$GAMEDIR/gamedata/assets/script/cutscene/easy/$scriptname"
      if [ -f "$target" ] && [ ! -f "${target}.orig" ]; then
        cp "$target" "${target}.orig"
      fi
      cp "$script" "$target"
      echo "  - Patched cutscene script: $scriptname"
    fi
  done

  echo "$PATCH_VERSION" > "$GAMEDIR/.patched"
  echo "Patches applied successfully."
fi

# --- Set up runtime environment ---

# SDL2 and port libraries
export LD_LIBRARY_PATH="$GAMEDIR/eventheocean/libs.aarch64:$GAMEDIR/gamedata:$LD_LIBRARY_PATH"

# Controller mapping
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

# Force KMSDRM video driver for handheld
export SDL_VIDEODRIVER=kmsdrm

# Ensure game runs at device resolution
export SDL_VIDEO_KMSDRM_MODELINE=""

cd "$GAMEDIR/gamedata"

# Make executable
chmod +x EventheOcean

# Launch with gptokeyb for button-to-key mapping
$GPTOKEYB "EventheOcean" -c "$GAMEDIR/eventheocean.gptk" &
pm_platform_helper "$GAMEDIR/gamedata/EventheOcean"
./EventheOcean 2>> "$GAMEDIR/log.txt"

pm_finish
