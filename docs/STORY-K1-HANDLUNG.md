# Story Kapitel 1: Hauptquest, Nebenquests, Zwischensequenzen

Gruppen K1-H, K1-N, K1-Z (Regeln, Marken, übrige Teildateien: `STORY-REGELN.md`). Welttexte (K1-W) in `STORY-K1-WELT.md`, Zwischenbildschirm in `STORY-BLENDE.md`. Nur Deutsch; Englisch beim Bauen übersetzen.

## K1-H Hauptquest

### Geänderte Dialogzeilen (41)

Ersetzen den bisherigen Text in `Story.kt`/`Jobs.kt` (bisheriger Text zum Auffinden in Klammern).

`[41.rowena.wach]` (Rowena beim Aufwachen; bisher „Na, endlich wach, {name}? Du hast geschlafen wie ein Stein.“)
Na, endlich wach, {name}? Für einen, der nur eine Nacht bleiben wollte, hast du geschlafen wie ein Stein.


`[41.aldric.auge]` (neue Zeile in Aldrics Gespräch über den Brief, nur wenn der Held den Fund am Steinkreis gemacht hat)
Ein graues Auge … wie auf dem Fetzen, den Jorin mir vom Steinkreis brachte. Dann war er schon hier, ganz nah bei Bornim.

`[41.garrick.krogg]` (Garrick über Krogg; bisher „Ich habe Goblins belauscht. Ihr Bugbear Krogg trägt den Schlüssel zu Graks Halle.“)
Ich habe Goblins belauscht. Ihr Grottenschrat Krogg trägt den Schlüssel zu Graks Halle.

### Weg über Morwen vor der Höhle (D4.1)

Freigegeben 15.10., 11:3x (Nutzer mit Sokrates); Grund: Bugbear-Merkmal „erster Hieb trifft härter“ (`Monsters.kt`) und Morwens Rauch (`[62i.ort.tiefwald]`). Rauchbündel nimmt Krogg den ersten Hieb (Kampfwirkung Jerry, Dialog Tom).

`[D4.1.garrick.morwen]` (Garrick nach `[41.garrick.krogg]` und „Er haust im Ostflügel …“, bis Krogg fällt; der ganze Krogg-Teil schon im ersten Gespräch nach den Tränken, D23.2)
Geh nicht mit leeren Händen zu ihm. Morwen, die Kräuterfrau im Tiefen Flüsterwald, weiß, wie man so einem den ersten Hieb nimmt.

`[D4.1.garrick.warnung]` (nur Heldenstufe unter 3, danach)
Und ehrlich, {name}: So wie du jetzt aussiehst, legt Krogg dich mit einem Schlag um. Sammel erst ein paar Narben im Tiefen Flüsterwald.

`[D4.1.morwen.krogg]` (Morwen, sobald Garrick getroffen und Krogg nicht besiegt, einmal; gibt 1 Rauchbündel)
Krogg? Grottenschrate schlagen aus dem Dunkel zu, und der erste Hieb ist der schlimmste. Aber ihre Nasen sind fein.
Wirf ihm das hier vor die Füße, sobald er auftaucht. Der Rauch beißt in den Augen, und sein Hieb geht ins Leere.

`[D4.1.rauch.tasche]` (Beschreibung des Rauchbündels in der Tasche; Nutzer 15.10., 12:2x)
Ein Bündel beißender Kräuter von Morwen. Krogg vor die Füße werfen: Der Rauch nimmt ihm den ersten Hieb. Nur im Kampf.

`[D4.1.chronik]` (Chronik, Aufträge, nach Garricks Hinweis; erledigt mit dem Rauchbündel oder Kroggs Fall)
**Rauch gegen Krogg**
Garrick riet {name}, vor dem Kampf gegen Krogg die Kräuterfrau Morwen im Tiefen Flüsterwald aufzusuchen. Sie kenne ein Mittel gegen den ersten Hieb eines Grottenschrats.

