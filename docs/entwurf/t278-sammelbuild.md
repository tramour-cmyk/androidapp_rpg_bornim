# Tom und Jerry · Build 278 · Sammelbuild nach Build 277 · PR #197
Ganzes Spiel · Tom (635, 785.19, 814, 856, 870.7, 870.9, 926, 933, 951, 954, 963, 964, 967, 977, 984.1, 989, 990, 991, 994, 1009), Jerry (595, 744, 806, 824, 836, 840, 909, 923, 935, 939, 950, 952, 959, 960, 971, 983, 986, 992, 993, 997, 998, 999, 1001, 1003, 1004, 1006, 1007, 1013; 988 und 1006 mit Build 277 auf `main`, hier zum Ansehen) · Entwurf 12.11., 06:05 · APK folgt

Ein Weg: über Build 277 installieren, Hauptmenü, „Weiter“ mit deinem Spielstand aus Build 277; erst Dorf am Tag (A), dann Wald und Kampf (B), zurück ins Dorf am Abend (C), dann Probekämpfe und Sprünge im Reiter „Test“ (D), zuletzt ein neues Spiel für die Erschaffung (E). Den Reiter „Test“ gibt es nur im Testmodus: im Hauptmenü siebenmal aufs Firmenzeichen tippen. Was nicht passt, reicht als Nummer (z. B. 278.5) mit einem Wort.

Verglichen (alt gegen neu): Gegenstandsfenster und Laden (870.7, 926) gegen das Bild, das passte (Chef 11.11., 19:57); Rückfrage „Überspringen?“ (856) gegen das Bild von 19:58; Testmenü (991) gegen Build 277.

Im Bau geprüft: Spielstand „Weiter“ nimmt immer den neuesten Platz (`spielstand_test`, 1009); Karten, Texte, Intro und Kartenblätter kommen aus der Godot-Quelle statt aus Kotlin, gleich dem alten Export (`karten_regeln`, 870.9); Lauf schneller ohne weggelassene Prüfung (909); Heiltrank ein Wert an einer Stelle, heilt weiter 14 (923); leichte Ziele üben höchstens ein Zehntel (971, Simulation 444); Metall sperrt Evokation, Illusion, Beschwörung (`handlungen_870`, 964); Schild nicht mehr in der Faust (`halt_653`, 967); Grimmzahn mit Ruhebewegung (`ruhe_977`), Monster der Karte ebenso (`ruhe_1007`); kein Bildsprung im Kampf (`kamera_992`); Hinweis „Schwerer Hieb“ ohne „Decken“ (`decken_1004`); Heldin keucht mit Frauenstimme (`keuchen_1003`); Schildprüfung nach der Herkunft, der Klosterschüler ohne Schild (`schild_406`, 1013).

Bekannt, nicht melden: die Erklärsätze beim Gedrückthalten in der Erschaffung (278.36) stehen noch auf dem alten Stand (Wille „stärkere Zauber“, Gewandtheit ohne Nahkampf); das Angleichen an die Heldenseite ist Vorgang 1015 (Homer).

## A · Dorf am Tag

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 278.1 | Tom | 785.19 | eine Person im Dorf ansprechen, nicht tippen, bis die Zeile steht; dann bei der nächsten Zeile mitten im Erscheinen einmal tippen | der Text erscheint Zeichen für Zeichen, das ▼ erst, wenn er steht; dein Tippen zeigt die Zeile sofort ganz, erst das nächste Tippen geht weiter; nichts springt im Kasten | Text steht sofort ganz da; Tippen überspringt die Zeile; Wörter brechen beim Erscheinen um |
| 278.2 | Tom | 814 | Dorf um 10 Uhr (Reiter „Test“ → Uhrzeit): auf dem Erdweg vor dem Schlagbaum gehen, dann rennen | bei jedem Schritt ein kleines Staubwölkchen am Fuß | kein Staub zu sehen |
| 278.3 | Tom | 814 | auf ein Huhn am Stall zugehen, auch von der Seite zu Bäumen oder Wasser hin und während es pickt oder läuft | es gackert, Federn fliegen, es rennt weg oder steht mit erhobenem Kopf | nichts passiert, auch direkt daneben |
| 278.4 | Tom | 990 | Thessas Kramladen und die Schenke am Tag betreten | die Staubflocken schweben nur im Licht der Fenster und bleiben im Raum | Flocken über die Wand hinaus ins Schwarze oder unter dem Boden; Staub an der geschlossenen Tür |
| 278.5 | Tom | 870.7, 926 | bei Thessa eine Rüstung und eine Waffe antippen, dann eine, die du trägst | Fenster ohne Kasten wie im Bild von 19:57; Schaden und Schutzwert als Zahl, „Güte: Normal“ (oder Schlecht, Gut, Meisterhaft); beim Kauf der Vergleich mit deinem Stück | Würfel wie „1W8“, Kasten mit Goldrahmen, keine Güte |

