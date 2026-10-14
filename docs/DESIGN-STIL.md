# Stil-Leitlinien

Wie das Spiel aussieht, klingt und sich spielt: die Einzelheiten zum [Leitbild](DESIGN-LEITBILD.md). Wie gebaut und geprüft wird (Abnahme „Ort fertig“, selbst prüfen, alte Ansicht), steht in [Abnahme](DESIGN-ABNAHME.md). Gilt für **alle** künftigen Arbeiten an Grafik, Animation und Klang.

Siehe auch: [Offen](ARBEIT-OFFEN.md) · [Merkliste](LISTE-IDEEN.md) · [Änderungshistorie](../CHANGELOG.md)

## Richtung

- **Unser Stil ist die lebendige Diagonalwelt** (Nutzer 14.10.): Details, Mikrobewegungen, Licht aus Quellen, Klang. Alles andere richtet sich daran aus, auch Standbilder der Zwischensequenzen und Kampf (79). „Dieselbe Welt“ heißt gleiche Farben, Formen, Licht und Stimmung, nicht derselbe Blickwinkel.
- **Weg vom Nintendo- und Pokémon-Stil** (knuffig, quietschbunt, Spielzeug), **hin zu erwachsener, etwas düsterer Fantasy.**
- Bessere Grafik: echte Formen, Licht und Schatten, glaubwürdige Proportionen (Körpermaße, Waffengrößen nach realen Vorbildern).
- Bessere Übergänge: keine Sprünge zwischen Haltungen, Bewegungen gehen fließend ineinander über.
- Licht kommt von sichtbaren Quellen (Sonne, Mond, Fackeln, Feuer, Pilze, Fenster). Dunkelheit ist erlaubt.
- **Monster sind düster und gefährlich:** böse Mäuler, große Zähne und Klauen, Narben, glühende oder tote Augen, zerfetzte Kleidung. Nie niedlich, nie knuffig.
- Blut und Wunden gehören dazu, abgestuft über die Menüeinstellung „Blut bei Treffern“ (Aus, Dezent, Deutlich), für Held und Gegner gleich.

## Abwechslung: mindestens drei Varianten

- **Kein Gegner sieht aus wie der vorige seiner Art.** Jede Gegnerart bekommt mindestens drei Varianten in Aussehen und Ausrüstung, zum Beispiel ein Goblin mit Krummsäbel und Schild, einer mit Speer, einer mit Keule und Helm. Dazu kommen Hautton, Fell oder Narben.
- **Die Werte bleiben gleich:** Varianten sind Optik. Schaden, Rüstungsklasse und Trefferpunkte kommen aus den Monsterdaten.
- **Jede Bewegung in mindestens drei Varianten:** Angriff, Treffer, Ausweichen und Sieg oder Niederlage, damit Kämpfe nicht gleichförmig wirken. Das gilt für Gegner wie für den Helden.
- **Kein Gegner verschwindet einfach:** Jede Gegnerart bekommt eigene Sterbeanimationen (mindestens drei), erst danach blendet sie aus. Ein tödlicher kritischer Treffer bekommt einen eigenen Killerschlag (Erweiterungen in der [Merkliste](LISTE-IDEEN.md) „Sonstiges“).
- **Größe und Körperbau variieren** im Rahmen des SRD, zum Beispiel Goblins 98–118 cm (Small), Skelette 160–185 cm, dazu schlank, normal oder kräftig. Größe, Körperbau, Ausrüstung und Hautton werden unabhängig voneinander gewählt.
- Die Variante wird beim Kampfbeginn aus dem Erscheinungsbild-Zufall des Gegners gewählt und bleibt für diesen Gegner im ganzen Kampf gleich.
- **Ausnahme einmalige Monster:** Bosse und andere einzigartige Monster (etwa Krogg, Grak, Grimmzahn) erscheinen nur in einer Form, ohne Varianten in Aussehen und Ausrüstung, damit man sie wiedererkennt; ihre Bewegungen haben trotzdem je drei Varianten.
- Gilt für alle künftigen Gegner, Tiere, Begleiter und Figuren.

