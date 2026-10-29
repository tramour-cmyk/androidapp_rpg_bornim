#!/usr/bin/env python3
"""Prüfung beim Commit in der Notizkopie (192.1, Grenzen aus D31.1). Aufruf als pre-commit-Haken (notiz.sh richtet ihn ein).
Hält an (Exit 1): Uhrzeit von heute mehr als 5 Minuten nach jetzt in einer neuen Zeile; gelöschte Chefsache-Datei ohne
Änderung an VORGANGSARCHIV.md (Ausweg: BORNIM_ZURUECK=1 für zurückgezogene Fragen des Absenders); neue Vorratszeile mit Nummer ohne
Zeile in LISTE-VORGAENGE.md (D- und Unternummern über die Oberzeile); Vorrat über 15000 Bytes, den der Commit vergrößert
(Hinweis eines anderen mit „von <Absender>“ in jeder neuen Zeile ausgenommen, 400; ARBEIT-BETRIEB.md ausgenommen: Fords Startsperre muss dorthin, kürzen ist Fords Zeile); neue Antwort im Vorgangsarchiv, deren Vorlage
in entscheiden/, ansehen/ oder billigen/ stehen bleibt (383.3: wer die Antwort einträgt, löscht die Datei im selben Commit; bleibt die
Frage trotz Antwort offen, setzt er die Zeit in Zeile 1 oder 2 der Datei neu). Eine beantwortete Vorlage darf ohne Archivänderung weg.
Warnt (Exit 0): Modellnamen, Zeilen über 1500 Zeichen. Fasst nur Notizen an; sonst Exit 0. Jeder Fehler im Haken lässt durch."""
import datetime, os, re, subprocess, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def git(*a):
    return subprocess.run(["git"] + list(a), capture_output=True, text=True).stdout

BESITZER = {"KREATIV": "Homer", "TEAM-TOM": "Tom", "TEAM-JERRY": "Jerry", "PROJEKT": "Perikles", "PRUEFUNG": "Diogenes", "BERATUNG": "Sokrates"}
NAMEN = ("Homer", "Tom", "Jerry", "Perikles", "Diogenes", "Sokrates", "Ford")

def fremd_hinweis(p):
    """400: Hinweis eines anderen in einen vollen Vorrat geht durch, wenn jede neue Zeile einen Absender nennt, der nicht der Besitzer ist;
    kürzen bleibt Sache des Besitzers (regelcheck meldet die Größe weiter). Sonst blieb der Hinweis beim Absender liegen."""
    eig = BESITZER.get(re.match(r"docs/ARBEIT-(.*)\.md$", p).group(1))
    zeilen = [z[1:] for z in git("diff", "--cached", "-U0", "--", p).splitlines() if z.startswith("+") and not z.startswith("+++") and z[1:].strip()]
    andere = "|".join(n for n in NAMEN if n != eig)
    return bool(zeilen) and all(re.search(r"\bvon (Team |Chef über )?(%s)\b" % andere, z) for z in zeilen)

