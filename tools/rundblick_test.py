# 1789: Start der Routine Rundblick durch lauf.py (ohne Kern, ohne Rufname, ohne Feld „Zurück“), Ausnahme in auftrag.py,
# „fertig“ ohne Commit in rueckmeldung.py, Rolle Rundblick in kosten.py und startsperre-haken.py. Ohne Netz.
# Aufruf: python3 tools/rundblick_test.py
import datetime, importlib.util, os, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER); sys.argv = [sys.argv[0]]
import lauf, auftrag, kosten, rueckmeldung
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

T = "Wochentermin 23.11.: Rundblick (Routine, Auftrag docs/entwurf/1727-muster/routine-rundblick.md Teil A) (719)"
W = os.path.normpath(os.path.join(HIER, ".."))
# 1 auftrag.py: Routine erkennen, Teil A lesen
soll("Routine erkannt", auftrag.routine(T) == ("docs/entwurf/1727-muster/routine-rundblick.md", "Teil A"), auftrag.routine(T))
soll("kein Routine-Titel", auftrag.routine("Tom – 9001: Zwerg") is None)
d = tempfile.mkdtemp(); os.makedirs(os.path.join(d, "r"))
open(os.path.join(d, "r", "x.md"), "w").write("# x\n\n```markdown\nfalsch\n```\n\n## Teil A: Rundblick\n\n```markdown\n**Rundblick** Ziel.\n```\n")
TD = "Wochentermin 23.11.: Rundblick (Routine, Auftrag r/x.md Teil A) (719)"
soll("Teil A: Block unter der Überschrift", auftrag.routine_text(TD, d) == "**Rundblick** Ziel.", auftrag.routine_text(TD, d))
soll("ohne Teil: erster Block", auftrag.routine_text("W (Routine, Auftrag r/x.md)", d) == "falsch")
soll("Datei fehlt: None", auftrag.routine_text("W (Routine, Auftrag r/y.md Teil A)", d) is None)
soll("echter Teil A lesbar", (auftrag.routine_text(T, W) or "").startswith("**Rundblick** (einmal die Woche)"))

# 2 lauf.py: Ausnahme vom Feld „Zurück“
soll("auftrag_fehlt: Routine ohne Auftrag gilt", lauf.auftrag_fehlt("9050", docs=d, titel=T) is None)
soll("auftrag_fehlt: andere Zeile ohne Auftrag hält an", lauf.auftrag_fehlt("9051", docs=d, titel="Tom – 9051: Zwerg") == "kein Auftrag")

# 3 rundblick_zeilen
Z = [{"nr": "9050", "titel": TD, "besitzer": "Sokrates", "stand": "startbar", "warte": []}]
J = lauf.JETZT
def s(sid, titel, laufend, ruhig): return {"id": sid, "title": titel, "_info": ("Rundblick", laufend, ruhig, [])}
def rz(je=None, marken=None, scharf=True, zeilen=Z):
    a = []; nr = lauf.rundblick_zeilen(a, je or {}, set(), marken or {}, zeilen=zeilen, scharf=scharf, wurzel=d); return nr, a
