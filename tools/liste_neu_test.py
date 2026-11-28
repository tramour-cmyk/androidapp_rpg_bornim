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
# 1897 (D338.3): Auftrag nach Klasse eingereiht, nie Auftrag zu Kür vor eigenes Muss des Planers
_pl = ([("1484", "M", "eigenes Muss", {"nr": "1484"})], [("45", "K", "eigene Kür", {"nr": "45"})], None, [])
lauf.auftrag_einreihen(_pl, [("Auftrag", "K", "Auftrag 458.3", {"auftrag_fuer": "458.3"}), ("Auftrag", "M", "Auftrag 513", {"auftrag_fuer": "513"})])
soll("Planer: Auftrag zu Kür hinter eigenes Muss, Eilt-Auftrag vor eigenes Muss (M? fällt, 1871)",
     [x[0] for x in _pl[0]] == ["Auftrag", "1484"] and _pl[0][0][3]["auftrag_fuer"] == "513"
     and [x[3].get("auftrag_fuer", x[0]) for x in _pl[1]] == ["458.3", "45"], (_pl[0], _pl[1]))
# 1871 Stilllegung C (g): M? geht als Zeile KLASSE an den Disponenten, keine Muss-Zeile „M? entscheiden“ beim Planer
Z5 = "| 1900 | Probe Klasse | 6 | E Technik | M? | – | – | – | *startbar* | *–* | *0* | *–* |"
open(os.path.join(A, "LISTE-VORGAENGE.md"), "w").write(neu.rstrip("\n") + "\n" + Z5 + "\n"); startbar._LISTE = None
_m = lauf.stand()
soll("1871: M? ohne Muss-Zeile beim Planer, gesammelt für KLASSE", not [x for r in _m for x in _m[r][0] if x[0] == "M?"]
     and any(f.startswith("1900 (") for f in lauf.M_FRAGEN), (lauf.M_FRAGEN, {r: [x[0] for x in _m[r][0]] for r in _m}))
open(os.path.join(A, "LISTE-VORGAENGE.md"), "w").write(neu); startbar._LISTE = None; lauf.M_FRAGEN[:] = []
soll("1871: Kostenschwelle und Kosten auf fallen", not hasattr(startbar, "kosten_offen") and not hasattr(lauf, "kosten_auf") and not hasattr(lauf, "sokrates_ziel"))
_k = [x for x in lauf.auftrag_zeilen(_st, 9)]
soll("Auftrag-Zeile trägt die Klasse ihrer Zeile", [x[1] for x in _k] == ["M", "M", "K", "K"], [x[1] for x in _k])
# 1932 (Archiv 1727j Frage 16, Chef 22.11., 12:06): Eilt, Funde des Chefs, Muss reihum je Fachprofil, Kür nach Liegezeit; bis zu 2 Planer
_st2 = {"Technik": ([("2001", "M", "a", {}), ("2002", "M", "b", {}), ("2003", "M", "c", {})], [("2010", "K", "k1", {})], None, []),
        "Welt": ([("2004", "M", "d", {}), ("2005", "M", "e", {"titel": "Von Chef (18.11., 14:34, Fund, Build 298): x", "stand": "startbar"})], [("2011", "K", "k2", {})], None, []),
        "Kataloge": ([("513", "M", "eilt", {})], [], None, []), "Arbeitsplaner": ([], [], None, [])}
_lz = lauf._liegezeiten; lauf._liegezeiten = lambda: {"2010": 200, "2011": 100}
_a2 = [x[3]["auftrag_fuer"] for x in lauf.auftrag_zeilen(_st2, 99)]
soll("1932/1967: Folge Eilt, Fund, Muss (gleicher Block: Listenfolge, dann Nr.), Kür älteste zuerst", _a2 == ["513", "2005", "2001", "2002", "2003", "2004", "2011", "2010"], _a2)
# 1967 (Chef 22.11., 17:43, 17:46): Schlüssel (Klasse, Blockrang, Rest); Blockrang = Zeilenfolge in chefsache/themenbloecke.md, nicht Nummer
_tb = os.path.join(A, "chefsache", "themenbloecke.md"); _tb_alt = open(_tb).read()
open(_tb, "w").write("| Nr. | Themenblock | Fachprofil | Kapitel 1 | ruht bis | Bereiche | Vorgänge |\n|---|---|---|---|---|---|---|\n"
    "| 10 | Regeln | Regeln | ja | – | G Regeln | – |\n| 2 | Kampf | Kampf | ja | – | E Kampf | – |\n| 5 | Klang | Klang | ja | – | E Klang | – |\n")
