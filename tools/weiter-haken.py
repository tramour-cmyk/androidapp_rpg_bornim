#!/usr/bin/env python3
"""Weiter-Haken (Thema 54). Läuft als Stop-Haken über .claude/settings.json und tut bei jedem Fehler still nichts.

Will die Sitzung ihren Zug beenden, hält der Haken sie einmal auf und erinnert: Liegt ein Punkt ohne Entscheidung des
Nutzers in der Übergabe, jetzt weiterarbeiten (seit 13.10. bei jedem Zugende, vorher nur bei Ankündigungen). „Vorrat
leer“ in der Nachricht lässt sofort durch. Wartet sie begründet (Build mit Weckruf, Test des Nutzers, Entscheidung), beendet sie einfach
noch einmal; beim zweiten Mal lässt der Haken sie durch (stop_hook_active), es gibt also nie eine Schleife.
"""
import json
import re
import sys

ANKUENDIGUNG = re.compile(
    r"(als n(ä|ae)chstes|ich (arbeite|mache|fange|baue|zeichne|setze|starte|gehe)\b[^.\n]{0,60}\b(weiter|jetzt|an|dran|los)\b"
    r"|bin (jetzt )?dran|ich melde mich|mache (jetzt|gleich) weiter|weiter mit\b)",
    re.IGNORECASE,
)


VORRAT_LEER = re.compile(r"vorrat leer", re.IGNORECASE)


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


def main():
    try:
        e = json.load(sys.stdin)
        if e.get("stop_hook_active"):
            return
        t = e.get("last_assistant_message") or letzter_text(e["transcript_path"])
        # 54, Nutzer 13.10., 15:2x: „Das darf nicht sein“ (Tom hatte auf Build und Entscheidung gewartet, obwohl
        # Punkte in der eigenen Übergabe lagen). Deshalb hält der Haken jedes Zugende einmal an, nicht nur eine
        # Ankündigung; nur „Vorrat leer“ in der Nachricht (wirklich nichts mehr da) lässt sofort durch.
        if VORRAT_LEER.search(t or ""):
            return
        grund = "Deine letzte Nachricht kündigt Arbeit an. " if ANKUENDIGUNG.search(t or "") else ""
        print(json.dumps({
            "decision": "block",
            "reason": "Weiter-Haken (Thema 54): " + grund + "Bevor du den Zug beendest: Ein Build, ein Test oder eine "
                      "Rückfrage ist kein Grund aufzuhören. Steht in deiner Übergabe oder in „Wer macht was“ ein Punkt, "
                      "der keine Entscheidung des Nutzers braucht (auch: Standbilder eines Entwurfs, Weckruf melden, "
                      "Notizen nachziehen, Vorrat aus SELBST.md)? Dann jetzt damit anfangen, ohne Ankündigung. "
                      "Nur wenn wirklich nichts mehr da ist: in der Nachricht „Vorrat leer“ schreiben und beenden.",
        }))
    except Exception:
        return


main()
