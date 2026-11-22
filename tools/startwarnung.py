#!/usr/bin/env python3
"""Startwarnungen mit festem Besitzer (1642; 340.12 Änderung 1, Chef 18.11., 09:45; ersetzt 340.3, die Pflegezeilen).

Jede Warnung, die beim Start einer Sitzung erscheint (`notiz.sh`, Start-Haken), hat hier genau einen Besitzer. Steht sie länger als
6 Stunden, legt das Werkzeug selbst einen Vorgang bei ihm an („Von Werkzeug (Startwarnung …)“, Kür, Bereich B Abläufe); ist die
Warnung weg, setzt es diesen Vorgang auf „erledigt“. Muster 1 des Rollenspiegels 18.11.: „alle sehen sie, keiner trägt ein“.

  startwarnung.py --zeigen [--alle]   Warnungen mit Besitzer, seit wann und Vorgang (notiz.sh); ohne --alle nur die Wächter
                                      (77, 98, 108, 969, 650.2), Größe und Pflegefehler einmal am Tag (1129 A 7, notiz.sh gibt --alle)
  startwarnung.py --pflegen [--probe] Stand fortschreiben, nach 6 h Vorgang anlegen, gelöste schließen; Commit auf origin/main ohne
                                      Arbeitskopie (eigener Index, wie meldung.sh), bei abgelehntem Push neu gerechnet. --probe: nur
                                      zeigen.

Stand (erstes Auftreten je Warnung, Vorgangsnummer) in `tools/startwarnung-stand.json` auf main. Schlüssel je Warnung fest
(Art und Datei), damit eine Zahl im Text (Bytes) die Uhr nicht neu stellt.
"""
import datetime, json, os, re, subprocess, sys, tempfile, zoneinfo

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")
STAND = "tools/startwarnung-stand.json"
LISTE = "docs/LISTE-VORGAENGE.md"
FRIST_H = 6
GRENZE = 30000  # CLAUDE.md „Vorräte klein halten“, wie neustart-haken.py (1641)

# Fester Besitzer je Datei (1642): Vorrat → Rolle; Rollendatei → Rolle; Story → Homer; sonst Perikles (Abläufe, Listen)
VORRAT = {"ARBEIT-KREATIV.md": "Homer", "ARBEIT-TEAM-TOM.md": "Tom", "ARBEIT-TEAM-JERRY.md": "Jerry", "ARBEIT-TEAM-SPIKE.md": "Spike",
          "ARBEIT-PROJEKT.md": "Perikles", "ARBEIT-PRUEFUNG.md": "Diogenes", "ARBEIT-BERATUNG.md": "Sokrates", "ARBEIT-BETRIEB.md": "Ford",
          "ARBEIT-BESETZUNG.md": "Ford", "ARBEIT-TAGESBERICHT.md": "Perikles"}
ROLLE = {"ROLLE-KREATIV.md": "Homer", "ROLLE-ENTWICKLUNG.md": "Perikles", "ROLLE-PROJEKT.md": "Perikles", "ROLLE-PRUEFUNG.md": "Diogenes",
         "ROLLE-BERATUNG.md": "Sokrates", "ROLLE-BETRIEB.md": "Ford"}
FREMD = {"CLAUDE.md": "Perikles", "LISTE-VORGAENGE.md": "Perikles", "Block": "Perikles", "Testbuilds": "Ford", "startbar.py": "Ford"}
TAGLICH = ("groesse", "regel", "vorrat")  # nur mit --alle (einmal am Tag, 1129 A 7)


# 1646: Archive sind Verlauf, alte Dateinamen darin bleiben stehen (77, 98)
VERLAUF = ("docs/PRUEFBERICHT-ARCHIV.md", "docs/VORGANGSARCHIV.md", "docs/LISTE-VORGAENGE-ARCHIV.md")

def git(*a, eingabe=None, env=None):
    return subprocess.run(["git", "-C", ROOT, *a], capture_output=True, text=True, input=eingabe, env=env, timeout=60)


def jetzt():
    return datetime.datetime.now(BERLIN)


# 1893: an der umgestellten Liste (Kopf ohne Besitzer) ist der Besitzer ein Profil; Rollen wie umstellen.py PROFIL, Homer → Fachprofil
# des Blocks „G Story“, übrige Rollen (Vorräte fallen mit 1727) → Arbeitsplaner. Bereich der Werkzeugzeile: Story bei Story, sonst Abläufe.
PROFIL = {"Diogenes": "Prüfer", "Ford": "Disponent", "Perikles": "Arbeitsplaner"}


