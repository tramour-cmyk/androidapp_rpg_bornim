# Stil-Leitlinien

Gilt für **alle** künftigen Arbeiten und Überarbeitungen an Grafik, Animation und Klang. Stand: 11.10.2026, 11:45 (Berliner Zeit; Abschnitt „Karte und Räume“ und Silhouetten-Prüfung aus den Rückmeldungen bis 11.10. ergänzt).

Siehe auch: [Offen](OFFEN.md) · [Merkliste](MERKLISTE.md) · [Änderungshistorie](../CHANGELOG.md)

## Richtung

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
- **Kein Gegner verschwindet einfach:** Jede Gegnerart bekommt eigene Sterbeanimationen (mindestens drei), erst danach blendet sie aus. Ein tödlicher kritischer Treffer bekommt einen eigenen Killerschlag (siehe Liste [Offen](OFFEN.md) unter „Geplant“).
- **Größe und Körperbau variieren** im Rahmen des SRD, zum Beispiel Goblins 98–118 cm (Small), Skelette 160–185 cm, dazu schlank, normal oder kräftig. Größe, Körperbau, Ausrüstung und Hautton werden unabhängig voneinander gewählt.
- Die Variante wird beim Kampfbeginn aus dem Erscheinungsbild-Zufall des Gegners gewählt und bleibt für diesen Gegner im ganzen Kampf gleich.
- **Ausnahme einmalige Monster:** Bosse und andere einzigartige Monster (etwa Krogg, Grak, Grimmzahn) erscheinen nur in einer Form, ohne Varianten in Aussehen und Ausrüstung, damit man sie wiedererkennt; ihre Bewegungen haben trotzdem je drei Varianten.
- Gilt für alle künftigen Gegner, Tiere, Begleiter und Figuren.

## Lebendige Welt: keine Figur steht starr

Wunsch des Nutzers (09.10.): Wer auf der Karte steht, lebt. Jede Figur, auch der Held, atmet, verlagert ab und zu das Gewicht, schaut kurz zur Seite oder stützt die Hände in die Hüften (Baustein `MapRest`, bekommen neue Figuren automatisch). Figuren mit eigener Aufgabe bekommen eigene Handlungen obendrauf (Garrick: Hände am Feuer wärmen, in den Wald spähen).

- Nie im Takt: Ob, wann, was und wie lange, entscheidet der Zufall, mit eigenem Startwert je Figur, damit zwei Figuren nebeneinander nie gleichzeitig dasselbe tun. Ein gleichmäßiger Rhythmus wirkt wie ein Roboter.
- Figuren schauen den Helden an, wenn er nahe ist, verlieren aber nach etwa 20 s Stillstand das Interesse.
- Haltungen vorher in allen Blickrichtungen prüfen (vorn, schräg, Seite, hinten); was von einer Seite falsch aussieht, fliegt raus.
- Auch Orte leben (Regel des Nutzers, 10.10., 6f): Räume, Dorf und Wald sollen lebendig wirken, nicht wie eine Kulisse. Licht flackert, Rauch steigt, Staub tanzt im Lichtstrahl, Dinge liegen so, als hätte gerade jemand sie benutzt. Grundstimmung düster durch Licht und Schatten, nicht durch Dunkelheit.

## Karte und Räume (diagonale Sicht)

Aus den Rückmeldungen des Nutzers bis 11.10. (Verlauf im [Archiv](ARCHIV.md)):
- **Ausrüstung unterwegs:** Waffen geschultert (nie am Boden schleifend), Schild auf dem Rücken, Zweitwaffe in der Scheide. Im Kampf wie gehabt.
- **Neue Orte nur diagonal (13u, Nutzer 12.10., 12:20):** jeder neue Ort und Raum wird gleich diagonal gebaut (Vorlagen `MapRoomIso`, `MapTownIso`), nie mehr eine gerade Fassung. Der Autoschalter (13.4) ist nur die Brücke für Wald, Tiefer Wald und Höhle.
- **Alte Ansicht eingefroren (13w, Nutzer 12.10., 12:26):** keine Arbeit und keine Fehlerbehebung mehr an der geraden Ansicht, außer bei Abstürzen; gelöscht, sobald Wald, Tiefer Wald und Höhle diagonal fertig sind.
- **Sichtbarkeit (Thema 43, Nutzer 12.10.):** Was in der alten Ansicht rechts gut zu sehen war, steht diagonal vorn unten zwischen Kamera und Geschehen.
  - **Wichtiges steht frei:** Leute, Questziele, Eingänge, Schilder, Feuerstellen haben freien Blick; zur Kamera hin (Süden, Osten) nichts Hohes davor. Sonst umstellen (das Ding oder die Bäume davor); die Karte muss nur diagonal stimmen.
  - **Durchsicht nur um den Helden:** Kronen, Felsen, Büsche und hohe Möbel in einem kleinen Umkreis um den Helden fast ganz durchsichtig, nicht gestapelt, damit er nie verschwindet.
  - **Verstecktes erwünscht:** Kisten und Kleinkram dürfen unter Bäumen liegen und tauchen erst auf, wenn der Held hingeht (Belohnung fürs Erkunden); keine Durchsicht für sie aus der Ferne.
