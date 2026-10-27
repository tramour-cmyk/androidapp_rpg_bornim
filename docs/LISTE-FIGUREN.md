# Figuren

Nachschlagen (70.5, Nutzer 14.10.): wie wiederkehrende Leute und einmalige Monster aussehen, damit man sie auf der Karte, im Kampf und in Zwischenbildern wiedererkennt. **Die einzige Quelle fürs Aussehen**; Code-Kommentare beschreiben die Umsetzung, der Storyplan nur Rolle und Handlung. Gewöhnliche Monster (je drei Varianten) nur mit ihrer Abnahmeliste (348.11, unten).

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

## Abnahmelisten der Modelle (348.11)

Je Modell fünf prüfbare Punkte (Größe, Umriss, Merkmal, Farbe, Haltung), aus der bisherigen gezeichneten Fassung im Code; vor Entwurfsrunde 1 von Homer, einmal vom Chef gebilligt. Helfer, Homer, Diogenes prüfen nur diese Punkte, je Punkt Ja oder Nein mit einem Satz; alles andere kommt auf die Liste für den Feinschliff (`LISTE-UMZUG-348.md` „Arbeitsteilung“ 7). „Bisher“ = die Fassung, die heute im Spiel ist.

Gebilligt (Chef 25.10., 22:00):

**Goblin** (Jerry; ab Entwurfsrunde 5; gilt für den Nahkämpfer; Späher und Schamane bekommen eigene Listen)
1. **Größe:** 108 cm, reicht dem Helden (175 cm) bis zur Brust; je Goblin 91–109 %.
2. **Umriss:** großer Kopf auf kleinem, drahtigem Körper (der Kopf ist ein Viertel der Körperhöhe, beim Menschen ein Siebtel), lange Arme, große Hände und Füße.
3. **Merkmal Kopf:** Ohren seitlich hoch und spitz nach hinten; tiefer Brauenwulst; breiter Kiefer mit Unterbiss und zwei Hauern über der Oberlippe; lange Nase mit Haken an der Spitze; schmale gelbe Augen im Schatten der Brauen; gefletschtes Maul mit krummen gelben Zähnen; alte Narbe über dem linken Auge.
4. **Farbe und Ausrüstung:** dunkles Oliv, nie heller als bisher; drei Ausrüstungen auf einen Blick verschieden: Lederwams, Schild aus rohen Brettern und räudiges Fell; Lederkappe, Beil und Fell; Helm, nackter Oberkörper, Säbel und Dolch. Klingen rostig.
5. **Haltung:** geduckt, Knie gebeugt, Rumpf vorgebeugt.

**Wildschwein** (Jerry; ab Entwurfsrunde 4)
1. **Größe:** etwa 85 cm Schulterhöhe (je Tier 75–94 cm), Schulter etwa auf Hüfthöhe des Helden.
2. **Umriss:** vorn tief und hoch, hinten schmaler, Kopf ein langer Keil, schlanke Beine auf gespaltenen Hufen.
3. **Merkmal:** gebogene Hauer aus beiden Kiefern (unten lang, oben kurz), flache Rüsselscheibe, zottige Backen, Borstenkamm auf dem Rücken, kleine spitze Ohren (beim Angriff angelegt), dünner Schwanz mit Quaste.
4. **Farbe:** drei Felle auf einen Blick verschieden: fast schwarz; grau gesprenkelt mit Narben; rostbraun mit Narben und eingerissenem Ohr. Kleine rote Augen, die nicht leuchten.
5. **Haltung:** Kopf tief, Kamm aufgestellt.

**Held** (Tom; ab Entwurfsrunde 6)
1. **Größe:** nach Volk wie bisher (Mensch 175, Elf 172, Zwerg 135, Halbling 105, Halbork 185 cm; Frauen 7 % kleiner); Maßstab für alle anderen Modelle.
2. **Umriss:** Volk und Körperbau am Umriss erkennbar (Zwerg breit und gedrungen, Elf schlank, Halbork massig).
3. **Merkmal:** jede angelegte Ausrüstung sichtbar und erkennbar (Waffe, Schild, Rüstung, Helm, Umhang); Klasse ohne Text erkennbar.
4. **Farbe:** Haut, Haar und Stoffe wie in der Charaktererstellung gewählt; nie heller als bisher.
5. **Haltung und Gesicht:** aufrecht, bereit, Waffe in der Hand; Augen, Brauen, Mund wie bisher.

