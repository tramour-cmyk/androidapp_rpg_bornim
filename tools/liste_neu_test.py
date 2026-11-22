#!/usr/bin/env python3
"""1893: Leser und Schreiber der umgestellten Vorgangsliste (Kopf ohne Besitzer) in startbar.py, alte Liste unverändert."""
import os, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import startbar

FEHL = 0
def soll(name, ok, info=""):
    global FEHL
    print(("ok   " if ok else "FEHL ") + name + ("" if ok else " %r" % (info,)))
    FEHL += not ok

A = tempfile.mkdtemp()
os.makedirs(os.path.join(A, "chefsache")); os.makedirs(os.path.join(A, "vorgang"))
open(os.path.join(A, "chefsache", "themenbloecke.md"), "w").write(
    "# Themenblöcke\n\n| Nr. | Themenblock | Fachprofil | Kapitel 1 | ruht bis | Bereiche | Vorgänge |\n|---|---|---|---|---|---|---|\n"
    "| 4 | Kataloge | Kataloge | ja | – | – | 458 |\n| 6 | Technik | Technik | ja | – | E Technik, Q QS | – |\n"
    "| 7 | Firma | Werkzeug | nein | – | B Werkzeuge | – |\n| 8 | Marktstart | – | nein | – | M Markt | – |\n")
open(os.path.join(A, "vorgang", "1484.md"), "w").write("# 1484\n\n## Herkunft\n\n- Build: –\n\n## Build\n- Build: 301\n")
startbar.DOCS = A
Z1 = "| 1484 | Welt 9–10 Bilder/s | 6 | E Technik | M | 1270.6 | 1270 | – | *startbar* | *–* | *0* | *3,10 $* |"
Z2 = "| 513 | Ein Figurenstand | 4 | E Kataloge | Eilt | 23.11. | – | claude/figurenstand-513 | *ruht* | *–* | *0* | *14,01 $* |"
Z3 = "| 458.3 | Gegenstandskatalog | 4 | E Kataloge | K | – | 458 | – | *gebaut, Geprüft an: 6434b312c* | *–* | *0* | *–* |"
Z4 = "| 45 | Geschäftsmodell | 8 | M Markt | K | – | – | – | *nach Meilenstein* | *–* | *0* | *–* |"
neu = "# Vorgänge\n\n" + startbar.KOPF_NEU + "\n|" + "---|" * 12 + "\n" + "\n".join([Z1, Z2, Z3, Z4]) + "\n"
zs = startbar.vorgangsliste(neu)
soll("neue Liste erkannt", startbar.NEU is True and len(zs) == 4, (startbar.NEU, len(zs)))
d = {x["nr"]: x for x in zs}
soll("Besitzer = Fachprofil des Blocks", d["1484"]["besitzer"] == "Technik" and d["458.3"]["besitzer"] == "Kataloge", d["1484"]["besitzer"])
soll("Block ohne Fachprofil: Arbeitsplaner", d["45"]["besitzer"] == "Arbeitsplaner", d["45"]["besitzer"])
soll("Stand ohne Kursiv, Wort gelesen", d["458.3"]["stand"].startswith("gebaut") and d["458.3"]["wort"] == "gebaut", d["458.3"]["stand"])
soll("Eilt zählt als Muss mit Marke", d["513"]["kl"] == "M" and d["513"]["eilt"] and startbar.jetzt_zeile(d["513"]), d["513"])
soll("Build aus der Vorgangsdatei (letzte Zeile)", d["1484"]["build"] == "301" and d["458.3"]["build"] == "–", d["1484"]["build"])
soll("wartet auf als Liste", d["1484"]["warte"] == ["1270.6"], d["1484"]["warte"])
soll("Schreiber gibt die Zeile unverändert zurück", all(startbar.zeile_text(d[n]) == z for n, z in (("1484", Z1), ("513", Z2), ("458.3", Z3), ("45", Z4))),
     [startbar.zeile_text(d[n]) for n in ("1484", "513")])
