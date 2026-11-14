# Octobus Mincraft — a Minecraft-style homebrew for the Nintendo DS Lite

A 3D block-building game in the spirit of early Minecraft Pocket Edition (Alpha-era), built **from scratch** for real Nintendo DS Lite hardware — no official SDK, no devkitPro/BlocksDS. The ARM9/ARM7 startup code, linker script, `.nds` packer and DLDI stub were all written by hand. Tested on **real hardware** via an R4-style flashcart, not just an emulator.

![Title screen](screenshots/title_screen.png)

> Korean documentation: [README.ko.md](README.ko.md)

## What this is (and isn't)

This is a personal, non-commercial homebrew project. It does not use any Mojang/Microsoft code or official assets — textures are hand/AI-drawn or extracted from a custom texture pack — and it is not affiliated with or endorsed by Mojang or Microsoft in any way. "Minecraft" is a trademark of Mojang Synergies AB; this project is a fan-made, from-scratch reimplementation for a 20-year-old handheld that never got an official port, shared for personal/educational use only. See [LICENSE](LICENSE) for terms.

## Running it

1. Copy `OctobusMincraft.nds` to your flashcart's SD card and launch it like any other `.nds` game.
2. To try it on a PC first, open it in melonDS or DeSmuME (in-game saving usually doesn't work in most emulators — see below).

## Features

- **Infinite, chunk-streamed world** with seed-based terrain generation (forest/plains, desert, ocean biomes), villages (houses, wells, paths, villagers, iron golems), Nether portals + dimension, and End ruins containing a pre-lit End portal.
- **Four game modes**: Survival, Creative (flight, infinite blocks, creative inventory), Hardcore (1.5× damage, world deletes on death), and **Spectator** (no-clip flight, can't interact with anything, invulnerable, not targeted by mobs).
- **Day/night cycle** with hostile mobs (zombies, creepers) at night, water breathing/drowning, fall damage, hunger and regen.
- **Crafting**: planks, sticks, tools (wood/stone/iron/diamond tiers), doors, beds (full 2-block vanilla-accurate placement), glass, sandstone, stone brick.
- **Wiki-accurate fire**: flint & steel, fire spread/burnout rules, flammable blocks, Nether portal lighting (2–21 wide, 3–21 tall frames).
- **Ore generation** is percent-per-chunk: coal 20%, iron 12%, gold 3%, redstone 20% (only below Y = sea level − 12), emerald 5%, diamond 0.4% (spawns 2–4 veins at once when it hits).
- A from-scratch **3D renderer** on the DS's fixed-function GPU: greedy meshing, frustum culling, a polygon budget (1600 quads, ~48-block view distance) tuned to stay inside the DS's hardware limits.
- Mojang-style chunky-bevel UI, a bottom-screen touch look-pad, on-screen FOV slider, and a title screen with a rotating 3D world panorama.
- 5 languages (English, Korean, Chinese, Japanese, and a North Korean joke/easter-egg variant), switchable in Settings.
- SD card saves via a hand-written FAT16/FAT32 driver + DLDI stub (world deltas are RLE-compressed).

## Screenshots

| Mode select | Survival gameplay | Creative inventory |
|---|---|---|
| ![Mode select](screenshots/mode_select.png) | ![Survival](screenshots/gameplay_survival.png) | ![Creative inventory](screenshots/creative_inventory_blocks.png) |

| New items/blocks | Spectator mode |
|---|---|
| ![Items](screenshots/creative_inventory_items.png) | ![Spectator](screenshots/spectator_mode.png) |

## Controls

| Button | Action |
|---|---|
| D-Pad | Move / strafe, auto-step up single blocks |
| Touch drag | Look around |
| L (hold) | Mine block / attack mob |
| R or B | Place block / eat |
| A | Jump (swim up in water) |
| Y | Next hotbar slot |
| X | Inventory |
| SELECT | Crafting |
| START | Pause menu |

## Known limitations

- No furnace yet — ore drops directly as ingots, meat is "cooked" via crafting with 1 coal.
- No chest storage, torches, or redstone wiring. Mobs aren't persisted across saves.
- This is a scoped reimplementation, not a 1:1 port — the DS has ~4MB RAM and a ~2000-polygon realistic budget, so large systems like enchanting, brewing, and most biomes beyond a handful aren't included.
- Speed optimizations (ARM-mode hot paths, DTCM placement, hardware-timer profiling) were deliberately removed in v0.4 because they conflicted with some flashcarts' DLDI SD driver timers; chunk loading may be a little slower than a fully-optimized build as a result.
- Primarily tested in DeSmuME; also confirmed booting on real R4-flashcart hardware.

## Building from source

No SDK required — just a C toolchain and Python.

- **Arm GNU Toolchain** (`arm-none-eabi-gcc`)
- **Python 3** + Pillow (`pip install pillow`)
- Windows: run `build.bat`
- Linux / WSL / macOS: run `make`
- If you edit `lang/strings.txt`, regenerate the font/string tables with `python tools/make_lang.py lang/strings.txt src/arm9 <path to unifont.otf>` (a prebuilt `src/arm9/lang.c` is checked in, so you only need this if you change the text).

## Project layout

- `src/arm9/` — the game itself (ARM9, the DS's main CPU)
  - `world.c` — chunk streaming, modified-chunk storage, greedy meshing
  - `gen.c` — seed-based terrain/structure generation (Overworld/Nether/End, villages, ruins, ores)
  - `render.c` — DS 3D rendering: frustum culling, polygon budget, fog
  - `entity.c` — mob AI and box models
  - `ui.c`, `gfx2d.c` — HUD and bottom-screen UI, text rendering
  - `save.c`, `fat.c`, `dldi.s` — save system (hand-written FAT16/32 driver + DLDI stub)
  - `fire.c` — fire spread/burnout/damage
- `src/arm7/` — the DS's co-processor (ARM7): reads touch screen + X/Y buttons for ARM9
- `tools/mknds.py` — `.nds` ROM header/icon packer (replaces `ndstool`)
- `tools/make_assets.py` — converts `gfx/*.bmp` into C texture/item/block tables

## Changing textures

Everything under `gfx/` is a plain BMP. Edit with any image editor and rebuild — **magenta (255, 0, 255) is the transparency key**. Hotbar/hand icons are generated automatically from block textures at runtime (isometric cube), so you don't need separate icon art.

## License

Licensed under **CC BY-NC-SA 4.0** — see [LICENSE](LICENSE) for the full text. In short: you're free to use, copy, and modify this project (including for your own DS homebrew), but:

- **No commercial use / resale** — you can't sell this, a renamed copy of it, or a derivative of it.
- **Attribution required** — you can't claim this project (or a relabeled copy of it) as your own original work; credit the original author.
- **Share-alike** — if you redistribute a modified version, it must carry the same license.
