#!/usr/bin/env python3
"""Weiter-Haken (Thema 54). Läuft als Stop-Haken über .claude/settings.json und tut bei jedem Fehler still nichts.

Will die Sitzung ihren Zug beenden, hält der Haken sie einmal auf und erinnert: Liegt ein Punkt ohne Entscheidung des
Nutzers in der Übergabe, jetzt weiterarbeiten (seit 13.10. bei jedem Zugende, vorher nur bei Ankündigungen). „Vorrat
leer“ in der Nachricht lässt sofort durch. Wartet sie begründet (Build mit Weckruf, Test des Nutzers, Entscheidung), beendet sie einfach
noch einmal; beim zweiten Mal lässt der Haken sie durch (stop_hook_active), es gibt also nie eine Schleife.
"""
import json
import os
import re
import sys

ANKUENDIGUNG = re.compile(
    r"(als n(ä|ae)chstes|ich (arbeite|mache|fange|baue|zeichne|setze|starte|gehe)\b[^.\n]{0,60}\b(weiter|jetzt|an|dran|los)\b"
    r"|bin (jetzt )?dran|ich melde mich|mache (jetzt|gleich) weiter|weiter mit\b)",
    re.IGNORECASE,
)


# „an den Nachfolger übergeben“: nach einem Neustart arbeitet die alte Sitzung nicht neben der neuen weiter
VORRAT_LEER = re.compile(r"vorrat leer|an den nachfolger (übergeben|uebergeben)", re.IGNORECASE)


def letzter_text(pfad):
    text = ""
    with open(pfad, encoding="utf-8", errors="replace") as f:
        for zeile in f:
            if '"assistant"' not in zeile:
                continue
            try:
                d = json.loads(zeile)
            except ValueError:
                continue
            if d.get("type") != "assistant" or d.get("isSidechain"):
                continue
            teile = [c.get("text", "") for c in (d.get("message") or {}).get("content") or [] if isinstance(c, dict) and c.get("type") == "text"]
            if any(t.strip() for t in teile):
                text = "\n".join(teile)
    return text


# 54 gilt nur für Tom und Jerry (Nutzer 14.10., 17:3x, 65.9; Ford seit D5.3): Perikles, Homer, Sokrates, Diogenes und Ford starten mit ihrem Namen als
# erster Nachricht (bei Ford-Starts steht er im angehängten Text); dort schweigt der Haken.
ROLLE_OHNE_HAKEN = re.compile(r"\b(sokrates|ford)\b", re.IGNORECASE)
# 195 (Chef 19.10.): „Solange Arbeit da ist, arbeiten.“ Auch Perikles, Homer, Diogenes, Tom, Jerry: ist laut startbar.py eine Zeile startbar, hält der Haken einmal an
ROLLE_STARTBAR = re.compile(r"\b(perikles|homer|diogenes|tom|jerry)\b", re.IGNORECASE)


def startbar_nr(rolle):
    """Nummer der obersten startbaren Zeile der Rolle (Muss, Kür, nach dem Meilenstein) laut startbar.py auf frischem main, sonst None."""
    import subprocess
    wurzel = os.path.join(os.path.dirname(os.environ.get("CLAUDE_PROJECT_DIR", ".")), "bornim-main")
    if not os.path.isdir(wurzel):
        wurzel = os.environ.get("CLAUDE_PROJECT_DIR", ".")
    try:
        subprocess.run(["git", "pull", "-q", "--ff-only", "origin", "main"], cwd=wurzel, capture_output=True, timeout=20)
        o = subprocess.run([sys.executable, os.path.join(wurzel, "tools", "startbar.py")], cwd=wurzel, capture_output=True, text=True, timeout=30).stdout
    except Exception:
        return None
    for z in o.splitlines():
        if z.startswith("  " + rolle + ":"):
            if "PAUSE" in z:
                return None
            for teil in z.split(":", 1)[1].split("|"):
                m = re.match(r"\s*(?:Muss|Kür|nach dem Meilenstein)\s+(\S+)", teil)
                if m and m.group(1) != "–":
                    return m.group(1)
    return None


