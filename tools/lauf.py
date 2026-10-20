#!/usr/bin/env python3
"""Fords Lauf als Werkzeug (167.2): rechnet, wen Ford startet und was er archiviert; Ford führt nur aus.

Aufruf: python3 tools/lauf.py [--sperre] [--besetzung] [--nur-muss] [--ohne NR:Grund …] SEITE [SEITE …]
SEITE = gespeicherte Ausgabe von list_sessions (mine, alle Seiten bis has_more falsch, wie bei kosten.py)
  ODER Kurzform (Datei mit einer Zeile je Sitzung, kein Abschreiben der Seiten nötig, 167.2):
  `Kennung | working|idle|blocked|need_input|archived | updated_at (ISO) | Titel | Kosten $ (oder -)`
Ausgabe, Zeile für Zeile auszuführen:
  START <Rolle> | model | environment_id | source_url | Titel | erste Nachricht   → create_session mit allen Feldern, source_url Pflicht (187) (Startsperre vorher pushen: --sperre schreibt sie)
  ARCHIVIERE <session_id> | <Rolle> | <Kosten $> | <Vorgang>        → archive_session, danach --kosten (siehe unten)
  NICHTS <Rolle>: Grund                                             → nichts tun
  WARNUNG …                                                         → Ford meldet es lautlos
  WARNUNG-LAUT …                                                    → Ford meldet es mit --laut (190.7: dieselbe Warnung zum zweiten Mal)
  STILLSTAND <Rolle>: …                                             → Ford schreibt die Protokollzeile „Stillstand <Rolle> seit HH:MM“ (Schritt 5, 192.2)
  VORRAT-LEER: …                                                    → Ford meldet es einmal am Tag (Schritt 9, 192.2)
  WOCHENSTART TT.MM. | Rolle | Titel | erste Nachricht                  → Ford startet wie START (Schritt 11, 192.2); Marke „Wochenstart TT.MM. Rolle“ schreibt --sperre
  RUECKBLICK TT.MM. | Perikles | Titel | erste Nachricht                  → dasselbe für Tagesrückblick 20.–22.10. und Bilanz 23.10. (Marke „Rückblick TT.MM.“)
  AUSGESCHLOSSEN NR: Grund                                          → Ford hat die Zeile mit --ohne ausgeschlossen; Ford meldet Grund lautlos (190.2)
--ohne NR:Grund  (mehrfach) schließt die Zeile NR für diesen Lauf aus; lauf.py nimmt dann die nächste startbare Zeile derselben Rolle (190.2). Ohne Grund gilt es nicht.
--nur-muss   startet nur Muss, keine Kür und nichts „nach dem Meilenstein“ (D31.3: Ford setzt es bei `allowed_warning` vor Wochenmitte, D20.2).
--sperre     trägt „Startsperre HH:MM Start <Name>“ ins Protokoll von ARBEIT-BETRIEB.md (Ford pusht, erst dann create_session).
--morgen     gibt die Morgenmeldung als fertigen Text aus (192.2, Schritt 10).
--besetzung  schreibt ARBEIT-BESETZUNG.md neu (nur Tabelle und Stand); schreibt nur, wenn sich die Tabelle ändert.
--kosten NR USD [SESSION_ID]  addiert USD auf die Kostenspalte der Zeile NR in LISTE-VORGAENGE.md oder -ARCHIV.md (Ford ruft es je ARCHIVIERE-Zeile, mit der Kennung).
  Mit Kennung gilt das Buchungsverzeichnis docs/KOSTEN-GEBUCHT.tsv (191): gebucht wird nur die Differenz zu früher Gebuchtem, damit wieder geöffnete oder doppelt archivierte Sitzungen nichts doppelt kosten.
Offene „M?“ aller Vorräte erscheinen als eine Muss-Zeile „M? entscheiden: …“ im Plan für Perikles (190.8).
Jeder Lauf hängt die WARNUNG-Zeilen von abgleich.py an (191).
Regeln (LISTE-BETRIEB.md, ROLLE-BETRIEB.md): Tom, Jerry, Diogenes, Homer, Perikles: Muss vor Kür, Kür vor Leerlauf (196), danach Zeilen „nach dem Meilenstein“ (190.10); Sokrates, Ford, Ford 2 nie.
Nachfolger (190.7): nennt die Übergabe im Vorrat „Nachfolger: <Titel>“ und gibt es seither keine Sitzung der Rolle, startet lauf.py diese (vor Muss und Kür,
auch bei Homer, Perikles); ein Datum in der Zukunft im Titel schiebt den Start, „keiner“ und „nur wenn …“ lassen die Zeilenregel gelten. Kann sie nicht starten
(Pause, Titel ohne Zeit in der Übergabe), steht WARNUNG mit Grund; beim zweiten Lauf mit derselben Übergabe WARNUNG-LAUT (Protokollzeile „Nachfolger-Warnung“, --sperre schreibt sie).
„Wartet auf Chef“ und Dateien der Chefsache halten nur die Sitzung dieser Zeile (190.4): passt die Nummer im Titel nicht, wird die Sitzung nicht festgehalten und die Rolle nicht belegt;
Sitzungen ohne Nummer im Titel hält jede Frage ihrer Rolle (vorsichtshalber).
Laufend = Status working/blocked und updated_at jünger als 60 Minuten. Fertig (158) = nicht laufend, seit 60 Minuten ruhig (238; Start-Sperre und Belegung weiter 20), kein Hindernis
(keine eigene Datei in chefsache/entscheiden, keine Zeile des Vorrats „wartet auf Chef“, nicht need_input). Hindernis oder laufend: Rolle belegt, kein zweiter Start.
Nicht Sache des Werkzeugs: „Neustart <Name>, <Commit>“ (Nachricht), Wochenstart, Tagesrückblick, Meldungen, Eingang (bleiben bei Ford).
"""
import os, re, sys, datetime, zoneinfo, subprocess
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
NIE_ARCHIV = {"Ford", "Ford 2"}  # Ford, Wache; Sokrates und Sonstige nach eigener Regel (197)
SPERRE_MIN = 20
ARCHIV_MIN = 60  # 238: der Chef antwortet oft erst nach Minuten im alten Gespräch; eine archivierte Sitzung nimmt nichts mehr an

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
    aus = {}; m_fragen = []
    for datei, rolle in startbar.ROLLEN:
        inhalt = startbar.lesen(datei)
        zs = startbar.hochstufen([x for x in startbar.zeilen(inhalt) if x[1] not in ("–", "-")])
        sperr = {x[0]: startbar.blocker(x[0], x[3], chef, x[2]) for x in zs}
        zs = [x for x in zs if sperr[x[0]] != "ERLEDIGT"]
        muss = [x for x in zs if x[1] == "M" and not sperr[x[0]]]
        kuer = [x for x in zs if x[1] != "M" and not sperr[x[0]]]
        kuer += [(x[0], "N", x[2], x[3]) for x in zs if sperr[x[0]] == "nach dem Meilenstein"]  # 190.10: letzte Stufe vor Leerlauf
        wartet = [x[0] for x in zs if (sperr[x[0]] or "").startswith("Chef")]
        aus[rolle] = (muss, kuer, startbar.pause(inhalt), wartet)
        offen_m = [x[0] for x in zs if x[1] == "M?" and not sperr[x[0]]]
        if offen_m: m_fragen.extend("%s (%s)" % (n, rolle) for n in offen_m)
    if m_fragen and "Perikles" in aus:  # 190.8: offene „M?“ als eine Muss-Zeile für Perikles, alle in einem Zug
        z = ("M?", "M", "M? entscheiden: " + ", ".join(m_fragen) + " (190.8: je Vorgang M oder K mit einem Satz Grund)", "")
        aus["Perikles"][0].insert(0, z)
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

