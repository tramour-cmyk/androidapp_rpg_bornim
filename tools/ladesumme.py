#!/usr/bin/env python3
"""1866 (1739, werkzeuge.md Z. 77; Chef 20.11., 16:49 „Kerne nicht aufblähen, Größe nennen“, 16:52 Tabelle nachhalten): Größen- und
Ladesummen-Skript. Byte je Teil (Sockel, Kern, Profil, Querprofil, Routine) und Summe je Sitzungsart, mit --gegen REV vorher/nachher.

Messregel (`1727-muster/texte-stand-10-00.md`:3): UTF-8, ohne Kopfzeile „# …“ und die Leerzeile danach, bis vor die erste Zeile mit
„## “, ohne letztes Zeilenende; bei Codeblöcken nur der Inhalt. Ein Teil ist
  PFAD                       Ladetext der Datei nach Messregel
  PFAD|Überschrift[|n]       n-ter Codeblock (Vorgabe 1) unter der Überschrift (Zeilenanfang), bis zur nächsten gleich hohen
Nach der Umstellung (1871) liegen die Ladetexte unter docs/profile/<Profil>.md (lauf.kern); gibt es die Datei, zählt sie statt
des Entwurfs. Muster (erst nachsehen, wie andere es lösen): Größenbudgets wie size-limit/bundlesize (Teil, Grenze, Vergleich mit
dem Ausgangsstand), hier für Ladetexte statt Pakete.
Aufruf: python3 tools/ladesumme.py [--gegen REV] [--teile] | --test
"""
import os, re, subprocess, sys

WURZEL = os.environ.get("BORNIM_WURZEL") or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
M = "docs/entwurf/1727-muster/"
G = "docs/entwurf/1727-gesamtbild.md"
# Teil: (Quelle Entwurf, Profilname nach der Umstellung oder None, Grenze in Byte oder None)
TEILE = {
    "Sockel": (G + "|## 1 Sockel", None, 1200),
    "Kern Leitung": (G + "|### 2.1 Kern Leitung|2", None, 3000),
    "Kern Büro": (M + "kern-buero.md", "Kern Büro", None),
    "Kern Arbeitsplaner": (M + "kern-arbeitsplaner.md", "Arbeitsplaner", 3000),
    "Kern Abnahme": (M + "kern-abnahme.md", "Kern Abnahme", None),
    "Profil Disponent": (M + "profil-disponent.md|## Text", "Disponent", None),
    "Profil Prüfer": (M + "profil-pruefer.md", "Prüfer", None),
    "Profil Tester": (M + "profil-tester.md", "Tester", None),
    "Profil Werkzeug A": (M + "profil-werkzeug.md|## Teil A", "Werkzeug", None),
    "Querprofil Fremde Inhalte A": (M + "profil-fremde-inhalte.md|## Teil A", "Fremde Inhalte", None),
    "Querprofil Signatur und Leben": (M + "querprofil-signatur-und-leben.md", "Signatur und Leben", None),
    "Profil Welt": (M + "profil-welt.md", "Welt", None),
    "Profil Figur und Prüfbild": (M + "profil-figur-und-pruefbild.md", "Figur und Prüfbild", None),
    "Profil Story": (M + "profil-story.md", "Story", None),
    "Routine Wache": (M + "routine-wache.md|## Text", "Wache", None),
}
# Sitzungsart: Teile (herausgezogen.md „Ladesumme je Sitzungsart“); Auftrag kommt je Start dazu
SITZUNGEN = {
    "Leitung": ["Sockel", "Kern Leitung"],
    "Büro: Disponent": ["Sockel", "Kern Büro", "Profil Disponent"],
    "Büro: Arbeitsplaner": ["Sockel", "Kern Büro", "Kern Arbeitsplaner"],
    "Werkstatt Welt": ["Sockel", "Querprofil Signatur und Leben", "Profil Welt", "Profil Figur und Prüfbild"],
    "Werkstatt Text": ["Sockel", "Profil Story"],
    "Werkstatt Werkzeug": ["Sockel", "Profil Werkzeug A"],
    "Abnahme: Prüfer": ["Sockel", "Kern Abnahme", "Profil Prüfer"],
    "Abnahme: Tester": ["Sockel", "Kern Abnahme", "Profil Tester"],
    "Routine Wache": ["Sockel", "Routine Wache"],
}


def messregel(text):
    """Ladetext nach Messregel in Byte."""
    z = text.split("\n")
    if z and z[0].startswith("# "):
        z = z[1:]
        if z and not z[0].strip(): z = z[1:]
    j = next((k for k, x in enumerate(z) if x.startswith("## ")), len(z))
    return len("\n".join(z[:j]).rstrip("\n").encode("utf-8"))


