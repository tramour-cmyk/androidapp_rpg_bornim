#!/usr/bin/env python3
"""Chefsache-Haken (63, 65.8; Nutzer 15.10., 16:3x: „nur ständig dafür sorgen, von mir gegebene Anweisungen
nachzukontrollieren“). Läuft als Stop-Haken für alle Rollen und tut bei jedem Fehler still nichts.

Enthält die letzte Antwort eine Frage oder Empfehlung an den Nutzer, hält der Haken den Zug einmal an und nennt die
Nummern: Jede muss auf „Chefsache“ stehen (Datei docs/chefsache/<ordner>/<nr>-….md), bevor der Zug endet. Beim
zweiten Beenden lässt er durch (stop_hook_active), es gibt also nie eine Schleife.

347 (Chef 24.10., 16:30): Stempelprüfung und Zähler im selben Haken, ein gemeinsames Anhalten (Gegenprüfung 347.1 B):
- Steht am Anfang der Antwort ein Stempel „[TT.MM., HH:MM]“ außerhalb von Nachricht des Nutzers minus 1 Minute bis
  Zugende plus 2 Minuten, hält der Haken an. Fehlt der Stempel, hält er nicht an.
- Zähler: je Zugende eine Zeile nach ~/.bornim-regeltreue.tsv (Container; nichts im Chat). Vor Übergabe oder Neustart
  schreibt die Sitzung die Summe nach docs/LISTE-REGELTREUE.md: `python3 tools/zug-haken.py --summe <Rolle> [Sitzung]`.
"""
import datetime
import json
import os
import re
import statistics
import sys
import zoneinfo

BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")
ZAEHLER = os.environ.get("BORNIM_REGELTREUE") or os.path.expanduser("~/.bornim-regeltreue.tsv")
KOPF = "zeit\tsitzung\tkontext_token\twoerter\tentschuldigung\tstempel\tdaneben_min\tangehalten"
STEMPEL = re.compile(r"^\W*(?:\*\*[^*\n]{1,40}\*\*)?\s*\[(\d{1,2})\.(\d{1,2})\.,? (\d{1,2}):(\d{2})\]")
ENTSCHULD = re.compile(r"entschuldig|verzeih|tut mir (so |sehr )?leid|\bsorry\b|mein fehler", re.IGNORECASE)

# Frage an den Nutzer: Satz endet mit „?“ (nicht in Code oder Links); Empfehlung oder Vorschlag in eigenen Worten
FRAGE = re.compile(r"\?\s*(\*\*)?\s*$", re.MULTILINE)
EMPFEHLUNG = re.compile(r"empfehl|empfiehl|vorschlag|schlage .{0,30}vor|würde ich|zu entscheiden", re.IGNORECASE)
# Testbitte (D8.5): auch „Anzusehen“ gehört auf Chefsache
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


