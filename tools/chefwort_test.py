# 1762 Haken D: Chefwort aus fremder Sitzung wörtlich in docs/vorgang/NR.md, offene Zeile an den Arbeitsplaner.
# Erkennung (Chef gegen Sitzung, Nummern gegen Uhrzeit/Datum/Build), scharf erst mit tools/1727-SCHARF, eigener gegen fremder
# Vorgang (Besitzer, Halter einer Übergabezeile), Hintergrund-Eintrag, doppelter Wortlaut, von Hand. Echtes Git mit nacktem origin.
# Aufruf: python3 tools/chefwort_test.py
import json, os, subprocess, sys, tempfile, time
HIER = os.path.dirname(os.path.abspath(__file__))
d = tempfile.mkdtemp(); o = os.path.join(d, "origin.git"); A = os.path.join(d, "a")
def g(*a, cwd=None): return subprocess.run(["git"] + list(a), cwd=cwd, check=True, capture_output=True, text=True).stdout
g("init", "-q", "--bare", "-b", "main", o)
g("clone", "-q", o, A); g("config", "user.email", "t@t", cwd=A); g("config", "user.name", "t", cwd=A); g("checkout", "-q", "-b", "main", cwd=A)
os.makedirs(os.path.join(A, "docs")); os.makedirs(os.path.join(A, "tools"))
for f in ("chefwort.py", "rueckmeldung.py", "uebergabe.py", "startbar.py", "bereiche.py", "vorgang.py", "neustart-haken.py", "kernregeln.txt"):
    if os.path.exists(os.path.join(HIER, f)): os.symlink(os.path.join(HIER, f), os.path.join(A, "tools", f))
open(os.path.join(A, "docs", "LISTE-VORGAENGE.md"), "w").write(
    "# Vorgangsliste\n\n| Nr. | Titel | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |\n|---|---|---|---|---|---|---|---|---|---|\n"
    "| 9001 | Zwerg auf dem Tisch | Tom | M | gebaut | – | – | 301 | E Welt | – |\n"
    "| 9002 | Schatten im Wald | Spike | M | startbar | – | – | – | T Technik | – |\n"
    "| 9003.2 | Höhlenklang | Jerry | M | gebaut | – | – | 301 | K Klang | – |\n"
    "| 9004 | Tür im Turm | Tom | M | gebaut | – | – | – | E Welt | – |\n"
    + "".join("| %s | Fall 1962 | Tom | M | startbar | – | – | – | B Werkzeuge | – |\n" % n for n in ("1520", "1871", "1959", "1961")))
open(os.path.join(A, "docs", "ARBEIT-BESETZUNG.md"), "w").write(
    "| Rolle | Sitzung | Vorgang | Zweig | seit |\n|---|---|---|---|---|\n| Arbeitsplaner | [AP](https://claude.ai/code/session_AP1) | – | – | 21.11. |\n"
    "| Sokrates | [S](https://claude.ai/code/session_SOK) | – | – | 21.11. |\n")
g("add", "-A", cwd=A); g("commit", "-q", "-m", "start", cwd=A); g("push", "-q", "origin", "main", cwd=A)
ENV = dict(os.environ, BORNIM_WURZEL=A, BORNIM_JETZT="21.11., 20:30", GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@t",
           GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@t", BORNIM_SITZUNG="session_SOK",
           BORNIM_CHEFWORT_FEHLER=os.path.join(d, "fehler.txt"))
ENV.pop("BORNIM_OHNE_PUSH", None); ENV.pop("BORNIM_CHEFWORT_AN", None)
os.environ.update(ENV)
sys.path.insert(0, os.path.join(A, "tools"))
import chefwort as cw
fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))
def datei(nr):
    g("fetch", "-q", "origin", cwd=A)
    try: return g("show", "origin/main:docs/vorgang/%s.md" % nr, cwd=A)
    except subprocess.CalledProcessError: return ""
def lauf(*a):
    p = subprocess.run([sys.executable, os.path.join(A, "tools", "vorgang.py")] + list(a), env=ENV, capture_output=True, text=True, cwd=A)
    return p.returncode, p.stdout + p.stderr

