# Merkliste

Ideen und Vorschläge aus der bisherigen Entwicklung, die noch **nicht umgesetzt** sind. Gesammelt, damit wir sie später prüfen, neu bewerten oder verwerfen können. Stand: 11.10.2026, 11:45 (Berliner Zeit).

Bereits umgesetzte Punkte stehen in der [Änderungshistorie](../CHANGELOG.md), was gerade ansteht oder zu entscheiden ist in der Liste [Offen](ARBEIT-OFFEN.md). Für alle Ideen gelten die [Stil-Leitlinien](DESIGN-STIL.md).

## Ideenrunde 10.10. (Tom-Beratung, 13:36)

Ideen zu Mechanik, Animation, Klang und Grafik. Als Themen angelegt: Trefferstopp (16), Nachschwingen (17), Pechsträhnen dämpfen (18), siehe [Offen](ARBEIT-OFFEN.md). Der Rest:

- **Aktive Abwehr per Tippen (Idee 1):** kurzes Zeitfenster beim gegnerischen Hieb, Tippen = Parieren mit halbem Schaden. Nutzer findet die Idee nicht gut, soll aber erhalten bleiben. Wäre eine Ausnahme von „kein Tippen mitten in einer Aktion“; nur als abschaltbarer Versuch.
- **Trefferchancen sichtbar machen (Teil von Idee 2):** Chance vor dem Angriff anzeigen.
- **Verletzungen bis zur Rast (Idee 3):** Wer tief fällt, behält eine Wunde (z. B. −1 RK), sichtbar als Verband am Helden; das Gasthaus heilt sie.
- **Licht als Mechanik (Idee 4):** Fackel brennt ab; im Dunkeln sieht man Lauerer später, Untote sind stärker.
- (im Vorrat, 23a) **Raumklang (Idee 8):** Hall in der Höhle, gedämpft und nah in der Schänke, offen im Wald.
- (im Vorrat, 23a) **Musik in Schichten (Idee 10):** Nähert sich ein Jäger, schleicht sich eine dunkle Spur in die Musik, bevor der Kampf beginnt; Stille bewusst einsetzen. Erweitert die neue Musik (28).
- **Regeln:** SRD bleibt Grundlage, nicht wechseln; das Würfelglück wird abgefedert (18, sichtbare Chancen).

## Veröffentlichung (Weg, besprochen 10.10., 13:36)

1. Stilumbau abschließen.
2. Pflichttest im Play Store (neues privates Konto: mindestens 12 Tester, 14 Tage am Stück) als echten Test nutzen, Rückmeldungen sammeln.
3. Kapitel 1 kostenlos veröffentlichen (Bewertungen, Spieler); 99 Cent für Kapitel 1 bringen kaum Käufer (keine Sichtbarkeit ohne Bewertungen, nach Steuer und Google-Anteil etwa 70 Cent).
4. Danach Vollversion mit einmaligem Kauf, spätere Kapitel nachkaufbar (45a); Preis offen (72g).
- Vorher: Datenschutzerklärung, Altersfreigabe (Blut), Zahlungsprofil mit Händleradresse, kurze Rechtsprüfung (Herkunft von Schriften und Klängen). Siehe auch „Google Play“ unten.

## Ladezeiten

- **Gezeichnete Bilder auf dem Gerät speichern (24.4, 11.10.):** Figuren-, Boden- und Kampfbilder nach dem ersten Zeichnen auf dem Gerät ablegen, damit der nächste Start ohne Wartezeit geht. Erst angehen, wenn mit 24.1–24.3 gemessen ist, wie lang das Übergangsbild noch dauert.

## Werkzeuge

