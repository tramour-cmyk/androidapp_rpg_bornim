# Tom und Jerry · Build 288 · Menü, Rattenbiss, Kerbe, Modellspeicher · [PR #207](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/207)
E Kampf · Tom (785.1, 785.2, 785.3, 785.6, 870.13; ohne dich 1290), Jerry (1284 Film bei dir), Spike (1270.2) · 15.11., 13:35 · APK folgt
Gegengelesen: Jerry 15.11., 13:36 (1266 und 1284 richtig unter „Schon vorgelegt“: 1266 gebilligt, das Kerbensystem bleibt im Spiel aus (`kerbe_an` false), am Handy nichts zu sehen; 1284 Urteil am Film. Hinweis: 288.2 und 288.4 hängen am Zufall von „Beute erzeugen“; wenn möglich ein fester Knopf im Reiter „Test“, sonst so lassen)

Sammelbuild auf Build 287 aufgesetzt (enthält alles aus 287); die Punkte der Liste 287 kommen hier nicht noch einmal.

Ein Weg: erst die Liste 287 zu Ende testen, dann über Build 287 installieren, Hauptmenü, „Weiter“ mit deinem Spielstand; im Menü 288.1 bis 288.5, dann Reiter „Test“, Zeile 288.6 „Lage herstellen“.

Schon vorgelegt, fährt unverändert mit (kein neuer Prüfpunkt): 1266 Kerbholz (Film und Hörprobe gebilligt 15.11., 12:31 und 12:48), 1284 Rattenbiss (Film bei dir, `ansehen/1284-rattenbiss.md`, Urteil dort).

Bekannt: das Fackelbild 287.1 kam noch aus dem alten Renderer (opengl3); ab diesem Lauf zeichnen Bilder und Filme im Renderer des Handys (1290).

Im Bau geprüft: Bilder und Filme dieses Laufs im Renderer des Handys (1290, Schritt „Bildwerkzeuge“ meldet „Forward Mobile“), Ratte beißt auch daneben knapp vor dem Ziel (`biss_1284`), Modelle einmal geladen und wiederverwendet (`modellspeicher_1270`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 288.1 | Tom | 785.3 | Handy | Menü → Tasche, unter „Vorräte“ einen Vorrat antippen, etwa den Verband | unter dem Bild steht seine Seltenheit als Wort in ihrer Farbe, etwa „Gewöhnlich“ | kein Wort; falsche Farbe |
| 288.2 | Tom | 785.1 | Handy | in der Tasche ein Stück mit blauer Zeile zu einem Grundwert anlegen, etwa „+1 Kraft“ (sonst Reiter „Test“ → „Beute erzeugen“); Menü → Held | neben dem Grundwert blau „+1“, darunter „Blau: Bonus durch Ausrüstung (im Wert enthalten)“ | kein blaues Plus; Satz fehlt; Zeile ragt über den Rand |
| 288.3 | Tom | 785.2 | Handy | Menü → Held, eine Fertigkeit antippen; dann Reiter „Fertigkeiten“, eine matte (noch nicht geübte) antippen | ein Fenster mit ihrem Namen und einem Satz, was sie tut; bei einer, die noch nicht wirkt, mit Hinweis darauf; Antippen schließt es | nichts geschieht; falscher Satz; Fenster bleibt stehen |
| 288.4 | Tom | 785.6 | Handy | ein Stück mit blauer Zeile „Zauberschaden“ oder „Abwehrprobe“ anlegen (sonst „Beute erzeugen“ wiederholen); Menü → Ausrüstung, unten „Kampfwerte“ | eine Zeile „Zauberschaden“ bzw. „Abwehrprobe“ mit „+n %“ | Zeile fehlt; steht auch ohne solches Stück da |
| 288.5 | Tom | 870.13 | Handy | Menü → System → Handbuch, durchrollen; Hauptmenü und Testerseite ansehen | Absätze zu Grundwerten, Fertigkeiten und Kampf, Zahlen statt Klammern; nirgends „SRD 5.1 · CC BY 4.0“ | „Kämpfer“, „Rüstungsklasse“, Würfel; geschweifte Klammern; der SRD-Hinweis steht noch da |
| 288.6 | Spike | 1270.2 | Handy | Zeile 288.6 → „Lage herstellen“ (Probekampf Wolfsrudel), Kampf zu Ende spielen; noch einmal „Lage herstellen“; danach Reiter „Test“ → „Gerät“, Zeile „Kampfort bereit nach“ | der zweite Kampf ist deutlich schneller bereit als 0,9 s (dein Wert 1270.1: kalt 3,0 s, warm 0,9 s); Figuren sehen aus wie vorher | zweiter Kampf nicht schneller; Figur fehlt oder sieht anders aus |

## Lagen

- 288.6: probe=WOLVES