# 1 Wer spricht
def protokoll(*zeilen):
    p = os.path.join(d, "s%d.jsonl" % protokoll.n); protokoll.n += 1
    open(p, "w").write("".join(json.dumps(z, ensure_ascii=False) + "\n" for z in zeilen)); return p
protokoll.n = 0
def warteschlange(text): return {"type": "queue-operation", "operation": "enqueue", "content": text}
def nutzer(text, art=None, quelle=None):
    z = {"type": "user", "message": {"role": "user", "content": text}}
    if art: z["origin"] = {"kind": art}
    if quelle: z["promptSource"] = quelle
    return z
def chef(text):  # 1962: Haken-Eingabe einer echten Chefnachricht (Startnachricht davor, Zeile „user“ ohne origin)
    return {"prompt": text, "transcript_path": protokoll(nutzer("Start", "task-notification", "system"), warteschlange(text), nutzer(text))}
soll("Chef", cw.vom_chef("9001 passt, freigegeben"))
soll("andere Sitzung (Name und Zeit)", not cw.vom_chef("**Ford** [21.11., 20:10] 9001 bitte"))
soll("Startauftrag", not cw.vom_chef("Du bist **Spike**, Technik …"))
soll("Systemmeldung", not cw.vom_chef("<task-notification>9001</task-notification>") and not cw.vom_chef("[SYSTEM NOTIFICATION] 9001"))
soll("Wecker", not cw.vom_chef("sieh in 9001 (9001-Ü1)"))
pr = os.path.join(d, "p.jsonl")
open(pr, "w").write(json.dumps({"type": "user", "origin": {"kind": "task-notification"}, "message": {"content": "Mach 9001 fertig"}}) + "\n")
soll("im Protokoll als Sitzungsnachricht markiert", not cw.vom_chef("Mach 9001 fertig", pr))
open(pr, "w").write(json.dumps({"type": "user", "message": {"content": "Mach 9001 fertig"}}) + "\n")
soll("1962: erste Nachricht der Sitzung nie Chef, auch ohne Herkunft", not cw.vom_chef("Mach 9001 fertig", pr))
soll("1962: nach der Startnachricht ohne Herkunft = Chef", cw.vom_chef("Mach 9001 fertig", chef("Mach 9001 fertig")["transcript_path"]))
soll("1962: origin human = Chef", cw.herkunft("Mach 9001", protokoll(nutzer("Start", "task-notification", "system"), nutzer("Mach 9001", "human"))) == "chef")
soll("1962: Nachricht einer Sitzung (peer) nicht", cw.herkunft("Mach 9001", protokoll(nutzer("Start"), nutzer("Mach 9001", "peer"))) == "sitzung")
soll("1962: unbekannte Art unbelegt", cw.herkunft("Mach 9001", protokoll(nutzer("Start"), nutzer("Mach 9001", "remote"))).startswith("unbelegt"))
soll("1962: Zeile noch nicht im Protokoll = offen", cw.herkunft("Mach 9001", protokoll(nutzer("Start"), warteschlange("Mach 9001"))) == "offen")
soll("1962: Haken ohne Protokoll trägt nichts ein", cw.haken({"prompt": "9001 passt"}, "Sokrates") == [])

# 2 Welche Vorgänge
v = cw.vorgaenge("9001 gut. Um 20:06 am 21.11. für 30 € und 9002 nicht; 9003.2a beantwortet")
soll("Nummern, Unternummer, Rückfrage-Buchstabe", sorted(v) == ["9001", "9002", "9003.2"], sorted(v))
soll("Uhrzeit, Datum, Betrag zählen nicht", sorted(cw.vorgaenge("21.11., 20:06: 9001 kostet 9002 €")) == ["9001"], sorted(cw.vorgaenge("21.11., 20:06: 9001 kostet 9002 €")))
soll("Build 301 = alle Vorgänge mit Build 301", sorted(cw.vorgaenge("Build 301 passt")) == ["9001", "9003.2"], sorted(cw.vorgaenge("Build 301 passt")))
soll("t301.4 ebenso", sorted(cw.vorgaenge("t301.4 ✓")) == ["9001", "9003.2"])
soll("Nummer mit Komma dahinter (1769)", sorted(cw.vorgaenge("9001, ein Lauf frei")) == ["9001"] and sorted(cw.vorgaenge("9001, 9002 passen")) == ["9001", "9002"], sorted(cw.vorgaenge("9001, 9002 passen")))
soll("Dezimalzahl zählt nicht", cw.vorgaenge("9001,50 € und 9002,5") == {}, cw.vorgaenge("9001,50 € und 9002,5"))
soll("Pfad und unbekannte Nummer nicht", cw.vorgaenge("docs/vorgang/9001.md und 9999") == {})
soll("Nummer am Satzende", sorted(cw.vorgaenge("Gebilligt: 9001.")) == ["9001"], sorted(cw.vorgaenge("Gebilligt: 9001.")))

