# 1766: Höchstdauer je Auftrag in lauf.py (auch bei working, scharf erst mit tools/1727-SCHARF und Wert) und Laufbremse
# (probelauf.py: den nächsten Lauf gibt der Prüfer frei). Ohne Netz. Aufruf: python3 tools/laufbremse_test.py
import datetime, os, sys, tempfile
HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER); sys.argv = [sys.argv[0]]
import lauf, probelauf
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

B = lauf.BERLIN
J = datetime.datetime(2026, 11, 21, 22, 0, tzinfo=B)
docs = tempfile.mkdtemp(); os.makedirs(os.path.join(docs, "vorgang"))
def datei(nr, text): open(os.path.join(docs, "vorgang", "%s.md" % nr), "w", encoding="utf-8").write(text)
def sitz(sid, titel, start, laeuft=True, env=None):
    s = {"id": sid, "title": titel, "created_at": start, "updated_at": "2026-11-21T20:59:00Z", "_info": ("Tom", laeuft, 1, [])}
    if env: s["environment_id"] = env
    return s
G = {"Mittel": 90, "Hoch": 180}
hz = lambda je, **k: lauf.hoechstdauer_zeilen([], je, set(), docs=docs, jetzt=J, **k)

# 1 aus: ohne Schalter oder ohne Wert nichts
t1 = sitz("session_T1", "Tom – 9001: Zwerg (21.11., 19:00)", "2026-11-21T18:00:00Z")  # 19:00 Berlin, 180 Min.
soll("ohne 1727-SCHARF nichts", hz({"Tom": [t1]}, grenzen=G, scharf=False) == [])
soll("Wert fehlt (None): nichts", hz({"Tom": [t1]}, grenzen={"Mittel": None, "Hoch": None}, scharf=True) == [])
soll("Konstante steht oben, Wert fehlt bis 1774", lauf.HOECHSTDAUER_MIN == {"Mittel": None, "Hoch": None}, lauf.HOECHSTDAUER_MIN)

# 2 über der Grenze, auch bei working: erstes Mal Hinweis
z = hz({"Tom": [t1]}, grenzen=G, scharf=True)
soll("erstes Mal: HÖCHSTDAUER mit Hinweis", len(z) == 1 and z[0].startswith("HÖCHSTDAUER session_T1 | Tom | 9001 | Hinweis: Höchstdauer 90 Min. (Mittel) überschritten, 180 Min. seit 21.11., 19:00, Sitzung session_T1 angehalten (1766)"), z)
soll("ruhende Sitzung: nichts", hz({"Tom": [sitz("session_T1", t1["title"], t1["created_at"], laeuft=False)]}, grenzen=G, scharf=True) == [])
soll("Ford, Sokrates nie", hz({"Ford": [t1], "Sokrates": [t1]}, grenzen=G, scharf=True) == [])
soll("archiviert: nichts", lauf.hoechstdauer_zeilen([], {"Tom": [t1]}, {"session_T1"}, docs=docs, jetzt=J, grenzen=G, scharf=True) == [])
soll("Titel ohne Nummer: nichts", hz({"Tom": [sitz("session_T9", "Tom – Aufräumen", t1["created_at"])]}, grenzen=G, scharf=True) == [])

# 3 unter der Grenze; Hoch über Umgebung oder Feld Leistungsstufe
soll("unter 90 Min.: nichts", hz({"Tom": [sitz("session_T2", "Tom – 9002: x", "2026-11-21T19:45:00Z")]}, grenzen=G, scharf=True) == [])
soll("Umgebung HOCH: 180 Min. gilt, 180 nicht darüber", hz({"Tom": [sitz("session_T3", "Tom – 9003: x", t1["created_at"], env=lauf.HOCH)]}, grenzen=G, scharf=True) == [])
datei("9004", "# 9004\n\n## Auftrag (21.11., 18:30)\n\n8. **Leistungsstufe:** Hoch\n")
z = hz({"Tom": [sitz("session_T4", "Tom – 9004: x", "2026-11-21T17:00:00Z")]}, grenzen=G, scharf=True)
soll("Leistungsstufe Hoch im Auftrag, ab Auftrag gezählt (210 Min.)", len(z) == 1 and "Höchstdauer 180 Min. (Hoch)" in z[0] and "210 Min. seit 21.11., 18:30" in z[0], z)

# 4 jüngerer Auftrag setzt die Uhr neu (Folgeauftrag an dieselbe Fachkraft)
datei("9005", "# 9005\n\n## Auftrag (21.11., 18:00)\n\nalt\n\n## Auftrag (21.11., 21:00)\n\nneu\n")
soll("Folgeauftrag 21:00: 60 Min., nichts", hz({"Tom": [sitz("session_T5", "Tom – 9005: x", "2026-11-21T16:00:00Z")]}, grenzen=G, scharf=True) == [])