**Leute** (Tom; ab Entwurfsrunde 5; Merkmale und Farben je Person in der Tabelle oben)
1. **Größe:** wie der Held nach Volk und Geschlecht; Kinder kleiner.
2. **Umriss:** jede Person an Umriss oder Gerät erkennbar (Aldrics Stab, Speer der Wache, Borins Hammer, Garricks Bogen); keine zwei gleich.
3. **Merkmal:** die Merkmale aus der Beschreibung je Person (z. B. Rowena Schürze und hochgekrempelte Ärmel, Aldric weißer Bart, Osric kahl, Lyra Stirnreif, Bram Bart und Leinenhemd).
4. **Farbe:** Kleidung je Person in der Farbe wie bisher (z. B. Lyra weiße Robe, Jorin das Blau des Dorfes, Thessa Rost-Ocker); nie heller als bisher.
5. **Haltung und Gesicht:** jede steht oder sitzt anders (Borin am Tisch); Augen, Brauen, Mund wie bisher.

Gebilligt (Chef 25.10., 23:33, 348.11 b): übrige Monster aus Kapitel 1. Für alle gilt:
- **Echte Größe:** die Maße gelten auch im Kampfort, ohne die bisherige Vergrößerung (Gegner 1,3-fach, Bosse 1,5-fach).
- **Leuchten** nur, wo eine sichtbare Quelle ist: Schamane (Fluch) und Skelett (Untod), dazu Grimmzahn (Faden der Geschichte); alle anderen Augen matt, grelle Farben gedämpft.
- **Kits am Umriss verschieden** (Kapuze, Fellkragen, Helm), nicht nur an der Farbe.
- Jeder Goblin, Kobold, Untote ist zufällig schlank, mittel oder kräftig.
- **Gekaufte Modelle** (348.12c, Chef 26.10., 20:32): Größe nach diesen Listen, nicht nach dem Modell; Augen matt, auch wo das Modell leuchtet (nur das Skelett behält seinen Glutpunkt); Rolle des Vorgängers bleibt, Werte nach dem Modell.

**Goblin-Späher**
1. **Größe:** wie der Goblin, 98–118 cm.
2. **Umriss:** wie der Goblin: großer Kopf, kurze Beine, sehniger Körper, lange Arme, große Hände und Füße.
3. **Merkmal:** Kopf wie der Goblin; Kurzbogen.
4. **Farbe und Ausrüstung:** Haut wie der Goblin; drei Kits am Umriss verschieden: Lederwams und Kapuze; Lederkappe und Fellumhang; Lederwams und Fellumhang.
5. **Haltung:** geduckt wie der Goblin, Bogen in Ruhehaltung.

**Goblin-Schamane**
1. **Größe:** wie der Goblin.
2. **Umriss:** wie der Goblin, Stab aufgestellt, gehörnter Tierschädel als Kappe.
3. **Merkmal:** Gesicht bemalt wie ein Totenschädel, Augenhöhlen rußschwarz, Blutstreifen über die Nase; Kette aus Knochen und Zähnen; Stab mit Schädel oben. Augen brennen grün, der Schädel am Stab glimmt (sein Fluch).
4. **Farbe und Ausrüstung:** Haut wie der Goblin; drei Kits am Umriss verschieden: rußschwarze Robe; Fellumhang; beides.
5. **Haltung:** Stab aufgestellt, die freie Hand mit gekrümmten Fingern vorgestreckt.

**Kobold**
1. **Größe:** 72–88 cm, reicht dem Helden bis knapp unter die Hüfte.
2. **Umriss:** großer Kopf, sehr kurze Beine, große Hände und Füße, dicker Schwanz bis zum Boden.
3. **Merkmal:** Kopf wie ein kleiner Drache: lange Schnauze, offener Kiefer mit Nadelzähnen, zwei Hörner nach hinten, Kragen hinter dem Kiefer, Stachelkamm, Schlitzaugen (gedämpft orange, nicht grell).
4. **Farbe und Ausrüstung:** Schuppen rostrot, ocker, ziegel- oder umbrabraun, heller Bauch; drei Kits: Speer und Lederkappe; Speer und Schild aus Brettern; Dolch und Fellumhang.
5. **Haltung:** tiefer geduckt als der Goblin, Schnauze vorgestreckt.

**Skelett**
1. **Größe:** 160–185 cm, etwa wie der Held.
2. **Umriss:** menschlich, nur Knochen, sehr dünn.
3. **Merkmal:** Totenschädel mit leicht offenem Kiefer und Zahnreihen, schwarze Augenhöhlen mit je einem schwachen Glutpunkt, Nasenkerbe.
4. **Farbe und Ausrüstung:** vergilbter, fleckiger Knochen; drei Kits, alles rostig: Kurzschwert und Helm; Kurzschwert und Schild; Speer und Helm.
5. **Haltung:** aufrecht und steif, Kopf leicht gedreht.