def block(text, kopf, n=1):
    """Inhalt des n-ten Codeblocks unter der Überschrift KOPF (bis zur nächsten gleich hohen oder höheren); Byte oder None."""
    z = text.split("\n")
    i = next((k for k, x in enumerate(z) if x.startswith(kopf)), None)
    if i is None: return None
    stufe = len(kopf) - len(kopf.lstrip("#"))
    bl, drin, cur = [], False, []
    for x in z[i + 1:]:
        if not drin and re.match(r"#{1,%d} " % stufe, x): break  # Überschriften im Codeblock zählen nicht (Sockel beginnt mit „# …“)
        if x.startswith("```"):
            if drin: bl.append(cur); cur = []
            drin = not drin
        elif drin: cur.append(x)
    return len("\n".join(bl[n - 1]).encode("utf-8")) if len(bl) >= n else None


def lesen(pfad, rev=None):
    if rev:
        p = subprocess.run(["git", "-C", WURZEL, "show", "%s:%s" % (rev, pfad)], capture_output=True, text=True)
        return p.stdout if p.returncode == 0 else None
    try: return open(os.path.join(WURZEL, pfad), encoding="utf-8").read()
    except OSError: return None


def teil_byte(name, rev=None):
    """(Byte oder None, Quelle)."""
    quelle, profil, _ = TEILE[name]
    if profil:
        t = lesen("docs/profile/%s.md" % profil, rev)
        if t is not None: return messregel(t), "docs/profile/%s.md" % profil
    pfad, _, rest = quelle.partition("|")
    t = lesen(pfad, rev)
    if t is None: return None, pfad
    if not rest: return messregel(t), pfad
    kopf, _, n = rest.partition("|")
    return block(t, kopf, int(n or 1)), quelle


def tabelle(rev=None, nur_teile=False):
    aus = []
    jetzt = {n: teil_byte(n)[0] for n in TEILE}
    vor = {n: teil_byte(n, rev)[0] for n in TEILE} if rev else {}
    f = lambda b: "–" if b is None else "{:,}".format(b).replace(",", ".")
    d = lambda a, b: "" if a is None or b is None or a == b else " (%+d)" % (a - b)
    aus.append("| Teil | Byte%s | Grenze |" % (" (vorher %s)" % rev if rev else ""))
    for n, (_, _, g) in TEILE.items():
        b = jetzt[n]; warn = " **über Grenze**" if g and b and b > g else ""
        aus.append("| %s | %s%s%s | %s |" % (n, f(b), (" ← %s" % f(vor[n]) + d(b, vor[n])) if rev else "", warn, f(g)))
    if nur_teile: return aus
    aus.append(""); aus.append("| Sitzungsart | Summe%s | Teile |" % (" (vorher)" if rev else ""))
    for s, ts in SITZUNGEN.items():
        su = None if any(jetzt[t] is None for t in ts) else sum(jetzt[t] for t in ts)
        sv = None if not rev or any(vor[t] is None for t in ts) else sum(vor[t] for t in ts)
        aus.append("| %s | %s%s | %s |" % (s, f(su), (" ← %s" % f(sv) + d(su, sv)) if rev else "", " + ".join(ts)))
    aus.append("\nMessregel ohne Kopfzeile, Leerzeile, letztes Zeilenende; Auftrag je Start dazu (bis 1,5 KB, Werkzeug etwa 2 KB).")
    return aus


def test():
    f = 0
    def ok(b, was):
        nonlocal f; f += not b; print(("ok  " if b else "FEHL"), was)
    ok(messregel("# Kopf\n\nZeile ä\n\n## Rest\nx\n") == len("Zeile ä".encode()), "Messregel: ohne Kopf, Leerzeile, bis ##, ohne Zeilenende")
    ok(messregel("Text\n") == 4, "Messregel ohne Kopfzeile")
    t = "## 1 Sockel\n\nvor\n```markdown\n# K\nabc\n```\n### 1.1 Unter\n```\nxy\n```\n## 2\n```\nzzz\n```\n"
    ok(block(t, "## 1 Sockel") == 7 and block(t, "## 1 Sockel", 2) == 2 and block(t, "### 1.1 Unter") == 2 and block(t, "## 2") == 3, "Codeblöcke je Überschrift, „# “ im Block beendet nicht")
    ok(block(t, "## 9") is None and block(t, "## 1 Sockel", 3) is None, "fehlt → None")
    # Abgleich mit gemessenen Werten (Gesamtbild 0.1, herausgezogen.md), soweit am Stand vorhanden
    soll = {"Sockel": 1109, "Kern Leitung": 2837, "Kern Büro": 680, "Profil Werkzeug A": 1103, "Kern Arbeitsplaner": 2649, "Profil Disponent": 3775}
    for n, w in soll.items():
        b, q = teil_byte(n)
        if b is None: print("…   %s: Quelle %s fehlt am Stand" % (n, q)); continue
        ok(b == w, "%s %s Byte wie gemessen (%s)" % (n, b, w))
    print("ladesumme --test: %s" % ("alles grün" if not f else "%d FEHL" % f))
    return 1 if f else 0


if __name__ == "__main__":
    a = sys.argv[1:]
    if "--test" in a: sys.exit(test())
    rev = a[a.index("--gegen") + 1] if "--gegen" in a else None
    print("\n".join(tabelle(rev, "--teile" in a)))
