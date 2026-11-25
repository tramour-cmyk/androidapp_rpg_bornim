#!/usr/bin/env python3
"""2019 (Sokrates 24.11., 12:35): Routine Wochenzählung läuft montags von selbst, auch unter der Laufsperre. Echter Fall:
Mo 23.11., 08:03 legte nur `lauf.py --sperre` den Wochentermin an (Takt läuft ohne); Zeile 2018 bekam den Blockbesitzer
„Werkzeug“ (Q QM, Block 7) und hing an der Laufsperre „nur Spiel und Eilt“. Erwartet: Termin auch ohne --sperre angelegt,
Zeile trägt die Rolle der Routine, START Wochenzählung mit Profil und Woche, frei unter der Laufsperre.
Aufruf: python3 tools/lauf_2019_test.py"""
import datetime, os, sys, tempfile
H = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, H); sys.argv = sys.argv[:1]
import lauf, startbar, guthaben, vorgang

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else str(zeige)[-1500:]))

KOPF = ("| Nr. | Titel | Block | Bereich | Kl. | wartet auf | Bezug | Zweig | *Stand* | *Sitzung* | *Runde* | *Kosten* |\n"
        "|---|---|---|---|---|---|---|---|---|---|---|---|\n")
Z2018 = ("| 2018 | Wochentermin 23.11.: Wochenzählung (Routine, Auftrag docs/entwurf/1727-muster/routine-wochenzaehlung.md) (719) "
         "| 7 | Q QM | M | – | – | – | *startbar* | *–* | *0* | *–* |\n")
BLOECKE = "| 7 | Firma: Werkzeuge und Abläufe | Werkzeug | nein | – | B Steuerung, B Abläufe, B Werkzeuge, Q QM | – |\n"
docs = tempfile.mkdtemp(prefix="lauf-2019-"); os.makedirs(os.path.join(docs, "chefsache"))
open(os.path.join(docs, "chefsache", "themenbloecke.md"), "w", encoding="utf-8").write(BLOECKE)
open(os.path.join(docs, "LISTE-VORGAENGE.md"), "w", encoding="utf-8").write("# Liste\n\n" + KOPF)
open(os.path.join(docs, "LISTE-VORGAENGE-ARCHIV.md"), "w", encoding="utf-8").write("")
alt_docs = startbar.DOCS; startbar.DOCS = docs

# 1. Zeile 2018 trägt die Rolle der Routine, nicht den Blockbesitzer
zl = startbar.vorgangsliste("# Liste\n\n" + KOPF + Z2018)
d = zl[0] if zl else {}
soll("2018: Besitzer „Wochenzählung“ (nicht Werkzeug aus Block 7)", d.get("besitzer") == "Wochenzählung", d.get("besitzer"))

# 2. Wochentermin am Mo 23.11., 08:03 ohne --sperre angelegt
lauf.JETZT = datetime.datetime(2026, 11, 23, 8, 3, tzinfo=lauf.BERLIN)
neu = []
vorgang.neu = lambda t, ber, kl, wer, *a: (neu.append((t, ber, wer)), "2018")[1]
aus = []
if hasattr(lauf, "wochentermine_anlegen"): lauf.wochentermine_anlegen(aus, scharf=True)
else: aus.append("NICHTS Diogenes: Wochentermin fällig, der Lauf mit --sperre legt ihn an (719)")
soll("Mo 23.11., 08:03 ohne --sperre: Wochentermin Wochenzählung angelegt",
     [x for x in neu if x[0].startswith("Wochentermin 23.11.: Wochenzählung (Routine")] and any("Wochentermin 2018 angelegt" in l for l in aus), (neu, aus))
neu.clear(); aus = []
lauf.JETZT = datetime.datetime(2026, 11, 24, 12, 40, tzinfo=lauf.BERLIN)
if hasattr(lauf, "wochentermine_anlegen"): lauf.wochentermine_anlegen(aus, scharf=True)
soll("Nicht-Montag (Di 24.11.): nichts angelegt, keine Ausgabe", not neu and not aus, (neu, aus))
startbar.DOCS = alt_docs

# 3. START Wochenzählung für 2018 mit Profil und Woche 16.–22.11.
lauf.JETZT = datetime.datetime(2026, 11, 24, 12, 40, tzinfo=lauf.BERLIN)
aus = []
ROOT = os.path.dirname(H)  # lauf.DOCS ist der Notizklon; Test liest das Profil dieses Stands
nr = lauf.rundblick_zeilen(aus, {}, set(), {}, zeilen=[d], scharf=True, wurzel=ROOT, name="Wochenzählung")
st = [l for l in aus if l.startswith("START ")]
soll("START Wochenzählung für 2018", nr == "2018" and st and st[0].startswith("START Wochenzählung |") and "| Wochenzählung – KW 47 – 2018 (" in st[0], aus)  # 2041 d (Chef 25.11., 21:14): „Wochenzählung – KW“
soll("Startnachricht: Woche Mo 16.11. bis So 22.11.", st and "Mo 16.11. bis So 22.11." in st[0], st)
prof = lauf.ladetext("Wochenzählung", os.path.join(ROOT, "docs"))
soll("Startnachricht: Profil docs/profile/Wochenzählung.md (Ladetext)", prof and st and prof.split("\n")[0] in st[0].replace("\\n", "\n"), (prof, st))
soll("Routine ohne Kern und Rufname (ROUTINE_ROLLEN)", "Wochenzählung" in lauf.ROUTINE_ROLLEN and st and lauf.mit_kern(st[0]) == st[0], st)
soll("Rolle für Kosten und Sitzungen: kosten.rolle(„Wochenzählung – 2018: …“)", lauf.kosten.rolle("Wochenzählung – 2018: Routine (24.11., 12:40)") == "Wochenzählung"
     and lauf.kosten.rolle("Wochenzählung – KW 47 – 2018 (24.11., 12:40)") == "Wochenzählung")

# 4. Laufsperre 287 (Form 2001, Wortlaut Archiv 23.11., 14:43) hält Werkzeug an, die Routine nicht
ARCHIV = ("- **287 Laufsperre (Form 2001)** (23.11., 14:43, Chef an Sokrates: „lasst den einen dritten aufmachen“) → **Laufsperre: höchstens "
          "drei Fachkräfte zugleich, nur Spiel, nachts 23–07 keine, spätestens 28.11., 20:00**\n")
b = guthaben.Bremse(datetime.datetime(2026, 11, 24, 12, 40, tzinfo=lauf.BERLIN), "", archiv=ARCHIV, laufend=2)
soll("Laufsperre hält Werkzeug für 2018 an (wie am 23.11.)", b.ober_grund("Werkzeug", d) is not None, b.ober_grund("Werkzeug", d))
soll("Laufsperre hält Wochenzählung nicht an (FREI_OBER)", b.ober_grund("Wochenzählung", d) is None, b.ober_grund("Wochenzählung", d))

print("FEHL: %d" % fehl if fehl else "alle ok")
sys.exit(1 if fehl else 0)
