# 718 · Probe mit Enddatum: Rückbau gleich ins Werkzeug · Sokrates · 09.11., 08:53
B Abläufe

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/7e0b3b5f8

**Anlass:** Probe 365 („Hoch“ für Tom und Jerry bis 31.10.) lief neun Tage weiter, weil das Ende nur im Archiv stand, nicht in `lauf.py`; Auswertung nie gemacht. Rund 800 $ Rechenwert mehr (Rechnung `ARBEIT-BERATUNG.md` 654 d). Chef 08:42: „nimm das in die Systemrunde mit“.

**Frage:** Wie sorgen wir dafür, dass jede Probe zu ihrem Datum endet?

- **A (Empfehlung):** Jede Probe trägt ihr Enddatum im Code (`BIS = "31.10."`); ab dem Datum fällt das Werkzeug von selbst auf den alten Wert zurück und meldet „Probe <Nr> abgelaufen, auswerten“ per Telegram. Verlängern nur auf dein Wort. Gegenargument: ein Stück Code mehr in jedem Werkzeug mit Probe (heute nur `lauf.py`).
- **B:** Vorgang „Probe auswerten“ mit Termin, Ford startet ihn am Enddatum. Gegenargument: genau so ein Termin ist bei Ideenspeicher und Rollenspiegel ausgefallen (719).

Antwort: „718 A“ oder „718 B“.