_st3 = {"Klang": ([("3001", "M", "e5", {"eilt": True, "bereich": "E Klang"}), ("3011", "M", "m5", {"bereich": "E Klang"})],
                  [("3021", "K", "k5", {"bereich": "E Klang"})], None, []),
        "Kampf": ([("3002", "M", "e2", {"eilt": True, "bereich": "E Kampf"}), ("3012", "M", "m2", {"bereich": "E Kampf"})],
                  [("3022", "K", "k2a", {"bereich": "E Kampf"}), ("3023", "K", "k2b", {"bereich": "E Kampf"}), ("3031", "N", "n2", {"bereich": "E Kampf"})], None, []),
        "Regeln": ([("3003", "M", "e10", {"eilt": True, "bereich": "G Regeln"}),
                    ("3013", "M", "f10", {"titel": "Von Chef (22.11., 17:00, Fund, Build 300): x", "bereich": "G Regeln"})],
                   [("3024", "K", "k10", {"bereich": "G Regeln"}), ("3032", "N", "n10", {"bereich": "G Regeln"})], None, [])}
lauf._liegezeiten = lambda: {"3021": 50, "3022": 300, "3023": 100, "3024": 400}
_o3 = lauf.auftrag_offen(_st3)
_g = lambda k: [o[2] for o in _o3 if o[0] == k]
soll("1967: drei Eilt aus Block 5, 2, 10 → 10, 2, 5 (Zeilenfolge der Themenblöcke)", _g(0) == ["3003", "3002", "3001"], _g(0))
soll("1967: Block 10 nur Fund und Kür, Block 2 Muss → Muss aus 2 vor Muss aus 5, vor jeder Kür", _g(2) == ["3012", "3011"]
     and max(i for i, o in enumerate(_o3) if o[0] == 2) < min(i for i, o in enumerate(_o3) if o[0] == 3), _g(2))
soll("1967: Eilt aus Block 5 vor Fund aus Block 10 vor jedem Muss", [o[2] for o in _o3][:4] == ["3003", "3002", "3001", "3013"], [o[2] for o in _o3])
soll("1967: Kür in Blockfolge, im Block älteste zuerst; nach dem Meilenstein in Blockfolge",
     _g(3) == ["3024", "3023", "3022", "3021"] and _g(4) == ["3032", "3031"], (_g(3), _g(4)))
open(_tb, "w").write(_tb_alt)
lauf.AUFTRAG_IN_ARBEIT.add("513")
soll("1932: Auftrag in Arbeit fällt weg", lauf.auftrag_zeilen(_st2)[0][3]["auftrag_fuer"] == "2005", lauf.auftrag_zeilen(_st2))
lauf.AUFTRAG_IN_ARBEIT.clear()
soll("1932: ein Planer bis 10 dringende ohne Auftrag", lauf.planer_zahl(_st2) == 1 and lauf.ZWEITER_PLANER_AB == 10 and lauf.MAX_PLANER == 2)
_ab = lauf.ZWEITER_PLANER_AB; lauf.ZWEITER_PLANER_AB = 3
soll("1932: zwei Planer über der Schwelle (6 dringende > 3)", lauf.planer_zahl(_st2) == 2)
_fn = (lauf.ist_scharf, lauf.nacht_halt, lauf.umgebung)
lauf.ist_scharf = lambda *a: True; lauf.nacht_halt = lambda *a: False; lauf.umgebung = lambda r, h=False: "env_x"
_au = ["START Arbeitsplaner | opus | env_x | r | main | Arbeitsplaner – Auftrag 513 (22.11., 12:00) | x"]; _sp = []; _sn = {}
lauf.zweiter_planer(_au, _st2, {}, set(), {}, None, _sp, _sn, [])
soll("1932: zweiter Planer startet mit dem nächsten Auftrag, den keiner schreibt", len(_au) == 2 and "| Arbeitsplaner 2 – Auftrag 2005 (" in _au[1]
     and _au[1].startswith("START Arbeitsplaner |") and _sp == ["Arbeitsplaner"] and _sn == {"Arbeitsplaner": "2005"}, _au[1:])
