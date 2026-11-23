#!/usr/bin/env python3
"""Neustart-Haken (Thema 14). Läuft über .claude/settings.json und tut bei jedem Fehler still nichts.

  neustart-haken.py prompt   bei jeder Nachricht des Nutzers (UserPromptSubmit): misst, wie stark das Gespräch
                             seit dem Start gewachsen ist, und erinnert ab der Schwelle an einen Neustart,
                             erst selten, dann immer öfter, je länger der Nutzer weiterarbeitet.
  neustart-haken.py vor|nach an jedem Werkzeugaufruf (PreToolUse/PostToolUse, 1537): Erinnerung und Sperre je Rolle (SCHWELLEN, 1520; sonst 200/300 Tsd.)
                             außer Übergabe, Push, Nachricht an Ford (Kaufrepo +200 Tsd., 818; Sokrates 400/500 Tsd., 1643; nie im Test des Chefs; nie bei Ford, 1574).
                             1762: ruft chefwort.haken() (Haken D, Chefwort aus fremder Sitzung).
  neustart-haken.py abgelehnt  (1999) PermissionDenied/PostToolUseFailure: abgelehntes create_trigger/create_session → Lehrenbuch;
                             „nach“ und „vor“ prüfen es ebenso
  neustart-haken.py start    beim Sitzungsstart (SessionStart): warnt, wenn ein Vorrat docs/ARBEIT-*.md zu groß ist.

Die Größe kommt aus dem Gesprächsprotokoll (transcript_path): Token der letzten Antwort (Eingabe, auch
zwischengespeichert). Seit 383 A zählt die ganze Gesprächslänge (jeder Aufruf liest sie ganz), nicht mehr der Zuwachs.

Schwellen über Umgebungsvariablen änderbar: BORNIM_NEUSTART_AB (Gesprächslänge in Token, Vorgabe 200000; 383 A, Chef 09.11.; vorher 300000 Zuwachs nach 383.1),
BORNIM_OFFEN_MAX (Bytes, Vorgabe 30000 wie CLAUDE.md „Vorräte klein halten“, 1641). Zustand je Sitzung in /tmp/bornim-neustart-<Sitzung>.json.
Bei der 1., 11., 21. … Nachricht zusätzlich die Kernregel-Zeile aus tools/kernregeln.txt (347, ein Wortlaut, auch notiz.sh).
"""
import json
import os
import sys

KERN_ALLE = 10
AB = int(os.environ.get("BORNIM_NEUSTART_AB", "200000"))
OFFEN_MAX = int(os.environ.get("BORNIM_OFFEN_MAX", "30000"))   # 1641: wie CLAUDE.md (vorher 15000)
# 818 (Chef 09.11., 22:27: „Oder ihr lasst halt jetzt die Sitzungen dann doch länger offen, wenn die Gefahr besteht, dass es wieder ein Repo-Problem gibt“):
# liegt das Kaufrepo in der Sitzung, gilt die doppelte Schwelle (400 Tsd., wie vor 383 A) und die Sitzung nimmt den nächsten eigenen Vorgang selbst.
KAUF = "/home/user/bornim-kaufmodelle"
# Abstände in Nachrichten zwischen zwei Erinnerungen: erst 6, dann 4, 3, 2, danach bei jeder Nachricht.
ABSTAENDE = [6, 4, 3, 2, 1]


def groessen(pfad):
    """Kontextgröße jeder Antwort im Protokoll, in Reihenfolge (nur die Hauptsitzung, keine Unteragenten)."""
    werte = []
    with open(pfad, encoding="utf-8", errors="replace") as f:
        for zeile in f:
            if '"usage"' not in zeile:
                continue
            try:
                d = json.loads(zeile)
            except ValueError:
                continue
            if d.get("type") != "assistant" or d.get("isSidechain"):
                continue
            u = (d.get("message") or {}).get("usage") or {}
            t = sum(int(u.get(k) or 0) for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))
            if t > 0:
                werte.append(t)
    return werte


