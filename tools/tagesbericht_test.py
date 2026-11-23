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
# 1659: Zeile Läufe aus den Zahlen; 1660: Vorrat als Satz
d2 = {"rot": {"24h": (1, 4, __import__("collections").Counter(tom=1), 30.0, 120.0), "7d": (2, 10, None, 60.0, 300.0)}, "lz": "",
      "e1": ["1", "2"], "e7": ["1", "2", "3"], "jetzt": {"1": dict(bereich="E", stand="erledigt"), "2": dict(bereich="E", stand="verworfen"),
                                                       "3": dict(bereich="B", stand="erledigt")}}
T.rotbuch_kurz = lambda: ""
w = T.wirkung_text(d2)
for teil in ("**75 % grün** (3 von 4)", "**30 min in roten Läufen** (25 % der Laufzeit)", "**4,0 Läufe je erledigtem Spielvorgang**", "7 Tage 80 % grün", "Tom 1"):
    if teil not in w: fehler.append("Läufe ohne " + teil)
# 1715: Buildzweige grün, rot, abgebrochen mit verlorener Bauzeit; rot über grün → Systemfrage
L = lambda b, c, mi: dict(head_branch=b, conclusion=c, created_at="x", run_started_at="2026-11-18T10:00:00Z", updated_at="2026-11-18T10:%02d:00Z" % mi)
z = T.bau_zahl([L("claude/build-300", "success", 40), L("claude/build-300", "failure", 30), L("claude/build-301", "failure", 20),
                L("claude/build-301", "cancelled", 25), L("claude/jerry-760", "failure", 10)])
if z != (1, 2, 1, 25.0): fehler.append("bau_zahl %r" % (z,))
if "**1 grün, 2 rot, 1 abgebrochen** (25 min Bauzeit verloren) → **Systemfrage an Spike**" not in T.bau_text(z): fehler.append("bau_text " + T.bau_text(z))
if "Systemfrage" in T.bau_text((2, 2, 0, 0)) or "keine Läufe" not in T.bau_text(None): fehler.append("bau_text Grenze")
d2["rot"]["bau"] = z
if "Buildzweige 24 h" not in T.wirkung_text(d2): fehler.append("wirkung ohne Buildzweige")
# 1739: „Wo stehen wir“ neben „Rest geschätzt“, Zeile Fristen, Umschaltung über tools/1727-SCHARF
import tempfile
T.SCHARF = os.path.join(tempfile.mkdtemp(), "1727-SCHARF")
if T.zeile3({"Rest geschätzt": "x"})[0] != "Rest geschätzt" or T.zeile3({})[0] != "Rest geschätzt": fehler.append("zeile3 vor Umschaltung")
if T.zeile3({"Wo stehen wir": "Block 1"})[:2] != ("Wo stehen wir", "Block 1"): fehler.append("zeile3 Wo stehen wir")
open(T.SCHARF, "w").close()
if T.zeile3({})[0] != "Wo stehen wir" or T.zeile3({"Rest geschätzt": "x"})[0] != "Rest geschätzt": fehler.append("zeile3 nach Umschaltung")
alt_lesen = T.lesen
T.lesen = lambda p: "## Eingaben\n- Wo stehen wir: Block 2 steht\n- Größtes Risiko: Geld\n" if p == "ARBEIT-TAGESBERICHT.md" else alt_lesen(p)
if T.eingaben() != {"Wo stehen wir": "Block 2 steht", "Größtes Risiko": "Geld"}: fehler.append("eingaben %r" % T.eingaben())
T.lesen = alt_lesen
f = {"test": [(6, "Build 301"), (9, "t302")], "fragen": [(4, "1790a"), (1, "1791a")], "ohne_auftrag": ["1800", "1801"], "unveroeff": 12, "release": ("v0.1.900", 3)}
ft = T.fristen_text(f)
for teil in ("Testbitten über 5 Tage **2** (älteste t302, 9 Tage)", "Fragen an dich ohne Antwort **2** (älteste 1790a, 4 Tage)",
             "Vorgänge ohne Auftrag über 1 Tag **2** (1800, 1801)", "**12** Einträge; letztes Release v0.1.900 vor **3 Tagen**"):
    if teil not in ft: fehler.append("Fristen ohne " + teil)
del f["ohne_auftrag"]; f["test"] = []
if "ohne Auftrag" in T.fristen_text(f) or "Testbitten über 5 Tage **0**;" not in T.fristen_text(f): fehler.append("Fristen vor Umschaltung")
echt = T.fristen({}, {})
if not isinstance(echt.get("unveroeff"), int) or not echt.get("release") or "ohne_auftrag" not in echt: fehler.append("fristen am Stand %r" % echt)
os.remove(T.SCHARF)
if "ohne_auftrag" in T.fristen({}, {}): fehler.append("fristen ohne Umschaltung mit Auftragszahl")
print("tagesbericht_test:", "grün" if not fehler else "ROT: " + "; ".join(fehler))
sys.exit(1 if fehler else 0)
