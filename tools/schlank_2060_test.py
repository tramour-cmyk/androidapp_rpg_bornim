# 2060 (Chef 27.11., 09:27 „Alter Schlons fliegt ins Archiv, neuer Schlons kommt rein“): nach jedem Eintrag stehen in NR.md nur
# Kopf, neueste Auftragsfassung, Chefworte, Zustand, offene Übergaben, letzte Rückmeldung, unbeantwortete Fragen; der Rest wörtlich
# im Archiv. Ü-Nummer und Zählung (Laufbremse, Obergrenzen) über Datei plus Archiv.
# Aufruf: python3 tools/schlank_2060_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uebergabe as ue, rueckmeldung as rm

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

T = """# 9600 · Probe

## Auftrag (26.11., 09:00)

1. **Ziel:** neu

## Auftrag (25.11., 20:00)

1. **Ziel:** alt

## Chefworte

- **25.11., 19:00**, Chef an Alter Ego:
> Mach das.

## Rückmeldungen

Zustand: aufgehoben 26.11., 09:56 durch Chefwort 26.11., 09:55 (war: ruht, beim Chef seit 26.11., 09:50 (Obergrenze A); 1976)

Zustand: aufgehoben 25.11., 21:00 (alt)

Wörtlich, mit Zeit; trägt `vorgang.py rueckmeldung` ein (1763).

- **26.11., 09:10**, Prüfer (`session_P1`):
> nein: Mangel 1

- **26.11., 09:12**, Werkzeug (`session_W1`):
> Frage: beantwortet durch erledigte Übergabe an Werkzeug 09:14 (Ü4)

- **26.11., 09:20**, Werkzeug (`session_W1`):
> fertig an abc1234

- **26.11., 09:25**, Prüfer (`session_P1`):
> nein: Mangel 2

- **26.11., 09:30**, Werkzeug (`session_W2`):
> Frage: noch offen, soll X oder Y?

- **26.11., 09:40**, Prüfer (`session_P1`):
> Hinweis: letzte Rückmeldung

**Antwort Sokrates zu 9600-Ü2 (26.11., 09:14):** nimm Y.

## Übergaben

| Ü | an | was | seit | Zustand |
|---|---|---|---|---|
| 9600-Ü1 | Prüfer | prüfen: „fertig“ (Rückmeldung 26.11., 09:20 von Werkzeug) | 26.11., 09:20 | erledigt 26.11., 09:25 session_P1 |
| 9600-Ü2 | Sokrates | Frage W1 | 26.11., 09:12 | erledigt 26.11., 09:14 session_S |
| 9600-Ü3 | Sokrates | Frage W2: X oder Y | 26.11., 09:30 | offen |
| 9600-Ü4 | Werkzeug | Antwort zu Frage W1: nimm Y | 26.11., 09:14 | erledigt 26.11., 09:15 session_W1 |
"""

def von(z, nr): return "Werkzeug"

rm._ARCHIV.clear(); rm._ARCHIV["archiv/9600.md"] = ""
vor = rm.zaehlen(T)
neu, arch = ue.aufraeumen(T, "", "9600", von)
rm._ARCHIV["archiv/9600.md"] = arch
r = ue.abschnitt(neu, "Rückmeldungen")
bl = [m.group("text") for m in rm.BLOCK.finditer(r)]
soll("(1) nur letzte Rückmeldung und offene Frage bleiben", bl == ["Frage: noch offen, soll X oder Y?", "Hinweis: letzte Rückmeldung"], bl)
soll("(1) neuester Zustand bleibt, älterer raus", "Zustand: aufgehoben 26.11., 09:56" in r and "Zustand: aufgehoben 25.11., 21:00" not in neu, r)
soll("(1) erledigte Übergaben raus, offene bleibt", "| 9600-Ü1 |" not in neu and "| 9600-Ü2 |" not in neu and "| 9600-Ü3 | Sokrates | Frage W2: X oder Y | 26.11., 09:30 | offen |" in neu, neu)
soll("(1) beantwortete Antwort raus", "nimm Y" not in neu, neu)
soll("(1) Auftrag und Chefworte bleiben", "**Ziel:** neu" in neu and "**Ziel:** alt" not in neu and ue.abschnitt(neu, "Chefworte") == ue.abschnitt(T, "Chefworte"), neu)
weg = [z for z in T.splitlines() if z.strip() and z not in neu.splitlines() and z not in arch.splitlines()]
soll("(2) jede entfernte Zeile wörtlich im Archiv", not weg, weg)
soll("(2) erledigte Zeile voll im Archiv", "| 9600-Ü1 | Prüfer | prüfen: „fertig“ (Rückmeldung 26.11., 09:20 von Werkzeug) | 26.11., 09:20 | erledigt 26.11., 09:25 session_P1 |" in arch, arch)
soll("(4) Zählung gleich (Datei + Archiv)", rm.zaehlen(neu) == vor, (rm.zaehlen(neu), vor))
soll("(4) Zählung findet Archiv auch ohne „# NR ·“-Kopf", rm.zaehlen(neu.replace("# 9600 · Probe", "# Vorgang 9600")) == vor,
     rm.zaehlen(neu.replace("# 9600 · Probe", "# Vorgang 9600")))