def zuwachs(werte):
    """Zuwachs der letzten Antwort gegenüber dem Start bzw. dem letzten Verdichten."""
    if not werte:
        return 0, 0
    basis = werte[0]
    for vorher, jetzt in zip(werte, werte[1:]):
        if jetzt < vorher * 0.7:  # verdichtet: neuer Start
            basis = jetzt
    return werte[-1] - basis, werte[-1]


def text(stufe, plus, gesamt, ab=AB, ford=False):
    k = lambda n: f"{round(n / 1000)} Tsd."
    kopf = f"Neustart-Haken (Thema 14): Das Gespräch ist {k(gesamt)} Token lang (Schwelle {k(ab)}, je Rolle 1520; seit dem Start +{k(plus)}); Erinnerung Nr. {stufe}."
    # 81r: der Anlass entscheidet, nicht ein Ja des Nutzers; kein Vorschlag im Chat (D8.2: der löste den Chefsache-Haken aus)
    if stufe == 1:
        rest = "An der nächsten Bruchstelle (Thema fertig, Build ausgeliefert): zuerst `python3 tools/regelcheck.py --kurz` und die Funde im eigenen Vorrat beheben, dann Übergabe mit „Nachfolger: <Titel>“ pushen, send_message an Ford „Neustart <Name>, <Commit>“ (81r, LISTE-RELEASE-NEUSTART.md „Neustart“). Im Chat nichts dazu."
    else:
        rest = "Zweite Erinnerung: jetzt den Schritt beenden, Übergabe pushen, Neustart über Ford (81r); im Chat danach genau „Weiter in <Titel>: <Link>“."
    return kopf + " " + rest


ROLLEN = r"(Perikles|Homer|Sokrates|Diogenes|Ford|Tom|Jerry|Spike|Tuffy)( \d)?"


def ist_ford():
    """1574: diese Sitzung ist der aktuelle Ford laut ARBEIT-BETRIEB.md („Ford (aktuell)“), auch wenn die erste Nachricht nicht mit „Ford“ beginnt
    (Handstart des Chefs 17.11., 18:24: Haken erkannte ihn nicht)."""
    import re
    kennung = os.environ.get("CLAUDE_CODE_REMOTE_SESSION_ID", "").split("_", 1)[-1]
    if not kennung:
        return False
    for d in ("/home/user/bornim-main", os.environ.get("CLAUDE_PROJECT_DIR") or "."):
        try:
            m = re.search(r"\*\*Ford \(aktuell\)\*\* `session_(\w+)`", open(os.path.join(d, "docs", "ARBEIT-BETRIEB.md"), encoding="utf-8").read())
        except OSError:
            continue
        if m:
            return m.group(1) == kennung
    return False


def name(pfad, sitzung):
    """462: Rolle aus der ersten Nachricht („Wer man ist, sagt die erste Nachricht“), je Sitzung zwischengespeichert."""
    import re
    zpfad = f"/tmp/bornim-name-{sitzung}"
    try:
        return open(zpfad).read().strip()
    except OSError:
        pass
    if not pfad or not os.path.exists(pfad):
        return ""
    gefunden = ""
    with open(pfad, encoding="utf-8", errors="replace") as f:
        for i, zeile in enumerate(f):
            if i > 50:
                break
            try:
                d = json.loads(zeile)
            except ValueError:
                continue
            inhalt = d.get("content") if d.get("type") == "queue-operation" else (d.get("message") or {}).get("content") if d.get("type") == "user" else None
            if isinstance(inhalt, list):
                inhalt = " ".join(t.get("text", "") for t in inhalt if isinstance(t, dict))
            if not isinstance(inhalt, str) or not inhalt.strip():
                continue
            m = re.match(r"\W*" + ROLLEN + r"\b", inhalt.strip())
            # 1683: Startnachricht mit Kern beginnt mit „## Kern … Du bist **Spike**“, nicht mit dem Namen (Haken grüßten mit „Tom“)
            m = m or re.search(r"Du bist \*\*" + ROLLEN + r"\*\*", inhalt[:2000])
            m = m or re.search(r"^Dein Rufname: \w+ \(Rolle " + ROLLEN + r"\b", inhalt.strip())  # 1739 (lauf.mit_rufnamen)
            gefunden = (m.group(1) + (m.group(2) or "")) if m else ""
            break
    if gefunden:
        with open(zpfad, "w") as f:
            f.write(gefunden)
    return gefunden


