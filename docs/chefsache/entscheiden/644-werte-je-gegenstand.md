# 644 · Werte je Gegenstand ohne Würfel: Vorgang anlegen? · Sokrates · 08.11., 11:06

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/DESIGN-SPIELSYSTEM-2-0-ENTWURF.md

**Frage:** Im BRS hat jede Waffenart einen festen Grundschaden (Einhänder 6 …), jede Rüstung einen Rüstungswert. Innerhalb einer Art unterscheiden sich die Stücke heute nicht (Kurzschwert, Krummsäbel, Langschwert alle „Einhänder 6“). Vorgesehen sind Gegenstandsstufe, Güte (Normal, Gut, Meisterhaft) und Zustand, aber ohne Zahlen. Soll ich einen Vorschlag mit Zahlen machen und in der Simulation 444 rechnen lassen, bevor mehr Ausrüstung entsteht?
**Votum Sokrates: ja.**
**Berührt:** 478 (Rechenkern BRS), 469, `LISTE-GEGENSTAENDE.md`, Simulation 444, Läden und Beute Kapitel 1.

## Begründung

Ohne Zahlen je Stück ist jeder Kauf und jeder Fund im Kampf gleich viel wert; „echte Wahl“ (`DESIGN-LEITBILD.md`) fehlt bei der Ausrüstung.

## Sachverhalt

`DESIGN-SPIELSYSTEM-2-0-ENTWURF.md`: Grundschaden je Waffengruppe (Zeile 122), Abzug = Rüstungswert × (1 + Fertigkeit/100) (334), Gegenstandsstufe, Güte, Zustand ohne Zahlen (386). 478 (`claude/jerry-478-brs`) ordnet jede Waffe nur ihrer Gruppe zu. Würfelreste: Ansagen, Zauber, Tränke, Heilung, über ein Verhältnis umgerechnet.

## Auswertung

- **Stärkstes Gegenargument:** Neue Zahlen vor dem Test von 478 und vor 469 können wieder umgeworfen werden; mehr Unterschiede je Stück heißt auch mehr Balancearbeit.
- **Entkräftet:** erst nur Vorschlag und Rechnung, gebaut wird nach 469; Läden und Beute von Kapitel 1 brauchen die Zahlen ohnehin.

## Folgerungen

„644 ja“: ich lege den Vorschlag (Zahlen je Stufe, Güte, Zustand, Eigenheiten je Waffe) vor, Jerry rechnet ihn in 444. „noch nicht“: 644 ruht bis nach 469.
