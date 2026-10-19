#!/usr/bin/env python3
"""Fords Lauf als Werkzeug (167.2): rechnet, wen Ford startet und was er archiviert; Ford führt nur aus.

Aufruf: python3 tools/lauf.py [--sperre] [--besetzung] [--ohne NR:Grund …] SEITE [SEITE …]
SEITE = gespeicherte Ausgabe von list_sessions (mine, alle Seiten bis has_more falsch, wie bei kosten.py)
  ODER Kurzform (Datei mit einer Zeile je Sitzung, kein Abschreiben der Seiten nötig, 167.2):
  `Kennung | working|idle|blocked|need_input|archived | updated_at (ISO) | Titel | Kosten $ (oder -)`
Ausgabe, Zeile für Zeile auszuführen:
  START <Rolle> | model | environment_id | source_url | Titel | erste Nachricht   → create_session mit allen Feldern, source_url Pflicht (187) (Startsperre vorher pushen: --sperre schreibt sie)
  ARCHIVIERE <session_id> | <Rolle> | <Kosten $> | <Vorgang>        → archive_session, danach --kosten (siehe unten)
  NICHTS <Rolle>: Grund                                             → nichts tun
  WARNUNG …                                                         → Ford meldet es lautlos
  WARNUNG-LAUT …                                                    → Ford meldet es mit --laut (190.7: dieselbe Warnung zum zweiten Mal)
  AUSGESCHLOSSEN NR: Grund                                          → Ford hat die Zeile mit --ohne ausgeschlossen; Ford meldet Grund lautlos (190.2)
--ohne NR:Grund  (mehrfach) schließt die Zeile NR für diesen Lauf aus; lauf.py nimmt dann die nächste startbare Zeile derselben Rolle (190.2). Ohne Grund gilt es nicht.
--sperre     trägt „Startsperre HH:MM Start <Name>“ ins Protokoll von ARBEIT-BETRIEB.md (Ford pusht, erst dann create_session).
--besetzung  schreibt ARBEIT-BESETZUNG.md neu (nur Tabelle und Stand); schreibt nur, wenn sich die Tabelle ändert.
--kosten NR USD  addiert USD auf die Kostenspalte der Zeile NR in LISTE-VORGAENGE.md oder -ARCHIV.md (Ford ruft es je ARCHIVIERE-Zeile).
Regeln (LISTE-BETRIEB.md, ROLLE-BETRIEB.md): Tom, Jerry, Diogenes, Homer, Perikles: Muss vor Kür, Kür vor Leerlauf (196); Sokrates, Ford, Ford 2 nie.
Nachfolger (190.7): nennt die Übergabe im Vorrat „Nachfolger: <Titel>“ und gibt es seither keine Sitzung der Rolle, startet lauf.py diese (vor Muss und Kür,
auch bei Homer, Perikles); ein Datum in der Zukunft im Titel schiebt den Start, „keiner“ und „nur wenn …“ lassen die Zeilenregel gelten. Kann sie nicht starten
(Pause, Titel ohne Zeit in der Übergabe), steht WARNUNG mit Grund; beim zweiten Lauf mit derselben Übergabe WARNUNG-LAUT (Protokollzeile „Nachfolger-Warnung“, --sperre schreibt sie).
„Wartet auf Chef“ und Dateien der Chefsache halten nur die Sitzung dieser Zeile (190.4): passt die Nummer im Titel nicht, wird die Sitzung nicht festgehalten und die Rolle nicht belegt;
Sitzungen ohne Nummer im Titel hält jede Frage ihrer Rolle (vorsichtshalber).
Laufend = Status working/blocked und updated_at jünger als 60 Minuten. Fertig (158) = nicht laufend, seit 20 Minuten ruhig, kein Hindernis
(keine eigene Datei in chefsache/entscheiden, keine Zeile des Vorrats „wartet auf Chef“, nicht need_input). Hindernis oder laufend: Rolle belegt, kein zweiter Start.
Nicht Sache des Werkzeugs: „Neustart <Name>, <Commit>“ (Nachricht), Wochenstart, Tagesrückblick, Meldungen, Eingang (bleiben bei Ford).
"""
import os, re, sys, datetime, zoneinfo
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar, kosten

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
# Notizen liegen nur auf main (CLAUDE.md): auch aus der Arbeitskopie immer dort schreiben, nie die Arbeitskopie (15:03-Lauf 18.10.: Zähler und Besetzung überschrieben)
_haupt = os.path.join(ROOT, "..", "bornim-main", "docs")
DOCS = _haupt if os.path.isdir(_haupt) and "bornim-main" not in os.path.abspath(ROOT) else startbar.DOCS
startbar.DOCS = DOCS
BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")
JETZT = datetime.datetime.now(BERLIN)
MITTEL = "env_01F9WxikYD4TTdhscxvPi93p"
REPO = "https://github.com/tramour-cmyk/androidapp_rpg_bornim"  # ohne source_url startet die Sitzung ohne Repo (18.10., Jerry 39; 187)
MODELL = {"Tom": "opus", "Homer": "opus", "Sokrates": "opus", "Jerry": "opus", "Perikles": "sonnet", "Diogenes": "sonnet"}
VORRAT = {"Homer": "ARBEIT-KREATIV.md", "Tom": "ARBEIT-TEAM-TOM.md", "Jerry": "ARBEIT-TEAM-JERRY.md",
          "Perikles": "ARBEIT-PROJEKT.md", "Diogenes": "ARBEIT-PRUEFUNG.md", "Sokrates": "ARBEIT-BERATUNG.md"}
