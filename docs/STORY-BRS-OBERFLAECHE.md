# Oberfläche und Namen nach dem BRS (870.15)

Homer 10.11.; Teil von `STORY-BRS-ANLEITUNG.md` (Grundsätze dort). Für Schritt 4 (Tom, 870.4), 5 und 6 (Jerry, 870.5, 870.6), 8 (Tom, 870.9) und 9 (870.13). Absichten der Gegner ohne Würfel stehen schon als `[870.14.ansage.…]` in `STORY-BRS-KAMPF.md`. Fremd geprüft 16:50.

## Oberfläche „ui“ (`daten/texte.json`)

Entfallen mit `erschaffung.gd`, `heldwerte.gd` und den Klassen (Schritt 4), ohne Ersatz: `chooseClass`, `proficiency`, `hitDie`, `primary`, `armorProf`, `points`, `fromLevel`, `cannotEquipArmor`, `attack` (Angriffsbonus), `passive`, `unlimited` (∞ für Zaubertricks), `ac` (Schutzwert heißt `[870.14.kw.schutz]`). Geändert:

- `sp`: Mana / Mana (Leiste, Kampfkopf)
- `hp`: Leben / Life (Leiste, Kampfkopf, an Zahlen; nie TP/HP, 1320)
- `level`: in der Leiste kurz „St.“ / “Lv” wie heute; im Heldenreiter und auf dem Kapitelschirm Heldenstufe / Hero Level
- `skills`: im Heldenreiter Fertigkeiten / Skills (Überschrift der Fertigkeitenliste); im Kampf heißt der Knopf Können / Abilities (`[870.14.knopf.koennen]`, eigener Schlüssel)
- `chooseRace`: Wähle dein Volk / Choose your people
- `alreadyFull`: Dein Leben ist schon voll. / Your life is already full.

## Rast „rast“

- `short`: Kurze Erholung · 2 Stunden / Short Respite · 2 hours
- `long`: Langes Ausruhen · 9 Stunden / Long Rest · 9 hours
- `shortDoes` (1038 R1, Homer 12.11., 1047): Ausdauer voll, kein Leben zurück / Full stamina, no life back
- `longDoes`: Leben, Mana und Ausdauer voll, Zustände geheilt / Life, mana and stamina full, conditions cured
- `longDone`: Das Lange Ausruhen hattest du heute schon. / You have already had your Long Rest today.
- `roomDoes`: Ein Bett oben unter dem Dach: Langes Ausruhen / A bed upstairs under the roof: Long Rest
- `hourGone`: Zwei Stunden vergehen. / Two hours pass. · `hoursGone`: Neun Stunden vergehen. / Nine hours pass.
- `shortRested` (1038 R1, ohne `{0}`): Zwei Stunden Ruhe. Die Ausdauer ist voll. / Two hours of rest. Your stamina is full.
- `longRested`: Neun Stunden Schlaf. Leben, Mana und Ausdauer sind voll. / Nine hours of sleep. Life, mana and stamina are full.
- `roomRested`: Du steigst die Treppe hinauf und schläfst neun Stunden. Leben, Mana und Ausdauer sind voll. / You climb the stairs and sleep for nine hours. Life, mana and stamina are full.
- „bis zur nächsten Rast“ (Met, Ausdauertrank, Leuchtfunke) bleibt: **Rast** ist der Oberbegriff für beide, englisch „rest“; „Kurze Erholung“ und „Langes Ausruhen“ nur, wo genau eine gemeint ist.

## Tipp Flucht (`marstips.gd`, neu; Knopf `kampf_ui.gd` 701 hat heute keinen)

`[870.15.tip.flucht]` FLEE: Gelingt nach deiner Gewandtheit; misslingt sie, ist der Zug verloren. Vor Bossen gibt es keine Flucht. / EN: Works by your Agility; if it fails, the turn is lost. There is no fleeing from bosses.

## Gegenstände (`daten/texte.json` „dinge“, mit 870.6)

Texte ohne Würfel (Wirkung und Zahl stehen in den Regelwerten und in der Meldung):