# 3 Nicht scharf: nichts
nrs = cw.haken({"prompt": "9001 freigegeben"}, "Sokrates")
soll("ohne tools/1727-SCHARF nichts", nrs == [] and datei("9001") == "")
open(cw.SCHARF, "w").write("1727\n")

# 4 Eigener Vorgang (Besitzer): nichts; fremder: im Hintergrund eingetragen
soll("eigener Vorgang (Besitzer Spike) bleibt in der Sitzung", cw.haken(chef("9002 so lassen"), "Spike") == [])
soll("Sitzungsnachricht nicht", cw.haken({"prompt": "**Tom** [21.11., 20:29] 9001 fertig"}, "Sokrates") == [])
nrs = cw.haken(chef("9001 freigegeben, Build 312:\nBart passt jetzt"), "Sokrates")
soll("fremder Vorgang erkannt", nrs == ["9001"], nrs)
t = ""
for _ in range(60):
    t = datei("9001")
    if "Ü1" in t: break
    time.sleep(0.5)
soll("Chefwort wörtlich mit Zeit und Sitzung", "- **21.11., 20:30**, Chef in Sitzung Sokrates (`session_SOK`):\n> 9001 freigegeben, Build 312:\n> Bart passt jetzt\n" in t, t)
soll("Freigabe des Builds: offene Zeile an den Disponenten im selben Stand (1782)", "| 9001-Ü1 | Disponent | Chefwort 21.11., 20:30 aus Sitzung Sokrates lesen (Abschnitt Chefworte); Freigabe oder Ergebnis des Builds: Build-Macher starten (3.3 Nr. 7, 1782) | 21.11., 20:30 | offen |" in t, t)
soll("ein Commit für beides", g("log", "-1", "--format=%s", "origin/main", cwd=A).strip() == "Chefwort 9001 aus Sitzung Sokrates (Haken D, 1762)")
soll("Abschnitt Chefworte vor Übergaben", t.index("## Chefworte") < t.index("## Übergaben"), t)

# 5 Gleicher Wortlaut zur gleichen Minute: einmal
k = cw.eintragen("9001", "9001 freigegeben, Build 312:\nBart passt jetzt", "21.11., 20:30", "Sokrates", "session_SOK")
soll("doppelt: nichts neu", k is None and datei("9001").count("Bart passt jetzt") == 1, datei("9001"))

# 6 Von Hand über vorgang.py, mit Wecker an den Arbeitsplaner
rc, out = lauf("chefwort", "9003.2", "Nein, der Hall ist zu lang", "--zeit", "21.11., 20:31")
soll("vorgang.py chefwort", rc == 0 and "CHEFWORT 9003.2 eingetragen, OFFEN 9003.2-Ü1 an Arbeitsplaner" in out and "WECKER session_AP1 | sieh in 9003.2 (9003.2-Ü1)" in out, out)
soll("Rolle aus der Besetzung", "Chef in Sitzung Sokrates" in datei("9003.2"), datei("9003.2"))
rc, out = lauf("offen", "Arbeitsplaner")
soll("Arbeitsplaner sieht nur den Fund (Freigabe ging an den Disponenten; Einschränkung oder Frage dagegen an ihn, 1908)", "1 Zeile" in out and "9003.2-Ü1" in out, out)

# 7 Halter einer angenommenen Zeile gilt als eigen (nach der Umschaltung ohne Besitzer)
rc, out = lauf("annehmen", "9001-Ü1")
soll("Sokrates nimmt 9001-Ü1 an", rc == 0 and out.startswith("ANGENOMMEN"), out)
soll("dann eigen, kein neuer Eintrag", cw.haken(chef("9001 noch heller"), "Sokrates") == [])