## B · Wald und Kampf

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 278.6 | Tom | 951 | in den Flüsterwald gehen, ins Dorf zurück, wieder in den Flüsterwald | auch beim zweiten Besuch Name und ein Satz, ein anderer als beim ersten | beim zweiten Besuch nur der Name |
| 278.7 | Jerry | 744, 1007 | einem Tier auf der Karte (Wolf, Reh) eine Weile zusehen, ohne nah heranzugehen; dann langsam näher | es geht in Bögen, verweilt unterschiedlich lange mit Ruhebewegung (umsehen, schnuppern, ein Wolf setzt sich auch); sein Knurren oder Laut ist nur nah zu hören | Gerade, Halt, Drehen auf der Stelle im Takt; steht reglos; Laut über die ganze Karte gleich laut |
| 278.8 | Jerry | 806 | Testmodus → Anzeigen „Bildrate“ an; Kampf mit einem Wolf, Bilder/s ablesen | Kampfort mit Gras und Blumen, ohne Bodennebel; Lichtschächte hinter den Kämpfern | Nebel am Boden; Bilder/s unter 17 (Zahl nennen) |
| 278.9 | Jerry | 992 | im selben Kampf auf das Bild achten, besonders zu Beginn und wenn eine Zeile in den Bericht kommt | das Bild steht ruhig, kein Zucken, der Wolf springt nicht um | Bild springt beim Start oder bei neuen Berichtszeilen |
| 278.10 | Jerry | 840, 986 | im ersten Wolfskampf auf die Ansage „Anspringen“ achten; im Kampf mit Grimmzahn, Krogg oder Grak ebenso auf deren erste Ansagen | direkt nach der ersten Ansage eine Eingebung des Helden in Gold im Bericht, einmal je Spielstand und Ansage; beim nächsten Mal nicht wieder | keine Eingebung, oder sie kommt in jedem Kampf |
| 278.11 | Jerry | 836 | im zweiten Kampf auf den Hinweis „Nahkampf erreicht nur die vordere Reihe.“ achten | steht nur einmal je Spielstand, im zweiten Kampf nicht mehr | steht in jedem Kampf |
| 278.12 | Jerry | 960 | einen Gegner lange drücken, vor und nach dem ersten Treffer | unter Name und Absicht seine Schwächen, Stärken und die Gegenwirkung; mit Verstand unter 6 erst nach einem Treffer, sonst „unbekannt“ | keine Schwächen, auch nach dem Treffer |
| 278.13 | Jerry | 1001 | im Kampf einen Ring öffnen (Angriff) und auf die Schalter am Rand achten | Raster-, Würfel- und Tempo-Schalter sind weg, solange der Ring wartet, und kommen danach wieder | Schalter stehen während des Rings |
| 278.14 | Jerry | 998 | im Kampf das Raster einschalten | goldenes Raster, kräftiger als bisher, mit dunklem Grund | blasses, dünnes Raster wie in Build 277 |
| 278.15 | Jerry | 939 | im Kampf hören: Ring öffnen, gut oder perfekt treffen; ein Wolf erscheint; den Kampf gewinnen | schwerer Schwung beim Öffnen, Block bei gut und perfekt; Wolfsgeheul beim Erscheinen (nicht jedes Mal); im Siegfenster Klang für Beute, Münzen, Stufenaufstieg | stumm |

