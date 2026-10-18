#!/usr/bin/env python3
"""Fords Lauf als Werkzeug (167.2): rechnet, wen Ford startet und was er archiviert; Ford führt nur aus.

Aufruf: python3 tools/lauf.py [--sperre] [--besetzung] SEITE [SEITE …]
SEITE = gespeicherte Ausgabe von list_sessions (mine, alle Seiten bis has_more falsch, wie bei kosten.py).
Ausgabe, Zeile für Zeile auszuführen:
  START <Rolle> | model | environment_id | Titel | erste Nachricht   → create_session (Startsperre vorher pushen: --sperre schreibt sie)
  ARCHIVIERE <session_id> | <Rolle> | <Kosten $> | <Vorgang>        → archive_session, danach --kosten (siehe unten)
  NICHTS <Rolle>: Grund                                             → nichts tun
  WARNUNG …                                                         → Ford meldet es lautlos
--sperre     trägt „Startsperre HH:MM Start <Name>“ ins Protokoll von ARBEIT-BETRIEB.md (Ford pusht, erst dann create_session).
--besetzung  schreibt ARBEIT-BESETZUNG.md neu (nur Tabelle und Stand); schreibt nur, wenn sich die Tabelle ändert.
--kosten NR USD  addiert USD auf die Kostenspalte der Zeile NR in LISTE-VORGAENGE.md (Ford ruft es je ARCHIVIERE-Zeile).
Regeln (LISTE-BETRIEB.md, ROLLE-BETRIEB.md): Tom, Jerry, Diogenes: Muss vor Kür; Homer, Perikles nur Muss; Sokrates, Ford, Ford 2 nie.
Laufend = Status working/blocked und updated_at jünger als 60 Minuten. Fertig (158) = nicht laufend, seit 20 Minuten ruhig, kein Hindernis
(keine eigene Datei in chefsache/entscheiden, keine Zeile des Vorrats „wartet auf Chef“, nicht need_input). Hindernis oder laufend: Rolle belegt, kein zweiter Start.
Nicht Sache des Werkzeugs: „Neustart <Name>, <Commit>“ (Nachricht), Wochenstart, Tagesrückblick, Meldungen, Eingang (bleiben bei Ford).
"""
import os, re, sys, datetime, zoneinfo
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar, kosten

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DOCS = startbar.DOCS
BERLIN = zoneinfo.ZoneInfo("Europe/Berlin")
JETZT = datetime.datetime.now(BERLIN)
MITTEL = "env_01F9WxikYD4TTdhscxvPi93p"
MODELL = {"Tom": "opus", "Homer": "opus", "Sokrates": "opus", "Jerry": "sonnet", "Perikles": "sonnet", "Diogenes": "sonnet"}
VORRAT = {"Homer": "ARBEIT-KREATIV.md", "Tom": "ARBEIT-TEAM-TOM.md", "Jerry": "ARBEIT-TEAM-JERRY.md",
          "Perikles": "ARBEIT-PROJEKT.md", "Diogenes": "ARBEIT-PRUEFUNG.md", "Sokrates": "ARBEIT-BERATUNG.md"}
START_REIHE = ["Tom", "Jerry", "Diogenes", "Homer", "Perikles"]
MIT_KUER = {"Tom", "Jerry", "Diogenes"}
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
    """Rolle → (Muss, Kür, Pause, wartetAufChef) aus den Vorräten."""
    chef = startbar.chefdateien()
    aus = {}
    for datei, rolle in startbar.ROLLEN:
        inhalt = startbar.lesen(datei)
        zs = [x for x in startbar.zeilen(inhalt) if x[1] not in ("–", "-")]
        sperr = {x[0]: startbar.blocker(x[0], x[3], chef, x[2]) for x in zs}
        zs = [x for x in zs if sperr[x[0]] != "ERLEDIGT"]
        muss = next((x for x in zs if x[1] == "M" and not sperr[x[0]]), None)
        kuer = next((x for x in zs if x[1] != "M" and not sperr[x[0]]), None)
        wartet = [x[0] for x in zs if (sperr[x[0]] or "").startswith("Chef")]
        aus[rolle] = (muss, kuer, startbar.pause(inhalt), wartet)
    return aus

