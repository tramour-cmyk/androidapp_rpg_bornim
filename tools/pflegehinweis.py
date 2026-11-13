#!/usr/bin/env python3
"""Pflegehinweise als Zeile der Vorgangsliste (340.3, Chef 02.11., 19:44, „340.2 ja“, Variante A; seit 275.2 in LISTE-VORGAENGE.md).

Was `notiz.sh` beim Start meldet (Größe, lange Zeilen, Übergabe zu lang; `regelcheck.py --kurz`), steht täglich als eine Zeile
„Pflege“ „von Werkzeug“ mit dem Besitzer in der Liste und ersetzt die vom Vortag; ohne Befund fällt die Zeile weg.
Dazu der Rollenspiegel als fester Freitagstermin: ab Freitag steht für jede Rolle ohne Antwort der Woche die Zeile „Spiegel“,
bis `tools/rollenspiegel.sh <Rolle> --antwort …` angehängt hat (auch wenn am Freitag keine Sitzung der Rolle lief).

Schreibt nicht in die Arbeitskopie: liest `origin/main`, baut den Commit mit eigenem Index und pusht (wie `meldung.sh`),
darum stört es offene Änderungen nicht. `notiz.sh` ruft es einmal am Tag je Rechner im Hintergrund.
Aufruf: python3 tools/pflegehinweis.py [--probe]   (--probe: nur zeigen, nichts pushen)
"""
import datetime, os, re, subprocess, sys, tempfile, zoneinfo

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")
JETZT = datetime.datetime.now(BERLIN)
VORRAT = {"Sokrates": "ARBEIT-BERATUNG.md", "Perikles": "ARBEIT-PROJEKT.md", "Homer": "ARBEIT-KREATIV.md",
          "Ford": "ARBEIT-BETRIEB.md", "Diogenes": "ARBEIT-PRUEFUNG.md", "Team Tom": "ARBEIT-TEAM-TOM.md",
          "Team Jerry": "ARBEIT-TEAM-JERRY.md"}
# Befunde ohne eigenen Vorrat: wer die Datei pflegt
FREMD = {"CLAUDE.md": "ARBEIT-PROJEKT.md", "LISTE-VORGAENGE.md": "ARBEIT-PROJEKT.md", "ARBEIT-TAGESBERICHT.md": "ARBEIT-PROJEKT.md",
         "Block": "ARBEIT-PROJEKT.md", "Testbuilds": "ARBEIT-BETRIEB.md", "startbar.py": "ARBEIT-BETRIEB.md"}


def git(*a, eingabe=None, env=None):
    return subprocess.run(["git", "-C", ROOT, *a], capture_output=True, text=True, input=eingabe, env=env, timeout=60)


def befunde():
    """{Vorratsdatei: [Befund, …]} aus regelcheck --kurz."""
    r = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "regelcheck.py"), "--kurz"], capture_output=True, text=True)
    je = {}
    for z in r.stdout.splitlines():
        if not z.startswith("  - "):
            continue
        f = z[4:].strip()
        ziel = next((v for k, v in FREMD.items() if f.startswith(k) or f.startswith("docs/" + k)), None)
        m = re.match(r"(?:docs/)?(ARBEIT-[A-Z-]+\.md)", f)
        ziel = ziel or (m.group(1) if m else "ARBEIT-PROJEKT.md")
        je.setdefault(ziel, []).append(re.sub(r"^(?:docs/)?ARBEIT-[A-Z-]+\.md: ", "", f))
    return je


def freitag(tag):
    return tag + datetime.timedelta(days=4 - tag.weekday())  # wie rollenspiegel.sh: Mo–Do der kommende, Sa/So der vergangene


def spiegel_faellig(text_spiegel):
    """Rollen, deren Rollenspiegel fällig ist: ab Freitag ohne Antwort unter „## Woche <Freitag>“; Mo–Do, wenn die Vorwoche fehlte
    und die laufende Woche noch keine Antwort hat."""
    wochen = {m.group(1): m.end() for m in re.finditer(r"(?m)^## Woche (\d\d\.\d\d\.)", text_spiegel)}

    def hat(rolle, tag):
        k = tag.strftime("%d.%m.")
        if k not in wochen:
            return False
        rest = text_spiegel[wochen[k]:]
        rest = rest.split("\n## Woche ", 1)[0]
        return re.search(r"(?m)^### " + re.escape(rolle) + r"\b", rest) is not None

    heute = JETZT.date()
    diese = freitag(heute)
    faellig = {}
    for rolle in VORRAT:
        if hat(rolle, diese):
            continue
        if heute.weekday() >= 4:
            faellig[rolle] = diese.strftime("%d.%m.")
        else:
            vorige = diese - datetime.timedelta(days=7)
            if vorige >= datetime.date(2026, 11, 6) and not hat(rolle, vorige):  # 340.3 gilt ab dem ersten Freitag danach
                faellig[rolle] = vorige.strftime("%d.%m.") + ", nachholen"
    return faellig