## C · Dorf am Abend

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 278.16 | Tom | 814 | abends (20:30) auf dem Erdweg vor dem Schlagbaum gehen; dann ins Licht der eigenen Fackel schauen | Staubwölkchen je Schritt, schwächer als am Tag | kein Staub |
| 278.17 | Tom | 990 | abends die Schenke betreten | kein Staub im Lichtkegel, er verblasst am Abend | Staub leuchtet wie am Tag |

## D · Reiter „Test“: Probekämpfe und Sprünge

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 278.18 | Tom | 991 | Reiter „Test“ ganz durchgehen, ein paar Schalter antippen (Tag/Nacht, Gras, Tiere, Lichtschächte) | jeder Schalter zeigt am Zeichen, ob er an ist (aus: matt und durchgestrichen), darunter an/aus oder der Wert; Tag/Nacht nennt die Tageszeit | Zeichen sieht an und aus gleich aus |
| 278.19 | Jerry | 806 | Reiter „Test“ → Welt „Kampf messen“, dann einen Kampf beginnen und etwa 40 s warten | der Kampf hält vor dem ersten Zug an, danach steht über dem Kampfort je Baustein (Gras, Tusche, Schatten …) die Zeit; bitte ein Bildschirmbild davon | keine Messung, Kampf startet normal |
| 278.20 | Tom | 994 | Reiter „Test“ → Anzeigen „Klang“ an (nach einem Neustart der App wieder aus), dann im Dorf umhergehen | wechselnde Klänge, eine Wiederholung steht als eine Zeile | ständig „hen_scratch“, ein Klang ohne Ton |
| 278.21 | Tom | 977 | Sprung „Grimmzahn“, in einigem Abstand stehen bleiben und zusehen | Grimmzahn bewegt sich im Stehen (knurrt, sieht sich um, hechelt) | steht reglos |
| 278.22 | Tom | 635 | Sprung in den Tempel des Morgenlichts (Lyra nach der Rettung) und in die Höhle (Lyra hinter dem Gitter) | Lyra als neue Figur (Stirnreif, weiße Robe), Hände frei, ruhige Bewegung im Stehen, an beiden Orten | Hände vor dem Bauch wie gefesselt, alte Figur mit gestreiftem Kleid |
| 278.23 | Jerry | 935 | MARS-Probekampf gegen Wölfe, „Tasche“ → Brandflasche auf einen Wolf | Wurfbewegung des Helden, die Flasche fliegt im Bogen und zerschellt am Wolf, er brennt | Flasche schießt gerade wie ein Feuerball |
| 278.24 | Jerry | 950 | MARS-Probekampf mit Söldner: Held und Söldner tauschen den Platz | beide gehen mit Schritten an den neuen Platz, nach hinten rückwärts, der Blick bleibt beim Gegner | gleiten ohne Schritte |
| 278.25 | Jerry | 999 | MARS-Probekampf: „Waffe wechseln“ auf Bogen, dann zurück; mit einem Zweihänder ebenso | die andere Waffe ist in der Hand, der Bogen links; beim Zweihänder ist der Schild weg und kommt mit der ersten Waffe zurück | alte Waffe bleibt in der Hand, Schild beim Zweihänder |
| 278.26 | Jerry | 824 | MARS-Probekampf, starten als „Herumtreiber“ (ohne Schild): angreifen | nach dem Hieb geht der Held rückwärts in ruhigem Schritt an seinen Platz, die Füße rutschen nicht | er saust zurück, Füße gleiten |
| 278.27 | Jerry | 983 | MARS-Probekampf gegen Goblins: Kampf laufen lassen, bis die Reihe umgestellt wird | der Goblin geht mit seinem Zug um die anderen herum an den neuen Platz, Gesicht zum Helden | bleibt stehen oder springt an den Platz |
| 278.28 | Jerry | 595 | Probekampf gegen Spinne, Egel und Säureschnecke, je mit einem Kämpfer ohne Schild | gegen die niedrigen Gegner schlägt er nach unten (Hieb oder Stich zum Ziel); die Spinne greift den Helden an | Hiebe über den Gegner hinweg |
| 278.29 | Jerry | 993 | Probekampf mit dem Zauberlehrling: Arkanpfeil | ein leuchtender Pfeil fliegt sichtbar zum Ziel und schlägt ein; der Ring läuft ruhig | dünner Strich, Ring rattert |
| 278.30 | Jerry | 997 | im Testkampf auf die Zeile unter der Zugleiste achten | je Figur, die sich bewegt, Name und laufende Bewegung (z. B. „Ansgar: Hieb_2“); wer ruht, ohne Zeile | nur Haken und Kreuz |
| 278.31 | Jerry | 1004 | im Probekampf gegen Grak seine Ansage „Schwerer Hieb“ lange drücken | Hinweis ohne „Decken“: „… sonst Abwehr oder den Ring treffen“ | Hinweis nennt „Decken“ |
| 278.32 | Tom | 856 | Sprung zu einer Zwischensequenz, „Überspringen“ antippen | die Rückfrage „Überspringen?“ ohne Kasten und Goldrand wie im Bild von 19:58, der Erzähltext ebenso | alter Kasten mit Goldrahmen, gerahmte Knöpfe |
| 278.33 | Jerry | 988 | MARS-Probekampf gegen Wölfe: warten, bis ein Wolf auf der Stelle ausweicht | das Bild geht schon zu Beginn des Ausweichens zurück, Kopf und Rand des Wolfs bleiben im Bild | Kopf oder Rand angeschnitten, Bild springt spät zurück |
| 278.34 | Jerry | 1006 | Probekampf gegen Skelette, ein paar Züge zusehen | die Skelette bewegen sich im Stehen jedes für sich | alle im Gleichklang |