def liste_neu(liste):
    import startbar
    return startbar.KOPF_NEU in (liste or "")


def profil(rolle):
    import startbar
    if rolle in PROFIL: return PROFIL[rolle]
    if rolle == "Homer": return startbar.themenbloecke()[0].get(startbar.block_von("", "G Story"), "Arbeitsplaner")
    return rolle if rolle in startbar.profile() else "Arbeitsplaner"


def bereich_von(besitzer):
    import startbar
    story = startbar.themenbloecke()[0].get(startbar.block_von("", "G Story"))
    return "G Story" if besitzer in ("Homer", story) else "B Abläufe"


def besitzer_nr(nr, liste, archiv=""):
    """Besitzer eines Vorgangs aus Liste, sonst Archiv (Spalte Besitzer ist dort die vorletzte); umgestellte Liste: Profil der Zeile."""
    if liste_neu(liste):
        import startbar
        d = next((x for x in startbar.vorgangsliste(liste) if x["nr"] == nr), None)
        if d: return d["besitzer"]
        liste = ""
    m = re.search(r"(?m)^\| %s \|[^|]*\| ([^|]+) \|" % re.escape(nr), liste)
    if m:
        return m.group(1).strip()
    m = re.search(r"(?m)^\| %s \|.*\| ([^|]+) \| [^|]+ \|\s*$" % re.escape(nr), archiv)
    return m.group(1).strip() if m else None


def datei_besitzer(pfad, liste="", archiv=""):
    name = os.path.basename(pfad)
    if name in VORRAT: return VORRAT[name]
    if name in ROLLE: return ROLLE[name]
    if name in FREMD: return FREMD[name]
    if "/chefsache/" in "/" + pfad:
        m = re.match(r"t?(\d+(?:\.\d+)?)", name)
        b = besitzer_nr(m.group(1), liste, archiv) if m else None
        if b and b not in ("Chef", "Ideen"): return {"Team Tom": "Tom", "Team Jerry": "Jerry"}.get(b, b)
    if name.startswith("STORY-"): return "Homer"
    return "Perikles"


def zeige(ref, pfad):
    return git("show", f"{ref}:{pfad}").stdout