# 8 Fehler beim Eintragen geht nicht verloren: nächste Nachricht meldet ihn
open(cw.FEHLER, "w").write("9001 (21.11., 20:40): origin/main nicht erreichbar\n")
import io, contextlib
buf = io.StringIO()
with contextlib.redirect_stdout(buf): cw.haken({"prompt": "hallo"}, "Sokrates")
soll("Fehler gemeldet und Datei weg", "Eintragen fehlgeschlagen" in buf.getvalue() and "9001 (21.11., 20:40)" in buf.getvalue() and not os.path.exists(cw.FEHLER), buf.getvalue())

# 9 1782 (3.3 Nr. 7, L-U15): Freigabe des Builds oder Ergebnis nach Checkliste 11, 12 → Disponent, sonst Arbeitsplaner
mit, ohne = {"build": "301"}, {"build": "–"}
soll("„passt“ mit Build am Vorgang → Disponent", cw.empfaenger("9001 passt", "9001", mit) == "Disponent")
soll("„freigegeben“ ohne Build → Arbeitsplaner", cw.empfaenger("9002 freigegeben", "9002", ohne) == "Arbeitsplaner")
soll("„gut“ als erstes Wort, Build im Text → Disponent", cw.empfaenger("Gut, Build 301 kann so", "9002", ohne) == "Disponent")
soll("„gut“ mitten im Satz → Arbeitsplaner", cw.empfaenger("9001 sieht nicht gut aus, Bart zu hell", "9001", mit) == "Arbeitsplaner")
soll("Ergebnis „- 301.2 ✗ Bart“ → Disponent", cw.empfaenger("## Ergebnis\n- 301.1 ✓\n- 301.2 ✗ Bart zu hell\n- Rest ✓", "9001", mit) == "Disponent")
soll("👎 allein (ein Punkt, Fund) → Arbeitsplaner", cw.empfaenger("👎 9001", "9001", ohne) == "Arbeitsplaner")
soll("Fund ohne Freigabe → Arbeitsplaner", cw.empfaenger("Nein, der Hall ist zu lang", "9003.2", mit) == "Arbeitsplaner")
# 10 1903 (D340.1): Verneinung, einzelnes 👍/👎, Ergebnis ohne Build sind keine Freigabe
soll("„Das passt nicht“ mit Build → Arbeitsplaner", cw.empfaenger("Das passt nicht, Schatten falsch", "9001", mit) == "Arbeitsplaner")
soll("„noch nicht freigegeben“ mit Build → Arbeitsplaner", cw.empfaenger("9001 ist noch nicht freigegeben", "9001", mit) == "Arbeitsplaner")
soll("„passt so nicht“ → Arbeitsplaner", cw.empfaenger("Build 301 passt so nicht", "9001", mit) == "Arbeitsplaner")
soll("„gut, aber nicht freigegeben“ → Arbeitsplaner", cw.empfaenger("Gut gemeint, aber nicht freigegeben", "9001", mit) == "Arbeitsplaner")
soll("„👍“ allein mit Build → Arbeitsplaner", cw.empfaenger("👍", "9001", mit) == "Arbeitsplaner")
soll("„👎 Tür flackert“ mit Build → Arbeitsplaner", cw.empfaenger("👎 Tür flackert", "9001", mit) == "Arbeitsplaner")
soll("„3 ✓“ ohne Build → Arbeitsplaner", cw.empfaenger("3 ✓", "9002", ohne) == "Arbeitsplaner")
soll("„3 ✓“ mit Build am Vorgang → Disponent", cw.empfaenger("3 ✓", "9001", mit) == "Disponent")
soll("„Ergebnis t301“ ohne Build am Vorgang → Disponent", cw.empfaenger("t301\n- 1 ✓\n- Rest ✓", "9002", ohne) == "Disponent")
soll("gemischt „passt nicht, freigegeben ist der Rest“ → Arbeitsplaner (im Zweifel)", cw.empfaenger("Tür passt nicht, freigegeben ist der Rest", "9001", mit) == "Arbeitsplaner")
soll("„freigegeben und passt mit Einschränkungen“ → Arbeitsplaner (1908)", cw.empfaenger("Testbuild freigegeben und passt mit Einschränkungen", "9001", mit) == "Arbeitsplaner")
for _t in ("Passt, aber Schatten zu dunkel. Build 312", "Gut gemeint, aber zu laut, Build 312", "Passt, aber noch nicht freigeben, Build 312",
           "Passt das? Build 312", "Build 312 passt, bis auf die Tür", "Passt allerdings flackert die Fackel, Build 312"):
    soll("1908 Einschränkung/Frage „%s“ → Arbeitsplaner" % _t, cw.empfaenger(_t, "9001", mit) == "Arbeitsplaner")