soll("Block aus Unternummer (458.3 → 4)", startbar.block_von("458.3", "E Figuren") == "4")
soll("Block aus Bereich, sonst 9", startbar.block_von("1999", "B Werkzeuge") == "7" and startbar.block_von("1999", "E Welt") == "9")
x = dict(d["1484"], bereich="B Werkzeuge", block=None, kosten="–", stand="in Arbeit")
soll("neue Zeile: Block gerechnet, Rechenfelder kursiv", startbar.zeile_text(x) == "| 1484 | Welt 9–10 Bilder/s | 7 | B Werkzeuge | M | 1270.6 | 1270 | – | *in Arbeit* | *–* | *0* | *–* |", startbar.zeile_text(x))
f = startbar.pruefen_zeile(dict(d["1484"]), None)
soll("Formprüfung: 12 Spalten, Profil gültiger Besitzer", not [e for e in f if "Spalten" in e or "Besitzer" in e], f)
soll("Profile in BESITZER und WARTE_ROLLEN", all(p in startbar.BESITZER for p in ("Technik", "Disponent", "Prüfer")) and startbar.art("Prüfer") == "rolle")
soll("Schleife je Besitzer: Profile ohne Vorrat", [r for _, r in startbar.besitzer_reihe()][:3] == ["Arbeitsplaner", "Kataloge", "Technik"] and startbar.besitzer_reihe()[0][0] is None,
     startbar.besitzer_reihe()[:3])
soll("Tafel liest die neue Liste (Archiv-Leser)", [t["nr"] for t in startbar.tafel_zeilen(neu)] == ["1484", "513", "458.3", "45"])

import lauf  # 1893: lauf.py an der neuen Liste
startbar.vorgangsliste(neu)
soll("lauf: Start je Profil ohne Disponent, Planer Arbeitsplaner", lauf.neue_liste() and "Technik" in lauf.START_REIHE
     and "Disponent" not in lauf.START_REIHE and lauf.PLANER == "Arbeitsplaner" and lauf.MIT_KUER == set(lauf.START_REIHE), lauf.START_REIHE)
soll("lauf: Profil ohne Vorrat (Nachfolger, Hintergrundlauf)", lauf.nachfolger("Technik")[0] is None and lauf.lauf_laeuft("Technik") is None
     and lauf.lauf_marke_falsch("Technik") == [])
soll("lauf: Nachricht nennt Vorgangsdatei statt Vorrat", "docs/vorgang/1484.md" in lauf.vorrat_hinweis("Technik", "1484"))
_k = lauf.mit_kern("START Technik | opus | e | r | main | T | Technik\\n\\nArbeite 1484; zuerst Start nach deiner Rollendatei, dann x.")
soll("lauf: ohne Ladetext kein Verweis auf die Rollendatei", "Rollendatei" not in _k and _k.endswith("zuerst x."), _k)
startbar.DOCS = A; open(os.path.join(A, "LISTE-VORGAENGE.md"), "w").write(neu); startbar._LISTE = None
_docs = lauf.DOCS; lauf.DOCS = A  # 1893 (Sokrates 08:33): Aufträge für Zeilen ohne „## Auftrag“ schreibt der Arbeitsplaner
open(os.path.join(A, "vorgang", "513.md"), "w").write("# 513\n\n## Auftrag (22.11., 08:00)\n\nunvollständig\n")
_st = {"Technik": ([("1484", "M", "Welt", {})], [], None, []), "Kataloge": ([("513", "M", "Figurenstand", {})], [("458.3", "K", "Katalog", {})], None, []),
       "Arbeitsplaner": ([("M?", "M", "M? entscheiden", {})], [("45", "K", "Geschäftsmodell", {})], None, [])}
