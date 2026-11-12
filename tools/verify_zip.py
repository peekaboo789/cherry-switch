#!/usr/bin/env python3
"""Validate a CherryPlayer release zip before it is uploaded."""
import glob
import sys
import zipfile

REQUIRED = {
    "switch/CherryPlayer/CherryPlayer.nro": "NRO0",
    "switch/CherryPlayer/mpv.conf": None,
}


def main() -> int:
    zips = sorted(glob.glob("build/CherryPlayer-*.zip"))
    if len(zips) != 1:
        print(f"expected exactly one release zip, found {zips}")
        return 1

    path = zips[0]
    print(f"checking {path}")
    with zipfile.ZipFile(path) as zf:
        names = zf.namelist()
        for name, magic in REQUIRED.items():
            if name not in names:
                print(f"missing entry: {name}")
                return 1
            data = zf.read(name)
            if magic is not None and not data.startswith(magic.encode()):
                print(f"bad magic for {name}: {data[:4]!r}")
                return 1
            print(f"  {name}: {len(data)} bytes")

        unexpected = [n for n in names if n.startswith("switch/SwitchWave/")]
        if unexpected:
            print(f"upstream app directory leaked into package: {unexpected}")
            return 1

        nro = zipfile.ZipFile(path).read("switch/CherryPlayer/CherryPlayer.nro")
        if len(nro) < 1_000_000:
            print(f"NRO looks too small: {len(nro)} bytes")
            return 1

    print("release zip OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
