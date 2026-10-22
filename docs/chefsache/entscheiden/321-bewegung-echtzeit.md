# 321 · Bewegungen auch in Echtzeit prüfen, mit Mindestdauer?
Sokrates · 22.10., 22:40 · B Abläufe · M (Chef 22.10., 22:40, Wortlaut: „Und in wie vielen Regeln haben wir festgehalten, dass Animationen zu prüfen sind und dass die Weichung geschmeidig laufen müssen?“)

## Befund

- Sechs Stellen verlangen flüssige, selbst angesehene Bewegungen: `DESIGN-LEITBILD.md` 12, `DESIGN-ABNAHME.md` („Kampfabläufe selbst durchspielen“, Sprungtest), `ROLLE-ENTWICKLUNG.md` („fertig ist, was du im Film gesehen hast“), `LISTE-BAUEN-TESTEN.md` Schritt 3, Meilenstein „Läuft rund“.
- Alle prüfen auf Sprünge, keine auf Erkennbarkeit. Graks schwerer Hieb (310) dauert 340 ms hin und zurück; Jerry filmte in vierfacher Zeitlupe, dort sah er gut aus. Chef 22:38: „schneller wieder hinten, als ich blinzeln konnte“ (320).

## Vorschlag

In `DESIGN-ABNAHME.md` „Kampfabläufe selbst durchspielen“ einen Halbsatz ergänzen, keine neue Regel: „einmal in Echtzeit bei Tempo ‚Normal‘ ansehen; Hauptbewegung (Schlag, Biss, Zauber) mindestens 0,5 s, schwerer Hieb länger“.

**Zahlen (Chef 23:28: „Schau doch mal ein paar … Kampffilme an … dann kannst du das messen“):** Filme ansehen kann ich nicht; Werte aus Sportmessung und Spieltrickfilm: echter Schwerthieb 0,3–0,5 s, Faustschlag 0,1–0,2 s; Spiele strecken auf Lesbarkeit: Ausholen deutlich länger als der Schlag, kurzer Halt beim Treffer, ruhiges Zurück. Heute bei uns 0,34 s für alles.

| Bewegung bei „Normal“ | Ausholen | Schlag | Halt | Zurück | gesamt |
|---|---|---|---|---|---|
| Stich, Biss | 0,2 s | 0,1 s | 0,1 s | 0,2 s | **0,6 s** |
| Schwert-, Axthieb | 0,3 s | 0,15 s | 0,1 s | 0,25 s | **0,8 s** |
| schwerer Hieb (Grak, angesagt) | hält schon | 0,2 s | 0,25 s | 0,45 s | **0,9 s** nach dem Ausholen |

## Stärkstes Gegenargument

Eine feste Zahl macht alle Schläge gleich träge; schnelle Gegner (Wolf, Ratte) sollen flink wirken. Antwort: die Zahl gilt für die Hauptbewegung bei „Normal“, flinke Gegner dürfen darunter, wenn es im Film noch zu sehen ist.

## Empfehlung

**Halbsatz ergänzen und die Tabelle als Richtwert** (Stich 0,6 s, Hieb 0,8 s, schwerer Hieb 0,9 s nach dem Ausholen); Gerätetest entscheidet, „Schnell“ und „Langsam“ skalieren.

Berührt: 310, 320 (Jerry), `DESIGN-ABNAHME.md`.
