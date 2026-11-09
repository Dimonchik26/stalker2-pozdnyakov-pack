# S.T.A.L.K.E.R. 2 — Pozdnyakov's Pack

Optimization (5 graphics presets + A-Life patch) and 200 kg carry weight for
S.T.A.L.K.E.R. 2: Heart of Chornobyl 2.0.5 / 2.0.6.

Збірка від Pozdnyakova: оптимізація (5 пресетів графіки + патч A-Life) і вага 200 кг.

**This repository is the complete source of the mod. It contains no compiled code.**

## Contents

| Path | What it is |
|---|---|
| `1_Optimization/presets/*/Engine.ini` | 5 graphics presets — Unreal Engine console variables, plain text |
| `1_Optimization/paks/*.pak` | A-Life / physics patch (Normal and Hard), built from `src/paks/` |
| `2_CarryWeight_200kg/paks/z_CarryWeight200_P.pak` | 200 kg carry weight, built from `src/paks/` |
| `*.bat` | Windows batch installers / uninstallers, plain text |
| `README.txt`, `MANUAL_INSTALL.txt`, `*/README*.txt` | user documentation (Ukrainian) |
| `src/paks/` | full contents of every `.pak` — plain-text config patches in GSC's official `{bpatch}` format |
| `src/tools/pak.py` | plain-Python reader/writer for the UE pak format (v3, zlib, no encryption) |
| `src/tools/build_paks.py` | rebuilds all three `.pak` files from `src/paks/` |
| `src/BUILD.md` | build instructions |

## What the .bat installers do

- find the game folder (standard Steam/GOG/Xbox paths, a path you enter, or `game_path.txt`);
- copy `Engine.ini` to `%LOCALAPPDATA%\Stalker2\Saved\Config\Windows` (backup as `Engine.ini.bak`) and set it read-only;
- copy the `.pak` files to `<game>\Stalker2\Content\Paks\~mods\`;
- optionally assign the discrete NVIDIA GPU to the game (Windows graphics preference) and the High performance power plan.

They do not download anything and do not touch game binaries or save files.

## Build

Requirements: Python 3.8+ (standard library only).

```
python src/tools/build_paks.py
```

The three paks are written to `build/` and are byte-identical to the ones in
`1_Optimization/paks/` and `2_CarryWeight_200kg/paks/`.

## Install

Close the game, run `Install_All.bat`, choose a preset (1–5) and the .pak
version. Manual install: see `MANUAL_INSTALL.txt`.

The item spawner is a separate mod (ReShade-UETools ItemSpawner by C3G4) and
is not part of this repository.

## Author

Pozdnyakov
