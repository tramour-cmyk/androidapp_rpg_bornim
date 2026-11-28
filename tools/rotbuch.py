#!/usr/bin/env python3
"""Rotbuch (1334, Chef 15.11., 21:09: „100-mal rot für irgendwas, weil wir nicht in der Lage sind, aus unseren Fehlern zu lernen
und es so anzupassen, dass es läuft.“): rote Tests der Godot-Läufe der letzten 48 h zählen und Wiederholer selbst zum Vorgang machen.

Quelle: Anmerkungen „918 rot (<Stufe>) tests/<name>.gd“ der Prüfläufe (öffentliche API ohne Anmeldung; Ergebnis je Lauf im Zwischenspeicher
~/.cache/bornim-rotbuch.json, weil die API ohne Anmeldung 60 Abfragen je Stunde erlaubt).
- **wiederholt:** derselbe Test zweimal oder öfter rot binnen 48 h, auf verschiedenen Zweigen oder zweimal auf main/Sammelbuild → Muss beim Besitzer des Tests, Titel „… · wiederholt“ (vor Neuem).
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
BAUTEAMS = ("Tom", "Jerry", "Spike")  # 1399: bauen Spielcode und seine Tests
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
    zeit = {l["run_number"]: l.get("created_at", "") for l in ls}  # 1583: Rot vor der Erledigung zählt nicht
    aus = {}
    for t, rs in rot.items():
        # am selben Commit ein Lauf mit dem Test rot und einer ohne (grün oder rot aus anderem Grund)
        wackelt = any(any(t not in s for s in je_commit[sha]) for sha in {l["head_sha"] for l in ls if t in set(speicher.get(str(l["id"]), []))})
        aus[t] = {"rot": rs, "wackelt": wackelt, "zeit": {n: zeit.get(n, "") for n, _, _ in rs}}
    return aus


def besitzer_von_nr(nr):
    for d in startbar.zeilen_liste():
        if d["nr"] == nr: return d["besitzer"]
    try: archiv = open(os.path.join(REPO, "docs", "LISTE-VORGAENGE-ARCHIV.md"), encoding="utf-8").read()
    except OSError: return None
    m = re.search(r"(?m)^\| %s \|(?:[^|]*\|){4}\s*(?:Team\s+)?(\w+)\s*\|" % re.escape(nr), archiv)
    return m.group(1) if m else None


def grenzen():
    """Grenz-Commits eines flachen Klons (1392): deren Betreff sagt nichts über den Anleger einer Datei."""
    r = subprocess.run(["git", "-C", REPO, "rev-parse", "--git-path", "shallow"], capture_output=True, text=True)
    pfad = r.stdout.strip()
    if pfad and not os.path.isabs(pfad): pfad = os.path.join(REPO, pfad)
    try: return {z.strip() for z in open(pfad, encoding="utf-8") if z.strip()}
    except OSError: return set()


def nr_aus_name(test):
    """Zu 1392: Nummer aus dem Testnamen („ziege_4162“ → 416.2, „pruefliste_1020“ → 1020): erst ganz, dann mit Punkt von rechts.
    1399 (D260.1): jede Zahl im Namen von links („anmarsch_506_1“ → 506, nicht 1), Zahlen unter drei Stellen nur als Zusatz; zählt nur ein
    Besitzer, der Spielcode baut (Tom, Jerry, Spike), sonst nannte die Zahl eine Mutter (399 → Perikles, 870 → Sokrates) und es bleibt Ford."""
    for z in re.findall(r"_(\d{3,})(?=_|$)", os.path.basename(test)[:-3]):
        for k in [z] + [z[:i] + "." + z[i:] for i in range(len(z) - 1, 0, -1)]:
            wer = {"Tuffy": "Jerry"}.get(besitzer_von_nr(k), besitzer_von_nr(k))
            if wer in BAUTEAMS: return wer
    return None


def anleger_netz(test):
    """1399: im flachen Klon den Betreff des ersten Commits der Datei über die öffentliche API (nur für Wiederholer, wenige Abrufe); sonst „“."""
    try:
        alle = []
        for seite in range(1, 6):
            teil = holen("commits?path=godot/%s&per_page=100&page=%d" % (test, seite))
            alle += teil
            if len(teil) < 100: break
        return alle[-1]["commit"]["message"].splitlines()[0] if alle else ""
    except Exception:
        return ""


def besitzer(test):
    """Rolle im Betreff des Commits, der die Testdatei anlegte („Tom: …“), sonst Besitzer der Nummer dort („416.8 …“), sonst Nummer
    im Testnamen, sonst Ford. Im flachen Klon ist der älteste Commit oft nur die Grenze; dann zählt der Name (1392)."""
    r = subprocess.run(["git", "-C", REPO, "log", "--diff-filter=A", "--format=%H %s", "--", "godot/" + test], capture_output=True, text=True)
    zeilen = [z for z in r.stdout.splitlines() if z]
    erst = zeilen[-1] if zeilen else ""
    sha, _, erst = erst.partition(" ")
    if sha in grenzen(): erst = anleger_netz(test)
    try:  # 1739 Rufnamen: „Anna: 1739 …“ zählt beim Besitzer der Nummer dahinter
        import rufname
        if rufname.aus_titel(erst): erst = re.sub(r"^\w+[:,]?\s*", "", erst, count=1)
    except Exception:
        pass
    m = re.match(r"(%s)\b" % "|".join(ROLLEN), erst)
    wer = m.group(1) if m else None
    if not wer and (n := re.match(r"(\d+[a-z]?(?:\.\d+[a-z]?)*)\b", erst)): wer = besitzer_von_nr(n.group(1))
    if not wer: wer = nr_aus_name(test)
    wer = {"Tuffy": "Jerry"}.get(wer, wer)
    return wer if wer in startbar.BESITZER and wer != "Ideen" else "Ford"


def zeile_von_nr(nr, archiv=False):
    """Zeile der Liste; mit archiv=True sonst aus LISTE-VORGAENGE-ARCHIV.md (Nr., Bereich, Besitzer = Fachprofil des Blocks, 1893)."""
    for d in startbar.zeilen_liste():
        if d["nr"] == nr: return d
    if not archiv: return None
    try: zeilen = open(os.path.join(startbar.DOCS, "LISTE-VORGAENGE-ARCHIV.md"), encoding="utf-8").read().splitlines()
    except OSError: return None
    for z in zeilen:
        f = [x.strip() for x in z.split("|")]
        if len(f) > 4 and f[1] == nr:
            block = startbar.block_von(nr, f[3])
            return {"nr": nr, "bereich": f[3], "block": block, "besitzer": startbar.themenbloecke()[0].get(block, "Arbeitsplaner")}
    return None


def ziel(test):
    """1893: (Besitzer, Bereich) des neuen Vorgangs. Alte Liste: besitzer(test), Bereich „E Technik“. Umgestellte Liste (Besitzer =
    Fachprofil des Blocks, `vorgang.py neu` nimmt nur den Bereich): Bereich der Zeile, deren Nummer im Betreff des anlegenden Commits
    oder im Testnamen steht und deren Profil Spielcode baut (kein Büro, kein Arbeitsplaner); sonst Technik."""
    startbar.zeilen_liste()
    if not startbar.NEU: return besitzer(test), "E Technik"
    r = subprocess.run(["git", "-C", REPO, "log", "--diff-filter=A", "--format=%H %s", "--", "godot/" + test], capture_output=True, text=True)
    zeilen = [z for z in r.stdout.splitlines() if z]
    sha, _, erst = (zeilen[-1] if zeilen else "").partition(" ")
    if sha in grenzen(): erst = anleger_netz(test)
    erst = re.sub(r"^[^:–\d]{1,30}(?::|\s–)\s*", "", erst, count=1)  # „Tom: 416 …“, „Anna – 1739 …“
    nrs = [n.group(1)] if (n := re.match(r"(\d+[a-z]?(?:\.\d+[a-z]?)*)\b", erst)) else []
    for z in re.findall(r"_(\d{3,})(?=_|$)", os.path.basename(test)[:-3]):
        nrs += [z] + [z[:i] + "." + z[i:] for i in range(len(z) - 1, 0, -1)]
    for k in nrs:
        d = zeile_von_nr(k, archiv=True)  # 1893: erledigte Mutter steht im Archiv
        if d and d.get("besitzer") not in startbar.BUERO + ["Arbeitsplaner"] and d.get("bereich"): return d["besitzer"], d["bereich"]
    return "Technik", "E Technik"


def bekannt(test):
    """Nummer einer offenen Zeile, deren Titel den Test nennt (Dateiname ohne .gd), sonst None."""
    stamm = os.path.basename(test)[:-3]
    for d in startbar.zeilen_liste():
        if d["wort"] != "erledigt" and re.search(r"(?<![\w])%s(?![\w])" % re.escape(stamm), d["titel"]): return d["nr"]
    return None


def erledigt_seit(test):
    """1583 (Jerry 1578): ISO-Zeit (UTC) der jüngsten Erledigung eines Vorgangs, der den Test im Titel nennt (Liste oder Archiv), sonst ""."""
    stamm = os.path.basename(test)[:-3]
    such = re.compile(r"(?<![\w])%s(?![\w])" % re.escape(stamm))
    nrs = []
    for name in ("LISTE-VORGAENGE.md", "LISTE-VORGAENGE-ARCHIV.md"):
        try: zeilen = open(os.path.join(REPO, "docs", name), encoding="utf-8").read().splitlines()
        except OSError: continue
        for z in zeilen:
            f = [x.strip() for x in z.split("|")]
            if len(f) > 3 and such.search(f[2]) and "erledigt" in z: nrs.append(f[1])
    beste = ""
    for nr in nrs:
        r = subprocess.run(["git", "-C", REPO, "log", "-1", "--format=%cI", "-G", r"^\| %s \|.*erledigt" % re.escape(nr), "--",
                            "docs/LISTE-VORGAENGE.md", "docs/LISTE-VORGAENGE-ARCHIV.md"], capture_output=True, text=True)
        t = (r.stdout or "").strip()
        if t:
            u = datetime.datetime.fromisoformat(t).astimezone(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
            beste = max(beste, u)
    return beste


GEMEINSAM = re.compile(r"^(main|claude/build-\d+)$")


def wiederholt(rs):
    """Zu 1334 (Tom, 15.11., 21:50): zweimal rot zählt nur auf verschiedenen Zweigen oder zweimal auf einem Stand mit main (main,
    Sammelbuild claude/build-<n>); dreimal rot auf demselben alten Teamzweig ohne den Fix von main ist kein Wiederholer (1339)."""
    return len({zw for _, zw, _ in rs}) >= 2 or sum(1 for _, zw, _ in rs if GEMEINSAM.match(zw)) >= 2


def kandidaten(zahl=None):
    """[(Test, Besitzer, Titel)] für neue Vorgänge: wiederholt (≥ 2× rot) oder Wackeltest, noch ohne offene Zeile."""
    aus = []
    for t, z in sorted((zahl or {}).items()):
        if bekannt(t): continue
        seit = erledigt_seit(t)  # 1583: Läufe vor der Erledigung des letzten Vorgangs zum Test zählen nicht
        if seit:
            zt = z.get("zeit", {})
            z = dict(z, rot=[x for x in z["rot"] if zt.get(x[0], "") > seit])
            if not z["rot"]: continue
        if not wiederholt(z["rot"]) and not z["wackelt"]: continue
        stamm = os.path.basename(t)[:-3]
        laeufe_ = ", ".join("%d" % n for n, _, _ in z["rot"][:6])
        if z["wackelt"]:
            titel = "Von Werkzeug (1334): Wackeltest %s: rot und grün am selben Commit (Läufe %s); deterministisch machen, nie abschalten · wiederholt" % (stamm, laeufe_)
        else:
            titel = "Von Werkzeug (1334): Wiederholrot %s: %d× rot in %d h (Läufe %s); Ursache nachstellen, beheben · wiederholt" % (stamm, len(z["rot"]), STUNDEN, laeufe_)
        aus.append((t,) + ziel(t) + (titel,))
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
    for t, wer, bereich, titel in ks:
        if "--anlegen" in sys.argv:
            r = subprocess.run([sys.executable, os.path.join(REPO, "tools", "vorgang.py"), "neu", titel, bereich, "M", wer, "--oben"], capture_output=True, text=True)
            print("ANGELEGT %s (%s): %s" % (t, wer, (r.stdout or r.stderr).strip().splitlines()[-1] if (r.stdout or r.stderr).strip() else "?"))
        else:
            print("NEU %s (%s): %s → python3 tools/rotbuch.py --anlegen" % (t, wer, titel))
    return 0


if __name__ == "__main__":
    sys.exit(main())