def pruefliste(pfad, eingabe):
    """812 (Chef 09.11., 21:23: „mitten im Testen mir eine neue Sitzung aufmachen, macht halt auch keinen Sinn“):
    Build N, wenn eine Prüfliste chefsache/ansehen/tN-….md offen ist und die jetzige oder eine der letzten
    fünf Nachrichten des Nutzers N nennt („273“, „t273“, „273.4“); sonst None."""
    import glob, re
    nummern = set()
    for d in ("/home/user/bornim-main", os.environ.get("CLAUDE_PROJECT_DIR") or "."):
        for f in glob.glob(os.path.join(d, "docs/chefsache/ansehen/t*-*.md")):
            m = re.match(r"t(\d+)-", os.path.basename(f))
            if m:
                nummern.add(m.group(1))
    if not nummern:
        return None
    texte = [str(eingabe.get("prompt") or "")]
    genannt = set()  # 865: Builds, die irgendwo im Verlauf stehen (auch in eigener Testbitte)
    with open(pfad, encoding="utf-8", errors="replace") as f:
        menschen = []
        for zeile in f:
            for n in nummern:
                if n not in genannt and re.search(r"(?<![\d.])t?" + n + r"(\.\d+)?(?![\d])", zeile):
                    genannt.add(n)
            if '"user"' not in zeile:
                continue
            try:
                d = json.loads(zeile)
            except ValueError:
                continue
            inhalt = (d.get("message") or {}).get("content") if d.get("type") == "user" and not d.get("isSidechain") else None
            if isinstance(inhalt, str) and inhalt.strip():
                menschen.append(inhalt)
    texte += menschen[-5:]
    for n in nummern:
        if any(re.search(r"(?<![\d.])t?" + n + r"(\.\d+)?(?![\d])", t) for t in texte):
            return n
    # 865 (Chef 10.11., 13:34): der Chef sagt beim Testen „Nummer 16“, „17 passt“, nicht die Buildnummer;
    # gilt als Test, wenn die Sitzung den Build im Verlauf hat und eine der letzten Nachrichten so einen Punkt nennt
    punkt = re.compile(r"\b(Nummer|Punkt|Nr\.?)\s*\d{1,2}\b|^\W*\d{1,2}\W*$|\b\d{1,2}\s+(passt|ok|okay|geht|fehlt|nicht|ist|war|auch)\b", re.I | re.M)
    if genannt and any(punkt.search(t) for t in texte):
        return max(genannt, key=int)
    return None


def geschuetzt():
    """1531 (Chef 17.11., 08:52): diese Sitzung steht in „**Nie archivieren:**“ (ARBEIT-BETRIEB.md): keine Neustart-Erinnerung."""
    import re
    kennung = os.environ.get("CLAUDE_CODE_REMOTE_SESSION_ID", "")
    if not kennung.startswith("cse_"): return False
    for d in ("/home/user/bornim-main/docs", os.path.join(os.environ.get("CLAUDE_PROJECT_DIR", "."), "docs")):
        try: text = open(os.path.join(d, "ARBEIT-BETRIEB.md")).read()
        except OSError: continue
        m = re.search(r"(?m)^\*\*Nie archivieren:?\*\*:?(.*)$", text)
        return bool(m) and ("session_" + kennung[4:]) in m.group(1)
    return False