### Rund um die Tempelszene (68)

Vor und nach der Szene (Ablauf unter K1-Z).

`[68.aldric]` (Aldric, nach dem Ring)
Morgen bei Sonnenaufgang legt Lyra das Amulett zurück auf den Altar. Ganz Bornim wird dort sein, und du gehörst in die erste Reihe.

`[68.lyra.1]` (Lyra spricht den Helden nach dem letzten Bild von selbst an, 68j; freigegeben 17:38, 68h/68i)
Ich verdanke dir mein Leben, {name}. Und Bornim sein Licht.

`[68.lyra.2]`
Graks Leute sprachen von einem Lager im Süden. Dort brachten sie, wen sie nicht selbst behalten wollten.

`[68.lyra.3]`
Ich weiß nicht, was er von mir will. Aber ich träume seit Wochen von grauer Asche.

`[68.chronik.lager]` (Chronik, Aufträge, nach Lyras Gespräch; ohne Kartenmarke, 68k/68m)
**Das Lager im Süden**
Lyra erinnerte sich, dass Graks Leute von einem Lager im Süden sprachen, in das sie Gefangene brachten. Wer dort festgehalten wird und wer das Lager führt, weiß niemand in Bornim.

`[68.rowena.lager]` (Rowena, nach der Tempelszene)
Ein Lager im Süden? Die Fuhrleute meiden die Südstraße seit dem Frühjahr. Jetzt weiß ich vielleicht, warum.

`[68.aldric.lager]` (Aldric, nach der Tempelszene)
Lyra hat mir vom Lager erzählt. Wenn dort Leute aus der Gegend festsitzen, kann Bornim nicht einfach wegsehen.

`[68.kapitelende]` (Kapitelende-Karte nach Aldric, vor Nacht und Andacht, `Story.chapterEndText`; 68o, Nutzer 15.10., 17:4x)
Bornim feiert bis tief in die Nacht. Das Sonnenamulett ist zurück in Bornim, und Schwester Lyra ist in Sicherheit.

Doch der Brief mit dem grauen Siegel lässt dich nicht los. Wer ist der Graue Prophet? Und was ist der Tag der Asche?

ENDE VON KAPITEL 1

Du kannst weiterspielen, Monster jagen und deinen Helden verbessern.

`[68.suedrand]` (Textkasten am Südrand, solange Kapitel 2 fehlt; 68p, Nutzer 15.10., 17:4x)
Der Weg nach Süden ist noch nicht begehbar. Kapitel 2 folgt mit einem späteren Update.


## K1-N Nebenquests

Bisher keine freigegebenen Texte; die Aushänge stehen in `Jobs.kt` und kommen beim ersten Ändern hierher.

## K1-Z Zwischensequenzen

### Intro (69)

Freigegeben 13.10., 16:31. Form nach `DESIGN-STIL.md` „Zwischensequenzen“ (70); Bilder aus Sicht des Helden, Du-Form. Nur beim ersten Spielstart; in „Bisher geschehen“ der erste Eintrag (69d). Klang (69c): leise Wind, Fluss, Grillen; Titelmusik erst beim Schwarzbild („Ancient Legend“ bleibt der Tempelszene 68 vorbehalten). Danach weckt Rowena den Helden (`[41.rowena.wach]`).

`[69.intro.1]` (Bild: die Südstraße unter dem Mond)
Drei Tage nach Norden. Die Straße ist leer, nur der Mond geht mit.

`[69.intro.2]` (Bild: Fluss und Brücke, in der Ferne Lichter von Bornim)
Hinter der Brücke ein paar Lichter. Bornim. Ein Bett für eine Nacht, mehr willst du nicht.

`[69.intro.3]` (Bild: leerer Dorfplatz, am Tempel ferne Fackeln und Schatten)
Der Platz schläft. Nur am Tempel wandern Fackeln. Eine späte Andacht, denkst du.