def sammeln(ref="origin/main", taeglich=True):
    """[{schluessel, besitzer, code, text}] aller Startwarnungen auf `ref` (dieselben Prüfungen wie früher in notiz.sh);
    taeglich=False: ohne Größe, Pflegefehler, Vorrat (schneller Start-Haken)."""
    aus = []
    liste, archiv = zeige(ref, LISTE), zeige(ref, "docs/LISTE-VORGAENGE-ARCHIV.md")

    neue = liste_neu(liste)  # 1893

    def neu(schluessel, besitzer, code, text):
        aus.append(dict(schluessel=schluessel, besitzer=profil(besitzer) if neue else besitzer, code=code, text=text))

    dateien = git("ls-tree", "--name-only", ref, "docs/").stdout.split()
    # 77: alte Notizdateinamen (Wächter Dokumentnamen, 13.10.)
    alt77 = "BERATER|DIOGENES|LEITBILD|STIL|ENTWICKLUNG|HELDENBAU|BALANCE|ZWISCHENBILD|STORY1|STORY|THEMEN|MERKLISTE|KAPITEL1|OFFEN|SELBST|ABLAEUFE|UMGEBUNG|ARCHIV"
    alt98 = ("ARBEIT-OFFEN|ARBEIT-SELBST|ARBEIT-FORD|ROLLE-BERATER|ROLLE-FORD|ROLLE-ENTWICKLER|ROLLE-TESTER|ROLLE-TEAM|ARBEIT-ABLAEUFE|"
             "ARBEIT-UMGEBUNG|STORY-K1-W|STORY-K1|LISTE-THEMEN|DESIGN-ZWISCHENBILD|LISTE-KAPITEL1")
    for code, muster, ohne in (("77", alt77, None), ("98", alt98, None)):
        for d in dateien:
            if re.fullmatch(r"docs/(%s)\.md" % muster, d):
                neu(f"{code}-datei:{d}", "Perikles", code, f"alte Notizdatei wieder da: {d}; Inhalt in die neue Datei, alte löschen")
        rx = r"(?<![\w-])(%s)\.md" % muster if code == "77" else r"(%s)\.md" % muster
        r = git("grep", "-l", "-P" if code == "77" else "-E", rx, ref, "--", "CLAUDE.md", "docs", "tools", ".claude",
                *[":!" + v for v in VERLAUF], ":!docs/alt", ":!tools/notiz.sh", ":!tools/startwarnung.py")
        for z in r.stdout.split():
            p = z.split(":", 1)[-1]
            if code == "77" and not (p == "CLAUDE.md" or p.startswith(("docs/", "tools/"))): continue
            neu(f"{code}:{p}", datei_besitzer(p, liste, archiv), code, f"alte Dateinamen erwähnt in {p}; neue Namen mit Vorsilbe ROLLE-/DESIGN-/STORY-/LISTE-/ARBEIT-")
    # 108: Bilder in der Chefsache höchstens 60 KB
    for z in git("ls-tree", "-r", "-l", ref, "docs/chefsache/").stdout.splitlines():
        t = z.split(None, 4)
        if len(t) == 5 and t[3].isdigit() and int(t[3]) > 61440 and not t[4].endswith(".md"):
            neu(f"108:{t[4]}", datei_besitzer(t[4], liste, archiv), "108", f"Datei über 60 KB: {t[4]}; verkleinern (800 px, WebP) oder über Telegram (--datei)")
    # 969: Regelwerte veraltet (Team Jerry)
    if os.path.isfile(os.path.join(ROOT, "tools/regelwerte.py")):
        if subprocess.run([sys.executable, os.path.join(ROOT, "tools/regelwerte.py"), "--pruefen"], capture_output=True).returncode:
            neu("969", "Jerry", "969", "docs/LISTE-REGELWERTE.md veraltet; python3 tools/regelwerte.py, committen")
    # 650.2: Inhaltsverzeichnis docs/README.md
    if os.path.isfile(os.path.join(ROOT, "tools/inhalt.py")):
        r = subprocess.run([sys.executable, os.path.join(ROOT, "tools/inhalt.py"), "--kurz"], capture_output=True, text=True)
        for z in r.stdout.splitlines():
            m = re.match(r"\s*- (.*?):\s*(\S+\.md)\s*$", z)
            if m:
                neu(f"650.2:{m.group(2)}", datei_besitzer(m.group(2)), "650.2", f"Inhaltsverzeichnis docs/README.md, {m.group(1)}: {m.group(2)}")
            elif z.strip().startswith("- "):
                neu("650.2:" + z.strip()[2:60], "Perikles", "650.2", "Inhaltsverzeichnis docs/README.md: " + z.strip()[2:])
    if not taeglich:
        return aus_einmal(aus)
    # Größe der Vorräte (30 KB)
    for d in dateien:
        if re.fullmatch(r"docs/ARBEIT-.*\.md", d) and d != "docs/ARBEIT-ARCHIV.md":
            n = len(zeige(ref, d).encode())
            if n > GRENZE:
                neu(f"groesse:{d}", datei_besitzer(d), "Größe", f"{d} hat {n} Bytes (Grenze {GRENZE}), Erledigtes streichen")
    # Pflegefehler (regelcheck --kurz, ohne die Größe, die steht schon oben)
    r = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "regelcheck.py"), "--kurz"], capture_output=True, text=True)
    for z in r.stdout.splitlines():
        if not z.startswith("  - "): continue
        f = z[4:].strip()
        if re.search(r"\d+ Bytes \(Grenze", f): continue
        m = re.match(r"(?:docs/)?([A-Za-z0-9_.-]+?\.(?:md|py))\s*:\s*(.*)", f)
        datei, was = (m.group(1), m.group(2)) if m else (f.split(":")[0], f)
        art = re.sub(r"[\d.,]+", "N", was)[:40]
        neu(f"regel:{datei}:{art}", datei_besitzer(datei), "Pflege", f"{datei}: {was}")
    # 1425: „Zu <Nr>“ zu Erledigtem im Vorrat
    try:
        import vorratspruefung
        zahl = {}
        for a, nr, _, t in vorratspruefung.funde():
            if a == "J": zahl.setdefault(t.split(":")[0], []).append(nr)
        for datei, nrn in zahl.items():
            neu(f"vorrat:{datei}", datei_besitzer(datei), "1425",
                "%s: %d „Zu“ zu Erledigtem (%s), beim Übergeben streichen" % (datei, len(nrn), ", ".join(nrn[:6]) + (" …" if len(nrn) > 6 else "")))
    except Exception:
        pass
    return aus_einmal(aus)