def erste_nachricht(pfad):
    with open(pfad, encoding="utf-8", errors="replace") as f:
        for zeile in f:
            if '"user"' not in zeile:
                continue
            try:
                d = json.loads(zeile)
            except ValueError:
                continue
            if d.get("type") != "user" or d.get("isSidechain") or d.get("isMeta"):
                continue
            c = (d.get("message") or {}).get("content")
            if isinstance(c, list):
                c = "\n".join(x.get("text", "") for x in c if isinstance(x, dict) and x.get("type") == "text")
            if isinstance(c, str) and c.strip() and not c.lstrip().startswith("<"):
                return c
    return ""


def ist_ford():
    """D5.3: Fords Sitzung erkennt der Haken auch an der Kennung in ARBEIT-BETRIEB.md (98; Ford 15.10., 12:02: der Name
    in der ersten Nachricht reichte nicht). Liest die frische Notizkopie, sonst die eigene."""
    kennung = os.environ.get("CLAUDE_CODE_REMOTE_SESSION_ID", "").split("_", 1)[-1]
    if not kennung:
        return False
    for wurzel in (os.path.join(os.path.dirname(os.environ.get("CLAUDE_PROJECT_DIR", ".")), "bornim-main"),
                   os.environ.get("CLAUDE_PROJECT_DIR", ".")):
        try:
            with open(os.path.join(wurzel, "docs", "ARBEIT-BETRIEB.md"), encoding="utf-8") as f:
                for zeile in f:
                    if "Ford lebt in einer Sitzung" in zeile:
                        return ("session_" + kennung) in zeile.split("Vorgänger")[0]
        except OSError:
            continue
    return False


def main():
    try:
        e = json.load(sys.stdin)
        if e.get("stop_hook_active"):
            return
        erste = erste_nachricht(e["transcript_path"])[:300]
        if ist_ford() or ROLLE_OHNE_HAKEN.search(erste):
            return
        t = e.get("last_assistant_message") or letzter_text(e["transcript_path"])
        # 54, Nutzer 13.10., 15:2x: „Das darf nicht sein“ (Tom hatte auf Build und Entscheidung gewartet, obwohl
        # Punkte in der eigenen Übergabe lagen). Deshalb hält der Haken jedes Zugende einmal an, nicht nur eine
        # Ankündigung; nur „Vorrat leer“ in der Nachricht (wirklich nichts mehr da) lässt sofort durch.
        if VORRAT_LEER.search(t or ""):
            return
        rm = ROLLE_STARTBAR.search(erste)
        nr = startbar_nr(rm.group(1).capitalize()) if rm else None
        if nr:
            print(json.dumps({"decision": "block", "reason": "Weiter-Haken (195): weiter mit %s (startbar laut startbar.py, Muss vor Kür vor „nach dem Meilenstein“). Sofort anfangen, ohne Ankündigung; nur wenn sie wirklich nicht geht, „Vorrat leer“ schreiben und den Grund nennen." % nr}))
            return
        grund = "Deine letzte Nachricht kündigt Arbeit an. " if ANKUENDIGUNG.search(t or "") else ""
        print(json.dumps({
            "decision": "block",
            "reason": "Weiter-Haken (Thema 54): " + grund + "Bevor du den Zug beendest: Ein Build, ein Test oder eine "
                      "Rückfrage ist kein Grund aufzuhören. Steht in deiner Übergabe oder in deinem Vorrat ein Punkt, "
                      "der keine Entscheidung des Nutzers braucht (auch: Standbilder eines Entwurfs, Weckruf melden, "
                      "Notizen nachziehen, nächste Zeile im Vorrat)? Dann jetzt damit anfangen, ohne Ankündigung. "
                      "Nur wenn wirklich nichts mehr da ist: in der Nachricht „Vorrat leer“ schreiben und beenden.",
        }))
    except Exception:
        return


main()