def prompt(eingabe):
    pfad = eingabe.get("transcript_path")
    sitzung = "".join(c for c in str(eingabe.get("session_id") or "x") if c.isalnum() or c == "-")[:64]
    # Uhr (Chef 18.10.: „keiner kann die Uhr lesen“): jede Nachricht trägt die echte Zeit, die Sitzung schätzt nie.
    # 462 (Chef 01.11., 20:34): fertiger Kopf mit Name, damit jede Nachricht so beginnt (CLAUDE.md Zusammenarbeit 7)
    try:
        import datetime, zoneinfo
        uhr = datetime.datetime.now(zoneinfo.ZoneInfo("Europe/Berlin")).strftime("%d.%m., %H:%M")
        print("Uhr: " + uhr + " (Berliner Zeit, Systemuhr; so stempeln)")
        try:
            wer = name(pfad, sitzung)
        except Exception:
            wer = ""
        if wer:
            print("Jede Nachricht an den Chef, auch Zwischenmeldungen in diesem Zug, beginnt mit: **" + wer + "** [" + uhr + "]")
        else:  # 462.1 (D59.3): Rolle nicht erkannt, kein wörtliches „<Name>“
            print("Jede Nachricht an den Chef, auch Zwischenmeldungen in diesem Zug, beginnt mit deinem Rollennamen fett und ["
                  + uhr + "], etwa „**Tom** [" + uhr + "]“")
    except Exception:
        pass
    kern(sitzung)
    try:  # 1762 Haken D: Chefwort zu fremdem Vorgang in die Vorgangsdatei (scharf erst mit tools/1727-SCHARF)
        sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
        import chefwort
        chefwort.haken(eingabe, name(pfad, sitzung))
    except Exception:
        pass
    if not pfad or not os.path.exists(pfad) or geschuetzt():
        return
    plus, gesamt = zuwachs(groessen(pfad))
    zpfad = f"/tmp/bornim-neustart-{sitzung}.json"
    try:
        with open(zpfad) as f:
            z = json.load(f)
    except (OSError, ValueError):
        z = {}
    ab = schwellen(rolle(pfad, sitzung), kauf())[0]  # 1520: je Rolle (818 Kaufrepo, 1643 Sokrates)
    ford = False
    try:  # 1574 (Chef 17.11., 18:31): Ford bleibt eine Sitzung, kein Selbstneustart; die Verdichtung hält sein Gespräch klein, keine Erinnerung
        if name(pfad, sitzung).startswith("Ford") or ist_ford():
            return
    except Exception:
        pass
    if gesamt < ab:  # 383 A: Gesprächslänge, nicht Zuwachs
        if z:
            os.remove(zpfad)  # unter der Schwelle (z. B. nach dem Verdichten): von vorn
        return
    stufe = int(z.get("stufe", 0))
    seit = int(z.get("seit", 0)) + 1
    faellig = stufe == 0 or gesamt >= 2 * ab or seit >= ABSTAENDE[min(stufe - 1, len(ABSTAENDE) - 1)]
    if faellig:
        stufe, seit = stufe + 1, 0
        try:  # 1019: Ford testet nie; Buildnummern in Meldungen anderer Sitzungen hielten ihn über 600 Tsd. (14.11.)
            n = None if ford else pruefliste(pfad, eingabe)
        except Exception:
            n = None
        if n:  # 812: kein Neustart mitten im Test
            print(f"Neustart-Haken (Thema 14): Das Gespräch ist {round(gesamt / 1000)} Tsd. Token lang, aber der Chef meldet Prüfliste t{n} in dieser Sitzung: "
                  "weiter, bis er fertig ist; danach Übergabe und Neustart über Ford (812). Im Chat nichts dazu.")
        else:
            print(text(stufe, plus, gesamt, ab, ford))
    with open(zpfad, "w") as f:
        json.dump({"stufe": stufe, "seit": seit}, f)


SPERRE_AB = int(os.environ.get("BORNIM_SPERRE_AB", "300000"))
WERKZEUG_ALLE = 25  # 1537: Erinnerung an Werkzeugaufrufen höchstens alle 25 Aufrufe
# 1537 (1520 so, Chef 17.11., 10:00): ab der Sperre nur noch Übergabe, Push, Neustart-Nachricht an Ford
FREI_WERKZEUG = {"ToolSearch", "ReadNotifications", "TaskStop", "mcp__claude-code-remote__send_message",
                 "mcp__claude-code-remote__get_session", "mcp__claude-code-remote__list_sessions",
                 "mcp__claude-code-remote__set_session_title", "mcp__claude-code-remote__create_session"}