START_REIHE = ["Tom", "Jerry", "Diogenes", "Homer", "Perikles"]
MIT_KUER = {"Tom", "Jerry", "Diogenes", "Homer", "Perikles"}
NIE_ARCHIV = {"Ford", "Ford 2", "Sokrates", "Sonstige"}  # Ford, Wache, Sokrates (Altsitzung hält Ford von Hand), Unbekanntes
SPERRE_MIN = 20

def z(s):
    return datetime.datetime.fromisoformat(s.replace("Z", "+00:00")).astimezone(BERLIN)

def lesen(p):
    return open(p, encoding="utf-8").read()

def berlin(d):
    return d.strftime("%d.%m., %H:%M")

def startmarken():
    """Rolle → letzter Startzeitpunkt aus „Startsperre HH:MM Start <Name>“ im Protokoll (Datum: heute, sonst gestern)."""
    aus = {}
    for l in lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")).splitlines():
        m = re.search(r"Startsperre (\d\d):(\d\d) Start (Ford 2|\w+)", l)
        if not m: continue
        d = JETZT.replace(hour=int(m.group(1)), minute=int(m.group(2)), second=0, microsecond=0)
        if d > JETZT: d -= datetime.timedelta(days=1)
        aus[m.group(3)] = d
    return aus

def chefdateien_je_rolle():
    d = os.path.join(DOCS, "chefsache", "entscheiden")
    aus = {}
    for n in (os.listdir(d) if os.path.isdir(d) else []):
        zeilen = [x for x in lesen(os.path.join(d, n)).splitlines() if x.strip()]
        if len(zeilen) > 1:
            r = zeilen[1].split(" · ")[0].strip()
            aus.setdefault(r, []).append(n)
    return aus

