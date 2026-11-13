#!/usr/bin/env python3
"""Neustart-Haken (Thema 14). Läuft über .claude/settings.json und tut bei jedem Fehler still nichts.

  neustart-haken.py prompt   bei jeder Nachricht des Nutzers (UserPromptSubmit): misst, wie stark das Gespräch
                             seit dem Start gewachsen ist, und erinnert ab der Schwelle an einen Neustart,
                             erst selten, dann immer öfter, je länger der Nutzer weiterarbeitet.
  neustart-haken.py start    beim Sitzungsstart (SessionStart): warnt, wenn ein Vorrat docs/ARBEIT-*.md zu groß ist.

Die Größe kommt aus dem Gesprächsprotokoll (transcript_path): Token der letzten Antwort (Eingabe, auch
zwischengespeichert). Seit 383 A zählt die ganze Gesprächslänge (jeder Aufruf liest sie ganz), nicht mehr der Zuwachs.

Schwellen über Umgebungsvariablen änderbar: BORNIM_NEUSTART_AB (Gesprächslänge in Token, Vorgabe 200000; 383 A, Chef 09.11.; vorher 300000 Zuwachs nach 383.1),
BORNIM_OFFEN_MAX (Bytes, Vorgabe 15000). Zustand je Sitzung in /tmp/bornim-neustart-<Sitzung>.json.
Bei der 1., 11., 21. … Nachricht zusätzlich die Kernregel-Zeile aus tools/kernregeln.txt (347, ein Wortlaut, auch notiz.sh).
"""
import json
import os
import sys

KERN_ALLE = 10
AB = int(os.environ.get("BORNIM_NEUSTART_AB", "200000"))
OFFEN_MAX = int(os.environ.get("BORNIM_OFFEN_MAX", "15000"))
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


def text(stufe, plus, gesamt, ab=AB):
    k = lambda n: f"{round(n / 1000)} Tsd."
    kopf = f"Neustart-Haken (Thema 14): Das Gespräch ist {k(gesamt)} Token lang (Schwelle {k(ab)}, 383 A{', doppelt: Kaufrepo eingebunden 818 oder Ford 1019' if ab != AB else ''}; seit dem Start +{k(plus)}); Erinnerung Nr. {stufe}."
    # 81r: der Anlass entscheidet, nicht ein Ja des Nutzers; kein Vorschlag im Chat (D8.2: der löste den Chefsache-Haken aus)
    if stufe == 1:
        rest = "An der nächsten Bruchstelle (Thema fertig, Build ausgeliefert): zuerst `python3 tools/regelcheck.py --kurz` und die Funde im eigenen Vorrat beheben, dann Übergabe mit „Nachfolger: <Titel>“ pushen, send_message an Ford „Neustart <Name>, <Commit>“ (81r, LISTE-RELEASE-NEUSTART.md „Neustart“). Im Chat nichts dazu."
    else:
        rest = "Zweite Erinnerung: jetzt den Schritt beenden, Übergabe pushen, Neustart über Ford (81r); im Chat danach genau „Weiter in <Titel>: <Link>“."
    return kopf + " " + rest


ROLLEN = r"(Perikles|Homer|Sokrates|Diogenes|Ford|Tom|Jerry|Spike|Tuffy)( \d)?"


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
    if not pfad or not os.path.exists(pfad):
        return
    plus, gesamt = zuwachs(groessen(pfad))
    zpfad = f"/tmp/bornim-neustart-{sitzung}.json"
    try:
        with open(zpfad) as f:
            z = json.load(f)
    except (OSError, ValueError):
        z = {}
    ab = 2 * AB if os.path.isdir(os.path.join(KAUF, ".git")) else AB  # 818
    try:  # 1019: Ford startet sich bei 400 Tsd. selbst neu (185, LISTE-BETRIEB „Selbstneustart“), nicht am Haken (Tiefe wuchs sonst täglich bis 6)
        if name(pfad, sitzung).startswith("Ford"):
            ab = 2 * AB
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
        try:
            n = pruefliste(pfad, eingabe)
        except Exception:
            n = None
        if n:  # 812: kein Neustart mitten im Test
            print(f"Neustart-Haken (Thema 14): Das Gespräch ist {round(gesamt / 1000)} Tsd. Token lang, aber der Chef meldet Prüfliste t{n} in dieser Sitzung: "
                  "weiter, bis er fertig ist; danach Übergabe und Neustart über Ford (812). Im Chat nichts dazu.")
        else:
            print(text(stufe, plus, gesamt, ab))
    with open(zpfad, "w") as f:
        json.dump({"stufe": stufe, "seit": seit}, f)


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
            print(f"Bornim: docs/{name} ist {round(n / 1000)} KB groß (Grenze {round(OFFEN_MAX / 1000)} KB). "
                  "Nach der Regel „Vorräte klein halten“ in CLAUDE.md aufräumen (Erledigtes ins Archiv bzw. in die Änderungshistorie).")


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


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
