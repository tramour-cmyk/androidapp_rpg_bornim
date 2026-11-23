#!/usr/bin/env python3
"""Fords Lauf als Werkzeug (167.2): rechnet, wen Ford startet und was er archiviert; Ford führt nur aus.

Aufruf: python3 tools/lauf.py [--sperre] [--besetzung] [--nur-muss] [--ohne NR:Grund …] SEITE [SEITE …]
SEITE = gespeicherte Ausgabe von list_sessions (mine, alle Seiten bis has_more falsch, wie bei kosten.py)
  ODER Kurzform (Datei mit einer Zeile je Sitzung, kein Abschreiben der Seiten nötig, 167.2):
  `Kennung | working|idle|blocked|need_input|archived|failed | updated_at (ISO) | Titel | Kosten $ (oder -) | created_at | used_tokens (context_usage, für WEITER, 261.5)`
  Letzte Zeile der Kurzform: `# has_more: nein` (erst nach der letzten Seite von list_sessions); fehlt sie oder steht „ja“, warnt lauf.py „Seite abgeschnitten“ (261.4).
Ausgabe, Zeile für Zeile auszuführen:
  START <Rolle> | model | [effort high] | environment_id | source_url | source_revision | Titel | erste Nachricht   → create_session mit allen Feldern, source_url (187) und source_revision main (382) Pflicht (Startsperre vorher pushen: --sperre schreibt sie)
  ARCHIVIERE <session_id> | <Rolle> | <Kosten $> | <Vorgang>        → archive_session, danach --kosten (siehe unten)
  GEBUCHT <session_id> | <Rolle> | <Kosten $> | <Vorgang>           → lauf.py hat selbst gebucht (nur mit --sperre); Ford pusht die Notizen, sonst nichts
  BUCHE <session_id> | <Rolle> | <Kosten $> | <Vorgang>             → nur `--kosten <Vorgang> <Kosten> <session_id>` (ruhende oder schon archivierte Sitzung von heute, Differenz zum Verzeichnis, 261.2)
  PR-ABO <session_id> | <Rolle> | PR #n | an <neuere session_id>    → „PR #“ im Titel: Abo der alten Sitzung an die neuere übergeben (subscribe_pr_activity dort), dann ARCHIVIERE (D40.4)
  ÜBERTRAGE <session_id> | <Rolle> | <Frage>                       → offene Frage der alten Sitzung wörtlich in Vorrat/Chefsache holen (list_events), dann folgt ARCHIVIERE (261)
  WEITER <session_id> | <Rolle> | <Vorgang> | <Nachricht>          → send_message „Weiter: <Vorgang>…“ an die alte Sitzung statt START (unter 200 Tsd. Token, 383 A; unter 60 Minuten Ruhe; abgelehnt → START, 261.5)
  NICHTS <Rolle>: Grund                                             → nichts tun
  LEERLAUF: …                                                       → (1100 A 6) nichts zu starten, melden, pushen: Ford endet sofort, nur Chatzeile, kein Telegram, kein Push
  STELLUNG aus | Co-Pilot: …                                        → (1100 A 1) aus: Ford endet; Co-Pilot: START nicht ausführen (LISTE-BETRIEB.md „Stellung“)
  WARNUNG Abgleich: n Zeilen „gebaut“ oder „zu testen“ ohne Build   → (1100 A 5) Zahl statt der Einzelzeilen; ganz einmal am Tag im ersten Lauf ab 8 Uhr (Marke „Abgleich ganz TT.MM.“)
  WARNUNG …                                                         → Ford meldet es lautlos
  WARNUNG-LAUT …                                                    → Ford meldet es mit --laut (190.7: dieselbe Warnung zum zweiten Mal)
  STILLSTAND <Rolle>: …                                             → Ford schreibt die Protokollzeile „Stillstand <Rolle> seit HH:MM“ (Schritt 5, 192.2)
  STILLSTAND-LÖSEN (1246): …                                         → (1871) Disponent löst je Ursache (Zeile freigeben, Fachkraft starten; an einer Entscheidung: Zeile an Sokrates), höchstens alle 3 Stunden
  KLASSE <Nr (Besitzer)>, …: …                                      → (1871) Disponent setzt Muss oder Kür mit einem Satz Grund (vorgang.py klasse), startet dafür keine Sitzung
  VORRAT-LEER: …                                                    → Ford meldet es einmal am Tag (Schritt 9, 192.2)
  (WOCHENSTART entfällt seit 719: Wochentermine legt --sperre als Muss-Vorgänge an, Zeile „NICHTS <Rolle>: Wochentermin <Nr> angelegt …“; Ford pusht die Notizen, gestartet wird per START)
  TAGESBERICHT TT.MM. | Perikles | [effort high] | Titel | erste Nachricht                → dasselbe für den Tagesbericht ab 7:30, Sa, So 9:30 (247.1, Marke „Tagesbericht TT.MM.“);
                                                                     mit tools/1727-SCHARF statt dessen START Tagesbericht (Routine, routine-tagesbericht.md, 1871)
  NEUSTART-LEITUNG <session_id> | Sokrates | <n> Tsd. Token | …     → (1988) Disponent: Leitung neu starten (Übergabe ins Gedächtnis), im selben Takt wie STREICHEN; ab 300 Tsd. used_tokens
  NEUSTART-DISPONENT <session_id> | Disponent | <n> Tsd. Token | … → (1988 Zusatz 09:26) Disponent: Übergabe zuerst, dann startet der Disponent seinen Nachfolger selbst (lauf.py --start Disponent, 1992); ab 300 Tsd.
  (1988 Zusatz 09:26) dieselbe WARNUNG-Zeile (gleicher Wortlaut, auch -LAUT) höchstens einmal je Stunde; Stand in BORNIM_WARN_STAND (Vorgabe /tmp/bornim-lauf-warnungen.json)
  (1989) lauf.py --start ROLLE NR "Nachricht" [SEITE …] [--sperre]: Handstart außerhalb des Takts → START-Zeile mit Startblock und
                                                                     STARTSPERRE <Protokollzeile> (mit --sperre selbst gepusht); von Hand nur so starten
  NACHRICHT <Rolle> | <session_id|-> | <Text>                        → (1739) send_message <Text> an die Sitzung; bei - (Ford) tut Ford es selbst
  (1739) offene Übergabezeile an eine Rolle ohne Sitzung → START dieser Rolle (Titel „<Rolle> – <Nr>: offene Übergabe“) oder angehängt an ihre START-Zeile; mit --sperre gibt der Lauf abgelaufene Fristen ruhender Halter frei (Zeile „NICHTS Übergabe: …“, schon gepusht)
  HÖCHSTDAUER <session_id> | <Rolle> | <Nr> | <Text>                → (1766, erst mit tools/1727-SCHARF und Wert in HOECHSTDAUER_MIN) interrupt_session, dann `vorgang.py rueckmeldung <Nr> "<Text>" --sitzung Ford`, pushen
  GUTHABEN … / LAUFSPERRE …                                         → (1804, erst mit tools/1727-SCHARF; tools/guthaben.py) Stufe nach 287 und Laufsperre aus Chefwort; lauf.py hält die Starts selbst an („NICHTS <Rolle>: Guthaben …“), Disponent startet nicht von Hand vorbei; lauf.py jeden Takt, nur START-Zeilen ruhen (1978)
  NACHHALTEN TT.MM.: …                                              → Ford führt LISTE-BETRIEB.md Schritt 8 aus (einmal am Tag ab 8 Uhr, 927)
  WARNUNG(-LAUT) Sitzung hängt / Sitzung wartet auf Freigabe (blocked ab 15 Min., 1572) / Jetzt installieren / Übergabe wartet auf Chef → wie jede Warnung melden, nachts lautlos (Schritt 9, 927)
  TAGESBERICHT-FEHLT TT.MM.: …                                      → Disponent meldet laut eine Zeile an den Chef (448); die TAGESBERICHT-Zeile (scharf: START Tagesbericht) daneben startet ihn erneut
  WÄCHTER <Nr> | <Rollen> | <session_id|-> | <Text>                  → Ford: meldung.sh --laut Ford "<Text>" und send_message <Text> an die Sitzung (383; einmal je „jetzt“, Marke schreibt --sperre; auch 559: „wartet auf Chef“ trotz neuerer Rückmeldung, einmal je Rückmeldung)
  AUSGESCHLOSSEN NR: Grund                                          → Ford hat die Zeile mit --ohne ausgeschlossen; Ford meldet Grund lautlos (190.2)
  OHNE-ÜBERHOLT NR: Grund                                           → (1129.1 P1) der Ausschluss gilt nicht mehr (Nummer im Archiv, ruht, oder „in Arbeit“ ohne Sitzung seit 2 h): Ford streicht --ohne NR ab dem nächsten Lauf, auch in seiner Übergabe
  URTEIL <Text>, Nachricht <Kennung>                              → (1228) offenes 👍/👎/✅ des Chefs: Ford erledigt es wie jeder (Archiveintrag mit Wortlaut und „Nachricht <Kennung>“, Datei der Chefsache weg, Stand); steht die Kennung schon im Archiv, nichts
  GELÖST <Nr> | <Rolle> | wartet auf … erfüllt | <session_id|->      → send_message „GELÖST <Nr>: wartet auf … erfüllt, startbar“ an die Sitzung (bei - nichts; „bleibt gesperrt“: nichts); --sperre hat die Zeile gesetzt (275.2), Notizen pushen
  (Bedeutung dieser Zeilen ist Fords Anleitung, LISTE-BETRIEB.md „Jeder Lauf“ 4 verweist hierher, 276)
--ohne NR:Grund  (mehrfach) schließt die Zeile NR für diesen Lauf aus; lauf.py nimmt dann die nächste startbare Zeile derselben Rolle (190.2). Ohne Grund gilt es nicht.
             Steht statt NR ein Rollenname (auch Spike), fällt die Rolle ganz aus dem Lauf: kein START, kein ARCHIVIERE, keine Warnung „Start nicht angekommen“ (1148).
             Dasselbe tut die Marke „Lauf läuft bis TT.MM., HH:MM“ oben im Vorrat (höchstens 12 h voraus), solange die Zeit nicht vorbei ist (Hintergrundlauf in der Sitzung).
--wecker ID[,ID]  (mehrfach) Sitzungen mit offenem eigenem Weckruf (list_triggers: enabled, next_run_at in der Zukunft, persistent_session_id) gelten als laufend:
             belegen ihre Rolle (auch Spike), werden nicht archiviert und bekommen kein WEITER, auch nach 20 oder 60 Minuten Ruhe (916, Tuffy 784 am 11.11.).
--ohne-pull  lässt das Vorspulen der Notizen aus (380: sonst zieht lauf.py bornim-main auf origin/main und bricht ab, wenn das nicht geht).
--nur-muss   startet nur Muss, keine Kür und nichts „nach dem Meilenstein“ (D31.3: Ford setzt es bei `allowed_warning` vor Wochenmitte, D20.2).
--sperre     trägt „Startsperre HH:MM Start <Name>“ ins Protokoll von ARBEIT-BETRIEB.md (Ford pusht, erst dann create_session).
             Scharf (tools/1727-SCHARF, 1892): bei jedem START setzt lauf.py die Startsperre selbst und pusht sie (auch ohne --sperre).
--aufraeumen kürzt Fords Protokoll auf die 20 neuesten Taten (plus Marken von heute, Startsperren auch von gestern, solange lauf.py sie prüft, 1187) und schiebt erledigte Zeilen von LISTE-VORGAENGE.md ins Archiv (270); --sperre tut es in jedem Lauf.
--liegt     Lauf auf eine Meldung „Start <Rolle> <Nr>, <Commit>“ (891): ruhende Sitzungen (nicht working/blocked) unter 20 Minuten belegen die Rolle nicht;
             neue Arbeit geht per WEITER in sie (unter 200 Tsd. Token), sonst START. Startmarke und laufende Sitzungen gelten wie sonst.
--besetzung  erlaubt, ohne Wirkung (1997): jeder vollständige Lauf schreibt am Ende Tabelle und Zeitmarke von ARBEIT-BESETZUNG.md
             und pusht sie selbst (Zeile HERZSCHLAG gepusht; sonst HERZSCHLAG NICHT GEPUSHT: Disponent pusht).
--kosten NR USD SESSION_ID  addiert USD auf die Kostenspalte der Zeile NR in LISTE-VORGAENGE.md oder -ARCHIV.md (Ford ruft es je ARCHIVIERE-Zeile, mit der Kennung).
  Kennung Pflicht (384: nachts gebuchte Sitzungen ohne Kennung waren nicht mehr nachweisbar); ohne Sitzung nur `ohne:<Grund>`. USD frisch aus get_session nach dem Archivieren
  (384: 3,13 statt 6,31 $ aus einer alten Abfrage gebucht).
  Mit Kennung gilt das Buchungsverzeichnis docs/KOSTEN-GEBUCHT.tsv (191): gebucht wird nur die Differenz zu früher Gebuchtem, damit wieder geöffnete oder doppelt archivierte Sitzungen nichts doppelt kosten.
Offene „M?“ erscheinen als eine Zeile KLASSE für den Disponenten (1871 Stilllegung C (g), ersetzt die Muss-Zeile „M? entscheiden“ für Perikles, 190.8).
Stillstand (1246): keine Rolle mit startbarem Muss, keine Sitzung arbeitet, Muss-Zeilen warten auf eine startbare Zeile einer Rolle, die lauf.py nicht startet → Zeile STILLSTAND-LÖSEN für den Disponenten (1871, statt Muss-Zeile für Perikles), Marke „Stillstand“, höchstens alle 3 Stunden.
Kosten: Sitzungen buchen auf die Nummern im Titel, auch Sokrates („Kosten auf“ der Übergabe fällt, 197; 1871); die Freigabe ab 40 $ (1538) fällt (Archiv „Dollar-Freigabe weg“ 20.11., 08:19).
Jeder Lauf hängt die WARNUNG-Zeilen von abgleich.py an (191).
Regeln (LISTE-BETRIEB.md, ROLLE-BETRIEB.md): Tom, Jerry, Diogenes, Homer, Perikles: Muss vor Kür, Kür vor Leerlauf (196), danach Zeilen „nach dem Meilenstein“ (190.10); Sokrates, Ford nie.
Nachfolger (190.7): nennt die Übergabe im Vorrat „Nachfolger: <Titel>“ und gibt es seither keine Sitzung der Rolle, startet lauf.py diese (vor Muss und Kür,
auch bei Homer, Perikles); ein Datum in der Zukunft im Titel schiebt den Start, „keiner“ und „nur wenn …“ lassen die Zeilenregel gelten. Kann sie nicht starten
(Titel ohne Zeit in der Übergabe; eine Pause im Vorrat hält den Nachfolger nicht auf, nur neue Arbeit, 347), steht WARNUNG mit Grund; beim zweiten Lauf mit derselben Übergabe WARNUNG-LAUT (Protokollzeile „Nachfolger-Warnung“, --sperre schreibt sie).
Nennt der Nachfolger („<Rolle> – <Nr> …“) eine nicht startbare Zeile des eigenen Vorrats, gilt die Zeilenregel, mit derselben Warnung (276, Fall 251).
„Auf Abruf“ oder „auf Zuruf“ im Nachfolger ist kein Auftrag: ohne Startbares NICHTS (641), sonst gilt die Zeilenregel mit Titel und Nachricht der Zeile (921).
Dateien der Chefsache und „wartet auf Chef“ halten keine Sitzung (261.4: die Frage steht in der Chefsache, nicht in der Sitzung);
Archivregel (261.5, vier Sätze; nur Ford ausgenommen): (1) je Bereich höchstens eine Sitzung, Bereich = Rolle laut Titel; ohne Rolle im Titel bleibt die Sitzung stehen, WARNUNG einmal;
(2) gibt es mehr als eine, archiviert Ford die ältere, also jede außer der zuletzt tätigen (späteres updated_at, nicht created_at; 261.6) (bei START im selben Lauf: ARCHIVIERE-Zeilen der alten Sitzungen direkt nach der START-Zeile), sobald die neuere läuft und die ältere nicht mehr arbeitet (261.5 Wartezeit, Chef 21.10., 16:46: keine 60 Minuten mehr; offene Frage: vorher ÜBERTRAGE; PR-Abo: Ford übergibt es vorher an die neuere Sitzung); (3) neue Arbeit geht per WEITER in die alte Sitzung,
wenn sie unter 200 Tsd. Token liegt (383 A, Chef 09.11.; vorher 400 Tsd. nach 383.1) und unter 60 Minuten ruht, sonst START; (4) Kostenbuchung bleibt eigene Regel (--kosten, GEBUCHT). Kein Hindernis hält eine Sitzung.
Prüfung des Ergebnisses: steht dieselbe Sitzung im nächsten Lauf wieder auf ARCHIVIERE, gibt es WARNUNG-LAUT „Disponent hat … nicht ausgeführt“ (Marke „Archiv <id>“); mehr als eine Sitzung je Bereich in zwei Läufen hintereinander
gibt WARNUNG-LAUT (Marke „Mehrfach <Rolle>“). Marken schreibt nur --sperre.
Startprüfung (837): gibt es 5 Minuten nach der jüngsten Startsperre einer Rolle keine Sitzung dieser Rolle (neu angelegt oder, bei WEITER, danach tätig),
steht WARNUNG-LAUT „Start <Rolle> nicht angekommen“ (einmal, Marke „Start-fehlt <Rolle> <Zeit>“; START ausgelassen ohne --ohne oder gescheitert), und die Sperre belegt die Rolle nicht mehr.
Laufend = Status working/blocked und updated_at jünger als 60 Minuten, oder offener Weckruf (--wecker, 916) (Start-Sperre und Belegung 20 Minuten). Laufend oder jünger als 20 Minuten: Rolle belegt, kein zweiter Start.
Nicht Sache des Werkzeugs: „Neustart <Name>, <Commit>“ (Nachricht), Eingang, Leermeldung eines Teams (bleiben bei Ford, LISTE-BETRIEB.md „Jeder Lauf“).
"""
import glob, os, re, sys, datetime, zoneinfo, subprocess
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
UMGEBUNG = {}  # alle MITTEL (Chef 09.11., 07:23: „Der Aufwand ist auf Mittel“); Probe 365 endete 31.10.; HOCH nur auf Wort des Chefs
HOCH_BIS = datetime.datetime(2026, 11, 13, 22, 4, tzinfo=BERLIN)  # 901: 365a B (Chef 11.11., 07:18), alle Rollen HOCH; vorgezogen (Chef 13.11., 22:04: „Aufwand, Mittel für alle ab sofort“), seitdem MITTEL
def aufwand(hoch=False):
    """981 (Chef 11.11., 18:04): bis HOCH_BIS oder für einen Start mit hoch (827.1) Feld „ | effort high“ hinter dem Modell
    (create_session effort: "high"), sonst leer (Feld weglassen)."""
    return " | effort high" if hoch or JETZT < HOCH_BIS else ""
def umgebung(r, hoch=False):
    """901: Umgebung für den Start einer Rolle; bis HOCH_BIS alle HOCH, für einen Start mit hoch (827.1) HOCH, sonst UMGEBUNG/MITTEL."""
    if hoch or JETZT < HOCH_BIS:
        return HOCH
    return UMGEBUNG.get(r, MITTEL)
REPO = "https://github.com/tramour-cmyk/androidapp_rpg_bornim"  # ohne source_url startet die Sitzung ohne Repo (18.10., Jerry 39; 187)
REVISION = "main"  # 382: ohne source_revision lasen neue Sitzungen einen alten Stand (26.10., ohne add_repo-Erlaubnis; Tom 376.1a)
# 1472 (Chef 16.11., 18:07: „Erst in die Startnachricht bei allen Beschäftigten“): add_repo gelang nur mit der Erlaubnis im Gespräch
# (Tom 17:21, Jerry 10:58), nicht allein mit autoMode.allow (Spike 13:09); darum steht das Chefwort in jeder START- und WEITER-Nachricht
def kern(rolle):
    """1683 (Chef 18.11., 16:54 „Kern über lauf.py, genauso“): Abschnitt „## Kern“ der Rollendatei, deren erste Zeile die Rolle nennt
    (ROLLE-TECHNIK.md „# Technik (Spike)“, ROLLE-BERATUNG-START.md „# Startprompt Sokrates“), bis zur nächsten „## “-Überschrift;
    mit „## Schwerpunkte“ dahinter dazu Schwerpunkt A (ohne Angabe A, ROLLE-BERATUNG-START.md 1). Ohne solche Datei leer.
    1893: an der neuen Liste der Ladetext des Profils `docs/profile/<Profil>.md` (werkzeuge.md Schritt 8): die Datei ohne Kopfzeile
    „# …“ und die Leerzeile danach (Messregel), bis zum ersten „## “; ohne Datei leer (Start ohne Kern, wie bisher)."""
    if NEU_LISTE:
        p = os.path.join(DOCS, "profile", "%s.md" % rolle)
        if not os.path.isfile(p): return ""
        zeilen = lesen(p).split("\n")
        if zeilen and zeilen[0].startswith("# "): zeilen = zeilen[1:]
        j = next((k for k, z in enumerate(zeilen) if z.startswith("## ")), len(zeilen))
        return "\n".join(zeilen[:j]).strip()
    for p in sorted(glob.glob(os.path.join(DOCS, "ROLLE-*.md"))):
        zeilen = lesen(p).split("\n")
        if not zeilen or not re.search(r"\b%s\b" % re.escape(rolle), zeilen[0]): continue
        try: i = next(k for k, z in enumerate(zeilen) if z.startswith("## Kern"))
        except StopIteration: continue
        j = next((k for k in range(i + 1, len(zeilen)) if zeilen[k].startswith("## ")), len(zeilen))
        teil = zeilen[i + 1:j]
        if j < len(zeilen) and zeilen[j].startswith("## Schwerpunkte"):
            a = next((k for k in range(j + 1, len(zeilen)) if zeilen[k].startswith("### A ")), None)
            if a is not None:
                b = next((k for k in range(a + 1, len(zeilen)) if zeilen[k].startswith(("### ", "## "))), len(zeilen))
                teil += zeilen[a:b]
        text = "\n".join(teil).strip().rstrip("-").strip()
        if text: return text
    return ""


# 1923 (1727j Startblock, Chef 22.11., 11:09 „Startblock ja, V7 genauso.“): an der neuen Liste setzt lauf.py jede Startnachricht
# aus Kern, Fachprofil, Querprofilen (wörtlich, je docs/profile/<Name>.md nach Messregel) und Auftrag zusammen; CLAUDE.md ist dann
# nur der Sockel und steht nie in der Nachricht (nichts doppelt). Fehlt eine Profildatei, fehlt nur dieser Teil (Zeile WARNUNG).
KERN_VON = {"Disponent": ["Kern Büro"], "Arbeitsplaner": ["Kern Büro"], "Prüfer": ["Kern Abnahme"], "Tester": ["Kern Abnahme"],
            "Sokrates": ["Kern Leitung"]}  # 1986 (Chef 23.11., 08:26 A): Leitung = Sockel + Kern Leitung + Gedächtnis (leitung_block)
GEDAECHTNIS = os.path.join("leitung", "gedaechtnis.md")  # 1986: unter DOCS, ganz (ohne Kopfzeile und Leerzeile)
# Querprofile, die der Auftrag zulädt (Kern Arbeitsplaner Feld 4 „Beachte“; Kern Abnahme „beide lädt der Auftrag zu“)
QUER_AUS_AUFTRAG = [("Signatur und Leben", re.compile(r"Querprofil\s+(?:„)?Signatur und Leben")),
                    ("Fremde Inhalte", re.compile(r"Querprofil\s+(?:„)?Fremde Inhalte")),
                    ("Werkzeug", re.compile(r"\bProfil\s+(?:„)?Werkzeug\b"))]
KAUFREPO_PROFIL = "Zugang Kaufrepo"  # V7: eigenes Profil, fest für die Liste BRAUCHT_KAUFREPO
# Liste „braucht Kaufrepo“ (V7): Build-Macher (Technik), Tester, alle, die das Spiel starten (Fachprofile der Spielblöcke außer Regeln,
# Story, Werkzeug); der Prüfer nur bei Bildaufträgen (Auftrag lädt Signatur und Leben zu)
BRAUCHT_KAUFREPO = {"Technik", "Tester", "Kampf", "Figur", "Kataloge", "Welt", "Klang", "Oberfläche"}
STARTBLOCK_FEHLT = []  # 1923: (Rolle, Teil) ohne Profildatei in diesem Lauf, main() gibt WARNUNG aus