_au = ["START Arbeitsplaner | opus | env_x | r | main | Arbeitsplaner – Auftrag 513 (22.11., 12:00) | x"]
_jr = {"Arbeitsplaner": [{"id": "s1", "_info": ("Arbeitsplaner", True, 5, [])}]}
lauf.zweiter_planer(_au, _st2, _jr, set(), {}, None, [], {}, [])
soll("1932: nie mehr als zwei Planer", len(_au) == 1, _au)
_au = []
lauf.zweiter_planer(_au, _st2, {}, set(), {}, None, [], {}, [])
soll("1932: ohne ersten Planer kein zweiter", _au == [], _au)
lauf.ZWEITER_PLANER_AB = _ab
_au = ["START Arbeitsplaner | opus | env_x | r | main | Arbeitsplaner – Auftrag 513 (22.11., 12:00) | x"]
lauf.zweiter_planer(_au, _st2, {}, set(), {}, None, [], {}, [])
soll("1932: unter der Schwelle kein zweiter", len(_au) == 1, _au)
lauf.ist_scharf, lauf.nacht_halt, lauf.umgebung = _fn; lauf._liegezeiten = _lz
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
# 1895 (D338.1): weiter-haken.py schickt wie lauf.py nur auf Zeilen mit gültigem Auftrag, die Planer-Sitzung „Auftrag“ nie weiter
_stand, _fehlt, _scharf, _nl = lauf.stand, lauf.auftrag_fehlt, lauf.ist_scharf, lauf.neue_liste
lauf.neue_liste = lambda: True; lauf.ist_scharf = lambda: True
lauf.auftrag_fehlt = lambda nr, docs=None, titel=None: None if nr in ("458.3",) else "kein Auftrag"
lauf.stand = lambda: {"Kataloge": ([("513", "M", "x", {})], [("458.3", "K", "y", {})], None, []),
                      "Arbeitsplaner": ([("Auftrag", "M", "Auftrag schreiben für 513", {})], [("45", "K", "z", {})], None, []),
                      "Technik": ([("1484", "M", "w", {})], [], "23.11.", [])}
soll("haken: oberste Zeile mit gültigem Auftrag (513 ohne → 458.3)", lauf.haken_naechste("Kataloge") == "458.3", lauf.haken_naechste("Kataloge"))
soll("haken: nie Zeile „Auftrag“, ohne Auftrag nichts", lauf.haken_naechste("Arbeitsplaner") is None, lauf.haken_naechste("Arbeitsplaner"))
soll("haken: Pause hält an", lauf.haken_naechste("Technik") is None)
lauf.ist_scharf = lambda: False
soll("haken: ohne Schalter wie bisher (513)", lauf.haken_naechste("Kataloge") == "513")
lauf.stand, lauf.auftrag_fehlt, lauf.ist_scharf, lauf.neue_liste = _stand, _fehlt, _scharf, _nl
import importlib.util
_sp = importlib.util.spec_from_file_location("weiter_haken", os.path.join(os.path.dirname(os.path.abspath(__file__)), "weiter-haken.py"))
_wh = importlib.util.module_from_spec(_sp); _in = sys.stdin; sys.stdin = io.StringIO("")
try: _sp.loader.exec_module(_wh)
finally: sys.stdin = _in
_msg = "Ladetext Arbeitsplaner\n" + "x" * 400 + "\n\nAuftrag: Arbeitsplaner\n\nAuftrag schreiben für 513 (Kataloge, kein Auftrag): Figurenstand (`vorgang.py auftrag 513`)"
soll("haken: Planer-Sitzung „Auftrag“ erkannt, auch hinter langem Ladetext", bool(_wh.AUFTRAG_SITZUNG.search(_msg))
     and not _wh.AUFTRAG_SITZUNG.search("Arbeitsplaner\n\nM? entscheiden: 1 (Technik)"))
# 1896 (D338.2): Planer-Start „Auftrag“ zählt unter der Nummer des Auftrags (Startsperre, Nachtdeckel 1643)
import nachtstarts
_ang = nachtstarts.angehalten; nachtstarts.angehalten = lambda r, n: (r, n) == ("Arbeitsplaner", "513")
_z = lauf.sperr_nummer("Auftrag", {"auftrag_fuer": "513"}); _aus, _mo = [], []
soll("Nachtdeckel: Auftrag zählt unter 513", _z == "513" and lauf.nacht_halt("Arbeitsplaner", _z, _aus, _mo) and "513" in _aus[0], (_z, _aus))
soll("Nachtdeckel: andere Zeilen unverändert", lauf.sperr_nummer("1484", {}) == "1484" and lauf.sperr_nummer("M?", {}) == "M?")
nachtstarts.angehalten = _ang
_src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "lauf.py"), encoding="utf-8").read()
soll("Startschleife nutzt sperr_nummer für Deckel und Sperre", "nacht_halt(r, zaehl_nr, ausgabe, morgen)" in _src and "sperr_nr[r] = zaehl_nr" in _src)
startbar.NEU = None

alt_z = "| 1484 | Welt | Spike | M | startbar | 1270.6 | – | – | E Technik | 3,10 $ |"
alt = "# Vorgänge\n\n" + startbar.KOPF + "\n|" + "---|" * 10 + "\n" + alt_z + "\n"
za = startbar.vorgangsliste(alt)
soll("alte Liste weiter gelesen", startbar.NEU is False and za[0]["besitzer"] == "Spike" and "eilt" not in za[0], za)
soll("alte Liste weiter geschrieben", startbar.zeile_text(za[0]) == alt_z, startbar.zeile_text(za[0]))
soll("alte Schleife je Rolle", startbar.besitzer_reihe() == startbar.ROLLEN)

print("liste_neu_test: " + ("alles grün" if not FEHL else "%d FEHL" % FEHL))
sys.exit(1 if FEHL else 0)