**Wiedergänger** (gekauft, Evil Undead; ersetzt den Zombie, 348.12c)
1. **Größe:** 160–185 cm, etwa wie der Held; jeder zufällig schlank, mittel oder kräftig.
2. **Umriss:** menschlich, ausgemergelt, überlange Arme mit langen Fingern und schwarzen Nägeln; kriecht und richtet sich auf.
3. **Merkmal:** Gesicht wie ein Totenschädel, Grinsen ohne Lippen, Rippen frei; Augen matt, auch wo das Modell leuchtet; Erde an Haut und Lumpen.
4. **Farbe und Ausrüstung:** Haut grabgrau, fahl oder erdbraun, nicht plastikglänzend; Fleischreste gedämpft, kein Gedärm; drei Kits am Umriss verschieden (Lumpen; Leichenhemd; rostiges Kettenhemd), immer Krallen statt Waffe.
5. **Haltung:** vorgebeugt, Arme hängen bis zu den Knien, Kopf vorgestoßen.

**Grabhund** (gekauft, Barghest; ersetzt den Ghul, 348.12c)
1. **Größe:** Schulter 90–100 cm, groß wie ein Kalb; Rücken etwa auf Hüfthöhe des Helden; jeder zufällig schlank, mittel oder kräftig.
2. **Umriss:** Riesenhund auf vier Beinen, tiefe Brust, schmale Hüften, schwere Mähne über Hals und Schultern.
3. **Merkmal:** schwarze Mähne über nackter fahler Haut; langer Fang mit gebleckten Zähnen; Krallen, die sich in den Boden graben; Augen matt, auch wo das Modell leuchtet.
4. **Farbe:** Haut leichenfahl, grabgrau oder graublau, Mähne schwarz; drei Tiere auf einen Blick verschieden (Mähne lang, kurz oder zerrupft, Narben).
5. **Haltung:** Kopf gesenkt, lautlos, lauernd.

**Krogg** (einmalig, Tabelle oben)
1. **Größe:** 212 cm, gut einen Kopf größer als der Held.
2. **Umriss:** massig, breite Schultern, lange Arme, große Hände, kurzer Hals.
3. **Merkmal:** Bärenkopf mit kurzer schwerer Schnauze, breite schwarze Nase, runde hohe Ohren, Mähne bis zu den Schultern, Bart, große Hauer, kleine Augen (gedämpft rot, nicht grell), drei Krallennarben über der Schnauze; Schlüssel am Gürtel (neu).
4. **Farbe und Ausrüstung:** zottiges Fell lohfarben, dunkelbraun, rost oder falb, dunkle Mähne; Morgenstern aus dunklem Eisen, schwarz von altem Blut (neu), Fellumhang, Lendenschurz, kein Schild.
5. **Haltung:** Schultern hochgezogen, leicht geduckt.

**Grak** (einmalig, Tabelle oben)
1. **Größe:** 186 cm, etwas größer als der Held.
2. **Umriss:** größer und breiter als ein Mensch.
3. **Merkmal:** breites flaches Gesicht, schwere Stirn, platte Nase, spitze Ohren, lange Hauer, geschoren bis auf einen Kriegerzopf, bernsteinfarbene Augen, schwarze Kriegsbemalung über den Augen, Narbe.
4. **Farbe und Ausrüstung:** Haut dunkelorange bis rotbraun; Halbplatte über dunkelrotem Steppmantel, roter Hauptmannsumhang, Großaxt in beiden Händen, kein Helm.
5. **Haltung:** aufrecht und gedrillt; beim angekündigten schweren Schlag die Axt über dem Kopf.

**Riesenratte**
1. **Größe:** Schulter 44–56 cm (die größte etwa ein Fünftel größer als die kleinste); Rumpf mit Kopf 1,1–1,4 m, Schwanz etwa drei Viertel davon.
2. **Umriss:** buckliger Vierbeiner mit langem, spitzem Kopf.
3. **Merkmal:** lange orange Nagezähne, immer sichtbar, Maul beim Angriff weit offen; räudige, verschorfte kahle Stellen; nackter, geringelter Schwanz am Boden; runde nackte Ohren; Krallenhände; Augen matt; Nase und Hände gedämpft, nicht rosa.
4. **Farbe:** braun; grau mit mehr Räude und Narbe; schwarz mit eingerissenem Ohr; Fell mit Struktur, nicht glatt.
5. **Haltung:** geduckt, schnuppernd, Schwanz pendelt.

**Riesenspinne**
1. **Größe:** Körper 40–55 cm hoch; Beine von Spitze zu Spitze 1,5–1,7 m, etwa so breit wie der Held groß.
2. **Umriss:** Vorderteil, Taille, großer schräger Hinterleib; acht Beine mit hohen Knien.
3. **Merkmal:** acht Augen, zwei davon groß, matt; behaarte Kieferklauen mit gebogenen Giftzähnen und gedämpften Gifttropfen (nicht grell grün); Taster.
4. **Farbe:** schwarz mit blutroter Sanduhr; braun mit hellen Streifen und Beinringen; blassgrau mit Winkelmustern und Narben.
5. **Haltung:** Vorderbeine leicht erhoben und wippend, Giftzähne halb offen.

