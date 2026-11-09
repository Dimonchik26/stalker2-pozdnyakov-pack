# Build instructions / source

This mod contains **no compiled code**. Everything is plain text except three
tiny `.pak` containers, and their full contents are in this folder.

| File in the release | What it is | Source |
|---|---|---|
| `1_Optimization/presets/*/Engine.ini` | Unreal Engine console variables (plain text) | the files themselves |
| `*.bat` | Windows batch installers (plain text): find the game folder, copy the files below, set the read-only attribute on Engine.ini, make a backup | the files themselves |
| `1_Optimization/paks/z_Stalker2Optimization.pak` | UE pak v3, 1 file, 234 bytes of text | `src/paks/z_Stalker2Optimization/` |
| `1_Optimization/paks/z_Stalker2OptimizationHard.pak` | UE pak v3, 1 file, 438 bytes of text | `src/paks/z_Stalker2OptimizationHard/` |
| `2_CarryWeight_200kg/paks/z_CarryWeight200_P.pak` | UE pak v3, 3 files of text | `src/paks/z_CarryWeight200_P/` |

The `.cfg_patch` / `_patch_*.cfg` files are S.T.A.L.K.E.R. 2 config patches in
GSC's official `{bpatch}` format: they change only the listed values
(A-Life update delay, physics distance, corpse limits; carry weight limits).

## Rebuilding the paks

Requirements: Python 3.8+ (standard library only).

```
python src/tools/build_paks.py
```

The paks are written to `build/` and are byte-identical to the ones in the
release (zlib level 9, no encryption, mount point
`../../../Stalker2/Content/GameLite/GameData/`).

`src/tools/pak.py` is a small plain-Python reader/writer for the UE pak
format (`python src/tools/pak.py <file.pak> <out_dir>` unpacks a pak).
The paks can also be opened with any standard UE pak tool (e.g. repak).