- **Maßstab:** Höhen im Maßstab des Helden (ein Tisch steht etwa hüfthoch neben ihm). Waagerechte Kreise (Fass, Eimer, Becken) sind in der diagonalen Sicht Ellipsen 2:1, ihr Schatten ebenso.
- **Räume:** eher klein und dicht als groß und leer; jeder Ort hat eigene Möbel, die zu seinem Bewohner passen (Pult und Truhe beim Ältesten, Ladentisch und Waren bei Thessa, Altar und Bänke im Tempel), je drei Varianten. Mehrteilige Möbel (Altar, Theke, Bett über mehrere Felder) haben durchgehend dieselbe Variante. Licht von Herd, Kerze und Fenster; Gebrauchsspuren.
- **Begleiter und Rudel:** folgen mit eigenem Weg, eigenem Tempo und eigenem Blick, werden nie starr um den Anführer mitgedreht.

## Wann ein Ort fertig ist („Ort fertig“)

Festgelegt mit dem Nutzer 11.10., 16:50 (Maßstab: Dorf und Räume). Gilt für Dorf, Räume, Wald, Höhle und jeden neuen Ort:
1. **Diagonale Sicht:** alles (Bäume, Felsen, Häuser, Möbel, Ufer, Hänge) für die schräge Kamera gezeichnet, nicht die alte Ansicht gekippt.
2. **Boden:** doppelte Auflösung, kein sichtbares Raster, Wege mit natürlichem Verlauf.
3. **Dinge:** rund geformt mit Volumen (`Sculpt`), je mindestens drei Varianten, im Maßstab des Helden.
4. **Licht und Schatten:** Schatten unter allem, was steht; Licht nur aus sichtbaren Quellen; nachts düster, aber lesbar.
5. **Durchsicht:** was vor dem Helden steht, wird halb durchsichtig.
6. **Lebendig:** Wind, Rauch, Tiere, Gebrauchsspuren, Wetter, je nach Ort.
7. **Figuren:** alle Leute als Puppen, alle Gegner als neue Kartenmodelle.
8. **Klang:** Umgebung aus echten Aufnahmen, Schritte passend zum Untergrund.
9. **Sichtbar (43):** Standbild je Ort aus Sicht des Helden; jede Person und jeder Questort ist beim Herangehen erkennbar.
10. **Geprüft:** Kollision 0 (nirgends hindurchlaufen), Sprungtest 0, Tippen trifft das gezeichnete Ding; Standbilder bei Tag und Nacht.

## Spielerfreundlich, einfach, frei (Thema 33)

Grundsatz des Nutzers (12.10.): Das Spiel lässt dem Spieler möglichst viel Freiheit, ist aber einfach zu bedienen und kommt mit möglichst wenigen Zusatzdialogen aus („keep it simple and clean“). Tom und Jerry prüfen das vor jeder Umsetzung, wo es Sinn ergibt, mit vier Fragen:
1. **Freiheit:** Muss der Spieler das tun, oder darf er wählen? Nebensachen (Aufträge, Sammeln, Handwerk) sind immer freiwillig; wer etwas nicht will, wird nicht daran erinnert oder gedrängt.
2. **Wenige Schritte:** Wie viele Fenster, Tipps und Bestätigungen braucht es? Ziel: eine Handlung, ein Fenster; keine Rückfrage „Wirklich?“ für Umkehrbares.
3. **Bekannte Bedienung:** Geht es mit Mustern, die das Spiel schon hat (Antippen, Liste, ein Knopf), statt mit einem neuen Bedienelement?
4. **Wachstum:** Bleibt es übersichtlich, wenn mit weiteren Kapiteln viel mehr davon kommt (zehnmal so viele Aufträge, Gegenstände, Orte)?

Im Vorschlag an den Nutzer stehen die vier Antworten kurz neben dem Abgleich mit den übrigen Leitlinien.

## Ausrüstung der Gegner

- Feste Ausrüstung je Gegnerart nach SRD, in mindestens drei Varianten.
- Zustände wie „rostig“ (altes Eisen) und „grob“ (Holzschild aus Planken) sind reine Optik. Sie kommen nicht in Beute- oder Händlerlisten.
- Die Ausrüstung passt zum Angriffsnamen des Gegners, etwa „Morgenstern“ bei Krogg oder „Kurzbogen“ beim Goblin-Späher.

## Selbst prüfen, bevor etwas gezeigt wird

- Jede neue Animation, Haltung oder Waffe wird automatisch auf **Kollisionen** geprüft: Waffe durch Körper, Kopf, Beine oder Schild, Stab durch den Körper, Schild durch die Waffe. Für alle Völker, Geschlechter und Staturen.
  - Werkzeuge in der Vorschau (`tools/preview`): `CLASH=1`, `CLERICCLASH=1` und vergleichbare Prüfläufe; Ziel ist immer 0 Treffer.