## E · Neues Spiel: Erschaffung und Held

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 278.35 | Tom | 870.9 | Hauptmenü → neues Spiel, Intro ansehen | Intro und Bilder wie in Build 277 | Intro fehlt oder ohne Bild |
| 278.36 | Tom | 954 | in der Erschaffung je einen Grundwert, ein Volk, eine Herkunft und eine Fertigkeit gedrückt halten | ein Satz, was es bewirkt, in einem Fenster | nichts passiert |
| 278.37 | Tom | 933 | Volk „Zwerg“ wählen, Gewandtheit mit „−“ auf 3 senken | danach steht Gewandtheit auf 2; der Text sagt ehrlich „beginnt bei 3“ | Wert bleibt bei 3 stehen |
| 278.38 | Tom | 984.1 | bei den Fertigkeiten nachsehen | Illusion und Beschwörung matt, nicht wählbar wie Bergbau | wählbar |
| 278.39 | Jerry | 959 | Herkunft „Schmiedelehrling“ ansehen | dabei Stumpfe Waffen neben Schmieden und Bergbau | nur Schmieden und Bergbau |
| 278.40 | Jerry | 952 | einen neuen Helden fertig erschaffen, Tasche → „Held“ | kritischer Treffer als Anfänger nahe 0 % (nicht 7 %) | 7 % schon zu Beginn |
| 278.41 | Tom | 963, 989 | Tasche → „Held“, jeden Grundwert gedrückt halten | nur Wirkungen, die es gibt: Zähigkeit „Abwehr gegen Gift, Betäubung und Blendung“, Wahrnehmung kritisch mit Dolch, Bogen, Armbrust, Wurf, Verstand „Schaden mit Evokation“, Wille Heilung und kritisch mit Evokation; je Waffe und Zauber die Aussicht auf kritisch | „Stärke deiner Zauber“, „Flächenwirkungen“, „Furcht und Zauber“, Krankheit, Spähen |