- **Film-Uhr (ruht seit 09.10., 23:09, deine Entscheidung):** Zwischenstand auf Zweig `claude/film-uhr` (nicht installieren). Kampfbildschirm auf eine eigene Uhr `BattleClock` und Wartezeiten über Bilder (`pause`) umgestellt, Zufall der Anzeige säbar; Kampffilme damit vollständig (140 statt 76–102 Bilder), Speichern nebenher. Offen: Filme mit Angriffen bleiben beim ersten Hieb stehen; in 5 von 140 Bildern weichen einzelne Pixel ab (parallele Figurenzeichnung in `Sdf.kt`). Ergebnis bisher: kaum schneller als Echtzeit, etwa die Hälfte der Zeit ist das Vorzeichnen der Figuren. Danach wären Ablaufprotokoll (B) und Bildvergleich (D) möglich.

## Attribute (Rest aus dem Attribut-Paket)

- **Stärke – rohe Gewalt:** Manche verschlossene Truhen oder Gitter lassen sich ab einem Mindestwert aufbrechen statt nur mit Schlüssel. Braucht neuen Karteninhalt, daher für Kapitel 2 gedacht.
- **Charisma – Gesprächsoptionen:** „Überreden“ oder „Einschüchtern“ bei Wachen, Händlern und Bösewichten, wenn es zur Geschichte passt. Braucht neue Dialoge, daher für Kapitel 2 gedacht.
- **Charisma – Auftreten auf der Karte:** Wanderer und schwächere Monster weichen einem einschüchternden Helden aus.
- **Weisheit – Lauerer erkennen:** Lauernde Monster (Spinne, Fledermaus) werden früher sichtbar.

## Kapitel 2

- **Geschichte:** die Spur des „Grauen Propheten“ und der „Tag der Asche“ als Bedrohung.
- **Neue Region:** z. B. Sumpf oder Ruinenstadt. Vorgabe: **Karten ab Kapitel 2 deutlich größer** als in Kapitel 1.
- **Vorgaben für jede neue Karte** (geprüft nach 60 und 13t, Tom 14.10., 77e.3; Kampfort-Regel in `DESIGN-STIL.md`):
  - Die Anzeige ist eine **feste Leiste über der Karte**; die Karte liegt darunter und wird nie von ihr verdeckt. Die Kamera folgt dem Helden ohne Anschlag am Rand (Füße etwas unter der Bildmitte), also gibt es keinen „oberen Rand unter der Leiste“ mehr.
  - **Kartenränder laufen diagonal:** oben sitzt die Nordecke, links und rechts die Ecken West und Ost. Nahe am Rand sieht man jenseits davon schwarze Schrägen (Lücke 27/5.5). Neue Karten bekommen am Rand einen Abschluss (Bäume, Felsen, Zaun, Wasser), damit keine Schräge ins Bild ragt; Eingänge, Schilder und wichtige Figuren am Rand in der Vorschau vom Weg dorthin prüfen.
  - Das Blickfeld ist ein gedrehtes Rechteck um den Helden, flach und breit: Wege, Engstellen und Sperren (z. B. Zäune wie am Schlagbaum) so legen, dass sie quer über den Bildschirm laufen statt steil nach oben.
  - Die Leiste hat immer dieselbe Höhe (eine Zeile für Zustände steht auch leer); neue Zustände reihen sich nebeneinander und machen sie nicht höher.