def nummer_aus_titel(t):
    m = re.search(r"–\s*([0-9][0-9a-zA-Z.]*)", t)
    return m.group(1).rstrip(".") if m else ""

def main():
    a = sys.argv[1:]
    if a[:1] == ["--kosten"]:
        return kosten_addieren(a[1], float(a[2].replace(",", ".")))
    sperre = "--sperre" in a; besetz = "--besetzung" in a
    seiten = [x for x in a if not x.startswith("--")]
    if not seiten: sys.exit(__doc__)
    offen = []; alle = {}
    for p in seiten:
        for s in kosten.sitzungen(p, offen): alle[s["id"]] = s
    ausgabe = []
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
        if r in chefd: hinder.append("Datei in der Chefsache " + ", ".join(chefd[r][:2]))
        if st.get(r) and st[r][3]: hinder.append("Zeile wartet auf Chef " + ", ".join(st[r][3][:2]))
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
            ausgabe.append("ARCHIVIERE %s | %s | %s | %s" % (s["id"], r, ("%.2f" % k) if k is not None else "fehlt", nummer_aus_titel(s.get("title", "")) or "Betrieb"))
    # Starten
    sperren = []
    for r in START_REIHE:
        muss, kuer, pause, _ = st.get(r, (None, None, None, []))
        belegt = [s for s in je_rolle.get(r, []) if s["_info"][1] or s["_info"][3] or s["_info"][2] < SPERRE_MIN]
        if pause: ausgabe.append("NICHTS %s: Pause bis %s" % (r, pause)); continue
        if belegt: ausgabe.append("NICHTS %s: belegt durch %s" % (r, belegt[0].get("title", belegt[0]["id"]))); continue
        if r in marken and (JETZT - marken[r]).total_seconds() < SPERRE_MIN * 60:
            ausgabe.append("NICHTS %s: Startmarke %s jünger als %d Minuten" % (r, marken[r].strftime("%H:%M"), SPERRE_MIN)); continue
        wahl = muss or (kuer if r in MIT_KUER else None)
        if not wahl: ausgabe.append("NICHTS %s: %s" % (r, "kein startbares Muss" if r not in MIT_KUER else "nichts Startbares")); continue
        nr, kl, thema, _ = wahl
        thema = re.sub(r"\*\*|`", "", thema)
        titel = "%s – %s (%s)" % (r, nr, berlin(JETZT))
        msg = "%s\n\nArbeite Zeile %s (%s) aus deinem Vorrat %s; zuerst Start nach deiner Rollendatei, dann die Zeile lesen und die Übergabe beachten." % (r, nr, "Muss" if kl == "M" else "Kür", VORRAT[r])
        ausgabe.append("START %s | %s | %s | %s | %s" % (r, MODELL[r], MITTEL, titel, msg.replace("\n", "\\n")))
        sperren.append(r)
    for l in ausgabe: print(l)
    if not ausgabe: print("NICHTS: nichts zu tun")
    if sperre and sperren:
        p = os.path.join(DOCS, "ARBEIT-BETRIEB.md"); t = lesen(p).rstrip("\n")
        t += "\n- %s %s: Startsperre %s Start %s (lauf.py)\n" % (JETZT.strftime("%H:%M"), JETZT.strftime("%d.%m."), JETZT.strftime("%H:%M"), ", ".join(sperren))
        open(p, "w", encoding="utf-8").write(t)
        print("Startsperre geschrieben: bitte committen und pushen, erst dann create_session.")
    if besetz: besetzung_schreiben(leb)

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

def kosten_addieren(nr, usd):
    p = os.path.join(DOCS, "LISTE-VORGAENGE.md"); L = lesen(p).split("\n")
    ziel = nr
    while ziel:
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
