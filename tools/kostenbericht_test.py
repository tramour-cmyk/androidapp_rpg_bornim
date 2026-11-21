#!/usr/bin/env python3
"""1739 (Archiv „Qualität eigener Kostenteil“ 20.11., 09:45): Teile Spiel, Qualität, Verwaltung; Nacharbeit gegen Prüfen."""
import datetime, os, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kostenbericht as kb

B = kb.BERLIN
fehler = 0


def pruefe(name, ist, soll):
    global fehler
    if ist != soll:
        fehler += 1
        print(f"FEHLER {name}: {ist!r} statt {soll!r}")


pruefe("teile", kb.teil_von({"E": 3, "G": 1, "Q": 2, "B": 4, "M": 1, "?": 9}), {"Spiel": 4, "Qualität": 2, "Verwaltung": 5})
vg = {"10": ("E Welt", None, "Von Chef (18.11., 14:34, Fund, Build 298): Streitkolben fehlt", True),
      "11": ("E Welt", None, "Von Sokrates: Wegweiser", False)}
zp = datetime.datetime(2026, 11, 21, 12, 0, tzinfo=B)
pruefe("Fund des Chefs", kb.ist_nacharbeit("10", "Tom: 10 Streitkolben", zp, vg, {}), True)
pruefe("erste Arbeit", kb.ist_nacharbeit("11", "Tom: 11 Wegweiser", zp, vg, {}), False)
pruefe("nach nein", kb.ist_nacharbeit("11", "Tom: 11 Wegweiser", zp, vg, {"11": zp - datetime.timedelta(hours=1)}), True)
pruefe("vor nein", kb.ist_nacharbeit("11", "Tom: 11 Wegweiser", zp, vg, {"11": zp + datetime.timedelta(hours=1)}), False)
pruefe("Revert", kb.ist_nacharbeit(None, "Revert \"Tom: 11\"", zp, vg, {}), True)
pruefe("Testpunkt", kb.ist_nacharbeit(None, "t82.3 Rückläufer Blende", zp, vg, {}), True)
pruefe("Build 300 ist kein Testpunkt", kb.ist_nacharbeit(None, "Spike: Build 300 Prüfliste", zp, vg, {}), False)

with tempfile.TemporaryDirectory() as d:
    os.makedirs(os.path.join(d, "docs", "vorgang"))
    open(os.path.join(d, "docs", "vorgang", "11.md"), "w", encoding="utf-8").write(
        "# 11\n\n## Rückmeldungen\n\n- **21.11., 10:00**, Tom:\n> fertig, 1234567\n"
        "- **21.11., 11:00**, Diogenes:\n> **Diogenes** [21.11., 11:00] nein, Wegweiser fehlt\n"
        "- **21.11., 11:30**, Diogenes:\n> nein, weiter\n- **30.12., 09:00**, Tom:\n> nein, aus dem Vorjahr\n")
    alt, kb.REPO = kb.REPO, d
    try:
        n = kb.erstes_nein(datetime.datetime(2026, 11, 21, 22, 0, tzinfo=B))
    finally:
        kb.REPO = alt
    pruefe("erstes nein", n.get("11"), datetime.datetime(2025, 12, 30, 9, 0, tzinfo=B))
    open(os.path.join(d, "docs", "vorgang", "11.md"), "w", encoding="utf-8").write(
        "# 11\n\n## Rückmeldungen\n\n- **21.11., 11:00**, Diogenes:\n> **Diogenes** [21.11., 11:00] nein, Wegweiser fehlt\n")
    kb.REPO = d
    try:
        n = kb.erstes_nein(datetime.datetime(2026, 11, 21, 22, 0, tzinfo=B))
    finally:
        kb.REPO = alt
    pruefe("nein hinter Stempel", n.get("11"), datetime.datetime(2026, 11, 21, 11, 0, tzinfo=B))

print("kostenbericht_test: " + ("grün" if not fehler else f"{fehler} Fehler"))
sys.exit(1 if fehler else 0)