n2, a2 = ue.aufraeumen(neu, arch, "9600", von)
soll("zweites Aufräumen ändert nichts", n2 == neu and a2 == arch, (n2, a2[-300:]))

# Laufbremse: zwei „nein“ ins Archiv, das dritte (neue) zählt als drittes
t3 = neu.rstrip("\n").replace("\n## Übergaben", "\n- **26.11., 09:50**, Prüfer (`session_P1`):\n> nein: Mangel 3\n\n## Übergaben", 1) + "\n"
n3, a3 = ue.aufraeumen(t3, arch, "9600", von)
rm._ARCHIV["archiv/9600.md"] = a3
soll("Laufbremse: drittes Nein nach Verschieben zählt 3", rm.zaehlen(n3)["nein"] == 3 and "Mangel 1" not in n3, (rm.zaehlen(n3), n3))

# Frage beantwortet nur durch neuere Auftragsfassung, Chefwort oder erledigte Übergabe an den Fragenden (Auftrag 10:10)
t5 = T.replace("| 9600-Ü4 | Werkzeug |", "| 9600-Ü4 | Sokrates |")
n5, _ = ue.aufraeumen(t5, "", "9600", von)
soll("Frage ohne erledigte Übergabe an den Fragenden bleibt (Antwort-Text, Übergabe an Sokrates zählen nicht)", "beantwortet durch erledigte" in n5, n5)
t6 = t5.replace("## Chefworte\n", "## Chefworte\n\n- **26.11., 09:13**, Chef an Alter Ego:\n> Nimm Y.\n", 1)
n6, _ = ue.aufraeumen(t6, "", "9600", von)
soll("Frage mit späterem Chefwort ist beantwortet", "beantwortet durch erledigte" not in n6, n6)
rm._ARCHIV["archiv/9600.md"] = arch

# (3) Ü-Nummer zählt das Archiv mit
k = ue.naechste_k("9600", neu, arch) if hasattr(ue, "naechste_k") else None
soll("(3) nächste Ü-Nummer über Datei + Archiv", k == "9600-Ü5", k)
# annehmen/erledigt: Zeile nur im Archiv gilt als erledigt
try: z = ue._finde(neu, "9600-Ü1", arch)
except Exception as e: z = {"z": repr(e)}
soll("Zeile nur im Archiv: _finde liefert sie (erledigt)", z["z"].startswith("erledigt"), z)
soll("Dedupe Sokrates-Zeile liest Archiv", "Frage W1" in ue.zeilen_was(neu, arch, "Sokrates"))

