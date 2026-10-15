#!/usr/bin/env python3
"""Dein-Zug-Haken (63, 65.8; Nutzer 15.10., 16:3x: „nur ständig dafür sorgen, von mir gegebene Anweisungen
nachzukontrollieren“). Läuft als Stop-Haken für alle Rollen und tut bei jedem Fehler still nichts.

Enthält die letzte Antwort eine Frage oder Empfehlung an den Nutzer, hält der Haken den Zug einmal an und nennt die
Nummern: Jede muss auf „Dein Zug“ stehen (Datei e/<nr>.html plus Zeile in der Liste), bevor der Zug endet. Beim
zweiten Beenden lässt er durch (stop_hook_active), es gibt also nie eine Schleife.
"""
import json
import re
import sys

# Frage an den Nutzer: Satz endet mit „?“ (nicht in Code oder Links); Empfehlung oder Vorschlag in eigenen Worten
FRAGE = re.compile(r"\?\s*(\*\*)?\s*$", re.MULTILINE)
EMPFEHLUNG = re.compile(r"empfehl|empfiehl|vorschlag|schlage .{0,30}vor|würde ich|zu entscheiden", re.IGNORECASE)
# Testbitte (D8.5): auch „Anzusehen“ gehört auf Dein Zug
TEST = re.compile(r"\b(ansehen|anschauen|schau|sieh|teste\w*|anhören|hör\w*|ausprobier\w*|probier\w*)\b", re.IGNORECASE)
# Empfehlung und Testbitte zählen nur, wenn sie den Nutzer ansprechen (D8.6: Berichte zitieren Empfehlungen)
ANSPRACHE = re.compile(r"\b(du|dir|dich|dein\w*)\b", re.IGNORECASE)
# Themennummern wie 68n, 72s.1, D3.13, 90a, 7.2
NUMMER = re.compile(r"\b(D?\d{1,3}[a-z]?(?:\.\d{1,2})?[a-z]?)\b")
FREI = re.compile(r"vorrat leer|weiter in .{0,80}: https://", re.IGNORECASE)


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
            teile = [c.get("text", "") for c in (d.get("message") or {}).get("content") or []
                     if isinstance(c, dict) and c.get("type") == "text"]
            if any(t.strip() for t in teile):
                text = "\n".join(teile)
    return text


def main():
    try:
        e = json.load(sys.stdin)
        if e.get("stop_hook_active"):
            return
        t = e.get("last_assistant_message") or letzter_text(e["transcript_path"])
        if not t or FREI.search(t):
            return
        ohne = re.sub(r"`[^`]*`|\]\([^)]*\)|https?://\S+|\[\d{1,2}\.\d{1,2}\.,? ?\d{1,2}:\d{2}\]|\b\d+\.\d+\.\d+\b|\b\d{1,2}\.\d{1,2}\.", "", t)
        # Empfehlung und Testbitte nur, wenn derselbe Satz den Nutzer anspricht (ein „du“ irgendwo reichte nicht)
        saetze = re.split(r"(?<=[.!?:;])\s+|\n+| – ", ohne)
        bitte = any((EMPFEHLUNG.search(z) or TEST.search(z)) and ANSPRACHE.search(z) for z in saetze)
        if not (FRAGE.search(ohne) or bitte):
            return
        nummern = sorted({n for n in NUMMER.findall(ohne) if re.search(r"[a-zA-Z.]", n)})
        liste = ", ".join(nummern[:12]) or "keine Nummer gefunden"
        print(json.dumps({
            "decision": "block",
            "reason": "Dein-Zug-Haken (63): Deine Antwort enthält eine Frage oder Empfehlung an den Nutzer (Nummern: "
                      + liste + "). Steht jede davon auf „Dein Zug“ (e/<nr>.html und Zeile in der Liste) und hat eine "
                      "Zeile mit Nummer im Vorrat (ARBEIT-…)? Gilt auch für Testbitten („Anzusehen“). Fehlt etwas: jetzt eintragen, ohne es im Chat zu erwähnen. Ohne "
                      "Nummer: erst Nummer vergeben. Steht schon alles dort oder ist es keine Frage an den Nutzer: "
                      "einfach erneut beenden.",
        }))
    except Exception:
        return


main()