FREI_DATEI = r"/docs/(ARBEIT-[^/]*|LISTE-REGELTREUE|LISTE-RELEASE-NEUSTART)\.md$"  # Übergabe, Zählung sichern (347), Neustart-Ablauf lesen (1540)
FREI_BASH = (r"^\s*(do\s+|then\s+)?(cd \S+\s*$|git( -C \S+)? (add|commit|push|pull|fetch|merge|status|log|diff|show|rev-parse|branch)\b"
             r"|python3 (\S*/)?tools/(vorgang|regelcheck|startbar|zug-haken)\.py|(\S*/)?tools/(notiz|meldung)\.sh"
             r"|(grep|sed -n|cat|head|tail)\b.*\bdocs/LISTE-RELEASE-NEUSTART\.md"
             r"|for \w+ in [\w ]+$|(break|done|fi|true|sleep \d+)\s*$|if git\b)")  # Push mit Wiederholschleife (1540)


# 1520 (Chef 22.11., 13:34 „nicht ständig neue Sitzungen … nicht ewig lang“): Erinnerung und Sperre je Rolle in Token, aus der Erneuerungsrechnung
# (Startlast gegen wachsenden Verlauf, Messung 22.11. in docs/vorgang/1520.md): günstigste Sperre aus 300/450/600 Tsd., Erinnerung bei 2/3.
# Fehlt die Rolle, gilt STANDARD. Ausnahmen nach Chefentscheid, nicht aus der Rechnung: Sokrates (1643), Kaufrepo +200 Tsd. (818); Ford nie (1574).
# Je Rolle: Kosten je Schritt bei Sperre 300/450/600 Tsd. (Opus 5.5, 1h-Cache 8 $, Lesen 0,20 $, Ausgabe 20 $ je MTok; 76 Sitzungen 22.11. ab 07:00).
STANDARD = (AB, SPERRE_AB)
SCHWELLEN = {
    "Spike": STANDARD,         # 27 Sitzungen: 6,75 / 8,01 / 9,42 ct, Minimum 199 Tsd.
    "Diogenes": STANDARD,      # 14: 6,45 / 7,74 / 9,15 ct, Minimum 192 Tsd.
    "Arbeitsplaner": STANDARD,  # 9: 6,92 / 8,17 / 9,57 ct, Minimum 197 Tsd.
    "Werkzeug": STANDARD,      # 3: 7,29 / 8,55 / 9,94 ct, Minimum 197 Tsd.
    "Prüfer": STANDARD,        # 2: 7,18 / 8,41 / 9,79 ct, Minimum 204 Tsd.
    "Wache": STANDARD,         # 2: 9,51 / 10,44 / 11,70 ct, Minimum 256 Tsd.
    "Homer": STANDARD,         # 1: 7,34 / 8,59 / 9,99 ct
    "Tagesbericht": STANDARD,  # 1: 6,39 / 7,70 / 9,12 ct
    "Welt": STANDARD,          # 1: 5,74 / 7,11 / 8,55 ct
    "Sokrates": (400000, 500000),  # Chefentscheid 1643; Rechnung (9): 7,30 / 8,62 / 10,04 ct, Minimum 188 Tsd. (Frage 1520)
}
KAUF_PLUS = 200000


def kauf():
    return os.path.isdir(os.path.join(os.environ.get("BORNIM_KAUF", KAUF), ".git"))


def schwellen(wer, mit_kauf=False):
    """1520: (Erinnerung, Sperre) für die Rolle wer; mit Kaufrepo je +KAUF_PLUS (818)."""
    e, s = SCHWELLEN.get(wer, STANDARD)
    return (e + KAUF_PLUS, s + KAUF_PLUS) if mit_kauf else (e, s)


def rolle(pfad, sitzung):
    """1520: Rolle für die Schwellen: name() oder, in der Neustruktur, „Dein Rufname: X (Rolle Werkzeug …“ bzw. „Du bist **Disponent**“."""
    import re
    try:
        wer = name(pfad, sitzung)
    except Exception:
        wer = ""
    if wer:
        return re.sub(r" \d$", "", wer)
    try:
        with open(pfad, encoding="utf-8", errors="replace") as f:
            kopf = f.read(200000)
    except (OSError, TypeError):
        return ""
    m = re.search(r"Dein Rufname: \w+ \(Rolle (\w+)", kopf) or re.search(r"Du bist \*\*(\w+)\*\*", kopf)
    return m.group(1) if m else ""


