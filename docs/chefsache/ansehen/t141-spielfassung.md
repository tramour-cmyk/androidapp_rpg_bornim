# Tom · Build 141 · Godot 0.348.141 · 399 Spielfassung: Rückläufer t139, Testmenü, Vorspann, Intro, Start in der Schenke, Worte in der Blende · ohne PR

B Umzug · Tom, Jerry · 28.10., 22:0x · APK: [Lauf 141](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/40768078764) (Artefakt `bornim-godot-apk`, Kennung de.bornim.game.godot, installiert sich über 139). Enthält alles aus 139; was dort noch nicht getestet ist, kann hier weiter getestet werden. Nur die neuen Punkte:

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 141.1 | Tom | 399.1 | App ganz schließen, neu starten | Firmenzeichen mit „präsentiert“ und Klanglogo (mit Musik), kurz schwarz und still, dann der Name mit Titelmusik, das Menü wächst darum; Tippen überspringt | gleich das Menü |
| 141.2 | Tom | 399.1 | Hauptmenü: siebenmal auf das Firmenzeichen unten tippen | beim siebten Mal „Testmodus aktiviert“, darunter „Testmodus aktiv“; noch siebenmal: „deaktiviert“ | nichts passiert |
| 141.3 | Tom | 399.1 | Testmodus an, ein Spiel laden, Leiste antippen | ganz rechts ein siebter Reiter „Test“ (Kolben): Gerät, Bildrate, Standort; Stufe −5 bis +5, +1000 Gold, Heilen, Vorräte, Waffe, andere Hand; Uhrzeit +3 h; Teleport Dorf; Kapitel 1 bis kurz vor Ende; Kampf gegen jede Gegnergruppe; MARS-Probekampf; Beute je Seltenheit | kein Reiter, Knopf tut nichts |
| 141.4 | Tom | 399.1 | Reiter Test: „Kampf“ gegen Goblins; dann MARS-Probekampf mit einer Klasse | Kampf beginnt, danach wieder im Dorf am selben Fleck; bei der Probe Held und Söldner der Klasse, dein Held danach unverändert | Absturz, Welt bleibt schwarz |
| 141.5 | Tom | 399.1 | Reiter Test: „Kapitel 1 bis kurz vor Ende“ | im Haus des Ältesten vor Aldric, abends, Amulett in der Tasche | bleibt, wo er war |
| 141.6 | Tom | 399.1 | über der Welt (Testmodus aus) | keine Zeile „Bilder/s …“ mehr oben links; nur mit „Bildrate anzeigen“ im Reiter Test | Zeile immer da |
| 141.7 | Tom | 399.1 (t139) | Spiel laden, System, Hauptmenü, Neues Spiel mit neuem Helden | Ankunft bei Nacht (fünf Bilder, Fackelzug, Klang), dann erwacht der Held neben dem Bett der Schenke, Rowena weckt ihn; ohne Gold und Aufträge des alten Spiels; der alte Spielstand bleibt in seinem Platz | Start dort, wo der alte stand |
| 141.8 | Tom | 399.1 (t139) | Menü öffnen und schließen, dann vor eine Tür; auch mit Steuerung Klassisch und Aktion links | der Aktionsknopf ist da, die Tür öffnet; nach Hauptmenü und neuem Spiel ebenso | kein Knopf |
| 141.9 | Tom | 399.1 (t139) | System, Anleitung, mit dem Finger über den Text wischen | der Text rollt bis zum Ende | steht still |
| 141.10 | Tom | 399.1 | aus der Schenke ins Dorf, dann zum ersten Mal in den Laden | auf Schwarz der Ortsname klein in Gold, darunter ein Satz des Orts, dann steigt der Ort auf; von Tür zu Tür beim zweiten Mal nur ein Blinzeln | nur Schwarz |
| 141.11 | Tom | 399.1 | in die Nähe von jemandem, der Neues zu sagen hat | mit dem goldenen „!“ ein kurzer Ruf ohne Worte (Mann, Frau, Kind), leiser mit Abstand | stumm |
| 141.12 | Jerry | 399.3 | lange rennen, bis der Atem weg ist | der Held keucht, erst schnell, dann langsamer und leiser, bis ein Viertel zurück ist | kein Atemgeräusch |

Bekannt, kein Testpunkt: der Held sieht in jeder Klasse gleich aus (Aussehen in der Erschaffung, 376.1); im Reiter Test fehlen noch Regen, Kartenzoom, Monster auf der Karte, Sichtlinie, Bosse (Wald und Höhle noch nicht begehbar), Varianten, Eröffnung, Kampfhilfen und Absturzbericht (Kampfort, Jerry).