soll("1908 „Passt. Build 312“ → Disponent", cw.empfaenger("Passt. Build 312", "9002", ohne) == "Disponent")
soll("1908 Ergebnis mit Frage im Fund bleibt Ergebnis → Disponent", cw.empfaenger("t312\n- 1 ✗ warum flackert die Tür?\n- Rest ✓", "9002", ohne) == "Disponent")
soll("1908 chef_nein: „Passt, aber …“ ist kein Nein", not cw.chef_nein("Passt, aber Schatten zu dunkel. Build 312"))
soll("1876: „weniger laufen“ → Sokrates", cw.empfaenger("9001 heute weniger laufen, nur Rückläufer", "9001", mit) == "Sokrates")
soll("1876: Laufsperre → Sokrates", cw.empfaenger("Laufsperre: höchstens 3 Starts, spätestens 18:00", "9002", ohne) == "Sokrates")
soll("1876: Vorgang im Bereich B Abläufe → Sokrates", cw.empfaenger("so nicht", "9009", {"nr": "9009", "bereich": "B Abläufe", "build": "–"}) == "Sokrates")
soll("1876: Freigabe im Bereich B Abläufe bleibt Disponent", cw.empfaenger("passt", "9009", {"nr": "9009", "bereich": "B Abläufe", "build": "t301"}) == "Disponent")
welt = {"nr": "9001", "bereich": "E Welt", "build": "–"}
soll("1915: „Die Wachen sollen nicht mehr laufen“ zu Spielvorgang → Arbeitsplaner", cw.empfaenger("Die Wachen sollen nicht mehr laufen", "9001", welt) == "Arbeitsplaner")
soll("1915: „Gegner sollen weniger laufen“ zu Spielvorgang → Arbeitsplaner", cw.empfaenger("Gegner sollen weniger laufen", "9001", welt) == "Arbeitsplaner")
soll("1915: „weniger laufen“ ohne Vorgang → Sokrates", cw.empfaenger("heute weniger laufen", None, None) == "Sokrates")
soll("1915: „weniger laufen“ zu Vorgang im Bereich B Steuerung → Sokrates", cw.empfaenger("weniger laufen", "9008", {"nr": "9008", "bereich": "B Steuerung", "build": "–"}) == "Sokrates")
soll("1915: „nur Rückläufer“ zu Spielvorgang bleibt Sokrates", cw.empfaenger("weniger laufen, nur Rückläufer", "9001", welt) == "Sokrates")
soll("1876: Fund ohne Betrieb bleibt Arbeitsplaner", cw.empfaenger("Tür läuft zu langsam", "9001", mit) == "Arbeitsplaner")
soll("Wort „Gutachten“ zählt nicht", cw.empfaenger("Gutachten zu 9001", "9001", mit) == "Arbeitsplaner")

# 11 1872: Chef-Nein zählt für Obergrenze A („Prüfer ja, Chef nein“ stoppt beim dritten)
soll("chef_nein: „nein“, 👎, ✗, „passt nicht“", all(cw.chef_nein(x) for x in ("Nein, Tür klemmt", "👎 Tür", "- 1 ✗ Tür", "Das passt nicht")), True)
soll("chef_nein: Freigabe, Frage, Fund ohne Nein nicht", not any(cw.chef_nein(x) for x in ("passt", "Gut, Build 301", "Warum ist die Tür blau?")))
import rueckmeldung as rm
for i, (zeit, wort) in enumerate([("21.11., 21:00", "Nein, Tür klemmt"), ("21.11., 21:10", "Gut so, freigegeben"), ("21.11., 21:20", "👎 Tür klemmt weiter")]):
    rc, out = lauf("chefwort", "9004", wort, "--zeit", zeit)