def uebergabe_stand(bis):
    """Inhalt von ARBEIT-BERATUNG.md, wie er zum Zeitpunkt `bis` (datetime) auf main stand; sonst der aktuelle (197.1)."""
    repo = os.path.dirname(DOCS)
    try:
        h = subprocess.run(["git", "-C", repo, "log", "-1", "--before=" + bis.isoformat(), "--format=%H", "--", "docs/" + VORRAT["Sokrates"]],
                           capture_output=True, text=True, timeout=30).stdout.strip()
        if h: return subprocess.run(["git", "-C", repo, "show", h + ":docs/" + VORRAT["Sokrates"]], capture_output=True, text=True, timeout=30, check=True).stdout
    except (OSError, subprocess.SubprocessError): pass
    return ""

def kosten_auf(bis=None):
    """Nummern aus „Kosten auf: …“ in der Übergabe von ARBEIT-BERATUNG.md (197); mit `bis` die Übergabe der Sitzung selbst (Stand vor dem Start des Nachfolgers, 197.1), sonst []."""
    inhalt = uebergabe_stand(bis) if bis else startbar.lesen(VORRAT["Sokrates"])
    for l in inhalt.splitlines()[:30]:
        if "Übergabe" in l and "Kosten auf:" in l:
            roh = re.split(r"Kosten auf:\**", l, maxsplit=1)[1]
            roh = re.split(r"\.\s|Nachfolger", roh, maxsplit=1)[0]
            return re.findall(r"\d+[a-z]*(?:\.\d+[a-z]*)*", roh)
    return []

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
    if a[:1] == ["--morgen"]:
        return morgenmeldung()
    if a[:1] == ["--kosten"]:
        return kosten_addieren(a[1], float(a[2].replace(",", ".")), a[3] if len(a) > 3 else None)
    nur_muss = "--nur-muss" in a
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
        if st.get(r) and haelt(nr_s, st[r][3]): hinder.append("Vorgang wartet auf Chef " + ", ".join(st[r][3][:2]))
        if pts.get("status_category") == "need_input": hinder.append("Frage offen (need_input)")
        s["_info"] = (r, laufend, ruhig, hinder)
        je_rolle.setdefault(r, []).append(s)
    # 191: Sitzungen mit Kosten, aber ohne Vorgangsnummer im Titel, lassen sich nicht buchen
    for s in leb:
        r = s["_info"][0]
        k = s.get("external_metadata", {}).get("usage", {}).get("cost_usd")
        if r in ("Ford", "Ford 2", "Sonstige", "Sokrates") or not k or k < 0.5 or nummer_aus_titel(s.get("title", "")): continue
        ausgabe.append("WARNUNG Abgleich: Sitzung %s „%s“ (%s, %.2f $) ohne Vorgangsnummer im Titel, Kosten nicht buchbar" % (s["id"], s.get("title", ""), r, k))
    # Archivieren
    for r, ss in sorted(je_rolle.items()):
        for s in ss:
            _, laufend, ruhig, hinder = s["_info"]
            if laufend: continue
            if r == "Sokrates":  # 197 (1): erst wenn ein Nachfolger läuft und die alte Sitzung 60 Minuten ruhig ist; Kosten auf die Nummern der Übergabe
                neuere = [x for x in ss if x is not s and z(x["created_at"]) > z(s["created_at"])]
                if ruhig < 60 or not neuere: continue
                if any("need_input" in h for h in s["_info"][3]):
                    ausgabe.append("NICHTS Sokrates: %s nicht archiviert, Frage offen (need_input)" % s["id"]); continue
                nrn = kosten_auf(min(z(x["created_at"]) for x in neuere))
                if not nrn: ausgabe.append("WARNUNG Sokrates %s ruht, aber die Übergabe in %s nennt keine „Kosten auf: <Nummern>“ (197): nicht archiviert" % (s["id"], VORRAT["Sokrates"])); continue
                k = s.get("external_metadata", {}).get("usage", {}).get("cost_usd")
                archiviert.add(s["id"])
                ausgabe.append("ARCHIVIERE %s | %s | %s | %s" % (s["id"], r, ("%.2f" % k) if k is not None else "fehlt", ",".join(nrn)))
                continue
            if r == "Sonstige":  # 197 (2): vom Chef gestartete Sitzungen nach 12 Stunden Ruhe; Nummer im Titel, sonst Betrieb
                if ruhig < 720 or s.get("title", "").startswith("Ford"): continue  # Ford-Wache bleibt
                if s["_info"][3]: continue
                k = s.get("external_metadata", {}).get("usage", {}).get("cost_usd")
                archiviert.add(s["id"])
                ausgabe.append("ARCHIVIERE %s | %s | %s | %s" % (s["id"], r, ("%.2f" % k) if k is not None else "fehlt", nummer_aus_titel(s.get("title", "")) or "Betrieb"))
                continue
            if r in NIE_ARCHIV: continue
            if ruhig < ARCHIV_MIN: continue
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
        wahl = (muss[0] if muss else None) or (kuer[0] if kuer and r in MIT_KUER and not nur_muss else None)
        if not wahl: ausgabe.append("NICHTS %s: %s" % (r, "kein startbares Muss" if r not in MIT_KUER else "nichts Startbares")); continue
        nr, kl, thema, _ = wahl
        thema = re.sub(r"\*\*|`", "", thema)
        titel = "%s – %s (%s)" % (r, nr, berlin(JETZT))
        msg = "%s\n\nArbeite Vorgang %s (%s) aus deinem Vorrat %s; zuerst Start nach deiner Rollendatei, dann den Vorgang lesen und die Übergabe beachten." % (r, nr, "Muss" if kl == "M" else "nach dem Meilenstein" if kl == "N" else "Kür", VORRAT[r])
        ausgabe.append("START %s | %s | %s | %s | %s | %s" % (r, MODELL[r], MITTEL, REPO, titel, msg.replace("\n", "\\n")))
        sperren.append(r)
    vorentscheid_marken = []
    try:
        import abgleich
        # 191: Notizen gegeneinander, nur WARNUNG; Vorentscheid-Warnungen (194.1, D33.2) einmal, beim zweiten Lauf WARNUNG-LAUT (Marke im Protokoll)
        bisher = lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md"))
        for l in abgleich.pruefen():
            if "Vorentscheid" in l:
                schluessel = re.sub(r"\s+", " ", l[len("WARNUNG Abgleich: "):][:60])
                if ("Marke Abgleich " + schluessel) in bisher: l = l.replace("WARNUNG ", "WARNUNG-LAUT ", 1)
                else: vorentscheid_marken.append("Abgleich " + schluessel)
            ausgabe.append(l)
    except Exception as e:
        ausgabe.append("WARNUNG abgleich.py fehlgeschlagen: %s" % e)
    # 192.2, Schritt 5: startbares Muss, aber weder gestartet noch belegt/Pause/Startmarke/Nachfolger-Termin → STILLSTAND (Ford schreibt die Protokollzeile)
    for r in START_REIHE:
        muss = st.get(r, ([], [], None, []))[0]
        if not muss or any(l.startswith(("START %s " % r, "NICHTS %s: belegt" % r, "NICHTS %s: Pause" % r, "NICHTS %s: Startmarke" % r, "NICHTS %s: Nachfolger" % r)) for l in ausgabe): continue
        ausgabe.append("STILLSTAND %s: Muss %s ohne Sitzung, Protokollzeile „Stillstand %s seit %s“" % (r, muss[0][0], r, JETZT.strftime("%H:%M")))
    # 192.2, Schritt 9: alle Vorräte leer (Muss, Kür, „nach dem Meilenstein“) → Ford meldet einmal am Tag „Vorrat leer“
    if st and all(not st[r][0] and not st[r][1] for r in st if r != "Sokrates"):
        ausgabe.append("VORRAT-LEER: kein startbares Muss, keine Kür, nichts „nach dem Meilenstein“; Ford meldet einmal am Tag „Vorrat leer“")
    # 192.2, Schritt 11: Wochenstart (Mo ab 8 Uhr) und Tagesrückblick (20.–22.10., Bilanz 23.10.), je einmal laut Marke im Protokoll
    marke_text = lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")); heute = JETZT.strftime("%d.%m.")
    wochen = []
    if JETZT.hour >= 8:
        per_belegt = any(s["_info"][1] or s["_info"][2] < SPERRE_MIN for s in je_rolle.get("Perikles", []))
        def einmal(marke, zeile):
            if marke in marke_text: return
            if per_belegt and "| Perikles |" in zeile:
                ausgabe.append("NICHTS Perikles: %s wartet, Perikles läuft (149a)" % marke); return
            ausgabe.append(zeile); wochen.append(marke)
        if JETZT.weekday() == 0 and JETZT.date() >= datetime.date(2026, 10, 26):  # 19.10. ohne Wochenstart (Protokoll 08:06), Wochenzählung erstmals 26.10.
            m = "Wochenstart %s" % heute
            einmal(m + " Perikles", "WOCHENSTART %s | Perikles | Perikles – Wochenziel %s | Perikles Wochenziel" % (heute, heute))
            if True:
                einmal(m + " Diogenes", "WOCHENSTART %s | Diogenes | Diogenes – Wochenzählung %s | Diogenes Wochenzählung (Zeile in ARBEIT-PRUEFUNG.md)" % (heute, heute))
        if (JETZT.month, JETZT.day) in ((10, 20), (10, 21), (10, 22)):
            einmal("Rückblick %s" % heute, "RUECKBLICK %s | Perikles | Perikles – Tagesrückblick %s | Perikles Tagesrückblick" % (heute, heute))
        elif (JETZT.month, JETZT.day) == (10, 23):
            einmal("Rückblick %s" % heute, "RUECKBLICK %s | Perikles | Perikles – Bilanz Tagesrückblick | Perikles Bilanz Tagesrückblick" % heute)
    # 194.2: Datei eines anderen in der Chefsache ohne „Stellungnahme Sokrates“ → Sokrates starten, höchstens zweimal am Tag (Marke im Protokoll)
    d = os.path.join(DOCS, "chefsache", "entscheiden"); ohne = []
    for n in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        txt = lesen(os.path.join(d, n)); zl = [x for x in txt.splitlines() if x.strip()]
        if len(zl) > 1 and not zl[1].startswith("Sokrates") and "Stellungnahme Sokrates" not in txt: ohne.append(n)
    if ohne:
        heute_n = marke_text.count("Marke Stellungnahme Sokrates %s" % heute)
        if any(s["_info"][1] or s["_info"][2] < SPERRE_MIN for s in je_rolle.get("Sokrates", [])):
            ausgabe.append("NICHTS Sokrates: Stellungnahme zu %s wartet, Sokrates läuft" % ", ".join(ohne[:3]))
        elif heute_n >= 2:
            ausgabe.append("NICHTS Sokrates: Stellungnahme zu %s wartet, heute schon zweimal gestartet (194.2)" % ", ".join(ohne[:3]))
        else:
            msg = "Sokrates\n\nStellungnahme (194.2): in der Chefsache liegen Dateien ohne „Stellungnahme Sokrates“: %s. Schreibe in jede das stärkste Gegenargument, Widerspruch zu Entschiedenem, Kosten und die Empfehlung in einem Satz, überschreibe nichts; zuerst Start nach deiner Rollendatei." % ", ".join(ohne)
            ausgabe.append("START Sokrates | opus | %s | %s | Sokrates – Stellungnahme (%s) | %s" % (MITTEL, REPO, berlin(JETZT), msg.replace("\n", "\\n")))
            wochen.append("Stellungnahme Sokrates %s" % heute)
    wochen += vorentscheid_marken
    for l in ausgabe: print(l)
    if not ausgabe: print("NICHTS: nichts zu tun")
    if sperre and (sperren or neue_warnungen or wochen):
        p = os.path.join(DOCS, "ARBEIT-BETRIEB.md"); t = lesen(p).rstrip("\n")
        if sperren: t += "\n- %s %s: Startsperre %s Start %s (lauf.py)\n" % (JETZT.strftime("%H:%M"), JETZT.strftime("%d.%m."), JETZT.strftime("%H:%M"), ", ".join(sperren))
        for m in wochen: t += "\n- %s %s: Marke %s (lauf.py)\n" % (JETZT.strftime("%H:%M"), heute, m)
        for w in neue_warnungen: t += "\n- %s %s: %s (lauf.py)\n" % (JETZT.strftime("%H:%M"), JETZT.strftime("%d.%m."), w)
        open(p, "w", encoding="utf-8").write(t)
        print("Protokoll geschrieben: bitte committen und pushen%s." % (", erst dann create_session" if sperren else ""))
    if besetz: besetzung_schreiben([s for s in leb if s["id"] not in archiviert])