- **Neue Monster (SRD):** Banditen und Kultisten, Gnoll, Worg, Harpyie (Gesang/Bezauberung), Belebte Rüstung, Mimik (Klammern), Oger, Eulenbär.
  - **Gebaut auf den 3D-Grundmodellen** (Heldenpuppe für Menschenähnliche, Vierbeiner-Modell wie beim Wolf): Rig, Bewegungen, Ausfallschritt und Stürze sind schon da; ein neues Monster braucht vor allem Ausrüstung, Maße, Kopf und eigene Haltungen. Es gelten die [Stil-Leitlinien](DESIGN-STIL.md) (je drei Varianten in Aussehen und Bewegung).
  - Aufwand nach heutiger Einschätzung:
    - sehr gering: Banditen und Kultisten (Puppe als Mensch mit Ausrüstung), Worg (Wolf, größer und dunkler);
    - gering: Belebte Rüstung (Puppe nur aus Rüstung, innen hohl, wie beim Skelett);
    - gering bis mittel: Oger (Puppe, Large, um 2,7 m, grob und schwer);
    - mittel: Gnoll (Puppe mit Hyänenkopf), Eulenbär (Vierbeiner mit Bärenkörper und Eulenkopf);
    - eher hoch: Harpyie (Puppe mit Flügeln und Vogelbeinen);
    - eigenes Modell: Mimik (Truhe mit Maul).
  - Was jetzt für Kobold, Zombie, Krogg, Grak, Wildschwein und Ratte entsteht (Kopfformen, große Statur, Vierbeiner-Varianten), macht diese Monster günstiger.
- **Neue Untote:** Schatten (Stärke entziehen), Gruft-Unhold (Lebensraub), Irrlicht (unsichtbar).
- **Neue Bosse:** Banditenhauptmann, Ogerhäuptling, Gelatinewürfel; mehrphasig, rufen Verstärkung.

## Gruppe und Kampf

- **Begleiter:** Lyra (Heilerin) oder Jäger Garrick als zweites Gruppenmitglied.
- **Echte Gruppenkämpfe:** mehrere Gegner gleichzeitig mit Zielauswahl, eigenen Lebensbalken und Flächenzaubern gegen alle. Großer Umbau; die heutigen Rudel (Begleiter im Hintergrund) wären die Vorstufe.
- **Kampfaktionen für Gruppen** (Nutzer 12.10., zu 34): „Abwarten“ (SRD *Bereithalten*: Angriff zurückhalten, zuschlagen, sobald der Gegner herankommt) und „Helfen“ (Gefährte greift im Vorteil an). „Zug beenden“ selbst ist Thema 34.
- **Weitere Zauber** ab Stufe 5 für alle Zauberklassen.
- **Kleriker-Fähigkeit „Läutern“:** heilt Zustände.
- **Positive Zustände:** Gesegnet, Geschützt, Hast, z. B. durch Tränke.
- **Neue Ausrüstungseigenschaft:** Giftresistenz.
- **Monster-Geräusche** (erste Hörproben Wolf, Goblin, Skelett liegen vor, 18e): eigene Laute je Gegnerart, jeweils in mehreren zufälligen Varianten wie beim Wolfsheulen. Zum Beispiel Knurren vor dem Angriff, Fauchen, Schmerzlaute bei Treffern und Todeslaute. Dazu Klappern bei Skeletten, Stöhnen bei Zombies, Schmatzen beim Ockergallert, Kreischen bei Fledermäusen, Kampfrufe bei Goblins und Kobolden, Brüllen bei Bossen. Elite-Gegner und Grimmzahn klingen tiefer.


## Welt und Leben auf der Karte

- **Schnellreise über die Kartenübersicht (Idee 09.10., 12:49):** Die Pergamentkarte (Entwurf C, `tools/preview` Modus `WEGE`) als Übersicht, mit Nebel des Unerkundeten wie auf der Karte; einmal entdeckte Orte (z. B. Bornim, Garricks Feuer, Höhleneingang) sind Reiseziele, gegen Gold. Gedanken dazu: ein Fuhrmann in Bornim oder Garrick als Führer statt Teleport; Preis nach Entfernung; Zeit vergeht (wer abends aufbricht, kommt nachts an); unterwegs ein Wurf auf einen Überfall, nachts höher; nicht aus Höhlen heraus, nicht im Kampf.
- **Monsterverhalten:** Goblins patrouillieren auf Wegen, Fledermäuse hängen an der Höhlendecke und stürzen herab.
- **Wetter:** Nebel; Windgeräusche als weiterer Umgebungsklang.
- **Sammelbares und Verstecke:** geheime Truhen, rissige Wände.

## Zutaten und Handwerk