t = datei("9004")
soll("zwei Chef-Nein, eine Freigabe: Zählung 2, keine Obergrenze", rm.zaehlen(t)["nein"] == 2 and "Obergrenze A" not in t, t)
rc, out = lauf("chefwort", "9004", "Das passt nicht, Tür klemmt immer noch", "--zeit", "21.11., 21:30")
t = datei("9004")
soll("drittes Chef-Nein: Obergrenze A, Zeile an Sokrates, ruht", "Zustand: ruht, beim Chef seit 21.11., 21:30 (Obergrenze A: 3. abgelehnter Auftrag, zuletzt Chefwort" in t
     and "| Sokrates | an den Chef: Chefsache anlegen, nicht selbst lösen (Obergrenze A: 3." in t and "OFFEN 9004-Ü4 an Sokrates" in out, (out, t))
rc, out = lauf("chefwort", "9004", "Nein, immer noch", "--zeit", "21.11., 21:40")
soll("ruht schon: Zeile wieder an den Arbeitsplaner, keine zweite Obergrenze", datei("9004").count("Obergrenze A") == 2 and "an Arbeitsplaner" in out, (out, datei("9004")))

# 12 1962: Startnachrichten (Disponent, Wache, Routine) sind nie Chefwort, auch wenn das Protokoll beim Haken leer oder frisch ist.
# Beleg 22.11., 18:15 (Protokoll dieser Sitzung): beim Haken steht dort zuerst nur „queue-operation“ (enqueue, Inhalt ohne origin);
# die Zeile „user“ mit origin task-notification folgt erst danach. Wortlaut der vier Fälle aus docs/vorgang/{1520,1959,1871,1961}.md.
START = json.load(open(os.path.join(HIER, "chefwort_test_start.json"), encoding="utf-8"))
for fall, text in START.items():
    nr = fall.split()[0]
    for wie, p in (("leeres Protokoll", protokoll()), ("frisches Protokoll (nur Warteschlange)", protokoll(warteschlange(text))),
                   ("Protokoll mit task-notification", protokoll(warteschlange(text), nutzer(text, "task-notification", "system")))):
        nrs = cw.haken({"prompt": text, "transcript_path": p}, "Sokrates")
        soll("1962 Startnachricht %s, %s: kein Chefwort" % (fall, wie), nrs == [], nrs)
time.sleep(3)
soll("1962 Startnachrichten: keine Vorgangsdatei geschrieben", all(datei(n) == "" for n in ("1520", "1871", "1959", "1961")),
     [n for n in ("1520", "1871", "1959", "1961") if datei(n)])
wort = "1520 so nicht, der Text ist zu lang"
p = protokoll(warteschlange(START["1520 22.11., 17:10"]), nutzer(START["1520 22.11., 17:10"], "task-notification", "system"), warteschlange(wort), nutzer(wort))
nrs = cw.haken({"prompt": wort, "transcript_path": p}, "Sokrates")
t = ""
for _ in range(60):
    t = datei("1520")
    if "1520-Ü1" in t: break
    time.sleep(0.5)
soll("1962 echtes Chefwort nach der Startnachricht wird eingetragen", nrs == ["1520"] and "> " + wort in t, (nrs, t))
os.environ["BORNIM_CHEFWORT_WARTEN"] = "1"
wort = "1871 bitte morgen frueher"
nrs = cw.haken({"prompt": wort, "transcript_path": protokoll(nutzer("Start", "task-notification", "system"), warteschlange(wort))}, "Sokrates")
for _ in range(40):
    if os.path.exists(cw.FEHLER): break
    time.sleep(0.25)
time.sleep(0.5)
meldung = open(cw.FEHLER).read() if os.path.exists(cw.FEHLER) else ""
soll("1962 Zeile kommt nicht ins Protokoll: nichts eingetragen, Meldung für die nächste Nachricht",
     nrs == ["1871"] and datei("1871") == "" and "Herkunft Chef nicht belegt (offen)" in meldung, (nrs, meldung))

print("chefwort_test: %s" % ("alles grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
