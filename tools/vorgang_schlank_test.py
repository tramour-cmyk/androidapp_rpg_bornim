# 2042 (2), (3), (4) (Chef 26.11., 09:30/09:42): Vorgangsdatei schlank. Erledigte Übergabe eine Zeile „von“, Wortlaut ins Archiv;
# Aufräumen: ältere Auftragsfassungen, ältere Stände, Nachträge, Hinweise, Antworten außer der letzten ins Archiv; Zählung gleich.
# Aufruf: python3 tools/vorgang_schlank_test.py
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uebergabe as ue, rueckmeldung as rm

fehl = 0
def soll(name, ok, zeige=""):
    global fehl; fehl += not ok; print(("ok  " if ok else "FEHL"), name, ("" if ok else zeige))

LANG = "nein. " + "Mangel " * 80 + "Beleg fehlt am Ende"
T = """# 9500 · Probe

## Auftrag (26.11., 09:00)

1. **Ziel:** neu

## Auftrag (25.11., 20:00)

1. **Ziel:** alt

## Chefworte

- **25.11., 19:00**, Chef an Alter Ego:
> Mach das.

## Messung 1: Probe

| a | b |

## Stand Anna (25.11., 21:00)

- alter Stand

## Stand Berta (26.11., 09:10)

- neuer Stand

## Rückmeldungen

Wörtlich, mit Zeit; trägt `vorgang.py rueckmeldung` ein (1763).

- **25.11., 20:30**, Prüfer (`session_P1`):
> Beleg fehlt: Bild

- **25.11., 20:40**, Prüfer (`session_P1`):
> Beleg fehlt: Film

- **26.11., 09:20**, Prüfer (`session_P1`):
> %s

## Übergaben

| Ü | an | was | seit | Zustand |
|---|---|---|---|---|
| 9500-Ü1 | Prüfer | prüfen: „fertig“ (Rückmeldung 25.11., 20:10 von Werkzeug): langer Text | 25.11., 20:10 | erledigt 25.11., 20:30 session_P1 |
| 9500-Ü2 | Sokrates | steckt fest: Übergabe 9500-Ü1 an Prüfer zweimal ohne Ergebnis | 25.11., 20:50 | erledigt 25.11., 21:00 session_S |
| 9500-Ü3 | Werkzeug | Rückläufer (nein des Prüfers): nachbessern | 26.11., 09:20 | offen |

## Nachtrag Sokrates 22:36

- Teil 6 genauer.

**Antwort Sokrates zu 9500-Ü1 (25.11., 22:37):** alte Antwort.

## Hinweise Sokrates (25.11., 22:40)

**Antwort Sokrates zu 9500-Ü2 (25.11., 22:50):** neueste Antwort.
""" % LANG

def von(z, nr): return {"9500-Ü2": "Werkzeug"}.get(z["k"])

neu, arch = ue.aufraeumen(T, "", "9500", von)
rm._ARCHIV["archiv/9500.md"] = arch

soll("neueste Auftragsfassung byteweise gleich, ältere raus", "## Auftrag (26.11., 09:00)\n\n1. **Ziel:** neu\n" in neu and "**Ziel:** alt" not in neu, neu)
soll("Chefworte byteweise gleich", ue.abschnitt(neu, "Chefworte") == ue.abschnitt(T, "Chefworte"), neu)
soll("nur letzter Stand bleibt", "neuer Stand" in neu and "alter Stand" not in neu, neu)
soll("Messung, Nachtrag, Hinweise raus", "## Messung" not in neu and "## Nachtrag" not in neu and "Teil 6 genauer" not in neu, neu)
soll("letzte Antwort bleibt, ältere raus", "neueste Antwort" in neu and "alte Antwort" not in neu, neu)
soll("offene Übergabe byteweise gleich", "| 9500-Ü3 | Werkzeug | Rückläufer (nein des Prüfers): nachbessern | 26.11., 09:20 | offen |" in neu, neu)
soll("erledigte Übergabe: von aus dem Text", "| 9500-Ü1 | Prüfer | von Werkzeug | 25.11., 20:10 | erledigt 25.11., 20:30 session_P1 |" in neu, neu)
soll("erledigte Übergabe: von aus Commit (von_fn)", "| 9500-Ü2 | Sokrates | von Werkzeug | 25.11., 20:50 | erledigt 25.11., 21:00 session_S |" in neu, neu)
kurz = [m.group("text") for m in rm.BLOCK.finditer(ue.abschnitt(neu, "Rückmeldungen"))]
soll("lange Rückmeldung ≤400 mit Verweis", len(kurz) == 3 and all(len(k) <= 400 for k in kurz) and kurz[-1].endswith("(voll: archiv/9500.md)"), kurz)
weg = [z for z in T.splitlines() if z.strip() and z not in neu.splitlines() and z not in arch.splitlines()]
soll("jede entfernte Zeile steht im Archiv", not weg, weg)
soll("Zählung gleich (Datei + Archiv)", rm.zaehlen(neu) == rm.zaehlen(T), (rm.zaehlen(neu), rm.zaehlen(T)))
soll("beleg_als_nein gleich (ältere Aufträge aus dem Archiv)", rm.beleg_als_nein(neu) == rm.beleg_als_nein(T) == 1, (rm.beleg_als_nein(neu), rm.beleg_als_nein(T)))
soll("Leser macher/lauf_offen gleich", rm.macher(neu, "9500") == rm.macher(T, "9500") and rm.lauf_offen(neu) == rm.lauf_offen(T))
n2, a2 = ue.aufraeumen(neu, arch, "9500", von)
soll("zweites Aufräumen ändert nichts", n2 == neu and a2 == arch, (n2 == neu, a2 == arch))
soll("Datei kleiner", len(neu) < len(T) // 2 + 300, (len(T), len(neu)))
soll("Dedupe Sokrates-Zeile liest Archiv", "Übergabe 9500-Ü1 an " in ue.zeilen_was(neu, arch, "Sokrates"), ue.zeilen_was(neu, arch, "Sokrates"))

# (2) beim Schreiben: erledigt macht die Zeile schlank, Wortlaut ins Archiv
t3, a3 = ue.schlank_uebergaben(T, "", "9500", von)
soll("schlank_uebergaben: erledigte Zeilen schlank, offene gleich, Wortlaut im Archiv",
     "| 9500-Ü1 | Prüfer | von Werkzeug |" in t3 and "| 9500-Ü3 | Werkzeug | Rückläufer" in t3 and "langer Text" in a3 and "langer Text" not in t3, a3)

print("vorgang_schlank_test: %s" % ("grün" if not fehl else "%d FEHL" % fehl))
sys.exit(1 if fehl else 0)
