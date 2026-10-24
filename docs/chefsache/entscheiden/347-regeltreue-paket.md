# 347 · Paket „Regeltreue erhöhen, Kosten senken“: was davon umsetzen?
Sokrates · 24.10., 16:24 · B Abläufe

**Frage** (Chef 24.10., 16:20): `PAKET-FUER-SOKRATES.md` mit drei Dateien (`hook-zaehler.py`, `hook-prompt.sh`, `notiz.sh`) prüfen; verwenden oder erst besprechen. Alles abgelegt unter `tools/regeltreue/` (nicht eingeschaltet).

**Abgleich mit dem Bestand:**
- **Uhrzeit:** Es gibt sie schon bei jedem Prompt. `tools/neustart-haken.py prompt` schreibt „Uhr: … (Berliner Zeit, Systemuhr; so stempeln)“ vor jede Antwort. Die Annahme des Pakets, die Zeit hänge nur an einer Textregel, stimmt nicht. Trotzdem stempelte Sokrates am 23.10. einmal 09:10 um 09:02 (die Commit-Prüfung hielt es an). Die Zeile allein reicht also nicht ganz; genau das soll der Zähler messen.
- **Neustart-Schwelle:** steht in `tools/neustart-haken.py` (100.000 Token Zuwachs, Umgebungsvariable `BORNIM_NEUSTART_AB`). Diese Sitzung lief trotzdem bis über 700.000 Token, weil Ford den Neustart wegen der Pausezeile im Vorrat abgelehnt hat. Der Haken mahnte über 100-mal ohne Wirkung. Das ist ein eigener Fehler im Ablauf.
- **Der Zähler (3.4) hat einen Grundfehler:** Er schreibt nach `.claude/regeltreue.tsv` im Container der Sitzung. Cloud-Container werden nach jeder Sitzung weggeworfen, jede Sitzung hat ihren eigenen. Die Zahlen gingen also verloren und kämen nie zusammen.

**Empfehlung:**
1. **Messen zentral statt im Container:** Dieselben Werte (Wörter je Antwort, Entschuldigung, Stempel und Abweichung, Kontextgröße) rechnet Ford in `lauf.py` stündlich aus den Verläufen aller Sitzungen (`list_events`). So hat Sokrates bei 316 schon gemessen. Kein neuer Haken, nichts geht verloren, und die Messung zählt alle Rollen gleich. Die Regeln für die Zählung aus `hook-zaehler.py` übernehmen.
2. **Kernregel-Zeile:** nicht als zweiter Haken, sondern als eine Zeile mehr in `neustart-haken.py prompt`, bei jedem 10. Prompt. Kosten etwa 60 Token alle 10 Prompts.
3. **`notiz.sh` wie im Paket** (Zeit und Kernregeln am Ende). Klein, schadet nicht.
4. **Start kleiner (3.6):** ja. Der größte Hebel, etwa 20.000 Token weniger je Start von Tom und Jerry. Perikles stellt `ROLLE-ENTWICKLUNG.md` um, die Teams prüfen die Befehle in der eigenen Sitzung.
5. **`CLAUDE.md` (3.5):** „Sparsam“ neu und Telegram länger: ja. „Bekannte Fehler“ als neuer Abschnitt: ja, mit Regelbilanz, also dafür den Satz über die Zeitstempel in „Feste Regeln“ streichen, den die neue Zeile ersetzt.
6. **Neustart, wenn eine Pause im Vorrat steht:** Der Haken hat Vorrang. Ford startet dann trotzdem den Nachfolger; die Pause gilt nur für Starts ohne Anlass.
7. **Reihenfolge:** erst 1 (Basis, 2 bis 3 Tage), dann 2 bis 6 auf einmal, eine Woche später vergleichen.

**Stärkstes Gegenargument:** Jede Erinnerungszeile ist Text, und Text hat bisher wenig gewirkt (318). Nur die Messung sagt, ob das Paket etwas bringt. Darum steht die Messung zuerst und zentral.

**Wer:** 1, 2, 6 Ford mit Perikles (Werkzeuge); 3, 4, 5 Perikles; Auswertung Sokrates (318). Ab Sa 24.10., 21 Uhr (Guthaben).

**Berührt:** 316, 318, 338.2, 340, 341; alle Rollen.

**Was du sagen sollst:** „347 ja“, einzelne Punkte streichen oder „erst besprechen“.
