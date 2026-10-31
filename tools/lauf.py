#!/usr/bin/env python3
"""Fords Lauf als Werkzeug (167.2): rechnet, wen Ford startet und was er archiviert; Ford führt nur aus.

Aufruf: python3 tools/lauf.py [--sperre] [--besetzung] [--nur-muss] [--ohne NR:Grund …] SEITE [SEITE …]
SEITE = gespeicherte Ausgabe von list_sessions (mine, alle Seiten bis has_more falsch, wie bei kosten.py)
  ODER Kurzform (Datei mit einer Zeile je Sitzung, kein Abschreiben der Seiten nötig, 167.2):
  `Kennung | working|idle|blocked|need_input|archived | updated_at (ISO) | Titel | Kosten $ (oder -) | created_at | used_tokens (context_usage, für WEITER, 261.5)`
  Letzte Zeile der Kurzform: `# has_more: nein` (erst nach der letzten Seite von list_sessions); fehlt sie oder steht „ja“, warnt lauf.py „Seite abgeschnitten“ (261.4).
Ausgabe, Zeile für Zeile auszuführen:
  START <Rolle> | model | environment_id | source_url | source_revision | Titel | erste Nachricht   → create_session mit allen Feldern, source_url (187) und source_revision main (382) Pflicht (Startsperre vorher pushen: --sperre schreibt sie)
  ARCHIVIERE <session_id> | <Rolle> | <Kosten $> | <Vorgang>        → archive_session, danach --kosten (siehe unten)
  GEBUCHT <session_id> | <Rolle> | <Kosten $> | <Vorgang>           → lauf.py hat selbst gebucht (nur mit --sperre); Ford pusht die Notizen, sonst nichts
  BUCHE <session_id> | <Rolle> | <Kosten $> | <Vorgang>             → nur `--kosten <Vorgang> <Kosten> <session_id>` (ruhende oder schon archivierte Sitzung von heute, Differenz zum Verzeichnis, 261.2)
  PR-ABO <session_id> | <Rolle> | PR #n | an <neuere session_id>    → „PR #“ im Titel: Abo der alten Sitzung an die neuere übergeben (subscribe_pr_activity dort), dann ARCHIVIERE (D40.4)
  ÜBERTRAGE <session_id> | <Rolle> | <Frage>                       → offene Frage der alten Sitzung wörtlich in Vorrat/Chefsache holen (list_events), dann folgt ARCHIVIERE (261)
  WEITER <session_id> | <Rolle> | <Vorgang> | <Nachricht>          → send_message „Weiter: <Vorgang>…“ an die alte Sitzung statt START (unter 400 Tsd. Token, unter 60 Minuten Ruhe; abgelehnt → START, 261.5)
  NICHTS <Rolle>: Grund                                             → nichts tun
  WARNUNG …                                                         → Ford meldet es lautlos
  WARNUNG-LAUT …                                                    → Ford meldet es mit --laut (190.7: dieselbe Warnung zum zweiten Mal)
  STILLSTAND <Rolle>: …                                             → Ford schreibt die Protokollzeile „Stillstand <Rolle> seit HH:MM“ (Schritt 5, 192.2)
  VORRAT-LEER: …                                                    → Ford meldet es einmal am Tag (Schritt 9, 192.2)
  WOCHENSTART TT.MM. | Rolle | Titel | erste Nachricht                  → Ford startet wie START (Schritt 11, 192.2); Marke „Wochenstart TT.MM. Rolle“ schreibt --sperre
  TAGESBERICHT TT.MM. | Perikles | Titel | erste Nachricht                → dasselbe für den Tagesbericht ab 7:30, Sa, So 9:30 (247.1, Marke „Tagesbericht TT.MM.“)
  WÄCHTER <Nr> | <Rollen> | <session_id|-> | <Text>                  → Ford: meldung.sh --laut Ford "<Text>" und send_message <Text> an die Sitzung (383; einmal je „jetzt“, Marke schreibt --sperre)
  AUSGESCHLOSSEN NR: Grund                                          → Ford hat die Zeile mit --ohne ausgeschlossen; Ford meldet Grund lautlos (190.2)
--ohne NR:Grund  (mehrfach) schließt die Zeile NR für diesen Lauf aus; lauf.py nimmt dann die nächste startbare Zeile derselben Rolle (190.2). Ohne Grund gilt es nicht.
--ohne-pull  lässt das Vorspulen der Notizen aus (380: sonst zieht lauf.py bornim-main auf origin/main und bricht ab, wenn das nicht geht).
--nur-muss   startet nur Muss, keine Kür und nichts „nach dem Meilenstein“ (D31.3: Ford setzt es bei `allowed_warning` vor Wochenmitte, D20.2).
--sperre     trägt „Startsperre HH:MM Start <Name>“ ins Protokoll von ARBEIT-BETRIEB.md (Ford pusht, erst dann create_session).
--morgen     gibt die Morgenmeldung als fertigen Text aus (192.2, Schritt 10).
--aufraeumen kürzt Fords Protokoll auf die 20 neuesten Taten (plus Marken von heute und gestern) und schiebt erledigte Zeilen von LISTE-VORGAENGE.md ins Archiv (270); --sperre tut es in jedem Lauf.
--besetzung  schreibt ARBEIT-BESETZUNG.md neu (nur Tabelle und Stand); schreibt nur, wenn sich die Tabelle ändert.
--kosten NR USD SESSION_ID  addiert USD auf die Kostenspalte der Zeile NR in LISTE-VORGAENGE.md oder -ARCHIV.md (Ford ruft es je ARCHIVIERE-Zeile, mit der Kennung).
  Kennung Pflicht (384: nachts gebuchte Sitzungen ohne Kennung waren nicht mehr nachweisbar); ohne Sitzung nur `ohne:<Grund>`. USD frisch aus get_session nach dem Archivieren
  (384: 3,13 statt 6,31 $ aus einer alten Abfrage gebucht).
  Mit Kennung gilt das Buchungsverzeichnis docs/KOSTEN-GEBUCHT.tsv (191): gebucht wird nur die Differenz zu früher Gebuchtem, damit wieder geöffnete oder doppelt archivierte Sitzungen nichts doppelt kosten.
Offene „M?“ aller Vorräte erscheinen als eine Muss-Zeile „M? entscheiden: …“ im Plan für Perikles (190.8).
Jeder Lauf hängt die WARNUNG-Zeilen von abgleich.py an (191).
Regeln (LISTE-BETRIEB.md, ROLLE-BETRIEB.md): Tom, Jerry, Diogenes, Homer, Perikles: Muss vor Kür, Kür vor Leerlauf (196), danach Zeilen „nach dem Meilenstein“ (190.10); Sokrates, Ford, Ford 2 nie.
Nachfolger (190.7): nennt die Übergabe im Vorrat „Nachfolger: <Titel>“ und gibt es seither keine Sitzung der Rolle, startet lauf.py diese (vor Muss und Kür,
auch bei Homer, Perikles); ein Datum in der Zukunft im Titel schiebt den Start, „keiner“ und „nur wenn …“ lassen die Zeilenregel gelten. Kann sie nicht starten
(Titel ohne Zeit in der Übergabe; eine Pause im Vorrat hält den Nachfolger nicht auf, nur neue Arbeit, 347), steht WARNUNG mit Grund; beim zweiten Lauf mit derselben Übergabe WARNUNG-LAUT (Protokollzeile „Nachfolger-Warnung“, --sperre schreibt sie).
Nennt der Nachfolger („<Rolle> – <Nr> …“) eine nicht startbare Zeile des eigenen Vorrats, gilt die Zeilenregel, mit derselben Warnung (276, Fall 251).
Dateien der Chefsache und „wartet auf Chef“ halten keine Sitzung (261.4: die Frage steht in der Chefsache, nicht in der Sitzung);
Archivregel (261.5, vier Sätze; nur Ford und Ford 2 ausgenommen): (1) je Bereich höchstens eine Sitzung, Bereich = Rolle laut Titel; ohne Rolle im Titel bleibt die Sitzung stehen, WARNUNG einmal;
(2) gibt es mehr als eine, archiviert Ford die ältere, also jede außer der zuletzt tätigen (späteres updated_at, nicht created_at; 261.6) (bei START im selben Lauf: ARCHIVIERE-Zeilen der alten Sitzungen direkt nach der START-Zeile), sobald die neuere läuft und die ältere nicht mehr arbeitet (261.5 Wartezeit, Chef 21.10., 16:46: keine 60 Minuten mehr; offene Frage: vorher ÜBERTRAGE; PR-Abo: Ford übergibt es vorher an die neuere Sitzung); (3) neue Arbeit geht per WEITER in die alte Sitzung,
wenn sie unter 400 Tsd. Token liegt (383.1, Vorentscheid; vorher 150 Tsd., D40.1) und unter 60 Minuten ruht, sonst START; (4) Kostenbuchung bleibt eigene Regel (--kosten, GEBUCHT). Kein Hindernis hält eine Sitzung.
Prüfung des Ergebnisses: steht dieselbe Sitzung im nächsten Lauf wieder auf ARCHIVIERE, gibt es WARNUNG-LAUT „Ford hat … nicht ausgeführt“ (Marke „Archiv <id>“); mehr als eine Sitzung je Bereich in zwei Läufen hintereinander
gibt WARNUNG-LAUT (Marke „Mehrfach <Rolle>“). Marken schreibt nur --sperre.
Laufend = Status working/blocked und updated_at jünger als 60 Minuten (Start-Sperre und Belegung 20 Minuten). Laufend oder jünger als 20 Minuten: Rolle belegt, kein zweiter Start.
Nicht Sache des Werkzeugs: „Neustart <Name>, <Commit>“ (Nachricht), Wochenstart, Tagesbericht, Meldungen, Eingang (bleiben bei Ford).
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
HOCH = "env_017fgL1YDcVTYTkJsU3APEfR"  # „WireStorm Hoch“
UMGEBUNG = {"Tom": HOCH, "Jerry": HOCH}  # 365: Probe Aufwand „Hoch“ für die Teams bis 31.10. (Chef 25.10., 12:38); sonst MITTEL
REPO = "https://github.com/tramour-cmyk/androidapp_rpg_bornim"  # ohne source_url startet die Sitzung ohne Repo (18.10., Jerry 39; 187)
REVISION = "main"  # 382: ohne source_revision lasen neue Sitzungen einen alten Stand (26.10., ohne add_repo-Erlaubnis; Tom 376.1a)
MODELL = {"Tom": "opus", "Homer": "opus", "Sokrates": "opus", "Jerry": "opus", "Perikles": "opus", "Diogenes": "opus"}  # 270: Regelwächter groß, Probe bis 26.10.
VORRAT = {"Homer": "ARBEIT-KREATIV.md", "Tom": "ARBEIT-TEAM-TOM.md", "Jerry": "ARBEIT-TEAM-JERRY.md",
          "Perikles": "ARBEIT-PROJEKT.md", "Diogenes": "ARBEIT-PRUEFUNG.md", "Sokrates": "ARBEIT-BERATUNG.md",
          "Spike": "ARBEIT-TEAM-TOM.md", "Tuffy": "ARBEIT-TEAM-JERRY.md"}  # 394: eigene Rolle (belegt Tom nicht), Vorrat des Teams
START_REIHE = ["Tom", "Jerry", "Diogenes", "Homer", "Perikles"]
MIT_KUER = {"Tom", "Jerry", "Diogenes", "Homer", "Perikles"}
NIE_ARCHIV = {"Ford", "Ford 2"}  # Ford, Wache; Sokrates und Sonstige nach eigener Regel (197)
SPERRE_MIN = 20
WEITER_TOKEN = 400000  # 261.5 (3); 383.1 (Chef 27.10., 19:19 „nicht mal 2 Seiten lang“): Kontext 1 Mio., Kosten je Arbeit bis 500 Tsd. gleich (Messung Sokrates 18:15); Vorentscheid Perikles 27.10. (vorher 150 Tsd., D40.1)
WEITER_MIN = 60  # 261.5 (3): WEITER nur in eine Sitzung, die unter 60 Minuten ruht; fürs Archivieren gibt es keine Wartezeit mehr (Chef 21.10., 16:46)

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
        m = re.search(r"Startsperre (\d\d):(\d\d) Start ((?:Ford 2|\w+)(?:, (?:Ford 2|\w+))*)", l)
        if not m: continue
        d = JETZT.replace(hour=int(m.group(1)), minute=int(m.group(2)), second=0, microsecond=0)
        if d > JETZT: d -= datetime.timedelta(days=1)
        for name in m.group(3).split(", "): aus[name] = d  # 433: „Start Tom, Spike“ sperrt beide, nicht nur den ersten
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

GESPERRT = {}  # Rolle → {Nummer: Grund} der nicht startbaren Zeilen (276: Nachfolger auf gesperrter Zeile)

def stand():
    """Rolle → (Muss-Liste, Kür-Liste, Pause, Chef-Nummern) aus den Vorräten; Listen = alle startbaren Zeilen in Vorratsreihenfolge."""
    chef = startbar.chefdateien()
    aus = {}; m_fragen = []
    for datei, rolle in startbar.ROLLEN:
        inhalt = startbar.lesen(datei)
        zs = startbar.hochstufen([x for x in startbar.zeilen(inhalt) if x[1] not in ("–", "-")])
        sperr = {x[0]: startbar.blocker(x[0], x[3], chef, x[2]) for x in zs}
        zs = [x for x in zs if sperr[x[0]] != "ERLEDIGT"]
        leichen = startbar.leichen_von(zs, sperr)  # 275 Stufe 1: überholte Stände zuerst berichtigen, als eine Muss-Zeile wie „M?“
        muss = [x for x in zs if x[1] == "M" and not sperr[x[0]]]
        if leichen and startbar.LEICHEN_START: muss.insert(0, ("Leichen", "M", "Stand berichtigen (275): " + "; ".join("%s %s" % l for l in leichen) + " (startbar.py --leichen)", ""))
        kuer = [x for x in zs if x[1] != "M" and not sperr[x[0]]]
        kuer += [(x[0], "N", x[2], x[3]) for x in zs if sperr[x[0]] == "nach dem Meilenstein"]  # 190.10: letzte Stufe vor Leerlauf
        wartet = [x[0] for x in zs if (sperr[x[0]] or "").startswith("Chef")]
        aus[rolle] = (muss, kuer, startbar.pause(inhalt), wartet)
        GESPERRT[rolle] = {x[0]: sperr[x[0]] for x in zs if sperr[x[0]]}
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
    """Hält eine Frage (Nummern der Zeilen/Dateien) diese Sitzung? Ohne Nummer im Titel: nein (261, Chef 20.10.: eine aktive Sitzung je Arbeitsbereich)."""
    if not nummern or not nr_sitzung: return False
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
        roh = NACHFOLGER.search(l).group(1).strip().lstrip("*").strip()
        q = re.match(r"[„\"]([^“\"]+)[“\"]", roh)  # 375: Titel in Anführungszeichen endet beim schließenden („…“; schickt zuerst …)
        if q: roh = q.group(1)
        roh = re.split(r"\.(?=\s+[A-ZÄÖÜ„*]|\s*$)|;", roh, maxsplit=1)[0].strip(" *„“\"")
        if re.search(r"startet\s+`?lauf\.py`?", roh): return None, zeit, "bedingt: " + roh[:60]  # 375: Termin, den lauf.py selbst startet
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

def sokrates_ziel(s, ss):
    """„Kosten auf“ aus der Übergabe der Sokrates-Sitzung s (Stand vor dem Start der nächsten aus ss, 197.1) als „361,89“, sonst ""."""
    neuere = [x for x in ss if x is not s and z(x["created_at"]) > z(s["created_at"])]
    return ",".join(kosten_auf(min(z(x["created_at"]) for x in neuere) if neuere else z(s["updated_at"])))

def juengste(ss):
    """Die zuletzt tätige Sitzung eines Bereichs (261.6): späteres updated_at, bei Gleichstand späteres created_at."""
    return max(ss, key=lambda x: (z(x["updated_at"]), z(x["created_at"])))

def titel_datum(titel):
    """Erstes TT.MM. im Titel, wenn es in der Zukunft liegt; heute mit „um/ab H:MM“ danach, wenn die Uhrzeit noch kommt (375); sonst None."""
    for m in re.finditer(r"(?<!\d)(\d\d?)\.(\d\d)\.", titel):
        try: d = startbar.jahr_von(int(m.group(1)), int(m.group(2)))
        except ValueError: continue
        if d > JETZT.date(): return "%02d.%02d." % (d.day, d.month)
        u = re.search(r"\b(?:um|ab)\s+(\d\d?)[:.](\d\d)\b", titel[m.end():])
        if d == JETZT.date() and u and (int(u.group(1)), int(u.group(2))) > (JETZT.hour, JETZT.minute):
            return "%02d.%02d., %d:%s" % (d.day, d.month, int(u.group(1)), u.group(2))
    return None

def warnungen_bekannt():
    """Zeilen „Nachfolger-Warnung <Rolle> (Übergabe …)“ im Protokoll."""
    return [l for l in lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")).splitlines() if "Nachfolger-Warnung" in l]

def nummer_aus_titel(t):
    m = re.search(r"–\s*([0-9][0-9a-zA-Z.]*)", t)
    if m: return m.group(1).rstrip(".")
    # 261.2: Nummer auch mitten im Titel („Tom – Umriss prüfen 216.3“); Uhrzeiten in Klammern und „Build 40“ zählen nicht
    s = re.sub(r"\([^)]*\)", " ", t)
    s = re.sub(r"\bBuilds?\s+\d+(\s+und\s+\d+)?", " ", s)
    s = re.sub(r"\b(Godot|Runde|Lauf|Brücke)\s+\d+[a-z]?\b", " ", s)  # „Tom – Umzug Godot 12“ buchte auf Vorgang 12 (Ford 25.10.)
    m = re.search(r"(?<![\d.:])(\d{2,3}[a-zA-Z]?(?:\.\d+[a-z]?)*)(?![\d:])", s)
    return m.group(1).rstrip(".") if m else ""

def nummern_aus_titel(t):
    """379: alle Vorgangsnummern im Titel als Kommaliste („Jerry – 348.7a Runde 5, 348.12f Rute r7“ → „348.7a,348.12f“), Kosten zu gleichen Teilen (197)."""
    erste = nummer_aus_titel(t)
    if not erste: return ""
    s = re.sub(r"\([^)]*\)", " ", t.split("–", 1)[-1])
    s = re.sub(r"\bBuilds?\s+\d+(\s+und\s+\d+)?", " ", s)
    s = re.sub(r"\b(Godot|Runde|Lauf|Brücke)\s+\d+[a-z]?\b", " ", s)
    alle = [erste] + [m.rstrip(".") for m in re.findall(r"(?<![\d.:\w])(\d{2,3}[a-zA-Z]?(?:\.\d+[a-z]?)*)(?![\d:])", s)]
    return ",".join(dict.fromkeys(alle))

PROTOKOLL_MAX = 20  # ARBEIT-BETRIEB.md „höchstens 20 Zeilen; ältere streichen“ (117)
TECHNIK = re.compile(r"Marke |Startsperre \d|Nachfolger-Warnung")
ZEILE = re.compile(r"- (\d\d):(\d[\dx]) (\d\d)\.(\d\d)\.")

def aufraeumen():
    """270: hält Notizen unter den Grenzen, die Ford von Hand nie kürzte. Protokoll: die 20 neuesten Zeilen mit Tat (neueste oben),
    dazu Marken, Startsperren und Nachfolger-Warnungen von heute und gestern (liest lauf.py); älteres steht in Git.
    LISTE-VORGAENGE.md: Zeilen mit Stand „erledigt …“ unverändert ans Ende von LISTE-VORGAENGE-ARCHIV.md (169). Gibt die Zahl der Änderungen zurück."""
    n = 0
    p = os.path.join(DOCS, "ARBEIT-BETRIEB.md"); t = lesen(p)
    i = t.find("## Protokoll")
    if i >= 0:
        kopf, zeilen = [], []
        for l in t[i:].split("\n"):
            (zeilen if ZEILE.match(l) else kopf).append(l)
        def zeit(l):
            m = ZEILE.match(l); return (m.group(4), m.group(3), m.group(1), m.group(2).replace("x", "9"))
        gestern = (JETZT - datetime.timedelta(days=1)).strftime("%d.%m.")
        technik = [l for l in zeilen if TECHNIK.search(l) and ZEILE.match(l).group(3) + "." + ZEILE.match(l).group(4) + "." in (JETZT.strftime("%d.%m."), gestern)]
        taten = sorted([l for l in zeilen if not TECHNIK.search(l)], key=zeit, reverse=True)[:PROTOKOLL_MAX]
        while kopf and not kopf[-1].strip(): kopf.pop()
        neu = t[:i] + "\n".join(kopf) + "\n\n" + "\n".join(taten + technik) + "\n"
        if neu != t:
            n += len(zeilen) - len(taten) - len(technik); open(p, "w", encoding="utf-8").write(neu)
    p = os.path.join(DOCS, "LISTE-VORGAENGE.md"); t = lesen(p).split("\n")
    weg = [l for l in t if l.startswith("| ") and l.rstrip(" |").split("|")[-1].strip().lower().startswith("erledigt")]
    if weg:
        open(p, "w", encoding="utf-8").write("\n".join(l for l in t if l not in weg))
        q = os.path.join(DOCS, "LISTE-VORGAENGE-ARCHIV.md")
        alt = lesen(q)  # erst lesen, dann öffnen: open(…, "w") leert die Datei
        open(q, "w", encoding="utf-8").write(alt.rstrip("\n") + "\n" + "\n".join(weg) + "\n")
        n += len(weg)
    return n

def noch_offen(ausgabe, rolle, nrn):
    """275 (Chef 15:20, „Ford sichert“): endet eine Sitzung, deren Vorgang im Vorrat oder in der Liste noch „in Arbeit“ steht, meldet Ford es dem Besitzer."""
    for nr in [x for x in (nrn or "").split(",") if x and x != "Betrieb"]:
        st = startbar.VORG.get(nr, "")
        zeile = [z for d, ro in startbar.ROLLEN if ro == kosten.TEAM.get(rolle, rolle) for z in startbar.zeilen(startbar.lesen(d)) if z[0] == nr]
        if re.match(r"in Arbeit", st) or (zeile and re.match(r"in Arbeit|begonnen", startbar.blank(zeile[0][3]))):
            ausgabe.append("WARNUNG %s %s: Sitzung endet, Stand noch „in Arbeit“; Besitzer setzt ihn mit tools/vorgang.py stand (275)" % (rolle, nr))

def notizen_frisch():
    """380: Ford zog den Arbeitsbaum, lauf.py las aber die alten Notizen in bornim-main (Zeile 275 von Diogenes fehlte, NICHTS statt START).
    Vor jedem Lauf die Notizen auf origin/main bringen (nur vorspulen); geht das nicht, Lauf abbrechen statt mit altem Stand rechnen."""
    d = os.path.join(DOCS, "..")
    try:
        subprocess.run(["git", "-C", d, "pull", "-q", "--ff-only", "origin", "main"], capture_output=True, text=True, timeout=60)
        r = subprocess.run(["git", "-C", d, "rev-list", "--count", "HEAD..origin/main"], capture_output=True, text=True, timeout=20)
        hinten = int(r.stdout.strip() or 0)
    except Exception as e:
        print("WARNUNG Notizen nicht geprüft (%s); Lauf mit Stand %s" % (e, d)); return True
    if hinten:
        print("WARNUNG-LAUT Notizen in %s %d Commits hinter origin/main und nicht vorspulbar (eigene Commits?): erst git -C %s pull --no-rebase, dann lauf.py erneut (380)" % (os.path.abspath(d), hinten, os.path.abspath(d)))
        return False
    return True

def main():
    a = sys.argv[1:]
    if a[:1] == ["--morgen"]:
        return morgenmeldung()
    if a[:1] == ["--aufraeumen"]:
        return print("Aufgeräumt: %d Zeilen (Notizen pushen)" % aufraeumen())
    if a[:1] == ["--kosten"]:  # 384: nur mit Kennung, sonst fehlt die Sitzung im Buchungsverzeichnis (doppelt oder nie gebucht)
        if len(a) < 4 or not a[3].startswith(("session_", "ohne:")):
            print("lauf.py --kosten NR USD session_…: Kennung fehlt (384); ohne Sitzung nur mit „ohne:<Grund>“", file=sys.stderr); sys.exit(2)
        return kosten_addieren(a[1], float(a[2].replace(",", ".")), a[3] if a[3].startswith("session_") else None)
    if "--ohne-pull" not in a and not notizen_frisch(): sys.exit(1)
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
        # 261.4 (Chef 21.10.): eine Chefsache hält keine Sitzung; Datei in der Chefsache und „wartet auf Chef“ sind kein Hindernis mehr, nur need_input
        if pts.get("status_category") == "need_input":
            s["_frage_alt"] = (pts.get("title") or pts.get("description") or pts.get("summary") or "Frage siehe list_events")  # 261.5 (2): Frage zuerst übertragen, dann archivieren
        s["_info"] = (r, laufend, ruhig, hinder)
        je_rolle.setdefault(r, []).append(s)
    # 191: Sitzungen mit Kosten, aber ohne Vorgangsnummer im Titel, lassen sich nicht buchen
    for s in leb:
        r = s["_info"][0]
        k = s.get("external_metadata", {}).get("usage", {}).get("cost_usd")
        if r in ("Ford", "Ford 2", "Sonstige", "Sokrates") or not k or k < 0.5 or nummer_aus_titel(s.get("title", "")): continue
        ausgabe.append("WARNUNG Abgleich: Sitzung %s „%s“ (%s, %.2f $) ohne Vorgangsnummer im Titel, Kosten nicht buchbar" % (s["id"], s.get("title", ""), r, k))
    # 261.2: ruhende Sitzungen von heute nachbuchen (Differenz zum Buchungsverzeichnis), auch ohne Archivieren; Ford und Titel ohne Nummer auf Betrieb
    gebucht = {}
    vz = os.path.join(DOCS, "KOSTEN-GEBUCHT.tsv")
    for l in lesen(vz).splitlines():
        k = l.split("\t")
        if len(k) == 2: gebucht[k[0]] = float(k[1])
    for s in alle.values():
        k = s.get("external_metadata", {}).get("usage", {}).get("cost_usd")
        if not k or z(s["updated_at"]).astimezone(BERLIN).date() != JETZT.date(): continue
        if s["id"] not in gebucht and z(s["created_at"]).astimezone(BERLIN).date() != JETZT.date(): continue
        diff = round(k - gebucht.get(s["id"], 0.0), 2)
        if diff < 0.05: continue
        info = s.get("_info")
        if info and info[1]: continue  # laufende Sitzung: erst wenn sie ruht
        if not info and (JETZT - z(s["updated_at"])).total_seconds() < 3600 and s.get("session_status") == "SESSION_STATUS_RUNNING": continue
        r = kosten.rolle(s.get("title", ""))
        ziel = "Betrieb" if r in ("Ford", "Ford 2") else (nummer_aus_titel(s.get("title", "")) or "Betrieb")
        if r == "Sokrates":  # 375: auch hier „Kosten auf“ der Übergabe (197), sonst Betrieb hier und die Nummern beim ARCHIVIERE (7,10 $ doppelt, 25.10.)
            ziel = sokrates_ziel(s, [x for x in alle.values() if kosten.rolle(x.get("title", "")) == "Sokrates"]) or ziel
        if sperre:  # echter Lauf: lauf.py bucht selbst (19.10.: Ford führte BUCHE nicht aus, 261.2); Ford pusht die Notizen
            kosten_addieren(ziel, k, s["id"]); ausgabe.append("GEBUCHT %s | %s | %.2f | %s (Notizen pushen)" % (s["id"], r, k, ziel))
        else:
            ausgabe.append("BUCHE %s | %s | %.2f | %s" % (s["id"], r, k, ziel))
    # Archivieren: Archivregel in vier Sätzen (261.5); nur Ford und Ford 2 ausgenommen
    marke_alt = lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")); neue_marken = []
    def marke_zeit(text):
        """Zeitpunkte aller Protokollzeilen „- HH:MM TT.MM.: Marke <text>“."""
        aus = []
        for m in re.finditer(r"- (\d\d):(\d\d) (\d\d)\.(\d\d)\.: Marke " + re.escape(text) + r"\b", marke_alt):
            try: aus.append(JETZT.replace(month=int(m.group(4)), day=int(m.group(3)), hour=int(m.group(1)), minute=int(m.group(2)), second=0, microsecond=0))
            except ValueError: pass
        return aus
    for r, ss in sorted(je_rolle.items()):
        if r in NIE_ARCHIV: continue
        if r == "Sonstige":  # (1) ohne Rolle im Titel lässt Ford die Sitzung stehen und meldet es einmal
            for s in ss:
                if s.get("title", "").startswith("Ford"): continue
                if not marke_zeit("Ohne-Rolle " + s["id"]):
                    ausgabe.append("WARNUNG Sitzung %s „%s“ hat keine Rolle im Titel: bleibt stehen, nicht archiviert (261.5)" % (s["id"], s.get("title", ""))); neue_marken.append("Ohne-Rolle " + s["id"])
            continue
        for s in ss:
            _, laufend, ruhig, hinder = s["_info"]
            if laufend: continue
            # (2) nur mit neuerer Sitzung desselben Bereichs, ohne Wartezeit (261.5, Chef 16:46; ersetzt 60 Minuten aus 238)
            # 261.6 (Chef 22.10., 06:43): „neuer“ = letzte Arbeit (updated_at), nicht created_at; bleiben darf nur die zuletzt tätige
            if s is juengste(ss): continue
            k = s.get("external_metadata", {}).get("usage", {}).get("cost_usd")
            nrn = nummern_aus_titel(s.get("title", "")) or "Betrieb"
            if r == "Sokrates":  # (4) Kostenbuchung bleibt eigene Regel (197): Kosten auf die Nummern der Übergabe
                auf = sokrates_ziel(s, ss)
                if auf: nrn = auf
                else: ausgabe.append("WARNUNG Sokrates %s: Übergabe in %s nennt keine „Kosten auf: <Nummern>“ (197), Kosten auf %s" % (s["id"], VORRAT["Sokrates"], nrn))
            archiviert.add(s["id"])
            pr = re.search(r"PR #\d+", s.get("title", ""))  # D40.4: lauf.py kennt keine Abos, nur den Titel
            if pr:
                neu = juengste(ss)
                ausgabe.append("PR-ABO %s | %s | %s | an %s" % (s["id"], r, pr.group(0), neu["id"]))
            if s.get("_frage_alt"): ausgabe.append("ÜBERTRAGE %s | %s | %s" % (s["id"], r, str(s["_frage_alt"]).replace("\n", " ")[:200]))
            ausgabe.append("ARCHIVIERE %s | %s | %s | %s" % (s["id"], r, ("%.2f" % k) if k is not None else "fehlt", nrn))
            noch_offen(ausgabe, r, nrn)
            # Prüfung des Ergebnisses: dieselbe Sitzung steht im nächsten Lauf wieder auf ARCHIVIERE
            alt = [d for d in marke_zeit("Archiv " + s["id"]) if (JETZT - d).total_seconds() >= 1800]
            if alt and not marke_zeit("Archiv-Warnung " + s["id"]):  # D40.2: einmal je Sitzung
                ausgabe.append("WARNUNG-LAUT Ford hat ARCHIVIERE %s (%s) aus dem Lauf von %s nicht ausgeführt (261.5); darf Ford es nicht, archiviert der Chef sie selbst" % (s["id"], r, alt[0].strftime("%H:%M")))
                neue_marken.append("Archiv-Warnung " + s["id"])
            elif not alt and not marke_zeit("Archiv " + s["id"]): neue_marken.append("Archiv " + s["id"])
    # Prüfung: mehr als eine Sitzung je Bereich in zwei Läufen hintereinander (Abstand 30 bis 150 Minuten)
    for r, ss in sorted(je_rolle.items()):
        if r in NIE_ARCHIV or r == "Sonstige": continue
        offene = [s for s in ss if s["id"] not in archiviert]
        if len(offene) < 2: continue
        zeiten = marke_zeit("Mehrfach " + r.replace(" ", "-"))
        vor = [d for d in zeiten if 1800 <= (JETZT - d).total_seconds() <= 9000]
        aelteste = min(offene, key=lambda x: z(x["updated_at"]))["id"]
        if vor and not marke_zeit("Mehrfach-Warnung %s %s" % (r.replace(" ", "-"), aelteste)):  # einmal je Lage (wie D40.2)
            neue_marken.append("Mehrfach-Warnung %s %s" % (r.replace(" ", "-"), aelteste))
            ausgabe.append("WARNUNG-LAUT %d Sitzungen im Bereich %s in zwei Läufen hintereinander (seit %s, 261.5)" % (len(offene), r, vor[0].strftime("%H:%M")))
        if not [d for d in zeiten if (JETZT - d).total_seconds() < 1800]: neue_marken.append("Mehrfach " + r.replace(" ", "-"))
    # Starten
    for nr, grund in sorted(ausschluss.items()): ausgabe.append("AUSGESCHLOSSEN %s: %s" % (nr, grund))
    sperren = []; neue_warnungen = []
    bekannt = warnungen_bekannt()
    def vorgaenger(r):
        # 261.5 (Chef 18:25): startet ein Nachfolger, archiviert Ford die alten Sitzungen der Rolle gleich danach, nicht erst im nächsten Lauf
        for s in je_rolle.get(r, []):
            if s["id"] in archiviert or s["_info"][1]: continue
            archiviert.add(s["id"])
            k = s.get("external_metadata", {}).get("usage", {}).get("cost_usd")
            if s.get("_frage_alt"): ausgabe.append("ÜBERTRAGE %s | %s | %s" % (s["id"], r, str(s["_frage_alt"]).replace("\n", " ")[:200]))
            ausgabe.append("ARCHIVIERE %s | %s | %s | %s" % (s["id"], r, ("%.2f" % k) if k is not None else "fehlt", nummern_aus_titel(s.get("title", "")) or "Betrieb"))
            noch_offen(ausgabe, r, nummern_aus_titel(s.get("title", "")))
            if not marke_zeit("Archiv " + s["id"]): neue_marken.append("Archiv " + s["id"])
    for r in START_REIHE:
        muss, kuer, pause, _ = st.get(r, ([], [], None, []))
        # Hindernis hält nur die Sitzung der Zeile, nicht die Rolle (190.4)
        belegt = [s for s in je_rolle.get(r, []) if s["id"] not in archiviert and (s["_info"][1] or s["_info"][2] < SPERRE_MIN)]
        nf, nf_zeit, nf_grund = nachfolger(r)
        gestartet = nf_zeit is not None and any(z(s["created_at"]) > nf_zeit for s in alle.values() if kosten.rolle(s.get("title", "")) == r)
        if nf and nf_zeit is None:
            ausgabe.append("WARNUNG Nachfolger %s: Übergabe ohne lesbare Zeit, „%s“ nicht gestartet" % (r, nf)); nf = None
        offen_nf = nf if nf and not gestartet else None
        # 347 (6): Pause hält neue Arbeit an, nicht die Ablösung einer Sitzung, die per Übergabe einen Nachfolger nennt
        if pause and not offen_nf:
            ausgabe.append("NICHTS %s: Pause bis %s" % (r, pause))
            continue
        if belegt: ausgabe.append("NICHTS %s: belegt durch %s" % (r, belegt[0].get("title", belegt[0]["id"]))); continue
        if r in marken and (JETZT - marken[r]).total_seconds() < SPERRE_MIN * 60:
            ausgabe.append("NICHTS %s: Startmarke %s jünger als %d Minuten" % (r, marken[r].strftime("%H:%M"), SPERRE_MIN)); continue
        if offen_nf and titel_datum(offen_nf):
            ausgabe.append("NICHTS %s: Nachfolger „%s“ erst %s; Zeilenregel gilt bis dahin" % (r, offen_nf, titel_datum(offen_nf)))
            offen_nf = None
        # 276 (Fall 251): nennt der Nachfolger eine Zeile des eigenen Vorrats, die nicht startbar ist, gilt die Zeilenregel; beim zweiten Lauf laut
        nf_nr = re.search(r"–\s*([0-9][0-9a-zA-Z.]*[0-9a-zA-Z])", offen_nf or "")
        if nf_nr and nf_nr.group(1) in ausschluss:  # 375 (Ford 27.10., 10:05): --ohne gilt auch für den Nachfolger
            ausgabe.append("NICHTS %s: Nachfolger „%s“ ausgeschlossen (--ohne %s); Zeilenregel gilt" % (r, offen_nf, nf_nr.group(1)))
            offen_nf = None
        elif nf_nr and nf_nr.group(1) in GESPERRT.get(r, {}):
            warnen(ausgabe, neue_warnungen, bekannt, r, nf_zeit, "Nachfolger „%s“ nicht startbar (%s), oberste startbare Zeile statt dessen; Übergabe anpassen" % (offen_nf, GESPERRT[r][nf_nr.group(1)]))
            offen_nf = None
        if offen_nf:
            thema = re.sub(r"\s*\([^)]*\)\s*$", "", offen_nf)
            titel = "%s (%s)" % (thema, berlin(JETZT))
            msg = "%s\n\nNachfolger laut Übergabe in %s: %s. Zuerst Start nach deiner Rollendatei, dann die Übergabe lesen und dort weiterarbeiten." % (r, VORRAT[r], offen_nf)
            if muss and muss[0][0] == "Leichen": msg += " Vorher: " + muss[0][2] + "."
            ausgabe.append("START %s | %s | %s | %s | %s | %s | %s" % (r, MODELL[r], UMGEBUNG.get(r, MITTEL), REPO, REVISION, titel, msg.replace("\n", "\\n")))
            vorgaenger(r); sperren.append(r); continue
        if pause:
            ausgabe.append("NICHTS %s: Pause bis %s" % (r, pause)); continue
        muss = [x for x in muss if x[0] not in ausschluss]; kuer = [x for x in kuer if x[0] not in ausschluss]
        wahl = (muss[0] if muss else None) or (kuer[0] if kuer and r in MIT_KUER and not nur_muss else None)
        if not wahl: ausgabe.append("NICHTS %s: %s" % (r, "kein startbares Muss" if r not in MIT_KUER else "nichts Startbares")); continue
        nr, kl, thema, _ = wahl
        thema = re.sub(r"\*\*|`", "", thema)
        # 261.5 (3): neue Arbeit in der alten Sitzung weiter, wenn sie unter WEITER_TOKEN Token liegt und unter 60 Minuten ruht
        alte = [s for s in je_rolle.get(r, []) if not s["_info"][1] and s["_info"][2] < WEITER_MIN and s["id"] not in archiviert and not s.get("_frage_alt")
                and (s.get("context_usage", {}).get("used_tokens") or s.get("external_metadata", {}).get("context_usage", {}).get("used_tokens") or 10**9) < WEITER_TOKEN]
        if alte:
            s = max(alte, key=lambda x: z(x["updated_at"]))
            ausgabe.append("WEITER %s | %s | %s | Weiter: %s (%s) aus %s%s; wird send_message abgelehnt, stattdessen START" % (s["id"], r, nr, nr, "Muss" if kl == "M" else "nach dem Meilenstein" if kl == "N" else "Kür", VORRAT[r],
                ", Freitag: am Ende Rollenspiegel mit tools/rollenspiegel.sh <Rolle>, Datei nicht öffnen (340)" if JETZT.weekday() == 4 else ""))
            sperren.append(r); continue
        titel = "%s – %s (%s)" % (r, nr, berlin(JETZT))
        msg = "%s\n\nArbeite Vorgang %s (%s) aus deinem Vorrat %s; zuerst Start nach deiner Rollendatei, dann den Vorgang lesen und die Übergabe beachten." % (r, nr, "Muss" if kl == "M" else "nach dem Meilenstein" if kl == "N" else "Kür", VORRAT[r])
        if nr == "Leichen": msg += " Leichen: " + thema + "; danach weiter nach Vorrang."
        if JETZT.weekday() == 4: msg += " Freitag: am Ende der Sitzung Rollenspiegel mit tools/rollenspiegel.sh <Rolle>, Datei nicht öffnen (340)."
        ausgabe.append("START %s | %s | %s | %s | %s | %s | %s" % (r, MODELL[r], UMGEBUNG.get(r, MITTEL), REPO, REVISION, titel, msg.replace("\n", "\\n")))
        vorgaenger(r); sperren.append(r)
    # 433 (Chef 31.10., 22:1x: „Da muss doch nicht jetzt Tom drei Wochen auf Tom warten“): arbeitet Tom (Jerry), startet Spike (Tuffy)
    # die nächste startbare Muss-Zeile des Teams, die von der laufenden Arbeit unabhängig ist: andere Nummer, anderer Zweig, nicht „nur Tom“.
    # Nur Muss (Leiharbeiter „notfalls“). Spike setzt zuerst „in Arbeit bei Spike“, dann nimmt das Team die Zeile nicht (startbar.py);
    # endete Spike ohne neuen Stand, startet er auf dieser Zeile wieder, sobald Tom belegt ist.
    def laeuft(rr): return [s for s in je_rolle.get(rr, []) if s["id"] not in archiviert and (s["_info"][1] or s["_info"][2] < SPERRE_MIN)]
    for team, zusatz in (("Tom", "Spike"), ("Jerry", "Tuffy")):
        team_s = laeuft(team); zus_s = laeuft(zusatz)
        team_start = [l for l in ausgabe if l.startswith("START %s " % team) or (l.startswith("WEITER ") and " | %s | " % team in l)]
        if not team_s and not team_start: ausgabe.append("NICHTS %s: %s frei, macht es selbst" % (zusatz, team)); continue
        if zus_s: ausgabe.append("NICHTS %s: belegt durch %s" % (zusatz, zus_s[0].get("title", zus_s[0]["id"]))); continue
        if zusatz in marken and (JETZT - marken[zusatz]).total_seconds() < SPERRE_MIN * 60:
            ausgabe.append("NICHTS %s: Startmarke %s jünger als %d Minuten" % (zusatz, marken[zusatz].strftime("%H:%M"), SPERRE_MIN)); continue
        besetzt = set()
        for s in team_s: besetzt.update(x for x in nummern_aus_titel(s.get("title", "")).split(",") if x)
        for l in team_start:
            m = re.search(r"Vorgang (\S+) \(|^WEITER \S+ \| \w+ \| (\S+) \|", l) if not l.startswith("START") or "Nachfolger laut" not in l else None
            if m: besetzt.add(m.group(1) or m.group(2))
            elif l.startswith("START"): besetzt.add("Nachfolger")  # Nachfolger: Thema aus dem Titel
        alle_m = st.get(team, ([], [], None, []))[0]
        def zweig(x): return x[3].split("|")[-1].strip()
        zweige = {zweig(x) for x in alle_m if any(gleich(x[0], b) for b in besetzt)} - {"–", "-", ""}
        frei = [x for x in alle_m if x[0] not in ausschluss and x[0] != "Leichen" and not any(gleich(x[0], b) for b in besetzt)
                and zweig(x) not in zweige and not re.search(r"nur %s\b" % team, x[2] + x[3])]
        if besetzt == {"Nachfolger"} or not besetzt and not team_s:
            ausgabe.append("NICHTS %s: Arbeit von %s unbekannt (Nachfolger oder Titel ohne Nummer)" % (zusatz, team)); continue
        eigen = [n for n, g in GESPERRT.get(team, {}).items() if g == "in Arbeit bei " + zusatz]
        if eigen: frei = [(eigen[0], "M", "", "")]
        if not frei: ausgabe.append("NICHTS %s: kein zweites unabhängiges Muss bei %s" % (zusatz, team)); continue
        nr, kl, thema, _ = frei[0]
        titel = "%s – %s (%s)" % (zusatz, nr, berlin(JETZT))
        msg = ("%s\n\nArbeite Vorgang %s (Muss) aus dem Vorrat %s als Zusatzentwickler von Team %s (433, ROLLE-ENTWICKLUNG.md); %s arbeitet an %s, das fasst du nicht an. "
               "Zuerst Start nach der Rollendatei, dann sofort `python3 tools/vorgang.py stand %s 'in Arbeit bei %s'` und pushen (sonst nimmt %s die Zeile auch), dann den Vorgang lesen; eigener Zweig; fertig: Stand setzen, keine Übergabe im Vorrat, kein Nachfolger."
               % (zusatz, nr, VORRAT[zusatz], team, team, ", ".join(sorted(besetzt - {"Nachfolger"})) or "Betrieb", nr, zusatz, team))
        ausgabe.append("START %s | %s | %s | %s | %s | %s | %s" % (zusatz, MODELL[team], UMGEBUNG.get(team, MITTEL), REPO, REVISION, titel, msg.replace("\n", "\\n")))
        vorgaenger(zusatz); sperren.append(zusatz)
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
        if not muss or any(l.startswith(("START %s " % r, "NICHTS %s: belegt" % r, "NICHTS %s: Pause" % r, "NICHTS %s: Startmarke" % r, "NICHTS %s: Nachfolger" % r)) or (l.startswith("WEITER ") and " | %s | " % r in l) for l in ausgabe): continue
        ausgabe.append("STILLSTAND %s: Muss %s ohne Sitzung, Protokollzeile „Stillstand %s seit %s“" % (r, muss[0][0], r, JETZT.strftime("%H:%M")))
    # 192.2, Schritt 9: alle Vorräte leer (Muss, Kür, „nach dem Meilenstein“) → Ford meldet einmal am Tag „Vorrat leer“
    if st and all(not st[r][0] and not st[r][1] for r in st if r != "Sokrates"):
        ausgabe.append("VORRAT-LEER: kein startbares Muss, keine Kür, nichts „nach dem Meilenstein“; Ford meldet einmal am Tag „Vorrat leer“")
    # 192.2, Schritt 11: Wochenstart (Mo ab 8 Uhr) und Tagesbericht (247.1), je einmal laut Marke im Protokoll
    heute = JETZT.strftime("%d.%m.")
    # Tagesbericht gilt auch ohne Marke als erledigt, wenn sein Kopf schon steht (22.10.: um 08:10 geschrieben, 19:04 erneut verlangt);
    # ab 24.10. ist es der Stand zum Marktstart (338.1, 341): erledigt, wenn „**Stand <heute>, “ in LISTE-ABNAHME-KAPITEL1.md steht
    marke_text = lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")) + "".join(
        "\nTagesbericht %s" % heute for z in lesen(os.path.join(DOCS, "ARBEIT-TAGESBERICHT.md")).splitlines()
        if z.startswith("## ") and (", %s " % heute) in z) + (
        "\nTagesbericht %s" % heute if ("**Stand %s, " % heute) in lesen(os.path.join(DOCS, "LISTE-ABNAHME-KAPITEL1.md")) else "")
    wochen = []
    def per_start(h, mi):
        return (JETZT.hour, JETZT.minute) >= (h, mi)
    per_belegt = any(s["_info"][1] or s["_info"][2] < SPERRE_MIN for s in je_rolle.get("Perikles", []))
    def einmal(marke, zeile):
        if marke in marke_text: return
        if per_belegt and "| Perikles |" in zeile:
            ausgabe.append("NICHTS Perikles: %s wartet, Perikles läuft (149a)" % marke); return
        ausgabe.append(zeile); wochen.append(marke)
    # 247.1: Tagesbericht täglich ab 7:30 (Sa, So 9:30), ersetzt Morgenbericht und Tagesrückblick (90)
    if per_start(*((9, 30) if JETZT.weekday() >= 5 else (7, 30))):
        einmal("Tagesbericht %s" % heute, "TAGESBERICHT %s | Perikles | Perikles – Stand zum Marktstart %s | Perikles Stand zum Marktstart (338.1)" % (heute, heute))
    if JETZT.hour >= 8:
        if JETZT.weekday() == 0 and JETZT.date() >= datetime.date(2026, 10, 26):  # 19.10. ohne Wochenstart (Protokoll 08:06), Wochenzählung erstmals 26.10.
            m = "Wochenstart %s" % heute
            einmal(m + " Perikles", "WOCHENSTART %s | Perikles | Perikles – Wochenziel %s | Perikles Wochenziel" % (heute, heute))
            einmal(m + " Diogenes", "WOCHENSTART %s | Diogenes | Diogenes – Wochenzählung %s | Diogenes Wochenzählung (Zeile in ARBEIT-PRUEFUNG.md)" % (heute, heute))
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
            # 261.6: Stellungnahme per WEITER in die bestehende Sokrates-Sitzung statt einer zweiten daneben (Bedingungen wie 261.5 (3))
            alte = [s for s in je_rolle.get("Sokrates", []) if s["id"] not in archiviert and s["_info"][2] < WEITER_MIN and not s.get("_frage_alt")
                    and (s.get("context_usage", {}).get("used_tokens") or s.get("external_metadata", {}).get("context_usage", {}).get("used_tokens") or 10**9) < WEITER_TOKEN]
            if alte:
                ausgabe.append("WEITER %s | Sokrates | Stellungnahme | %s; wird send_message abgelehnt, stattdessen START wie sonst" % (juengste(alte)["id"], msg.split("\n\n", 1)[1]))
            else:
                ausgabe.append("START Sokrates | opus | %s | %s | %s | Sokrates – Stellungnahme (%s) | %s" % (MITTEL, REPO, REVISION, berlin(JETZT), msg.replace("\n", "\\n")))
            wochen.append("Stellungnahme Sokrates %s" % heute)
    try:  # 383: Wartewächter
        ww, wm = waechter(je_rolle, marke_text); ausgabe += ww; wochen += wm
    except Exception as e:
        ausgabe.append("WARNUNG Wartewächter fehlgeschlagen: %s (383, Perikles)" % e)
    wochen += vorentscheid_marken + neue_marken
    for l in ausgabe: print(l)
    if not ausgabe: print("NICHTS: nichts zu tun")
    if sperre and (sperren or neue_warnungen or wochen):
        p = os.path.join(DOCS, "ARBEIT-BETRIEB.md"); t = lesen(p).rstrip("\n")
        if sperren: t += "\n- %s %s: Startsperre %s Start %s (lauf.py)\n" % (JETZT.strftime("%H:%M"), JETZT.strftime("%d.%m."), JETZT.strftime("%H:%M"), ", ".join(sperren))
        for m in wochen: t += "\n- %s %s: Marke %s (lauf.py)\n" % (JETZT.strftime("%H:%M"), heute, m)
        for w in neue_warnungen: t += "\n- %s %s: %s (lauf.py)\n" % (JETZT.strftime("%H:%M"), JETZT.strftime("%d.%m."), w)
        open(p, "w", encoding="utf-8").write(t)
        print("Protokoll geschrieben: bitte committen und pushen%s." % (", erst dann create_session" if sperren else ""))
    if sperre:
        n = aufraeumen()
        if n: print("Aufgeräumt: %d Zeilen aus Protokoll und LISTE-VORGAENGE.md (270; Notizen pushen)" % n)
    if besetz: besetzung_schreiben([s for s in leb if s["id"] not in archiviert])

WAECHTER_STUNDEN = 3  # 383 (Chef 27.10., 17:53): Chef sagt „jetzt“ und bekommt drei Stunden lang keine Vorlage → laut an Chef und Sitzung
WAECHTER_AB = datetime.datetime(2026, 10, 27, 19, 0, tzinfo=BERLIN)  # Protokoll der Meldungen gibt es erst ab hier; ältere „jetzt“ zählen nicht
JETZT_FELD = re.compile(r"[„\"]jetzt[“\"]\s*(?:(\d{1,2})\.(\d{1,2})\.,?\s*)?(\d{1,2}):(\d{2})")

def meldungen():
    """Zeilen (Zeit, {Nummern ohne Punkt}, Name, Art) aus dem Zweig „meldungen“ (meldung.sh schreibt je Meldung eine, 383)."""
    try:
        if os.environ.get("BORNIM_MELDUNGEN"): roh = lesen(os.environ["BORNIM_MELDUNGEN"])
        else:
            repo = os.path.join(DOCS, "..")
            subprocess.run(["git", "-C", repo, "fetch", "-q", "origin", "meldungen"], capture_output=True, timeout=30, check=True)
            roh = subprocess.run(["git", "-C", repo, "show", "FETCH_HEAD:meldungen.tsv"], capture_output=True, text=True, timeout=30, check=True).stdout
    except Exception:
        return []
    aus = []
    for l in roh.splitlines():
        t = l.split("\t")
        if len(t) < 4: continue
        try: d = datetime.datetime.strptime(t[0], "%Y-%m-%d %H:%M").replace(tzinfo=BERLIN)
        except ValueError: continue
        aus.append((d, {x.replace(".", "").lower() for x in t[1].split(",")}, t[2], t[3]))
    return aus

def chefsache_seit(nr):
    """Zeit des letzten Commits einer Chefsache-Datei zu nr (auch gelöschte), sonst None."""
    k = nr.replace(".", "").lower()
    try:
        r = subprocess.run(["git", "-C", os.path.join(DOCS, ".."), "log", "-1", "--format=%ct", "--until=%d" % int(JETZT.timestamp()), "--", ":(glob)docs/chefsache/*/%s-*.md" % k],
                           capture_output=True, text=True, timeout=30).stdout.strip()
        return datetime.datetime.fromtimestamp(int(r), BERLIN) if r else None
    except Exception:
        return None

def waechter(je_rolle, marke_text):
    """383: je Vorratszeile mit „jetzt“ TT.MM., HH:MM (Datum fehlt: letztes Datum davor in der Zeile), Stand nicht „ruht“:
    nach drei Stunden ohne Vorlage eine Zeile WÄCHTER. Vorlage = Meldung eines anderen als Ford mit --laut, Bild, Film oder Datei
    zu dieser Nummer, oder eine Chefsache-Datei zur Nummer, seit dem „jetzt“ angelegt oder geändert. Lautlose Standzeilen zählen nicht."""
    offen = {}
    for datei, rolle in startbar.ROLLEN:
        for nr, kl, titel, rest in startbar.zeilen(startbar.lesen(datei)):
            if kl in ("–", "-") or rest.strip().lower().startswith("ruht"): continue
            zeile = titel + " | " + rest
            m = JETZT_FELD.search(zeile)
            if not m: continue
            if m.group(1): tag, mon = int(m.group(1)), int(m.group(2))
            else:
                vorher = re.findall(r"(?<![\d.])(\d{1,2})\.(\d{1,2})\.", zeile[:m.start()])
                if not vorher: continue
                tag, mon = int(vorher[-1][0]), int(vorher[-1][1])
            try: d = JETZT.replace(month=mon, day=tag, hour=int(m.group(3)), minute=int(m.group(4)), second=0, microsecond=0)
            except ValueError: continue
            if d > JETZT + datetime.timedelta(days=1): d = d.replace(year=d.year - 1)
            nr = re.sub(r"\*", "", nr)
            if nr in offen: offen[nr][1].append(rolle)
            else: offen[nr] = (d, [rolle])
    if not offen: return [], []
    ml = meldungen(); aus = []; marken = []
    for nr, (d, rollen) in offen.items():
        if d < WAECHTER_AB or JETZT - d < datetime.timedelta(hours=WAECHTER_STUNDEN): continue
        marke = "Wächter %s %s" % (nr, d.strftime("%d.%m. %H:%M"))
        if marke in marke_text: continue
        k = nr.replace(".", "").lower()
        if any(d <= z <= JETZT and k in nrn and name != "Ford" and art != "text" for z, nrn, name, art in ml): continue
        cs = chefsache_seit(nr)
        if cs and cs >= d: continue
        sitz = [s for r in rollen for s in je_rolle.get(r, [])]
        sid = juengste(sitz)["id"] if sitz else "-"
        std = int((JETZT - d).total_seconds() // 3600)
        aus.append("WÄCHTER %s | %s | %s | %s: Chef „jetzt“ %s, seit %d Std. keine Vorlage (Wartewächter 383); %s: vorlegen oder Chefsache-Datei mit Stand" % (
            nr, ", ".join(rollen), sid, nr, berlin(d), std, ", ".join(rollen)))
        marken.append(marke)
    return aus, marken

def morgenmeldung():
    """192.2, Schritt 10, 247.1: Morgenmeldung als eine Zeile (Ford schickt sie mit meldung.sh --laut); die Seite zum Tag schreibt Perikles um 7:30 als Tagesbericht."""
    chef = os.path.join(DOCS, "chefsache"); n = 0
    for ordner in ("entscheiden", "ansehen", "billigen"):
        d = os.path.join(chef, ordner)
        n += len([x for x in os.listdir(d) if x.endswith(".md")]) if os.path.isdir(d) else 0
    print("Morgen %s: %s in der Chefsache; Stand zum Marktstart folgt um %s. Bitte Bild der Nutzung (Woche %%; ruht die Niederlassung: nur Max)" % (
        JETZT.strftime("%d.%m."), ("%d offen" % n) if n else "nichts offen", "9:30" if JETZT.weekday() >= 5 else "7:30"))

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
        if diff <= 0: print("Kosten %s: %.2f $ für %s schon gebucht, nichts zu tun (mehrere Vorgänge einer Sitzung: eine Kommaliste in einem Aufruf, 379)" % (nr, usd, sid)); return
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
                alt = re.sub(r"^[–-]\s*(;\s*\+)?", "", t[-4])  # 375: „–“ und „–; +N $“ heißen nur N $, Ford las „Kosten …: –“
                m = re.fullmatch(r"([\d,.]+)\s*\$", alt) if alt else None
                if m or not alt:
                    t[-4] = ("%.2f" % ((float(m.group(1).replace(",", ".")) if m else 0.0) + usd)).replace(".", ",") + " $"
                else:  # Nachträge in einem „+N $“ am Ende sammeln statt anhängen (Größe LISTE-VORGAENGE, Perikles 24.10.)
                    m = re.fullmatch(r"(.*); \+([\d,.]+)\s*\$", alt)
                    t[-4] = (m.group(1) if m else alt) + "; +" + ("%.2f" % ((float(m.group(2).replace(",", ".")) if m else 0.0) + usd)).replace(".", ",") + " $"
                L[i] = "| " + " | ".join(t[1:-1]) + " |"
                open(p, "w", encoding="utf-8").write("\n".join(L))
                print("Kosten %s: +%s $, jetzt %s" % (ziel, ("%.2f" % usd).replace(".", ","), t[-4])); return
      kurz = re.sub(r"(\.\d+[a-z]*|[a-z])$", "", ziel)
      if kurz == ziel: break
      ziel = kurz
    print("WARNUNG Kosten: keine Zeile für %s, bitte von Hand auf Betrieb" % nr)

if __name__ == "__main__":
    main()