- `potion` (955, Chef 11.11., 13:55; statt „Ein klassischer roter Heiltrank …“): Rot, mit einem Geschmack nach Eisen; schließt kleine Wunden. Wirkt sofort, auch im Kampf. / EN: Red, with a taste of iron; it closes small wounds. Works at once, even in battle.
- `greater_potion`: „Doppelt so stark wie …“ → Stärker als der einfache Heiltrank. Wirkt sofort, auch im Kampf. / EN: Stronger than the plain healing potion. Works at once, even in battle. (Homer 11.11., 955: in den Kampf kommt heute nur `potion`, `aufruf.gd` 246; bis Großer und Kostbarer Heiltrank dort trinkbar sind, ohne „, auch im Kampf“ / „, even in battle“)
- `alchemist_fire`: Wurfmittel. Feuer, setzt den Gegner in Brand. / EN: Thrown. Fire; sets the foe ablaze. („trifft immer“ nur, wenn 870.5 es so baut)
- `holy_water`: Wurfmittel. Licht; wirkt nur gegen Untote, dort aber hart. / EN: Thrown. Light; harms only the undead, but hard.
- `roast_meat`: Stärkt für den nächsten Kampf: du triffst leichter und schlägst härter. / EN: Fortifies you for the next battle: you land blows more easily and hit harder. (wie `[870.14.satt]`)
- `spider_silk` (934): Fein und zäh wie Draht, aus dem Leib einer Riesenspinne. Feuer frisst sie im Nu. Händler zahlen gut dafür. / EN: Fine and tough as wire, from the body of a giant spider. Fire consumes it in an instant. Traders pay well for it. (Feuer verbrennt die Seide, `lohn.gd` 78)
- `spider_gland` (934): „… Morwen kann daraus Alchemistenfeuer mischen.“ → Aus einer Riesenspinne. Morwen mischt daraus Brandflaschen. / EN: From a giant spider. Morwen mixes firebottles from it. (Rezept Morwen: Brandflasche aus 1 Giftdrüse, `Recipes.kt` 17)

`[1318.kurz]` Kurzzeile unter dem Namen in der Ladenliste, Kaufen und Verkaufen (Vorschlag Homer 15.11., 1318 für 785.24 Tom; wie alt `ShopScreen.kt` 244, aber ohne Würfel). Zahl {0} aus den Regelwerten, nie fest im Text: Tränke `werte.json` „welt“ „heilung“, Verband `Menue.verband_heilung` des Helden (mit Heilkunde). Klein, ohne Punkt; „Leben“/„Life“ nach `STORY-REGELN.md` (3), 1320:

| Ding | Deutsch | Englisch |
| --- | --- | --- |
| `potion`, `greater_potion`, `superior_potion` | heilt {0} Leben | heals {0} Life |
| `remedy` | heilt Zustände und {0} Leben | cures conditions, heals {0} Life |
| `bandage` | stillt Blutung, heilt {0} Leben | stops bleeding, heals {0} Life |
| `stamina_potion` | doppelter Atem bis zur Rast | double stamina until the next rest |
| `spark_potion` | leuchtet bis zur Rast | glows until the next rest |
| `alchemist_fire` | Feuer (wie heute `sprache.gd` „kurz“) | Fire |
| `holy_water` | Licht, nur gegen Untote | Light, undead only |

Ohne Kurzzeile: Zutaten und Beute (Kräuter, rohes Fleisch, Fell, Hauer, Drüse, Flügel, Seide). `roast_meat` (Tasche und Verkaufen): heilt {0} Leben / heals {0} Life, {0} mit dem Bonus aus Kochen (`Laden.essen_bonus`). Kräutertrank ohne „alle“: im Kampf bleibt der Rausch (`mars.gd` 1579).

Namen mit SRD-Herkunft (Vorschlag Homer; Text und Wirkung bleiben, nur der Name wechselt):

| heute | neu |
| --- | --- |
| Heiltrank / Potion of Healing | Heiltrank / Healing Potion |
| Großer Heiltrank / Potion of Greater Healing | Großer Heiltrank / Great Healing Potion |
| Überragender Heiltrank / Potion of Superior Healing | Kostbarer Heiltrank / Precious Healing Potion |
| Alchemistenfeuer / Alchemist's Fire | Brandflasche / Firebottle |
| Handschuhe der Ogerkraft / Gauntlets of Ogre Power | Kroggs Pranken / Krogg's Gauntlets |
| Umhang des Schutzes / Cloak of Protection | Wehrmantel / Bulwark Cloak |

Weihwasser, Kräutertrank und die übrigen Namen bleiben. Kosten: nur Text.