# Merkmale-Wächter für jeden Schreibvorgang (atomar_dateien, auftrag.mit_aufraeumen)
g = getattr(ue, "aufgeraeumt", None)
t4, a4 = g(T, "", "9600", von) if g else (T, "")
soll("aufgeraeumt: Regel greift beim Schreiben", "| 9600-Ü1 |" not in t4 and "| 9600-Ü1 |" in a4, t4)
# Leser (Auftrag 5 (0), Prüffrage 5): je Leser Ergebnis am vollen Text ohne Archiv = am aufgeräumten Text mit Archiv
import tempfile, guthaben, lauf, probelauf
L = T.replace("## Übergaben", "- **26.11., 09:42**, Kampf (`session_X`):\n> fertig an def5678\n\n- **26.11., 09:45**, Prüfer (`session_P1`):\n> Hinweis: Nachtrag\n\n## Übergaben", 1)
L = L.replace("| 9600-Ü3 | Sokrates |", "| 9600-Ü5 | Arbeitsplaner | Rückläufer (nein des Prüfers): nachbessern | 26.11., 09:26 | offen |\n| 9600-Ü3 | Sokrates |", 1)
rm._ARCHIV["archiv/9600.md"] = ""
lv, la = ue.aufraeumen(L, "", "9600", von)
def _offen(t):  # vorgang.py offen (ue.offen) mit auf die Probedatei gelenktem _alle_dateien (Carla 10:26)
    alt = (ue._alle_dateien, ue._main_zeilen_schliessen)
    ue._alle_dateien, ue._main_zeilen_schliessen = (lambda: iter([("9600", t)])), (lambda: None)
    try: return [(z["k"], nr, wie) for z, nr, wie in ue.offen(still=True)]
    finally: ue._alle_dateien, ue._main_zeilen_schliessen = alt
def leser(t, a):
    rm._ARCHIV["archiv/9600.md"] = a
    d = tempfile.mkdtemp(); os.makedirs(os.path.join(d, "vorgang")); open(os.path.join(d, "vorgang", "9600.md"), "w").write(t)
    return {"naechste_k": ue.naechste_k("9600", t, a), "zaehlen": rm.zaehlen(t), "beleg_als_nein": rm.beleg_als_nein(t),
            "offen_lokal": {r: ue.offen_lokal(r, d) for r in ("Sokrates", "Arbeitsplaner", "Prüfer", "Werkzeug")},
            "nein_unter_bisher": rm.nein_unter_bisher(t), "macher": rm.macher(t, "9600"), "lauf_offen": rm.lauf_offen(t),
            "planer_wartet": ue.planer_wartet(t), "ruecklaeufer_offen": lauf.ruecklaeufer_offen(t), "ruht": rm.ruht(t),
            "offen": _offen(t),
            "fertige_sitzungen": guthaben.fertige_sitzungen([t]), "pruefer_frei": probelauf.pruefer_frei("9600", t),
            "erstes_nein": next((m.group("zeit") for m in rm.BLOCK.finditer(rm.rueck(t)) if "nein" in rm.worte(m.group("text"))), None)}
vor_l, nach_l = leser(L, ""), leser(lv, la)
for k in vor_l: soll("Leser %s vorher = nachher" % k, vor_l[k] == nach_l[k], (vor_l[k], nach_l[k]))
soll("Leserprobe greift: Block von session_X verschoben", "fertig an def5678" not in lv and "session_X" in vor_l["fertige_sitzungen"], (lv, vor_l["fertige_sitzungen"]))
soll("Leserprobe offen: Zeilen gefunden", len(vor_l["offen"]) == 2, vor_l["offen"])

# Sokrates 10:50: ein Block bleibt nur, wenn der Absender genau „Chef“ ist; „Alter Ego in Vertretung“ geht ins Archiv
C = T.replace("## Übergaben", "- **26.11., 09:41**, Alter Ego, Entscheid in Vertretung (Chef 09:40):\n> Vertretung: nimm X\n\n- **26.11., 09:43**, Chef:\n> Chef selbst\n\n- **26.11., 09:44**, Prüfer (`session_P1`):\n> Hinweis: zuletzt\n\n## Übergaben", 1)
cn, ca = ue.aufraeumen(C, "", "9600", von)
soll("Absender „Alter Ego … (Chef …)“ ins Archiv, genau „Chef“ bleibt", "Vertretung: nimm X" not in cn and "Vertretung: nimm X" in ca and "Chef selbst" in cn, cn)
rm._ARCHIV.clear()
print("schlank_2060_test: %s" % ("grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