## Lebendige Welt: keine Figur steht starr

Wunsch des Nutzers (09.10.): Wer auf der Karte steht, lebt. Jede Figur, auch der Held, atmet, verlagert ab und zu das Gewicht, schaut kurz zur Seite oder stützt die Hände in die Hüften (Baustein `MapRest`, bekommen neue Figuren automatisch). Figuren mit eigener Aufgabe bekommen eigene Handlungen obendrauf (Garrick: Hände am Feuer wärmen, in den Wald spähen).

- Nie im Takt: Ob, wann, was und wie lange, entscheidet der Zufall, mit eigenem Startwert je Figur, damit zwei Figuren nebeneinander nie gleichzeitig dasselbe tun. Ein gleichmäßiger Rhythmus wirkt wie ein Roboter.
- Figuren schauen den Helden an, wenn er nahe ist (bis 3 Felder), verlieren aber nach etwa 10 s Stillstand das Interesse (5la.3, Nutzer 13.10.).
- Haltungen vorher in allen Blickrichtungen prüfen (vorn, schräg, Seite, hinten); was von einer Seite falsch aussieht, fliegt raus.
- Auch Orte leben (Regel des Nutzers, 10.10., 6f): Räume, Dorf und Wald sollen lebendig wirken, nicht wie eine Kulisse. Licht flackert, Rauch steigt, Staub tanzt im Lichtstrahl, Dinge liegen so, als hätte gerade jemand sie benutzt. Grundstimmung düster durch Licht und Schatten, nicht durch Dunkelheit.
- **Effekte aktiv anbieten (44d, Nutzer 12.10.):** Rauch, Funken, Staub im Licht, Vögel, Regen und Ähnliches unterstreichen die Lebendigkeit. Tom und Jerry schlagen sie bei jedem neuen Ort und jeder neuen Figur von sich aus vor (Standbilder), statt zu warten, bis sie fehlen.

## Karte und Räume (diagonale Sicht)

Aus den Rückmeldungen des Nutzers bis 11.10. (Verlauf im [Archiv](ARBEIT-ARCHIV.md)):
- **Ausrüstung unterwegs:** Waffen geschultert (nie am Boden schleifend), Schild auf dem Rücken, Zweitwaffe in der Scheide. Im Kampf wie gehabt.
- **Sichtbarkeit (Thema 43, Nutzer 12.10.):** Was in der alten Ansicht rechts gut zu sehen war, steht diagonal vorn unten zwischen Kamera und Geschehen.
  - **Wichtiges steht frei:** Leute, Questziele, Eingänge, Schilder, Feuerstellen haben freien Blick; zur Kamera hin (Süden, Osten) nichts Hohes davor. Sonst umstellen (das Ding oder die Bäume davor); die Karte muss nur diagonal stimmen.
  - **Durchsicht nur um den Helden:** Kronen, Felsen, Büsche und hohe Möbel in einem kleinen Umkreis um den Helden fast ganz durchsichtig, nicht gestapelt, damit er nie verschwindet.
  - **Verstecktes erwünscht:** Kisten und Kleinkram dürfen unter Bäumen liegen und tauchen erst auf, wenn der Held hingeht (Belohnung fürs Erkunden); keine Durchsicht für sie aus der Ferne.