**Riesen-Hundertfüßer**
1. **Größe:** 1,4–1,6 m lang; Kopf in Ruhe auf Wadenhöhe.
2. **Umriss:** flach, 26 Panzerglieder in S-Form, Vorderende aufgerichtet.
3. **Merkmal:** zwölf Beinpaare, lange Fühler, sichelförmige Giftklauen, zwei nachgezogene Hinterbeine.
4. **Farbe:** rostrot mit gelben Beinen; blauschwarz mit roten Beinen; ocker und schwarz gebändert.
5. **Haltung:** nie still: Körper wellt sich, Kopf hebt und senkt sich, Klauen gehen auf und zu.

**Riesenfledermaus**
1. **Größe:** schwebt, Ohrspitzen etwa auf Hüfthöhe des Helden; Spannweite 1,5–1,8 m.
2. **Umriss:** aufrecht hängender Rumpf, ausgebreitete Hautflügel mit Fingerknochen.
3. **Merkmal:** hohe, eingekerbte Ohren; Nasenblatt; aufgerissenes Maul mit Fangzähnen und Geiferfaden; Hakenkrallen; Augen matt.
4. **Farbe:** braun; schwarz mit eingerissenem Flügel; grau mit Narben; Braun und Schwarz auf einen Blick verschieden (bisher beide fast schwarz).
5. **Haltung:** schwebt, schlägt ruhig mit den Flügeln, wippt, das Maul arbeitet.

**Riesenegel** (gekauft, Mobile Leeches; ersetzt die Stirge, 348.12c)
1. **Größe:** 0,8–1,2 m lang, dick wie ein Unterarm; aufgerichtet etwa kniehoch.
2. **Umriss:** Wurm aus Ringen ohne Beine, kriecht, richtet das Vorderende auf; fliegt nicht.
3. **Merkmal:** runder Saugmund voller Zähnchen, kein Auge; prall vom Blut des letzten Opfers.
4. **Farbe:** nur dunkle Häute: braun, grau, ocker; nie türkis, nie glühend rot, keine leuchtenden Ringe; nass glänzend, sonst matt.
5. **Haltung:** windet sich, tastet mit dem Vorderende, schnellt beim Angriff vor.

**Säureschnecke** (gekauft, Giant Slug; ersetzt die Ockergallerte, 348.12c)
1. **Größe:** lang wie ein Pferd (2,0–2,4 m), Kopf aufgerichtet etwa auf Brusthöhe des Helden.
2. **Umriss:** Nacktschnecke ohne Haus, flach hinten, Kopf vorn aufgerichtet.
3. **Merkmal:** Stielaugen, die nach dem Ziel tasten; Zahnmaul mit langer Zunge; zischende Schleimspur.
4. **Farbe:** schlammbraun, kränklich gelbgrau oder dunkel ocker; nirgends rosa (Beulen auf dem Rücken und Perlen an der Zunge in Hautfarbe übermalt); Schleim nass, nicht grell.
5. **Haltung:** sehr langsam, hebt den Kopf, bevor sie zustößt; schwer verwundet flacher.

Wolf und Grimmzahn ohne Liste: sie stehen nach Wort des Chefs. Wiedergänger, Grabhund, Riesenegel, Säureschnecke: Homer 26.10. nach Chefsache 34812c-monsterwahl (Git, `6d3ffeb9b^`), gebilligt (Chef 27.10., 10:04, Vorgangsarchiv 348.12c Listen; beim ersten Standbild zuerst Größe prüfen). Neue Monster (ab Kapitel 2) bekommen ihre Liste vor Entwurfsrunde 1 (Homer).

Fundstellen übrige Monster: Chefsache 34811b-monsterlisten (Git, `929f19051^`). Fundstellen: Goblin: `Doll.kt` :65–70, :102, :879–935; `FoeArt.kt` :86; `MonsterKit.kt` :14–16, :33–38. Wildschwein: `Beast.kt` :267–368; `BeastArt.kt` :36–45, :213. Held: `Doll.kt` :65–70, :724–725. Leute: `MapFolk.kt` :40–98.

## Verwechslungsgefahr

Lange Stangen tragen Aldric (quer auf der Schulter), Jorin (Speer mit Spitze), Ansel (senkrecht, viel länger) und Kael (Stock, gebeugt, mit Decke und Laterne). Am ersten Standbild prüfen; reicht es nicht, bekommt Ansel statt des Stakstocks eine Reuse.

Vierbeiner im nächtlichen Wald: Wolf, Grimmzahn (fast schwarz, Narbe) und Grabhund (größer, schwarze Mähne über fahler nackter Haut) am ersten gemeinsamen Standbild prüfen.
