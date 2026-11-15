#!/usr/bin/env python3
"""Rotbuch (1334, Chef 15.11., 21:09: „100-mal rot für irgendwas, weil wir nicht in der Lage sind, aus unseren Fehlern zu lernen
und es so anzupassen, dass es läuft.“): rote Tests der Godot-Läufe der letzten 48 h zählen und Wiederholer selbst zum Vorgang machen.

Quelle: Anmerkungen „918 rot (<Stufe>) tests/<name>.gd“ der Prüfläufe (öffentliche API ohne Anmeldung; Ergebnis je Lauf im Zwischenspeicher
~/.cache/bornim-rotbuch.json, weil die API ohne Anmeldung 60 Abfragen je Stunde erlaubt).
- **wiederholt:** derselbe Test zweimal oder öfter rot binnen 48 h → Muss beim Besitzer des Tests, Titel „… · wiederholt“ (vor Neuem).
- **Wackeltest:** derselbe Test am selben Commit einmal rot und einmal nicht → Muss, Test deterministisch machen (nie abschalten).
- Steht der Test schon im Titel einer offenen Zeile (etwa 1195 hoehle_492), ist er bekannt: kein neuer Vorgang, die Zweige führen ihn
  dort als bekannt. Besitzer des Tests: Rolle im Betreff des Commits, der die Testdatei anlegte („Tom: …“), sonst Ford.

Aufruf: python3 tools/rotbuch.py            Zählung je Test (48 h) und Kandidaten
        python3 tools/rotbuch.py --anlegen  legt die Kandidaten mit vorgang.py neu an (Ford, danach pushen)
        python3 tools/rotbuch.py --kurz     eine Zeile für den Tagesbericht
"""
import datetime, json, os, re, subprocess, sys, urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar

API = "https://api.github.com/repos/tramour-cmyk/androidapp_rpg_bornim/"
STUNDEN = 48
SPEICHER = os.path.expanduser("~/.cache/bornim-rotbuch.json")
ROT = re.compile(r"^918 rot \((\w+)\) (tests/[\w./-]+\.gd)")
ROLLEN = ("Tom", "Jerry", "Spike", "Tuffy", "Homer", "Perikles", "Sokrates", "Diogenes", "Ford")
REPO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")


def holen(pfad):
    return json.load(urllib.request.urlopen(urllib.request.Request(API + pfad, headers={"Accept": "application/vnd.github+json"}), timeout=10))


def laeufe(stunden=STUNDEN):
    seit = (datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(hours=stunden)).strftime("%Y-%m-%dT%H:%M:%SZ")
    aus = []
    for seite in range(1, 6):
        teil = holen("actions/workflows/godot.yml/runs?status=completed&per_page=100&page=%d&created=%%3E%%3D%s" % (seite, seit)).get("workflow_runs") or []
        aus += [l for l in teil if l.get("conclusion") in ("success", "failure")]
        if len(teil) < 100: break
    return aus


def rote_tests(lauf, speicher):
    """Tests mit Anmerkung „918 rot“ im Lauf (leer bei grün); je Lauf einmal abgefragt."""
    if lauf["conclusion"] != "failure": return []
    k = str(lauf["id"])
    if k not in speicher:
        tests = []
        for cr in holen("check-suites/%s/check-runs" % lauf["check_suite_id"]).get("check_runs", []):
            if not cr.get("output", {}).get("annotations_count"): continue
            for a in holen("check-runs/%s/annotations" % cr["id"]):
                m = ROT.match(a.get("message", ""))
                if m and m.group(2) not in tests: tests.append(m.group(2))
        speicher[k] = tests
    return speicher[k]


def zaehlen(ls=None, speicher=None):
    """{Test: {"rot": [(Lauf, Zweig, Commit)], "wackelt": bool}} der letzten 48 h."""
    ls = laeufe() if ls is None else ls
    speicher = {} if speicher is None else speicher
    rot, je_commit = {}, {}
    for l in ls:
        tests = rote_tests(l, speicher)
        je_commit.setdefault(l["head_sha"], []).append(set(tests))
        for t in tests: rot.setdefault(t, []).append((l["run_number"], l.get("head_branch") or "", l["head_sha"][:9]))
    aus = {}
    for t, rs in rot.items():
        # am selben Commit ein Lauf mit dem Test rot und einer ohne (grün oder rot aus anderem Grund)
        wackelt = any(any(t not in s for s in je_commit[sha]) for sha in {l["head_sha"] for l in ls if t in set(speicher.get(str(l["id"]), []))})
        aus[t] = {"rot": rs, "wackelt": wackelt}
    return aus


