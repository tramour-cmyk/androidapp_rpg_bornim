# Tom und Jerry · Build 279 · Version folgt · Nachtrag zu 278: Prüfliste im Spiel, Schnellstart, Probekampf-Baukasten, Fortsetzen · PR #198
Ganzes Spiel · Tom (1020.1, 1021, 990, 1017), Jerry (1020.2, 863), Spike (1021 „Letztes Ende“) · 12.11., 09:38 · APK folgt
Rot, bekannt, nicht melden: wolf_mess_438 – ein Wolfsbiss gleitet knapp über der Grenze (Vorgang 1018). Dazu bekannt und in 279 unverändert: Kartenrand im Norden offen (1022), Fußstaub nicht zu sehen (814), Beet nicht bis an den Zaun (612, kommt im nächsten Build), Bildrate im Kampf (806, 15 Bilder/s).
Gegengelesen: Sokrates 12.11., 09:42 (6 Funde, eingearbeitet `ec72af9c4`). Die Prüfliste im Spiel stammt vom Baustart und hat diese Korrekturen noch nicht; Unterschiede nur bei 278.10, .11 (zuerst „Einmaliges“), 278.28 („Andere Hand: leer“), 278.32 (über das Intro eines neuen Spiels) und der Zeile „bekannt“.

Ein Weg: über Build 278 installieren, Hauptmenü, „Weiter“ mit deinem Spielstand; zuerst den Reiter „Test“ öffnen: dort steht diese Prüfliste (279.1), du kannst sie gleich dort abhaken. Dann die neuen Punkte 279.2 bis 279.10, danach die offenen Punkte aus Build 278 (Nummern 278.x, Wortlaut wie dort, nur an Build 279 angepasst). Den Reiter „Test“ gibt es nur im Testmodus: im Hauptmenü siebenmal aufs Firmenzeichen tippen.

Verglichen (alt gegen neu): Reiter „Test“ mit Prüfliste gegen das Bild, das passte (Chef 12.11., 08:58, `ansehen/10201-pruefliste.md`); Probekampf-Abschnitt gegen Build 278.

Im Bau geprüft: Prüfliste im Spiel (`pruefliste_1020`), Schnellstart, Lage merken und zurück, Schalter über Neustart (`schnellstart_1020`), Fortsetzen nach Ende im Hintergrund (`fortsetzen_1021`), letztes Ende laut System (`ende_1021`), Probekampf-Baukasten und Gegnerzug (`probekampf_1020`), Ratten nicht ineinander (`ruhe_863`), kein Staub in Innenräumen (`effekte_814`); die sechs roten Tests aus Lauf 373 außer wolf_mess_438 grün (Lauf 376).