soll("ohne 1727-SCHARF nichts", rz(scharf=False) == (None, []))
nr, a = rz()
soll("scharf: START Rundblick", nr == "9050" and len(a) == 1 and a[0].startswith("START Rundblick | opus") and "| Rundblick – 9050: Routine (" in a[0], a)
soll("Teil A und Nummer in der Nachricht", a and "**Rundblick** Ziel." in a[0] and "<Nr> ist 9050." in a[0], a)
soll("ohne Kern (mit_kern ändert nichts)", a and lauf.mit_kern(a[0]) == a[0])
r = lauf.mit_rufnamen(a, [], J) if a else []
soll("ohne Rufname", r == a, r)
soll("Kaufrepo-Satz an der Routine (1803)", a and lauf.mit_kaufrepo(a[0]).endswith(lauf.kaufrepo_satz()) and lauf.mit_kaufrepo(lauf.mit_kaufrepo(a[0])) == lauf.mit_kaufrepo(a[0]), a)
soll("Kaufrepo-Satz an START Tom", lauf.mit_kaufrepo("START Tom | opus | x | y").endswith(lauf.kaufrepo_satz()))
soll("Kaufrepo-Satz bei WEITER vor send_message", lauf.KAUFREPO.strip() + " Wird send_message" in lauf.mit_kaufrepo("WEITER Tom | x; wird send_message an y", False))
# 1907: Ideenlauf (Sokrates, Gesamtbild 4.3 G:451) über denselben Starter; ohne Teil A WARNUNG
ZI = [{"nr": "9060", "titel": "Wochentermin 29.11.: Ideenlauf (Routine, Auftrag r/x.md Teil A) (719)", "besitzer": "Sokrates", "stand": "startbar", "warte": []}]
a = []; nr = lauf.rundblick_zeilen(a, {}, set(), {}, zeilen=ZI, scharf=True, wurzel=d, name="Ideenlauf")
soll("1907: START Ideenlauf mit Teil A", nr == "9060" and len(a) == 1 and a[0].startswith("START Ideenlauf | opus") and "| Ideenlauf – 9060: Routine (" in a[0] and "Routine Ideenlauf, Vorgang 9060" in a[0], a)
a = []; nr = lauf.rundblick_zeilen(a, {}, set(), {}, zeilen=ZI, scharf=True, wurzel=d)
soll("1907: Rundblick-Starter nimmt den Ideenlauf nicht", nr is None and a == [], a)
ZI2 = [dict(ZI[0], titel=ZI[0]["titel"].replace("r/x.md", "r/fehlt.md"))]
a = []; nr = lauf.rundblick_zeilen(a, {}, set(), {}, zeilen=ZI2, scharf=True, wurzel=d, name="Ideenlauf")
soll("1907: Teil A fehlt → WARNUNG Ideenlauf", nr is None and a and a[0].startswith("WARNUNG Ideenlauf 9060 nicht gestartet: Teil A nicht lesbar"), a)
soll("1907: Rolle Ideenlauf in kosten, Routine ohne Kern", "Ideenlauf" in kosten.ROLLEN and "Ideenlauf" in lauf.ROUTINE_ROLLEN)
# 1781: nach der Umschaltung „Sockel“ statt „Rollendatei“, ohne Schalter der alte Satz; nie zwei Sätze
soll("1781 ohne Schalter: Rollendatei", lauf.mit_kaufrepo("START Tom | opus | x | y", False).endswith("in deiner Rollendatei steht."))
soll("1781 scharf: Sockel", lauf.mit_kaufrepo("START Tom | opus | x | y", True).endswith("in deinem Sockel steht."))
soll("1781 scharf: Rollendatei nicht mehr genannt", "Rollendatei" not in lauf.mit_kaufrepo("START Tom | opus | x | y", True))
soll("1781 scharf, doppelt angewandt: ein Satz", lauf.mit_kaufrepo(lauf.mit_kaufrepo("START Tom | opus | x | y", True), True).count("add_repo") == 1)
soll("1781 alter Satz schon da, scharf: kein zweiter", lauf.mit_kaufrepo("START Tom | opus | x | y" + lauf.KAUFREPO, True).count("add_repo") == 1)
soll("1781 WEITER scharf: Sockel vor send_message", lauf.KAUFREPO_SCHARF.strip() + " Wird send_message" in lauf.mit_kaufrepo("WEITER Tom | x; wird send_message an y", True))
soll("1781 Schalter folgt tools/1727-SCHARF", lauf.kaufrepo_satz() == (lauf.KAUFREPO_SCHARF if lauf.ist_scharf() else lauf.KAUFREPO))
soll("NACHRICHT ohne Kaufrepo-Satz", lauf.mit_kaufrepo("NACHRICHT Tom | s | t") == "NACHRICHT Tom | s | t")
soll("Zeile wartet: nichts", rz(zeilen=[dict(Z[0], warte=["Wochenzählung"])]) == (None, []))
soll("Besitzer nicht Sokrates: nichts", rz(zeilen=[dict(Z[0], besitzer="Tom")]) == (None, []))
soll("erledigt: nichts", rz(zeilen=[dict(Z[0], stand="erledigt")]) == (None, []))
nr, a = rz({"Rundblick": [s("session_R1", "Rundblick – 9050: Routine (23.11., 09:00)", True, 3)]})
soll("läuft: NICHTS", nr is None and a == ["NICHTS Rundblick: läuft (1789)"], a)
nr, a = rz({"Rundblick": [s("session_R1", "Rundblick – 9050: Routine (23.11., 09:00)", False, 90)]})
soll("Lauf zu Ende, Vorgang offen: wartet aufs Büro, kein zweiter Start", nr is None and "wartet auf das Büro" in a[0], a)
nr, a = rz({"Rundblick": [s("session_R0", "Rundblick – 9001: Routine (16.11., 09:00)", False, 9000)]})
soll("alte Woche stört nicht", nr == "9050", a)
nr, a = rz(marken={"Rundblick": J - datetime.timedelta(minutes=5)})
soll("Startmarke jünger als 20 Min.: nichts", nr is None and "Startmarke" in a[0], a)
nr, a = rz(zeilen=[dict(Z[0], titel="Wochentermin 23.11.: Rundblick (Routine, Auftrag r/fehlt.md Teil A) (719)")])
soll("Teil A fehlt: WARNUNG", nr is None and a[0].startswith("WARNUNG Rundblick 9050 nicht gestartet"), a)

