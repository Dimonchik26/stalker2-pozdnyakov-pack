"""
Rebuilds the three .pak files of the mod from the plain-text sources in src/paks.

Usage (Python 3.8+, no third-party packages):
    python src/tools/build_paks.py            -> writes the paks into build/

Each pak is an Unreal Engine pak (version 3, zlib, no encryption) whose only
content is plain-text S.T.A.L.K.E.R. 2 config patches in GSC's official
{bpatch} format, mounted at ../../../Stalker2/Content/GameLite/GameData/.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, HERE)
import pak  # noqa: E402  (plain-Python pak writer/reader, same folder)

MOUNT = "../../../Stalker2/Content/GameLite/GameData/"

# pak name -> files inside it (path relative to src/paks/<pak name>), in pak index order
PAKS = {
    "z_Stalker2Optimization": [
        "CoreVariables.cfg_patch_Stalker2Optimization",
    ],
    "z_Stalker2OptimizationHard": [
        "CoreVariables.cfg_patch_Stalker2OptimizationHard",
    ],
    "z_CarryWeight200_P": [
        "CoreVariables.cfg_patch_CarryWeight200",
        "CoreVariablesCustom.cfg_patch_CarryWeight200",
        "ObjWeightParamsPrototypes/ObjWeightParamsPrototypes_patch_CarryWeight200.cfg",
    ],
}


def main():
    out_dir = os.path.join(ROOT, "build")
    os.makedirs(out_dir, exist_ok=True)
    for name, files in PAKS.items():
        src = os.path.join(ROOT, "src", "paks", name)
        entries = []
        for rel in files:
            with open(os.path.join(src, *rel.split("/")), "rb") as f:
                entries.append((rel, f.read()))
        out = os.path.join(out_dir, name + ".pak")
        pak.pack(entries, MOUNT, out)
        print("built", out)


if __name__ == "__main__":
    main()