## A · Reiter „Test“ und Hauptmenü

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 279.1 | Tom | 1020.1 | Reiter „Test“: oben unter „Prüfliste · Build 279“ eine Zeile antippen, „Passt“ oder „Falsch“ mit einem Wort; App schließen und neu öffnen; „Ergebnis kopieren“, im Chat einfügen | die Zeile klappt auf mit Richtig und Falsch; „Passt“ springt zur nächsten offenen; Haken und Kreuz mit Wort sind nach dem Neustart noch da; im Chat steht „Build 279 · Ergebnis“ mit je Zeile Haken oder Kreuz | keine Prüfliste, Ergebnis nach Neustart weg, Zwischenablage leer |
| 279.2 | Tom | 1020.1 | Hauptmenü → „Schnellstart · Wachsoldat“ | neues Spiel ohne Intro und Erschaffung, der Held steht erwacht in der Schenke; zurück im Hauptmenü zeigt „Weiter“ weiter deinen eigenen Spielstand. Noch nicht in 279: Volk und Geschlecht wählen, Start nach Aldrics Auftrag (dafür nach dem Schnellstart „Teleport“ und die Stationen 1–9 im Reiter „Test“); die Herkunft wählst du im Reiter „Test“ unter „Schnellstart“ | Intro läuft; dein Spielstand ist überschrieben |
| 279.3 | Tom | 1020.1 | Reiter „Test“ → Schnelltest „Lage merken“, dann woandershin (Teleport Wald, Uhrzeit ändern), dann „Lage zurück“ | du stehst wieder, wo du gemerkt hast, mit derselben Uhrzeit | Lage zurück tut nichts oder lädt deinen alten Spielstand |
| 279.4 | Tom | 1020.1 | Reiter „Test“ → „Einmaliges“, dann einen Wolfskampf beginnen | die Eingebung nach „Anspringen“ und der Hinweis zur vorderen Reihe erscheinen wieder wie beim ersten Mal | nichts kommt wieder |
| 279.5 | Tom | 1020.1 | Reiter „Test“ → „Uhrzeit“ mehrmals antippen; „Schnell“ einschalten, App schließen und neu öffnen | die Uhr springt auf 8, 10, 12, 19, 20:30, 21, 23 Uhr; „Schnell“ ist nach dem Neustart noch an | Uhr springt um 3 Stunden; Schalter nach Neustart aus |
| 279.6 | Tom | 1021 | mitten im Dorf in eine andere App wechseln (Browser, Kamera), ein paar Minuten dort bleiben, zurück ins Spiel | das Spiel steht an derselben Stelle; hat Android es beendet, geht es ohne Vorspann gleich dort weiter; Reiter „Test“ nennt unter dem Absturzbericht, warum die App zuletzt endete | Vorspann und Hauptmenü erscheinen, du musst „Weiter“ tippen |
| 279.7 | Jerry | 1020.2 | Reiter „Test“ → „MARS-Probekampf“: Herkunft, Volk, Stufe, Waffe (Bogen, Zweihänder), andere Hand, Söldner, Tasche, Leben, Tageszeit wählen, „Probekampf starten“; nach dem Kampf „Nochmal“ | der Held kämpft genau mit der Wahl; „Nochmal“ beginnt denselben Kampf, „Zurück zum Testmenü“ führt in den Reiter | Wahl wirkt nicht; nach dem Kampf nur „Zurück“ |
| 279.8 | Jerry | 1020.2 | im selben Abschnitt „Gegnerzug“ auf „Anspringen“ (gegen Wölfe) oder „Schwerer Hieb“ (gegen Grak), „Ausweichen“ erzwingen, Tempo „sehr schnell“ | der Gegner sagt den gewählten Zug gleich an; der erste Angriff auf den Helden geht fehl; „sehr schnell“ ist deutlich schneller als „schnell“ | Zug kommt nicht; kein Ausweichen |

## B · Dorf und Kampf

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 279.9 | Tom | 990 | Thessas Kramladen und die Schenke am Tag betreten | kein Staub im Licht mehr | Flocken schweben im Raum |
| 279.10 | Jerry | 863 | MARS-Probekampf gegen Ratten, ein paar Züge zusehen | Ratten weichen dem Helden aus und stehen danach nie ineinander oder halb aufeinander | zwei Ratten übereinander |
| 278.9 | Jerry | 992 | im Kampf auf das Bild achten, besonders zu Beginn und wenn eine Zeile in den Bericht kommt | das Bild steht ruhig, kein Zucken, der Wolf springt nicht um | Bild springt beim Start oder bei neuen Berichtszeilen |
| 278.10 | Jerry | 840, 986 | vorher Reiter „Test“ → „Einmaliges“ (279.4); dann im ersten Wolfskampf auf die Ansage „Anspringen“ achten; im Kampf mit Grimmzahn, Krogg oder Grak ebenso auf deren erste Ansagen | direkt nach der ersten Ansage eine Eingebung des Helden in Gold im Bericht, einmal je Spielstand und Ansage; beim nächsten Mal nicht wieder | keine Eingebung, oder sie kommt in jedem Kampf |
| 278.11 | Jerry | 836 | vorher Reiter „Test“ → „Einmaliges“ (279.4); dann im ersten und zweiten Kampf auf den Hinweis „Nahkampf erreicht nur die vordere Reihe.“ achten | steht nur einmal je Spielstand, im zweiten Kampf nicht mehr | steht in jedem Kampf |
| 278.12 | Jerry | 960 | einen Gegner lange drücken, vor und nach dem ersten Treffer | unter Name und Absicht seine Schwächen, Stärken und die Gegenwirkung; mit Verstand unter 6 erst nach einem Treffer, sonst „unbekannt“ | keine Schwächen, auch nach dem Treffer |
| 278.13 | Jerry | 1001 | im Kampf einen Ring öffnen (Angriff) und auf die Schalter am Rand achten | Raster-, Würfel- und Tempo-Schalter sind weg, solange der Ring wartet, und kommen danach wieder | Schalter stehen während des Rings |
| 278.14 | Jerry | 998 | im Kampf das Raster einschalten | goldenes Raster, kräftiger als bisher, mit dunklem Grund | blasses, dünnes Raster wie in Build 277 |
| 278.15 | Jerry | 939 | im Kampf hören: Ring öffnen, gut oder perfekt treffen; ein Wolf erscheint; den Kampf gewinnen | schwerer Schwung beim Öffnen, Block bei gut und perfekt; Wolfsgeheul beim Erscheinen (nicht jedes Mal); im Siegfenster Klang für Beute, Münzen, Stufenaufstieg | stumm |

