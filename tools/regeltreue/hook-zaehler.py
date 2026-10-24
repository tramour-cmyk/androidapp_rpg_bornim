#!/usr/bin/env python3
"""Stop-Hook, nur Messung: schreibt je Zugende eine Zeile nach .claude/regeltreue.tsv.
Gibt nichts aus (kostet keine Token), blockiert nie, endet immer mit Exit-Code 0.
Ablegen als tools/hook-zaehler.py. Die Datei .claude/regeltreue.tsv in .gitignore eintragen."""
import json, os, re, sys
from datetime import datetime
from zoneinfo import ZoneInfo

PROJEKT = os.environ.get("CLAUDE_PROJECT_DIR", ".")
LOG = os.path.join(PROJEKT, ".claude", "regeltreue.tsv")
KOPF = "zeit\tsitzung\tprompt_nr\tkontext_token\twoerter\tentschuldigung\tstempel\tstempel_abweichung_min"
ENTSCHULD = re.compile(r"entschuldig|verzeih|tut mir (so )?leid|\bleid\b|\bsorry\b|mein fehler", re.I)
STEMPEL = re.compile(r"\[(\d\d)\.(\d\d)\., (\d\d):(\d\d)\]")


def schreibe(zeile):
    os.makedirs(os.path.dirname(LOG), exist_ok=True)
    neu = not os.path.exists(LOG)
    with open(LOG, "a", encoding="utf-8") as f:
        if neu:
            f.write(KOPF + "\n")
        f.write(zeile + "\n")


def letzte_antwort(pfad):
    text, usage = "", {}
    with open(pfad, encoding="utf-8") as f:
        zeilen = f.readlines()
    for roh in reversed(zeilen):
        try:
            e = json.loads(roh)
        except ValueError:
            continue
        if e.get("type") != "assistant":
            continue
        msg = e.get("message", {})
        teile = [b.get("text", "") for b in msg.get("content", []) if isinstance(b, dict) and b.get("type") == "text"]
        if not usage and msg.get("usage"):
            usage = msg["usage"]
        if teile:
            text = "\n".join(teile)
            if msg.get("usage"):
                usage = msg["usage"]
            break
    return text, usage


def main():
    daten = json.load(sys.stdin)
    if daten.get("stop_hook_active"):
        return
    text, usage = letzte_antwort(daten["transcript_path"])
    sid = str(daten.get("session_id", "?"))
    jetzt = datetime.now(ZoneInfo("Europe/Berlin"))
    ohne_code = re.sub(r"```.*?```", " ", text, flags=re.S)
    woerter = len(ohne_code.split())
    entschuldigung = 1 if ENTSCHULD.search(text) else 0
    ctx = sum(int(usage.get(k, 0) or 0) for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))
    stempel, abw = 0, ""
    m = STEMPEL.search(text[:120])
    if m:
        stempel = 1
        try:
            tm, mo, h, mi = (int(x) for x in m.groups())
            gemeldet = jetzt.replace(month=mo, day=tm, hour=h, minute=mi, second=0, microsecond=0)
            abw = str(int(abs((jetzt - gemeldet).total_seconds()) // 60))
        except ValueError:
            abw = "ungueltig"
    try:
        prompt_nr = open("/tmp/bornim-hook-" + sid, encoding="utf-8").read().strip()
    except OSError:
        prompt_nr = ""
    schreibe("\t".join([jetzt.strftime("%Y-%m-%d %H:%M"), sid[:8], prompt_nr, str(ctx), str(woerter),
                        str(entschuldigung), str(stempel), abw]))


try:
    main()
except Exception as fehler:  # Messung darf nie stören
    try:
        schreibe("FEHLER\t" + repr(fehler)[:200])
    except Exception:
        pass
sys.exit(0)
