# Änderungshistorie

Alle Änderungen an „Chroniken von Bornim“, neueste zuerst. Jede Version ist als [Release](https://github.com/tramour-cmyk/androidapp_rpg_bornim/releases) mit fertiger APK verfügbar. Zeiten in Berliner Zeit.

## Unveröffentlicht

## v0.1.56 – 06.10.2026, 13:36

**Verbessert – Wolfsgeheul**
- Das Heulen klingt jetzt wie ein Wolf statt wie ein Gebläse: ein weicher, fast reiner Ton ohne Rauschen, der lauter wird, wenn er steigt, ungleichmäßig zittert und weich ausklingt. Dazu kommt ein Nachhall wie im Wald.
- Die drei Varianten sind ein langes Heulen, ein kurzer Ruf mit längerem, höherem Heulen und ein tiefes, klagendes Heulen mit Stimmsprung.

## v0.1.54 – 06.10.2026, 13:04

**Neu – Wolfsgeheul**
- Wölfe heulen wieder, aber nicht jedes Mal: manchmal beim Auftauchen und manchmal, wenn ein Jungwolf fällt oder flieht. Der Kopf geht hoch, das Heulen hält und klingt wieder ab.
- Drei verschiedene Heul-Geräusche, zufällig gewählt: ein langes Auf und Ab, ein kurzes abgesetztes und ein tiefes, zitterndes, jeweils mit leisem Waldecho. Sie laufen über die Lautstärke für Effekte.

## v0.1.53 – 06.10.2026, 12:46

- Keine Änderungen im Spiel; nur interne Vorschau-Werkzeuge.

## v0.1.52 – 06.10.2026, 12:41

**Behoben**
- Griff ein Jungwolf an, biss der Leitwolf in der Animation mit zu. Jetzt holt nur der Jungwolf aus und beißt zu, wenn sein Treffer gemeldet wird; der Leitwolf bleibt ruhig. Gleiches gilt für Rudel im alten Stil (Kobolde, Goblin-Späher).

## v0.1.51 – 06.10.2026, 12:31

**Verbessert – flüssigere Bewegungen**
- Der Wolf hat deutlich mehr Zwischenbilder bei gleichem Tempo: 16 statt 6 beim Atmen, 17 statt 9 bei Biss und Sprung, doppelt so viele bei Heulen und Treffer-Reaktion.
- Alle Bilder eines Gegners und seines Rudels werden zu Kampfbeginn im Hintergrund vorbereitet (bei schwerer Verletzung erneut), damit beim ersten Angriff nichts mehr ruckelt.

## v0.1.50 – 06.10.2026, 12:22

**Behoben**
- Wunden, Elite-Leuchten und Schimmer verschwanden schlagartig, sobald ein Gegner auf 0 TP fiel. Sie bleiben jetzt beim Zusammenbrechen sichtbar und verblassen mit dem Gegner.

## v0.1.49 – 06.10.2026, 12:00

**Neu – Kämpfe in neuer Grafik (Schritt 1: Wald und Wolf)**
- Kämpfe im Flüsterwald und im Tiefen Flüsterwald spielen in neuen Szenen: durchgehender Boden mit Tiefe statt Plattformen, Waldrand, Berge im Dunst, Baumstämme und Laub als Rahmen, Lichtstrahlen.
- Sechs Arten von Orten: Lichtung, Waldrand, Teich, umgestürzter Baum, Felsen und alter Steinkreis – je nachdem, wo auf der Karte der Kampf beginnt (am Wasser am Teich, bei Felsen zwischen Felsen).
- Tag, Abend und Nacht mit eigenem Himmel, Licht und Farben; nachts Sterne, Mond und Glühwürmchen. Der Tiefe Wald ist dunkler, mit geschlossenem Blätterdach, Nebel und Pilzen.
- Der Wolf ist neu gezeichnet: größer, düsterer, mit vier Fellvarianten (grau, schwarz, rostbraun, aschgrau), Narben und eingerissenen Ohren. Grimmzahn ist größer, schwarz, mit roten Augen.
- Flüssigere Bewegungen mit vielen Zwischenbildern: atmen in Ruhe, zwei Angriffsarten (Biss und Sprungangriff), Heulen, wenn das Rudel angreift, Zurückzucken bei Treffern.
- Held und Gegner werfen Schatten; auch in Höhle und Dorf gibt es keine Plattformen mehr.
- Elite-Gegner im neuen Stil leuchten pulsierend entlang ihres Umrisses in der Farbe ihrer Eigenschaft. Schimmernde Wölfe haben silberblaues Fell, Glitzer um den Körper und einen Lichtschimmer, der regelmäßig über das Fell wandert.
- **Blut bei Treffern** (dezent), im Menü unter „System“ einstellbar: Aus, Dezent oder Deutlich (mit Spritzern am Boden). Skelette splittern, Untote verlieren dunkle Brühe, der Schleim spritzt.
- Man sieht, wie schwer ein Gegner verletzt ist: Je weniger Lebenspunkte er hat, desto mehr Blut spritzt bei Treffern. Unter der Hälfte zeigen sich Wunden am Körper, unter einem Viertel mehr davon, mit frischem Blut (Skelette bekommen Risse, Untote dunkle Flecken). Schwer verletzte Gegner atmen schneller; der Wolf lässt den Kopf hängen und schont eine Vorderpfote. Bei „Blut: Aus“ bleibt nur die Haltung.

## v0.1.41 – 06.10.2026, 07:49

**Verbessert**
- Die Leiste oben hat jetzt immer dieselbe Höhe, auch wenn Zustände wie Gift oder Satt dazukommen oder wegfallen. Die Karte springt dadurch nicht mehr.

## v0.1.40 – 06.10.2026, 07:43

**Geändert – Anzeige als feste Leiste**
- Lebens-, Zauber- und Erfahrungsbalken, Tag und Uhrzeit, Zustände und die Tasche sitzen jetzt in einer festen Leiste über der Karte. Sie überdeckt keinen Teil der Karte mehr, auch nicht am oberen Rand (z. B. am Höhleneingang).
- Die Karte scrollt dafür wieder nur bis zu ihrem Rand, ohne dunklen Streifen.

## v0.1.34 – 06.10.2026, 07:18

**Verbessert – mehr Sicht auf der Karte**
- Die Anzeige oben rechts ist deutlich flacher: Lebens-, Zauber- und Erfahrungsbalken links, Tag und Uhrzeit sowie offene Attributspunkte und Zustände rechts daneben, die Tasche etwas kleiner.
- Am oberen Kartenrand scrollt die Karte ein Feld weiter, sodass die oberste Reihe (z. B. der Schlagbaum oder der Höhleneingang) nicht mehr unter der Anzeige verschwindet.

## v0.1.33 – 06.10.2026, 07:03

**Behoben**
- Nach jedem Stufenaufstieg kam der Hinweis, Attributspunkte zu verteilen, auch wenn es gar keine gab. Er erscheint jetzt nur noch auf den Stufen mit neuen Punkten (4, 8, 12, 16, 19) und nennt die richtige Anzahl.
- Im Laden brach der gewählte Reiter („▶ Verkaufen“) in zwei Zeilen um. Der Pfeil vor gewählten Reitern und Knöpfen ist jetzt überall weg; die Auswahl zeigt einheitlich die gelbe Reiterfarbe.

**Geändert – Zaun am Schlagbaum**
- Statt eines langen Zauns quer durchs Dorf führt jetzt links und rechts vom Weg je ein kurzer Zaun vom Waldrand hinunter zum Schlagbaum. Der Norden des Dorfes bleibt offen.
- Wache Jorin geht seine Runde direkt vor dem Schlagbaum und ist dabei immer gut zu sehen. Vorher verschwand er zeitweise hinter den Dächern.
- Das Schild „Norden: Flüsterwald“ steht ein Feld rechts vom Zaun, frei neben dem Weg.

## v0.1.28 – 05.10.2026, 20:53

**Neu – Schlagbaum am Nordweg**
- Am Nordrand von Bornim sperren jetzt ein rot-weißer Schlagbaum und ein Dorfzaun den Weg in den Flüsterwald.
- Nach dem Gespräch mit Ältestem Aldric öffnet **Wache Jorin** den Schlagbaum, wenn du ihn ansprichst. Danach bleibt der Weg dauerhaft frei. Das Ziel im Menü weist darauf hin.
- Läufst du gegen den geschlossenen Schlagbaum, erfährst du, was fehlt.
- **Jorin geht Streife:** Er läuft am Zaun entlang, bleibt am Weg stehen und schaut nach Norden. Sprichst du ihn an, bleibt er stehen.
- Wer die Quest in einem bestehenden Spielstand schon hat, findet den Schlagbaum offen.

## v0.1.27 – 05.10.2026, 20:29

**Geändert – Namen mit Fantasy-Klang**
- Die Bewohner von Bornim tragen jetzt Namen, die besser in eine Fantasy-Welt passen:
  - Wirtin Berta → **Rowena**, Händlerin Tilda → **Thessa** („Thessas Kramladen“), Bruder Odo → **Bruder Osric**
  - Kräuterfrau Hedda → **Morwen**, Jäger Wilhelm → **Garrick**, Bauer Ludwig → **Bram**
  - Greta → **Gwenna**, Lene → **Liska**, das Dorfkind Finn → **Pim**
- Verschlossene Häuser: Bäcker Anton → **Edrik**, Schmied Bruno → **Dorran**; in der kleinen Hütte wohnt jetzt der **alte Kael**.
- Aldric, Jorin, Borin, Lyra und die Bosse behalten ihre Namen. Spielstände bleiben gültig.

## v0.1.26 – 05.10.2026, 20:10

**Neu – die Figur zeigt deine Ausrüstung**
- Dein Held sieht auf der Karte so aus, wie er ausgerüstet ist: Helm, Kapuze oder Reif, die Art der Rüstung (Stoff, Leder, Kette, Platte), Umhang, Waffe in der Hand (Schwert, Dolch, Axt, Streitkolben, Stab, Zauberstab, Bogen, Speer) und Schild.
- Höhere Seltenheit färbt Metall und Säume ein; wer etwas Episches oder Göttliches trägt, funkelt.
- Seitlich gehaltene Waffen zeigen nach vorn, statt das Gesicht zu verdecken.
- Gilt überall: auf der Karte, in der Spielstand-Übersicht, im Reiter „Held“ und schon bei der Charaktererstellung mit der Startausrüstung.

## v0.1.25 – 05.10.2026, 20:00

**Neu – drei Spielstand-Plätze**
- Bis zu drei Helden lassen sich parallel spielen.
- **Titelbild:** „Fortsetzen“ lädt den zuletzt gespielten Helden und zeigt Name und Stufe. Neu ist der Knopf **„Spielstände“** mit einer Übersicht aller Plätze: Held, Volk, Klasse, Stufe, Ort, Spieltag und Zeitpunkt des letzten Speicherns, dazu „Laden“ und „Löschen“ (mit Sicherheitsabfrage). Auf einem leeren Platz startet „Neues Spiel“ direkt dort.
- **Neues Spiel** belegt den ersten freien Platz. Sind alle drei belegt, wählst du, welcher Held ersetzt wird.
- Der bisherige Spielstand wird beim ersten Start automatisch auf Platz 1 übernommen.

**Sonstiges**
- Merkliste: Anmeldung mit Google Play (Cloud-Spielstände, Erfolge) samt Voraussetzungen ergänzt.

## v0.1.24 – 05.10.2026, 19:46

**Neu – Sicherheitsabfragen**
- **Wegwerfen** in der Tasche fragt nach und nennt, was ein Händler für den Gegenstand zahlen würde.
- **„Gewöhnliche verkaufen“** im Laden fragt nach und zeigt alle betroffenen Gegenstände samt Gesamterlös.
- **Neues Spiel** über einen vorhandenen Spielstand fragt immer nach, bevor der alte Held überschrieben wird (vorher geschah das ohne Warnung).
- Neue Einstellung **„Sicherheitsabfragen: An/Aus“** im System-Reiter (für Wegwerfen und Sammelverkauf; die Abfrage beim Überschreiben des Spielstands bleibt immer aktiv).

## v0.1.23 – 05.10.2026, 18:46

**Neu – ein schöneres Bornim (Teil 2)**
- **Ein Bach** fließt durch den Süden des Dorfs, mit runden Ufern und einer Holzbrücke an der Hauptstraße. Er ersetzt den eckigen Teich; Greta angelt jetzt am Bach.
- **Südlicher Dorfrand:** eingezäunter Gemüsegarten mit Kohl und Möhren, ein goldenes Getreidefeld, Heuballen und **Hühner**, die um die Ballen scharren.
- **Wäscheleine** mit bunter Wäsche bei Gretas Haus.
- **Zwei neue Bewohner:** Bauer Ludwig an seinem Feld und Lene an der Wäscheleine, jeweils mit eigenen Sätzen vor und nach dem Ende von Kapitel 1.
- Felder, Beete, Heuballen und Wäsche lassen sich ansehen.
- Wasser hat jetzt überall runde Ufer statt eckiger Kanten (auch im Wald).

## v0.1.22 – 05.10.2026, 18:41

**Neu – ein schöneres Bornim (Teil 1)**
- **Größeres Dorf** (36 × 28 statt 24 × 20 Felder) mit gepflastertem **Dorfplatz**: Brunnen in der Mitte, vier Marktstände (Obst, Stoffe, Kräuter), Bänke und Laternen, die nachts leuchten.
- **Verschiedene Häuser:** rote Ziegel, blauer und grauer Schiefer, Stroh oder Holzschindeln; Fachwerk, Naturstein oder Holzbretter; Fensterläden in verschiedenen Farben, Brennholz an der Wand, Schornsteine mal links, mal rechts.
- **Gebäude mit Charakter:** Gasthaus mit Wirtshausschild und Fässern, Tildas Laden mit gestreifter Markise, Tempel aus hellem Stein mit Glockenturm und Bogenfenstern.
- **Fünf neue Wohnhäuser** von Bäcker Anton, Schmied Bruno, Greta, Finns Familie und eine kleine Hütte. Sie sind vorerst verschlossen, ein kurzer Text verrät, wer dort wohnt.
- Marktstände, Laternen, Fässer und Bänke lassen sich ansehen.
- Alte Spielstände: Steht der Held an einer Stelle, die jetzt bebaut ist, wird er auf das nächste freie Feld gesetzt.

## v0.1.21 – 05.10.2026, 17:09

**Neu – jedes Attribut zählt**
- **Erklärung im Heldenreiter:** Tippt man auf ein Attribut, steht dort, was es bringt, mit den aktuellen Zahlen.
- **Charisma:** pro Punkt 5 % günstiger einkaufen und teurer verkaufen (höchstens 20 %, bei negativem Modifikator umgekehrt). Normale Gegner zögern mit 8 % Chance pro Punkt eingeschüchtert und verlieren ihre erste Runde.
- **Intelligenz:** Ab INT 12 erkennt der Held zu Kampfbeginn Schwächen, Resistenzen und Immunitäten des Gegners. Pro Punkt 10 % Chance auf einen zusätzlichen Trank beim Brauen und 3 % mehr Erfahrung.
- **Weisheit:** pro Punkt ein halbes Feld mehr Sicht im Nebel, 15 % seltener Hinterhalte (bis 60 %) und 15 % Chance auf ein zusätzliches Kraut.
- **Stärke:** Wurfgeschosse (Alchemistenfeuer, Weihwasser) bekommen den Stärke-Modifikator als Bonusschaden.
- **Geschicklichkeit:** Schleichen: Jagende Monster bemerken den Helden pro 2 Punkte ein Feld später (normal 4, mindestens 2).
- **Konstitution:** Gift und Blutung klingen nach dem Kampf pro Punkt eine Runde schneller ab; Mahlzeiten heilen zusätzlich den Modifikator.

**Neu – Version sichtbar**
- Titelbild und System-Reiter zeigen die genaue installierte Version mit Unternummer und Build-Nummer (vorher stand dort immer „v0.1“).

**Sonstiges**
- Neue [Merkliste](docs/MERKLISTE.md) mit allen bisher nicht umgesetzten Ideen.

## v0.1.20 – 05.10.2026, 16:51

**Geändert – Blumenwiesen und Heilkräuter**
- **Echte Blumenwiesen:** Statt einzelner, kaum erkennbarer Felder gibt es im Flüsterwald drei und im Tiefen Flüsterwald fünf Wiesen aus 4–7 Feldern. Die Blüten sind dichter, größer und bunter, gut sichtbar auch auf dem Handy.
- **Heilkräuter sieht man jetzt:** Wo Kräuter wachsen, steht eine hellgrüne Heilpflanze mit weißer Blüte (etwa auf jedem zweiten Wiesenfeld). Drüberlaufen pflückt sie, dann ist sie weg und wächst am nächsten Tag nach. Kein Glücksspiel mehr wie vorher (50 % Zufall pro Feld).
- **Hedda** erklärt jetzt genau, wo die Kräuter wachsen und woran man sie erkennt.

## v0.1.19 – 05.10.2026, 16:28

**Geändert – Spielbalance** (per Kampfsimulation für alle vier Klassen abgestimmt)
- **Point-Buy bei der Charaktererstellung:** 24 Punkte frei verteilen, Werte 8–15 vor Volksbonus (14 kostet 7, 15 kostet 9 Punkte). Der Knopf „Vorschlag“ verteilt passend zur Klasse. Neue Helden starten damit etwas kleiner als bisher.
- **Attributspunkte wie im SRD:** je 2 Punkte auf Stufe 4, 8, 12, 16 und 19 statt 1 Punkt auf jeder Stufe.
- **Feuerball:** nur noch einmal pro Kampf. Begleiter (Rudel, Späher, Leibwache) fliehen nur noch, wenn ihr Rettungswurf misslingt.
- **Beute nach Kapiteln:** In Kapitel 1 ist normale Beute bis Stufe 2 gewöhnlich, danach nur gelegentlich ungewöhnlich. Bosse, Eliten, Truhen und schimmernde Monster geben höchstens „selten“. Bessere Seltenheiten kommen mit späteren Kapiteln. Bosse lassen ein Highlight und etwas normale Beute fallen statt drei bis vier seltener Gegenstände. Tildas Laden führt in Kapitel 1 höchstens Ungewöhnliches.
- **Obergrenzen für Ausrüstung:** In Kapitel 1 bringt alle Ausrüstung zusammen höchstens +1 je Attribut, auf Angriff, Zauberangriff und RK sowie +2 Schaden. Im Heldenreiter markiert ein Sternchen, wenn deine Ausrüstung mehr könnte.
- **Story-Gegenstände aus Kapitel 1** (Glutstab, Klinge von Bornim, Graks Kriegsaxt, Grimmzahns Fang usw.) sind jetzt „selten“ mit kleineren Werten.
- **Normale Monster** wachsen mit der Heldenstufe stärker mit (TP), damit Kämpfe auf Stufe 5–6 nicht nach einer Runde vorbei sind. Bosse bleiben wie bisher.
- **Schurke:** „Unglaubliches Ausweichen“ halbiert ab Stufe 5 den ersten Treffer in jeder Runde (vorher nur einmal pro Kampf).
- **Bestehende Spielstände:** Beim Laden werden die Attributspunkte nach der neuen Regel neu berechnet (zu viel Verteiltes wird zurückgenommen, zuerst beim am stärksten gesteigerten Attribut), und die Story-Gegenstände werden angepasst. Ein Hinweis erscheint einmalig.

## v0.1.18 – 05.10.2026, 15:55

**Geändert**
- Gegenstandsbeschreibungen wiederholen die Werte nicht mehr (vorher z. B. „heilt 2W4+2“ und darunter „Heilt 2W4+2 TP.“). Stattdessen steht dort, was der Wert nicht verrät: etwa dass der Kräutertrank alle Zustände heilt oder Alchemistenfeuer in Brand setzt.

## v0.1.17 – 05.10.2026, 15:50

**Fehlerbehebungen**
- Heddas Laden zeigt jetzt schon beim ersten Besuch den Reiter „Brauen“ und keine Ausrüstung mehr (vorher erst ab dem zweiten Gespräch).

## v0.1.16 – 05.10.2026, 15:30

**Neu – Zutaten**
- **Beute von Tieren:** Wölfe lassen Fleisch und Wolfsfelle fallen, Wildschweine Fleisch und Keilerhauer, Riesenratten manchmal Fleisch, Riesenspinnen Giftdrüsen, Riesenfledermäuse Flügel. Grimmzahn hinterlässt immer Fell und Fleisch.
- **Braten am Lagerfeuer:** Beim Rasten an einem Lagerfeuer wird mitgebrachtes Fleisch gebraten. Gebratenes Fleisch heilt 2W4+2 TP und stärkt für den nächsten Kampf (+1 auf Angriffe und Schaden, oben rechts als „Satt“ angezeigt). Man kann es auch verkaufen.
- **Heilkräuter:** Auf Blumenwiesen im Wald wachsen Kräuter; jede Wiese kann einmal am Tag abgeerntet werden. Im Flüsterwald gibt es dafür neue Blumenwiesen.
- **Brauen bei Hedda:** Neuer Reiter „Brauen“ in Heddas Laden: Heiltrank (2 Kräuter + 5 Gold), Kräutertrank (2 Kräuter + 2 Gold), Großer Heiltrank (3 Kräuter + Fledermausflügel + 15 Gold), Alchemistenfeuer (Giftdrüse + 5 Gold).
- Felle, Hauer und alle anderen Zutaten lassen sich bei Tilda und Hedda verkaufen.
- Hedda verkauft keine Ausrüstung mehr (vorher erschien dort Tildas Sortiment).

## v0.1.15 – 05.10.2026, 15:25

**Neu**
- **Wolfsrudel:** Ein Wolf kommt mit ein oder zwei Jungwölfen, die im Kampf von der Seite zuschnappen.
- **Goblin mit Späher:** Goblins haben einen Späher dabei, der aus dem Hintergrund Pfeile schießt.
- **Grimmzahns Leibwache:** Zwei Wölfe begleiten den Leitwolf, auf der Karte und im Kampf.
- Wie beim Kobold-Rudel gilt: Fällt der Anführer, fliehen die Begleiter, und ein Feuerball verjagt sie sofort. Begleiter bringen etwas mehr Erfahrung.
- **Stufengrenze in Kapitel 1:** Der Held steigt in Kapitel 1 höchstens bis Stufe 6, damit die Bosse eine Herausforderung bleiben. Weitere EP werden aufgehoben und ab Kapitel 2 angerechnet. Kampf und Heldenreiter zeigen „Höchststufe für Kapitel 1 erreicht“. Das Testmenü kann weiterhin jede Stufe einstellen.

**Geändert**
- Damit Rudel nicht zu schwer werden, haben Wolf und Grimmzahn etwas weniger TP (per Simulation abgestimmt).

## v0.1.14 – 05.10.2026, 15:16

**Neu**
- **Zustände wirken nach dem Kampf weiter:** Gift und Blutung kosten auf der Karte alle 4 Schritte ein bis drei TP, bis sie abklingen. Der Held fällt dadurch nie unter 1 TP. Ein Fluch („Geschwächt“) bleibt, bis man rastet, schläft, einen Kräutertrank trinkt oder Bruder Odo aufsucht, und gilt auch im nächsten Kampf. Brand, Betäubung, Verlangsamung und Blendung enden mit dem Kampf.
- **Anzeige oben rechts:** Balken für TP, ZP (bei Zauberkundigen) und den Fortschritt zur nächsten Stufe (EP), dazu farbige Schilder für anhaltende Zustände.
- Den Kräutertrank kann man jetzt auch mit vollen TP trinken, wenn ein Zustand auf dem Helden liegt.

**Geändert**
- Der Tastenton im Menü ist leiser und weicher.

## v0.1.13 – 05.10.2026, 15:00

**Geändert**
- Nächtliches Grillenzirpen klingt natürlicher und leiser (vorher erinnerte es an ein altes Handyklingeln).

## v0.1.12 – 05.10.2026, 14:56

**Neu**
- **Kämpfe bei Abend und Nacht:** Im Freien passt sich der Kampfhintergrund der Tageszeit an – in der Dämmerung mit rosa-violettem Himmel, nachts mit dunklem Sternenhimmel und Mondsichel. Held und Monster werden passend getönt. In der Höhle bleibt alles wie bisher.

## v0.1.11 – 05.10.2026, 14:48

**Neu**
- **Nebel des Unbekannten** in Wald und Höhle: Unerkundetes ist schwarz, Gesehenes bleibt abgedunkelt sichtbar. Der Held sieht in einem Kegel von 160° in Blickrichtung etwa 5 Felder weit (nachts und in der Höhle 4) und rundum ein Feld; Bäume, Felsen und Wände verdecken die Sicht. Monster sieht man nur, wenn sie im Blick sind – das „!“ eines Verfolgers hört man aber auch aus dem Nebel. Erkundetes wird gespeichert. Antippen zum Hinlaufen geht nur in bereits erkundetes Gebiet.
- **Tiefer Flüsterwald:** neues, gut doppelt so großes Gebiet östlich des Flüsterwalds (Ausgang beim Jägerlager), Gebietsstufe 2, 13 umherstreifende Monster, nachts Untote und Ghule, vier Truhen.
- **Kräuterfrau Hedda** am Lagerfeuer im Tiefen Flüsterwald: verkauft Tränke und Kräutertränke; ihr Kräuterrauch macht das Lager zur Schutzzone.
- **Grimmzahn, der Leitwolf:** optionaler Boss im Norden des Tiefen Flüsterwalds mit eigenem Beutestück „Grimmzahns Fang“ (episches Amulett mit Blutungschance). Lässt sich im Testmenü mit „Bosse zurücksetzen“ erneut herausfordern.

## v0.1.10 – 05.10.2026, 14:28

**Fehlerbehebungen**
- Ausrüstungsreiter: Nach dem Ablegen eines Gegenstands wird die Ausrüstungsgrafik sofort aktualisiert (vorher blieb das alte Bild stehen).
- Tasche und Laden: Die Pfeile ▲/▼ (besser/schlechter als das Angelegte) sind nach dem Anlegen sofort aktuell.

## v0.1.9 – 05.10.2026, 14:19

**Neu**
- **Kobold-Rudel:** Kobolde kommen mit ein oder zwei sichtbaren Begleitern. Diese stehen im Kampf hinter dem Anführer und stechen mit zu; fällt der Anführer, fliehen sie. Ein Feuerball verjagt das Rudel sofort. Auf der Karte laufen Kobolde als Grüppchen. (Ersetzt den bisherigen unsichtbaren „Vorteil“-Wurf.)
- **Schutzzonen:** Am Lager von Jäger Wilhelm, an den Waldausgängen und am Höhleneingang greifen keine Monster an und es gibt keine Hinterhalte. Am Lager erscheint der Hinweis „Jäger Wilhelm schwenkt seine Fackel – die Biester weichen zurück!“.
- **Ein- und Zweihänder erkennbar:** „2H“-Plakette am Symbol, „Zweihändig“/„Einhändig“/„Nebenhand“ im Untertitel, eigene Zeile in den Details und Warnung, was beim Anlegen abgelegt wird.

**Geändert**
- Monster sehen den Helden erst ab 4 Feldern (vorher 5) und verfolgen ihn etwas langsamer.
- Verfolger geben auf, wenn der Held mehr als 7 Felder Vorsprung hat oder sie mehr als 9 Felder von ihrem Revier entfernt sind.

**Fehlerbehebungen**
- Monster, die die Verfolgung abbrechen, kehren zu ihrem Startpunkt zurück, statt am Abbruchpunkt stehen zu bleiben.

## v0.1.8 – 05.10.2026, 13:25

**Neu – lebendige Welt**
- **Tag und Nacht:** Eine Spielstunde dauert eine Minute; Uhrzeit und Tag stehen oben rechts. Nachts wird es dunkel, um den Helden liegt ein Laternenschein, Fenster und Lagerfeuer leuchten.
- **Nachtmonster:** Nachts streifen Skelette, Zombies und Fledermäuse durch den Wald.
- **Schlafen:** Nachts kann man im Gasthaus-Bett bis zum Morgen schlafen (volle TP und ZP).
- **Dorfleben:** Finn und Greta laufen im Dorf umher und bleiben stehen, wenn man neben ihnen steht.
- **Kleinigkeiten:** Schmetterlinge, auffliegende Vögel, Schornsteinrauch, Glühwürmchen, fallende Blätter, gelegentlicher Regen.
- **Umgebungsgeräusche:** Vögel am Tag, Grillen und Eule in der Nacht, Tropfen in der Höhle.
- **Testmenü:** „Uhrzeit +3 h“ und „Regen an/aus“.

## v0.1.7 – 05.10.2026, 13:11

**Neu – sichtbare Monster**
- Monster streifen sichtbar durch Wald und Höhle:
  - **Jäger** (Wolf, Goblin, Ghul, Skelett …) entdecken den Helden mit rotem „!“ und Signalton und verfolgen ihn.
  - **Lauerer** (Spinne, Fledermaus, Gallerte) warten versteckt und springen erst aus der Nähe heran.
  - **Wanderer** ziehen friedlich umher.
- **Erstschlag:** Wer ein Monster von hinten angreift, überrascht es (es setzt eine Runde aus). Wer von hinten erwischt wird, gerät in einen **Hinterhalt**.
- Elite-Monster leuchten schon auf der Karte in ihrer Farbe, schimmernde funkeln.
- Antippen eines Monsters greift es an; die Aktionstaste zeigt dann gekreuzte Schwerter.
- Ist der Held der Gegend weit überlegen, weichen normale Monster aus.
- Besiegte Monster kehren nach 60 Schritten zurück.

**Geändert**
- Zufallskämpfe gibt es nur noch sehr selten (0,4 % pro Schritt im hohen Gras), immer als Hinterhalt mit eigenem Klang.

## v0.1.6 – 05.10.2026, 13:02

**Neu – Statuseffekte**
- Sieben Zustände mit Rundenzähler, als farbige Schilder an den Lebensbalken: Vergiftet, Brennend, Blutend, Betäubt, Verlangsamt, Geschwächt, Geblendet.
- Quellen:
  - **Monster:** Spinnengift und Netz, Ghul-Lähmung (Elfen immun), Schamanenfluch und Feuerpfeil, Fledermaus blendet, Stirge und Grak lassen bluten, Krogg betäubt.
  - **Kritische Treffer** – Klingen lassen bluten, Wuchtwaffen betäuben (für Held und Monster).
  - **Zauber:** Feuerzauber und Alchemistenfeuer setzen in Brand, Heilige Flamme kann blenden.
  - **Elite-Eigenschaften:** Giftig, Glühend.
- Neue Eigenschaften auf Ausrüstung: Gift-, Blutungs- und Betäubungschance, Standhaftigkeit (wehrt Zustände ab).
- Neuer **Kräutertrank** im Laden (20 Gold): heilt alle Zustände.

**Geändert**
- Spinnengift wirkt jetzt über mehrere Runden statt als Sofortschaden.
- Giftige und glühende Eliten abgeschwächt, damit sie nicht zu hart sind.

## v0.1.5 – 05.10.2026, 12:45

**Geändert**
- Reiter „Held“: Der Anteil der Ausrüstung an jedem Attribut steht blau neben dem Wert.

**Fehlerbehebungen**
- Testmenü: Beim Herabstufen werden zu viel verteilte Attributspunkte zurückgenommen (zuerst beim am stärksten gesteigerten Wert). Ein Held auf Stufe X hat danach genau X − 1 Punkte.

## v0.1.4 – 05.10.2026, 11:23

**Geändert**
- „Über das Spiel“: neue Beschreibung, passend zum README.

## v0.1.3 – 05.10.2026, 11:15

- Nur README (neue Kurzbeschreibung); die App ist unverändert zu v0.1.2.

## v0.1.2 – 05.10.2026, 11:09

**Geändert**
- APK mit eigenem, dauerhaftem Signierschlüssel. Einmalig v0.1.1 deinstallieren, danach funktionieren Updates normal.

## v0.1.1 – 05.10.2026, 10:45

**Neu**
- Umzug in dieses Repository. Funktionsumfang wie der letzte Stand des Vorgängerprojekts (siehe unten).
- Eigene App-Kennung `de.bornim.game`: Die App wird als neue App installiert, alte Spielstände werden nicht übernommen.
- Signiert noch mit einem temporären Schlüssel.

---

## Vorgeschichte (Vorgängerprojekt, bis 05.10.2026)

Die Entwicklung begann in einem früheren Repository. Die wichtigsten Schritte bis zum Umzug:

1. **Grundspiel:** Kapitel 1 „Der Blutzahn-Stamm“ (Dorf, Flüsterwald, Blutzahnhöhle, Krogg und Hauptmann Grak), 5 Völker, 4 Klassen, vereinfachte Regeln nach SRD 5.1, rundenbasierte Kämpfe, Deutsch und Englisch, Speichern und Laden.
2. **Spielgefühl:** flüssige Bewegung, volle Heilung beim Stufenaufstieg, Attributspunkte mit Bestätigung, Ladenkauf mit Gegenstandsdetails.
3. **Musik und Grafik:** lizenzfreie, selbst komponierte Musik (Oberwelt, Kampf, Bosskampf, epische Titelmusik), abschaltbar; Grafik in 32 px mit Schrägansicht; Copyright auf dem Titelbild.
4. **Beutesystem:** 9 Ausrüstungsplätze, Ein- und Zweihänder, Kampf mit zwei Waffen, zufällige Eigenschaften, 6 Seltenheitsstufen von gewöhnlich bis göttlich, Elite-Gegner, mitwachsende Monster.
5. **Klang und Kampf:** neu synthetisierte Musik, 26 Soundeffekte, Kampfanimationen mit Variationen.
6. **Name:** Das Dorf und das Spiel heißen jetzt Bornim.
7. **Fehlerbehebung:** TP-Anzeige oben rechts aktualisiert nach Lagerfeuer oder Heilung beim Priester.
8. **Neue Kampfgrafik:** 64-px-Monster mit Licht, Schatten und Animationen; Varianten pro Begegnung; Held zeigt seine Ausrüstung; 8 neue Monsterarten (insgesamt 17); Elite-Eigenschaften mit Aura; schimmernde Varianten.
9. **Testmenü** (7-mal auf das Copyright tippen); Eliten erst ab Heldenstufe 2.
10. **Touch-Steuerung:** Ziehen und Tippen zum Laufen, Aktionstaste mit Symbol statt A/B, klassisches Steuerkreuz als Option.