def setzen_liste(text, rolle, nr, zeile, unten=False):
    """275.2: Werkzeugzeile `nr` (Pflege, Spiegel) des Besitzers in der Vorgangsliste ersetzen: Pflege ans Ende seiner Zeilen, Spiegel an
    den Anfang; zeile None: entfernen."""
    sys.path.insert(0, os.path.join(ROOT, "tools")); import startbar
    L = text.split("\n")
    L = [z for z in L if not (z.startswith(f"| {nr} |") and len(z.split("|")) > 3 and z.split("|")[3].strip() == rolle)]
    if zeile:
        zs = [d for d in startbar.vorgangsliste("\n".join(L)) if d["besitzer"] == rolle]
        if zs: pos = zs[-1]["i"] + 1 if unten else zs[0]["i"]
        else:
            alle = startbar.vorgangsliste("\n".join(L))
            pos = (alle[-1]["i"] + 1) if alle else len(L)
        L.insert(pos, zeile)
    return "\n".join(L)


def gleich_bis_auf_zahlen(a, b):
    """1129.1 P2 (a): zwei Pflegezeilen sind gleich, wenn sie sich nur in Mengenangaben unterscheiden („57611 Bytes“, „712 Zeichen“)."""
    n = lambda z: re.sub(r"\d+(?=\s*(Bytes|Zeichen|KB)\b)", "N", z)
    return n(a) == n(b)


def berechnen(basis, je, tag):
    sys.path.insert(0, os.path.join(ROOT, "tools")); import startbar
    spiegel = spiegel_faellig(git("show", f"{basis}:docs/LISTE-ROLLENSPIEGEL.md").stdout)
    pfad = "docs/LISTE-VORGAENGE.md"
    alt = git("show", f"{basis}:{pfad}").stdout
    if not alt:
        return {}
    neu = alt
    for rolle, datei in VORRAT.items():
        besitzer = rolle.split()[-1]  # „Team Tom“ → Tom
        b = je.get(datei, [])
        pflege = None
        if b:
            text = "; ".join(b)
            text = text if len(text) <= 200 else text[:197] + " …"
            pflege = startbar.zeile_text(dict(nr="Pflege", titel="von Werkzeug (340.3, %s): %s" % (tag, text.replace("|", "/")), besitzer=besitzer, kl="K",
                                              stand="startbar", warte=[], bereich="B Abläufe"))
            # 1129.1 P2 (a): ändert sich nur eine Zahl (Bytes, Zeichen) am selben Tag, bleibt die alte Zeile; sonst je Start ein Commit
            # (309 in 7 Tagen) und dazu je ein Lauf „Chefsache: Übersicht“
            vorher = next((z for z in alt.split("\n") if z.startswith("| Pflege |") and len(z.split("|")) > 3
                           and z.split("|")[3].strip() == besitzer), None)
            if vorher and gleich_bis_auf_zahlen(vorher, pflege):
                pflege = vorher
        s = spiegel.get(rolle)
        sp = startbar.zeile_text(dict(nr="Spiegel", titel="von Werkzeug (340.3, Rollenspiegel Woche %s): `tools/rollenspiegel.sh %s` zeigt die Fragen; "
                                      "Antwort mit `--antwort` anhängen, committen, pushen" % (s, besitzer), besitzer=besitzer, kl="M", stand="startbar",
                                      warte=[], bereich="B Abläufe")) if s else None
        neu = setzen_liste(setzen_liste(neu, besitzer, "Pflege", pflege, unten=True), besitzer, "Spiegel", sp)  # Pflege als Kür unten
    return {pfad: neu} if neu != alt else {}


def main():
    probe = "--probe" in sys.argv
    je = befunde()
    tag = JETZT.strftime("%d.%m.")
    for versuch in range(3):  # bei abgelehntem Push neu auf dem neuen Stand rechnen, nie fremde Änderungen überschreiben
        if git("fetch", "-q", "origin", "main").returncode:
            return
        basis = git("rev-parse", "FETCH_HEAD").stdout.strip()
        aenderung = berechnen(basis, je, tag)
        if probe or not aenderung:
            for p, t in aenderung.items():
                print(p, *[z for z in t.split("\n") if z.startswith(("| Pflege |", "| Spiegel |"))], sep="\n  ")
            return
        idx = tempfile.mktemp()
        env = dict(os.environ, GIT_INDEX_FILE=idx)
        git("read-tree", basis, env=env)
        for p, t in aenderung.items():
            blob = git("hash-object", "-w", "--stdin", eingabe=t).stdout.strip()
            git("update-index", "--cacheinfo", f"100644,{blob},{p}", env=env)
        baum = git("write-tree", env=env).stdout.strip()
        if os.path.exists(idx):
            os.remove(idx)
        c = git("commit-tree", baum, "-p", basis, "-m", f"Werkzeug: Pflegehinweise {tag} (340.3)").stdout.strip()
        if c and git("push", "-q", "origin", f"{c}:refs/heads/main").returncode == 0:
            print("pflegehinweis: Vorgangsliste neu (Pflege, Spiegel)")
            return

if __name__ == "__main__":
    main()