- **Maßstab:** Höhen im Maßstab des Helden (ein Tisch steht etwa hüfthoch neben ihm). Waagerechte Kreise (Fass, Eimer, Becken) sind in der diagonalen Sicht Ellipsen 2:1, ihr Schatten ebenso.
- **Räume:** eher klein und dicht als groß und leer; jeder Ort hat eigene Möbel, die zu seinem Bewohner passen (Pult und Truhe beim Ältesten, Ladentisch und Waren bei Thessa, Altar und Bänke im Tempel), je drei Varianten. Mehrteilige Möbel (Altar, Theke, Bett über mehrere Felder) haben durchgehend dieselbe Variante. Licht von Herd, Kerze und Fenster; Gebrauchsspuren.
- **Karte und Kampfort gehören zusammen** (Standard für alle bestehenden und neuen Karten; 77e.3): Was auf der Karte steht, bestimmt die Kampfkulisse. Wasser, Felsen, Feuerstellen, Lager, Leuchtpilze, Lichtschächte und Fackeln auf der Karte erscheinen im Kampf an derselben Stelle wieder, auch mit demselben Licht. Kein reines Auswürfeln der Kulisse. Jede neue Kampfkulisse bekommt Orte, die auf der Karte als Gegenstücke vorkommen, und umgekehrt.
- **Begleiter und Rudel:** folgen mit eigenem Weg, eigenem Tempo und eigenem Blick, werden nie starr um den Anführer mitgedreht.

## Spielerfreundlich, einfach, frei (Thema 33)

Grundsatz des Nutzers (12.10.): Das Spiel lässt dem Spieler möglichst viel Freiheit, ist aber einfach zu bedienen und kommt mit möglichst wenigen Zusatzdialogen aus („keep it simple and clean“). Tom und Jerry prüfen das vor jeder Umsetzung, wo es Sinn ergibt, mit vier Fragen:
1. **Freiheit:** Muss der Spieler das tun, oder darf er wählen? Nebensachen (Aufträge, Sammeln, Handwerk) sind immer freiwillig; wer etwas nicht will, wird nicht daran erinnert oder gedrängt.
2. **Wenige Schritte:** Wie viele Fenster, Tipps und Bestätigungen braucht es? Ziel: eine Handlung, ein Fenster; keine Rückfrage „Wirklich?“ für Umkehrbares.
3. **Bekannte Bedienung:** Geht es mit Mustern, die das Spiel schon hat (Antippen, Liste, ein Knopf), statt mit einem neuen Bedienelement?
4. **Wachstum:** Bleibt es übersichtlich, wenn mit weiteren Kapiteln viel mehr davon kommt (zehnmal so viele Aufträge, Gegenstände, Orte)?

Im Vorschlag an den Nutzer stehen die vier Antworten kurz neben dem Abgleich mit den übrigen Leitlinien.

## Oberfläche (Thema 60)

- Alle Oberflächen sehen aus wie Blende und Textkasten (42b): schwarz, dünner Goldrand, Überschriften und Hervorhebungen in gedämpftem Gold, Text in gebrochenem Weiß, Serife (mitgeliefert, OFL); keine hellen Tafeln mehr (Nutzer 12.10., 23:20).
- Pixelschrift nur für kleine Zahlen im Kampf. Farben, die auf Schwarz stehen (Seltenheit, Warnung), hell genug zum Lesen.

## Ausrüstung der Gegner

- Feste Ausrüstung je Gegnerart nach SRD, in mindestens drei Varianten.
- Zustände wie „rostig“ (altes Eisen) und „grob“ (Holzschild aus Planken) sind reine Optik. Sie kommen nicht in Beute- oder Händlerlisten.
- Die Ausrüstung passt zum Angriffsnamen des Gegners, etwa „Morgenstern“ bei Krogg oder „Kurzbogen“ beim Goblin-Späher.

## Zwischensequenzen (Thema 70)