- Jede Bewegung wird als Bildfolge angesehen, nicht nur ein Standbild: Ausholen, Treffer, Rückweg, Übergänge.
- **Silhouetten prüfen:** Jede Figur und jedes Ding von allen Seiten auf unfreiwillig Komisches oder Anstößiges ansehen (Beispiel 10.10.: ein waagerecht nach vorn zeigender Dolch auf Hüfthöhe beim Goblin).
- Jeder Angriff ist sichtbar, auch ein Fehlschlag: Geschosse fliegen vorbei, Flammen schlagen neben dem Ziel ein.
- Umgang mit Waffen muss stimmen: Griff, Abstützen, Rückstoß, Haltung in Ruhe.
- **Eine Aktion ist ein Stück:** Bewegung zuerst, dann eine einzige Textzeile mit Ausgang und Schaden; kein Tippen mitten in einer Aktion. Der Kampf läuft von selbst weiter, im eingestellten Kampftempo.
- **Kampfabläufe selbst durchspielen**, eigenverantwortlich und genau, bei jedem neuen Monster und jeder Änderung an Kampf oder Bewegung: Passt die Haltung zu jeder Meldung (Angriff, Treffer, Verfehlen, Abwehr, Konter, Zauber, Wurf, Sturz)? Wird keine Bewegung unterbrochen, doppelt gespielt oder fällt zu früh in die Ruhe zurück? Bleiben gehaltene Haltungen (Ausholen, Abwehr, Zauber sammeln) stehen, bis die nächste Meldung sie auflöst?
  - Nicht nur die Logik lesen, sondern durch die echte Oberfläche filmen und die Bildfolge ansehen: Vorschau `FILM=klasse:gegner FILMTAPS=SFASSS` (S Szene/Weiter, F Kampf, A Angriff, D Abwehr) legt in Echtzeit alle 80 ms ein Bild ab. Mehrere Klassen und Waffen, mit und ohne Abwehr.

- **Sprungtest (Thema 12, 10.10.):** Jede Bewegung und jeder Übergang (Stehen, Atmen, Gehen, Drehen, Haltungen hinein und heraus, Gehen ↔ Stehen, Rudel folgt) wird Bild für Bild auf Sprünge geprüft: `JumpTest` in `core` (`./gradlew -p core test --tests '*JumpTest*'`), ohne Bild, in Sekunden. Ziel 0 Meldungen, wie bei den Kollisionen. Neue Bewegungen kommen dort als Prüffall hinzu.

## Klang

- **Weg von quietschenden Chiptune- und Nintendo-Tönen, hin zu glaubwürdigen Geräuschen**: Stahl, Holz, Leder, Schritte, Feuer, Stimmen von Tieren.
- **Systemklänge nur in einer Fassung** (Regel des Nutzers, 11.10.): Klänge, die etwas melden (Stufenaufstieg u. ä.), gibt es genau einmal, damit man sie sofort wiedererkennt. Alle übrigen (Umwelt, Kampf, Tiere, Dinge) haben mindestens drei Varianten.
- **Echte Aufnahmen statt Synthese** (18, 11.10.): Grundlage sind CC0-Aufnahmen; nur Lizenzen, die kommerzielle Nutzung erlauben (Regel in `CLAUDE.md`), Quellen und Lizenz je Datei festhalten; erzeugte Klänge nur, wo sich nichts findet.
- Mindestens drei Varianten je Geräusch, damit es nicht eintönig wird. Die Varianten sind echte Alternativen mit eigenem Charakter (z. B. Abwehr: Klonk auf Holz und Eisen, hölzernes Pochen, Klinge gegen Klinge), nicht nur dieselbe Aufnahme in anderer Tonhöhe. Im Spiel wird zufällig gewechselt.
- **Ortsklang nur von dem, was da ist** (Nutzer 11.10., 22:06, Thema 24.8): Was man an einem Ort hört, kommt von sichtbaren Quellen und den Leuten, die gerade dort sind. Kein Stimmengewirr und keine Menge, wo nur zwei Leute stehen (Schänke: Rowena, Borin); stattdessen Herd plus Einzelklänge der Anwesenden in unregelmäßigen Abständen (Becher abstellen, Krug, Wischen, Stuhl knarrt, Räuspern ohne Worte). Keine erkennbare Sprache.
- Zu neuen oder geänderten Klängen gibt es Hörproben zum Vergleich (Vorschau: `SOUNDS=NAME,…`).
- **Musik (Nutzer 11.10., 19:43, Thema 28):** einheitlich in einem Stil: **orchestral**, düster und bedrohlich, tragend; kein Metal, kein Rock, kein Chiptune. Ausnahme **Dorf:** mittelalterlich (Laute, Trommeln, etwas Bass). Dazu eine eindeutige Titelmusik.
- Was noch zu überarbeiten ist, steht in der Liste [Offen](OFFEN.md) unter „Geplant“.