def morgenmeldung():
    """192.2, Schritt 10: Morgenmeldung als fertiger Text (Ford schickt sie mit meldung.sh --laut; Übernacht-Fertiges und Nutzungsbild ergänzt er)."""
    zeilen = []
    for l in lesen(os.path.join(DOCS, "ARBEIT-BESETZUNG.md")).splitlines():
        t = [x.strip() for x in l.split("|")]
        if l.startswith("| ") and len(t) > 6 and t[1] not in ("Rolle", "---") and t[1] != "Ford":
            zeilen.append("%s %s" % (t[1], t[3]))
    print("Morgen %s" % JETZT.strftime("%d.%m."))
    print("Wer woran: " + ("; ".join(zeilen) if zeilen else "niemand"))
    chef = os.path.join(DOCS, "chefsache")
    teile = []
    for ordner, name in (("entscheiden", "zu entscheiden"), ("ansehen", "anzusehen"), ("billigen", "zu billigen")):
        d = os.path.join(chef, ordner)
        dat = sorted(n for n in os.listdir(d) if n.endswith(".md")) if os.path.isdir(d) else []
        if dat: teile.append("%d %s (%s)" % (len(dat), name, ", ".join(n.split("-")[0] for n in dat[:6])))
    print("Chefsache: " + ("; ".join(teile) if teile else "nichts offen"))
    st = stand(); start = ["%s %s" % (r, v[0][0][0]) for r, v in sorted(st.items()) if v[0]]
    print("Startbares Muss: " + (", ".join(start) if start else "keins"))
    print("Bitte Bild der Nutzung (Woche %; ruht die Niederlassung: nur Max)")