Alle Zwischensequenzen (Intro 69, Tempelszene 68, spätere Wendepunkte) sind gleich gebaut, damit sie als eine Reihe erkennbar sind:
- etwa **fünf gerenderte Standbilder** ohne Animation, verbunden durch **weiche Überblendungen**; zusammen etwa 30–40 Sekunden
- je Bild **ein kurzer Text** im Textkasten-Stil; Texte legen Nutzer und Berater fest (`STORY-REGELN.md`)
- **Klang je Szene**: leise Geräusche (Intro) oder ein eigenes Musikstück (Tempel: „Ancient Legend“), Geräusche bleiben darunter leise
- Antippen überspringt; danach in der Chronik unter „Bisher geschehen“ wieder ansehbar
- **Figuren** an Umriss und festem Merkmal erkennbar (Merkmale in `LISTE-FIGUREN.md`), nicht am Gesicht; Rückenansicht oder Schattenriss (70.2)
- **Selten:** je Kapitel höchstens Anfang und Ende, dazu selten ein Wendepunkt (70.4)
- **Bild:** dieselbe Welt (Grundsatz unter „Richtung“), leicht abstrahiert: ruhigere Formen, weniger Einzelheiten, ein Hauch von Gemälde, weder Ölgemälde noch Bildschirmfoto; Grad am Probebild (69e). Musterbild folgt nach den Probebildern (70.1)
- **Blickwinkel:** Ich-Perspektive des Helden oder ein Bild ohne ihn (Stimmung, anderer Schauplatz); der Held erscheint nie, weil er wählbar ist (Geschlecht, Klasse, Ausrüstung); andere Figuren dürfen ins Bild (wie Lyra in der Tempeltür)
- **Leises Leben** (Flackern, Lichtfall, Staub) wird nach der Stilwahl in einem Test-Build an einer Szene entschieden (70.3)

## Klang

- **Weg von quietschenden Chiptune- und Nintendo-Tönen, hin zu glaubwürdigen Geräuschen**: Stahl, Holz, Leder, Schritte, Feuer, Stimmen von Tieren.
- **Systemklänge nur in einer Fassung** (Regel des Nutzers, 11.10.): Klänge, die etwas melden (Stufenaufstieg u. ä.), gibt es genau einmal, damit man sie sofort wiedererkennt. Alle übrigen (Umwelt, Kampf, Tiere, Dinge) haben mindestens drei Varianten.
- **Echte Aufnahmen statt Synthese** (18, 11.10.): Grundlage sind CC0-Aufnahmen (Lizenzregel in `CLAUDE.md`); erzeugte Klänge nur, wo sich nichts findet.
- Mindestens drei Varianten je Geräusch, damit es nicht eintönig wird. Die Varianten sind echte Alternativen mit eigenem Charakter (z. B. Abwehr: Klonk auf Holz und Eisen, hölzernes Pochen, Klinge gegen Klinge), nicht nur dieselbe Aufnahme in anderer Tonhöhe. Im Spiel wird zufällig gewechselt.
- **Ortsklang nur von dem, was da ist** (Nutzer 11.10., 22:06, Thema 24.8): Was man an einem Ort hört, kommt von sichtbaren Quellen und den Leuten, die gerade dort sind. Kein Stimmengewirr und keine Menge, wo nur zwei Leute stehen (Schänke: Rowena, Borin); stattdessen Herd plus Einzelklänge der Anwesenden in unregelmäßigen Abständen (Becher abstellen, Krug, Wischen, Stuhl knarrt, Räuspern ohne Worte). Keine erkennbare Sprache.
- **Hintergrundklänge aktiv anbieten (44d, Nutzer 12.10.):** Wind, Feuer, Tiere, Schritte, Arbeit der Leute beleben jeden Ort; Tom und Jerry bieten sie bei jedem neuen Ort und jeder neuen Figur von sich aus an, mit Hörproben.
- Zu neuen oder geänderten Klängen gibt es Hörproben zum Vergleich (Vorschau: `SOUNDS=NAME,…`).
- **Musik (Nutzer 11.10., 19:43, Thema 28):** einheitlich in einem Stil: **orchestral**, düster und bedrohlich, tragend; kein Metal, kein Rock, kein Chiptune. Ausnahme **Dorf:** mittelalterlich (Laute, Trommeln, etwas Bass). Dazu eine eindeutige Titelmusik.
- Was noch zu überarbeiten ist, steht in der [Merkliste](LISTE-IDEEN.md) „Klänge überarbeiten“.