def aus_einmal(aus):
    """je Schlüssel nur einmal"""
    gesehen, ein = set(), []
    for w in aus:
        if w["schluessel"] not in gesehen:
            gesehen.add(w["schluessel"]); ein.append(w)
    return ein


def stand_laden(ref="origin/main"):
    try:
        return json.loads(zeige(ref, STAND) or "{}")
    except ValueError:
        return {}


def seit_text(iso):
    try:
        return datetime.datetime.fromisoformat(iso).astimezone(BERLIN).strftime("%d.%m., %H:%M")
    except (TypeError, ValueError):
        return "?"


def zeigen(alle):
    stand = stand_laden()
    liste = zeige("origin/main", LISTE)
    for w in sammeln(taeglich=alle):
        if not alle and w["schluessel"].split(":")[0] in TAGLICH: continue
        s = stand.get(w["schluessel"], {})
        zusatz = ", seit " + seit_text(s["seit"]) if s.get("seit") else ""
        zusatz += ", Vorgang " + s["vorgang"] if s.get("vorgang") else ""
        b = (liste_neu(liste) and s.get("vorgang") and besitzer_nr(s["vorgang"], liste)) or w["besitzer"]  # 1893: Profil des Vorgangs
        print(f"Warnung ({w['code']}; Besitzer {b}{zusatz}): {w['text']}")


def offen_in_liste(nr, liste):
    m = re.search(r"(?m)^\| %s \|(.*)$" % re.escape(nr), liste)
    return bool(m) and "| erledigt" not in m.group(0)


def zaehler(betrieb):
    m = re.search(r"\*\*Nächste freie Vorgangsnummer: (\d+)\*\*( \(zuletzt [^)]*\))?", betrieb)
    return m


def berechnen(basis, warnungen, zeit):
    """→ ({pfad: neuer Text}, Meldungen). Reine Rechnung auf dem Stand `basis`."""
    import startbar, vorgang
    stand = stand_laden(basis)
    liste = zeige(basis, LISTE)
    betrieb = zeige(basis, "docs/ARBEIT-BETRIEB.md")
    archiv = zeige(basis, "docs/LISTE-VORGAENGE-ARCHIV.md")
    if not liste or not betrieb:
        return {}, []
    neu_stand, meldungen = {}, []
    L = liste.split("\n")
    jetzt_iso = zeit.isoformat(timespec="minutes")
    nummern = set(re.findall(r"(?m)^\| (\d+) \|", liste)) | set(re.findall(r"(?m)^\| (\d+) \|", archiv))
    m = zaehler(betrieb)
    naechste = int(m.group(1)) if m else None
    for w in warnungen:
        k = w["schluessel"]
        s = dict(stand.get(k) or {"seit": jetzt_iso})
        s["besitzer"], s["text"] = w["besitzer"], w["text"][:300]
        if s.get("vorgang") and not offen_in_liste(s["vorgang"], "\n".join(L)):
            s.pop("vorgang")  # Besitzer hat geschlossen, Warnung steht noch: Uhr neu
            s["seit"] = jetzt_iso
        alt = (zeit - datetime.datetime.fromisoformat(s["seit"])).total_seconds() / 3600
        if alt >= FRIST_H and not s.get("vorgang") and naechste is not None:
            while str(naechste) in nummern: naechste += 1
            nr = str(naechste); naechste += 1; nummern.add(nr)
            titel = "Von Werkzeug (Startwarnung %s, 1642, seit %s): %s" % (w["code"], seit_text(s["seit"]), w["text"])
            titel = (titel if len(titel) <= 300 else titel[:297] + " …").replace("|", "/")
            d = dict(nr=nr, titel=titel, besitzer=w["besitzer"], kl="K", stand="startbar", warte=[], zweig="–", build="–",
                     bereich="B Abläufe", kosten="–")
            if liste_neu(liste):  # 1893: Block aus dem Bereich, Zeile ans Ende ihres Blocks (Folge Eilt, Muss, Kür bleibt bei vorgang.py ordnen)
                d["bereich"] = bereich_von(w["besitzer"])
                d["block"] = startbar.block_von(nr, d["bereich"])
                zs = startbar.vorgangsliste("\n".join(L))
                im = [x["i"] for x in zs if x.get("block") == d["block"]]
                ende = (max(im) + 1) if im else ((max(x["i"] for x in zs) + 1) if zs else len(L))
            else:
                _, ende = vorgang.gruppe(L, w["besitzer"])
            L.insert(ende, startbar.zeile_text(d, neu=liste_neu(liste)))
            s["vorgang"] = nr
            meldungen.append(f"{nr} bei {w['besitzer']}: {w['text'][:80]}")
        neu_stand[k] = s
    # gelöste Warnungen: Vorgang des Werkzeugs schließen
    for k, s in stand.items():
        if k in neu_stand or not s.get("vorgang"): continue
        nr = s["vorgang"]
        for i, z in enumerate(L):
            if z.startswith(f"| {nr} |") and "Startwarnung" in z:
                d = next((x for x in startbar.vorgangsliste("\n".join(L)) if x["i"] == i), None)
                if d and d["wort"] not in ("erledigt", "in Arbeit"):
                    d = dict(d, stand="erledigt, Warnung weg (Werkzeug 1642)")
                    L[i] = startbar.zeile_text(d)
                    meldungen.append(f"{nr} erledigt (Warnung weg)")
    # 340.3 fällt weg (340.12 A): alte Pflegezeilen entfernen
    L = [z for z in L if not z.startswith("| Pflege |")]
    aus = {}
    neu_liste = "\n".join(L)
    if neu_liste != liste: aus[LISTE] = neu_liste
    if m and naechste is not None and naechste != int(m.group(1)):
        marke = " (zuletzt %d Werkzeug %s 1642)" % (naechste - 1, zeit.strftime("%d.%m. %H:%M:%S"))
        aus["docs/ARBEIT-BETRIEB.md"] = betrieb.replace(m.group(0), "**Nächste freie Vorgangsnummer: %d**%s" % (naechste, marke), 1)
    text_stand = json.dumps(neu_stand, ensure_ascii=False, indent=1, sort_keys=True) + "\n"
    if text_stand != (zeige(basis, STAND) or ""):
        # nur die Uhr schreiben, wenn sich Schlüssel oder Vorgänge ändern; Text allein (Bytes) ist kein Commit wert
        alt_kern = {k: (v.get("seit"), v.get("vorgang"), v.get("besitzer")) for k, v in stand.items()}
        neu_kern = {k: (v.get("seit"), v.get("vorgang"), v.get("besitzer")) for k, v in neu_stand.items()}
        if alt_kern != neu_kern or aus: aus[STAND] = text_stand
    return aus, meldungen