_a = lauf.auftrag_zeilen(_st, 9)
soll("lauf: Auftrag-Zeilen Eilt, Muss vor Kür, Zeilenfolge, ohne M?", [x[3]["auftrag_fuer"] for x in _a] == ["513", "1484", "458.3", "45"], [x[3] for x in _a])
soll("lauf: Auftrag-Zeile nennt Profil und Grund", _a[1][0] == "Auftrag" and "(Technik, kein Auftrag)" in _a[1][2] and "(Kataloge, Auftrag:" in _a[0][2], _a[:2])
soll("lauf: höchstens AUFTRAG_PLANER zugleich", len(lauf.auftrag_zeilen(_st)) == lauf.AUFTRAG_PLANER == 1)
lauf.DOCS = _docs
# 1893 Teil 3: übrige Werkzeuge an der neuen Liste
import startwarnung, rotbuch, chefwort
soll("startwarnung: Rolle → Profil", [startwarnung.profil(r) for r in ("Ford", "Perikles", "Diogenes", "Tom")] == ["Disponent", "Arbeitsplaner", "Prüfer", "Arbeitsplaner"])
_sl = startwarnung.stand_laden; _sz = startwarnung.zeige; _ss = startwarnung.sammeln
startwarnung.stand_laden = lambda *a: {"969:x": {"vorgang": "1484"}}; startwarnung.zeige = lambda ref, p: neu
startwarnung.sammeln = lambda taeglich=True: [dict(schluessel="969:x", besitzer="Arbeitsplaner", code="969", text="t")]
import io, contextlib
_o = io.StringIO()
with contextlib.redirect_stdout(_o): startwarnung.zeigen(True)
soll("startwarnung: Anzeige nennt Profil des Vorgangs", "Besitzer Technik, Vorgang 1484" in _o.getvalue(), _o.getvalue())
startwarnung.stand_laden, startwarnung.zeige, startwarnung.sammeln = _sl, _sz, _ss
soll("startwarnung: Besitzer der Nummer = Profil", startwarnung.besitzer_nr("1484", neu) == "Technik", startwarnung.besitzer_nr("1484", neu))
startbar.DOCS = A  # lauf.py setzt DOCS auf die Notizkopie
open(os.path.join(A, "LISTE-VORGAENGE.md"), "w").write(neu); startbar._LISTE = None
soll("rotbuch: Bereich aus der Nummer im Testnamen", rotbuch.ziel("tests/probe_513.gd") == ("Kataloge", "E Kataloge"), rotbuch.ziel("tests/probe_513.gd"))
soll("rotbuch: ohne Nummer Technik", rotbuch.ziel("tests/probe.gd") == ("Technik", "E Technik"), rotbuch.ziel("tests/probe.gd"))
open(os.path.join(A, "LISTE-VORGAENGE-ARCHIV.md"), "w").write("| Nr. | Vorgang | Bereich | Kl. | Kosten | Vorrat | Stand |\n|---|---|---|---|---|---|---|\n"
                                                     "| 1777 | Erledigte Mutter | E Technik | M | – | Spike | erledigt |\n")
soll("rotbuch: Nummer nur im Archiv (erledigte Mutter)", rotbuch.ziel("tests/probe_1777.gd") == ("Technik", "E Technik"), rotbuch.ziel("tests/probe_1777.gd"))
soll("rotbuch: Archiv-Zeile mit Block und Profil", (rotbuch.zeile_von_nr("1777", archiv=True) or {}).get("block") == "6" and rotbuch.zeile_von_nr("1777") is None)
import liegt, datetime, zoneinfo  # 1893: lauf.py gibt JETZT mit Zeitzone
_j = datetime.datetime(2026, 11, 24, 9, 0, tzinfo=zoneinfo.ZoneInfo("Europe/Berlin"))
try: _l = liegt.zeilen(startbar.vorgangsliste(neu), [0] * 20, _j, None, lambda c: True); _ok = any(x.startswith("LIEGT 513 | ruht") for x in _l)
except TypeError as e: _l, _ok = str(e), False
soll("liegt: JETZT mit Zeitzone (lauf.py) bricht nicht ab", _ok, _l)
startbar._LISTE = None
soll("chefwort: Profil-Kopf ist keine Chefnachricht", chefwort.vom_chef("**Technik** [22.11., 09:00] Stand") is False)
startbar.NEU = None

alt_z = "| 1484 | Welt | Spike | M | startbar | 1270.6 | – | – | E Technik | 3,10 $ |"
alt = "# Vorgänge\n\n" + startbar.KOPF + "\n|" + "---|" * 10 + "\n" + alt_z + "\n"
za = startbar.vorgangsliste(alt)
soll("alte Liste weiter gelesen", startbar.NEU is False and za[0]["besitzer"] == "Spike" and "eilt" not in za[0], za)
soll("alte Liste weiter geschrieben", startbar.zeile_text(za[0]) == alt_z, startbar.zeile_text(za[0]))
soll("alte Schleife je Rolle", startbar.besitzer_reihe() == startbar.ROLLEN)

print("liste_neu_test: " + ("alles grün" if not FEHL else "%d FEHL" % FEHL))
sys.exit(1 if FEHL else 0)