def protokoll(pfad):
    """Zeit der letzten Nachricht des Nutzers (keine Werkzeugergebnisse) und Kontextgröße der letzten Antwort."""
    frage, ctx = None, 0
    with open(pfad, encoding="utf-8", errors="replace") as f:
        for zeile in f:
            try:
                d = json.loads(zeile)
            except ValueError:
                continue
            if d.get("isSidechain"):
                continue
            m = d.get("message") or {}
            if d.get("type") == "user" and not d.get("isMeta") and not d.get("isCompactSummary"):
                c = m.get("content")
                if isinstance(c, str) or (isinstance(c, list) and c and not any(isinstance(x, dict) and x.get("type") == "tool_result" for x in c)):
                    try:
                        frage = datetime.datetime.fromisoformat(d["timestamp"].replace("Z", "+00:00")).astimezone(BERLIN)
                    except (KeyError, ValueError):
                        pass
            elif d.get("type") == "assistant" and m.get("usage"):
                u = m["usage"]
                ctx = sum(int(u.get(k) or 0) for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens")) or ctx
    return frage, ctx


def stempel_pruefen(t, frage, jetzt):
    """(gefunden, Minuten daneben) für den Stempel am Anfang der Antwort; daneben 0 = in Ordnung."""
    m = STEMPEL.match(t.lstrip())
    if not m or frage is None:  # ohne Zeit der Nachricht nicht anhalten
        return 0, 0
    tag, mon, h, mi = (int(x) for x in m.groups())
    kandidaten = []
    for jahr in (jetzt.year - 1, jetzt.year, jetzt.year + 1):  # Jahreswechsel
        try:
            kandidaten.append(datetime.datetime(jahr, mon, tag, h, mi, tzinfo=BERLIN))
        except ValueError:
            pass
    if not kandidaten:
        return 1, 9999
    st = min(kandidaten, key=lambda x: abs((x - jetzt).total_seconds()))
    von = frage - datetime.timedelta(minutes=1)
    bis = jetzt + datetime.timedelta(minutes=2)
    if st < von:
        return 1, int((von - st).total_seconds() // 60) + 1
    if st > bis:
        return 1, int((st - bis).total_seconds() // 60) + 1
    return 1, 0


def zaehlen(werte):
    try:
        neu = not os.path.exists(ZAEHLER)
        with open(ZAEHLER, "a", encoding="utf-8") as f:
            if neu:
                f.write(KOPF + "\n")
            f.write("\t".join(str(w) for w in werte) + "\n")
    except OSError:
        pass


def summe(rolle, sitzung=None):
    """Eine Zeile für docs/LISTE-REGELTREUE.md: die genannte Sitzung, sonst die zuletzt gezählte."""
    try:
        zeilen = [z.rstrip("\n").split("\t") for z in open(ZAEHLER, encoding="utf-8")][1:]
    except OSError:
        print("keine Zählung in " + ZAEHLER)
        return
    je = {}
    for z in zeilen:
        if len(z) >= 8:
            je.setdefault(z[1], []).append(z)
    if not je:
        return
    sid = next((k for k in je if sitzung and k.startswith(sitzung)), None) or zeilen[-1][1]
    for sid, zz in [(sid, je[sid])]:
        w = [int(z[3]) for z in zz]
        st = [z for z in zz if z[5] == "1"]
        print("| %s | %s | %s | %d | %d | %d | %d | %d/%d | %d |" % (
            datetime.datetime.now(BERLIN).strftime("%d.%m., %H:%M"), rolle, sid[:12], len(zz), int(statistics.median(w)),
            max(w), sum(int(z[4]) for z in zz), sum(1 for z in st if z[6] != "0"), len(st), max(int(z[2]) for z in zz) // 1000))


def main():
    try:
        e = json.load(sys.stdin)
        if e.get("stop_hook_active"):
            return
        t = e.get("last_assistant_message") or letzter_text(e["transcript_path"])
        gruende = []
        try:
            jetzt = datetime.datetime.now(BERLIN)
            frage, ctx = protokoll(e["transcript_path"]) if e.get("transcript_path") else (None, 0)
            gef, daneben = stempel_pruefen(t or "", frage, jetzt)
            if daneben:
                gruende.append("Stempel-Prüfung (347): Der Stempel am Anfang deiner Antwort liegt %d Minuten neben der Uhr "
                               "(Nachricht %s, jetzt %s). Antwort mit richtigem Stempel wiederholen (Zeit aus `TZ=Europe/Berlin date`, "
                               "nicht schätzen), ohne Hinweis darauf im Chat."
                               % (daneben, frage.strftime("%H:%M") if frage else "?", jetzt.strftime("%H:%M")))
            ohne_code = re.sub(r"```.*?```", " ", t or "", flags=re.S)
            werte = [jetzt.strftime("%Y-%m-%d %H:%M"), str(e.get("session_id", "?"))[:40], ctx, len(ohne_code.split()),
                     1 if ENTSCHULD.search(t or "") else 0, gef, daneben]
        except Exception:
            werte = None
        chef = chefsache(t)
        if chef:
            gruende.append(chef)
        if werte:
            zaehlen(werte + [1 if gruende else 0])
        if gruende:
            print(json.dumps({"decision": "block", "reason": " · ".join(gruende)}))
    except Exception:
        return


def chefsache(t):
    """Grund zum Anhalten, wenn die Antwort eine Frage oder Empfehlung an den Nutzer enthält (63), sonst None."""
    if not t or FREI.search(t):
        return None
    ohne = re.sub(r"`[^`]*`|\]\([^)]*\)|https?://\S+|\[\d{1,2}\.\d{1,2}\.,? ?\d{1,2}:\d{2}\]|\b\d+\.\d+\.\d+\b|\b\d{1,2}\.\d{1,2}\.", "", t)
    # Empfehlung und Testbitte nur, wenn derselbe Satz den Nutzer anspricht (ein „du“ irgendwo reichte nicht)
    saetze = re.split(r"(?<=[.!?:;])\s+|\n+| – ", ohne)
    bitte = any((EMPFEHLUNG.search(z) or TEST.search(z)) and ANSPRACHE.search(z) for z in saetze)
    if not (FRAGE.search(ohne) or bitte):
        return None
    nummern = sorted({n for n in NUMMER.findall(ohne) if re.search(r"[a-zA-Z.]", n)})
    liste = ", ".join(nummern[:12]) or "keine Nummer gefunden"
    return ("Chefsache-Haken (63): Deine Antwort enthält eine Frage oder Empfehlung an den Nutzer (Nummern: "
                  + liste + "). Steht jede davon auf „Chefsache“ (Datei docs/chefsache/entscheiden/ oder ansehen/<nr>-….md) und hat eine "
                  "Zeile mit Nummer im Vorrat (ARBEIT-…)? Gilt auch für Testbitten („Anzusehen“). Fehlt etwas: jetzt eintragen, ohne es im Chat zu erwähnen. Ohne "
                  "Nummer: erst Nummer vergeben. Steht schon alles dort oder ist es keine Frage an den Nutzer: "
                  "einfach erneut beenden.")


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "--summe":
        summe(sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else None)
    else:
        main()
