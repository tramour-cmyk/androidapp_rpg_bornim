# Jerry · Testreihe 16.10.: vier Sammelbuilds

Jerry · 16.10., 14:3x · ersetzt die 14 Einzel-Builds (108a: Chef „sinnvolles Bündeln, damit ich nicht alles extra installieren muss“). Vorher-/Nachher-Bilder und Hörproben kamen per Telegram.

Kurz: 4 Sammelbuilds statt 14 Einzel-APKs, je Build eine Prüfliste; Reihenfolge 1 → 4

**Zu tun:** Build 1 installieren, seine Punkte prüfen, Ergebnis je Punkt („1.2 passt“, „1.3 nicht, weil …“) schreiben; dann Build 2, 3, 4. Jeder Build enthält `main` (auch Toms #71) und lässt sich über 0.1.757 und 0.1.773 installieren; die Nummern steigen von 1 nach 4 (0.1.777–0.1.780).

APK: im PR unten unter „Checks“ → „build“ → „Artifacts“. Testmenü: Reiter „Test“ (Uhrzeit +3 h, Teleport, „Held trifft immer kritisch“, „Bosse zurücksetzen“, „Alle Vorräte auf mindestens 10“).

## Build 1 · 0.1.777 · Klang draußen · [PR #88](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/88)

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 1.1 | 95 | draußen rennen, bis die Atemanzeige leer ist; dann stehen bleiben, 10 s zuhören | Held keucht erst dicht, dann leiser mit Pausen, 5–10 s, bis er wieder rennen darf | stumm, oder Keuchen läuft weiter, wenn er wieder rennen darf |
| 1.2 | 84 | Tiefer Wald nachts (Uhrzeit +3 h), 3 min stehen; Höhle 3 min; Wiese am Dorf, auf pickende Vögel zugehen | Tiefer Wald ohne Vogelgesang und Eule, fernes Wolfsgeheul alle 1–2½ min von einer Seite; Höhle selten leises Grollen; Vögel flattern hörbar auf, scharren ab und zu | Vogelgesang im Tiefen Wald; Geheul laut oder im Takt |
| 1.3 | D3.1, D3.4 | im Dorf durch eine Tür gehen und daneben an der Wand entlang; am Lagerfeuer stehen, während Kampfklänge spielen | Türklang nur auf der Tür; Feuer und Ortsklang reißen nicht ab | Türklang ohne Tür; Feuer verstummt |
| 1.4 | D6.4 | im Dorf zum Fluss und über die Brücke, dann 10 Felder weg | Rauschen am Fluss, auf der Brücke am lautesten, ab etwa 8 Feldern still; Weiher still | kein Rauschen, oder es reißt beim Gehen ab |

## Build 2 · 0.1.778 · Intro und Menü · [PR #89](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/89)

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 2.1 | 69c | neues Spiel, Intro nicht überspringen | Bild 1–4 je eigene leise Mischung (Wind, Grillen, Fluss), zum Schwarzbild still | Klang lauter als die Musik; Sprung zwischen den Bildern |
| 2.2 | 69c.1 | wie 2.1, bis Bild 5; dann antippen | dumpfe Glocke schwillt an, drei Rufe, ein ferner Schrei unter der Titelmusik; Antippen: Glocke klingt aus | Glocke bricht hart ab |
| 2.3 | 40, 13e.6 | Menü → System: drei Regler; in der Höhle „Dunkle Töne“ von 0 auf 100 % | Gesamt, Musik, Effekte wirken einzeln (Ortsklang und Intro-Klang hängen an „Effekte“); Schwarz hebt sich höchstens leicht, Prüfzeichen gerade noch sichtbar | ein Regler ohne Wirkung; Höhle sieht hell und grau aus |
| 2.4 | 30 | App starten und sofort beenden (Zurück), dreimal | kein Absturz (sonst nichts zu sehen) | „App wurde beendet“ |

## Build 3 · 0.1.779 · Kampf · [PR #90](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/90)

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 3.1 | 38, D4.1 | Höhle, Rauchbündel in der Tasche (beim Händler oder „Vorräte auffüllen“), Kampf gegen Krogg beginnen; danach verlieren | Held wirft das Bündel zu Kampfbeginn selbst, Kroggs erster Hieb geht ins Leere; nach Niederlage liegt das Bündel wieder in der Tasche | Bündel bleibt ungenutzt oder ist nach der Niederlage weg |
| 3.2 | 51 | einen Kampf verlieren (Magier und eine zweite Klasse), dreimal | Held liegt am Boden, kein Arm in der Luft, fällt nicht aus dem Bild | Arm steht nach oben; Held verschwindet links |
| 3.3 | 36.6 | Test: „Held trifft immer kritisch“ an, „Bosse zurücksetzen“, Krogg töten (Schwert und Speer) | Stücke beim Zerteilen und Durchbohren so fein wie Krogg selbst | grobe Pixel an den Stücken (Oberkörper teils hinter dem Rand: bekannt) |
| 3.4 | 53 | Krogg mit Feuer treffen (Feuerzauber oder Alchemistenfeuer) | Flammen sitzen auf Kroggs Umriss | Flammen links neben ihm |

## Build 4 · 0.1.780 · Schänke und Raumklang · [PR #91](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/91)

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 4.1 | 86.9 | in der Schänke Met trinken bis „betrunken“, dann draußen kämpfen und einmal fliehen | Held trifft seltener, Flucht misslingt öfter (im Kampf keine Anzeige, das ist so gewollt) | kein Unterschied zu nüchtern; Absturz beim Kampf nach dem Met |
| 4.2 | 119 | in der Höhle kämpfen und eine Truhe öffnen; in der Schänke Becher und Stühle hören; im Tempel und im Laden eine Tür; draußen kämpfen | Höhle hallt (Hiebe, Stimmen, Tür), Tempel weit, Schänke und Laden nah und gedämpft, draußen trocken wie bisher; Systemklänge überall gleich | Hall draußen; Treffer in der Höhle verschwimmen; Systemklang hallt |

## Build 5 · 0.1.782 · Gegnerstimmen · [PR #85](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/85)

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 5.1 | 18.11 | Höhle und Wald: gegen Keiler, Kobold, Riesenratte, Riesenspinne, Fledermaus kämpfen, dann Krogg (Test: „Bosse zurücksetzen“) | jeder Gegner ruft beim Angriff, bei Treffer und im Tod mit eigener Stimme, wie die Hörproben; Krogg tief und schwer | Gegner stumm; Stimme zu laut gegen die Hiebe; falsche Stimme |

Fällt ein Punkt durch, nehme ich ihn per `git revert` aus dem Build, der Rest geht auf `main` (78a).
