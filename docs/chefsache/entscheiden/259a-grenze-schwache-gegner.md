# 259a · Grenze „leichter Kampf“: 4 Stufen tragen gegen drei Wölfe nicht
Jerry · 20.10., 23:24 · G Balance · K (Auftrag aus 259: „Grenze ‚4‘ prüft Jerry mit der Kampfsimulation“; Maßstab Sokrates: Sieg fast immer, Verlust unter einem Viertel der LP)

## Befund

259 ist gebaut wie entschieden (Zweig `claude/jerry-259-schwach`, fährt im nächsten Jerry-Build). Die Simulation (Kerntest `SkirmishEasyTest`, je 200 Kämpfe „Schnell“, Held und Söldner Kämpfer, Held jede Klasse) sagt:

| Gegner (HG) | Stufe 5–7 (Abstand 4–6, voller Schaden) | Stufe 8 (Abstand 7, halber Schaden) |
|---|---|---|
| drei Wölfe (1/4) | Sieg 61–97 %, LP-Verlust Held 18–53 %; Magier am schwächsten (61–70 % Sieg, 43–53 % Verlust) | Sieg 98–100 %, Verlust 7–21 % |
| Spinne (1) und Wolf | Sieg 79–99 %, Verlust 13–38 % | Sieg 99–100 %, Verlust 5–13 % |
| Goblin und Späher (1/4) | Sieg 96–100 %, Verlust 4–17 % | Sieg 100 %, Verlust 1–5 % |

Wo kein Sieg ist, hält „Schnell“ meist unter einem Drittel LP an und der Spieler übernimmt (bis 30 %); der Held fällt in bis zu 5 % der Kämpfe (Magier gegen Wölfe), bevor er anhalten kann. Zudem: MARS läuft heute nur als Probe mit Stufe 3, dort ist kein Kampf leicht (Stufe 3 gegen Wolf 1/4 ist Abstand 2,75, nicht „knapp ja“ wie in 259 geschätzt). Zum Testen gibt es im Test-Reiter die Stufe von Held und Söldner (3, 5, 6, 8, 11).

## Empfehlung

**Noch nicht ändern:** Grenze 4 bleibt, bis MARS im Spiel kämpft (212); dann mit echten Gegnergruppen neu messen. Heute wirkt 259 nur in der Probe mit gewählter Stufe, ein Fehlgriff kostet nichts.

*Stärkstes Gegenargument:* Was gebaut ist, prägt den Eindruck der Tester: wer mit Stufe 5 gegen Wölfe „Schnell“ drückt und in jedem dritten Kampf übernehmen muss, hält den Knopf für kaputt. *Alternative:* Grenze 7 (leicht erst, wo der Schaden halb ist); dann wirkt 259 in Kapitel 1 nie (Stufe dort höchstens 6), also auch nicht im Fall des Chefs.

## Antwort

„259a noch nicht“ (Empfehlung), „259a Grenze 7“ oder eine andere Zahl.

**Berührt:** 259, 212, 38.
