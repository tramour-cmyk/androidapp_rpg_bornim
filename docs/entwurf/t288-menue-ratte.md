# Tom und Jerry · Build 288 · 0.348.493 · Menü, Rattenbiss, Kerbe, Modellspeicher · [PR #207](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/207)
E Kampf · Tom (785.2, 785.3, 870.13; ohne dich 1290), Jerry (1284 abgelehnt, fährt mit), Spike (1270.2) · 15.11., 16:15 · [APK (Lauf 493)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43723535827/artifacts/14167127253)
Gegengelesen: Jerry 15.11., 13:36 (1266 und 1284 richtig unter „Schon vorgelegt“: 1266 gebilligt, das Kerbensystem bleibt im Spiel aus (`kerbe_an` false), am Handy nichts zu sehen; 1284 Urteil am Film. Hinweis: 288.2 und 288.4 hängen am Zufall von „Beute erzeugen“; wenn möglich ein fester Knopf im Reiter „Test“, sonst so lassen)

Sammelbuild auf Build 287 aufgesetzt (enthält alles aus 287); die Punkte der Liste 287 kommen hier nicht noch einmal.

Ein Weg: über Build 287 installieren, Hauptmenü, „Weiter“ mit deinem Spielstand; im Menü 288.1, 288.3, 288.5, dann Reiter „Test“, Zeile 288.6 „Lage herstellen“.

Nicht in dieser Liste: 288.2 (785.1) und 288.4 (785.6) hingen am Zufall von „Beute erzeugen“; sie kommen mit fester Lage in den nächsten Build. Im Reiter „Test“ stehen sie noch: überspringen.

Schon vorgelegt, fährt unverändert mit (kein neuer Prüfpunkt): 1266 Kerbholz (Film und Hörprobe gebilligt 15.11., 12:31 und 12:48), 1284 Rattenbiss: dein ✗ am Film (15.11., 14:54) kam nach dem Mischen; der Biss in diesem Build ist der abgelehnte Stand, nicht prüfen, der neue Anlauf liegt bei Jerry.

Bekannt: das Fackelbild 287.1 kam noch aus dem alten Renderer (opengl3); ab diesem Lauf zeichnen Bilder und Filme im Renderer des Handys (1290).

Im Bau geprüft: Bilder und Filme dieses Laufs im Renderer des Handys (1290, Schritt „Bildwerkzeuge“ meldet „Forward Mobile“), Ratte beißt auch daneben knapp vor dem Ziel (`biss_1284`), Modelle einmal geladen und wiederverwendet (`modellspeicher_1270`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 288.1 | Tom | 785.3 | Handy | Menü → Tasche, unter „Vorräte“ einen Vorrat antippen, etwa den Verband | unter dem Bild steht seine Seltenheit als Wort in ihrer Farbe, etwa „Gewöhnlich“ | kein Wort; falsche Farbe |
| 288.3 | Tom | 785.2 | Handy | Menü → Held, eine Fertigkeit antippen; dann Reiter „Fertigkeiten“, eine matte (noch nicht geübte) antippen | ein Fenster mit ihrem Namen und einem Satz, was sie tut; bei einer, die noch nicht wirkt, mit Hinweis darauf; Antippen schließt es | nichts geschieht; falscher Satz; Fenster bleibt stehen |
| 288.5 | Tom | 870.13 | Handy | Menü → System → Handbuch, durchrollen; Hauptmenü und Testerseite ansehen | Absätze zu Grundwerten, Fertigkeiten und Kampf, Zahlen statt Klammern; unter dem Firmenzeichen und auf der Testerseite kein Hinweis mehr auf das alte Regelwerk (SRD) | „Kämpfer“, „Rüstungsklasse“, Würfel; geschweifte Klammern; der SRD-Hinweis steht noch da |
| 288.6 | Spike | 1270.2 | Handy | Zeile 288.6 → „Lage herstellen“ (Probekampf Wolfsrudel), Kampf zu Ende spielen; noch einmal „Lage herstellen“; danach Reiter „Test“ → „Gerät“, Zeile „Kampfort bereit nach“ | der zweite Kampf ist nach höchstens 0,7 s bereit, die Hälfte deines Werts aus 287.4 (1,4 s, A56); Figuren sehen aus wie vorher | zweiter Kampf über 0,7 s; Figur fehlt oder sieht anders aus |

## Lagen

- 288.6: probe=WOLVES
