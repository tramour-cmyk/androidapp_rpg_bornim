# Figuren

Nachschlagen (70.5, Nutzer 14.10.): wie wiederkehrende Leute und einmalige Monster aussehen, damit man sie auf der Karte, im Kampf und in Zwischenbildern wiedererkennt. **Die einzige Quelle fürs Aussehen**; Code-Kommentare beschreiben die Umsetzung, der Storyplan nur Rolle und Handlung. Gewöhnliche Monster (je drei Varianten) stehen nicht hier.

- **Merkmal** = woran man die Figur auch von hinten oder als Schattenriss erkennt (70.2, `DESIGN-STIL.md` „Zwischensequenzen“). Es bleibt in jedem Bild gleich. Waffen nur in Worten, bei kämpfenden Figuren; Kampfwerte stehen in `core` (146).
- **Charakter** = ein bis zwei Wörter; Dialoge und Gesten folgen ihm.
- **Schlüssel** = je Figur eins: die Geste zum goldenen Zeichen (134.2, im Spiel seit Build 23) oder, wo der Held die Figur nicht trifft, ein Satz aus freigegebenen Texten. Gesten: **Hand** (kurz heben), **Winken** (zweimal heran), **Nicken** (zweimal), **Merkmal** (das gehaltene Ding kurz anheben), je etwa eine Sekunde; wer keine hat, hebt die Hand. Nicken nur bei ruhigen Figuren, auf dem Handy zählt der Umriss.
- Einmalige Monster gibt es nur in einer Form (`DESIGN-STIL.md`, Ausnahme einmalige Monster).
- Neue Figur oder Änderung: Vorschlag an den Berater (Grundsatzfrage Aussehen), Eintrag hier nach Ja des Nutzers. „neu“ = beschlossen, im Spiel noch nicht gebaut.

## Kapitel 1: Bornim und Wald

| Figur | Umriss, Statur | Merkmal | Kleidung, Farben | Charakter | Schlüssel | Klang, Handlung | Ort |
|---|---|---|---|---|---|---|---|
| Ältester Aldric | alt, hager, langer weißer Bart | Stab quer auf der Schulter | Robe Pflaume, dunkler Umhang | würdevoll, besorgt | Merkmal: Stab von der Schulter heben | – | Ältestenhaus |
| Rowena | kräftig, Ärmel hochgekrempelt | helle Schürze; neu: Krug in der Hand | braune Wolle | herzlich, resolut | Merkmal: Krug heben, prostet zu | Wischen, Einschenken | Gasthaus |
| Schwester Lyra | schlank | Stirnreif | weiße Robe | ernst, ahnungsvoll | Nicken | – | Tempel (vorher Höhle) |
| Bruder Osric | mittel, kahl | Sonne auf der Brust; in Szenen eine Kerze | ungefärbte Wolle | sanft, fürsorglich | Hand, offen wie zum Segen | – | Tempel |
| Wache Jorin | kräftig, Kettenhemd, Helm | Speer auf der Schulter, blauer Wappenrock | Dorfblau | pflichtbewusst | Winken, knapp | – | Schlagbaum |
| Thessa | mittel, wohlhabend | Reiseumhang | Rost und Ocker | geschäftstüchtig | Winken, lockt Kundschaft | – | Kramladen |
| Borin | Zwerg, kräftig | Hammer auf der Schulter | Schmiedeleder | brummig, besserwisserisch | Merkmal: Becher heben | Becher, Stuhl, Husten | Gasthaus, am Tisch |
| Jäger Garrick | breit, kurzer Vollbart | Kapuze, Langbogen quer über dem Rücken | dunkles Oliv, dunkles Leder | wortkarg, unterstützend | Nicken | – | Lagerfeuer im Wald |
| Kräuterfrau Morwen | alt, schlank, graues Haar | Kapuze; neu: Kräuterbündel am Gürtel | Moosgrün | wissend, verschlossen | Winken, langsam | – | Tiefer Flüsterwald |
| Gwenna | mittel, Fischerin | neu: Tobins Ring an einer Schnur um den Hals | schlammiges Grün, Schal | trauernd, misstrauisch | Hand, zögernd | – | Dorf |
| Pim | Kind, klein | zu großer Kittel | Graublau | neugierig, schwärmerisch | Hand, schnell hin und her | – | Dorf |
| Bauer Bram | breit, sonnenverbrannt, Bart | grobes Leinenhemd | Leinen, Erdbraun | bodenständig | Hand | – | Dorf |
| Liska | schlank, Magd | Kopftuch | verblichenes Rot | scheu, klatschfreudig | Nicken | – | Dorf |
| Der alte Kael | sehr alt, gebeugt | Wolldecke um die Schultern, angesengte Laterne; Familienzeichen Raute mit Balken (alte Hausmarke; dasselbe Zeichen über der Tür seines Elternhauses in Aschfurt, 6d); in Kapitel 1 steht die Laterne auf einem kniehohen Steinsockel neben seiner Tür, Zeichen in den Sockel gemeißelt, nachts schwach bernsteinfarben brennend (80, 80a) | Wolldecke | verbittert, wissend | Merkmal: Laterne heben (80) | Husten, Stock auf Holz; sitzt nach der Tempelszene vor dem Haus, dreht die Laterne, schaut nach Süden | eigenes Haus |