def letzte_groesse(pfad, rueck=3_000_000):
    """1537: nur die letzte Antwort zählt; liest das Protokollende, damit jeder Werkzeugaufruf billig bleibt."""
    with open(pfad, "rb") as f:
        f.seek(0, 2)
        f.seek(max(0, f.tell() - rueck))
        zeilen = f.read().decode("utf-8", errors="replace").splitlines()
    for zeile in reversed(zeilen):
        if '"usage"' not in zeile:
            continue
        try:
            d = json.loads(zeile)
        except ValueError:
            continue
        if d.get("type") != "assistant" or d.get("isSidechain"):
            continue
        u = (d.get("message") or {}).get("usage") or {}
        t = sum(int(u.get(k) or 0) for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))
        if t > 0:
            return t
    return 0


def frei(eingabe):
    """1537: erlaubt ab der Sperre: Übergabe (Vorrat docs/ARBEIT-*.md lesen und schreiben), Commit und Push, Meldung, Nachricht an Ford."""
    import re
    werkzeug = str(eingabe.get("tool_name") or "")
    ein = eingabe.get("tool_input") or {}
    if werkzeug in FREI_WERKZEUG:
        return True
    if werkzeug in ("Read", "Edit", "Write"):
        return bool(re.search(FREI_DATEI, str(ein.get("file_path") or "")))
    if werkzeug == "Bash":
        befehl = str(ein.get("command") or "")
        befehl = re.sub(r"<<-?\s*['\"]?(\w+)['\"]?.*?^\s*\1\s*$", "", befehl, flags=re.S | re.M)  # Hier-Dokument (Commit-Nachricht)
        befehl = re.sub(r"\"(?:[^\"\\]|\\.)*\"|'[^']*'", "''", befehl, flags=re.S)  # Text in Anführungszeichen
        befehl = re.sub(r"\s\d?>&\d|\s\d?>\s*/dev/null|\s*\|\s*(tail|head|grep)\b[^|;&\n]*", "", befehl)  # 2>&1, 2>/dev/null, | tail -5
        if re.search(r"[|>`]|\$\(", befehl.replace("||", "&&")):
            return False
        teile = [t for t in re.split(r"\s*(?:&&|\|\||;|\n)\s*", befehl.strip()) if t.strip()]
        return bool(teile) and all(re.match(FREI_BASH, t) for t in teile)
    return False


