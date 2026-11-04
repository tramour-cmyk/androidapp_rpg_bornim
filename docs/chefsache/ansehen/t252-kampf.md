# Tom und Jerry · Build 252 · Godot 0.348.252 · Build 251 und sechs Kampfbefunde zu Build 249 · [PR #182](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/182)
E Kampf · Team Jerry · 04.11., 02:20 · [Lauf 252, bornim-godot-apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/41753201022/artifacts/13288854895) (grün 03:17) · Geprüft an: Rechner ohne Kaufmodelle, Daten aus dem APK von Build 249: tier_553 0, grimm_533 0, tips_536 0, zugleiste_552 0, ausweichen_546 0, mars_golden 0, mars_regeln 0, kampfzustand_532, tempo_527, testmenue_555 grün

Build 252 enthält alles aus Build 251: gleich 252 installieren, die Prüfliste [t251](t251-testmenue.md) gilt dort ebenso. Neu sind nur die Zeilen unten, Vorgänge 546, 551, 552, 553, 533, 536. Verglichen: alt `SkirmishScreen.kt` und `MarsTips.kt` (langes Drücken), `Monsters.kt` und `Packs.kt` (Grimmzahn), `DeviceInfo.kt` (Bildschirmecken) gegen neu.

Ein Weg: Testmodus an, Reiter „Test“, MARS-Probekampf gegen das Wolfsrudel; danach Teleport Wald, ein Kampf mit Ratten, dann zu Grimmzahn.

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 252.1 | Jerry | 552 | Probekampf, oben am Bildschirm | die Zugreihenfolge steht unter der Kamera, ganz lesbar | oben nur ein leerer schwarzer Streifen |
| 252.2 | Jerry | 551 | Probekampf, der Goldrahmen um den Kasten unten, besonders unten links und rechts; bitte ein **Bildschirmfoto** | der Rahmen läuft rundum durch | an den unteren Ecken unterbrochen (zeigt das Bildschirmfoto die Lücke auch, ist es eine andere Ursache) |
| 252.3 | Jerry | 536 | Probekampf, eine halbe Sekunde auf „Angriff“ drücken, dann loslassen; ebenso auf „Abwehr“, „Held“ | unten erscheint eine Erklärung, was der Knopf tut; losgelassen passiert nichts | keine Erklärung, oder der Held greift an |
| 252.4 | Jerry | 536 | lang auf das Zeichen über einem Wolf drücken (die Ansage), dann lang auf einen Wolf selbst | Ansage: was sie heißt und was hilft; Wolf: Name, Absicht und auf wen | nichts erscheint |
| 252.5 | Jerry | 546 | Probekampf, zusehen, wenn ein Wolf einem Schlag ausweicht | er springt flink im Lauf zur Seite und kehrt dann zurück | er schleicht im Schritt weg („Schlaftabletten“) |
| 252.6 | Jerry | 553 | nach dem Rattenkampf im Wald an den Wölfen auf der Karte vorbeigehen | Wölfe sehen aus und laufen wie Wölfe | ein graues, hochbeiniges Tier mit langem Hals |
| 252.7 | Jerry | 533 | Kampf mit Grimmzahn (Station oder Tiefer Wald) | kein Knopf „Flucht“; „Held Auto“ sagt „Nicht gegen Bosse.“; fällt Grimmzahn: „Ihr Leitwolf ist gefallen – die Wölfe verschwinden heulend im Wald!“, Sieg mit mehr als 450 EP | Flucht möglich, die Wölfe kämpfen weiter, Grimmzahn so schwach wie ein Wolf |

Bekannt, nicht in diesem Build: Grimmzahns Fang (das Amulett) fehlt noch, Einzelstücke gibt es in Godot noch nicht; Grimmzahn sieht aus wie bisher (neuer auf dem Kaufwolf erst nach deinem Wort, 533); Ratten fallen von selbst und Haken/Kreuz (548, 545) warten auf [548a](../entscheiden/548a-ratten-haken.md); „in die Knie“ ohne Sturz (547) liegt bei Homer.