# 5 Ford hat es getan (Kennung in der Rückmeldung): nichts; andere Sitzung danach: steckt fest
datei("9001", "# 9001\n\n## Rückmeldungen\n\n- **21.11., 21:00**, Ford:\n> Hinweis: Höchstdauer 90 Min. (Mittel) überschritten, 120 Min. seit 21.11., 19:00, Sitzung session_T1 angehalten (1766)\n")
soll("schon eingetragen: nichts", hz({"Tom": [t1]}, grenzen=G, scharf=True) == [])
t6 = sitz("session_T6", "Tom – 9001: Zwerg, Neustart", "2026-11-21T19:00:00Z")  # 20:00 Berlin, 120 Min.
z = hz({"Tom": [t6]}, grenzen=G, scharf=True)
soll("zweites Mal je Vorgang: steckt fest (geht an Sokrates)", len(z) == 1 and "| 9001 | steckt fest: Höchstdauer 90 Min." in z[0] and "zweites Mal" in z[0], z)
import rueckmeldung
soll("rueckmeldung.py liest es als steckt fest", rueckmeldung.worte(z[0].split(" | ", 3)[3]) == {"steckt fest"}, z)
soll("erstes Mal nur Hinweis (zählt nicht)", rueckmeldung.worte("Hinweis: Höchstdauer 90 Min.") == {"Hinweis"})

# 6 Laufbremse: Freigabe durch den Prüfer (probelauf.py)
text = ("# 9010\n\n## Rückmeldungen\n\n- **21.11., 20:10**, Tom:\n> fertig, Commit abc\n"
        "- **21.11., 20:40**, Prüfer (`session_PR1`):\n> nein: Bart fehlt\n- **21.11., 20:50**, Tom:\n> fertig, Commit def\n")
soll("jüngste Prüfer-Rückmeldung gibt frei (Minute bis :59)", probelauf.pruefer_frei("9010", text) == "2026-11-21 20:40:59", probelauf.pruefer_frei("9010", text))
soll("„fertig“ allein gibt nichts frei", probelauf.pruefer_frei("9011", "## Rückmeldungen\n\n- **21.11., 20:10**, Tom:\n> fertig\n") is None)
soll("Beleg fehlt gibt frei", probelauf.pruefer_frei("9012", "- **21.11., 21:05**, Prüfer:\n> Beleg fehlt: Film\n") == "2026-11-21 21:05:59")
soll("ohne 1727-SCHARF liest pruefer_frei nichts", os.path.exists(probelauf.SCHARF) or probelauf.pruefer_frei("9010") is None)

# 7 Starter der Routinen (startbar.WOCHENTERMINE_1727): Rundblick montags nach erledigter Wochenzählung, nur scharf
import startbar
startbar.DOCS = docs; startbar.urteil_faellig = lambda j, d: []; startbar.leichenpruefung_faellig = lambda j, d: []; startbar.spiegel_auswertung_faellig = lambda j, d: []
open(os.path.join(docs, "LISTE-VORGAENGE.md"), "w").write("| 9100 | Wochentermin 23.11.: Wochenziel (719) | Perikles |\n")
open(os.path.join(docs, "LISTE-VORGAENGE-ARCHIV.md"), "w").write("")
mo = datetime.datetime(2026, 11, 23, 9, 0)
titel = lambda sch: [t for t, _, _ in startbar.wochentermine_faellig(mo, scharf=sch)]
soll("ohne Schalter: alte Wochenzählung, kein Rundblick", any("Wochenzählung (Kennzahlen" in t for t in titel(False)) and not any("Rundblick" in t for t in titel(False)), titel(False))
soll("scharf: Wochenzählung als Routine, Rundblick wartet", any("Wochenzählung (Routine" in t for t in titel(True)) and not any("Rundblick" in t for t in titel(True)), titel(True))
open(os.path.join(docs, "LISTE-VORGAENGE-ARCHIV.md"), "w").write("| 9101 | Wochentermin 23.11.: Wochenzählung (Routine, Auftrag x) (719) | Diogenes | erledigt |\n")
r = [x for x in startbar.wochentermine_faellig(mo, scharf=True) if "Rundblick" in x[0]]
soll("Wochenzählung erledigt: Rundblick fällig (Sokrates, B Abläufe)", r == [("Wochentermin 23.11.: Rundblick (Routine, Auftrag docs/entwurf/1727-muster/routine-rundblick.md Teil A) (719)", "B Abläufe", "Sokrates")], r)
# 1793: Wochenzählung erst nach Montag erledigt → Rundblick am Dienstag unter dem Montagsdatum nachgeholt, danach Warnung
di = [t for t, _, _ in startbar.wochentermine_faellig(datetime.datetime(2026, 11, 24, 9, 0), scharf=True) if "Rundblick" in t]
soll("Dienstag: Rundblick vom Montag nachgeholt", di == [r[0][0]], di)
soll("Mittwoch: kein Rundblick mehr", not any("Rundblick" in t for t, _, _ in startbar.wochentermine_faellig(datetime.datetime(2026, 11, 25, 9, 0), scharf=True)))
soll("Mittwoch: ausgefallen gemeldet", [x[1] for x in startbar.nach_ausgefallen(datetime.datetime(2026, 11, 25, 9, 0), scharf=True)] == ["23.11."])
open(os.path.join(docs, "LISTE-VORGAENGE.md"), "a").write("| 9102 | %s | Sokrates |\n" % r[0][0])
soll("angelegt: nichts ausgefallen", startbar.nach_ausgefallen(datetime.datetime(2026, 11, 25, 9, 0), scharf=True) == [])
soll("ohne Schalter: keine Meldung", startbar.nach_ausgefallen(datetime.datetime(2026, 11, 25, 9, 0), scharf=False) == [])

print("laufbremse_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