- **Handwerk:** Felle und Hauer verarbeiten, z. B. Lederrüstung verbessern (heute nur zum Verkaufen). Siehe auch den Schmied unten.
- **Fleisch an die Wirtin** im Gasthaus verkaufen (heute bei Thessa und Morwen).
- **Kräuter wachsen am Morgen nach** statt schon um Mitternacht (Spielzeit).

## Schmied Dorran

Dorran wohnt heute nur hinter einer verschlossenen Tür („Er ist wohl in seiner Werkstatt“). Er bekommt eine eigene Schmiede im Dorf.

- **Die Schmiede:** offene Werkstatt neben seinem Haus mit Esse, Amboss und Wassertrog. Funken fliegen, ab und zu hört man Hammerschläge. Abends glüht die Esse.
- **Einstieg als kleine Quest:** Dorrans Esse ist kalt, weil ihm das Eisenerz ausgegangen ist. Goblins haben den Erzkarren auf der Waldstraße überfallen. Bringt man ihm Erz aus der Blutzahnhöhle (neue Zutat **Eisenerz**, liegt dort in Erzadern oder in Kisten), öffnet er die Schmiede.
- **Aufwerten:** ein Ausrüstungsteil verbessern, z. B. Schaden oder Rüstungsklasse um eine Stufe, gegen Gold und Material (Eisenerz für Metall, Felle für Leder, Hauer und Giftdrüsen für besondere Werte). Pro Teil nur wenige Stufen, und immer nur bis zur Obergrenze des Kapitels, damit die Balance hält.
- **Umschmieden:** eine einzelne Eigenschaft eines Gegenstands neu auswürfeln, z. B. „+1 Stärke“ gegen etwas anderes. Jedes weitere Umschmieden desselben Teils wird teurer.
- **Zerlegen:** ungeliebte Ausrüstung in Material verwandeln statt zu verkaufen: Eisenstücke, Leder und ab „selten“ etwas **Glutstaub** für bessere Aufwertungen.
- **Auftragsarbeit:** Mit genug Material schmiedet Dorran eine passende Waffe für die eigene Klasse. Sie ist am nächsten Spieltag fertig, dann holt man sie ab (nutzt die Tageszeit, die es schon gibt).
- **Attribute:** Charisma senkt seine Preise wie beim Händler. Stärke könnte erlauben, selbst am Amboss mitzuhelfen und so etwas Material zu sparen.
- **Bedienung:** wie Morwens Brauen ein eigener Reiter im Laden („Schmieden“), mit Material-Anzeige wie bei den Rezepten.
- **Später (Kapitel 2):** Runen oder Sockel für Ausrüstung, seltene Erze aus neuen Gebieten, eine Belohnung von Dorran für eine größere Aufgabe.

## Google Play

- **Anmeldung mit Google Play (Play Games Services):** automatische Anmeldung mit dem Google-Konto, Spielstände in der Cloud (pro Spielstand-Platz), Erfolge wie „Grak besiegt“ oder „Erste schimmernde Beute“, auf Wunsch Bestenlisten.
- **Voraussetzungen, die nur der Inhaber erledigen kann:** Google-Play-Entwicklerkonto (einmalig 25 US-Dollar, Identitätsprüfung), das Spiel in der Play Console anlegen und den Fingerabdruck des Signierschlüssels hinterlegen, eine Datenschutzerklärung. Zum Testen reicht ein interner Test-Track.
- **Danach im Code:** die Play-Games-Bibliothek einbinden, Anmeldung beim Start, Cloud-Abgleich der Spielstand-Plätze, Erfolge.
- Sinnvoll erst, wenn das Spiel im Play Store erscheinen soll (siehe auch Rechtliches unten).

## Sonstiges