def ladetext(name, docs=None):
    """1923: Ladetext von docs/profile/<name>.md nach Messregel (ohne Kopfzeile „# …“ und Leerzeile, bis vor „## “); None ohne Datei."""
    p = os.path.join(docs or DOCS, "profile", "%s.md" % name)
    if not os.path.isfile(p): return None
    zeilen = lesen(p).split("\n")
    if zeilen and zeilen[0].startswith("# "): zeilen = zeilen[1:]
    j = next((k for k, z in enumerate(zeilen) if z.startswith("## ")), len(zeilen))
    return "\n".join(zeilen[:j]).strip()

def startblock(rolle, nr, docs=None):
    """1923: (Teile [(Name, Text)], Auftrag oder None) für den Start von rolle zu Vorgang nr: Kern (KERN_VON), Fachprofil (rolle),
    Querprofile aus dem jüngsten Auftrag der Vorgangsdatei (QUER_AUS_AUFTRAG, nie das eigene Fachprofil doppelt), Zugang Kaufrepo
    nach BRAUCHT_KAUFREPO (Prüfer: nur mit Signatur und Leben). Teile ohne Datei fallen weg und stehen in STARTBLOCK_FEHLT."""
    auftrag = None
    if nr:
        p = os.path.join(docs or DOCS, "vorgang", "%s.md" % nr)
        text = lesen(p) if os.path.isfile(p) else ""
        ab = juengster_auftrag(text)
        if ab: auftrag = text[ab[0]:ab[1]].strip() or None
    namen = list(KERN_VON.get(rolle, [])) + [rolle]
    quer = [n for n, rx in QUER_AUS_AUFTRAG if auftrag and rx.search(auftrag) and n not in namen]
    namen += quer
    if rolle in BRAUCHT_KAUFREPO or (rolle == "Prüfer" and "Signatur und Leben" in quer): namen.append(KAUFREPO_PROFIL)
    teile = []
    for n in namen:
        t = ladetext(n, docs)
        if t: teile.append((n, t))
        elif (rolle, n) not in STARTBLOCK_FEHLT: STARTBLOCK_FEHLT.append((rolle, n))
    return teile, auftrag

def leitung_block(docs=None):
    """1986: Teile [(Name, Text)] für jede START- und WEITER-Zeile an Sokrates: Kern Leitung (docs/profile/Kern Leitung.md nach
    Messregel) und das Gedächtnis ganz, ohne seine Kopfzeile und die Leerzeile danach (alle Abschnitte); kein Fachprofil, kein
    Auftrag aus der Vorgangsdatei, nichts aus ROLLE-BERATUNG-START.md. Fehlt eine Datei, fehlt nur dieser Teil (STARTBLOCK_FEHLT)."""
    teile = []
    for n in KERN_VON["Sokrates"]:
        t = ladetext(n, docs)
        if t: teile.append((n, t))
        elif ("Sokrates", n) not in STARTBLOCK_FEHLT: STARTBLOCK_FEHLT.append(("Sokrates", n))
    p = os.path.join(docs or DOCS, GEDAECHTNIS)
    z = lesen(p).split("\n") if os.path.isfile(p) else []
    if z and z[0].startswith("# "):
        z = z[1:]
        if z and not z[0].strip(): z = z[1:]
    t = "\n".join(z).strip()
    if t: teile.append(("Gedächtnis", t))
    elif ("Sokrates", "Gedächtnis") not in STARTBLOCK_FEHLT: STARTBLOCK_FEHLT.append(("Sokrates", "Gedächtnis"))
    return teile

def nr_aus_titel(kopf):
    m = re.search(r"–\s*(\d{3,4}(?:\.\d+)?)\b", kopf.rpartition(" | ")[2])
    return m.group(1) if m else None

def mit_kern(l, docs=None):
    """1683: jede START-Zeile beginnt in der ersten Nachricht (letztes Feld) mit dem Kern der Rolle, darunter „Auftrag:“ und die bisherige Nachricht.
    1893: an der neuen Liste Ladetext des Profils statt Kern; „Start nach deiner Rollendatei“ heißt dort „den Ladetext oben“ (Profile ohne Rollendatei).
    1923: an der neuen Liste Startblock (startblock): Teile je mit Kopfzeile „**<Name>**“, dann „Auftrag:“ mit dem jüngsten Auftrag der
    Vorgangsdatei wörtlich und der bisherigen Nachricht.
    1986: Sokrates an alter und neuer Liste mit leitung_block (Kern Leitung, Gedächtnis), auch in jeder WEITER-Zeile an Sokrates."""
    if l.startswith("WEITER ") and l.count(" | ") >= 3 and l.split(" | ", 2)[1].strip() == "Sokrates":
        kopf3, msg = l.split(" | ", 3)[:3], l.split(" | ", 3)[3]
        k = "\n\n".join("**%s**\n%s" % (n, t) for n, t in leitung_block(docs))
        return "%s | %s" % (" | ".join(kopf3), ("%s\n\nAuftrag: %s" % (k, msg) if k else msg).replace("\n", "\\n"))
    if not l.startswith("START "): return l
    rolle = l[6:].split(" |", 1)[0].strip()
    if rolle in ROUTINE_ROLLEN: return l  # 1789: Routine ohne Kern (Archiv 20.11., 07:37 „nicht deinen Kern“)
    kopf, _, msg = l.rpartition(" | ")
    auftrag = None
    if rolle == "Sokrates":  # 1986
        k = "\n\n".join("**%s**\n%s" % (n, t) for n, t in leitung_block(docs))
    elif NEU_LISTE:
        teile, auftrag = startblock(rolle, nr_aus_titel(kopf), docs)
        k = "\n\n".join("**%s**\n%s" % (n, t) for n, t in teile)
    else:
        k = kern(rolle)
    if NEU_LISTE or rolle == "Sokrates":
        msg = msg.replace("zuerst Start nach deiner Rollendatei, dann", "zuerst den Ladetext oben, dann" if k else "zuerst").replace(
            "Zuerst Start nach deiner Rollendatei.", "Zuerst den Ladetext oben." if k else "")
    if rolle == "Sokrates":  # 1986: Stellungnahme (194.2) endet auf „; zuerst Start nach deiner Rollendatei.“
        msg = msg.replace("; zuerst Start nach deiner Rollendatei.", "; zuerst den Ladetext oben." if k else ".")
    if rolle == "Tester":  # 1795 (Sokrates 22.11., 09:41): der Tester meldet als Absender „Tester“, unter der Nummer des Auftrags
        m = re.search(r"–\s*(\d{3,4}(?:\.\d+)?)\b", kopf.rpartition(" | ")[2]) or re.search(r"\bVorgang\s+(\d{3,4}(?:\.\d+)?)\b", msg)
        if not m:  # 1912 (D344.1): Zahl nach „Build“ oder „t“ (t312) ist der Build, nicht der Vorgang
            m = next((x for x in re.finditer(r"(?<![\d.:,])(\d{3,4}(?:\.\d+)?)\b", msg) if not re.search(r"(?i)(?:\bBuilds?\s*|\bt)$", msg[:x.start()])), None)
        msg += "\\n\\nMeldung: `vorgang.py rueckmeldung %s \"Befunde: n …\" --sitzung Tester` (1795)." % (m.group(1) if m else "<Nr>")
    if auftrag: msg = "%s\n\n%s" % (auftrag, msg.replace("\\n", "\n"))  # 1923: Auftrag wörtlich vor der bisherigen Nachricht
    msg = msg.replace("\n", "\\n")
    if not k: return "%s | %s" % (kopf, ("Auftrag: " + msg) if auftrag else msg)
    return "%s | %s\\n\\nAuftrag: %s" % (kopf, k.replace("\n", "\\n"), msg)

LEITUNG_NEUSTART_TOKEN = 300000  # 1988 (Chef 23.11., 09:02): Leitung mit 430 Tsd. Token stempelte 20 Min. vor; Zusatz 09:26: auch Disponent
NEUSTART_ZEILE = {"Sokrates": ("NEUSTART-LEITUNG", "Leitung neu starten (Übergabe ins Gedächtnis)"),
                  "Disponent": ("NEUSTART-DISPONENT", "Übergabe zuerst, dann startet der Disponent seinen Nachfolger selbst mit `lauf.py --start Disponent`; der Nachfolger archiviert den Vorgänger")}  # 1992 (Chef 23.11., 10:04)

