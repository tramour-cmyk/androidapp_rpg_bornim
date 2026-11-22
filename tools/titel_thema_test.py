# 1960 (Chef 22.11., 16:52): START-Titel tragen das Thema aus dem Vorgangstitel, „<Rufname> – <Nr>: <Thema> (TT.MM., HH:MM)“,
# Planer „<Rufname> – Auftrag <Nr>: <Thema> (…)“. Zuordnung (Nummer, Kosten, Rolle, Belegung) mit Thema wie ohne.
# Aufruf: python3 tools/titel_thema_test.py [--alle]   (--alle: Thema jeder offenen Zeile der Vorgangsliste ausgeben)
import datetime, os, re, shutil, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import rufname, kosten, lauf, startbar

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

J = datetime.datetime(2026, 11, 22, 16, 56, tzinfo=lauf.BERLIN)
lauf.JETZT = J
ZEILEN = [
    {"nr": "1960", "titel": "Sitzungstitel ohne Thema: Rufnamen-Sitzungen heißen nur „Dirk – 1957“, „Carla – Auftrag 1675“; Soll wie …", "besitzer": "Werkzeug"},
    {"nr": "1957", "titel": "Von Ford (22.11., 16:23): lauf.py erkennt eigene Rufnamen-Sitzungen nicht (Titel „Anna – Auftrag 1727“)", "besitzer": "Werkzeug"},
    {"nr": "1621", "titel": "Zweihandwaffen kürzer Großaxt 131→110 cm, Kriegshammer 115→100", "besitzer": "Figur"},
    {"nr": "1675", "titel": "Wachsoldatin im Hauptmenü, Schild schwebt neben ihr", "besitzer": "Figur"},
    {"nr": "1566", "titel": "Höhlenwasser leuchtet hinter Wänden im Dunkeln, obwohl nicht in Sicht und ohne Licht", "besitzer": "Welt"},
]
startbar._LISTE = ZEILEN
th = getattr(lauf, "thema", lambda t: "")
st = getattr(lauf, "start_titel", None)
def titel(kopf, nr):  # vor 1960: Titel ohne Thema wie in lauf.py Z. 1550/1557/585
    return st(kopf, nr) if st else "%s (%s)" % (kopf, lauf.berlin(J))

# Kürzung
soll("Thema bis „:“", th(ZEILEN[0]["titel"]) == "Sitzungstitel ohne Thema", th(ZEILEN[0]["titel"]))
soll("Vorspann „Von X (…):“ weg, bis „ (“", th(ZEILEN[1]["titel"]) == "lauf.py erkennt eigene Rufnamen-Sitzungen nicht", th(ZEILEN[1]["titel"]))
soll("höchstens 50 Zeichen am Wortende mit …", th(ZEILEN[4]["titel"]) == "Höhlenwasser leuchtet hinter Wänden im Dunkeln, …", th(ZEILEN[4]["titel"]))
soll("ohne „|“, Zeilenumbruch, „ – “, „Auftrag <Zahl>“", th("Fix | Auftrag 1727 für\nden Lauf – Rest") == "Fix für den Lauf", th("Fix | Auftrag 1727 für\nden Lauf – Rest"))
soll("Zahl im Thema endet davor (sonst Kosten auf Vorgang 131)", th(ZEILEN[2]["titel"]) == "Zweihandwaffen kürzer Großaxt", th(ZEILEN[2]["titel"]))
soll("Markdown weg, unpaariges „ weg", th("**Titel** mit „Zitat: x") == "Titel mit", th("**Titel** mit „Zitat: x"))

# START-Titel (Fachkraft 1550, Planer 1557, zweiter Planer 585) mit Thema, scharf
lauf.ist_scharf = lambda: True
f = titel("Werkzeug – 1960", "1960"); p = titel("Arbeitsplaner – Auftrag 1675", "1675"); p2 = titel("Arbeitsplaner 2 – Auftrag 1621", "1621")
soll("Fachkraft-Titel mit Thema", f == "Werkzeug – 1960: Sitzungstitel ohne Thema (22.11., 16:56)", f)
soll("Planer-Titel mit Thema", p == "Arbeitsplaner – Auftrag 1675: Wachsoldatin im Hauptmenü, Schild schwebt neben ihr (22.11., 16:56)", p)
soll("zweiter Planer mit Thema", p2 == "Arbeitsplaner 2 – Auftrag 1621: Zweihandwaffen kürzer Großaxt (22.11., 16:56)", p2)
soll("Nummer ohne Zeile: Titel ohne Thema", titel("Werkzeug – 9999", "9999") == "Werkzeug – 9999 (22.11., 16:56)", titel("Werkzeug – 9999", "9999"))

# Rufnamen und Zuordnung mit Thema wie ohne
rufname._SPERRE[rufname.DOCS] = set()
aus = lauf.mit_rufnamen(["START Werkzeug | o | e | r | main | %s | Werkzeug" % f, "START Arbeitsplaner | o | e | r | main | %s | Arbeitsplaner" % p,
                         "START Arbeitsplaner | o | e | r | main | %s | Arbeitsplaner" % p2], [], J)
