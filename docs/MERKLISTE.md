# Merkliste

Ideen und Vorschläge aus der bisherigen Entwicklung, die noch **nicht umgesetzt** sind. Gesammelt, damit wir sie später prüfen, neu bewerten oder verwerfen können. Stand: 06.10.2026, 07:50 (Berliner Zeit).

Bereits umgesetzte Punkte stehen in der [Änderungshistorie](../CHANGELOG.md), was gerade ansteht oder zu entscheiden ist in der Liste [Offen](OFFEN.md). Für alle Ideen gelten die [Stil-Leitlinien](STIL.md).

## Attribute (Rest aus dem Attribut-Paket)

- **Stärke – rohe Gewalt:** Manche verschlossene Truhen oder Gitter lassen sich ab einem Mindestwert aufbrechen statt nur mit Schlüssel. Braucht neuen Karteninhalt, daher für Kapitel 2 gedacht.
- **Charisma – Gesprächsoptionen:** „Überreden“ oder „Einschüchtern“ bei Wachen, Händlern und Bösewichten, wenn es zur Geschichte passt. Braucht neue Dialoge, daher für Kapitel 2 gedacht.
- **Charisma – Auftreten auf der Karte:** Wanderer und schwächere Monster weichen einem einschüchternden Helden aus.
- **Weisheit – Lauerer erkennen:** Lauernde Monster (Spinne, Fledermaus) werden früher sichtbar.

## Kapitel 2

- **Geschichte:** die Spur des „Grauen Propheten“ und der „Tag der Asche“ als Bedrohung.
- **Neue Region:** z. B. Sumpf oder Ruinenstadt. Vorgabe: **Karten ab Kapitel 2 deutlich größer** als in Kapitel 1.
- **Vorgaben für jede neue Karte:**
  - Die Anzeige ist eine **feste Leiste über der Karte** (seit v0.1.40). Neue Karten werden mit dieser Leiste geplant und in der Vorschau geprüft, damit nichts davon verdeckt wird.
  - **Eingänge, Schilder und wichtige Figuren am Kartenrand** (vor allem oben) in der Vorschau genau an dieser Stelle prüfen, wie beim Höhleneingang im Flüsterwald.
  - Die sichtbare Fläche ist durch die Leiste etwas kleiner: Wege, Engstellen und Sperren (z. B. Zäune wie am Schlagbaum) so planen, dass man sie gut überblickt.
  - Die Statuszeile hat immer dieselbe Höhe; neue Zustände dürfen die Leiste nicht höher machen.
  - **Karte und Kampfort gehören zusammen** (Standard für alle bestehenden und neuen Karten): Was auf der Karte steht, bestimmt die Kampfkulisse. Wasser, Felsen, Feuerstellen, Lager, Leuchtpilze, Lichtschächte und Fackeln auf der Karte erscheinen im Kampf an derselben Stelle wieder, auch mit demselben Licht. Kein reines Auswürfeln der Kulisse.
  - **Stimmung wie im Kampf:** erwachsener, etwas düsterer Stil. Licht kommt von sichtbaren Quellen (Sonne/Mond, Fackeln, Feuer, Pilze, Fenster), Dunkelheit ist erlaubt, die Laterne des Helden leuchtet. Kleine Bewegung (Flackern, Tropfen, Funken, Staub) und passende Umgebungsgeräusche.
  - Jede neue Kampfkulisse bekommt Orte, die auf der Karte als Gegenstücke vorkommen, und umgekehrt.
- **Technisch beim Start von Kapitel 2:** den Merker `chapter2_started` setzen. Damit gelten automatisch:
  - die Stufengrenze 6 fällt; EP werden ab dann wieder gesammelt (aus Kapitel 1 wird nichts nachträglich angerechnet);
  - bessere Beute (normal bis „selten“, besondere Beute bis „sehr selten“);
  - höhere Obergrenzen für Ausrüstungsboni (+2).
