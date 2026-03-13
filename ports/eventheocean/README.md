# Even the Ocean

## Thanks

Thanks to [Analgesic Productions](https://twitter.com/han_tani) (Melos Han-Tani & Marina Kittaka) for creating Even the Ocean and releasing the game as [99%-open-source](https://github.com/analgesicproductions/Even-The-Ocean-Open-Source).

## Installation

The game is available on [Steam](https://store.steampowered.com/app/265470/Even_the_Ocean/) (Windows/Mac only). The source code and assets are also available on [GitHub](https://github.com/analgesicproductions/Even-The-Ocean-Open-Source).

Copy the following into `ports/eventheocean/gamedata/`:
- `assets/` folder (art, music, scripts, maps)
- `manifest` file

### From Steam (Windows version)

1. Install Even the Ocean on Steam
2. Right-click > Properties > Local Files > Browse Local Files
3. Copy the `assets` folder and `manifest` file into `ports/eventheocean/gamedata/`

### From the open-source GitHub repo

1. Clone or download https://github.com/analgesicproductions/Even-The-Ocean-Open-Source
2. Copy the `assets` folder and `manifest` file into `ports/eventheocean/gamedata/`

## What the port provides

This port includes a full aarch64 Linux build — no Linux version of the game is required. The port provides:
- Cross-compiled `EventheOcean` game binary and Haxe runtime (`.dso` files) for aarch64
- Custom-compiled `lime-legacy.ndll` (the NME/Lime rendering engine) with:
  - KMSDRM video backend support
  - Software renderer scaled to device display (640x480)
  - Fullscreen and input fixes for handheld devices
- SDL2 shared library built with KMSDRM support
- Patched cutscene scripts to fix camera offset rendering on handheld displays
- A half-size storyteller image for the intro cutscene (optimized for 416x256 internal resolution)
- Button-to-keyboard mapping via gptokeyb

## Controls

| Button | Action |
|--------|--------|
| D-Pad  | Move / Navigate menus |
| A      | Confirm / Jump |
| B      | Cancel / Back |
| X      | Action |
| Y      | Map |
| L1     | Prev |
| R1     | Next |
| Start  | Enter / Pause |
| Select | Escape / Menu |

## Technical Notes

- Internal resolution: 416x256 (half of PC's 832x512), rendered via software renderer
- Display output: SDL_RenderSetScale to device resolution via KMSDRM
- The game uses HaxeFlixel + OpenFL + Lime Legacy (NME) runtime
- The `lime-legacy.ndll` is compiled from the Lime 2.9.0 legacy C++ source with aarch64 cross-compilation
- Game binary cross-compiled on Ubuntu (WSL2) using `aarch64-linux-gnu-g++`

## Known Issues

- Mayor cutscene map panning may not scroll correctly (map markers visible but camera pan disabled)