def werkzeug(eingabe, art):
    """1537 (1520 so, Chef 17.11., 10:00): Neustart-Haken an jedem Werkzeugaufruf, damit lange Züge ohne Nachricht nicht ungemessen bleiben.
    art „vor“ (PreToolUse): ab der Sperre aus schwellen() (1520, je Rolle) Rückgabe 2 = Aufruf gesperrt, außer frei();
    art „nach“ (PostToolUse): ab der Erinnerung aus schwellen() alle WERKZEUG_ALLE Aufrufe eine Erinnerung, zählt die Stufe weiter (Weiter-Haken 195).
    Nie, solange der Chef einen Build der Sitzung testet (812, 865) oder die Sitzung geschützt ist (1531)."""
    pfad = eingabe.get("transcript_path")
    if not pfad or not os.path.exists(pfad) or geschuetzt():
        return 0
    gesamt = letzte_groesse(pfad)
    sitzung = "".join(c for c in str(eingabe.get("session_id") or "x") if c.isalnum() or c == "-")[:64]
    ford = name(pfad, sitzung).startswith("Ford") or ist_ford()
    if ford:  # 1574: Ford bleibt eine Sitzung, weder Erinnerung noch Sperre
        return 0
    ab, sperre = schwellen(rolle(pfad, sitzung), kauf())  # 1520: Tabelle je Rolle (818 Kaufrepo, 1643 Sokrates)
    if gesamt < ab:
        return 0
    zpfad = f"/tmp/bornim-neustart-{sitzung}.json"
    try:
        with open(zpfad) as f:
            z = json.load(f)
    except (OSError, ValueError):
        z = {}
    aufrufe = int(z.get("aufrufe", 0)) + (1 if art == "nach" else 0)
    k = lambda n: f"{round(n / 1000)} Tsd."
    if art == "vor":
        if gesamt < sperre or frei(eingabe):
            return 0
        test = z.get("test")
        if test is None:  # Prüfliste liest das ganze Protokoll, darum zwischengespeichert (frisch alle WERKZEUG_ALLE Aufrufe)
            test = "" if ford else (pruefliste(pfad, {}) or "")
            z["test"] = test
            with open(zpfad, "w") as f:
                json.dump(z, f)
        if test:
            return 0
        sys.stderr.write(f"Neustart-Haken (1537): Das Gespräch ist {k(gesamt)} Token lang, Sperre ab {k(sperre)}: erlaubt sind nur noch "
                         "Übergabe (docs/ARBEIT-*.md), Commit und Push, meldung.sh, vorgang.py und die Nachricht an Ford "
                         + ("(Selbstneustart nach LISTE-BETRIEB.md)." if ford else "„Neustart <Name>, <Commit>“ (send_message); im Chat danach genau „Weiter in <Titel>: <Link>“."))
        return 2
    z["aufrufe"] = aufrufe
    if aufrufe % WERKZEUG_ALLE == 0 or "test" not in z:
        try:
            z["test"] = "" if ford else (pruefliste(pfad, {}) or "")
        except Exception:
            z["test"] = ""
    if not z["test"] and (aufrufe % WERKZEUG_ALLE == 1 or int(z.get("stufe", 0)) == 0):
        stufe = int(z.get("stufe", 0)) + 1
        z["stufe"], z["seit"] = stufe, 0
        hinweis = text(stufe, 0, gesamt, ab, ford).replace("; seit dem Start +0 Tsd.", "") + f" Ab {k(sperre)} sperrt der Haken jeden Werkzeugaufruf außer Übergabe, Push und Nachricht an Ford (1537)."
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": hinweis}}, ensure_ascii=False))
    with open(zpfad, "w") as f:
        json.dump(z, f)
    return 0


def kern(sitzung):
    """347: Kernregel-Zeile bei jeder KERN_ALLE-ten Nachricht, Wortlaut aus kernregeln.txt (main zuerst)."""
    zpfad = f"/tmp/bornim-kern-{sitzung}"
    try:
        n = int(open(zpfad).read().strip() or 0) + 1
    except (OSError, ValueError):
        n = 1
    with open(zpfad, "w") as f:
        f.write(str(n))
    if n % KERN_ALLE != 1:
        return
    for d in ("/home/user/bornim-main/tools", os.path.dirname(os.path.abspath(__file__))):
        try:
            print(open(os.path.join(d, "kernregeln.txt"), encoding="utf-8").read().strip())
            return
        except OSError:
            pass


BESITZER_VORRAT = {"ARBEIT-KREATIV.md": "Homer", "ARBEIT-TEAM-TOM.md": "Tom", "ARBEIT-TEAM-JERRY.md": "Jerry", "ARBEIT-TEAM-SPIKE.md": "Spike",
                   "ARBEIT-PROJEKT.md": "Perikles", "ARBEIT-PRUEFUNG.md": "Diogenes", "ARBEIT-BERATUNG.md": "Sokrates", "ARBEIT-BETRIEB.md": "Ford",
                   "ARBEIT-BESETZUNG.md": "Ford", "ARBEIT-TAGESBERICHT.md": "Perikles"}