rf, rp, rp2 = [l.split(" | ")[5] for l in aus]
soll("mit_rufnamen: Rufname vor Thema", rf.startswith("Anna – 1960: Sitzungstitel ohne Thema (") and rp.startswith("Britta – Auftrag 1675: Wachsoldatin"), (rf, rp))
alt = {"rf": "Anna – 1960 (22.11., 16:56)", "rp": "Britta – Auftrag 1675 (22.11., 16:56)", "rp2": "Carla – Auftrag 1621 (22.11., 16:56)"}
D = tempfile.mkdtemp(); B = os.path.join(D, "ARBEIT-BETRIEB.md")
open(B, "w", encoding="utf-8").write("# Betrieb\n\n- 16:56 22.11.: Startsperre 16:56 Start Werkzeug, Arbeitsplaner, Arbeitsplaner (lauf.py, Werkzeug 1960 Anna, Arbeitsplaner 1675 Britta, Arbeitsplaner 1621 Carla)\n")
rufname.BETRIEB = B
C = "2026-11-22T15:56:30Z"
for k, neu in (("rf", rf), ("rp", rp), ("rp2", rp2)):
    a = alt[k]
    for fn in (lauf.nummer_aus_titel, lauf.nummern_aus_titel, lauf.auftrag_aus_titel, lambda t: rufname.rolle(t, C),
               lambda t: rufname.bereich(t, ZEILEN), lambda t: kosten.rolle(t, C), lambda t: kosten.rolle(t)):
        soll("%s: gleich mit Thema (%s)" % (k, getattr(fn, "__name__", "")), fn(neu) == fn(a), "%r: %r statt %r" % (neu, fn(neu), fn(a)))
soll("Planer mit Thema zählt als Arbeitsplaner (Kosten)", kosten.rolle(rp, C) == "Arbeitsplaner" and kosten.rolle(rp2, C) == "Arbeitsplaner", (kosten.rolle(rp, C), kosten.rolle(rp2, C)))
soll("Planer mit Thema bucht nur auf seinen Vorgang", lauf.nummern_aus_titel(rp) == "1675" and lauf.nummern_aus_titel(rp2) == "1621", (lauf.nummern_aus_titel(rp), lauf.nummern_aus_titel(rp2)))
lauf.PLANER = "Arbeitsplaner"
leb = [{"title": t, "created_at": C, "updated_at": "2026-11-22T15:56:40Z", "status_bucket": "WORKING"} for t in (rf, rp, rp2)]
soll("Planer mit Thema belegt seinen Auftrag (kein zweiter START)", lauf.planer_in_arbeit(leb) == {"1675", "1621"}, lauf.planer_in_arbeit(leb))
soll("Belegung aus START-Zeile (zweiter_planer liest auftrag_aus_titel)", [lauf.auftrag_aus_titel(l) for l in aus] == [None, "1675", "1621"], [lauf.auftrag_aus_titel(l) for l in aus])
# Ursache Disponent 16:53 (1960 Bisher): ohne Startsperre mit dem Rufnamen fällt kosten.rolle auf den Besitzer der ersten Nummer
open(B, "w", encoding="utf-8").write("# Betrieb\n")
soll("Ursache Doris→Welt: Hand-Titel ohne Startsperre zählt beim Besitzer", kosten.rolle("Doris – 1566: Auftrag schreiben", C) == "Welt", kosten.rolle("Doris – 1566: Auftrag schreiben", C))
shutil.rmtree(D, ignore_errors=True)

# ohne tools/1727-SCHARF unverändert
lauf.ist_scharf = lambda: False
soll("ohne SCHARF Titel wie bisher", titel("Werkzeug – 1960", "1960") == "Werkzeug – 1960 (22.11., 16:56)", titel("Werkzeug – 1960", "1960"))

# alle offenen Zeilen der Vorgangsliste: kein leeres oder verstümmeltes Thema
startbar._LISTE = None
offen = [d for d in startbar.zeilen_liste() if not d["stand"].startswith("erledigt")]
schlecht = []
for d in offen:
    t = th(d["titel"])
    if "--alle" in sys.argv: print("  %-7s %s" % (d["nr"], t))
    if (not t or len(t) > 50 or re.search(r"[|\n]| – |\bAuftrag \d", t) or t.count("„") != t.count("“") or t[-1] in ",;:(–-"
            or lauf.nummern_aus_titel("X – 1: %s (22.11., 16:56)" % t) != "1"):
        schlecht.append((d["nr"], t))
soll("alle %d offenen Zeilen: Thema da und lesbar" % len(offen), offen and not schlecht, schlecht[:10])

print("titel_thema_test: %s" % ("grün" if not fehl else "%d rot" % fehl))
sys.exit(1 if fehl else 0)