# 4 Rolle in kosten.py und startsperre-haken.py
soll("kosten.rolle: Rundblick", kosten.rolle("Rundblick – 9050: Routine (23.11., 09:00)") == "Rundblick")
spec = importlib.util.spec_from_file_location("sh", os.path.join(HIER, "startsperre-haken.py")); sh = importlib.util.module_from_spec(spec); spec.loader.exec_module(sh)
soll("Startsperre-Haken kennt die Rolle", sh.rolle_aus({"title": "Rundblick – 9050: Routine (23.11., 09:00)", "prompt": "Routine Rundblick"}) == "Rundblick")

# 5 rueckmeldung.py: „fertig“ ohne Commit
an, was = rueckmeldung.weitergabe({"fertig"}, "", "23.11., 10:00", "Rundblick", "fertig", "", routine=True)
soll("Routine fertig ohne Commit → Disponent: anlegen, schließen", an == "Disponent" and "Routine fertig" in was and "schliessen" in was, (an, was))
an, was = rueckmeldung.weitergabe({"fertig"}, "", "23.11., 10:00", "Tom", "fertig", "", routine=False)
soll("sonst „fertig“ ohne Commit abgewiesen", an == "Disponent" and "ohne Commit" in was, was)
soll("ist_routine: Zeile nicht da", rueckmeldung.ist_routine("99999") is False)
# 1790: „ja“ des Prüfers bei einem Werkzeug ist keine Testbitte an den Chef
an, was = rueckmeldung.weitergabe({"ja"}, "", "23.11., 10:00", "Prüfer", "ja, greift", "", werkzeug=True)
soll("ja bei Werkzeug → Disponent ohne Testbitte", an == "Disponent" and "kein Test des Chefs" in was and "Testbitte" not in was and "vorgang.py fertig" in was, was)
an, was = rueckmeldung.weitergabe({"ja"}, "", "23.11., 10:00", "Prüfer", "ja", "")
soll("ja sonst → Testbitte an den Chef", an == "Disponent" and "Testbitte" in was, was)
soll("ist_werkzeug: Zeile nicht da", rueckmeldung.ist_werkzeug("99999") is False)

# 1871: Tagesbericht als Routine statt Perikles (werkzeuge.md Stilllegung C, routine-tagesbericht.md)
zl, warn = lauf.tagesbericht_start("22.11.", wurzel=W)
soll("Tagesbericht: START-Zeile der Routine", zl and zl.startswith("START Tagesbericht | ") and warn is None, (zl, warn))
soll("Tagesbericht: Titel mit 448", zl and "| Tagesbericht – 448: Routine 22.11. (" in zl, zl)
soll("Tagesbericht: Auftrag ist der Text der Routine, eine Zeile", zl and "Ziel: der Chef sieht morgens" in zl and "\n" not in zl, zl)
soll("Tagesbericht: ohne Kern (mit_kern lässt die Zeile)", zl and lauf.mit_kern(zl) == zl)
zl2, warn2 = lauf.tagesbericht_start("22.11.", wurzel=d)
soll("Tagesbericht: Datei fehlt → Warnung", zl2 is None and warn2.startswith("WARNUNG Tagesbericht 22.11."), (zl2, warn2))
soll("Tagesbericht: Rolle für Kosten", kosten.rolle("Tagesbericht – 448: Routine 22.11. (22.11., 07:30)") == "Tagesbericht")
print("rundblick_test: %d Fehler" % fehl)
sys.exit(1 if fehl else 0)