`[69.intro.4]` (Bild: warmes Fenster des Gasthauses, die Tür geht auf)
Im »Schlafenden Greif« brennt noch Licht. Die Wirtin fragt nicht viel.

`[69.intro.5]` (Schwarzbild; gedämpft eine Glocke, Rufe, ein ferner Schrei: der Überfall, den der Held verschläft, 69b)
Irgendwo schlägt eine Glocke. Du hörst sie nicht.

### Tempelszene: Rückkehr des Amuletts (68)

Freigegeben 13.10., 17:26. Abschluss von Kapitel 1, Form nach `DESIGN-STIL.md` „Zwischensequenzen“ (70): fünf Standbilder mit Überblendung, Du-Form, Musik „Ancient Legend“. Nach der Abgabe des Amuletts lädt Aldric den Helden zur Morgenandacht ein (`[68.aldric]`, nach dem Ring, vor „Ruh dich aus …“). Danach keine freie Wahl: schwarze Blende, nächster Morgen, sofort die Szene; danach ist das Spiel wieder frei (68a geändert, Nutzer 17:28: sonst warten alle tagelang im Tempel). Danach steht der Held am Morgen im Tempel, Lyra und Osric sind ansprechbar (68f); die Nacht zählt als Rast (68g). Lyra leitet den Tempel, Bruder Osric ist ihr Gehilfe und Heiler (68d).

`[68.tempel.1]` (Bild: Tempel innen, voll mit Dorfleuten, der Altar leer)
Der Tempel ist voll. Tagelang war er kalt und leer.

`[68.tempel.2]` (Bild: Aldric legt Lyra das Amulett in die Hände, der Held steht daneben)
Aldric gibt Lyra das Amulett. Sie hält es lange, als könnte es zerbrechen.

`[68.tempel.3]` (Bild: Lyra am Altar, Osric hält ihr die Kerze)
Osric hält die Kerze ruhig. Lyra betet in Worten, die älter sind als der Tempel selbst.

`[68.tempel.4]` (Bild: das erste Morgenlicht fällt durchs Tempelfenster auf das Amulett, die Gesichter werden hell)
Das erste Licht des Tages fällt durchs Fenster. Das Amulett fängt es auf.

`[68.tempel.5]` (Bild: Lyra allein, Blick in die Dämmerung; leiser Hinweis auf Kapitel 2)
Bornim atmet auf. Nur Lyra sieht noch lange ins Grau hinaus.

## Fleisch an die Wirtin (139)

`[139.rowena.fleisch]` (Rowena, wenn der Held rohes Fleisch dabeihat; vor dem Verkauf)
Frisches Fleisch aus dem Wald? Gib her, daraus wird morgen der Eintopf im Greif.
EN: Fresh meat from the woods? Hand it over, it'll be tomorrow's stew at the Griffin.

`[139.rowena.danke]` (nach dem Verkauf)
Ehrlicher Preis für ehrliche Ware. Komm wieder, wenn du mehr erlegst.
EN: An honest price for honest goods. Come back when you've hunted more.

## Durchgang Kapitel 1 (280)

Homer 21.10.: Texte, die nicht zu dem passen, was man sieht, oder fest Benanntem widersprechen. Bau Tom (280.1).

`[280.tipp]` (Aufwachen im Greif, nach Rowenas letzter Zeile; ersetzt in `Story.kt` „Tipp: Mit dem Steuerkreuz bewegst du dich, mit A sprichst du … START öffnet das Menü.“: es gibt keinen Knopf A und kein START, das Steuerkreuz nur in der klassischen Steuerung)
Fingersteuerung: Tipp: Zieh den Finger über das Bild, um zu laufen, oder tippe dorthin, wo du hinwillst. Tippe auf Leute und Dinge, um mit ihnen zu sprechen oder sie zu untersuchen. Der Beutel oben öffnet das Menü.
EN: Tip: drag your finger across the screen to walk, or tap where you want to go. Tap people and things to talk to them or examine them. The bag at the top opens the menu.
Klassische Steuerung: Tipp: Mit dem Steuerkreuz läufst du, der große Knopf spricht mit Leuten und untersucht Dinge. Der Beutel oben öffnet das Menü.
EN: Tip: the D-pad moves you; the big button talks to people and examines things. The bag at the top opens the menu.