## Über das Spiel (`texte.json` ui `aboutText`, Bau 870.20 Tom)

`[870.15.ueber]` (870.19, Homer 15.11.: ersetzt den Text mit SRD, Klassen und Wizards of the Coast; dritter Absatz neu mit dem Namen der Firma) Ein Fantasy-Rollenspiel in Kapiteln. Erkunde das Dorf Bornim und das Land darum, stelle dich Wölfen, Goblins und Schlimmerem im Kampf Zug um Zug, sammle Beute und schreibe mit deinem Helden die Chroniken von Bornim fort.\n\nDie Regeln sind ein eigenes System, das Bornimer Rollenspielsystem: Du wirst, was du tust.\n\nGeschichte, Orte und Figuren sind eigene Erfindungen. Ein Spiel von BornWire TCS.
EN: A fantasy role-playing game told in chapters. Explore the village of Bornim and the land around it, face wolves, goblins and worse in turn-based battle, gather loot and continue the Chronicles of Bornim with your hero.\n\nThe rules are a system of our own, the Bornim Roleplaying System: you become what you do.\n\nThe story, places and characters are original. A game by BornWire TCS.
(Der SRD-Absatz entfällt ganz, ebenso „SRD 5.1 · CC BY 4.0“ unter dem Logo im Hauptmenü und auf der Seite, `hauptmenue.gd` 330 und 545, alles mit 870.20 und erst, wenn kein Wert mehr aus dem SRD rechnet (`brs.gd` 7 nennt noch `tabellen.json` bis 2.3; Inventur Sokrates); der Lizenzschirm für Schrift, Klang und Engine und „Mit Dank an“ `[623.dank.*]` bleiben.)

## Monsternamen

`[870.15.namen.monster]` Bärenschrat = **bearbrute** (im Satz klein wie „wolf“; Krogg bleibt „Krogg der Grobian“ / „Krogg the Brute“); Goblin-Hauptmann = **goblin captain** (Grak bleibt „Hauptmann Grak“ / „Captain Grak“). Riesenegel / Giant Leech und Säureschnecke / Acid Slug gelten statt Blutflügler und Ockerschleim (348.12c, `LISTE-BESTIARIUM.md`); `brs.gd` 14, 17 und `tabellen.json` („Stirge“, „Ockergallerte“) ziehen nach (870.3); in `[870.14.gegen.flueger]` und `[870.14.gegen.schleim]` gelten dieselben Wortlaute für Riesenegel und Säureschnecke. Interne Kennungen („bugbear“, „hobgoblin_captain“, „stirge“) dürfen bleiben, solange kein Spieler sie sieht.

Neuer Wortlaut (Tom, Schritt 8; Texte in `STORY-K1-HANDLUNG.md`, `STORY-K1-WELT.md`, `STORY-CHRONIK-TEXTE-K1.md` nachgezogen):

- `geschichte.gd` 345 Aldric: Doch nun führt sie ein Goblin-Hauptmann namens Grak – grausam und gerissen. / EN: But now they're led by a goblin captain called Grak, cruel and cunning.
- `geschichte.gd` 385 `[504.garrick.krogg]` erste Zeile: Ich habe Goblins belauscht. Ihr Bärenschrat Krogg trägt den Schlüssel zu Graks Halle. / EN: I overheard some goblins. Their bearbrute Krogg carries the key to Grak's hall.
- `geschichte.gd` 392 Morwen: Krogg? Bärenschrate schlagen aus dem Dunkel zu, und der erste Hieb ist der schlimmste. Aber ihre Nasen sind fein. / EN: Krogg? Bearbrutes strike from the dark, and the first blow is the worst. But their noses are keen.
- Chronik 2 „Der Auftrag“: … nun führt sie ein Goblin-Hauptmann namens Grak an. … / EN: … now a goblin captain named Grak leads them. …
- Chronik 6 „Kroggs Schlüssel“: … bewachte der Bärenschrat Krogg … / EN: … the bearbrute Krogg guarded …
- Chronik 8 „Graks Fall“: … {name} besiegte den Goblin-Hauptmann. … / EN: … {name} defeated the goblin captain. …
- Chronik-Auftrag Morwen: … ein Mittel gegen den ersten Hieb eines Bärenschrats. / EN: … a way to blunt a bearbrute's first blow.