def start(eingabe):
    wurzel = os.environ.get("CLAUDE_PROJECT_DIR") or eingabe.get("cwd") or "."
    # 98: jeder Vorrat ARBEIT-*.md, außer dem eingefrorenen Archiv (117).
    docs = os.path.join(wurzel, "docs")
    try:
        namen = sorted(os.listdir(docs))
    except OSError:
        return
    for name in namen:
        if not (name.startswith("ARBEIT-") and name.endswith(".md")) or name == "ARBEIT-ARCHIV.md":
            continue
        n = os.path.getsize(os.path.join(docs, name))
        if n > OFFEN_MAX:
            wer = BESITZER_VORRAT.get(name, "Perikles")  # 1642: jede Startwarnung mit festem Besitzer (wie startwarnung.py)
            print(f"Bornim: docs/{name} ist {round(n / 1000)} KB groß (Grenze {round(OFFEN_MAX / 1000)} KB; Besitzer {wer}, nach 6 h Vorgang durchs Werkzeug). "
                  "Nach der Regel „Vorräte klein halten“ in CLAUDE.md aufräumen (Erledigtes ins Archiv bzw. in die Änderungshistorie).")


# 1999 (b, c): abgelehntes create_trigger/create_session wird eine rohe Zeile im Lehrenbuch (Fall Betrieb, je Tag und Ursache einmal).
# Claude Code meldet eine Ablehnung der Auto-Prüfung als Ereignis PermissionDenied (Feld reason), einen Fehler des Dienstes als
# PostToolUseFailure (Feld error); PostToolUse kommt nur nach Erfolg (code.claude.com/docs/en/hooks). Darum versteht der Haken alle drei.
STARTWERKZEUG = ("create_trigger", "create_session")
ABGELEHNT = r"(?i)\b(denied|refused|rejected|not (?:permitted|allowed|authori[sz]ed)|abgelehnt|verweigert|nicht erlaubt)\b"


def abgelehnt(eingabe):
    """(Ursache, Anlass) für ein abgelehntes create_trigger/create_session, sonst None."""
    import re
    w = str(eingabe.get("tool_name") or "")
    kurz = next((k for k in STARTWERKZEUG if w == k or w.endswith("__" + k)), None)
    if not kurz:
        return None
    ev = str(eingabe.get("hook_event_name") or "")
    if ev == "PermissionDenied":
        grund = str(eingabe.get("reason") or "ohne Grund")
    elif ev == "PostToolUseFailure":
        if eingabe.get("is_interrupt"):
            return None
        grund = str(eingabe.get("error") or "ohne Fehlertext")
    else:
        antwort = eingabe.get("tool_response")
        antwort = antwort if isinstance(antwort, str) else json.dumps(antwort, ensure_ascii=False) if antwort is not None else ""
        if not re.search(ABGELEHNT, antwort):
            return None
        grund, ev = antwort, ev or "PostToolUse"
    sitzung = os.environ.get("CLAUDE_CODE_REMOTE_SESSION_ID", "") or str(eingabe.get("session_id") or "")
    return ("%s abgelehnt (%s)" % (kurz, ev), "%s in Sitzung %s: %s" % (kurz, sitzung or "?", " ".join(grund.split())[:300]))


def lehre_abgelehnt(eingabe):
    """Schreibt im Hintergrund (Push dauert länger als die Hakenfrist); Ausgabe nach /tmp/bornim-lehre-betrieb.log. Rückgabe Ursache oder None."""
    import subprocess
    t = abgelehnt(eingabe)
    if not t:
        return None
    lehren = os.path.join(os.path.dirname(os.path.abspath(__file__)), "lehren.py")
    with open("/tmp/bornim-lehre-betrieb.log", "a") as log:
        subprocess.Popen([sys.executable, lehren, "betrieb", t[0], t[1]], stdout=log, stderr=log, stdin=subprocess.DEVNULL, start_new_session=True)
    return t[0]


def main():
    try:
        eingabe = json.load(sys.stdin)
    except ValueError:
        eingabe = {}
    art = sys.argv[1] if len(sys.argv) > 1 else ""
    if art == "prompt":
        prompt(eingabe)
    elif art == "start":
        start(eingabe)
    elif art in ("vor", "nach", "abgelehnt"):
        try:
            lehre_abgelehnt(eingabe)  # 1999
        except Exception:
            pass
        if art != "abgelehnt":
            return werkzeug(eingabe, art)
    return 0


if __name__ == "__main__":
    code = 0
    try:
        code = main() or 0
    except Exception:
        code = 0
    sys.exit(2 if code == 2 else 0)