- **Rechtliches:** Vor einer Veröffentlichung im Play Store oder einer kommerziellen Nutzung eine kurze Prüfung durch einen Anwalt für Marken- und Urheberrecht.
- **Mehr Abwechslung beim Helden (Rest aus 08.10.):** Ausweichen ist nur ein Hüpfer (zwei Seiten), der Speer hat zwei Stöße, Zauber eine Bewegung je Fokus.
- **Todesstoß für Fernkampf und Zauber (gewünscht 09.10.):** Der Killerschlag gilt zunächst nur für Nahkampfwaffen. Für Bogen, Armbrust und Zauber soll später auch ein eigener tödlicher Treffer kommen (z. B. Pfeil, der den Gegner umreißt und festnagelt; Feuer, das ihn verzehrt; Kraft, die ihn zerreißt).
- **Echtes Zerteilen in 3D (Killerschlag, gewählt als späterer Schritt am 09.10.):** Das Körpermodell selbst durchschneiden statt des flachen Bildes; Schnittflächen mit Fleisch und Knochen, beide Hälften fallen räumlich. Dann auch für Tiere. Aufwand grob ein bis zwei Arbeitstage.
- **Flüssigere Grafik mit mehr Zwischenbildern** (teilweise erledigt: Sprungtest 12/12a, Gehen in 8 Bildern) (Wunsch 10.10., 11:00; vorher „Zu entscheiden“): Die Haltungen (Arme, Beine, Waffe) wechseln heute 11- bis 13-mal pro Sekunde und bremsen an jeder Zwischenhaltung kurz ab. Mehr Bilder, längeres Vorabzeichnen zu Kampfbeginn; Claude prüft selbst mit Filmen und Kerntests.
- **Kampfkulisse der Höhle an die neue Karte angleichen** (zurückgestellt 10.10.): Beim Kampf in der Höhle soll die Kulisse wie dieselbe Höhle aussehen wie auf der Karte (Boden, Wände, Dinge, Licht).

## Klänge überarbeiten (Rest, aus „Offen“ am 11.10.)

Nach den [Stil-Leitlinien](DESIGN-STIL.md): weg von Chiptune, hin zu glaubwürdigen Geräuschen. Hörproben Runde 1 und 2 liegen vor (18d, Auswahl beim Nutzer). Noch offen: Menü-Klick, Belohnungen (Stufenaufstieg, Beute, epische Beute, Münzen, Truhe), Welt (Tür, Begegnung, Alarm, Hinterhalt), Zauber und Tränke, Kampfende (Gegner fällt, Held fällt), Umgebung (Vögel, Grillen, Eule, Tropfen, Knistern), Musik (28 erledigt; Schichten siehe Ideenrunde). Vorgehen: Hörproben, dann nach Freigabe umstellen.

## Bewusst so gelassen

- **Trank wird zweimal getrunken:** kein Fehler, Trinkvariante „zwei hastige Schlucke“ (08.10.).
- **Testkämpfe im Dorf:** Held und Gegner erreichen sich beim Angriff nicht (alte Kulisse ohne berechneten Schritt); im Dorf gibt es sonst keine Kämpfe (08.10.).
- **Figurgröße im Reiter „Held“** und **Kampfablauf** (Ansage mit Ausholen → Tippen → Schlag): so bestätigt.
- **30.7 (Jerry, 36f, 12.10.):** Klänge mit 22 statt 44 kHz (etwa 5 MB Speicher weniger, Höhen etwas dumpfer); erst wenn der Speicher wieder knapp wird.

- **59.6** Händler: Filter „nur tragbare“, Sortierung nach Platz – wenn es mehr Ware gibt (Nutzer 12.10., 22:49)
- **59.7** Händler mit Gesicht: Name, Bild, Begrüßungssatz statt „Laden“; Texte Nutzer und Berater (41) (Nutzer 12.10., 22:49)
- **Handlaterne für Jorin** (66a, 13.10.): Laterne in der freien Hand bei Nacht, neue Haltungen für Gehen, Wache, Abstellen; zusammen mit 55 (mehr Leerlauf).