Noch ohne Aussehen: Bäcker Edrik (verängstigt; Schlüssel `[73b.edrik]` „Ich mach nicht auf. Für niemanden.“), Schmied Dorran (arbeitsam; `[73b.dorran.nacht]` „Die Esse ist kalt. Komm morgen.“).

**Einmalige Monster**

| Figur | Umriss, Statur | Merkmal | Farben | Charakter | Schlüssel | Ort |
|---|---|---|---|---|---|---|
| Krogg der Grobian (Grottenschrat) | über 2 m, zottig, schwer, lange Arme, gebeugte Schultern | Morgenstern, schwarz von altem Blut; Schlüssel am Gürtel | Fell lohfarben bis rostbraun, dunkle Mähne | dumpf, hörig | „Schlüssel gehört Krogg! Grak sagt: niemand kommt durch!“ | Höhle, Ostflügel |
| Hauptmann Grak (Hobgoblin) | größer und breiter als ein Mensch, aufrecht und gedrillt | Kriegsaxt in beiden Händen, roter Hauptmannsumhang, barhäuptig mit Haarknoten und Kriegsbemalung | Haut dunkelorange bis rotbraun, Halbplatte | grausam, gerissen | „Der Prophet zahlt in Gold für jede Seele, die ich ihm bringe.“ | Höhle, Halle im Norden |
| Grimmzahn (Leitwolf) | Wolf, ein Fünftel größer | Narbe übers Auge, eingerissenes Ohr, rot glühende Augen | fast schwarz | herrisch | `[24.gegner.grimmzahn.2]` „Das Rudel verstummt. Grimmzahn tritt vor.“ | Tiefer Flüsterwald, Norden |
| Der Graue Prophet | nie zu sehen | Siegel: offenes graues Auge | Grau | offen (Storyplan) | „Der Tag der Asche naht.“ (Brief) | – |

## Kapitel 2: Südstraße, Schilfrode, Graumoor, Aschfurt

Leute aus Schilfrode tragen einen **Ölhaut-Umhang**; daran erkennt man sie auch als Opfer wieder. Gesten sind Vorschlag Homer (noch nicht gebaut); Schlüsselsätze kommen mit den Texten Kapitel 2 (41).

| Figur | Umriss, Statur | Merkmal | Kleidung, Farben | Charakter | Schlüssel | Klang, Handlung | Ort |
|---|---|---|---|---|---|---|---|
| Fuhrmann Jorrit | stämmig, mittleres Alter | breitkrempiger Hut, Peitsche am Gürtel, verbundener Unterarm | Ölhaut | ängstlich, redlich | Winken, hastig, hinter dem Wagen hervor | Seufzer; duckt sich hinter den Wagen, späht die Straße hinunter | Südstraße, dann Schilfrode/Bornim |
| Tobin | abgemagert, Bart verwildert, nie ganz aufrecht | reibt den leeren Ringfinger, grauer Stofffetzen ums Handgelenk | – | gebrochen | Nicken, kaum | sitzt zu Hause still neben Gwenna (oder bei Merle, 5e) | Kultlager, dann Bornim oder Schilfrode |
| Fährmann Ansel | hager | langer Stakstock (senkrecht, viel länger als Stab und Speer) | Ölhaut | still, beharrlich | Merkmal: Stakstock heben | Wasser gegen den Kahn, Seil knarrt; flickt bei Tag ein Seil | Fähranleger |
| Merle | – | Kopftuch, Korb mit Schilf | Ölhaut | wartend, zäh | Hand | schaut die Straße nach Norden hinunter, später flicht sie Schilfmatten | Schilfrode, Dorfrand |
| Fenn, Sohn von Merle und Ansel | jung | graue Kutte über Ölhaut | Grau | verblendet | – | Wache am Steg des Kultlagers (5a) | Kultlager |
| Händler Wendel | – | Stand unter Schilfdach | – | geschäftig | Winken | wischt den Tresen, ordnet Kisten | Schilfrode |

**Einmalige Gegner**

| Figur | Umriss, Statur | Merkmal | Farben | Charakter | Ort |
|---|---|---|---|---|---|
| Hauptmann Vesk | ehemaliger Zöllner | schwarze Rabenfedern am Helm, Säbel, Silberbeutel (klirrt bei jedem Schritt) | verblichenes Zöllnerwams über Kettenhemd, langer Mantel | gierig, verschlagen | Rabenschanze |
| Rask, Aufseher der Grauen (Aussehen offen) | – | – | graue Kutte | hart | Kultlager |
| Der Aschenpriester | – | Räuchergefäß mit Glut an einer Kette, offenes graues Auge auf der Brust, Gesicht mit Asche geweißt | graue Robe mit verkohltem Saum | fanatisch | Aschfurt, Kapelle |
| Gruft-Unhold | ausgezehrt, lange Klauen | Reste eines Ölhaut-Umhangs | graue Haut, tote Augen | – | Aschfurt, Kapelle |

## Verwechslungsgefahr

Lange Stangen tragen Aldric (quer auf der Schulter), Jorin (Speer mit Spitze), Ansel (senkrecht, viel länger) und Kael (Stock, gebeugt, mit Decke und Laterne). Am ersten Standbild prüfen; reicht es nicht, bekommt Ansel statt des Stakstocks eine Reuse.