## C · Reiter „Test“: Probekämpfe und Sprünge

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 278.18 | Tom | 991 | Reiter „Test“ ganz durchgehen, ein paar Schalter antippen (Tag/Nacht, Gras, Tiere, Lichtschächte) | jeder Schalter zeigt am Zeichen, ob er an ist (aus: matt und durchgestrichen), darunter an/aus oder der Wert; Tag/Nacht nennt die Tageszeit | Zeichen sieht an und aus gleich aus |
| 278.19 | Jerry | 806 | Reiter „Test“ → Welt „Kampf messen“, dann einen Kampf beginnen und etwa 40 s warten | der Kampf hält vor dem ersten Zug an, danach steht über dem Kampfort je Baustein (Gras, Tusche, Schatten …) die Zeit; bitte ein Bildschirmbild davon | keine Messung, Kampf startet normal |
| 278.20 | Tom | 994 | Reiter „Test“ → Anzeigen „Klang“ an, dann im Dorf umhergehen | wechselnde Klänge, eine Wiederholung steht als eine Zeile | ständig „hen_scratch“, ein Klang ohne Ton |
| 278.21 | Tom | 977 | Sprung „Grimmzahn“, in einigem Abstand stehen bleiben und zusehen | Grimmzahn bewegt sich im Stehen (knurrt, sieht sich um, hechelt) | steht reglos |
| 278.22 | Tom | 635 | Sprung in den Tempel des Morgenlichts (Lyra nach der Rettung) und in die Höhle (Lyra hinter dem Gitter) | Lyra als neue Figur (Stirnreif, weiße Robe), Hände frei, ruhige Bewegung im Stehen, an beiden Orten | Hände vor dem Bauch wie gefesselt, alte Figur mit gestreiftem Kleid |
| 278.24 | Jerry | 950 | MARS-Probekampf mit Söldner: Held und Söldner tauschen den Platz | beide gehen mit Schritten an den neuen Platz, nach hinten rückwärts, der Blick bleibt beim Gegner | gleiten ohne Schritte |
| 278.25 | Jerry | 999 | MARS-Probekampf: „Waffe wechseln“ auf Bogen, dann zurück; mit einem Zweihänder ebenso | die andere Waffe ist in der Hand, der Bogen links; beim Zweihänder ist der Schild weg und kommt mit der ersten Waffe zurück | alte Waffe bleibt in der Hand, Schild beim Zweihänder |
| 278.26 | Jerry | 824 | MARS-Probekampf mit Herkunft „Herumtreiber“ (ohne Schild), „Probekampf starten“, angreifen | nach dem Hieb geht der Held rückwärts in ruhigem Schritt an seinen Platz, die Füße rutschen nicht | er saust zurück, Füße gleiten |
| 278.27 | Jerry | 983 | MARS-Probekampf gegen Goblins, „Gegnerzug“ auf „Reihe umstellen“ | der Goblin geht mit seinem Zug um die anderen herum an den neuen Platz, Gesicht zum Helden | bleibt stehen oder springt an den Platz |
| 278.28 | Jerry | 595 | MARS-Probekampf gegen Spinne, Egel und Säureschnecke, Herkunft „Wachsoldat“, „Andere Hand“ auf „leer“ | gegen die niedrigen Gegner schlägt er nach unten (Hieb oder Stich zum Ziel); die Spinne greift den Helden an | Hiebe über den Gegner hinweg |
| 278.29 | Jerry | 993 | Probekampf mit dem Zauberlehrling: Arkanpfeil | ein leuchtender Pfeil fliegt sichtbar zum Ziel und schlägt ein; der Ring läuft ruhig | dünner Strich, Ring rattert |
| 278.30 | Jerry | 997 | im Testkampf auf die Zeile unter der Zugleiste achten | je Figur, die sich bewegt, Name und laufende Bewegung (z. B. „Ansgar: Hieb_2“); wer ruht, ohne Zeile | nur Haken und Kreuz |
| 278.31 | Jerry | 1004 | Probekampf gegen Grak, „Gegnerzug“ auf „Schwerer Hieb“, die Ansage lange drücken | Hinweis ohne „Decken“: „… sonst Abwehr oder den Ring treffen“ | Hinweis nennt „Decken“ |
| 278.32 | Tom | 856 | Hauptmenü → neues Spiel, Erschaffung beenden; im Intro „Überspringen“ antippen (mit 278.35, Intro danach noch einmal ganz ansehen) | die Rückfrage „Überspringen?“ ohne Kasten und Goldrand wie im Bild von 19:58, der Erzähltext ebenso | alter Kasten mit Goldrahmen, gerahmte Knöpfe |
| 278.33 | Jerry | 988 | MARS-Probekampf gegen Wölfe mit Herkunft „Klosterschüler“, „Ausweichen“ erzwingen | das Bild geht schon zu Beginn des Ausweichens zurück, der Held bleibt ganz im Bild | Held am Rand angeschnitten, Bild springt spät zurück |
| 278.34 | Jerry | 1006 | Probekampf gegen Skelette, ein paar Züge zusehen | die Skelette bewegen sich im Stehen jedes für sich | alle im Gleichklang |

