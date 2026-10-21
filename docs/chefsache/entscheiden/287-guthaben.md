# 287 · Guthaben bis Sa 10:00: jetzt sparen oder Credits?
Perikles · 22.10., 00:06 · B Kosten · M (nach 284, Chef 21.10., 19:49 „Vollgas“ bis Sa)

## Befund

- **Schätzung jetzt etwa 70 % Woche** (letztes Bild 59 %, 21.10., 15:25). Gerechnet über die Sitzungskosten (`list_sessions`, `cost_usd`): 20.10., 15:17 bis 21.10., 15:25 kosteten 268 $ für etwa 18 % (0,75 %/h, 11 $/h); seither bis 00:05 kosteten 165 $ (19 $/h), also etwa 11 %. Größte Posten seit 15:25: Jerry 54 $, Tom 43 $, Sokrates 35 $, Homer 15 $, Perikles 9 $, Ford 9 $.
- **Reicht nicht:** im Mittel (0,75 %/h) 80 % Do ~13:20, 95 % Fr ~09:20, 100 % Fr ~16:00; im Abendtakt (1,28 %/h) 100 % schon Do ~23:30. Bis Sa 10:00 dürfen es höchstens 0,52 %/h sein (etwa 7,7 $/h), bis zur Zurücksetzung Sa 21:00 0,43 %/h (6,4 $/h): rund 30 bis 40 % weniger als im Mittel.
- **Credits allein reichen nicht:** 95,69 Credits decken bei 11 $/h etwa 9 Stunden (falls sie zum Listenpreis abrechnen), also Fr 16:00 bis etwa Sa 01:00.

## Vorschlag

1. **Ab sofort sparen:** Ford fährt `lauf.py --nur-muss` ab 70 % statt 80 %; nachts (0 bis 7 Uhr) keine neuen Starts außer Rückläufern des Chefs; Sokrates und Homer nur auf Zuruf. Ziel unter 8 $/h.
2. **Weiter wie bisher**, ab 100 % Credits (etwa 9 Stunden), danach Stillstand bis Sa 21:00.
3. **Weiter wie bisher und Credits nachkaufen** (Ausgabenlimit unbegrenzt): etwa 200 bis 330 $ bis Sa 10:00 bzw. 21:00.

## Stärkstes Gegenargument

Die 70 % sind geschätzt, nicht abgelesen; das Bild der Morgenmeldung kann tiefer liegen, und die Nacht ist meist ruhig (der Mittelwert 0,75 %/h enthält eine Nacht schon). Dazu sparen wir vor allem Kür, denn die Teams haben kaum Startbares; die teuren Stunden sind die Tests mit dir. Darum gilt 1 nur, wenn das Bild es bestätigt.

## Empfehlung

**1**, sobald das Bild der Morgenmeldung 65 % oder mehr zeigt; darunter bleibt die alte Regel (80 %/95 %). Credits nur als Reserve für deine Tests am Samstagvormittag.

Berührt: 284 (Wochenziel bis Sa), 163.1 (Kosten der Abläufe), 177M (Stundenuhr nachts).

## Stellungnahme Sokrates (22.10., 01:05)

- **Stärkstes Gegenargument:** Die Datei rechnet bis Sa 10:00, gebraucht wird das Guthaben aber bis Sa 21:00: Ab Mittag spielst du mit dem besten Build durch, danach gibt es „nur Fehler aus dem Durchspielen“ (Wochenziel, 284). Ist Max um 10:00 leer, bleibt niemand, der deine Rückläufer behebt. Maßgeblich ist also 0,43 %/h (6,4 $/h), nicht 0,52 %/h. Nachgerechnet: 268 $ für 18 % sind 14,9 $ je Prozent, 165 $ ergeben also etwa 11 %, die 70 % stimmen. Vorschlag 1 spart dagegen wenig: Nachts ist es ohnehin ruhig, und Kür ist kaum startbar. Teuer sind die Testsitzungen (Jerry 54 $, Tom 43 $) und Sokrates (35 $).
- **Widerspruch zu Entschiedenem:** Mit 284 („Vollgas bis Samstag Vormittag“) verträgt sich 1 nur, solange die Muss-Arbeit voll weiterläuft. Das tut sie, gespart wird nur an Kür und an nächtlichen Starts. „Sokrates nur auf Zuruf“ gilt schon heute (`ROLLE-BERATUNG.md`). `lauf.py` startet mich aber für jede Stellungnahme selbst (194.2, auch diese Sitzung). Wer 1 ernst meint, setzt diese Starts bis Sa 21:00 aus. Deine Rückläufer gehen dann ohne meine Stellungnahme an dich, und die Empfehlung des Besitzers muss allein tragen.
- **Kosten:** 1 kostet nichts (ein Schalter beim Lauf). 2 riskiert Stillstand genau Sa 10 bis 21 Uhr. 3 kostet echtes Geld, etwa 200 bis 330 $. Die 95,69 Credits decken etwa 9 Stunden, also ziemlich genau Sa 12 bis 21 Uhr.
- **Empfehlung in einem Satz:** 1 gleich, ohne auf das Morgenbild zu warten (es spart nur, was ohnehin kaum läuft), dazu Stellungnahmen durch `lauf.py` bis Sa 21:00 aussetzen; die Credits nur für die Rückläufer aus deinem Durchspielen am Samstag, nichts nachkaufen.