def anhang():
    """Systemzeilen wie vorgang.zaehler_pushen (957)."""
    text = git("log", "-30", "--format=%B", "origin/main").stdout
    co = next((l for l in text.splitlines() if l.startswith("Co-Authored-By:")), None)
    sid = os.environ.get("CLAUDE_CODE_REMOTE_SESSION_ID", "")
    cs = ("Claude-Session: https://claude.ai/code/session_" + sid[4:]) if sid.startswith("cse_") else None
    return "\n".join(x for x in (co, cs) if x)


def pflegen(probe):
    warnungen = sammeln("origin/main") if probe else None
    for versuch in range(3):
        if git("fetch", "-q", "origin", "main").returncode:
            return
        basis = git("rev-parse", "FETCH_HEAD").stdout.strip()
        if warnungen is None or versuch:
            warnungen = sammeln(basis)
        aenderung, meldungen = berechnen(basis, warnungen, jetzt())
        if probe or not aenderung:
            for x in meldungen: print("startwarnung:", x)
            for p in aenderung: print("startwarnung: ändert", p)
            return
        with tempfile.TemporaryDirectory() as t:
            env = dict(os.environ, GIT_INDEX_FILE=os.path.join(t, "index"))
            git("read-tree", basis, env=env)
            for p, text in aenderung.items():
                blob = git("hash-object", "-w", "--stdin", eingabe=text).stdout.strip()
                git("update-index", "--add", "--cacheinfo", f"100644,{blob},{p}", env=env)
            baum = git("write-tree", env=env).stdout.strip()
        kopf = "Werkzeug: Startwarnungen %s (1642)" % jetzt().strftime("%d.%m., %H:%M")
        if meldungen: kopf += "\n\n" + "\n".join(meldungen)
        a = anhang()
        c = git("commit-tree", baum, "-p", basis, "-m", kopf + ("\n\n" + a if a else "")).stdout.strip()
        if c and git("push", "-q", "origin", f"{c}:refs/heads/main").returncode == 0:
            for x in meldungen: print("startwarnung:", x)
            return


if __name__ == "__main__":
    a = sys.argv[1:]
    if "--pflegen" in a:
        pflegen("--probe" in a)
    else:
        zeigen("--alle" in a)