## D · Neues Spiel: Erschaffung und Held

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 278.35 | Tom | 870.9 | Hauptmenü → neues Spiel, Intro ansehen | Intro und Bilder wie in Build 277 | Intro fehlt oder ohne Bild |
| 278.36 | Tom | 954, 1017 | in der Erschaffung je einen Grundwert, ein Volk, eine Herkunft und eine Fertigkeit gedrückt halten | ein Satz, was es bewirkt, in einem Fenster; Verstand „Mehr Schaden mit Evokation.“, Wille mit Heilmagie und kritisch mit Evokation, nirgends „Wurfwaffen“ | nichts passiert; Wille „stärkere Zauber“, Verstand „Wissen“ |
| 278.37 | Tom | 933 | Volk „Zwerg“ wählen, Gewandtheit mit „−“ auf 3 senken | danach steht Gewandtheit auf 2; der Text sagt ehrlich „beginnt bei 3“ | Wert bleibt bei 3 stehen |
| 278.38 | Tom | 984.1 | bei den Fertigkeiten nachsehen | Illusion und Beschwörung matt, nicht wählbar wie Bergbau | wählbar |
| 278.39 | Jerry | 959 | Herkunft „Schmiedelehrling“ ansehen | dabei Stumpfe Waffen neben Schmieden und Bergbau | nur Schmieden und Bergbau |
| 278.40 | Jerry | 952 | einen neuen Helden fertig erschaffen, Tasche → „Held“ | kritischer Treffer als Anfänger nahe 0 % (nicht 7 %) | 7 % schon zu Beginn |
| 278.41 | Tom | 963, 989, 1017 | Tasche → „Held“, jeden Grundwert gedrückt halten | nur Wirkungen, die es gibt: Zähigkeit „Abwehr gegen Gift, Betäubung und Blendung“, Wahrnehmung kritisch mit Dolch, Bogen, Armbrust (ohne Wurfwaffen), Verstand „Schaden mit Evokation“, Wille Heilung und kritisch mit Evokation; je Waffe und Zauber die Aussicht auf kritisch | „Stärke deiner Zauber“, „Flächenwirkungen“, „Furcht und Zauber“, Krankheit, Spähen |
