#!/usr/bin/env python3
"""Macht aus den geladenen Stücken (tools/klang/musik_holen.sh) die OGG-Dateien in app/src/main/assets/music (Thema 28, 28i).

Aufruf: python3 -I tools/klang/musik_bauen.py <Ordner mit den geladenen Dateien> [Arbeitsordner]
- Stereo, 44,1 kHz, Vorbis; Musik ~112 kbit/s (q 3), Klangflächen (grund_*) ~80 kbit/s (q 1).
- Lautheit angeglichen (zwei Durchgänge loudnorm, linear): Musik -18 LUFS, Klangflächen -24 LUFS (liegen unter allem).
- Klangflächen über 3 min auf 3 min gekürzt und nahtlos zur Schleife gemacht (die letzten 4 s gehen in den Anfang über).
"""
import json
import pathlib
import subprocess
import sys

SRC = pathlib.Path(sys.argv[1])
OUT = pathlib.Path(__file__).resolve().parents[2] / "app/src/main/assets/music"
OUT.mkdir(parents=True, exist_ok=True)
TMP = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 else SRC.parent / "musik_tmp"
TMP.mkdir(exist_ok=True)
BED_MAX = 180.0
SEAM = 4.0


def dauer(f):
    r = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(f)], capture_output=True, text=True, check=True)
    return float(r.stdout.strip())


def messen(f, pre, ziel):
    af = (pre + "," if pre else "") + f"loudnorm=I={ziel}:TP=-1.5:LRA=14:print_format=json"
    r = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", str(f), "-af", af, "-f", "null", "-"], capture_output=True, text=True)
    t = r.stderr
    return json.loads(t[t.rindex("{"):t.rindex("}") + 1])


for f in sorted(SRC.iterdir()):
    name = f.stem
    bed = name.startswith("grund_")
    ziel = -24 if bed else -18
    d = dauer(f)
    pre = "aresample=44100,aformat=channel_layouts=stereo"
    quelle = f
    if bed:
        # Schleife: Teil B = [SEAM, lang], sein Ende überblendet mit Teil A = [0, SEAM]
        lang = min(d, BED_MAX + SEAM)
        roh, quelle = TMP / "roh.wav", TMP / f"{name}.wav"
        subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", str(f), "-t", f"{lang:.3f}", "-af", pre, str(roh)], check=True)
        subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", str(roh), "-i", str(roh), "-filter_complex",
                        f"[0:a]atrim={SEAM},asetpts=PTS-STARTPTS[b];[1:a]atrim=0:{SEAM},asetpts=PTS-STARTPTS[a];[b][a]acrossfade=d={SEAM}:c1=tri:c2=tri",
                        str(quelle)], check=True)
    m = messen(quelle, pre, ziel)
    norm = (f"loudnorm=I={ziel}:TP=-1.5:LRA=14:linear=true:measured_I={m['input_i']}:measured_TP={m['input_tp']}"
            f":measured_LRA={m['input_lra']}:measured_thresh={m['input_thresh']}:offset={m['target_offset']},aresample=44100")
    af = (pre + "," if pre else "") + norm
    ziel_datei = OUT / f"{name}.ogg"
    subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", str(quelle), "-af", af,
                    "-map_metadata", "-1", "-c:a", "libvorbis", "-q:a", "1" if bed else "3", str(ziel_datei)], check=True)
    print(f"{name}: {d:.0f} s -> {dauer(ziel_datei):.0f} s, {ziel_datei.stat().st_size // 1024} KB, vorher {m['input_i']} LUFS")