def stand():
    """Rolle → (Muss-Liste, Kür-Liste, Pause, Chef-Nummern) aus den Vorräten; Listen = alle startbaren Zeilen in Vorratsreihenfolge."""
    chef = startbar.chefdateien()
    aus = {}
    for datei, rolle in startbar.ROLLEN:
        inhalt = startbar.lesen(datei)
        zs = startbar.hochstufen([x for x in startbar.zeilen(inhalt) if x[1] not in ("–", "-")])
        sperr = {x[0]: startbar.blocker(x[0], x[3], chef, x[2]) for x in zs}
        zs = [x for x in zs if sperr[x[0]] != "ERLEDIGT"]
        muss = [x for x in zs if x[1] == "M" and not sperr[x[0]]]
        kuer = [x for x in zs if x[1] != "M" and not sperr[x[0]]]
        wartet = [x[0] for x in zs if (sperr[x[0]] or "").startswith("Chef")]
        aus[rolle] = (muss, kuer, startbar.pause(inhalt), wartet)
    return aus

def gleich(a, b):
    """Gleicher Vorgang oder Unterpunkt (72u.1 ~ 72u ~ 72), Punkte egal; 7 ist nicht 72."""
    a = a.replace(".", "").lower(); b = b.replace(".", "").lower()
    if a == b: return True
    k, l = sorted((a, b), key=len)
    return bool(k) and l.startswith(k) and not l[len(k)].isdigit()

def dateinummer(name):
    """„190-ford-grenze.md“ → 190; „t31-kampf…md“ → t31."""
    return re.split(r"[-_. ]", name, 1)[0]

def haelt(nr_sitzung, nummern):
    """Hält eine Frage (Nummern der Zeilen/Dateien) diese Sitzung? Ohne Nummer im Titel: ja, vorsichtshalber (190.4)."""
    if not nummern: return False
    if not nr_sitzung: return True
    return any(gleich(nr_sitzung, n) for n in nummern)

NACHFOLGER = re.compile(r"Nachfolger:\*{0,2}\s*(.+)")
UEBERGABE = re.compile(r"Übergabe \((\d\d)\.(\d\d)\.,? (\d\d):(\d)([\dx])")

def nachfolger(rolle):
    """(Titel, Übergabezeit, Rohtext) aus der Übergabe im Vorrat, sonst (None, None, Grund); Titel None + Grund „bedingt“ lässt die Zeilenregel gelten."""
    inhalt = startbar.lesen(VORRAT[rolle])
    for l in inhalt.splitlines()[:30]:
        if "Übergabe" not in l or "Nachfolger:" not in l: continue
        m = UEBERGABE.search(l)
        zeit = None
        if m:
            try: zeit = datetime.datetime(JETZT.year, int(m.group(2)), int(m.group(1)), int(m.group(3)), int(m.group(4) + ("9" if m.group(5) == "x" else m.group(5))), tzinfo=BERLIN)
            except ValueError: pass
        roh = NACHFOLGER.search(l).group(1).strip()
        roh = re.split(r"\.(?=\s+[A-ZÄÖÜ„*]|\s*$)", roh, maxsplit=1)[0].strip(" *„“\"")
        if re.match(r"keine[rn]?\b", roh, re.I): return None, zeit, "keiner"
        if re.search(r"\b(nur wenn|falls|sobald|bis )", roh, re.I): return None, zeit, "bedingt: " + roh[:60]
        if not re.match(r"(%s)\b" % "|".join(MODELL), roh): roh = "%s – %s" % (rolle, roh)
        return roh, zeit, roh
    return None, None, "keine Übergabe mit Nachfolger"

def titel_datum(titel):
    """Erstes TT.MM. im Titel, wenn es in der Zukunft liegt, sonst None."""
    for m in re.finditer(r"(?<!\d)(\d\d?)\.(\d\d)\.", titel):
        try: d = startbar.jahr_von(int(m.group(1)), int(m.group(2)))
        except ValueError: continue
        if d > JETZT.date(): return "%02d.%02d." % (d.day, d.month)
    return None

