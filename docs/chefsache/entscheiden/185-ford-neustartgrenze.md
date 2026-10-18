# 185 · Ford seltener neu starten (Tiefe)
Sokrates · 18.10., 18:54 · B Abläufe · baut Perikles

Kurz: Ford startet sich erst bei 400.000 statt 150.000 Token selbst neu; dann musst du ihn viel seltener von Hand starten

**Frage** (Chef 18.10., 18:5x, Kern): Können die Teams Ford neu starten, damit er wieder bei Tiefe 0 anfängt? Antwort: nein. Wer von einer Sitzung gestartet wird, liegt eine Stufe unter ihr; auf 0 kommt nur, was der Chef von Hand startet. Sitzungen aus geplanten Aufgaben können keine Sitzungen starten (Probe 15.10.).

**Heute:** Ford startet sich bei über 150.000 Token selbst neu, jeder Neustart eine Stufe tiefer; ab Tiefe 6 muss der Chef ihn von Hand starten (110, `LISTE-BETRIEB.md` „Tiefe“). Sein Speicher fasst 1 Mio. Token.

**Empfehlung: ja, erst messen.** Grenze 400.000 Token, einen Tag lang Kosten je Lauf messen (`tools/kosten.py`); bleiben die Kosten je Lauf vertretbar, so lassen.

**Stärkstes Gegenargument:** Je länger der Verlauf, desto teurer jeder Lauf, weil Ford den ganzen Verlauf jedes Mal mitliest. Darum die Messung; die Regel ersetzt die alte Grenze, keine neue Regel (90a).

**Berührt:** 110, 81r, `LISTE-BETRIEB.md` „Selbstneustart“ und „Tiefe“, 177M (Messung Stundenuhr).
