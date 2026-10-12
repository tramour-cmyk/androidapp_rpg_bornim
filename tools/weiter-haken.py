#!/usr/bin/env python3
"""Weiter-Haken (Thema 54). Läuft als Stop-Haken über .claude/settings.json und tut bei jedem Fehler still nichts.

Will die Sitzung ihren Zug beenden, obwohl ihre letzte Nachricht Arbeit ankündigt („ich arbeite weiter“, „als
Nächstes“, „ich fange an“ …), hält der Haken sie einmal auf und erinnert: Ist nichts vom Nutzer zu entscheiden,
jetzt weiterarbeiten. Wartet sie begründet (Build mit Weckruf, Test des Nutzers, Entscheidung), beendet sie einfach
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
        if not ANKUENDIGUNG.search(t or ""):
            return
        print(json.dumps({
            "decision": "block",
            "reason": "Weiter-Haken (Thema 54): Deine letzte Nachricht kündigt Arbeit an. Ist nichts vom Nutzer zu "
                      "entscheiden, jetzt weiterarbeiten statt den Zug zu beenden (Regel „Nicht warten“ in CLAUDE.md). "
                      "Wartest du begründet (Build mit Weckruf, Test oder Entscheidung des Nutzers), beende einfach noch einmal.",
        }))
    except Exception:
        return


main()