`[280.krogg]` (Chronik, `Chronicle.kt`) „der Bugbear Krogg“ → „der Grottenschrat Krogg“, wie freigegeben in `[64d.krogg]` (feste Namen, `STORY-REGELN.md`).

## Lyras Befreiung und Lohn der Sammelaufträge (356)

Entschieden 24.10. (356 a 21:32, 356 b 21:33, Vorgangsarchiv). Bau Lyra 356.1 (Jerry), Aufträge 356.2.

**Lyra (356.1).** Ablauf: Lyra an den Pfeiler gekettet; nach Graks Tod liegt in seiner Beute ein Schlüssel; der Held schließt auf, Ketten fallen. Dann ihre vier Zeilen wie bisher (`Story.kt`, Weihwasser bleibt), danach der Segen, dann geht sie sichtbar zum Hallenausgang. Die Schlusszeile „Lyra eilt dem Ausgang entgegen.“ entfällt, weil man es sieht.

`[356.schluessel]` (Fund bei Grak, Name des Gegenstands) Graks Schlüssel. Beschreibung: Ein kleiner, blanker Schlüssel. Er passt nicht zu den Türen.
EN: Grak's Key. Description: A small, bright key. It fits none of the doors.

`[356.ketten]` *Der Schlüssel dreht sich schwer. Die Ketten fallen klirrend zu Boden.*
EN: *The key turns stiffly. The chains fall clattering to the floor.*

`[356.lyra.segen]` *Lyra legt dir die Hand auf die Stirn. Warmes Licht fließt durch dich.* „Das Morgenlicht vergisst niemanden, der ihm dient.“
EN: *Lyra lays her hand on your brow. Warm light flows through you.* "The Dawnlight forgets no one who serves it."

**Aufträge (356.2).** Geändert nur, was die neue Menge und der neue Lohn verlangen; Rest wie in `Jobs.kt`.

`[356.felle.zettel]` Suche drei Wolfsfelle, dicht und ohne Löcher. Der Winter kommt früh dieses Jahr. Bezahlung bei Thessa im Kramladen.
EN: Wanted: three wolf pelts, thick and whole. Winter comes early this year. Payment from Thessa at the general store.

`[356.felle.lohn]` 60 Gold, ein Pelzumhang
EN: 60 gold, a fur cloak

`[356.felle.bringen]` Drei Wolfsfelle, wie am Brett verlangt. Dicht und ohne Löcher.
EN: Three wolf pelts, as the board asked. Thick and whole.

`[356.felle.dank]` Drei. Gut. Die Felle riechen noch nach Blut – das wäscht sich aus. Hier, dein Lohn. Und den Umhang hab ich aus dem letzten Winter. Der hält warm.
EN: Three. Good. They still smell of blood – that washes out. Here, your pay. And this cloak is from last winter. It keeps you warm.

`[356.pelzumhang]` (Stück, ungewöhnlich, Umhang) Thessas Pelzumhang
EN: Thessa's Fur Cloak

`[356.hauer.lohn]` 50 Gold, ein Hauerdolch
EN: 50 gold, a tusk dagger

`[356.hauer.dank]` Hm. Ordentlich gebrochen, nicht geschnitten. Damit lässt sich arbeiten. Nimm. Und den hier – Griffschalen aus Hauer, wie die, die ich jetzt mache.
EN: Hm. Broken clean, not sawn. I can work with these. Take this. And this one – grip plates of tusk, like the ones I'm making now.

`[356.hauerdolch]` (Stück, ungewöhnlich, Dolch) Borins Hauerdolch
EN: Borin's Tusk Dagger