def warnungen_bekannt():
    """Zeilen „Nachfolger-Warnung <Rolle> (Übergabe …)“ im Protokoll."""
    return [l for l in lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")).splitlines() if "Nachfolger-Warnung" in l]

def nummer_aus_titel(t):
    m = re.search(r"–\s*([0-9][0-9a-zA-Z.]*)", t)
    return m.group(1).rstrip(".") if m else ""

def main():
    a = sys.argv[1:]
    if a[:1] == ["--kosten"]:
        return kosten_addieren(a[1], float(a[2].replace(",", ".")))
    sperre = "--sperre" in a; besetz = "--besetzung" in a
    ausschluss = {}
    for i, x in enumerate(a):
        if x == "--ohne" and i + 1 < len(a):
            nr, _, grund = a[i + 1].partition(":")
            if grund.strip(): ausschluss[nr.strip()] = grund.strip()
            else: print("WARNUNG --ohne %s ohne Grund ignoriert (190.2)" % nr)
    seiten = [x for i, x in enumerate(a) if not x.startswith("--") and not (i and a[i - 1] == "--ohne")]
    if not seiten: sys.exit(__doc__)
    offen = []; alle = {}
    for p in seiten:
        for s in kosten.sitzungen(p, offen): alle[s["id"]] = s
    ausgabe = []; archiviert = set()
    if offen: ausgabe.append("WARNUNG Seite abgeschnitten (has_more) in %s: Plan unvollständig, weitere Seite holen" % ", ".join(offen))
    leb = [s for s in alle.values() if s.get("session_status") != "SESSION_STATUS_ARCHIVED"]
    st = stand(); chefd = chefdateien_je_rolle(); marken = startmarken()
    je_rolle = {}
    for s in leb:
        r = kosten.rolle(s.get("title", ""))
        upd = z(s["updated_at"])
        ruhig = (JETZT - upd).total_seconds() / 60
        bucket = s.get("status_bucket", "")
        laufend = ("WORKING" in bucket or "BLOCKED" in bucket or s.get("session_status") == "SESSION_STATUS_RUNNING") and ruhig < 60
        pts = s.get("post_turn_summary") or s.get("external_metadata", {}).get("post_turn_summary") or {}
        hinder = []
        nr_s = nummer_aus_titel(s.get("title", ""))
        if r in chefd and haelt(nr_s, [dateinummer(n) for n in chefd[r]]): hinder.append("Datei in der Chefsache " + ", ".join(chefd[r][:2]))
        if st.get(r) and haelt(nr_s, st[r][3]): hinder.append("Zeile wartet auf Chef " + ", ".join(st[r][3][:2]))
        if pts.get("status_category") == "need_input": hinder.append("Frage offen (need_input)")
        s["_info"] = (r, laufend, ruhig, hinder)
        je_rolle.setdefault(r, []).append(s)
    # Archivieren
    for r, ss in sorted(je_rolle.items()):
        for s in ss:
            _, laufend, ruhig, hinder = s["_info"]
            if r in NIE_ARCHIV or laufend: continue
            if ruhig < SPERRE_MIN: continue
            if hinder: ausgabe.append("NICHTS %s: %s nicht archiviert, Hindernis: %s" % (r, s["id"], "; ".join(hinder))); continue
            k = s.get("external_metadata", {}).get("usage", {}).get("cost_usd")
            archiviert.add(s["id"])
            ausgabe.append("ARCHIVIERE %s | %s | %s | %s" % (s["id"], r, ("%.2f" % k) if k is not None else "fehlt", nummer_aus_titel(s.get("title", "")) or "Betrieb"))
    # Starten
    for nr, grund in sorted(ausschluss.items()): ausgabe.append("AUSGESCHLOSSEN %s: %s" % (nr, grund))
    sperren = []; neue_warnungen = []
    bekannt = warnungen_bekannt()
    for r in START_REIHE:
        muss, kuer, pause, _ = st.get(r, ([], [], None, []))
        # Hindernis hält nur die Sitzung der Zeile, nicht die Rolle (190.4)
        belegt = [s for s in je_rolle.get(r, []) if s["_info"][1] or s["_info"][2] < SPERRE_MIN]
        nf, nf_zeit, nf_grund = nachfolger(r)
        gestartet = nf_zeit is not None and any(z(s["created_at"]) > nf_zeit for s in alle.values() if kosten.rolle(s.get("title", "")) == r)
        if nf and nf_zeit is None:
            ausgabe.append("WARNUNG Nachfolger %s: Übergabe ohne lesbare Zeit, „%s“ nicht gestartet" % (r, nf)); nf = None
        offen_nf = nf if nf and not gestartet else None
        if pause:
            ausgabe.append("NICHTS %s: Pause bis %s" % (r, pause))
            if offen_nf: warnen(ausgabe, neue_warnungen, bekannt, r, nf_zeit, "Nachfolger „%s“ nicht gestartet, Pause bis %s" % (offen_nf, pause))
            continue
        if belegt: ausgabe.append("NICHTS %s: belegt durch %s" % (r, belegt[0].get("title", belegt[0]["id"]))); continue
        if r in marken and (JETZT - marken[r]).total_seconds() < SPERRE_MIN * 60:
            ausgabe.append("NICHTS %s: Startmarke %s jünger als %d Minuten" % (r, marken[r].strftime("%H:%M"), SPERRE_MIN)); continue
        if offen_nf and titel_datum(offen_nf):
            ausgabe.append("NICHTS %s: Nachfolger „%s“ erst %s; Zeilenregel gilt bis dahin" % (r, offen_nf, titel_datum(offen_nf)))
            offen_nf = None
        if offen_nf:
            thema = re.sub(r"\s*\([^)]*\)\s*$", "", offen_nf)
            titel = "%s (%s)" % (thema, berlin(JETZT))
            msg = "%s\n\nNachfolger laut Übergabe in %s: %s. Zuerst Start nach deiner Rollendatei, dann die Übergabe lesen und dort weiterarbeiten." % (r, VORRAT[r], offen_nf)
            ausgabe.append("START %s | %s | %s | %s | %s | %s" % (r, MODELL[r], MITTEL, REPO, titel, msg.replace("\n", "\\n")))
            sperren.append(r); continue
        muss = [x for x in muss if x[0] not in ausschluss]; kuer = [x for x in kuer if x[0] not in ausschluss]
        wahl = (muss[0] if muss else None) or (kuer[0] if kuer and r in MIT_KUER else None)
        if not wahl: ausgabe.append("NICHTS %s: %s" % (r, "kein startbares Muss" if r not in MIT_KUER else "nichts Startbares")); continue
        nr, kl, thema, _ = wahl
        thema = re.sub(r"\*\*|`", "", thema)
        titel = "%s – %s (%s)" % (r, nr, berlin(JETZT))
        msg = "%s\n\nArbeite Zeile %s (%s) aus deinem Vorrat %s; zuerst Start nach deiner Rollendatei, dann die Zeile lesen und die Übergabe beachten." % (r, nr, "Muss" if kl == "M" else "Kür", VORRAT[r])
        ausgabe.append("START %s | %s | %s | %s | %s | %s" % (r, MODELL[r], MITTEL, REPO, titel, msg.replace("\n", "\\n")))
        sperren.append(r)
    for l in ausgabe: print(l)
    if not ausgabe: print("NICHTS: nichts zu tun")
    if sperre and (sperren or neue_warnungen):
        p = os.path.join(DOCS, "ARBEIT-BETRIEB.md"); t = lesen(p).rstrip("\n")
        if sperren: t += "\n- %s %s: Startsperre %s Start %s (lauf.py)\n" % (JETZT.strftime("%H:%M"), JETZT.strftime("%d.%m."), JETZT.strftime("%H:%M"), ", ".join(sperren))
        for w in neue_warnungen: t += "\n- %s %s: %s (lauf.py)\n" % (JETZT.strftime("%H:%M"), JETZT.strftime("%d.%m."), w)
        open(p, "w", encoding="utf-8").write(t)
        print("Protokoll geschrieben: bitte committen und pushen%s." % (", erst dann create_session" if sperren else ""))
    if besetz: besetzung_schreiben([s for s in leb if s["id"] not in archiviert])

def besetzung_schreiben(leb):
    p = os.path.join(DOCS, "ARBEIT-BESETZUNG.md"); t = lesen(p)
    zeilen = ["| Rolle | Sitzung | Zeile | Zweig | seit |", "|---|---|---|---|---|"]
    for s in sorted(leb, key=lambda x: x["created_at"]):
        r, laufend, ruhig, hinder = s["_info"]
        titel = s.get("title", s["id"])
        if r == "Sonstige" and not titel.startswith("Ford"): continue
        zl = nummer_aus_titel(titel) or "Betrieb"
        zw = (s.get("external_metadata", {}).get("current_branches") or {}).get("") or "–"
        zeilen.append("| %s | [%s](https://claude.ai/code/%s) | %s | %s | %s |" % (r, titel, s["id"], zl, zw, berlin(z(s["created_at"]))))
    tabelle = "\n".join(zeilen)
    neu = re.sub(r"\| Rolle \| Sitzung.*?(?=\n\n|\Z)", lambda m: tabelle, t, count=1, flags=re.S)
    neu_ohne = re.sub(r"\*\*Stand:\*\*[^\n]*", "", neu)
    alt_ohne = re.sub(r"\*\*Stand:\*\*[^\n]*", "", t)
    if neu_ohne == alt_ohne: print("Besetzung unverändert."); return
    neu = re.sub(r"\*\*Stand:\*\*[^\n]*", "**Stand:** %s (lauf.py)" % berlin(JETZT), neu, count=1)
    open(p, "w", encoding="utf-8").write(neu)
    print("Besetzung geschrieben.")

def warnen(ausgabe, neue, bekannt, rolle, zeit, grund):
    """WARNUNG beim ersten Mal, WARNUNG-LAUT, wenn dieselbe Übergabe schon einmal gewarnt hat (190.7)."""
    marke = "Nachfolger-Warnung %s (Übergabe %s)" % (rolle, berlin(zeit))
    if any(marke in l for l in bekannt):
        ausgabe.append("WARNUNG-LAUT Nachfolger %s: %s (zweiter Lauf)" % (rolle, grund))
    else:
        ausgabe.append("WARNUNG Nachfolger %s: %s" % (rolle, grund)); neue.append(marke)

def kosten_addieren(nr, usd):
    ziel = nr
    while ziel:
      for dat in ("LISTE-VORGAENGE.md", "LISTE-VORGAENGE-ARCHIV.md"):  # abgeschlossene Zeilen liegen im Archiv, Kosten gehören trotzdem dorthin
        p = os.path.join(DOCS, dat); L = lesen(p).split("\n")
        for i, l in enumerate(L):
            t = [x.strip() for x in l.split("|")]
            if l.startswith("| ") and len(t) > 7 and t[1] == ziel:
                alt = t[-4]; m = re.fullmatch(r"([\d,.]+)\s*\$", alt) if alt else None
                if m or not alt:
                    t[-4] = ("%.2f" % ((float(m.group(1).replace(",", ".")) if m else 0.0) + usd)).replace(".", ",") + " $"
                else:
                    t[-4] = alt + "; +" + ("%.2f" % usd).replace(".", ",") + " $"
                L[i] = "| " + " | ".join(t[1:-1]) + " |"
                open(p, "w", encoding="utf-8").write("\n".join(L))
                print("Kosten %s: %s" % (ziel, t[-4])); return
      kurz = re.sub(r"(\.\d+[a-z]*|[a-z])$", "", ziel)
      if kurz == ziel: break
      ziel = kurz
    print("WARNUNG Kosten: keine Zeile für %s, bitte von Hand auf Betrieb" % nr)

if __name__ == "__main__":
    main()