def besitzer_von_nr(nr):
    for d in startbar.zeilen_liste():
        if d["nr"] == nr: return d["besitzer"]
    try: archiv = open(os.path.join(REPO, "docs", "LISTE-VORGAENGE-ARCHIV.md"), encoding="utf-8").read()
    except OSError: return None
    m = re.search(r"(?m)^\| %s \|(?:[^|]*\|){4}\s*(\w+)\s*\|" % re.escape(nr), archiv)
    return m.group(1) if m else None


def besitzer(test):
    """Rolle im Betreff des Commits, der die Testdatei anlegte („Tom: …“), sonst Besitzer der Nummer dort („416.8 …“), sonst Ford."""
    r = subprocess.run(["git", "-C", REPO, "log", "--diff-filter=A", "--format=%s", "--", "godot/" + test], capture_output=True, text=True)
    zeilen = [z for z in r.stdout.splitlines() if z]
    erst = zeilen[-1] if zeilen else ""
    m = re.match(r"(%s)\b" % "|".join(ROLLEN), erst)
    wer = m.group(1) if m else None
    if not wer and (n := re.match(r"(\d+[a-z]?(?:\.\d+[a-z]?)*)\b", erst)): wer = besitzer_von_nr(n.group(1))
    wer = {"Tuffy": "Jerry"}.get(wer, wer)
    return wer if wer in startbar.BESITZER and wer != "Ideen" else "Ford"


def bekannt(test):
    """Nummer einer offenen Zeile, deren Titel den Test nennt (Dateiname ohne .gd), sonst None."""
    stamm = os.path.basename(test)[:-3]
    for d in startbar.zeilen_liste():
        if d["wort"] != "erledigt" and re.search(r"(?<![\w])%s(?![\w])" % re.escape(stamm), d["titel"]): return d["nr"]
    return None


def kandidaten(zahl=None):
    """[(Test, Besitzer, Titel)] für neue Vorgänge: wiederholt (≥ 2× rot) oder Wackeltest, noch ohne offene Zeile."""
    aus = []
    for t, z in sorted((zahl or {}).items()):
        if len(z["rot"]) < 2 and not z["wackelt"]: continue
        if bekannt(t): continue
        stamm = os.path.basename(t)[:-3]
        laeufe_ = ", ".join("%d" % n for n, _, _ in z["rot"][:6])
        if z["wackelt"]:
            titel = "Von Werkzeug (1334): Wackeltest %s: rot und grün am selben Commit (Läufe %s); deterministisch machen, nie abschalten · wiederholt" % (stamm, laeufe_)
        else:
            titel = "Von Werkzeug (1334): Wiederholrot %s: %d× rot in %d h (Läufe %s); Ursache nachstellen, beheben · wiederholt" % (stamm, len(z["rot"]), STUNDEN, laeufe_)
        aus.append((t, besitzer(t), titel))
    return aus


def speicher_lesen():
    try: return json.load(open(SPEICHER, encoding="utf-8"))
    except (OSError, ValueError): return {}


def speicher_schreiben(s):
    try:
        os.makedirs(os.path.dirname(SPEICHER), exist_ok=True)
        json.dump(s, open(SPEICHER, "w", encoding="utf-8"))
    except OSError: pass


def main():
    s = speicher_lesen()
    try:
        zahl = zaehlen(speicher=s)
    except Exception as e:
        print("ROTBUCH: Netz oder API nicht erreichbar (%s)" % e.__class__.__name__); return 0
    finally:
        speicher_schreiben(s)
    if "--kurz" in sys.argv:
        oben = sorted(zahl.items(), key=lambda x: -len(x[1]["rot"]))[:6]
        print("rote Tests %d h: %s" % (STUNDEN, ", ".join("%s %d×%s" % (os.path.basename(t)[:-3], len(z["rot"]), " (wackelt)" if z["wackelt"] else "") for t, z in oben) or "keine"))
        return 0
    for t, z in sorted(zahl.items(), key=lambda x: -len(x[1]["rot"])):
        print("ROT %s: %d×%s, Läufe %s%s" % (t, len(z["rot"]), " WACKELT" if z["wackelt"] else "", ", ".join(str(n) for n, _, _ in z["rot"]),
                                           (", bekannt in " + bekannt(t)) if bekannt(t) else ""))
    ks = kandidaten(zahl)
    for t, wer, titel in ks:
        if "--anlegen" in sys.argv:
            r = subprocess.run([sys.executable, os.path.join(REPO, "tools", "vorgang.py"), "neu", titel, "E Technik", "M", wer, "--oben"], capture_output=True, text=True)
            print("ANGELEGT %s (%s): %s" % (t, wer, (r.stdout or r.stderr).strip().splitlines()[-1] if (r.stdout or r.stderr).strip() else "?"))
        else:
            print("NEU %s (%s): %s → python3 tools/rotbuch.py --anlegen" % (t, wer, titel))
    return 0


if __name__ == "__main__":
    sys.exit(main())