def besetzung_schreiben(leb):
    p = os.path.join(DOCS, "ARBEIT-BESETZUNG.md"); t = lesen(p)
    zeilen = ["| Rolle | Sitzung | Vorgang | Zweig | seit |", "|---|---|---|---|---|"]
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

def kosten_addieren(nr, usd, sid=None):
    if sid:
        vz = os.path.join(DOCS, "KOSTEN-GEBUCHT.tsv")
        alt = {}
        if os.path.exists(vz):
            for l in lesen(vz).splitlines():
                k = l.split("\t")
                if len(k) == 2: alt[k[0]] = float(k[1])
        diff = round(usd - alt.get(sid, 0.0), 2)
        if diff <= 0: print("Kosten %s: %.2f $ schon gebucht, nichts zu tun" % (nr, usd)); return
        alt[sid] = usd
        open(vz, "w", encoding="utf-8").write("".join("%s\t%.2f\n" % kv for kv in sorted(alt.items())))
        usd = diff
    ziele = [x.strip() for x in nr.split(",") if x.strip()]
    if len(ziele) > 1:  # 197: Kosten auf mehrere Vorgänge zu gleichen Teilen
        for x in ziele: _buchen(x, round(usd / len(ziele), 2))
        return
    _buchen(nr, usd)

def _buchen(nr, usd):
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