def main():
    ge = git("diff", "--cached", "--name-status", "--no-renames").splitlines()
    dat = [(l.split("\t")[0], l.split("\t")[1]) for l in ge if "\t" in l]
    video = [p for s, p in dat if s != "D" and p.lower().endswith((".mp4", ".webm"))]
    if video:  # 374 (373 b): Videos gehören auf den Zweig „bilder“ (meldung.sh legt sie dort ab), nie auf main
        print("Commit-Prüfung HÄLT AN: Video auf main (%s); auf den Zweig „bilder“ (374)" % ", ".join(video), file=sys.stderr); return 1
    if not dat or not all(p.startswith("docs/") or p in ("CLAUDE.md", "CHANGELOG.md") or p.startswith("tools/") for _, p in dat):
        return 0
    stop, warn = [], []
    import zoneinfo
    jetzt = datetime.datetime.now(zoneinfo.ZoneInfo("Europe/Berlin")); heute = jetzt.strftime("%d.%m.")
    arch = any(p == "docs/VORGANGSARCHIV.md" for _, p in dat)
    neu = git("diff", "--cached", "-U0", "--no-renames", "--", "docs", "CLAUDE.md").splitlines()
    datei = ""
    import startbar
    for z in neu:
        if z.startswith("+++ b/"): datei = z[6:]; continue
        if not z.startswith("+") or z.startswith("+++"): continue
        t = z[1:]
        for m in re.finditer(r"(?<!\d)" + re.escape(heute).replace(r"\.", r"\.") + r",? (\d\d):(\d\d)(?!\d)", t):
            if jetzt.replace(hour=int(m.group(1)), minute=int(m.group(2))) > jetzt + datetime.timedelta(minutes=5):
                stop.append("%s: Uhrzeit %s:%s liegt nach jetzt (%s)" % (datei, m.group(1), m.group(2), jetzt.strftime("%H:%M"))); break
        mm = re.match(r"\| ([0-9][0-9a-zA-Z.]*) \| (M\?|M|K) \|", t)
        if mm and re.match(r"docs/ARBEIT-(KREATIV|TEAM|PROJEKT|PRUEFUNG|BERATUNG)", datei):
            nr = mm.group(1)
            if not re.match(r"D\d", nr) and startbar.stand_von(nr)[0] is None and not any(nr in x for x in open("docs/LISTE-VORGAENGE.md", encoding="utf-8").read().split("\n") if x.startswith("| " + nr + " ")):
                stop.append("%s: Nummer %s ohne Zeile in LISTE-VORGAENGE.md" % (datei, nr))
        if re.search(r"\b(opus|sonnet|haiku|fable)\b", t, re.I) and not datei.endswith(("LISTE-BETRIEB.md", "PRUEFBERICHT-ARCHIV.md", "VORGANGSARCHIV.md", "PRUEFBERICHT.md")) and not datei.startswith("tools/"):
            warn.append("%s: Modellname in neuer Zeile" % datei)
        if len(t) > 1500 and datei.startswith("docs/ARBEIT-"): warn.append("%s: Zeile über 1500 Zeichen" % datei)
    antwort = startbar.antworten(git("show", ":docs/VORGANGSARCHIV.md")) if arch else startbar.antworten()
    if arch:  # 383.3: neue Antwort im Archiv → Vorlage zur Nummer im selben Commit weg (oder Zeit neu, wenn die Frage offen bleibt)
        neu_k = {m.group(1).replace(".", "").lower() for z in git("diff", "--cached", "-U0", "--", "docs/VORGANGSARCHIV.md").splitlines()
                 for m in [re.match(r"\+- \*\*([0-9A-Za-z][0-9A-Za-z.]*?)(?:,|\*\*| )", z)] if m}
        for p in git("ls-files", "--", "docs/chefsache/entscheiden", "docs/chefsache/ansehen", "docs/chefsache/billigen").split():
            n = os.path.basename(p)
            if n.split("-")[0].lower() in neu_k and n.endswith(".md") and os.path.exists(p):
                a = startbar.ueberholt(n, git("show", ":" + p), antwort)
                if a: stop.append("%s: Chef hat %s beantwortet (%s), die Vorlage bleibt stehen; im selben Commit löschen (383.3), "
                                  "bleibt die Frage offen: Zeit in Zeile 1 oder 2 der Datei neu setzen" % (p, a[0], a[1].strftime("%d.%m., %H:%M")))
    for s, p in dat:
        if s == "D" and p.startswith("docs/chefsache/entscheiden/") and not arch and os.environ.get("BORNIM_ZURUECK") != "1" \
                and not startbar.ueberholt(os.path.basename(p), git("show", "HEAD:" + p), antwort):
            stop.append("%s gelöscht ohne Eintrag im Vorgangsarchiv (zurückgezogen: BORNIM_ZURUECK=1)" % p)
        if re.match(r"docs/ARBEIT-(KREATIV|TEAM-TOM|TEAM-JERRY|PROJEKT|PRUEFUNG|BERATUNG)\.md$", p) and s != "D":
            neu_b = len(git("show", ":" + p).encode()); alt = git("show", "HEAD:" + p)
            if neu_b > 15000 and neu_b > len(alt.encode()) and not fremd_hinweis(p):
                stop.append("%s hat %d Bytes (über 15000) und wächst; erst kürzen (Hinweis eines anderen: Zeile mit „von <Absender>“ geht durch, 400)" % (p, neu_b))
    code = [p for s, p in dat if s != "D" and re.match(r"(core|app|tools/preview)/.*\.(kt|kts)$", p)]
    if code:  # 192.3: Kerntest-Marke aus tools/t logik (voller Lauf, Exit 0) muss neuer sein als der Code
        marke = os.path.join(git("rev-parse", "--git-common-dir").strip(), "kerntest-ok")
        try: neuster = max(os.path.getmtime(p) for p in code if os.path.exists(p))
        except ValueError: neuster = 0
        if not os.path.exists(marke) or os.path.getmtime(marke) < neuster:
            warn.append("Code ohne grünen Kerntest seit der letzten Änderung (tools/t logik, Exit-Code prüfen)")
    for w in warn: print("Commit-Prüfung Warnung: " + w, file=sys.stderr)
    for s in stop: print("Commit-Prüfung HÄLT AN: " + s, file=sys.stderr)
    return 1 if stop else 0

if __name__ == "__main__":
    try: sys.exit(main())
    except Exception as e:
        print("Commit-Prüfung übersprungen: %s" % e, file=sys.stderr); sys.exit(0)