- **Neue Monster (SRD):** Banditen und Kultisten, Gnoll, Worg, Harpyie (Gesang/Bezauberung), Belebte Rüstung, Mimik (Klammern), Oger, Eulenbär.
  - **Gebaut auf den 3D-Grundmodellen** (Heldenpuppe für Menschenähnliche, Vierbeiner-Modell wie beim Wolf): Rig, Bewegungen, Ausfallschritt und Stürze sind schon da; ein neues Monster braucht vor allem Ausrüstung, Maße, Kopf und eigene Haltungen. Es gelten die [Stil-Leitlinien](STIL.md) (je drei Varianten in Aussehen und Bewegung).
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
- **Weitere Zauber** ab Stufe 5 für alle Zauberklassen.
- **Kleriker-Fähigkeit „Läutern“:** heilt Zustände.
- **Positive Zustände:** Gesegnet, Geschützt, Hast, z. B. durch Tränke.
- **Neue Ausrüstungseigenschaft:** Giftresistenz.
- **Monster-Geräusche:** eigene Laute je Gegnerart, jeweils in mehreren zufälligen Varianten wie beim Wolfsheulen. Zum Beispiel Knurren vor dem Angriff, Fauchen, Schmerzlaute bei Treffern und Todeslaute. Dazu Klappern bei Skeletten, Stöhnen bei Zombies, Schmatzen beim Ockergallert, Kreischen bei Fledermäusen, Kampfrufe bei Goblins und Kobolden, Brüllen bei Bossen. Elite-Gegner und Grimmzahn klingen tiefer.

- **Rudelwölfe beißen ins Leere (gemeldet 08.10., v0.1.210):** Der Leitwolf springt beim Biss zum Helden, die anderen Wölfe des Rudels beißen nur auf ihrem Platz im Hintergrund (im Film bestätigt). Vorschlag: Rudelwölfe springen wie der Leitwolf zum Helden und zurück, gleitend und im selben Takt; wer beißt, wird vor den anderen gezeichnet.

## Welt und Leben auf der Karte

- **Wegesystem:** geschwungene Wege statt Treppenstufen aus Kacheln. Wege werden als Linien mit Breite über die Karte gelegt (Kurven, Abzweigungen, ausgefranste Ränder, Fahrspuren) und nicht mehr Kachel für Kachel gezeichnet. Gilt für Waldpfade, Dorfwege und spätere Straßen; Begehbarkeit bleibt wie bisher an den Kacheln.
- **Kartenansicht** im Menü mit den bereits erkundeten Bereichen.
- **Schnellreise über die Kartenübersicht (Idee 09.10., 12:49):** Die Pergamentkarte (Entwurf C, `tools/preview` Modus `WEGE`) als Übersicht, mit Nebel des Unerkundeten wie auf der Karte; einmal entdeckte Orte (z. B. Bornim, Garricks Feuer, Höhleneingang) sind Reiseziele, gegen Gold. Gedanken dazu: ein Fuhrmann in Bornim oder Garrick als Führer statt Teleport; Preis nach Entfernung; Zeit vergeht (wer abends aufbricht, kommt nachts an); unterwegs ein Wurf auf einen Überfall, nachts höher; nicht aus Höhlen heraus, nicht im Kampf.
- **Bewohner mit Tagesablauf:** Die Wirtin fegt vor der Tür, Läden haben nachts geschlossen. (Jorins Streife am Schlagbaum gibt es schon.)
- **Monsterverhalten:** Goblins patrouillieren auf Wegen, Fledermäuse hängen an der Höhlendecke und stürzen herab.
- **Wetter:** Nebel; Windgeräusche als weiterer Umgebungsklang.
- **Nebenquests** über ein Anschlagbrett, z. B. „Bring 5 Wolfsfelle“ oder „Finde Gwennas verlorenen Ring“.
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

## Balance – offene Beobachtungen

- **Kämpfer** erledigt normale Monster auf Stufe 5–6 meist in einer Runde (Zusätzlicher Angriff). Bei Bossen ist er gefordert. Falls störend: nachlegen.
- **Magier** ist gegen Bosse die zerbrechlichste Klasse (Grak auf Stufe 5–6: 44–62 % Siege in der Simulation).
- **Feuerball:** heute einmal pro Kampf mit 8W6. Falls er doch zu stark wirkt, gibt es zwei geprüfte Alternativen: 6W6 oder höhere Kosten (9 ZP).
- Werkzeug zum Prüfen: Kapitelsimulation `SIM=1 ./gradlew -p core test --tests '*ChapterSimTest*'`.

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