def wache_id():
    """1988 (4): Kennung der Wache aus ARBEIT-BETRIEB.md („**Wache (aktuell)** `session_…`“), sonst „-“."""
    m = re.search(r"\*\*Wache \(aktuell\)\*\* `(session_\w+)`", lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")))
    return m.group(1) if m else "-"

def leitung_neustart(je_rolle, archiviert, wache=None):
    """1988: je nicht archivierte Sitzung der Leitung (Sokrates) und, Zusatz 09:26, des Disponenten mit used_tokens
    (context_usage, get_session) ab 300.000 eine Zeile an den Disponenten; ohne Wert keine Zeile."""
    aus = []
    for rolle, (art, text) in NEUSTART_ZEILE.items():
        for s in je_rolle.get(rolle, []):
            tok = s.get("context_usage", {}).get("used_tokens") or s.get("external_metadata", {}).get("context_usage", {}).get("used_tokens")
            if s["id"] not in archiviert and tok and tok >= LEITUNG_NEUSTART_TOKEN:
                if "%s" in text: text = text % (wache or wache_id())
                aus.append("%s %s | %s | %d Tsd. Token | %s (1988, ab %d Tsd.)" % (art, s["id"], rolle, tok // 1000, text, LEITUNG_NEUSTART_TOKEN // 1000))
    return aus

NEUSTART_ARTEN = ("NEUSTART-LEITUNG ", "NEUSTART-DISPONENT ")
def vorn(zeilen):
    """1688, 1988: STREICHEN-Zeilen zuerst, dann NEUSTART-LEITUNG, NEUSTART-DISPONENT, sonst Reihenfolge unverändert."""
    return [l for l in zeilen if l.startswith("STREICHEN ")] + [l for a in NEUSTART_ARTEN for l in zeilen if l.startswith(a)] + \
        [l for l in zeilen if not l.startswith(("STREICHEN ",) + NEUSTART_ARTEN)]

WARN_STAND = os.environ.get("BORNIM_WARN_STAND", "/tmp/bornim-lauf-warnungen.json")
def warnung_einmal_je_stunde(zeilen, pfad=None, jetzt=None):
    """1988 (Zusatz Chef 09:26): dieselbe WARNUNG-Zeile (gleicher Wortlaut, auch WARNUNG-LAUT) höchstens einmal je Stunde.
    Stand (Zeile → Zeit) in pfad; ist er nicht les- oder schreibbar, bleiben alle Warnungen stehen (lieber doppelt als verschluckt)."""
    import json
    pfad, t = pfad or WARN_STAND, (jetzt or JETZT).timestamp()
    try: stand = json.load(open(pfad, encoding="utf-8"))
    except Exception: stand = {}
    neu, aus = dict(stand), []
    for l in zeilen:
        if l.startswith("WARNUNG"):
            if l in stand and 0 <= t - stand[l] < 3600: continue
            neu[l] = t
        aus.append(l)
    try:
        with open(pfad, "w", encoding="utf-8") as f: json.dump({k: v for k, v in neu.items() if t - v < 3600}, f, ensure_ascii=False)
    except Exception:
        return zeilen
    return aus


def mit_rufnamen(ausgabe, sitzungen, jetzt=None, namen=None):
    """1739 Rufnamen (erst mit tools/1727-SCHARF): jede START-Zeile außer Sokrates bekommt den nächsten freien Rufnamen des
    Tages (rufname.py) als erstes Wort des Titels statt der Rolle, und die erste Nachricht nennt ihn. Die Rolle bleibt im
    ersten Feld (Startsperre, Kern, Profil). 1957: namen (Rolle → Rufnamen in START-Folge) geht in die Startsperre; daraus finden
    Kosten, Archivregel, Startprüfung und Belegung die Startrolle (rufname.rolle), nicht den Besitzer des Vorgangs im Titel."""
    import rufname
    belegt = rufname.heute_vergeben([(s.get("title", ""), s.get("created_at", "")) for s in sitzungen], jetzt or JETZT)
    aus = []
    for l in ausgabe:
        teile = l.split(" | ", 6)
        if not l.startswith("START ") or len(teile) < 7 or teile[0][6:].strip() in ("Sokrates",) + tuple(ROUTINE_ROLLEN):
            aus.append(l); continue
        n = rufname.naechster(belegt)
        if not n:
            aus.append(l); aus.append("WARNUNG Rufname: alle Namen heute vergeben, Titel mit Rolle (1739)"); continue
        belegt.append(n)
        if namen is not None: namen.setdefault(teile[0][6:].strip(), []).append(n)
        t = teile[5]
        teile[5] = n + t[t.index(" – "):] if " – " in t else "%s – %s" % (n, t)
        teile[6] = "Dein Rufname: %s (Rolle %s; Titel, Besetzung, Meldung).\\n\\n%s" % (n, teile[0][6:].strip(), teile[6])  # „Rolle“ liest startsperre-haken.py
        aus.append(" | ".join(teile))
    return aus


KAUFREPO = " Das Kaufrepo schaltest du bei Bedarf selbst mit add_repo frei, so wie es der Chef festgelegt hat und wie es auch in deiner Rollendatei steht."  # Wortlaut Chef 16.11., 18:13
KAUFREPO_SCHARF = " Das Kaufrepo schaltest du bei Bedarf selbst mit add_repo frei, so wie es der Chef festgelegt hat und wie es auch in deinem Sockel steht."  # 1781 (Chef 21.11., 21:38 „Sockel, ja“), erst mit tools/1727-SCHARF
def kaufrepo_satz(scharf=None):
    """1781: nach der Umschaltung (tools/1727-SCHARF) gibt es keine Rollendateien mehr; der Satz verweist dann auf den Sockel."""
    return KAUFREPO_SCHARF if (ist_scharf() if scharf is None else scharf) else KAUFREPO
def mit_kaufrepo(l, scharf=None):
    """1472/1803/1781: Kaufrepo-Satz an jede Startnachricht (START: letztes Feld, auch Routinen und Starts aus auftrag.py; Archiv 1472,
    1781), bei WEITER vor dem Hinweis auf send_message. Steht schon einer der beiden Sätze darin, bleibt die Zeile, wie sie ist."""
    k = kaufrepo_satz(scharf)
    if l.startswith("START "): return l if l.endswith(KAUFREPO) or l.endswith(KAUFREPO_SCHARF) else l + k
    if l.startswith("WEITER ") and KAUFREPO not in l and KAUFREPO_SCHARF not in l: return l.replace("; wird send_message", ";" + k + " Wird send_message", 1)
    return l
MODELL = {"Tom": "opus", "Spike": "opus", "Homer": "opus", "Sokrates": "opus", "Jerry": "opus", "Perikles": "opus", "Diogenes": "opus"}  # 270: alle außer Ford groß (Chef 09.11., 13:01: „bis auf Ford grundsätzlich alle … auf Opus“)
STARK_GESTARTET = []
AUFWAND_HOCH = re.compile(r"Aufwand hoch\b", re.I)  # 827.1: „Nachfolger: … (Aufwand hoch, weil …)“ in der Übergabe
def modell(r, nr, nachfolger=""):
    """(Modell, Satz für die Startnachricht, hoch). 827.1 (Chef 13.11., 22:08: „wenn einer … mehr Leistung braucht, dann setzt er den
    Aufwand für die Aufgabe auf hoch … und dann wieder zurück“): ein Nachfolger mit „Aufwand hoch“ startet mit effort high und Umgebung
    HOCH, jeder andere Start Mittel; festgefahren (startbar.festgefahren) nur als Hinweis. Stärkstes Modell (827 A) nur ab STARK_AB (aus)."""
    team = r
    d = next((x for x in startbar.zeilen_liste() if x["nr"] == nr), None) if nr else None
    g = startbar.festgefahren(d)
    if g and not startbar.STARK_MARKE.search(d["titel"]) and JETZT >= startbar.STARK_AB.replace(tzinfo=BERLIN):
        STARK_GESTARTET.append(nr)  # 827 A: „die nächste Sitzung“, eine je Vorgang; --sperre setzt die Marke an den Titel
        return startbar.STARK_MODELL, " Stärkstes Modell (827 A): Vorgang %s ist festgefahren (%s); Ziel ist das „passt“ des Chefs mit möglichst wenig weiteren Rückläufern." % (nr, g), False
    if nachfolger and AUFWAND_HOCH.search(nachfolger):
        return MODELL.get(team, "opus"), " Aufwand hoch (827.1) laut Übergabe; nur für diese Aufgabe, im eigenen Nachfolger „Aufwand hoch“ nur mit neuem Grund.", True
    # festgefahren allein schaltet nicht hoch (Chef 22:04 „Mittel für alle“; 709, 709.1 liefen sonst dauernd hoch), nur Hinweis
    if g:
        return MODELL.get(team, "opus"), " Vorgang %s ist festgefahren (%s): braucht der nächste Start mehr Leistung, Übergabe mit „Nachfolger: … (Aufwand hoch, weil …)“ (827.1)." % (nr, g), False
    return MODELL.get(team, "opus"), "", False
# 718 A (Chef 09.11., 11:25): jede Probe = Abweichung vom alten Wert mit Enddatum; ab BIS gilt der alte Wert in der Tafel oben, lauf.py meldet
# einmal am Tag „Probe <Nr> abgelaufen, auswerten“ (WARNUNG-LAUT, Marke „Probe-abgelaufen <Nr>“); verlängern nur auf Wort des Chefs (BIS ändern, Wortlaut dazu)
PROBEN = [  # (Nr, Tafel, Schlüssel, Probewert, BIS „TT.MM.JJJJ“: ab diesem Tag alter Wert)
    # Probe 270 (Perikles groß bis 06.11.) beendet: dauerhaft, Chef 09.11., 13:01
]
def _bis(t):
    d, m, j = (t.strip(".").split(".") + [str(JETZT.year)])[:3]
    return datetime.date(int(j), int(m), int(d))
ABGELAUFEN = []
for _nr, _tafel, _k, _wert, _b in PROBEN:
    if JETZT.date() < _bis(_b): globals()[_tafel][_k] = _wert
    else: ABGELAUFEN.append((_nr, _tafel, _k, _b))
VORRAT = {"Homer": "ARBEIT-KREATIV.md", "Tom": "ARBEIT-TEAM-TOM.md", "Jerry": "ARBEIT-TEAM-JERRY.md",
          "Perikles": "ARBEIT-PROJEKT.md", "Diogenes": "ARBEIT-PRUEFUNG.md", "Sokrates": "ARBEIT-BERATUNG.md",
          "Spike": "ARBEIT-TEAM-SPIKE.md"}  # 1328: Spike eigener Vorrat; 433 Zusatzentwickler fällt (1871)
START_REIHE = ["Tom", "Jerry", "Spike", "Diogenes", "Homer", "Perikles"]
MIT_KUER = {"Tom", "Jerry", "Spike", "Diogenes", "Homer", "Perikles"}
PLANER = "Perikles"  # 1893: an der neuen Liste „Arbeitsplaner“ (Aufträge; M?, Kosten, Stillstand fallen, 1871 Stilllegung C (g))
NEU_LISTE = False  # 1893: True, wenn die Vorgangsliste den Kopf ohne Besitzer hat (startbar.NEU); setzt neue_liste()
NIE_START_NEU = {"Disponent"}  # 1893: der Disponent ist Fords Sitzung (startet die Wache), lauf.py startet ihn nie aus Zeilen

def neue_liste():
    """1893 (1727, Umschalt-Commit 1871): an der umgestellten Liste starten die Profile statt der Rollen. START_REIHE und MIT_KUER =
    Profile aus startbar.profile() (Fachprofile der Themenblöcke, dann Büro) ohne Disponent; Aufträge an den
    Arbeitsplaner; Profile haben keinen Vorrat (Nachfolger und Pause kommen aus der Vorgangsdatei). Alte Liste: alles wie bisher."""
    global START_REIHE, MIT_KUER, PLANER, NEU_LISTE
    startbar.besitzer_reihe()
    NEU_LISTE = bool(startbar.NEU)
    if not NEU_LISTE: return False
    START_REIHE = [p for p in startbar.profile() if p not in NIE_START_NEU]
    MIT_KUER = set(START_REIHE); PLANER = "Arbeitsplaner"
    return True

def vorrat_hinweis(r, nr=None):
    """Satzende der Startnachricht: alte Liste „die Übergabe in <Vorrat> beachten“, neue Liste die Vorgangsdatei (1893)."""
    if r in VORRAT and not NEU_LISTE: return "die Übergabe in %s beachten" % VORRAT[r]
    return "die Vorgangsdatei `docs/vorgang/%s.md` lesen (Auftrag, Feld „Zurück“)" % (nr or "<Nr>")
ROUTINE_ROLLEN = {"Rundblick", "Ideenlauf", "Tagesbericht"}  # 1789, 1907 (Ideenlauf, Gesamtbild 4.3 G:451): Routinen mit eigenem Start (ohne Kern, ohne Rufname, ohne Feld „Zurück“), nur mit tools/1727-SCHARF
NIE_ARCHIV = {"Ford"}  # Ford, Wache; Sokrates und Sonstige nach eigener Regel (197)

def geschuetzt():
    """1531 (Chef 17.11., 08:52 zur Sitzung Sokrates: „diese Sitzung definitiv nicht archivieren oder schließen lassen“): Kennungen aus der
    Zeile „**Nie archivieren:** session_… (…)“ oben in ARBEIT-BETRIEB.md; Ford archiviert sie nie, bis der Chef sie freigibt (Zeile weg)."""
    m = re.search(r"(?m)^\*\*Nie archivieren:?\*\*:?(.*)$", lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")))
    return set(re.findall(r"session_[A-Za-z0-9]+", m.group(1))) if m else set()
SPERRE_MIN = 20
WEITER_TOKEN = 200000  # 383 A (Chef 09.11., 18:05): günstigste Länge 200 Tsd. (Rechnung Sokrates); vorher 400000 nach 383.1 (Chef 27.10., 19:19 „nicht mal 2 Seiten lang“): Kontext 1 Mio., Kosten je Arbeit bis 500 Tsd. gleich (Messung Sokrates 18:15); Vorentscheid Perikles 27.10. (vorher 150 Tsd., D40.1)
FREIGABE_MIN = 15  # 1572: blocked ab 15 Minuten laut an den Chef (Konstante fiel mit e1cb7588c weg, Ford 17.11., 21:04)
WEITER_MIN = 60  # 261.5 (3): WEITER nur in eine Sitzung, die unter 60 Minuten ruht; fürs Archivieren gibt es keine Wartezeit mehr (Chef 21.10., 16:46)
# 1766 (Archiv 20.11., 08:19 „Höchstdauer je Auftrag“; Sokrates 21.11., 20:55 „nicht warten … dann nur die Konstante setzen“): Minuten je
# Auftrag nach Leistungsstufe, gezählt ab Sitzungsstart oder jüngstem „## Auftrag“ der Vorgangsdatei, auch bei working. None = Wert fehlt
# (liefert Sokrates in 1774), dann prüft lauf.py nichts. Scharf erst mit tools/1727-SCHARF.
# 1779 (Vorentscheid 1774, hoechstdauer-1774.md 6a): Mittel 360, Hoch 300 Minuten (Hoch enger: festgefahrene Aufgaben); Probewoche zeigt, ob 360 zu eng ist.
HOECHSTDAUER_MIN = {"Mittel": 360, "Hoch": 300}

def z(s):
    return datetime.datetime.fromisoformat(s.replace("Z", "+00:00")).astimezone(BERLIN)

def lesen(p):
    return open(p, encoding="utf-8").read()

def berlin(d):
    return d.strftime("%d.%m., %H:%M")

def laut_nachts():
    """Schritt 9: laut melden, nachts (22–7 Uhr) lautlos (ROLLE-BETRIEB.md)."""
    return "WARNUNG-LAUT" if 7 <= JETZT.hour < 22 else "WARNUNG"

def neu_fuer_chef(betrieb, vorraete):
    """927 (Schritt 9): (Marke, Text) für „Jetzt installieren“ in ARBEIT-BETRIEB.md und jede Übergabe „wartet auf Chef“,
    nur mit Datum von heute oder gestern (Marken leben zwei Tage, 270)."""
    tage = {JETZT.date(), JETZT.date() - datetime.timedelta(days=1)}
    def frisch(tt, mm):
        try: return datetime.date(JETZT.year, int(mm), int(tt)) in tage
        except ValueError: return False
    aus = []
    m = re.search(r"^\*\*Jetzt installieren:\*\*\s*(.*?Release\s+(\S+)\s+\((\d\d)\.(\d\d)\..*)$", betrieb, re.M)
    if m and frisch(m.group(3), m.group(4)):
        aus.append(("Installieren %s" % m.group(2), "Jetzt installieren: %s" % m.group(1)[:200]))
    for r, txt in sorted(vorraete.items()):
        u = re.search(r"^\*\*Übergabe[^\n]*?\((\d\d)\.(\d\d)\.,?\s*(\d\d:\d\d)[^\n]*", txt, re.M)
        if not u or not frisch(u.group(1), u.group(2)): continue
        nrn = warte_chef_nummern(u.group(0))
        if nrn:
            aus.append(("Übergabe-Chef %s %s.%s. %s" % (r, u.group(1), u.group(2), u.group(3)), "%s: Übergabe wartet auf Chef: %s" % (r, "; ".join(nrn))))
    return aus

VORGANG_NR = r"\d{1,4}[a-z]?(?:\.\d+[a-z]?)*"

def warte_chef_nummern(zeile):
    """941 (D171.1): je „wartet auf (den) Chef(sache N)“ außerhalb von „…“, "…", `…` die Vorgangsnummer mit kurzem Zusatz;
    die Nummer nach „Chefsache“, sonst die letzte im selben Satzteil davor (bis ; oder Satzende); Datum und Uhrzeit zählen nicht."""
    ohne = re.sub(r"„[^“\n]*“|\"[^\"\n]*\"|`[^`\n]*`", lambda m: " " * len(m.group(0)), zeile)
    aus = []
    for m in re.finditer(r"wartet auf (?:den )?Chef(?:sache\s+(%s))?" % VORGANG_NR, ohne):
        teil = re.split(r";|\.\s|\):\*\*", ohne[:m.start()])[-1]
        vorher = [t for t in re.findall(r"(?<![\w.:,-])(%s)(?![\w,:-])" % VORGANG_NR, teil) if not re.fullmatch(r"\d\d\.\d\d", t)]
        nr = m.group(1) or (vorher[-1] if vorher else "?")
        zusatz = re.sub(r"\s+", " ", zeile[m.start() - len(teil):m.end()]).strip()
        aus.append("%s (%s)" % (nr, ("…" + zusatz[-119:]) if len(zusatz) > 120 else zusatz))
    return aus

def nacht_halt(r, nr, ausgabe, morgen):
    """1643 (340.12/3): derselbe Vorgang nach zwei Neustarts in einer Nacht angehalten; Zeile „Morgen 1643: …“ im Protokoll für den Morgen."""
    try:
        import nachtstarts
        if not nr or not re.match(r"\d", str(nr)) or not nachtstarts.angehalten(r, str(nr)): return False
    except Exception:
        return False
    try: g = nachtstarts.grenze(r, str(nr))[1]  # 1792: Deckel aus Ausnahme des Chefs
    except Exception: g = nachtstarts.GRENZE
    ausgabe.append("NICHTS %s: Vorgang %s in dieser Nacht schon %d-mal gestartet, angehalten bis 7 Uhr; lauf.py jeden Takt, nur START-Zeilen ruhen (1643, 1978)" % (r, nr, g))
    morgen.append("Morgen 1643: %s %s nach zwei Neustarts in der Nacht angehalten, Ursache ansehen" % (r, nr))
    return True

def startmarken():
    """Rolle → letzter Startzeitpunkt aus „Startsperre HH:MM Start <Name>“ im Protokoll. Datum aus dem Zeilenkopf
    „- HH:MM TT.MM.:“ (631: ohne Datum galt eine Marke vom Vortag als heutige); fehlt er: heute, sonst gestern."""
    aus = {}
    for name, d in startsperren():
        if name not in aus or d > aus[name]: aus[name] = d
    return aus

def startsperren():
    """Alle (Rolle, Zeitpunkt) aus den Startsperren im Protokoll, auch die von Ford von Hand geschriebenen (837)."""
    aus = []
    for l in lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")).splitlines():
        m = re.search(r"Startsperre (\d\d):(\d\d) Start (\w+(?:, \w+)*)", l)
        if not m: continue
        d = JETZT.replace(hour=int(m.group(1)), minute=int(m.group(2)), second=0, microsecond=0)
        k = re.match(r"- \d\d:\d\d (\d\d)\.(\d\d)\.:", l)
        if k:
            try: d = d.replace(day=int(k.group(1)), month=int(k.group(2)))
            except ValueError: continue
            if d > JETZT + datetime.timedelta(days=1): d = d.replace(year=d.year - 1)
        elif d > JETZT: d -= datetime.timedelta(days=1)
        for name in m.group(3).split(", "):  # 433: „Start Tom, Spike“ sperrt beide, nicht nur den ersten
            aus.append((name, d))
    return aus

START_PRUEF_MIN = 5  # 837: so lange nach der Startsperre muss eine Sitzung der Rolle da sein
START_PRUEF_STD = 3  # ältere Startsperren prüft lauf.py nicht mehr (aufraeumen behält Startsperren so lange, auch über Mitternacht, 1187)

def start_angekommen(rolle, d, alle):
    """837: nach der Startsperre um d gibt es eine Sitzung der Rolle, neu angelegt (START) oder,
    nicht archiviert, danach tätig (WEITER schreibt dieselbe Sperre)."""
    for s in alle.values():
        if kosten.rolle(s.get("title", ""), s.get("created_at")) != rolle: continue
        if z(s["created_at"]) >= d - datetime.timedelta(minutes=START_PRUEF_MIN): return True  # Ford schrieb die Sperre auch schon nach dem Start (Jerry 10.11., 10:29/10:32)
        if s.get("session_status") != "SESSION_STATUS_ARCHIVED" and s.get("updated_at") and z(s["updated_at"]) >= d: return True
    return False

def start_noetig(rolle, st, ausschluss, nur_muss=False, nf_offen=False):
    """1586 (Ford 17.11., 18:38): eine fehlende Sitzung nach der Startsperre zählt nur, wenn die Rolle jetzt etwas zu starten hätte
    (offener Nachfolger oder startbare Zeile, die nicht mit --ohne ausgeschlossen ist, keine Pause). Sonst war der Start gewollt
    ausgelassen oder lief schon und ist archiviert (Kurzform ohne archivierte Sitzungen; Homer 1235 am 17.11., 1489 am 16.11.)."""
    if nf_offen: return True
    muss, kuer, pause, _ = st.get(rolle, ([], [], None, []))
    if pause: return False
    if [x for x in muss if x[0] not in ausschluss]: return True
    return bool(rolle in MIT_KUER and not nur_muss and [x for x in kuer if x[0] not in ausschluss])

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
M_FRAGEN = []  # offene „M?“ als „Nr (Besitzer)“, stand() füllt sie; Ausgabe KLASSE an den Disponenten (1871 Stilllegung C (g))

def stand():
    """Rolle → (Muss-Liste, Kür-Liste, Pause, Chef-Nummern) aus der Vorgangsliste (275.2, startbar.plan); Listen = alle startbaren Zeilen
    in Vorrangfolge, je Eintrag (Nr, Kl, Titel, Zeile als dict)."""
    aus = {}; m_fragen = []
    for datei, rolle in startbar.besitzer_reihe():  # 1893: neue Liste je Profil, ohne Vorrat
        if rolle in NIE_START_NEU: continue
        inhalt = startbar.lesen(datei) if datei else ""
        zs = startbar.plan(rolle)
        sperr = {x[0]: x[4] for x in zs}
        muss = [x[:4] for x in zs if x[1] == "M" and not x[4]]
        kuer = [x[:4] for x in zs if x[1] != "M" and not x[4]]
        kuer += [(x[0], "N", x[2], x[3]) for x in zs if x[4] == "nach dem Meilenstein"]  # 190.10: letzte Stufe vor Leerlauf
        wartet = [x[0] for x in zs if (x[4] or "").startswith("Chef")]
        p = startbar.pause(inhalt); frei = startbar.pause_frei(inhalt) if p else []
        if frei:  # 870.17: Pause mit „frei für: …“ sperrt alles außer diesen Nummern
            muss = [x for x in muss if startbar.ist_frei(x[0], frei)]; kuer = [x for x in kuer if startbar.ist_frei(x[0], frei)]; p = None
        elif p and muss:  # 1364 (Chef 16.11., 06:52): eine Pause mit Datum hält nur die Kür an, startbares Muss startet (wie 1246 ohne Datum)
            kuer = []; p = None
        aus[rolle] = (muss, kuer, p, wartet)
        GESPERRT[rolle] = {x[0]: x[4] for x in zs if x[4]}
        offen_m = [x[0] for x in zs if x[1] == "M?" and not x[4]]
        if offen_m: m_fragen.extend("%s (%s)" % (n, rolle) for n in offen_m)
    M_FRAGEN[:] = m_fragen  # 1871 Stilllegung C (g): M? klärt der Disponent mit der Zeile KLASSE (Profil Disponent „Klasse setzen statt M?“), keine Muss-Zeile mehr
    if NEU_LISTE and PLANER in aus and ist_scharf():
        auftrag_einreihen(aus[PLANER], auftrag_zeilen(aus))
    return aus

def auftrag_einreihen(planer, auftraege):
    """1897 (D338.3): Zeilen „Auftrag“ nach Klasse unter die eigenen Zeilen des Planers: Auftrag zu Muss in seine Muss-Liste, Auftrag zu Kür (und nach dem Meilenstein) in seine Kür-Liste; innerhalb der Liste Eilt zuerst, sonst Zeilenfolge der Vorgangsliste
    (Auftrag an der Stelle seiner Zeile), „nach dem Meilenstein“ zuletzt. So geht nie ein Auftrag zu Kür vor eigenes Muss."""
    folge = {d["nr"]: (not d.get("eilt"), i) for i, d in enumerate(startbar.zeilen_liste())}
    def rang(x): return (x[1] == "N", folge.get((x[3].get("auftrag_fuer") if x[0] == "Auftrag" else None) or x[0], (True, 10 ** 6)))
    muss, kuer = planer[0], planer[1]
    muss[:] = sorted(muss + [x for x in auftraege if x[1] == "M"], key=rang)
    kuer[:] = sorted(kuer + [x for x in auftraege if x[1] != "M"], key=rang)

AUFTRAG_PLANER = 1  # 1893; 1932 (Archiv 1727j Frage 16, Chef 22.11., 12:06): ein Planer, zweiter zugleich ab ZWEITER_PLANER_AB
ZWEITER_PLANER_AB = 10  # 1932: zweiter Planer, solange mehr als 10 Eilt-, Fund- oder Muss-Zeilen ohne gültigen Auftrag sind (Schwelle Sokrates)
MAX_PLANER = 2  # 1932: „bis zu 2 Planern“ (Chef 22.11., 12:06)
AUFTRAG_IN_ARBEIT = set()  # 1932: Nummern, deren Auftrag eine laufende Planer-Sitzung gerade schreibt (Titel „… Auftrag <Nr> …“), main() füllt sie

def _liegezeiten():
    """1932: Zeile → Unix-Sekunden der letzten Änderung (Maß wie liegt.py, startbar.zeilen_zeiten); {} ohne Git."""
    try:
        zeiten = startbar.zeilen_zeiten(JETZT)
    except Exception:
        zeiten = []
    return {d["nr"]: zeiten[d["i"]] for d in startbar.zeilen_liste() if d.get("i") is not None and d["i"] < len(zeiten) and zeiten[d["i"]] is not None}

def auftrag_offen(st, ohne=()):
    """1932: [(Gruppe, Rang, Nr, Profil, Titel, Grund, Klasse)] der startbaren Zeilen ohne gültigen „## Auftrag“. 1967 (Chef 22.11.,
    17:43, 17:46): Schlüssel (Klasse, Blockrang, Rest); Klasse 0 Eilt, 1 Funde des Chefs (guthaben.ruecklaeufer), 2 Muss, 3 Kür,
    4 nach dem Meilenstein; Blockrang = Zeilenfolge in chefsache/themenbloecke.md (projektplan.bloecke, Block je Zeile
    startbar.block_von); im Block Zeilenfolge der Liste, bei Kür Liegezeit (älteste zuerst, Maß wie liegt.py). Nummern in ohne
    (Auftrag in Arbeit) fallen weg."""
    import projektplan
    import guthaben
    liste = {d["nr"]: (i, d) for i, d in enumerate(startbar.zeilen_liste())}
    folge = [b for b, _ in projektplan.bloecke()]
    def rang(nr, d):
        b = startbar.block_von(str(nr), d.get("bereich"))
        return folge.index(b) if b in folge else len(folge)
    offen, gesehen, kuer = [], set(), []
    for teil in (0, 1):
        for r, x in st.items():
            for z in x[teil]:
                nr = z[0]
                if not re.match(r"\d", str(nr)) or nr in gesehen or nr in ohne: continue
                g = auftrag_fehlt(nr)
                if not g: continue
                gesehen.add(nr)
                i, d = liste.get(nr, (10 ** 6, {}))
                d = d or (z[3] if isinstance(z[3], dict) else {})
                kl = "M" if teil == 0 else "N" if z[1] == "N" else "K"  # 1897: Klasse der Zeile, für die der Auftrag ist
                b = rang(nr, d)
                if d.get("eilt"): offen.append((0, (b, i), nr, r, z[2], g, kl))
                elif guthaben.ruecklaeufer(d): offen.append((1, (b, i), nr, r, z[2], g, kl))
                elif kl == "M": offen.append((2, (b, i), nr, r, z[2], g, kl))
                elif kl == "N": offen.append((4, (b, i), nr, r, z[2], g, kl))
                else: kuer.append((b, i, nr, r, z[2], g, kl))
    if kuer:
        zeit = _liegezeiten()
        for b, i, nr, r, titel, g, kl in kuer: offen.append((3, (b, zeit.get(nr, float("inf")), i), nr, r, titel, g, kl))
    return sorted(offen)

def planer_zahl(st, ohne=()):
    """1932: wie viele Planer zugleich: MAX_PLANER, solange mehr als ZWEITER_PLANER_AB Eilt-, Fund- oder Muss-Zeilen ohne Auftrag sind, sonst AUFTRAG_PLANER."""
    n = len([o for o in auftrag_offen(st, ohne) if o[0] <= 2])
    return MAX_PLANER if n > ZWEITER_PLANER_AB else AUFTRAG_PLANER

def auftrag_zeilen(st, n=None, ohne=None):
    """1893 (Gesamtbild 3.3 Fassung 2 Nr. 4, Archiv 21.11., 10:11 „3.3 so“; Sokrates 22.11., 08:33): startbare Zeilen ohne gültigen
    „## Auftrag“ bekommen ihren Auftrag vom Arbeitsplaner, frisch je Auftrag: je Zeile eine Zeile „Auftrag“ für den Planer, höchstens
    n (AUFTRAG_PLANER). Folge nach 1967 (auftrag_offen): Klasse (Eilt, Funde des Chefs, Muss, Kür), darin Themenblock-Reihenfolge.
    Aufträge, die eine laufende Planer-Sitzung schreibt (AUFTRAG_IN_ARBEIT), fallen weg; den zweiten Planer startet main() (1932)."""
    aus = []
    for _, _, nr, r, titel, g, kl in auftrag_offen(st, AUFTRAG_IN_ARBEIT if ohne is None else ohne):
        aus.append(("Auftrag", kl, "Auftrag schreiben für %s (%s, %s): %s (`vorgang.py auftrag %s`; 3.3 Nr. 4, ein Auftrag je Sitzung)" % (nr, r, g, titel, nr), {"auftrag_fuer": nr}))
    return aus[:AUFTRAG_PLANER if n is None else n]

THEMA_MAX = 50  # 1960: Zeichen des Themas im START-Titel, mit „…“

FUELLWORT = {"nach", "zu", "von", "vom", "ab", "im", "in", "mit", "auf", "für", "und", "oder", "der", "die", "das", "des", "den", "dem",
            "bei", "aus", "zum", "zur", "an", "am", "über", "seit", "bis", "ohne", "je", "als", "wie", "statt"}

def _sieht_nummer(t):
    """1960: läse nummern_aus_titel in t hinter „X – 1:“ eine weitere Vorgangsnummer (Kosten zu gleichen Teilen, 197)?"""
    return nummern_aus_titel("X – 1: %s (01.01., 00:00)" % t) != "1"

def thema(t):
    """1960 (Chef 22.11., 16:52): Thema für den START-Titel aus dem Vorgangstitel: ohne Markdown, „|“, Zeilenumbruch und
    „Auftrag <Zahl>“; Vorspann bis zum ersten „: “ außerhalb von Klammern weg, wenn er mit „Von “ beginnt oder eine Vorgangsnummer
    trägt („Aus 623.2 (Jerry): …“); endet vor „;“, „: “, „ (“, „ – “, einem unpaarigen „ und vor jedem Wort, das nummern_aus_titel
    als weitere Vorgangsnummer läse (dann ohne Füllwort am Ende und mit „…“); höchstens THEMA_MAX Zeichen am Wortende mit „…“."""
    t = re.sub(r"\*\*|`", "", str(t or ""))
    t = " ".join(re.sub(r"[|\r\n]+", " ", t).split())
    tiefe = 0
    for i, c in enumerate(t):
        tiefe += (c == "(") - (c == ")")
        if c == ":" and tiefe == 0 and t[i + 1:i + 2] in (" ", ""):
            if (re.match(r"(D\d\S* )?[Vv]on ", t) or _sieht_nummer(t[:i])) and t[i + 1:].strip(): t = t[i + 1:]
            break
    t = re.split(r";|:(?=\s|$)| \(| – ", t.strip())[0]
    t = re.sub(r"\bAuftrag\s+\d[0-9a-zA-Z.]*", " ", t)
    if t.count("„") > t.count("“"): t = t[:t.rindex("„")]
    worte, rest = [], False
    for w in t.split():
        if _sieht_nummer(" ".join(worte + [w])): rest = True; break
        worte.append(w)
    if not worte and t.split(): worte = [re.split(r"\d", t.split()[0])[0]]  # „chefsache/bilder/415-…“: Teil vor der Zahl
    while rest and len(worte) > 1 and worte[-1].lower() in FUELLWORT: worte.pop()
    t = " ".join(worte).rstrip(" ,;:(–-/")
    if len(t) > THEMA_MAX - 2:
        t = t[:THEMA_MAX - 2]
        t = t[:t.rindex(" ")] if " " in t else t
        if t.count("„") > t.count("“"): t = t[:t.rindex("„")]
        rest = True
    t = t.rstrip(" ,;:(–-/")
    while rest and " " in t and t.rsplit(" ", 1)[1].lower() in FUELLWORT: t = t.rsplit(" ", 1)[0].rstrip(" ,;:(–-/")
    return (t + " …") if rest and t else t

def start_titel(kopf, nr):
    """1960: START-Titel „<Kopf>: <Thema> (TT.MM., HH:MM)“ (Fachkraft, Planer, zweiter Planer), Thema aus dem Vorgangstitel von nr;
    ohne tools/1727-SCHARF oder ohne Zeile wie bisher „<Kopf> (…)“. mit_rufnamen setzt danach den Rufnamen statt der Rolle."""
    th = thema(next((d["titel"] for d in startbar.zeilen_liste() if d["nr"] == nr), "")) if ist_scharf() else ""
    return "%s%s (%s)" % (kopf, (": " + th) if th else "", berlin(JETZT))

def auftrag_aus_titel(titel):
    """1932: Nummer aus einem Planer-Titel „<Name> – Auftrag <Nr> (…)“, sonst None."""
    m = re.search(r"\bAuftrag (\d[0-9a-zA-Z.]*[0-9a-zA-Z]|\d)\b", titel or "")
    return m.group(1) if m else None

def planer_in_arbeit(leb):
    """1932: Nummern der Aufträge, die eine Planer-Sitzung gerade schreibt (tätig oder kürzlich); 1957: Rufnamen-Planer über die Startsperre."""
    aus = set()
    for s_ in leb:
        if kosten.rolle(s_.get("title", ""), s_.get("created_at")) != PLANER or not (n_ := auftrag_aus_titel(s_.get("title", ""))): continue
        ruhig_ = (JETZT - z(s_["updated_at"])).total_seconds() / 60
        if ("WORKING" in s_.get("status_bucket", "") or "BLOCKED" in s_.get("status_bucket", "")) and ruhig_ < 60 or ruhig_ < SPERRE_MIN:
            aus.add(n_)
    return aus

def sperr_dazu(sperren, sperr_nr, rolle, nr):
    """1957 (Startsperre 16:18 „Arbeitsplaner 1727, Arbeitsplaner 1727“): weiterer START derselben Rolle mit eigener Nummer;
    sperr_nr[rolle] wird dann eine Liste je Vorkommen in sperren (startsperre_zeile liest beides)."""
    c = sperren.count(rolle); alt = sperr_nr.get(rolle)
    liste = list(alt) if isinstance(alt, list) else [alt] * min(c, 1)
    liste += [None] * (c - len(liste)); liste.append(nr)
    sperren.append(rolle); sperr_nr[rolle] = liste if len(liste) > 1 else nr

def zweiter_planer(ausgabe, st, je_rolle, archiviert, ausschluss, bremse, sperren, sperr_nr, morgen):
    """1932 (Archiv 1727j Frage 16, Chef 22.11., 12:06 „bis zu 2 Planern“): arbeitet schon ein Planer (laufende Sitzung oder START in
    diesem Lauf) und sind mehr als ZWEITER_PLANER_AB Eilt-, Fund- oder Muss-Zeilen ohne Auftrag, startet eine zweite Planer-Sitzung
    mit dem nächsten Auftrag, den keiner schreibt (Titel „<Planer> 2 – Auftrag <Nr>“; Rolle im ersten Feld bleibt der Planer).
    Nur an der neuen Liste mit tools/1727-SCHARF; Guthaben, Laufsperre und Nachtdeckel gelten wie beim ersten."""
    if not (NEU_LISTE and ist_scharf() and PLANER in st): return
    laufend = [s for s in je_rolle.get(PLANER, []) if s["id"] not in archiviert and (s["_info"][1] or s["_info"][2] < SPERRE_MIN)]
    start1 = [l for l in ausgabe if l.startswith("START %s |" % PLANER) or (l.startswith("WEITER ") and " | %s | " % PLANER in l)]
    zahl = len(laufend) + len(start1)
    if zahl == 0 or zahl >= MAX_PLANER: return
    in_arbeit = set(AUFTRAG_IN_ARBEIT) | {n for l in start1 if (n := auftrag_aus_titel(l))}
    if planer_zahl(st, in_arbeit) < MAX_PLANER: return
    wahl = next((a for a in auftrag_zeilen(st, 10 ** 6, in_arbeit) if a[1] == "M" and a[3]["auftrag_fuer"] not in ausschluss), None)
    if not wahl:
        return
    fn = wahl[3]["auftrag_fuer"]
    if bremse and (g := bremse.erlaubt(PLANER, wahl[1], wahl[3])):
        ausgabe.append("NICHTS %s 2: %s" % (PLANER, g)); return
    if nacht_halt(PLANER, fn, ausgabe, morgen): return
    if bremse: bremse.zaehle(PLANER, wahl[3])
    mo, satz, hoch = modell(PLANER, "Auftrag")
    titel = start_titel("%s 2 – Auftrag %s" % (PLANER, fn), fn)  # 1960
    msg = "%s\n\n%s; zweiter Planer (1932, über %d Eilt, Funde, Muss ohne Auftrag); zuerst Start nach deinem Ladetext, dann %s, den Auftrag schreiben, pushen und enden.%s" % (
        PLANER, re.sub(r"\*\*|`", "", wahl[2]), ZWEITER_PLANER_AB, vorrat_hinweis(PLANER, fn), satz)
    ausgabe.append("START %s | %s%s | %s | %s | %s | %s | %s" % (PLANER, mo, aufwand(hoch), umgebung(PLANER, hoch), REPO, REVISION, titel, msg.replace("\n", "\\n")))
    sperr_dazu(sperren, sperr_nr, PLANER, fn)  # 1957: eigene Nummer statt setdefault

def sperr_nummer(nr, d):
    """1896 (D338.2): Nummer für Startsperre und Nachtdeckel (1643): bei der Zeile „Auftrag“ die Nummer aus auftrag_fuer, sonst nr."""
    return (d.get("auftrag_fuer") if isinstance(d, dict) else None) or nr if nr == "Auftrag" else nr

def haken_naechste(rolle):
    """1895 (D338.1): Nummer, auf die weiter-haken.py eine Sitzung der Rolle schickt, nach denselben Regeln wie der Start: Muss vor Kür
    (Kür nur mit MIT_KUER), Pause hält an, mit tools/1727-SCHARF nur Zeilen mit gültigem Auftrag (auftrag_fehlt); Zeilen „Auftrag“
    nie (frisch je Auftrag, eigene Sitzung). M? und Kosten zählen (Arbeit des Planers). Sonst None."""
    neue_liste()
    muss, kuer, pause, _ = stand().get(rolle, ([], [], None, []))
    if pause: return None
    scharf = ist_scharf()
    for x in muss + (kuer if rolle in MIT_KUER else []):
        if x[0] == "Auftrag" or scharf and auftrag_fehlt(x[0]): continue
        return x[0]
    return None

def fremd_besitzer(rolle, nr, muss):
    """1662: Besitzer der Zeile nr, wenn sie offen einem anderen gehört und nicht in muss steht (etwa als Zeile, die auf die Rolle wartet); sonst None."""
    d = next((x for x in startbar.zeilen_liste() if x["nr"] == nr), None)
    if not d or "erledigt" in d.get("stand", ""): return None
    b = d.get("besitzer", "")
    if not b or b == rolle or any(x[0] == nr for x in muss): return None
    return b

def stillstand(st, je_rolle, archiviert, ausschluss):
    """1246: Text der Ursachen, wenn keine Rolle aus START_REIHE startbares Muss hat und keine ihrer Sitzungen arbeitet, aber Muss-Zeilen
    an einer startbaren Zeile einer nicht gestarteten Rolle hängen; sonst None. Warten auf Test, Chef oder Termin ist
    kein Stillstand."""
    rollen = [r for r in START_REIHE if r != PLANER]
    if any([x for x in st.get(r, ([],))[0] if x[0] not in ausschluss] for r in rollen): return None
    if any(s["_info"][1] for r in rollen for s in je_rolle.get(r, []) if s["id"] not in archiviert): return None
    eigner = {d["nr"]: d for d in startbar.zeilen_liste()}
    ursachen = {}
    for r in rollen:
        for nr, kl, _, d, grund in startbar.plan(r):
            if kl != "M" or not grund or nr in ausschluss or "fuer" in d: continue
            m = re.match(r"wartet auf ([0-9][\w.]*) \(startbar\)", grund)
            if m and eigner.get(m.group(1), {}).get("besitzer") not in START_REIHE + [None]:
                ursachen.setdefault("%s %s" % (eigner[m.group(1)]["besitzer"], m.group(1)), []).append("%s %s" % (r, nr))
    if not ursachen: return None
    return "; ".join("%s startbar, nicht gestartet, darauf warten %s" % (k, ", ".join(v)) for k, v in list(ursachen.items())[:6])

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

def lauf_laeuft(rolle):
    """1148 (von Ford), 1154 (Diogenes D205.5): Marke „Lauf läuft bis TT.MM., HH:MM“ oben im Vorrat — ein Hintergrundlauf
    (Render, Messung) hält die Sitzung belegt, obwohl sie idle aussieht; bis dahin startet und archiviert Ford die Rolle nicht.
    Nur mit Datum (ohne Datum blieb eine vergessene Marke bis zu 24 h stehen) und höchstens 12 h voraus; abgelaufen gilt sie nicht.
    Ohne Namen gilt die Marke für den Vorrat, mit Namen nur für diese Rolle."""
    if rolle not in VORRAT or NEU_LISTE: return None  # 1893: Profile ohne Vorrat
    for m in re.finditer(LAUF_MARKE, startbar.lesen(VORRAT[rolle])[:4000]):
        wer, _ = marke_wer(m, VORRAT[rolle])
        if wer and wer != rolle: continue
        try: bis = marke_bis(m)
        except ValueError: continue
        if JETZT <= bis <= JETZT + datetime.timedelta(hours=12): return m.group(0)
    return None

# 1161 (D206.1): „Uhr“ nach der Zeit ist erlaubt, sonst galt „(Spike)“ nicht und die Marke traf das Team
# 1177 (D208.1): die Klammer darf mehr als den Namen tragen („(Spike, Render)“); sonst galt die Marke still für das Team
LAUF_MARKE = r"Lauf läuft bis (\d\d)\.(\d\d)\.,? (\d\d):(\d\d)(?: Uhr)?(?:\s*\(([^)\n]*)\))?"

def marke_wer(m, datei):
    """(Name, Fehler) aus der Klammer der Marke: der Name einer Rolle dieses Vorrats irgendwo in der Klammer gilt (1177);
    ohne Klammer gilt die Marke für das Team. Klammer ohne passenden Namen: gilt für das Team, Fehler für die Warnung."""
    if m.group(5) is None: return None, None
    namen = [r for r, d in VORRAT.items() if d == datei]
    if len(namen) == 1: return None, None  # 1369 (D254.1): Vorrat einer Rolle (Spike): Klammer frei, Namenspflicht nur, wo geteilt (Jerry/Tuffy)
    wer = [w for w in re.findall(r"\w+", m.group(5)) if w in namen]
    if len(set(wer)) == 1: return wer[0], None
    if wer: return None, "mehrere Namen in der Klammer (%s), gilt für das Team" % ", ".join(dict.fromkeys(wer))
    return None, "Klammer ohne Namen dieses Vorrats (%s), gilt für das Team" % "/".join(namen)

def marke_bis(m):
    """Zeit der Marke; über den Jahreswechsel (D206: 31.12. mit „bis 01.01.“) ins nächste bzw. vorige Jahr. ValueError bei unmöglichem Datum."""
    bis = JETZT.replace(day=int(m.group(1)), month=int(m.group(2)), hour=int(m.group(3)), minute=int(m.group(4)), second=0, microsecond=0)
    if bis < JETZT - datetime.timedelta(days=180): bis = bis.replace(year=bis.year + 1)
    elif bis > JETZT + datetime.timedelta(days=180): bis = bis.replace(year=bis.year - 1)
    return bis

def lauf_marke_falsch(rolle):
    """1161 (D206.1): Marke, die nicht zählt (ohne Datum, Zeit unlesbar, über 12 h voraus), als Warnung statt still;
    Zitate der Regel („Lauf läuft bis …“ in Anführungszeichen) zählen nicht als Marke. Abgelaufen schweigt (gilt nach Regel nicht mehr)."""
    if rolle not in VORRAT or NEU_LISTE: return []
    kopf, falsch = startbar.lesen(VORRAT[rolle])[:4000], []
    for a in re.finditer(r"Lauf läuft bis", kopf):
        if a.start() and kopf[a.start() - 1] in "„\"“": continue
        m = re.match(LAUF_MARKE, kopf[a.start():])
        stueck = kopf[a.start():a.start() + 40].split("\n")[0]
        if not m: falsch.append((stueck, "ohne Datum oder Zeit in der Form TT.MM., HH:MM")); continue
        try: bis = marke_bis(m)
        except ValueError: falsch.append((stueck, "Datum oder Zeit unmöglich")); continue
        if bis > JETZT + datetime.timedelta(hours=12): falsch.append((m.group(0), "über 12 h voraus")); continue
        _, fehler = marke_wer(m, VORRAT[rolle])
        if fehler and bis >= JETZT: falsch.append((m.group(0), fehler))  # 1177: Klammer ohne passenden Namen nicht mehr still
    return falsch

def nachfolger(rolle):
    """(Titel, Übergabezeit, Rohtext) aus der Übergabe im Vorrat, sonst (None, None, Grund); Titel None + Grund „bedingt“ lässt die Zeilenregel gelten."""
    if rolle not in VORRAT or NEU_LISTE: return None, None, "kein Vorrat (1893: Nachfolger aus der Vorgangsdatei)"
    inhalt = startbar.lesen(VORRAT[rolle])
    for l in inhalt.splitlines()[:30]:
        if "Übergabe" not in l or "Nachfolger:" not in l: continue
        m = UEBERGABE.search(l)
        zeit = None
        if m:
            try: zeit = datetime.datetime(JETZT.year, int(m.group(2)), int(m.group(1)), int(m.group(3)), int(m.group(4) + ("9" if m.group(5) == "x" else m.group(5))), tzinfo=BERLIN)
            except ValueError: pass
        # 1239: die letzte Angabe zählt; „Nachfolger: …“ in Anführungszeichen ist ein Beispielsatz (Regeltext 827.1), kein Nachfolger
        stellen = [m.start() for m in re.finditer(r"Nachfolger:", l)]
        echte = [i for i in stellen if l[max(0, i - 1):i] not in ("„", '"', "‚")] or stellen
        roh = NACHFOLGER.match(l, echte[-1]).group(1).strip().lstrip("*").strip()
        q = re.match(r"[„\"]([^“\"]+)[“\"]", roh)  # 375: Titel in Anführungszeichen endet beim schließenden („…“; schickt zuerst …)
        satzende = r"(?<!\d\.\d\d)\.(?=\s+[A-ZÄÖÜ„*]|\s*$)|;"  # nicht am Datum: „Wochenziel 09.11.“ verlor sonst den Punkt, titel_datum sah keins (Perikles 08.11.)
        if q:
            # D83 (Diogenes 08.11.): „…“ ab 09.11., 8 Uhr: Datum hinter dem Titel bleibt als Klammer, damit titel_datum es sieht
            rest = re.split(satzende, roh[q.end():], maxsplit=1)[0]
            roh = q.group(1) + (" (%s)" % rest.strip(" ()*") if re.search(r"(?<!\d)\d\d?\.\d\d\.", rest) else "")
        roh = re.split(satzende, roh, maxsplit=1)[0].strip(" *„“\"")
        if re.search(r"startet\s+`?lauf\.py`?", roh): return None, zeit, "bedingt: " + roh[:60]  # 375: Termin, den lauf.py selbst startet
        roh = re.sub(r"^[-–—]+[\s,;:]*", "", roh).strip()  # 879 (D135.1): „– Auf Abruf (…)“, „–, auf Abruf“ ohne führenden Strich
        if re.match(r"keine[rn]?\b", roh, re.I) or not roh: return None, zeit, "keiner"  # 871: „Nachfolger: –“ startete „<Rolle> – –“
        # 893 (Ford 10.11., 18:04): „Tom – Sammelbuild 888 (wenn 709 und 506 fertig)“ startete stündlich; „wenn“ ist eine Bedingung
        if re.search(r"\b(nur wenn|wenn|falls|sobald|bis )", roh, re.I): return None, zeit, "bedingt: " + roh[:60]
        if not re.match(r"(%s)\b" % "|".join(MODELL), roh): roh = "%s – %s" % (rolle, roh)
        return roh, zeit, roh
    return None, None, "keine Übergabe mit Nachfolger"

def startsperre_zeile(sperren, sperr_nr, jetzt=None, rufnamen=None):
    """Protokollzeile „- HH:MM TT.MM.: Startsperre HH:MM Start <Rollen> (lauf.py, <Nr>)“ (750 A, 1643: mit Vorgang je Rolle).
    1957: je START mit Rufname „<Rolle> <Nr> <Rufname>“ (rufnamen: Rolle → Namen in START-Folge, aus mit_rufnamen), daraus liest
    rufname.rolle die Startrolle; sperr_nr[Rolle] darf eine Liste je Vorkommen sein (sperr_dazu)."""
    j = jetzt or JETZT; rufnamen = rufnamen or {}
    mit = []; k_je = {}
    for x in sperren:
        k = k_je.get(x, 0); k_je[x] = k + 1
        nr = sperr_nr.get(x)
        if isinstance(nr, list): nr = nr[k] if k < len(nr) else None
        nr = str(nr) if nr and re.match(r"\d", str(nr)) else None
        ns = rufnamen.get(x) or []
        if k < len(ns): mit.append(" ".join([x] + ([nr] if nr else []) + [ns[k]]))
        elif nr: mit.append("%s %s" % (x, nr) if len(sperren) > 1 else nr)
    return "- %s %s: Startsperre %s Start %s (lauf.py%s)" % (j.strftime("%H:%M"), j.strftime("%d.%m."), j.strftime("%H:%M"), ", ".join(sperren), "".join(", " + x for x in mit))


def start_zeilen(rolle, nr, nachricht, sitzungen=None, docs=None):
    """1989 (Chef 23.11., 09:04, 09:11): Handstart außerhalb des Takts wie ein Start im Takt: START-Zeile (Modell, Aufwand, Umgebung,
    Repo, main, Titel „<Rolle> – <Nr>: Handstart (…)“) mit Kaufrepo-Satz, Startblock (mit_kern) und, scharf, Rufname; dazu
    „STARTSPERRE <Protokollzeile>“ mit Rolle, Nummer und Rufname (startsperre_zeile), damit rufname.rolle sie zuordnet.
    sitzungen: (Titel, created_at) der heutigen Sitzungen für den Rufnamen; ohne sie die Rufnamen der heutigen Startsperren."""
    neue_liste()
    mo, satz, hoch = modell(rolle, nr)
    msg = "%s\n\n%s Zuerst Start nach deiner Rollendatei.%s" % (rolle, nachricht.strip(), satz)
    l = "START %s | %s%s | %s | %s | %s | %s | %s" % (rolle, mo, aufwand(hoch), umgebung(rolle, hoch), REPO, REVISION,
                                                     "%s – %s: Handstart (%s)" % (rolle, nr, berlin(JETZT)), msg.replace("\n", "\\n"))
    aus = [mit_kern(mit_kaufrepo(l), docs)]
    namen = {}
    if ist_scharf():
        if sitzungen is None:
            import rufname
            try: e = rufname.sperr_eintraege(lesen(os.path.join(docs or DOCS, "ARBEIT-BETRIEB.md")), JETZT.year)
            except Exception: e = []
            sitzungen = [("%s – x" % n, d.replace(tzinfo=BERLIN).isoformat()) for d, _, n in e if n and d.date() == JETZT.date()]
        aus = mit_rufnamen(aus, [{"title": a, "created_at": b} for a, b in sitzungen], namen=namen)
    aus += ["WARNUNG Startblock: %s ohne docs/profile/%s.md, Teil fehlt in der Startnachricht (1923)" % x for x in STARTBLOCK_FEHLT]
    aus.append("STARTSPERRE " + startsperre_zeile([rolle], {rolle: nr}, rufnamen=namen))
    return aus


def protokoll_pushen(anhaengen, nachricht):
    """1892: ARBEIT-BETRIEB.md auf origin/main um anhaengen(alter_text) ändern, ein Commit, gepusht (uebergabe.atomar_dateien, auf den gelesenen
    Stand); die lokale Datei bleibt unverändert. True bei Erfolg, sonst False (Grund ausgegeben).
    1918 (D348.1): hat die lokale ARBEIT-BETRIEB.md Ungepushtes (geändert oder eigener Commit voraus), kein Push von fern: False, der
    Aufrufer schreibt die Sperre lokal dazu und der Disponent pusht beides selbst (sonst Konflikt beim pull oder Fords Zeile fällt weg)."""
    try:
        import uebergabe as _ue
        grund = _ue.ungepusht("docs/ARBEIT-BETRIEB.md")
        if grund:
            print("WARNUNG Startsperre nicht von fern gepusht: lokale ARBEIT-BETRIEB.md %s (1918)" % grund)
            return False
        _ue.atomar_dateien(["docs/ARBEIT-BETRIEB.md"], lambda alt: ({"docs/ARBEIT-BETRIEB.md": anhaengen(alt["docs/ARBEIT-BETRIEB.md"]).rstrip("\n") + "\n"}, True), nachricht)
        return True
    except Exception as e:
        print("WARNUNG Startsperre nicht gepusht: %s (1892, Spike)" % e)
        return False


def protokoll_lokal(p, anhaengen):
    """1892-Fehler (Spike 22.11., 11:40 nachgestellt): erst lesen, dann schreiben; open(p, "w").write(anhaengen(lesen(p))) leerte die
    Datei vor dem Lesen (Python wertet open(…, "w") vor dem Argument aus), ARBEIT-BETRIEB.md blieb mit der Sperrzeile allein."""
    neu = anhaengen(lesen(p))
    with open(p, "w", encoding="utf-8") as f: f.write(neu)


def stellungnahme_start(ohne, msg):
    """1891 (D336.1): START-Zeile der Stellungnahme (194.2) mit der Nummer der ersten Chefsache-Datei im Titel („1727j-vorschlaege.md“
    → 1727j), damit Startsperre und Nachtdeckel (1643) einen Vorgang tragen; (Zeile, Nummer oder None)."""
    m = re.match(r"(\d[\w.]*?)(?:-|\.md$)", ohne[0]) if ohne else None
    nr = m.group(1) if m else None
    titel = "Sokrates – %sStellungnahme (%s)" % ((nr + ": ") if nr else "", berlin(JETZT))
    return ("START Sokrates | opus%s | %s | %s | %s | %s | %s" % (aufwand(), umgebung("Sokrates"), REPO, REVISION, titel, msg.replace("\n", "\\n"))), nr


def sokrates_zeilen(ausgabe, je_rolle, archiviert, vorgaenger=lambda r: None, docs=None, sperre=lambda nr: None):
    """1763 C (Chef 21.11., 14:37): offene Übergabezeilen an Sokrates („steckt fest“, „Frage“, „wirkt nein“, Obergrenze A/B → an den Chef)
    → Sokrates wecken (WEITER) oder starten; steht schon eine Sokrates-Zeile dieses Laufs, kommt der Auftrag dazu (nie zwei Sokrates)."""
    try:
        import uebergabe as _ue
        so_z = _ue.offen_lokal("Sokrates", docs or DOCS)
    except Exception:
        so_z = []
    if so_z:
        teil = "Offene Zeilen an dich (1763 C): %s. Je Zeile `vorgang.py annehmen <Kennung>`, Vorgangsdatei `docs/vorgang/<Nr>.md` lesen; „an den Chef“: Chefsache-Datei nach Muster, nicht selbst lösen; fertig: `vorgang.py erledigt <Kennung>`." % "; ".join("%s %s" % (k, w) for k, w in so_z[:6])
        i = next((j for j, z in enumerate(ausgabe) if z.startswith("START Sokrates |") or (z.startswith("WEITER ") and " | Sokrates | " in z)), None)
        if i is not None:
            if ausgabe[i].startswith("WEITER "):
                ausgabe[i] = ausgabe[i].replace(" | Stellungnahme | ", " | Stellungnahme | %s " % teil, 1)
            else:  # 1807 (D334.1): START der Stellungnahme trägt jetzt die Nummer der ersten Zeile im Titel und bekommt die Startsperre
                nr = so_z[0][0].split("-Ü")[0]
                ausgabe[i] = re.sub(r"\| Sokrates – (?:[\w.]+: )?Stellungnahme \(", lambda _m: "| Sokrates – %s: offene Zeilen und Stellungnahme (1763 C, " % nr, ausgabe[i], 1) + "\\n\\n" + teil
                vorgaenger("Sokrates"); sperre(nr)
        else:
            tok_so = lambda s: s.get("context_usage", {}).get("used_tokens") or s.get("external_metadata", {}).get("context_usage", {}).get("used_tokens") or 10**9
            laeuft_so = [s for s in je_rolle.get("Sokrates", []) if s["id"] not in archiviert and (s["_info"][1] or s["_info"][2] < SPERRE_MIN)]
            klein = [s for s in laeuft_so if tok_so(s) < WEITER_TOKEN] if laeuft_so else [s for s in je_rolle.get("Sokrates", []) if s["id"] not in archiviert and s["_info"][2] < WEITER_MIN and tok_so(s) < WEITER_TOKEN]
            if klein:
                ausgabe.append("WEITER %s | Sokrates | 1763 C | %s" % (juengste(klein)["id"], teil))
            elif laeuft_so:
                ausgabe.append("NICHTS Sokrates: %d offene Zeile(n) warten (1763 C), Sokrates läuft (Token über %d Tsd. oder unbekannt)" % (len(so_z), WEITER_TOKEN // 1000))
            else:
                # 1801: Titel mit der Vorgangsnummer der ersten Zeile, damit der Nachtstopp (1643) je Vorgang zählt, nicht alle 1763 C
                # zusammen; Startsperre mit dieser Nummer (vorher fehlte sie, der Startsperre-Haken hielt den Start an)
                nr = so_z[0][0].split("-Ü")[0]
                ausgabe.append("START Sokrates | opus%s | %s | %s | %s | Sokrates – %s: offene Zeilen (1763 C, %s) | %s" % (aufwand(), umgebung("Sokrates"), REPO, REVISION, nr, berlin(JETZT), ("Sokrates\n\n" + teil + " Zuerst Start nach deiner Rollendatei.").replace("\n", "\\n")))
                vorgaenger("Sokrates"); sperre(nr)
    return so_z


def rundblick_zeilen(ausgabe, je_rolle, archiviert, marken, zeilen=None, scharf=None, wurzel=None, name="Rundblick"):
    """1789 (routine-rundblick.md:13, :46; Archiv 20.11., 07:37, 07:53): den Wochentermin „Rundblick (Routine, …)“ (Besitzer
    Sokrates, startbar.WOCHENTERMINE_1727) startet der Disponent selbst: frische Sitzung mit Sockel (CLAUDE.md) und Teil A als
    Auftrag, ohne Kern der Leitung (mit_kern), ohne Arbeitsplaner, ohne Feld „Zurück“ (auftrag.routine), ohne Rufname.
    Rolle in der START-Zeile „Rundblick“ (Startsperre, kosten.rolle, Archivregel). Nur mit tools/1727-SCHARF.
    1907: ebenso NAME „Ideenlauf“ (Wochentermin „Ideenlauf (Routine, …)“, Gesamtbild 4.3 G:451, L-O15; Rolle „Ideenlauf“).
    Rückgabe: Vorgangsnummer, wenn eine START-Zeile steht, sonst None."""
    if not (ist_scharf() if scharf is None else scharf): return None
    import auftrag as _a
    zs = [d for d in (startbar.zeilen_liste() if zeilen is None else zeilen) if (name + " (Routine") in d.get("titel", "")
          and d.get("besitzer") == "Sokrates" and str(d.get("stand", "")).startswith("startbar") and not d.get("warte")]
    if not zs: return None
    d = zs[0]; nr = d["nr"]
    ss = [s for s in je_rolle.get(name, []) if s["id"] not in archiviert]
    if [s for s in ss if s["_info"][1] or s["_info"][2] < SPERRE_MIN]:
        ausgabe.append("NICHTS %s: läuft (1789)" % name); return None
    if [s for s in ss if nummer_aus_titel(s.get("title", "")) == nr]:
        ausgabe.append("NICHTS %s: Lauf zu %s ist zu Ende, wartet auf das Büro (Vorschläge anlegen, Vorgang schließen; 1789)" % (name, nr)); return None
    if name in marken and (JETZT - marken[name]).total_seconds() < SPERRE_MIN * 60:
        ausgabe.append("NICHTS %s: Startmarke %s jünger als %d Minuten" % (name, marken[name].strftime("%H:%M"), SPERRE_MIN)); return None
    text = _a.routine_text(d["titel"], wurzel or os.path.normpath(os.path.join(DOCS, "..")))
    if not text:
        ausgabe.append("WARNUNG %s %s nicht gestartet: Teil A nicht lesbar (%s; 1789, Spike)" % (name, nr, (_a.routine(d["titel"]) or ("?",))[0])); return None
    msg = "Routine %s, Vorgang %s (Wochentermin; ohne Kern, Teil A ist dein Auftrag, 1789).\n\n%s\n\n<Nr> ist %s." % (name, nr, text, nr)
    ausgabe.append("START %s | %s%s | %s | %s | %s | %s – %s: Routine (%s) | %s" % (name, MODELL["Sokrates"], aufwand(), umgebung(name), REPO, REVISION, name, nr, berlin(JETZT), msg.replace("\n", "\\n")))
    return nr


TAGESBERICHT_AUFTRAG = "docs/entwurf/1727-muster/routine-tagesbericht.md"
def tagesbericht_start(heute, zusatz="", wurzel=None):
    """1871 (werkzeuge.md Stilllegung C: „TAGESBERICHT an Perikles“ fällt mit der Rolle; G:486 „an Routine“;
    routine-tagesbericht.md: Sockel und Auftrag, ohne Kern, Start täglich 7:30, Sa/So 9:30 wie bisher): mit tools/1727-SCHARF
    START-Zeile der Routine „Tagesbericht“ (Rolle für Startsperre, Kosten, Archivregel), Auftrag = erster ```markdown-Block der
    Datei, Startsperre auf 448. Rückgabe (Zeile, None) oder (None, Warnung)."""
    import auftrag as _a
    text = _a.routine_text("(Routine, Auftrag %s)" % TAGESBERICHT_AUFTRAG, wurzel or os.path.normpath(os.path.join(DOCS, "..")))
    if not text:
        return None, "WARNUNG Tagesbericht %s nicht gestartet: Auftrag nicht lesbar (%s; 1871, Spike)" % (heute, TAGESBERICHT_AUFTRAG)
    msg = "Routine Tagesbericht %s, Vorgang 448 (täglich; ohne Kern, der Text ist dein Auftrag, 1871).%s\n\n%s" % (heute, zusatz, text)
    return "START Tagesbericht | %s%s | %s | %s | %s | Tagesbericht – 448: Routine %s (%s) | %s" % (
        MODELL["Sokrates"], aufwand(), umgebung("Tagesbericht"), REPO, REVISION, heute, berlin(JETZT), msg.replace("\n", "\\n")), None


def fristen_runde(ausgabe, seiten, docs=None):
    """1739 (Befund 1, werkzeuge.md A): in jedem Lauf mit --sperre `vorgang.py offen --sitzungen` (still): eine angenommene Zeile mit
    abgelaufener Frist, deren Halter nicht arbeitet, wird wieder offen (atomar auf origin/main, lokal nachgezogen), damit
    uebergabe_zeilen sie im selben Lauf weitergibt. Arbeitet der Halter, wird gewartet. Rückgabe: Kennungen, die wieder offen sind."""
    try:
        import uebergabe as _ue
        alt = _ue.WURZEL; _ue.WURZEL = os.path.normpath(os.path.join(docs or DOCS, ".."))
        try: liste = _ue.offen(None, list(seiten), still=True)
        finally: _ue.WURZEL = alt
    except Exception as e:
        ausgabe.append("WARNUNG Fristen der Übergabezeilen nicht geprüft: %s (1739)" % e); return []
    frei = [z["k"] for z, _nr, wie in liste if wie.startswith("wieder offen")]
    if frei: ausgabe.append("NICHTS Übergabe: %s wieder offen (Frist abgelaufen oder Halter abgebrochen; 1739, 1782: ein Neustart), schon auf origin/main" % ", ".join(frei))
    for z, nr, wie in liste:  # 1782 (3.3 Nr. 3), 1904 (D340.2): jede Zeile „steckt fest“ (frisch oder schon geschrieben) → Zeile an Sokrates nachholen
        if not (wie.startswith(_ue.FEST + " (zweites Mal") or z["z"].startswith(_ue.FEST)): continue
        if wie.startswith(_ue.FEST + " (zweites Mal"): grund = wie.split(": ", 1)[-1].rstrip(")").split(";")[0]
        else:
            m = re.match(r"steckt fest \(([^\d]*?)\s*\d", z["z"]); grund = m.group(1) if m else "Frist abgelaufen oder abgebrochen"
        import contextlib, io
        try:
            import rueckmeldung as _rm
            alt = _ue.WURZEL; _ue.WURZEL = os.path.normpath(os.path.join(docs or DOCS, ".."))
            try:
                with contextlib.redirect_stdout(io.StringIO()): k = _rm.fest_an_sokrates(nr, z["k"], z["an"], grund)
            finally: _ue.WURZEL = alt
            if k: ausgabe.append("NICHTS Übergabe: %s steckt fest, Zeile %s an Sokrates, %s wartet auf Sokrates (1782, 1904)" % (z["k"], k, nr))
        except Exception as e:
            ausgabe.append("WARNUNG Übergabe %s steckt fest, Zeile an Sokrates nicht geschrieben: %s; nächster Lauf holt es nach (1782, 1904)" % (z["k"], str(e)[:120]))
    return frei


ALT_EMPFAENGER = {"Arbeitsplaner": "Ford", "Disponent": "Ford", "Prüfer": "Diogenes"}  # 1739: bis tools/1727-SCHARF


def uebergabe_zeilen(ausgabe, je_rolle, archiviert, docs=None, start=None):
    """1739 (Sokrates 21.11., 20:43, F4 (1)): offene Übergabezeilen an andere als Sokrates (etwa „Arbeitsplaner“ aus chefwort.py,
    rueckmeldung.py) → NACHRICHT an die Sitzung des Empfängers. Hat er keine, startet ihn start(r, nr, teil) (Befund 1: Start statt
    nur NACHRICHT an Ford; hängt an eine START-Zeile dieses Laufs an, nie zwei Starts); kann start nicht (nicht startbare Rolle,
    --ohne, Hintergrundlauf, Startsperre jünger als 20 Min.) oder fehlt es, NACHRICHT an Ford. Bis zur Umschaltung
    (tools/1727-SCHARF) sind Arbeitsplaner und Disponent Ford, der Prüfer Diogenes (ALT_EMPFAENGER).
    1911 (D343.1): wartet der Vorgang (Feld „wartet auf“, etwa Sokrates nach „steckt fest“), bleibt eine Zeile an eine Fachkraft
    liegen (kein Start ohne Startbares, 340.12/3); Zeilen an das Büro (startbar.BUERO) gehen weiter. 1914 (D345.1): nur offene
    Wartegründe zählen (erfülltes Datum, erledigte Nummer nicht), und ein Warten auf den Empfänger selbst hält nie.
    1875 (Lauf 3 Disponent L4): Empfänger „Fachkraft“ (vorgang.py uebergabe) ist keine Rolle: bis zur Umschaltung der Besitzer des
    Vorgangs in der Liste, danach das Fachprofil seines Themenblocks (startbar.block_von, themenbloecke.md); sonst bleibt „Fachkraft“."""
    try:
        zl = {x["nr"]: x for x in startbar.vorgangsliste(lesen(os.path.join(docs or DOCS, startbar.LISTE)))}
    except Exception:
        zl = {}
    wartet = {n: x["warte"] for n, x in zl.items() if x.get("warte")}
    scharf = ist_scharf()
    def fachkraft(nr):
        if re.fullmatch(r"B\d+", nr): return "Technik" if scharf else "Spike"  # 1949: Build-Auftrag B<n> geht an den Build-Macher
        x = zl.get(nr) or {}
        b = (x.get("besitzer") or "").strip()
        if not scharf and b and b not in ("-", "–"): return b
        try:
            p = startbar.themenbloecke(docs)[0].get(startbar.block_von(nr, x.get("bereich"), docs))
            if p and p not in startbar.BUERO: return p
        except Exception:
            pass
        return b if b and b not in ("-", "–") else "Fachkraft"
    try:
        import uebergabe as _ue
        d = os.path.join(docs or DOCS, "vorgang")
        je = {}
        for n in sorted(os.listdir(d)) if os.path.isdir(d) else []:
            if not n.endswith(".md"): continue
            for z in _ue.zeilen(open(os.path.join(d, n), encoding="utf-8").read()):
                if not _ue.ist_offen(z["z"]) or z["an"].lower() == "sokrates": continue
                nr = z["k"].split("-Ü")[0]
                an = fachkraft(nr) if z["an"] == "Fachkraft" else z["an"]
                w = wartet.get(nr)
                if w:  # 1914 (D345.1): nur offene Wartegründe (startbar.offen_warte), und nie, wenn der Vorgang auf den Empfänger selbst wartet
                    try: w = startbar.offen_warte(zl[nr])
                    except Exception: pass
                    r_an = an if scharf else ALT_EMPFAENGER.get(an, an)
                    w = [t for t in w if t not in (an, r_an)]
                if w and an not in startbar.BUERO:
                    ausgabe.append("NICHTS Übergabe: %s an %s liegt, Vorgang wartet auf %s (1911)" % (z["k"], an, ", ".join(w))); continue
                je.setdefault(an, []).append((z["k"], z["was"], z["seit"]))
        rang = _ue.buero_rang(docs or DOCS)  # 1796: Büro-Folge Eilt, Fund des Chefs, Themenblock, Eingangszeit
        for an in je:
            je[an] = [(k, w) for k, w, s in sorted(je[an], key=lambda x: rang(_ue.nr_aus(x[0]), x[1], x[2]))]
    except Exception as e:
        ausgabe.append("WARNUNG offene Übergabezeilen nicht gelesen: %s (1739)" % e); return {}
    for an, zs in sorted(je.items()):
        r = "Ford" if an == "Disponent" else an if scharf else ALT_EMPFAENGER.get(an, an)  # 1893: Disponent ist Fords Sitzung
        teil = "Offene Zeilen an %s (1739): %s. Je Zeile `vorgang.py annehmen <Kennung>`, Vorgangsdatei `docs/vorgang/<Nr>.md` lesen; fertig: `vorgang.py erledigt <Kennung>`." % (an, "; ".join("%s %s" % (k, w) for k, w in zs[:6]))
        sitz = [s for s in je_rolle.get(r, []) if s["id"] not in archiviert] if r != "Ford" else []
        if sitz: ausgabe.append("NACHRICHT %s | %s | %s" % (r, juengste(sitz)["id"], teil))
        elif r != "Ford" and start and start(r, zs[0][0].split("-Ü")[0], teil): pass
        else: ausgabe.append("NACHRICHT Ford | - | " + (teil if r == "Ford" else "keine Sitzung %s: starten oder zuteilen. %s" % (r, teil)))
    return je


def startbar_zeile(nr):
    return next((d for d in startbar.zeilen_liste() if d["nr"] == nr), None)

def ist_scharf():
    return os.path.isfile(os.path.join(os.path.dirname(os.path.abspath(__file__)), "1727-SCHARF"))

def auftrag_fehlt(nr, docs=None, titel=None):
    """1739 (7.1 „kein Start ohne Feld Zurück“): Grund, warum Vorgang nr keinen gültigen Auftrag hat (jüngster Abschnitt
    „## Auftrag (…)“ in docs/vorgang/<Nr>.md, geprüft mit auftrag.pruefen: sieben Felder, „Zurück“ mit Inhalt, höchstens 2 KB),
    sonst None. Zeilen ohne Nummer (M?, Stillstand, Kosten) brauchen keinen."""
    if not re.match(r"B?\d", str(nr)): return None  # 1949: Build-Auftrag B<n> braucht ebenso einen Auftrag
    try:  # 1789: Routinen (Titel „(Routine, Auftrag <Datei> …)“) sind vom Feld „Zurück“ ausgenommen, Teil A ist der Auftrag
        import auftrag as _a
        if _a.routine(titel if titel is not None else next((d["titel"] for d in startbar.zeilen_liste() if d["nr"] == nr), "")): return None
    except Exception: pass
    p = os.path.join(docs or DOCS, "vorgang", "%s.md" % nr)
    text = lesen(p) if os.path.isfile(p) else ""
    ab = juengster_auftrag(text)
    if not ab: return "kein Auftrag"
    teil = text[ab[0]:]
    n = re.search(r"(?m)^## ", teil)
    try:
        import auftrag as _a
        f = _a.pruefen((teil[:n.start()] if n else teil).strip())
    except Exception as e:
        return "Auftrag nicht geprüft (%s)" % e
    return ("Auftrag: " + "; ".join(f[:2])) if f else None

ARCHIV_SCHUTZ_MIN = 15
def schutz_min(scharf=None):
    """1739 (7.1 „Archivieren mit Schutz 15 Minuten“; Büro-Gegenüberstellung: „nie binnen 15 Minuten nach der letzten Chefnachricht“):
    Minuten Ruhe, bevor eine Sitzung archiviert wird. list_sessions nennt die letzte Chefnachricht nicht, darum zählt das letzte
    Ereignis (updated_at; enger als verlangt, nie weiter). Bis zur Umschaltung (tools/1727-SCHARF) 1 Minute (340.10 (c))."""
    return ARCHIV_SCHUTZ_MIN if (ist_scharf() if scharf is None else scharf) else 1

AUFTRAG_KOPF = re.compile(r"(?m)^## Auftrag \((\d\d)\.(\d\d)\.,? (\d\d):(\d\d)\)")

def juengster_auftrag(text, jetzt=None):
    """1798 (Kern Arbeitsplaner: Auftrag oben in die Vorgangsdatei): (Anfang nach der Kopfzeile, Ende vor dem nächsten „## “) des
    jüngsten Abschnitts „## Auftrag (TT.MM., HH:MM)“ nach Zeit, gleich wo er steht (alte Dateien: unten); sonst None."""
    j = jetzt or JETZT; beste = None
    for m in AUFTRAG_KOPF.finditer(text or ""):
        t, mo, h, mi = (int(x) for x in m.groups())
        try: d = datetime.datetime(j.year if (mo, t) <= (j.month, j.day) else j.year - 1, mo, t, h, mi)
        except ValueError: continue
        if beste is None or d >= beste[0]: beste = (d, m.end())
    if not beste: return None
    n = re.search(r"(?m)^## ", text[beste[1]:])
    return beste[1], (beste[1] + n.start()) if n else len(text)

def auftrag_seit(text, jetzt=None):
    """Zeit des jüngsten Abschnitts „## Auftrag (TT.MM., HH:MM)“ der Vorgangsdatei (auftrag.py), sonst None."""
    j = jetzt or JETZT; beste = None
    for t, m, h, mi in AUFTRAG_KOPF.findall(text or ""):
        try: d = datetime.datetime(j.year if (int(m), int(t)) <= (j.month, j.day) else j.year - 1, int(m), int(t), int(h), int(mi), tzinfo=BERLIN)
        except ValueError: continue
        beste = max(beste or d, d)
    return beste

def leistungsstufe(s, text):
    """„Hoch“ bei Umgebung HOCH oder „Leistungsstufe: Hoch“ im jüngsten Auftrag (Feld 8 nach 1742), sonst „Mittel“."""
    if s.get("environment_id") == HOCH: return "Hoch"
    ab = juengster_auftrag(text or "")
    teil = (text or "")[ab[0]:ab[1]] if ab else ""
    return "Hoch" if re.search(r"(?i)Leistungsstufe\W{0,4}hoch\b", teil) else "Mittel"

def block_zeit(b, jetzt):
    """1779 c: Zeit „TT.MM., HH:MM“ am Anfang eines Rückmeldeblocks („- **21.11., 21:00**, Ford:“, ohne „- **“), sonst None."""
    m = re.match(r"(\d\d?)\.(\d\d?)\., (\d\d?):(\d\d)", b)
    if not m: return None
    t, mo, h, mi = map(int, m.groups())
    try: return datetime.datetime(jetzt.year if (mo, t) <= (jetzt.month, jetzt.day) else jetzt.year - 1, mo, t, h, mi, tzinfo=BERLIN)
    except ValueError: return None

def hoechstdauer_zeilen(ausgabe, je_rolle, archiviert, docs=None, jetzt=None, grenzen=None, scharf=None):
    """1766: laufende Sitzung (working/blocked) über der Höchstdauer ihres Auftrags → Zeile HÖCHSTDAUER für Ford: anhalten
    (interrupt_session) und Rückmeldung in die Vorgangsdatei. Erstes Mal „Hinweis“ (Abbruch, ein Neustart; Muster ablauf.md A6),
    zweites Mal je Vorgang „steckt fest“ → rueckmeldung.py gibt es an Sokrates (1763 C), er entscheidet über die Grenze (Profil Kosten).
    Steht die Sitzungskennung schon in einer Rückmeldung „Höchstdauer“, läuft die Uhr ab deren Zeit neu (1779 c: Weckruf oder WEITER
    ließ die Sitzung sonst ohne Grenze weiterlaufen); über der Grenze dann „steckt fest“, nach „steckt fest“ mit ihrer Kennung nichts mehr.
    1779 b: Sitzung, die nur ein offener Weckruf hält (idle, wartet etwa auf den Build), prüft sie nicht; „Ford 2“ nie."""
    grenzen = HOECHSTDAUER_MIN if grenzen is None else grenzen
    if not (ist_scharf() if scharf is None else scharf) or not any(grenzen.values()): return []
    j = jetzt or JETZT; d = os.path.join(docs or DOCS, "vorgang"); neu = []
    for r, ss in sorted(je_rolle.items()):
        if r in ("Ford", "Ford 2", "Sokrates", "Sonstige"): continue
        for s in ss:
            if s["id"] in archiviert or not s["_info"][1] or s.get("_nur_wecker"): continue
            nr = nummer_aus_titel(s.get("title", ""))
            if not nr: continue
            p = os.path.join(d, "%s.md" % nr); text = lesen(p) if os.path.isfile(p) else ""
            st = leistungsstufe(s, text); g = grenzen.get(st)
            if not g: continue
            hd = [b for b in re.split(r"(?m)^- \*\*", text) if "Höchstdauer" in b]
            eigen = [b for b in hd if s["id"] in b]
            if any("steckt fest" in b for b in eigen): continue
            seit = max([x for x in (z(s["created_at"]).astimezone(BERLIN), auftrag_seit(text, j)) + tuple(block_zeit(b, j) for b in eigen) if x])
            dauer = int((j - seit).total_seconds() // 60)
            if dauer <= g: continue
            wort = "steckt fest" if hd else "Hinweis"
            msg = "%s: Höchstdauer %d Min. (%s) überschritten, %d Min. seit %s, Sitzung %s angehalten (1766)%s" % (
                wort, g, st, dauer, seit.strftime("%d.%m., %H:%M"), s["id"], ", zweites Mal" if hd else "; ein Neustart wie sonst")
            neu.append("HÖCHSTDAUER %s | %s | %s | %s" % (s["id"], r, nr, msg))
    ausgabe += neu
    return neu


def routine_offen(s):
    """1789: Vorgang im Titel der Routinensitzung steht noch offen (nicht erledigt) in der Vorgangsliste."""
    nr = nummer_aus_titel(s.get("title", ""))
    return any(d["nr"] == nr and not str(d.get("stand", "")).startswith("erledigt") for d in startbar.zeilen_liste())

def juengste(ss):
    """Die zuletzt tätige Sitzung eines Bereichs (261.6): späteres updated_at, bei Gleichstand späteres created_at."""
    return max(ss, key=lambda x: (z(x["updated_at"]), z(x["created_at"])))

def titel_datum(titel):
    """Erstes TT.MM. im Titel, wenn es in der Zukunft liegt; heute mit Uhrzeit, wenn sie noch kommt (375): gleich nach dem
    Datum („16.11., 8 Uhr“, „16.11. 08:00“; 727, D62.2) oder „um/ab H:MM“ danach; sonst None."""
    for m in re.finditer(r"(?<!\d)(\d\d?)\.(\d\d)\.", titel):
        try: d = startbar.jahr_von(int(m.group(1)), int(m.group(2)))
        except ValueError: continue
        if d > JETZT.date(): return "%02d.%02d." % (d.day, d.month)
        rest = titel[m.end():]
        # 1372: „ab 16.11.“ ist ein Datum, keine Uhrzeit 16:11 (Punkt danach)
        u = re.match(r"\s*,?\s*(?:(?:um|ab)\s+)?(\d\d?)(?:[:.](\d\d)(?![.\d])(?:\s*Uhr)?|\s*Uhr)\b", rest) or \
            re.search(r"\b(?:um|ab)\s+(\d\d?)[:.](\d\d)(?![.\d])\b", rest)
        if d == JETZT.date() and u and (int(u.group(1)), int(u.group(2) or 0)) > (JETZT.hour, JETZT.minute):
            return "%02d.%02d., %d:%s" % (d.day, d.month, int(u.group(1)), u.group(2) or "00")
    return None

def warnungen_bekannt():
    """Zeilen „Nachfolger-Warnung <Rolle> (Übergabe …)“ im Protokoll."""
    return [l for l in lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")).splitlines() if "Nachfolger-Warnung" in l]

def nummer_aus_titel(t):
    m = re.search(r"–\s*([0-9][0-9a-zA-Z.]*)", t)
    if m and not re.fullmatch(r"\d\d\.\d\d\.(\d{2,4})?", m.group(1)): return m.group(1).rstrip(".")  # D52.1: Datum „02.11.“ ist kein Vorgang
    # 261.2: Nummer auch mitten im Titel („Tom – Umriss prüfen 216.3“); Uhrzeiten in Klammern und „Build 40“ zählen nicht
    s = re.sub(r"\([^)]*\)", " ", t)
    s = re.sub(r"\b\d\d\.\d\d\.(\d{2,4})?", " ", s)  # D52.1
    s = re.sub(r"\bBuilds?\s+\d+(\s+und\s+\d+)?", " ", s)
    s = re.sub(r"\b(Godot|Runde|Lauf|Brücke)\s+\d+[a-z]?\b", " ", s)  # „Tom – Umzug Godot 12“ buchte auf Vorgang 12 (Ford 25.10.)
    m = re.search(r"(?<![\d.:])(\d{2,4}[a-zA-Z]?(?:\.\d+[a-z]?)*)(?!\d|:\d)", s)  # 1134: vierstellig auch mitten im Titel
    return m.group(1).rstrip(".") if m else ""

def nummern_aus_titel(t):
    """379: alle Vorgangsnummern im Titel als Kommaliste („Jerry – 348.7a Runde 5, 348.12f Rute r7“ → „348.7a,348.12f“), Kosten zu gleichen Teilen (197)."""
    erste = nummer_aus_titel(t)
    if not erste: return ""
    s = re.sub(r"\([^)]*\)", " ", t.split("–", 1)[-1])
    s = re.sub(r"\b\d\d\.\d\d\.(\d{2,4})?", " ", s)  # D52.1
    s = re.sub(r"\bBuilds?\s+\d+(\s+und\s+\d+)?", " ", s)
    s = re.sub(r"\b(Godot|Runde|Lauf|Brücke)\s+\d+[a-z]?\b", " ", s)
    alle = [erste] + [m.rstrip(".") for m in re.findall(r"(?<![\d.:\w])(\d{2,4}[a-zA-Z]?(?:\.\d+[a-z]?)*)(?!\d|:\d)", s)]
    return ",".join(dict.fromkeys(alle))

ARCHIVMARKEN_MAX = 20  # 1147: Merker „Marke Archiv <id>“, nur die jüngsten
PROTOKOLL_MAX = 20  # ARBEIT-BETRIEB.md „höchstens 20 Zeilen; ältere streichen“ (117)
TECHNIK = re.compile(r"Marke |Startsperre \d|Nachfolger-Warnung")
ZEILE = re.compile(r"- (\d\d):(\d[\dx]) (\d\d)\.(\d\d)\.")

def aufraeumen():
    """270: hält Notizen unter den Grenzen, die Ford von Hand nie kürzte. Protokoll: die 20 neuesten Zeilen mit Tat (neueste oben),
    dazu Marken und Warnungen von heute, Startsperren und „Start-fehlt“ bis START_PRUEF_STD alt (liest lauf.py, 1147, 1187); älteres steht in Git.
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
        # 1147: Technikzeilen nur von heute (vorher heute und gestern): die Marken prüfen auf „heute“ oder je Sitzung einmal,
        # und 182 von 205 Zeilen waren Technik (22 KB im Protokoll, Datei 45 KB). Schlimmster Fall: eine Warnung über Mitternacht doppelt.
        # 1129.1 P4 (a): Startsperren und „Start-fehlt“ liest lauf.py nur 20 Minuten (SPERRE_MIN) bis 3 Stunden (START_PRUEF_STD) weit;
        # älter als 6 Stunden fallen sie weg, außer der jüngsten Startsperre je Rolle (startmarken). 13.11.: 174 von 296 Zeilen, 58 KB Datei
        def alter_h(l):
            m = ZEILE.match(l)
            try: d = JETZT.replace(day=int(m.group(3)), month=int(m.group(4)), hour=int(m.group(1)), minute=int(m.group(2).replace("x", "0")), second=0, microsecond=0)
            except ValueError: return 0
            if d > JETZT + datetime.timedelta(hours=1): d = d.replace(year=d.year - 1)  # 31.12. im Januar
            return (JETZT - d).total_seconds() / 3600
        # 1187 (D213.1): Startsperren und „Start-fehlt“ von gestern bleiben, solange lauf.py sie liest (START_PRUEF_STD); sonst strich der
        # Filter „nur heute“ eine Sperre von 23:58 im ersten Lauf nach Mitternacht, und Startprüfung 837 und 20-Minuten-Sperre sahen sie nicht
        sperrzeile = lambda l: re.search(r"Startsperre \d|Marke Start-fehlt", l)
        technik = [l for l in zeilen if TECHNIK.search(l) and (ZEILE.match(l).group(3) + "." + ZEILE.match(l).group(4) + "." == JETZT.strftime("%d.%m.")
                                                            or (sperrzeile(l) and alter_h(l) <= START_PRUEF_STD))]
        juengste = {}
        for l in technik:
            m = re.search(r"Startsperre \d\d:\d\d Start (\w+(?:, \w+)*)", l)
            if m:
                for name in m.group(1).split(", "):
                    if name not in juengste or alter_h(l) < alter_h(juengste[name]): juengste[name] = l
        technik = [l for l in technik if alter_h(l) <= 6 or l in juengste.values()
                   or not re.search(r"Startsperre \d|Marke Start-fehlt", l)]
        # 1957: Startsperren mit Rufname von heute und gestern bleiben (rufname.rolle ordnet laufende Rufnamen-Sitzungen darüber zu)
        import rufname as _rn
        gestern = (JETZT - datetime.timedelta(days=1)).strftime("%d.%m.")
        ruf = [l for l in zeilen if l not in technik and ZEILE.match(l).group(3) + "." + ZEILE.match(l).group(4) + "." in (JETZT.strftime("%d.%m."), gestern)
               and _rn.sperr_eintraege(l, JETZT.year)]
        technik += ruf
        # 1147: „Marke Archiv <id>“ ist nur ein Merker je Sitzung (D40.2); die 20 jüngsten reichen, ältere Sitzungen sind längst archiviert
        archiv = [l for l in technik if re.search(r"Marke Archiv \S", l)]
        if len(archiv) > ARCHIVMARKEN_MAX:
            alt_archiv = set(sorted(archiv, key=alter_h)[ARCHIVMARKEN_MAX:])
            technik = [l for l in technik if l not in alt_archiv]
        taten = sorted([l for l in zeilen if not TECHNIK.search(l)], key=zeit, reverse=True)[:PROTOKOLL_MAX]
        while kopf and not kopf[-1].strip(): kopf.pop()
        neu = t[:i] + "\n".join(kopf) + "\n\n" + "\n".join(taten + technik) + "\n"
        if neu != t:
            n += len(zeilen) - len(taten) - len(technik); open(p, "w", encoding="utf-8").write(neu)
    p = os.path.join(DOCS, "LISTE-VORGAENGE.md"); text = lesen(p)
    zs = [d for d in startbar.vorgangsliste(text) if d["wort"] == "erledigt" and d["nr"] not in startbar.SONDER]
    if zs:  # 275.2: ins Archiv im alten Format (Nr, Vorgang, Bereich, Kl., Kosten, Vorrat, Stand), damit Archivleser gleich bleiben
        L = text.split("\n"); weg = {d["i"] for d in zs}
        open(p, "w", encoding="utf-8").write("\n".join(l for i, l in enumerate(L) if i not in weg)); startbar.liste_merken(DOCS)  # 275 Stufe 2
        q = os.path.join(DOCS, "LISTE-VORGAENGE-ARCHIV.md")
        alt = lesen(q)  # erst lesen, dann öffnen: open(…, "w") leert die Datei
        neu = ["| %s | %s | %s | %s | %s | %s | %s |" % (d["nr"], d["titel"], d["bereich"], d["kl"], d["kosten"] or "–", d["besitzer"], d["stand"]) for d in zs]
        open(q, "w", encoding="utf-8").write(alt.rstrip("\n") + "\n" + "\n".join(neu) + "\n")
        n += len(zs); startbar.neu_laden()
    import vorgang  # 1543: je Besitzer Muss vor Kür, von selbst in jedem Lauf
    n += vorgang.ordnen()
    return n

def noch_offen(ausgabe, rolle, nrn):
    """275 (Chef 15:20, „Ford sichert“): endet eine Sitzung, deren Vorgang im Vorrat oder in der Liste noch „in Arbeit“ steht, meldet Ford es dem Besitzer."""
    for nr in [x for x in (nrn or "").split(",") if x and x != "Betrieb"]:
        zeile = [d for d in startbar.zeilen_liste() if d["nr"] == nr]
        if zeile and zeile[0]["wort"] == "in Arbeit":
            ausgabe.append("WARNUNG %s %s: Sitzung endet, Stand noch „in Arbeit“; Besitzer setzt ihn mit tools/vorgang.py stand (275)" % (rolle, nr))

NOTIZ_WARNUNG = []  # 1100 A (6): ein Lauf mit dieser Warnung ist nicht leer
def notizen_frisch():
    """380: Ford zog den Arbeitsbaum, lauf.py las aber die alten Notizen in bornim-main (Zeile 275 von Diogenes fehlte, NICHTS statt START).
    Vor jedem Lauf die Notizen auf origin/main bringen (nur vorspulen); geht das nicht, Lauf abbrechen statt mit altem Stand rechnen."""
    d = os.path.join(DOCS, "..")
    try:
        subprocess.run(["git", "-C", d, "pull", "-q", "--ff-only", "origin", "main"], capture_output=True, text=True, timeout=60)
        r = subprocess.run(["git", "-C", d, "rev-list", "--count", "HEAD..origin/main"], capture_output=True, text=True, timeout=20)
        hinten = int(r.stdout.strip() or 0)
    except Exception as e:
        print("WARNUNG Notizen nicht geprüft (%s); Lauf mit Stand %s" % (e, d)); NOTIZ_WARNUNG.append(e); return True
    if hinten:
        print("WARNUNG-LAUT Notizen in %s %d Commits hinter origin/main und nicht vorspulbar (eigene Commits?): erst git -C %s pull --no-rebase, dann lauf.py erneut (380)" % (os.path.abspath(d), hinten, os.path.abspath(d)))
        return False
    return True

def main():
    a = sys.argv[1:]
    import rufname as _rn; _rn.BETRIEB = os.path.join(DOCS, "ARBEIT-BETRIEB.md")  # 1957: Startsperren dort, wo lauf.py sie schreibt
    if any(x in ("--help", "-h", "--hilfe", "hilfe") for x in a):  # 1945: Hilfe vor jeder Prüfung (Notizkopie, Stellung)
        return print(__doc__)
    if a[:1] == ["--haken"] and len(a) > 1:  # 1895: für weiter-haken.py, nur die Nummer (leer = nichts)
        return print(haken_naechste(a[1]) or "")
    if a[:1] == ["--morgen"]:  # 783 W7 (Chef 09.11., 20:16): Fords 7-Uhr-Zeile entfällt, alles steht im Tagesbericht 7:30
        return print("Morgenmeldung entfällt (783 W7); Chefsache-Zahl und Bitte um das Bild der Nutzung stehen im Tagesbericht.")
    if a[:1] == ["--aufraeumen"]:
        return print("Aufgeräumt: %d Zeilen (Notizen pushen)" % aufraeumen())
    if a[:1] == ["--kosten"]:  # 384: nur mit Kennung, sonst fehlt die Sitzung im Buchungsverzeichnis (doppelt oder nie gebucht)
        if len(a) < 4 or not a[3].startswith(("session_", "ohne:")):
            print("lauf.py --kosten NR USD session_…: Kennung fehlt (384); ohne Sitzung nur mit „ohne:<Grund>“", file=sys.stderr); sys.exit(2)
        return kosten_addieren(a[1], float(a[2].replace(",", ".")), a[3] if a[3].startswith("session_") else None)
    if "--ohne-pull" not in a and not notizen_frisch(): sys.exit(1)
    if a[:1] == ["--start"]:  # 1989: Handstart mit Startblock; mit --sperre schreibt und pusht lauf.py die Startsperre selbst
        r = [x for x in a[1:] if x != "--sperre" and x != "--ohne-pull"]
        if len(r) < 3: sys.exit('lauf.py --start ROLLE NR "Nachricht" [SEITE …] [--sperre]')
        ss = None
        if r[3:]:
            import rufname as _r2; ss = []
            for p in r[3:]: ss += _r2.lies_sitzungen(lesen(p))
        zs = start_zeilen(r[0], r[1], r[2], ss)
        sp = [x[len("STARTSPERRE "):] for x in zs if x.startswith("STARTSPERRE ")]
        if "--sperre" in a and sp:
            if protokoll_pushen(lambda alt: alt.rstrip("\n") + "\n" + sp[0] + "\n", "Startsperre %s %s (lauf.py --start, 1989)" % (r[0], r[1])):
                zs = [x if not x.startswith("STARTSPERRE ") else "NICHTS Startsperre: geschrieben und gepusht (%s)" % sp[0] for x in zs]
        for x in zs: print(x)  # 1992: nicht z, das überdeckt z() in ganz main() (UnboundLocalError)
        return
    # 1100 A (1): Ford liest die Stellung nicht mehr selbst (notiz.sh entfällt im Lauf); lauf.py nennt sie, wenn sie nicht „Pilot“ ist (81g)
    stellung = re.search(r"\*\*Ford: (aus|Co-Pilot|Pilot)\*\*", lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")))
    if stellung and stellung.group(1) == "aus":
        return print("STELLUNG aus: Ford endet hier, nichts schreiben, nichts melden (81g)")
    vorab = []
    if stellung and stellung.group(1) == "Co-Pilot":
        vorab.append("STELLUNG Co-Pilot: START nicht ausführen; nur Neustart-Meldungen, „Auftrag Diogenes“ und Push-Meldungen (LISTE-BETRIEB.md „Stellung“, 81g)")
    if not stellung: vorab.append("WARNUNG Stellung „**Ford: …**“ oben in ARBEIT-BETRIEB.md nicht gefunden; Lauf wie Pilot (81g)")
    nur_muss = "--nur-muss" in a
    bremse = None
    if ist_scharf():  # 1804: Guthabenstufe (287) und Laufsperre aus Chefwort, erst mit tools/1727-SCHARF
        import guthaben
        zl = {d["nr"]: d for d in startbar.zeilen_liste()}
        bremse = guthaben.Bremse(JETZT, lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")), rueck=lambda n: guthaben.ruecklaeufer(zl.get(n)))
        vorab.extend(bremse.zeilen()); nur_muss = nur_muss or bremse.nur_muss()
    sperre = "--sperre" in a  # 1997: --besetzung erlaubt, ohne Wirkung (jeder Lauf schreibt und pusht die Besetzung)
    liegt = "--liegt" in a  # 891: Lauf auf „Start <Rolle> <Nr>“; eine ruhende Sitzung unter 20 Minuten belegt dann nicht, sie bekommt WEITER
    ausschluss = {}; wecker = set()
    for i, x in enumerate(a):
        if x == "--wecker" and i + 1 < len(a): wecker.update(w.strip() for w in a[i + 1].split(",") if w.strip())  # 916
        if x == "--ohne" and i + 1 < len(a):
            nr, _, grund = a[i + 1].partition(":")
            if grund.strip(): ausschluss[nr.strip()] = grund.strip()
            else: print("WARNUNG --ohne %s ohne Grund ignoriert (190.2)" % nr)
    # 1148 (von Ford): --ohne <Rolle>:Grund nimmt die ganze Rolle aus diesem Lauf (START,
    # ARCHIVIERE und die Warnung „Start nicht angekommen“); vorher wirkte nur --ohne <Nr>, und Ford bekam weiter START Spike
    ohne_rollen = {n for n in ausschluss if re.fullmatch(startbar.ROLLEN_NAMEN, n)}
    seiten = [x for i, x in enumerate(a) if not x.startswith("--") and not (i and a[i - 1] in ("--ohne", "--wecker"))]
    if not seiten: sys.exit(__doc__)
    offen = []; alle = {}
    for p in seiten:
        for s in kosten.sitzungen(p, offen): alle[s["id"]] = s
    ausgabe = vorab; archiviert = set()
    schutz = geschuetzt()  # 1531
    if offen: ausgabe.append("WARNUNG Seite abgeschnitten (has_more) in %s: Plan unvollständig, weitere Seite holen" % ", ".join(offen))
    leb = [s for s in alle.values() if s.get("session_status") != "SESSION_STATUS_ARCHIVED"]
    for name, tg, nach in startbar.nach_ausgefallen(JETZT):  # 1793: Routine mit „nach“ in der Nachholfrist nicht angelegt
        ausgabe.append("WARNUNG Wochentermin %s „%s“ ausgefallen: „%s“ war bis zum Folgetag nicht erledigt (1793; Sokrates, von Hand anlegen oder auslassen)" % (tg, name[:60], nach))
    for t, ber, wer in startbar.wochentermine_faellig(JETZT):  # 719 A: vor dem Plan, damit der neue Vorgang im selben Lauf startet
        if not sperre:
            ausgabe.append("NICHTS %s: Wochentermin „%s“ fällig, der Lauf mit --sperre legt ihn an (719)" % (wer, t)); continue
        try:
            import vorgang, io, contextlib
            with contextlib.redirect_stdout(io.StringIO()): nr = vorgang.neu(t, ber, "M", wer)  # Ford liest nur Befehlszeilen
            ausgabe.append("NICHTS %s: Wochentermin %s angelegt, „%s“ (719; Notizen pushen)" % (wer, nr, t))
        except SystemExit as e:
            ausgabe.append("WARNUNG Wochentermin „%s“ nicht angelegt: %s (719, Perikles)" % (t, e))
    sb = startbar.sammelbuild_faellig()  # 774: gemeinsamer Build nie verwaist
    if sb and not sperre:
        ausgabe.append("NICHTS %s: Sammelbuild fällig, der Lauf mit --sperre legt ihn an (774)" % sb[2])
    elif sb:
        try:
            import vorgang, io, contextlib
            with contextlib.redirect_stdout(io.StringIO()): nr = vorgang.neu(sb[0], sb[1], "M", sb[2], None, True)
            ausgabe.append("NICHTS %s: Sammelbuild %s angelegt (774; Notizen pushen)" % (sb[2], nr))
            startbar.neu_laden()
        except SystemExit as e:
            ausgabe.append("WARNUNG Sammelbuild nicht angelegt: %s (774, Perikles)" % e)
    zf = startbar.zusammenfuehren_faellig()  # 1424: getesteter Build liegt nie neben main
    if zf and not sperre:
        ausgabe.append("NICHTS %s: Zusammenführen fällig, der Lauf mit --sperre legt es an (1424)" % zf[2])
    elif zf:
        try:
            import vorgang, io, contextlib
            with contextlib.redirect_stdout(io.StringIO()): nr = vorgang.neu(zf[0], zf[1], "M", zf[2], None, True)
            ausgabe.append("NICHTS %s: Zusammenführen %s angelegt (1424; Notizen pushen)" % (zf[2], nr))
            startbar.neu_laden()
        except SystemExit as e:
            ausgabe.append("WARNUNG Zusammenführen nicht angelegt: %s (1424, Perikles)" % e)
    neue_liste()  # 1893
    AUFTRAG_IN_ARBEIT.clear()  # 1932: Aufträge, die eine Planer-Sitzung gerade schreibt, bekommt kein zweiter Planer
    AUFTRAG_IN_ARBEIT.update(planer_in_arbeit(leb))
    st = stand(); chefd = chefdateien_je_rolle(); marken = startmarken()
    je_rolle = {}
    for s in leb:
        r = kosten.rolle(s.get("title", ""), s.get("created_at"))
        upd = z(s["updated_at"])
        ruhig = (JETZT - upd).total_seconds() / 60
        bucket = s.get("status_bucket", "")
        laufend = ("WORKING" in bucket or "BLOCKED" in bucket or s.get("session_status") == "SESSION_STATUS_RUNNING") and ruhig < 60
        if s["id"] in wecker and not laufend: laufend = True; s["_nur_wecker"] = True  # 916: offener Weckruf hält die Sitzung, sonst START und ARCHIVIERE, der Wecker ginge verloren; 1779 b: Höchstdauer prüft sie nicht
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
        if r in ("Ford", "Sonstige", "Sokrates") or not k or k < 0.5 or nummer_aus_titel(s.get("title", "")): continue
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
        r = kosten.rolle(s.get("title", ""), s.get("created_at"))
        ziel = "Betrieb" if r == "Ford" else (nummer_aus_titel(s.get("title", "")) or "Betrieb")
        if sperre:  # echter Lauf: lauf.py bucht selbst (19.10.: Ford führte BUCHE nicht aus, 261.2); Ford pusht die Notizen
            kosten_addieren(ziel, k, s["id"]); ausgabe.append("GEBUCHT %s | %s | %.2f | %s (Notizen pushen)" % (s["id"], r, k, ziel))
        else:
            ausgabe.append("BUCHE %s | %s | %.2f | %s" % (s["id"], r, k, ziel))
    # Archivieren: Archivregel in vier Sätzen (261.5); nur Ford ausgenommen (Ford 2 entfällt, 650.1)
    marke_alt = lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")); neue_marken = []
    def marke_zeit(text):
        """Zeitpunkte aller Protokollzeilen „- HH:MM TT.MM.: Marke <text>“."""
        aus = []
        for m in re.finditer(r"- (\d\d):(\d\d) (\d\d)\.(\d\d)\.: Marke " + re.escape(text) + r"\b", marke_alt):
            try: aus.append(JETZT.replace(month=int(m.group(4)), day=int(m.group(3)), hour=int(m.group(1)), minute=int(m.group(2)), second=0, microsecond=0))
            except ValueError: pass
        return aus
    for nr, tafel, k, b in ABGELAUFEN:  # 718 A: einmal am Tag, bis die Zeile aus PROBEN gestrichen oder BIS auf Wort des Chefs verlängert ist
        if not [d for d in marke_zeit("Probe-abgelaufen " + nr) if d.date() == JETZT.date()]:
            ausgabe.append("WARNUNG-LAUT Probe %s abgelaufen, auswerten: %s %s seit %s wieder %s (verlängern nur auf Wort des Chefs, 718)" % (nr, tafel, k, b, globals()[tafel].get(k)))
            neue_marken.append("Probe-abgelaufen " + nr)
    for r, ss in sorted(je_rolle.items()):
        if r in NIE_ARCHIV: continue
        if r == "Sonstige":  # (1) ohne Rolle im Titel lässt Ford die Sitzung stehen und meldet es einmal
            for s in ss:
                if s.get("title", "").startswith("Ford"): continue
                if not marke_zeit("Ohne-Rolle " + s["id"]):
                    ausgabe.append("WARNUNG Sitzung %s „%s“ hat keine Rolle im Titel: bleibt stehen, nicht archiviert (261.5)" % (s["id"], s.get("title", ""))); neue_marken.append("Ohne-Rolle " + s["id"])
            continue
        if r in ohne_rollen or lauf_laeuft(r): continue  # 1148: --ohne <Rolle> und „Lauf läuft bis HH:MM“ nehmen sie ganz aus dem Lauf
        for s in ss:
            _, laufend, ruhig, hinder = s["_info"]
            if s["id"] in schutz: continue  # 1531
            if laufend or ruhig < schutz_min(): continue  # 340.10 V4 (c): unter 60 s nach dem letzten Ereignis nicht archivieren (Sokrates 13.11., 03:41); 1739: scharf 15 Min.
            # (2) nur mit neuerer Sitzung desselben Bereichs, ohne Wartezeit (261.5, Chef 16:46; ersetzt 60 Minuten aus 238)
            # 261.6 (Chef 22.10., 06:43): „neuer“ = letzte Arbeit (updated_at), nicht created_at; bleiben darf nur die zuletzt tätige
            # 1789: eine Routine bleibt nur, solange ihr Vorgang offen ist (eine Sitzung je Woche, keine neuere löst sie ab)
            if s is juengste(ss) and not (r in ROUTINE_ROLLEN and not routine_offen(s)): continue
            k = s.get("external_metadata", {}).get("usage", {}).get("cost_usd")
            nrn = nummern_aus_titel(s.get("title", "")) or "Betrieb"
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
                ausgabe.append("WARNUNG-LAUT Disponent hat ARCHIVIERE %s (%s) aus dem Lauf von %s nicht ausgeführt (261.5); darf der Disponent es nicht, archiviert der Chef sie selbst" % (s["id"], r, alt[0].strftime("%H:%M")))
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
    # 1572 (Chef 17.11., 17:02: Ford hing zwei Stunden an einer Freigabe, keiner meldete): blocked = wartet auf eine Freigabe in der Sitzung;
    # ab 15 Minuten laut an den Chef mit Link, einmal je Sitzung und Stand, nachts lautlos (Ford selbst prüft die Uhr-Sitzung, LISTE-BETRIEB.md)
    for s in leb:
        r, laufend, ruhig, _ = s["_info"]
        if "BLOCKED" not in s.get("status_bucket", "") or ruhig < FREIGABE_MIN: continue
        m = "Freigabe %s %s" % (s["id"], s["updated_at"][:16])
        if ("Marke " + m) in marke_alt: continue
        ausgabe.append("%s Sitzung wartet auf Freigabe: %s „%s“ seit %s; Chef: in https://claude.ai/code/%s freigeben oder ablehnen (1572)" % (
            laut_nachts(), r, s.get("title", ""), berlin(z(s["updated_at"])), s["id"]))
        neue_marken.append(m)
    # 927 (D162.1, Schritt 9): Sitzung hängt = working, aber seit 60 Minuten ohne neues updated_at (zwei Läufe) und ohne Weckruf; einmal je Sitzung und Stand, nachts lautlos
    for s in leb:
        r, laufend, ruhig, _ = s["_info"]
        bucket = s.get("status_bucket", "")
        if laufend or "BLOCKED" in bucket or not ("WORKING" in bucket or s.get("session_status") == "SESSION_STATUS_RUNNING"): continue
        m = "Hängt %s %s" % (s["id"], s["updated_at"][:16])
        if ("Marke " + m) in marke_alt: continue
        ausgabe.append("%s Sitzung hängt: %s „%s“ seit %s ohne Lebenszeichen, https://claude.ai/code/%s (927)" % (
            laut_nachts(), r, s.get("title", ""), berlin(z(s["updated_at"])), s["id"]))
        neue_marken.append(m)
    # 837 (Chef 10.11., 10:4x): Startsperre ohne Sitzung meldet laut (START ausgelassen oder gescheitert) und belegt die Rolle nicht
    nicht_da = set()
    for name, d in sorted(marken.items()):  # nur die jüngste Sperre je Rolle; ein späterer Start ersetzt einen früheren
        alter = (JETZT - d).total_seconds() / 60
        if alter < START_PRUEF_MIN or alter > START_PRUEF_STD * 60 or start_angekommen(name, d, alle) or name in ohne_rollen: continue  # 1148
        nf, nf_zeit, _ = nachfolger(name) if name in VORRAT else (None, None, None)
        nf_offen = bool(nf) and nf_zeit is not None and not any(z(s["created_at"]) > nf_zeit for s in alle.values() if kosten.rolle(s.get("title", ""), s.get("created_at")) == name)
        if name in VORRAT and not start_noetig(name, st, ausschluss, nur_muss, nf_offen): continue  # 1586 (Ford ohne Vorrat: Warnung wie bisher)
        nicht_da.add(name)
        schl = "Start-fehlt %s %s" % (name, d.strftime("%d.%m.-%H:%M"))
        if schl in marke_alt or schl in neue_marken: continue
        ausgabe.append("WARNUNG-LAUT Start %s nicht angekommen: Startsperre %s, keine Sitzung %s seither; Disponent: START ausführen oder mit --ohne NR:Grund ausschließen (837)" % (name, d.strftime("%d.%m., %H:%M"), name))
        neue_marken.append(schl)
    for name in nicht_da: marken.pop(name, None)  # (2) zählt nicht als Belegung
    if bremse and bremse.ober:  # 2001: laufende Fachkräfte aus der Sitzungsliste („Laufend“, Kopf), dazu Startsperren unter SPERRE_MIN ohne Sitzung seither
        gesperrt_ = ["Startsperre %s %s" % (r, d.strftime("%H:%M")) for r, d in sorted(marken.items()) if guthaben.fachkraft(r) and (JETZT - d).total_seconds() < SPERRE_MIN * 60
            and not any(z(s["created_at"]) >= d - datetime.timedelta(minutes=START_PRUEF_MIN) for s in je_rolle.get(r, []))]
        bremse.laufend = guthaben.laufende_fachkraefte(je_rolle, archiviert) + len(gesperrt_)
        bremse.namen = guthaben.laufende_namen(je_rolle, archiviert) + gesperrt_  # 2001-Ü10: wer gezählt ist
        neu_ = [l for l in bremse.zeilen() if l.startswith("LAUFSPERRE ") and "Fachkräfte zugleich" in l]
        ausgabe[:] = [neu_[0] if l.startswith("LAUFSPERRE ") and "Fachkräfte zugleich" in l and neu_ else l for l in ausgabe]
    # Starten
    for nr, grund in sorted(ausschluss.items()): ausgabe.append("AUSGESCHLOSSEN %s: %s" % (nr, grund))
    ausgabe.extend(ohne_ueberholt(ausschluss, leb))
    sperren = []; neue_warnungen = []; sperr_nr = {}; morgen = []  # 1643: Vorgang je Startsperre, Zeilen für den Morgen
    bekannt = warnungen_bekannt()
    def vorgaenger(r):
        # 261.5 (Chef 18:25): startet ein Nachfolger, archiviert Ford die alten Sitzungen der Rolle gleich danach, nicht erst im nächsten Lauf
        for s in je_rolle.get(r, []):
            if s["id"] in archiviert or s["id"] in schutz or s["_info"][1] or s["_info"][2] < schutz_min(): continue  # 340.10 (c): 60 s Ruhe, scharf 15 Min. (1739)  (1531: geschützte nie)
            archiviert.add(s["id"])
            k = s.get("external_metadata", {}).get("usage", {}).get("cost_usd")
            if s.get("_frage_alt"): ausgabe.append("ÜBERTRAGE %s | %s | %s" % (s["id"], r, str(s["_frage_alt"]).replace("\n", " ")[:200]))
            ausgabe.append("ARCHIVIERE %s | %s | %s | %s" % (s["id"], r, ("%.2f" % k) if k is not None else "fehlt", nummern_aus_titel(s.get("title", "")) or "Betrieb"))
            noch_offen(ausgabe, r, nummern_aus_titel(s.get("title", "")))
            if not marke_zeit("Archiv " + s["id"]): neue_marken.append("Archiv " + s["id"])
    # 1246 (Chef 14.11., 10:28: „wenn ich nachts schlafe und ihr alle aufeinander wartet …“): keine Rolle hat startbares Muss, keine
    # Sitzung arbeitet, aber Muss-Zeilen hängen an einer startbaren Zeile einer Rolle, die lauf.py nicht startet (Sokrates; Halt und
    # Pause mit Datum sind gewollt, Pause ohne Datum sperrt nur die Kür, startbar.halt) → Zeile STILLSTAND-LÖSEN an den Disponenten, höchstens alle 3 Stunden
    # (Marke „Stillstand“); 1871 Stilllegung C (g): keine Muss-Zeile an Perikles mehr (G:484, G:486; Profil Disponent „Takt“, Stillstand an einer Entscheidung → Zeile an Sokrates).
    still = stillstand(st, je_rolle, archiviert, ausschluss)
    if still and not [d for d in marke_zeit("Stillstand") if (JETZT - d).total_seconds() < 3 * 3600]:
        ausgabe.append("STILLSTAND-LÖSEN (1246): " + still + "; je Ursache lösen (Zeile freigeben, Fachkraft starten, hängt es an einer Entscheidung: Zeile an Sokrates), nicht nur melden")
        neue_marken.append("Stillstand")
    for r in START_REIHE:
        for stueck, grund in lauf_marke_falsch(r):  # 1161: sonst archiviert der Lauf die Sitzung mitten im Hintergrundlauf
            ausgabe.append("%s Marke „%s“ in %s zählt nicht (%s): Sitzung gilt als fertig; richtig „Lauf läuft bis TT.MM., HH:MM“, höchstens 12 h, "
                           "(1148, 1369)" % (laut_nachts(), stueck, VORRAT[r], grund))
        if r in ohne_rollen:  # 1148
            ausgabe.append("NICHTS %s: mit --ohne %s ausgeschlossen (%s)" % (r, r, ausschluss[r])); continue
        if (lm := lauf_laeuft(r)):  # 1148: Hintergrundlauf in der Sitzung
            ausgabe.append("NICHTS %s: „%s“ im Vorrat, Hintergrundlauf in der Sitzung" % (r, lm)); continue
        muss, kuer, pause, _ = st.get(r, ([], [], None, []))
        # Hindernis hält nur die Sitzung der Zeile, nicht die Rolle (190.4)
        belegt = [s for s in je_rolle.get(r, []) if s["id"] not in archiviert and (s["_info"][1] or s["_info"][2] < SPERRE_MIN and not liegt)]
        nf, nf_zeit, nf_grund = nachfolger(r)
        gestartet = nf_zeit is not None and any(z(s["created_at"]) > nf_zeit for s in alle.values() if kosten.rolle(s.get("title", ""), s.get("created_at")) == r)
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
        # 641 (Diogenes 08.11., 09:07): „auf Abruf“ oder „nur auf Zuruf“ startet nur, wenn die Rolle Startbares hat
        # 754 (D99.1): mit --ohne ausgeschlossene Zeilen zählen dabei nicht als startbar
        frei_m = [x for x in muss if x[0] not in ausschluss]; frei_k = [x for x in kuer if x[0] not in ausschluss]
        if offen_nf and re.search(r"auf (Abruf|Zuruf)", offen_nf, re.I):
            if not (frei_m or (frei_k and r in MIT_KUER and not nur_muss)):
                ausgabe.append("NICHTS %s: Nachfolger „%s“ auf Abruf, nichts startbar" % (r, offen_nf))
                continue
            offen_nf = None  # 921 (Ford 11.11., 11:07): „auf Abruf“ ist kein Auftrag; Startbares (auch „M? entscheiden“, 190.8) startet nach der Zeilenregel mit Titel und Nachricht der Zeile
        # 276 (Fall 251): nennt der Nachfolger eine Zeile des eigenen Vorrats, die nicht startbar ist, gilt die Zeilenregel; beim zweiten Lauf laut
        # 893: Nummer auch hinter einem Wort („Tom – Sammelbuild 888“), sonst griff die Zeilenregel für gesperrte Zeilen nicht
        nf_nr = re.search(r"–\s*(?:[^\W\d][\w-]*\s+)?([0-9][0-9a-zA-Z.]*[0-9a-zA-Z])", offen_nf or "")
        if nf_nr and nf_nr.group(1) in ausschluss:  # 375 (Ford 27.10., 10:05): --ohne gilt auch für den Nachfolger
            ausgabe.append("NICHTS %s: Nachfolger „%s“ ausgeschlossen (--ohne %s); Zeilenregel gilt" % (r, offen_nf, nf_nr.group(1)))
            offen_nf = None
        elif nf_nr and nf_nr.group(1) in GESPERRT.get(r, {}):
            warnen(ausgabe, neue_warnungen, bekannt, r, nf_zeit, "Nachfolger „%s“ nicht startbar (%s), oberste startbare Zeile statt dessen; Übergabe anpassen" % (offen_nf, GESPERRT[r][nf_nr.group(1)]))
            offen_nf = None
        elif nf_nr and (eig := fremd_besitzer(r, nf_nr.group(1), muss)):
            # 1662 (Ford 18.11., 13:06): Nachfolger auf einer Zeile, die inzwischen einem anderen gehört (1595 an Spike), startete die alte Rolle
            warnen(ausgabe, neue_warnungen, bekannt, r, nf_zeit, "Nachfolger „%s“ gehört inzwischen %s, oberste startbare Zeile statt dessen; Übergabe anpassen" % (offen_nf, eig))
            offen_nf = None
        if offen_nf and nf_nr and nacht_halt(r, nf_nr.group(1), ausgabe, morgen):
            continue
        if offen_nf and bremse:  # 1804: Nachfolger wie seine Zeile (ohne Zeile Muss)
            nz = next((x for x in muss + kuer if nf_nr and x[0] == nf_nr.group(1)), None)
            if (g := bremse.erlaubt(r, nz[1] if nz else "M", nz[3] if nz else None)):
                ausgabe.append("NICHTS %s: Nachfolger „%s“ angehalten: %s" % (r, offen_nf, g)); continue
            bremse.zaehle(r, nz[3] if nz else None)
        if offen_nf:
            thema = re.sub(r"\s*\([^)]*\)\s*$", "", offen_nf)
            titel = "%s (%s)" % (thema, berlin(JETZT))
            mo, satz, hoch = modell(r, nf_nr.group(1) if nf_nr else None, offen_nf)
            msg = "%s\n\nNachfolger laut Übergabe in %s: %s. Zuerst Start nach deiner Rollendatei, dann die Übergabe lesen und dort weiterarbeiten; steht dort „Letzte Antwort:“, nennt die Startmeldung sie (859).%s" % (r, VORRAT[r], offen_nf, satz)
            ausgabe.append("START %s | %s%s | %s | %s | %s | %s | %s" % (r, mo, aufwand(hoch), umgebung(r, hoch), REPO, REVISION, titel, msg.replace("\n", "\\n")))
            vorgaenger(r); sperren.append(r); sperr_nr[r] = nf_nr.group(1) if nf_nr else None; continue
        if pause:
            ausgabe.append("NICHTS %s: Pause bis %s" % (r, pause)); continue
        muss = [x for x in muss if x[0] not in ausschluss]; kuer = [x for x in kuer if x[0] not in ausschluss]
        if ist_scharf():  # 1739 (7.1): kein Start ohne Feld „Zurück“ (gültiger Auftrag in docs/vorgang/<Nr>.md)
            ohne_a = [(x[0], g) for x in muss + kuer if (g := auftrag_fehlt(x[0]))]
            if ohne_a:
                weg = {n for n, _ in ohne_a}
                muss = [x for x in muss if x[0] not in weg]; kuer = [x for x in kuer if x[0] not in weg]
                ausgabe.append("NICHTS %s: ohne gültigen Auftrag nicht gestartet (7.1, `vorgang.py auftrag <Nr>`): %s" % (r, "; ".join("%s %s" % x for x in ohne_a[:5])))
        if bremse:  # 1804
            gr = {x[0]: g for x in muss + kuer if (g := bremse.erlaubt(r, x[1], x[3]))}
            muss = [x for x in muss if x[0] not in gr]; kuer = [x for x in kuer if x[0] not in gr]
            if gr and not muss and not (kuer and r in MIT_KUER and not nur_muss):
                ausgabe.append("NICHTS %s: %s" % (r, next(iter(gr.values())))); continue
        wahl = (muss[0] if muss else None) or (kuer[0] if kuer and r in MIT_KUER and not nur_muss else None)
        if bremse and wahl: bremse.zaehle(r, wahl[3])
        if not wahl: ausgabe.append("NICHTS %s: %s" % (r, "kein startbares Muss" if r not in MIT_KUER else "nichts Startbares")); continue
        nr, kl, thema, _ = wahl
        thema = re.sub(r"\*\*|`", "", thema)
        zaehl_nr = sperr_nummer(nr, wahl[3])  # 1896 (D338.2): Zeile „Auftrag“ zählt unter der Nummer, für die der Auftrag ist
        if nacht_halt(r, zaehl_nr, ausgabe, morgen): continue
        # 261.5 (3): neue Arbeit in der alten Sitzung weiter, wenn sie unter WEITER_TOKEN Token liegt und unter 60 Minuten ruht
        mo, satz, hoch = modell(r, nr)
        alte = [] if hoch or mo == startbar.STARK_MODELL or nr == "Auftrag" else [s for s in je_rolle.get(r, []) if not s["_info"][1] and s["_info"][2] < WEITER_MIN and s["id"] not in archiviert and not s.get("_frage_alt")
                and (s.get("context_usage", {}).get("used_tokens") or s.get("external_metadata", {}).get("context_usage", {}).get("used_tokens") or 10**9) < WEITER_TOKEN]
        if alte:
            s = max(alte, key=lambda x: z(x["updated_at"]))
            ausgabe.append("WEITER %s | %s | %s | Weiter: %s (%s) aus der Vorgangsliste (vorgang.py --rolle %s); wird send_message abgelehnt, stattdessen START" % (s["id"], r, nr, nr, "Muss" if kl == "M" else "nach dem Meilenstein" if kl == "N" else "Kür", r))
            sperren.append(r); continue
        titel = start_titel("%s – %s" % (r, nr), nr)  # 1960
        fuer = wahl[3].get("fuer") if isinstance(wahl[3], dict) else None
        msg = "%s\n\nArbeite Vorgang %s (%s) aus der Vorgangsliste (`python3 tools/vorgang.py --rolle %s`, Einzelheiten `vorgang.py %s`)%s; zuerst Start nach deiner Rollendatei, dann den Vorgang lesen und %s." % (
            r, nr, "Muss" if kl == "M" else "nach dem Meilenstein" if kl == "N" else "Kür", r, nr,
            (", Zeile von %s, die auf dich wartet; fertig: `vorgang.py warte %s –` oder das Feld kürzen" % (fuer, nr)) if fuer else "", vorrat_hinweis(r, nr))
        if nr == "Auftrag":  # 1893 (Sokrates 22.11., 08:33): frisch je Auftrag, nie WEITER
            fn = wahl[3].get("auftrag_fuer")
            titel = start_titel("%s – Auftrag %s" % (r, fn), fn)  # 1960
            msg = "%s\n\n%s; zuerst Start nach deinem Ladetext, dann %s, den Auftrag schreiben, pushen und enden." % (r, thema, vorrat_hinweis(r, fn))
        msg += satz
        ausgabe.append("START %s | %s%s | %s | %s | %s | %s | %s" % (r, mo, aufwand(hoch), umgebung(r, hoch), REPO, REVISION, titel, msg.replace("\n", "\\n")))
        vorgaenger(r); sperren.append(r); sperr_nr[r] = zaehl_nr
    zweiter_planer(ausgabe, st, je_rolle, archiviert, ausschluss, bremse, sperren, sperr_nr, morgen)  # 1932
    # 433 Zusatzentwickler fällt (1871 Stilllegung C; Disponent teilt jeden Auftrag zu, G:128, G:130).
    vorentscheid_marken = []
    try:
        import abgleich
        # 191: Notizen gegeneinander, nur WARNUNG; Vorentscheid-Warnungen (194.1, D33.2) einmal, beim zweiten Lauf WARNUNG-LAUT (Marke im Protokoll)
        bisher = lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md"))
        # 1100 A (5), Chefwort 13.11., 09:29: Warnzeilen „gebaut“/„zu testen“ ohne Build einmal am Tag ganz (erster Lauf ab 8 Uhr, Marke im Protokoll), sonst eine Zeile mit der Zahl
        zeilen_ab = abgleich.pruefen()
        ohne_build = [l for l in zeilen_ab if re.search(r"„(gebaut|zu testen)“ ohne Build", l)]
        ganz_marke = "Abgleich ganz %s" % JETZT.strftime("%d.%m.")
        ganz = bool(ohne_build) and JETZT.hour >= 8 and ("Marke " + ganz_marke) not in bisher
        if ganz: vorentscheid_marken.append(ganz_marke)
        elif ohne_build:
            ausgabe.append("WARNUNG Abgleich: %d Zeilen „gebaut“ oder „zu testen“ ohne Build (ganz einmal am Tag ab 8 Uhr; python3 tools/abgleich.py zeigt sie; 1100 A)" % len(ohne_build))
        for l in zeilen_ab:
            if l in ohne_build and not ganz: continue
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
        if not muss or any(l.startswith(("START %s " % r, "NICHTS %s: belegt" % r, "NICHTS %s: Pause" % r, "NICHTS %s: Startmarke" % r, "NICHTS %s: Nachfolger" % r, "NICHTS %s: ohne gültigen Auftrag" % r)) or (l.startswith("WEITER ") and " | %s | " % r in l) for l in ausgabe): continue
        ausgabe.append("STILLSTAND %s: Muss %s ohne Sitzung, Protokollzeile „Stillstand %s seit %s“" % (r, muss[0][0], r, JETZT.strftime("%H:%M")))
    if M_FRAGEN:  # 1871 Stilllegung C (g): Klasse setzt der Disponent (Profil Disponent „Klasse setzen statt M?“), keine Sitzung dafür
        ausgabe.append("KLASSE %s: Muss oder Kür setzen, je Vorgang ein Satz Grund (vorgang.py klasse), nicht starten" % ", ".join(M_FRAGEN))
    # 192.2, Schritt 9: alle Vorräte leer (Muss, Kür, „nach dem Meilenstein“) → Ford meldet einmal am Tag „Vorrat leer“
    if st and all(not st[r][0] and not st[r][1] for r in st if r != "Sokrates"):
        ausgabe.append("VORRAT-LEER: kein startbares Muss, keine Kür, nichts „nach dem Meilenstein“; Ford meldet einmal am Tag „Vorrat leer“")
    # 192.2, Schritt 11: Wochenstart (Mo ab 8 Uhr) und Tagesbericht (247.1), je einmal laut Marke im Protokoll
    heute = JETZT.strftime("%d.%m.")
    # Tagesbericht gilt auch ohne Marke als erledigt, wenn sein Kopf schon steht (22.10.: um 08:10 geschrieben, 19:04 erneut verlangt);
    # ab 24.10. ist es der Stand zum Marktstart (338.1, 341): erledigt, wenn „**Stand <heute>, “ in PROJEKTPLAN.md steht
    marke_text = lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")) + "".join(
        "\nTagesbericht %s" % heute for z in lesen(os.path.join(DOCS, "ARBEIT-TAGESBERICHT.md")).splitlines()
        if z.startswith("## ") and (", %s " % heute) in z) + (
        "\nTagesbericht %s" % heute if ("**Stand %s, " % heute) in lesen(os.path.join(DOCS, "ARBEIT-TAGESBERICHT.md")) else "")  # 448: Kopf von tools/tagesbericht.py
    bericht_da = ("**Stand %s, " % heute) in lesen(os.path.join(DOCS, "ARBEIT-TAGESBERICHT.md"))
    wochen = []
    def per_start(h, mi):
        return (JETZT.hour, JETZT.minute) >= (h, mi)
    tb_scharf = ist_scharf()  # 1871: mit tools/1727-SCHARF Routine „Tagesbericht“ statt Perikles
    tb_rolle = "Tagesbericht" if tb_scharf else "Perikles"
    per_belegt = any(s["_info"][1] or s["_info"][2] < SPERRE_MIN for s in je_rolle.get(tb_rolle, []))
    def tb_zeile(zusatz=""):
        if not tb_scharf:
            return "TAGESBERICHT %s | Perikles%s | Perikles – 448: Tagesbericht %s | Perikles Tagesbericht (448)%s" % (heute, aufwand(), heute, zusatz)
        zl, warn = tagesbericht_start(heute, zusatz)
        if zl and "Tagesbericht" not in sperren: sperren.append("Tagesbericht"); sperr_nr["Tagesbericht"] = "448"
        return zl or warn
    def einmal(marke, zeile, tb=False):
        if marke in marke_text: return
        if per_belegt and (tb or "| Perikles |" in zeile):
            ausgabe.append("NICHTS %s: %s wartet, %s läuft (149a)" % (tb_rolle, marke, tb_rolle)); return
        ausgabe.append(zeile() if callable(zeile) else zeile); wochen.append(marke)
    # 247.1: Tagesbericht täglich ab 7:30 (Sa, So 9:30), ersetzt Morgenbericht und Tagesrückblick (90)
    if per_start(*((9, 30) if JETZT.weekday() >= 5 else (7, 30))):
        einmal("Tagesbericht %s" % heute, tb_zeile, tb=True)
    # 927 (D162.1): Anlässe, die Ford sonst nur unter „Bei Anlass“ fände, als Ausgabezeile
    if per_start(8, 0):  # Schritt 8 Nachhalten, im ersten Lauf ab 8 Uhr
        einmal("Nachhalten %s" % heute, "NACHHALTEN %s: LISTE-BETRIEB.md Schritt 8 (Zeilen „von …“, Freigaben)" % heute)
    vorraete = {r: lesen(os.path.join(DOCS, f)) for r, f in VORRAT.items() if os.path.exists(os.path.join(DOCS, f))}
    for marke, text in neu_fuer_chef(lesen(os.path.join(DOCS, "ARBEIT-BETRIEB.md")), vorraete):
        einmal(marke, "%s %s (Schritt 9, 927)" % (laut_nachts(), text))
    # 1334 (Chef 15.11., 21:09): derselbe Test zweimal rot binnen 48 h oder Wackeltest → Ford legt den Vorgang beim Besitzer an
    try:
        rb = subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)), "rotbuch.py")], capture_output=True, text=True, timeout=150).stdout
        for rz in rb.splitlines():  # 1343: nie „z“, das überdeckte in main() die Funktion z()
            if rz.startswith("NEU "): ausgabe.append("ROTBUCH %s (1334: `python3 tools/rotbuch.py --anlegen`, dann pushen)" % rz[4:].split(" → ")[0])
    except (OSError, subprocess.SubprocessError):
        pass
    # 448 (Chef 01.11., 11:09): fehlt der Bericht um 10 Uhr (Sa, So 12 Uhr), meldet Ford dem Chef laut eine Zeile und startet Perikles erneut
    if per_start(*((12, 0) if JETZT.weekday() >= 5 else (10, 0))) and not bericht_da and "Tagesbericht fehlt %s" % heute not in marke_text:
        wie = ("%s läuft noch, Disponent erinnert ihn" if per_belegt else "%s neu gestartet") % tb_rolle  # D55.5: kein „neu gestartet“ ohne Start
        ausgabe.append("TAGESBERICHT-FEHLT %s: Tagesbericht um %s nicht da; Disponent meldet laut „448: Tagesbericht fehlt, %s“" % (heute, JETZT.strftime("%H:%M"), wie))
        wochen.append("Tagesbericht fehlt %s" % heute)
        if "Tagesbericht %s" % heute in marke_text and not per_belegt:  # sonst startet ihn die Zeile oben schon
            ausgabe.append(tb_zeile(", fehlte um 10 Uhr (Sa, So 12 Uhr)" if not tb_scharf else " Fehlte um 10 Uhr (Sa, So 12 Uhr)."))
    # Wochenziel und Wochenzählung (früher WOCHENSTART) sind seit 719 Vorgänge aus startbar.WOCHENTERMINE, angelegt oben vor dem Plan
    # 194.2: Datei eines anderen in der Chefsache ohne „Stellungnahme Sokrates“ → Sokrates starten, höchstens zweimal am Tag (Marke im Protokoll)
    d = os.path.join(DOCS, "chefsache", "entscheiden"); ohne = []
    for n in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        txt = lesen(os.path.join(d, n)); zl = [x for x in txt.splitlines() if x.strip()]
        if len(zl) > 1 and not zl[1].startswith("Sokrates") and "Stellungnahme Sokrates" not in txt: ohne.append(n)
    if ohne:
        heute_n = marke_text.count("Marke Stellungnahme Sokrates %s" % heute)
        tok = lambda s: s.get("context_usage", {}).get("used_tokens") or s.get("external_metadata", {}).get("context_usage", {}).get("used_tokens") or 10**9
        so_laeuft = [s for s in je_rolle.get("Sokrates", []) if s["id"] not in archiviert and (s["_info"][1] or s["_info"][2] < SPERRE_MIN)]
        if heute_n >= 2:
            ausgabe.append("NICHTS Sokrates: Stellungnahme zu %s wartet, heute schon zweimal gestartet (194.2)" % ", ".join(ohne[:3]))
        else:
            msg = "Sokrates\n\nStellungnahme (194.2): in der Chefsache liegen Dateien ohne „Stellungnahme Sokrates“: %s. Schreibe in jede das stärkste Gegenargument, Widerspruch zu Entschiedenem, Kosten und die Empfehlung in einem Satz, überschreibe nichts; zuerst Start nach deiner Rollendatei." % ", ".join(ohne)
            # 261.6: Stellungnahme per WEITER in die bestehende Sokrates-Sitzung statt einer zweiten daneben (Bedingungen wie 261.5 (3))
            # 921 (Ford 11.11., 11:07): läuft Sokrates (auch offener Weckruf, --wecker) oder ruht unter 20 Minuten, geht die Stellungnahme per WEITER in diese Sitzung,
            # nie START daneben (sonst zwei Sokrates, eine davon archiviert); über WEITER_TOKEN wartet sie
            alte = [s for s in so_laeuft if tok(s) < WEITER_TOKEN] if so_laeuft else [s for s in je_rolle.get("Sokrates", []) if s["id"] not in archiviert and s["_info"][2] < WEITER_MIN and not s.get("_frage_alt") and tok(s) < WEITER_TOKEN]
            if alte:
                ausgabe.append("WEITER %s | Sokrates | Stellungnahme | %s; wird send_message abgelehnt, stattdessen START wie sonst" % (juengste(alte)["id"], msg.split("\n\n", 1)[1]))
            elif so_laeuft:
                ausgabe.append("NICHTS Sokrates: Stellungnahme zu %s wartet, Sokrates läuft (Token über %d Tsd. oder unbekannt)" % (", ".join(ohne[:3]), WEITER_TOKEN // 1000)); msg = None
            else:
                zeile, so_nr = stellungnahme_start(ohne, msg)
                ausgabe.append(zeile)
                vorgaenger("Sokrates")  # 261.5 (2): die ruhende alte Sitzung gleich danach archivieren, nicht zwei Sokrates nebeneinander
                # 1891 (D336.1): Startsperre auch ohne offene Zeilen (vorher nur vorgaenger, der Startsperre-Haken hielt den Start an)
                if "Sokrates" not in sperren: sperren.append("Sokrates")
                sperr_nr["Sokrates"] = so_nr
            if msg: wochen.append("Stellungnahme Sokrates %s" % heute)
    def _so_sperre(nr):  # 1801
        if "Sokrates" not in sperren: sperren.append("Sokrates")
        sperr_nr["Sokrates"] = nr
    if sperre: fristen_runde(ausgabe, seiten)  # 1739 Befund 1: abgelaufene Fristen je Lauf; 1782: vor Sokrates, damit „steckt fest“ im selben Lauf ankommt
    sokrates_zeilen(ausgabe, je_rolle, archiviert, vorgaenger, sperre=_so_sperre)  # 1763 C
    for rt in ("Rundblick", "Ideenlauf"):  # 1907: Ideenlauf wie Rundblick
        try:
            if (rb := rundblick_zeilen(ausgabe, je_rolle, archiviert, marken, name=rt)): sperren.append(rt); sperr_nr[rt] = rb
        except Exception as e: ausgabe.append("WARNUNG %s nicht geprüft: %s (1789, Spike)" % (rt, e))
    def ue_start(r, nr, teil):  # 1739 Befund 1: Empfänger ohne Sitzung starten
        if r not in START_REIHE or r in ohne_rollen or lauf_laeuft(r): return False
        i = next((j for j, l in enumerate(ausgabe) if l.startswith("START %s |" % r)), None)
        if i is not None: ausgabe[i] += "\\n\\n" + teil; return True
        if r in marken and (JETZT - marken[r]).total_seconds() < SPERRE_MIN * 60:
            ausgabe.append("NICHTS %s: Start unterwegs (Startsperre %s), offene Zeilen gehen im nächsten Lauf per NACHRICHT (1739)" % (r, marken[r].strftime("%H:%M"))); return True
        if nacht_halt(r, nr, ausgabe, morgen): return True
        if bremse:  # 2001: auch der Start für offene Übergabezeilen hält Guthaben und Laufsperre ein (vorher an der Bremse vorbei)
            zl_ = startbar_zeile(nr)
            if (g := bremse.erlaubt(r, (zl_ or {}).get("kl", "M"), zl_)):
                ausgabe.append("NICHTS %s: offene Übergabe %s angehalten: %s" % (r, nr, g)); return True
            bremse.zaehle(r, zl_)
        mo, satz, hoch = modell(r, nr)
        msg = "%s\n\n%s Zuerst Start nach deiner Rollendatei.%s" % (r, teil, satz)
        ausgabe.append("START %s | %s%s | %s | %s | %s | %s | %s" % (r, mo, aufwand(hoch), umgebung(r, hoch), REPO, REVISION,
                       "%s – %s: offene Übergabe (%s)" % (r, nr, berlin(JETZT)), msg.replace("\n", "\\n")))
        vorgaenger(r); sperren.append(r); sperr_nr[r] = nr
        return True
    uebergabe_zeilen(ausgabe, je_rolle, archiviert, start=ue_start)  # 1739, F4 (1)
    try: hoechstdauer_zeilen(ausgabe, je_rolle, archiviert)  # 1766
    except Exception as e: ausgabe.append("WARNUNG Höchstdauer nicht geprüft: %s (1766, Spike)" % e)
    try:  # 383: Wartewächter
        ww, wm = waechter(je_rolle, marke_text); ausgabe += ww; wochen += wm
    except Exception as e:
        ausgabe.append("WARNUNG Wartewächter fehlgeschlagen: %s (383, Perikles)" % e)
    try:  # 559: „wartet auf Chef“, obwohl eine neuere Rückmeldung des Chefs da ist (regelcheck.py --rueckmeldung); einmal je Rückmeldung
        r = subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)), "regelcheck.py"), "--rueckmeldung"],
                           capture_output=True, text=True, timeout=120)
        for l in r.stdout.splitlines():
            if not l.startswith("RÜCKMELDUNG "): continue
            nr, rollen, zeit, text = [x.strip() for x in l[len("RÜCKMELDUNG "):].split(" | ", 3)]
            marke = "Rückmeldung %s %s" % (nr, zeit)
            if marke in marke_text: continue
            sitz = [s for rl in rollen.split(", ") for s in je_rolle.get(rl, [])]
            ausgabe.append("WÄCHTER %s | %s | %s | %s; %s und Ford: Stand setzen, damit die Zeile startet" % (nr, rollen, juengste(sitz)["id"] if sitz else "-", text, rollen))
            wochen.append(marke)
        if r.returncode: ausgabe.append("WARNUNG regelcheck.py --rueckmeldung Exit %d: %s (559, Perikles)" % (r.returncode, r.stderr.strip()[-200:]))
    except Exception as e:
        ausgabe.append("WARNUNG Rückmeldungswächter fehlgeschlagen: %s (559, Perikles)" % e)
    wochen += vorentscheid_marken + neue_marken
    try:  # 1228 (Chef 13.11., 21:22: „jeder, der sieht, das erledigt“): offene Urteile auf Telegram, Netz für Sitzungen, die notiz.sh nicht rufen
        import reaktionen
        reaktionen.main(["--still"])
        ausgabe += ["URTEIL " + u for u in reaktionen.offene_urteile()]
    except Exception as e:
        ausgabe.append("WARNUNG Telegram-Urteile nicht gelesen: %s (1228, Perikles)" % str(e)[:120])
    # 942 (D171.2): eine hängende Sitzung, die derselbe Lauf archiviert (auch als Vorgänger beim START), meldet nicht „Sitzung hängt“
    haengt_weg = lambda l: " Sitzung hängt: " in l and any(l.endswith("code/%s (927)" % a) for a in archiviert)
    ausgabe = [l for l in ausgabe if not haengt_weg(l)]
    if ist_scharf():  # 1799: Wächter der Fristen nach Grobablauf 14.2, erst nach der Umschaltung
        try:
            import liegt as _liegt
            ausgabe += _liegt.liegt(JETZT, True)
        except Exception as e: ausgabe.append("WARNUNG LIEGT nicht geprüft: %s (1799)" % str(e)[:120])
    # 1472: Chefwort zum Kaufrepo an jede Startnachricht (START: letztes Feld), bei WEITER vor dem Hinweis auf send_message
    ausgabe = [mit_kaufrepo(l) for l in ausgabe]
    ausgabe = [mit_kern(l) for l in ausgabe]
    ausgabe += ["WARNUNG Startblock: %s ohne docs/profile/%s.md, Teil fehlt in der Startnachricht (1923)" % x for x in STARTBLOCK_FEHLT]
    rufnamen = {}  # 1957: Rolle → Rufnamen der STARTs, für die Startsperre
    if ist_scharf(): ausgabe = mit_rufnamen(ausgabe, alle.values(), namen=rufnamen)
    try:  # 1688 (Chef 23.11., 08:39): offene „streichen:“-Übergaben an den Disponenten als erste Zeilen, Pflicht vor jedem Start
        import streichen
        ausgabe = streichen.zuerst(streichen.lauf_zeilen(DOCS) + ausgabe)
    except Exception as e:
        ausgabe.insert(0, "WARNUNG Streichzeilen nicht gelesen: %s (1688)" % str(e)[:120])
    ausgabe = vorn(leitung_neustart(je_rolle, archiviert) + ausgabe)  # 1988: im selben Takt wie STREICHEN
    ausgabe = warnung_einmal_je_stunde(ausgabe)  # 1988 (Zusatz Chef 09:26): gleiche Warnung höchstens einmal je Stunde
    for l in ausgabe: print(l)
    if not ausgabe: print("NICHTS: nichts zu tun")
    if sperre:  # 1999 (d): gescheiterter Start/Neustart wird eine rohe Zeile im Lehrenbuch (je Tag und Rolle einmal)
        try:
            import lehren
            lehren.aus_lauf(ausgabe)
        except Exception as e: print("WARNUNG Lehrenbuch Betrieb nicht geschrieben: %s (1999)" % str(e)[:120])
    scharf_push = ist_scharf() and bool(sperren)  # 1892 (Lauf 3 Disponent L1): scharf setzt lauf.py die Startsperre bei START selbst und pusht
    if (sperre or scharf_push) and (sperren or neue_warnungen or wochen or morgen):
        def anhaengen(t):
            t = t.rstrip("\n")
            if sperren:  # 1643: mit Vorgang, damit nachtstarts.py die Neustarts je Vorgang zählt
                t += "\n" + startsperre_zeile(sperren, sperr_nr, rufnamen=rufnamen) + "\n"
            if sperre:  # Marken und Warnungen weiter nur mit --sperre
                for m in morgen:
                    if m not in t: t += "\n- %s %s: %s (lauf.py)\n" % (JETZT.strftime("%H:%M"), JETZT.strftime("%d.%m."), m)
                for m in wochen: t += "\n- %s %s: Marke %s (lauf.py)\n" % (JETZT.strftime("%H:%M"), heute, m)
                for w in neue_warnungen: t += "\n- %s %s: %s (lauf.py)\n" % (JETZT.strftime("%H:%M"), JETZT.strftime("%d.%m."), w)
            return t
        p = os.path.join(DOCS, "ARBEIT-BETRIEB.md")
        if scharf_push and protokoll_pushen(anhaengen, "Betrieb: Startsperre %s (lauf.py, 1892)" % ", ".join(sperren)):
            print("STARTSPERRE gepusht (1892): %s; create_session jetzt erlaubt; vor dem nächsten eigenen Commit `git pull --rebase`" % ", ".join(sperren))
        else:
            if scharf_push: print("STARTSPERRE NICHT GEPUSHT (1892): lokal geschrieben, selbst committen und pushen, erst dann create_session")
            protokoll_lokal(p, anhaengen)
            print("Protokoll geschrieben: bitte committen und pushen%s." % (", erst dann create_session" if sperren else ""))
    if sperre:
        for nr in STARK_GESTARTET:  # 827 A, Bau 828: Marke „stärkstes Modell TT.MM.“ am Titel; zählt Sokrates für die Auswertung nach drei
            d = next((x for x in startbar.zeilen_liste() if x["nr"] == nr), None)
            if d: subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)), "vorgang.py"), "setze", nr,
                                  "titel=%s · stärkstes Modell %s" % (d["titel"].rstrip(), JETZT.strftime("%d.%m."))], capture_output=True, text=True)
        if STARK_GESTARTET: print("Stärkstes Modell (827 A): %s, Marke am Titel (Notizen pushen)" % ", ".join(STARK_GESTARTET))
        for nr, wer, weg, neu_st in startbar.loesen(True):  # 275.2 Automatik A: erfüllte „wartet auf“ schreiben (Ford pusht)
            # D80.4: „Meldung an den Besitzer“: läuft eine Sitzung der Rolle, ihre Kennung (Ford: send_message); sonst startet lauf.py sie wie jede startbare Zeile
            sitz = [x for x in je_rolle.get(wer, []) if x["id"] not in archiviert]
            # Ford 18.11., 12:06 (1567 „zu testen“, 1622 „gebaut“): bleibt die Zeile nach dem Leeren gesperrt, keine Meldung „startbar“
            d_neu = next((x for x in startbar.zeilen_liste() if x["nr"] == nr), None)
            grund = startbar.sperre(d_neu) if d_neu else None
            if grund:
                print("GELÖST %s | %s | wartet auf %s erfüllt, bleibt gesperrt (%s) | - (Notizen pushen, keine Meldung)" % (nr, wer, ", ".join(weg), grund))
                continue
            print("GELÖST %s | %s | wartet auf %s erfüllt%s | %s (Notizen pushen)" % (nr, wer, ", ".join(weg), (" → " + neu_st) if neu_st else "",
                                                                                   ("an " + juengste(sitz)["id"]) if sitz else "-"))
        n = aufraeumen()
        if n: print("Aufgeräumt: %d Zeilen aus Protokoll und LISTE-VORGAENGE.md (270; Notizen pushen)" % n)
    # 1100 A (6), Chef 13.11., 09:29: nichts zu starten, nichts zu melden und nichts zu pushen → Ford endet nach diesem Schritt (kein Telegram, kein Push)
    zahl_zeile = lambda l: l.startswith("WARNUNG Abgleich: ") and "ohne Build (ganz einmal am Tag" in l
    if all(l.startswith("NICHTS") or zahl_zeile(l) for l in ausgabe) and not geaendert() and not NOTIZ_WARNUNG:
        print("LEERLAUF: nichts zu starten, nichts zu melden, nichts zu pushen; Ford endet hier mit der Chatzeile „Ford HH:MM ok“ (1100 A 6)")
    # 1997: zuletzt, ohne Schalter (auch --besetzung hat keine eigene Wirkung mehr): Absturz vorher = alte Marke = ALARM
    herzschlag_pushen([s for s in leb if s["id"] not in archiviert])

def geaendert():
    """1100 A (6): hat dieser Lauf Notizen geschrieben (Protokoll, Besetzung, Vorgangsliste)? Dann ist er nicht leer, Ford pusht."""
    try:
        r = subprocess.run(["git", "-C", os.path.join(DOCS, ".."), "status", "--porcelain", "--", "docs"], capture_output=True, text=True, timeout=20)
        return bool(r.stdout.strip()) or r.returncode != 0
    except Exception:
        return True

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
    for d in startbar.zeilen_liste():  # 275.2: „jetzt“ steht im Titel oder Stand der Listenzeile
            nr, kl, rolle = d["nr"], d["kl"], d["besitzer"]
            if kl in ("–", "-") or d["wort"] in ("ruht", "erledigt"): continue
            if d["wort"] in ("gebaut", "zu testen") or d["warte"]: continue  # 902: der Ball liegt anderswo (Test, Prüfung, anderer Vorgang, Chef); 870.6 und 900 gingen 11.11., 07:24 laut an den Chef
            zeile = d["titel"] + " | " + d["stand"]
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

OHNE_ARBEIT_H = 2  # 1129.1 P1: „in Arbeit“ ohne Sitzung, die den Vorgang im Titel trägt und in dieser Zeit tätig war

def ohne_ueberholt(ausschluss, leb):
    """1129.1 P1 (13.11.: 8 von 12 Ausschlüssen überholt, 882.1 „Tom in Arbeit“ 13 h ohne Sitzung, 40 Muss hingen daran):
    meldet je --ohne, das nicht mehr gilt, eine Zeile OHNE-ÜBERHOLT. Sonderzeilen (M?, Pflege) bleiben unbewertet."""
    offen = {d["nr"]: d for d in startbar.zeilen_liste() if d["wort"] != "erledigt"}
    aus = []
    for nr, grund in sorted(ausschluss.items()):
        if not re.fullmatch(r"[A-Za-z]?\d+[a-z]?(?:\.\d+[a-z]?)*", nr): continue
        d = offen.get(nr)
        if d is None: aus.append("OHNE-ÜBERHOLT %s: nicht mehr offen (Archiv oder erledigt)" % nr); continue
        if d["wort"] == "ruht": aus.append("OHNE-ÜBERHOLT %s: ruht, startet ohnehin nicht" % nr); continue
        if "in Arbeit" in grund:
            # 1134 (D198.1): alle Nummern im Titel; tätig auch, wer gerade läuft (updated_at bleibt im langen Zug stehen)
            tätig = [s for s in leb if nr in nummern_aus_titel(s.get("title", "")).split(",")
                     and ((JETZT - z(s["updated_at"])).total_seconds() < OHNE_ARBEIT_H * 3600
                          or s.get("session_status") == "SESSION_STATUS_RUNNING"
                          or any(w in s.get("status_bucket", "") for w in ("WORKING", "BLOCKED")))]
            if not tätig: aus.append("OHNE-ÜBERHOLT %s: „in Arbeit“, aber keine Sitzung mit %s im Titel seit %d h" % (nr, nr, OHNE_ARBEIT_H))
    return aus

def besetzung_text(t, leb):
    """Tabelle aus leb und Zeitmarke „**Stand:** … (lauf.py)“ in den Text t von ARBEIT-BESETZUNG.md; 1997: Zeitmarke immer neu."""
    zeilen = ["| Rolle | Sitzung | Vorgang | Zweig | seit |", "|---|---|---|---|---|"]
    try: vz = {d["nr"]: d.get("zweig", "–") for d in startbar.vorgangsliste(lesen(os.path.join(DOCS, "LISTE-VORGAENGE.md")))}  # 1407: Zweig aus der Vorgangszeile
    except Exception: vz = {}
    for s in sorted(leb, key=lambda x: x["created_at"]):
        r, laufend, ruhig, hinder = s["_info"]
        titel = s.get("title", s["id"])
        if r == "Sonstige" and not titel.startswith("Ford"): continue
        zl = nummer_aus_titel(titel) or "Betrieb"
        zw = ((s.get("external_metadata") or {}).get("current_branches") or {}).get("") or vz.get(zl) or "–"
        zeilen.append("| %s | [%s](https://claude.ai/code/%s) | %s | %s | %s |" % (r, titel, s["id"], zl, zw, berlin(z(s["created_at"]))))
    tabelle = "\n".join(zeilen)
    neu = re.sub(r"\| Rolle \| Sitzung.*?(?=\n\n|\Z)", lambda m: tabelle, t, count=1, flags=re.S)
    stand = "**Stand:** %s (lauf.py)" % berlin(JETZT)
    if "**Stand:**" in neu: return re.sub(r"\*\*Stand:\*\*[^\n]*", lambda m: stand, neu, count=1)
    return neu.rstrip("\n") + "\n\n" + stand + "\n"

def herzschlag_pushen(leb):
    """1997 (Chef 23.11., 13:56): Totmannschalter. Am Ende jedes vollständigen Laufs, ohne Schalter: Tabelle und Zeitmarke von
    ARBEIT-BESETZUNG.md auf origin/main schreiben und pushen (wie protokoll_pushen, ein Commit, lokale Datei bleibt). Stürzt der Lauf
    vorher ab, bleibt die Marke alt und herzschlag.py meldet ALARM. Hat die lokale Datei Ungepushtes oder geht der Push nicht (1918):
    lokal schreiben, der Disponent pusht selbst."""
    pfad = "docs/ARBEIT-BESETZUNG.md"
    _ue = wurzel = None
    try:
        import uebergabe as _ue
        # aus der Arbeitskopie (abgelöster HEAD) liegen die Notizen in ../bornim-main: dort committen und pushen (Test lauf_herzschlag_test.py)
        wurzel = _ue.WURZEL; _ue.WURZEL = os.path.normpath(os.path.join(DOCS, ".."))
        grund = _ue.ungepusht(pfad)
        if grund: raise RuntimeError("lokale ARBEIT-BESETZUNG.md %s (1918)" % grund)
        _ue.atomar_dateien([pfad], lambda alt: ({pfad: besetzung_text(alt[pfad], leb).rstrip("\n") + "\n"}, True),
                           "Herzschlag: Zeitmarke %s (lauf.py, 1997)" % JETZT.strftime("%H:%M"))
        print("HERZSCHLAG gepusht (1997): Zeitmarke %s und Besetzung auf origin/main; vor dem nächsten eigenen Commit `git pull --rebase`" % berlin(JETZT))
        return True
    except Exception as e:
        p = os.path.join(DOCS, "ARBEIT-BESETZUNG.md")
        protokoll_lokal(p, lambda t: besetzung_text(t, leb))
        print("HERZSCHLAG NICHT GEPUSHT (1997): %s; Zeitmarke lokal geschrieben, ARBEIT-BESETZUNG.md jetzt committen und pushen, sonst ALARM nach 2 h" % str(e)[:160])
        return False
    finally:
        if _ue is not None and wurzel is not None: _ue.WURZEL = wurzel

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

def kosten_neu(alt, usd):
    alt = re.sub(r"^[–-]\s*(;\s*\+)?", "", alt)  # 375: „–“ und „–; +N $“ heißen nur N $, Ford las „Kosten …: –“
    m = re.fullmatch(r"([\d,.]+)\s*\$", alt) if alt else None
    if m or not alt:
        return ("%.2f" % ((float(m.group(1).replace(",", ".")) if m else 0.0) + usd)).replace(".", ",") + " $"
    m = re.fullmatch(r"(.*); \+([\d,.]+)\s*\$", alt)  # Nachträge in einem „+N $“ am Ende sammeln statt anhängen (Perikles 24.10.)
    return (m.group(1) if m else alt) + "; +" + ("%.2f" % ((float(m.group(2).replace(",", ".")) if m else 0.0) + usd)).replace(".", ",") + " $"

def _buchen(nr, usd):
    ziel = nr
    while ziel:
      p = os.path.join(DOCS, "LISTE-VORGAENGE.md"); text = lesen(p)  # 275.2: Liste mit Feldern, Spalte „Kosten“ über den Kopf
      for d in startbar.vorgangsliste(text):
          if d["nr"] == ziel:
              L = text.split("\n"); d["kosten"] = kosten_neu(d.get("kosten", ""), usd); L[d["i"]] = startbar.zeile_text(d)
              open(p, "w", encoding="utf-8").write("\n".join(L)); startbar.liste_merken(DOCS)
              print("Kosten %s: +%s $, jetzt %s" % (ziel, ("%.2f" % usd).replace(".", ","), d["kosten"])); return
      for dat in ("LISTE-VORGAENGE-ARCHIV.md",):  # abgeschlossene Zeilen liegen im Archiv (altes Format), Kosten gehören trotzdem dorthin
        p = os.path.join(DOCS, dat); L = lesen(p).split("\n")
        for i, l in enumerate(L):
            t = [x.strip() for x in l.split("|")]
            if l.startswith("| ") and len(t) > 7 and t[1] == ziel:
                alt = re.sub(r"^[–-]\s*(;\s*\+)?", "", t[-4])
                m = re.fullmatch(r"([\d,.]+)\s*\$", alt) if alt else None
                if m or not alt:
                    t[-4] = ("%.2f" % ((float(m.group(1).replace(",", ".")) if m else 0.0) + usd)).replace(".", ",") + " $"
                else:  # Nachträge in einem „+N $“ am Ende sammeln statt anhängen (Größe LISTE-VORGAENGE, Perikles 24.10.)
                    m = re.fullmatch(r"(.*); \+([\d,.]+)\s*\$", alt)
                    t[-4] = (m.group(1) if m else alt) + "; +" + ("%.2f" % ((float(m.group(2).replace(",", ".")) if m else 0.0) + usd)).replace(".", ",") + " $"
                L[i] = "| " + " | ".join(t[1:-1]) + " |"
                open(p, "w", encoding="utf-8").write("\n".join(L))
                if p.endswith("LISTE-VORGAENGE.md"): startbar.liste_merken(DOCS)  # 275 Stufe 2
                print("Kosten %s: +%s $, jetzt %s" % (ziel, ("%.2f" % usd).replace(".", ","), t[-4])); return
      kurz = re.sub(r"(\.\d+[a-z]*|[a-z])$", "", ziel)
      if kurz == ziel: break
      ziel = kurz
    if nr != "Betrieb" and any(d["nr"] == "Betrieb" for d in startbar.vorgangsliste(lesen(os.path.join(DOCS, "LISTE-VORGAENGE.md")))):
        print("Kosten %s: keine Zeile, auf Betrieb (340.10)" % nr); return _buchen("Betrieb", usd)  # 340.10 V4 (b): feste Zeile statt Handbuchung
    print("WARNUNG Kosten: keine Zeile für %s, bitte von Hand auf Betrieb" % nr)

if __name__ == "__main__":
    main()
