#!/usr/bin/env python3
"""1647: keine Tabellenzeile des Tagesberichts über 400 Zeichen (169); Zeile 5 behält den Anfang, der Rest steht unter der Tabelle."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tagesbericht as T

lang5 = ("Änderungen warten auf deinen Test: **14** (Tom 4, Jerry 10); rote Läufe 24 h **5 von 9** (Jerry 1, beim Bau eines Test-Builds 4), "
         "7 Tage 101 von 186; rote Tests 48 h: wolf_mess_438 8×, tod_ragdoll_1215 4×, arkan_993 3×, biss_1284 3×, reihe_1305 3×, rand_1022 2×; "
         "APK-Läufe 24 h: **9**, Ø **46 min** (min 25, max 82), vorgerendert **7 von 9** (Ø 39 min, mit Neubau 71 min)")
lang8 = ("seit dem letzten Bericht (17.11., 07:42): Ford hing zwei Stunden und keiner meldete es (17:02, 1572); der weiße Streifen an der Wache "
         "war entgegen der Meldung noch da (21:45, 1515); der Feuerzauber beginnt hinter dem Kopf statt am Stab (21:40, 385.2); die Arbeit lief "
         "wieder nur auf zwei Entwickler zu, obwohl drei da waren und keiner es sah. Zweiter Satz.")
z = [("Z%d" % i, "kurz", "") for i in range(11)]
z[4] = ("Builds", lang5, "bei dir zum Testen: Build 298; ein Build nimmt alle fertigen Zweige (317)")
z[7] = ("Von dir zuerst gefunden", lang8, "Woche, zählt Diogenes montags")
T.zeilen = lambda d: z
d = {"rollen": {}, "erl_rolle": lambda e, r: 0, "e1": [], "e7": []}
md = T.zahlen_md(d)
fehler = [l[:40] + " (%d)" % len(l) for l in md.splitlines() if l.startswith("|") and len(l) > 400]
z5 = next(l for l in md.splitlines() if l.startswith("| 5 |"))
if "**5 von 9**" not in z5 or "weiter unter der Tabelle" not in z5: fehler.append("Zeile 5 Anfang fehlt: " + z5[:80])
if "- Zeile 5 (Builds), weiter:" not in md or "Ø **46 min**" not in md: fehler.append("Rest von Zeile 5 nicht unter der Tabelle")
if "ganz unter „Eingaben“" not in next(l for l in md.splitlines() if l.startswith("| 8 |")): fehler.append("Zeile 8 ohne Hinweis")
print("tagesbericht_test:", "grün" if not fehler else "ROT: " + "; ".join(fehler))
sys.exit(1 if fehler else 0)
