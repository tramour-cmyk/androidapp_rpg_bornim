# Tom und Jerry · Build 280 · 0.348.379 · Nachtrag zu 279: Reiter „Test“ passt auf den Schirm, Bäume im Wald, Dorf Süd, Stufen der Ausrüstung · PR #199
Ganzes Spiel · Tom (1027, 831, 644a.2), Spike (612), Jerry (1024, 935, 1014), Tuffy (644a.1, 633) · 12.11., 12:20 · APK folgt (Lauf zu PR #199)
Rot, bekannt, nicht melden: wolf_mess_438 – ein Wolfsbiss gleitet knapp über der Grenze (Vorgang 1018). Dazu bekannt und in 280 unverändert: Kartenrand im Süden und Osten (1022), Fußstaub (814, Bild beim Chef, kommt nach deinem Urteil), Bildrate im Kampf (806). Probekämpfe im Dorf starten, nicht im Wald (1025, zwei Kämpfe zugleich, noch offen).
Gegengelesen: Sokrates 12.11., 12:24 (4 Funde, eingearbeitet): 280.5 (Grundwert steigt durchs Üben) gestrichen, weil vom Spielstand aus erst nach etwa 10 gewonnenen Fertigkeitspunkten erreichbar und der Reiter „Test“ keinen Weg dorthin hat (kommt mit einem Weg im nächsten Build); 280.6 nur noch Kroggs Einzelstück, weil der Probekampf keine Stufe 1 anbietet (3, 5, 6, 8, 11) und das Siegfenster die Stufe der Beute nicht zeigt (Probebeute kommt nicht in die Tasche; Beutestufe sichert `gegenstaende_870`); 280.8 Tasche mit Flaschen; Weg bis 280.8.

Ein Weg: über Build 279 installieren, Hauptmenü, „Weiter“ mit deinem Spielstand; zuerst den Reiter „Test“ öffnen: dort steht diese Prüfliste und passt jetzt auf den Schirm (280.1). Dann die neuen Punkte 280.2 bis 280.8, danach die Punkte aus Build 279 und 278 (Nummern 279.x und 278.x, Wortlaut wie dort, nur an Build 280 angepasst). Den Reiter „Test“ gibt es nur im Testmodus: im Hauptmenü siebenmal aufs Firmenzeichen tippen.

Verglichen (alt gegen neu): Reiter „Test“ im Hochformat 1080 × 2340 vorher und nachher (Bild in der Meldung zu 1027); jede Zeichenreihe aller Reiter gegen die Schirmbreite.

Im Bau geprüft: jeder Reiter höchstens so breit wie der Schirm (`breite_1027`), Schalter im Kampf nie verdeckt (`schalter_1024`), Schild bei niedriger Abwehr (`schild_406`, 1014), Wurfflasche in Handgröße (`wurf_935`), Stufen der Beute und der Gaben (`gegenstaende_870`), Bäume im Wald (`baeume_831` nur Bild am Rechner).

## N · Neu in Build 280

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 280.1 | Tom | 1027 | Reiter „Test“ öffnen und ganz nach unten rollen; danach Held, Fertigkeiten, Tasche, Ausrüstung, Chronik und System antippen | alles innerhalb des Schirms: alle Reiterfelder ganz sichtbar, „Schnellstart · Wachsoldat“ und „Nächste“ ganz, Prüflistenzeilen enden vor dem rechten Rand, links und rechts gleich breiter Rand; Reihen mit vielen Zeichen brechen in eine zweite Reihe um | rechts abgeschnitten, rechts kein Rand |
| 280.2 | Tom | 612 | Dorf Süd am Fluss, am Tag | drei verschiedene Heuhaufen, kein Gras im Korn, das Beet geht bis an den Zaun | gleiche Heuhaufen mit Stab, Gras im Korn, Grasstreifen vor dem Zaun |
| 280.3 | Tom | 831 | Reiter „Test“ → „Bildrate“ an, „Uhrzeit“ auf 10 Uhr; Flüsterwald vom Waldeingang zum Feuer gehen; dann „Uhrzeit“ auf 23 Uhr, denselben Weg | zwischen unseren Bäumen abgestorbene Bäume und Kiefern mit Tuschelinie (im Schatten dicker, im Licht dünner) und Schatten am Boden; Bilder je Sekunde wie im Dorf | Bäume ohne Linie oder ohne Schatten, Nadeln als Vierecke, Bilder je Sekunde deutlich unter dem Dorf |
| 280.4 | Tom | 644a.2 | Reiter „Test“ → Stufe „−5“ bis Stufe 1; Thessas Laden öffnen; danach Stufe wieder hoch | Stücke über deiner Stufe stehen matt unter „Nicht tragbar“; was du schon trägst, bleibt angelegt; mit höherer Stufe rücken sie nach oben | alles tragbar, oder Getragenes fällt ab |
| 280.6 | Jerry | 633 | Reiter „Test“ → „Unsterblich“ an; unter „MARS-Probekampf“ Gegner „Krogg“, Stufe 3, „Probekampf starten“ und gewinnen | im Siegfenster unter der Beute „Kroggs Pranken“ | Krogg ohne sein Stück |
| 280.7 | Jerry | 1024 | Reiter „Test“ → „Bildrate“ an, dann einen Wolfskampf beginnen und die Ansage „Anspringen“ abwarten | die Schalter am rechten Rand (Kreuz, Schwert, Tempo, Würfel, Raster) liegen frei, keine Ansage über der Bildrate-Zeile | unterer Kasten verdeckt die Schalter halb, Ansage auf der Bildrate |
| 280.8 | Jerry | 935 | MARS-Probekampf mit „Tasche“ auf „Tränke, Flaschen“: Brandflasche werfen | die Flasche ist im Flug etwa so groß wie die Hand des Helden | winzig oder riesig |

## A · Reiter „Test“ und Hauptmenü

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 279.1 | Tom | 1020.1 | Reiter „Test“: oben unter „Prüfliste · Build 280“ eine Zeile antippen, „Passt“ oder „Falsch“ mit einem Wort; App schließen und neu öffnen; „Ergebnis kopieren“, im Chat einfügen | die Zeile klappt auf mit Richtig und Falsch; „Passt“ springt zur nächsten offenen; Haken und Kreuz mit Wort sind nach dem Neustart noch da; im Chat steht „Build 280 · Ergebnis“ mit je Zeile Haken oder Kreuz | keine Prüfliste, Ergebnis nach Neustart weg, Zwischenablage leer |
| 279.2 | Tom | 1020.1 | Hauptmenü → „Schnellstart · Wachsoldat“ | neues Spiel ohne Intro und Erschaffung, der Held steht erwacht in der Schenke; zurück im Hauptmenü zeigt „Weiter“ weiter deinen eigenen Spielstand. Noch nicht in 280: Volk und Geschlecht wählen, Start nach Aldrics Auftrag (dafür nach dem Schnellstart „Teleport“ und die Stationen 1–9 im Reiter „Test“); die Herkunft wählst du im Reiter „Test“ unter „Schnellstart“ | Intro läuft; dein Spielstand ist überschrieben |
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
