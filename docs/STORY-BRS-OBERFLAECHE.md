# Oberfläche, Absichten, Namen nach dem BRS (870.15)

Homer 10.11.; Teil von `STORY-BRS-ANLEITUNG.md` (Grundsätze dort). Für Schritt 4 (Tom, 870.4), 5 (Jerry, 870.5), 8 (Tom, 870.9) und 9 (870.13).

## Oberfläche „ui“ und „rast“ (`daten/texte.json`)

Entfallen mit `erschaffung.gd` und `heldwerte.gd` (Schritt 4), ohne Ersatz: `chooseClass`, `proficiency`, `hitDie`, `primary`, `armorProf`, `points`, `fromLevel`, `cannotEquipArmor`, `ac` (Schutzwert heißt `[870.14.kw.schutz]`). Geändert:

- `sp`: Mana / Mana (Leiste, Kampfkopf)
- `hp`: TP / HP bleibt (nur an Zahlen)
- `skills`: Können / Abilities (wie `[870.14.knopf.koennen]`)
- `chooseRace`: Wähle dein Volk / Choose your people
- `alreadyFull`: Dein Leben ist schon voll. / Your life is already full.
- `rast.short`: Kurze Erholung · 2 Stunden / Short Respite · 2 hours
- `rast.long`: Langes Ausruhen · 9 Stunden / Long Rest · 9 hours
- `rast.shortDoes`: Ausdauer voll, ein Teil des Lebens zurück / Full stamina, some of your life back
- `rast.longDoes`: Leben, Mana und Ausdauer voll, Zustände geheilt / Life, mana and stamina full, conditions cured
- `rast.longDone`: Heute hast du dich schon lange ausgeruht. / You have already had a Long Rest today.
- `rast.roomDoes`: Ein Bett oben unter dem Dach: Langes Ausruhen / A bed upstairs under the roof: Long Rest
- `rast.hourGone`: Zwei Stunden vergehen. / Two hours pass. · `rast.hoursGone`: Neun Stunden vergehen. / Nine hours pass.
- `rast.shortRested`: Zwei Stunden Ruhe. Die Ausdauer ist voll, +{0} TP. / Two hours of rest. Your stamina is full, +{0} HP.
- `rast.longRested`: Neun Stunden Schlaf. Leben, Mana und Ausdauer sind voll. / Nine hours of sleep. Life, mana and stamina are full.
- `rast.roomRested`: Du steigst die Treppe hinauf und schläfst neun Stunden. Leben, Mana und Ausdauer sind voll. / You climb the stairs and sleep for nine hours. Life, mana and stamina are full.
- „bis zur nächsten Rast“ (Met, Ausdauertrank, Leuchtfunke) bleibt: **Rast** ist der Oberbegriff für beide, englisch „rest“; „Kurze Erholung“ und „Langes Ausruhen“ nur, wo genau eine gemeint ist.

## Über das Spiel (`aboutText`, erst mit 870.13)

`[870.15.ueber]` Ein Fantasy-Rollenspiel in Kapiteln. Erkunde das Dorf Bornim und das Land darum, stelle dich Wölfen, Goblins und Schlimmerem im Kampf Zug um Zug, sammle Beute und schreibe mit deinem Helden die Chroniken von Bornim fort.\n\nDie Regeln sind ein eigenes System, das Bornimer Rollenspielsystem: Du wirst, was du tust.\n\nGeschichte, Orte, Figuren und Regeln sind eigene Erfindungen.
EN: A fantasy role-playing game told in chapters. Explore the village of Bornim and the land around it, face wolves, goblins and worse in turn-based battle, gather loot and continue the Chronicles of Bornim with your hero.\n\nThe rules are a system of our own, the Bornim Roleplaying System: you become what you do.\n\nThe story, places, characters and rules are original.
(Bis 870.13 bleibt der heutige Text mit SRD-Hinweis; der Lizenzschirm für Schrift und Klang bleibt.)

## Absichten der Gegner (`kampf/marstips.gd`, Ergänzung zu 870.14)

Ohne Würfel und ohne Nachteil; was hier nicht steht, bleibt wortgleich (`call`, `flank`, `pounce`, `circle`, `BAG`, `PLACE`, `MERC`). „Ein Fünftel“ ist die Regel des Umreißens (MARS), keine Zahl aus 444.

- `heavy`: Schwerer Hieb: die Axt mit voller Wucht, viel mehr Schaden, gegen eine Figur. Hilft: vorher ein Fünftel seines Lebens abnehmen, dann taumelt er und der Zug ist verloren; sonst Abwehr, Decken oder den Ring treffen. / EN: Heavy blow: the axe at full force, much more damage, against one figure. Counter: take a fifth of his life first and he staggers, his turn lost; otherwise Defend, Cover or meet the ring.
- `gather`: Kraft sammeln: er heilt sich um ein gutes Stück. Hilft: ein Fünftel seines Lebens vorher abnehmen, dann bleibt die Heilung aus. / EN: Gather strength: he heals a good deal. Counter: take a fifth of his life first and the healing fails.
- `breakthrough`: Durchbrechen: er stößt die Figur vorn nach hinten und schlägt die dahinter, die nun vorn steht, mit mehr Schaden. Hilft: der Bedrohte tritt selbst nach vorn, dann bleibt ein einfacher Schlag; oder ein Fünftel seines Lebens vorher. / EN: Break through: he shoves the front figure back and strikes the one behind, now in front, with extra damage. Counter: the threatened one steps forward, leaving a plain blow; or a fifth of his life first.
- `stab`: Stich: ein einfacher Schlag, ohne Ring. Hilft: Abwehr gibt ihm Ungunst; meist lohnt der eigene Angriff mehr. / EN: Stab: a plain blow, without a ring. Counter: Defend puts it at disfavor; usually your own attack is worth more.
- `venom`: Gift sammeln: der nächste Biss macht viel mehr Schaden, ohne Ring. Hilft: ein Fünftel ihres Lebens vorher, dann versiegt das Gift; sonst Abwehr. / EN: Gather venom: the next bite deals much more damage, without a ring. Counter: a fifth of her life first and the venom dries up; otherwise Defend.
- `web`: Netz werfen: trifft es, verliert die Figur ihren nächsten Zug. Hilft: den Ring perfekt treffen; Abwehr gibt ihr Ungunst. / EN: Throw web: if it hits, the figure loses its next turn. Counter: meet the ring perfectly; Defend puts her at disfavor.
- `aim`: Anlegen: ein Schuss mit mehr Schaden, ohne Ring. Hilft: die Figur geht in Abwehr, dann duckt sie sich und der Pfeil geht vorbei. / EN: Take aim: a shot with extra damage, without a ring. Counter: that figure Defends, ducks, and the arrow misses.
- `shadow`: In den Schatten: er verschwindet, bis zu seinem nächsten Zug haben Angriffe auf ihn Ungunst. Hilft: jeder Treffer vorher, auch ein leichter, hält ihn im Licht. / EN: Into the shadows: he vanishes; until his next turn, attacks on him are at disfavor. Counter: any hit beforehand, however light, keeps him in the light.

## Bärenschrat und Goblin-Hauptmann (`DESIGN-BRS.md` 12)

`[870.15.namen.monster]` Bärenschrat = **bearbrute** (im Satz klein wie „wolf“; Krogg bleibt „Krogg der Grobian“ / „Krogg the Brute“); Goblin-Hauptmann = **goblin captain** (Grak bleibt „Hauptmann Grak“ / „Captain Grak“). Ersetzt in `STORY-REGELN.md` (feste Namen) „Bugbear = Grottenschrat“.

Neuer Wortlaut (Tom, Schritt 8; Texte in `STORY-K1-HANDLUNG.md`, `STORY-K1-WELT.md`, `STORY-CHRONIK-TEXTE-K1.md` nachgezogen):

- `geschichte.gd` 345 `[41.aldric.grak]`: Doch nun führt sie ein Goblin-Hauptmann namens Grak – grausam und gerissen. / EN: But now they're led by a goblin captain called Grak, cruel and cunning.
- `geschichte.gd` 385 `[504.garrick.krogg]` erste Zeile: Ich habe Goblins belauscht. Ihr Bärenschrat Krogg trägt den Schlüssel zu Graks Halle. / EN: I overheard some goblins. Their bearbrute Krogg carries the key to Grak's hall.
- `geschichte.gd` 392 Morwen: Krogg? Bärenschrate schlagen aus dem Dunkel zu, und der erste Hieb ist der schlimmste. Aber ihre Nasen sind fein. / EN: Krogg? Bearbrutes strike from the dark, and the first blow is the worst. But their noses are keen.
- Chronik 2 „Der Auftrag“: … nun führt sie ein Goblin-Hauptmann namens Grak an. … / EN: … now a goblin captain named Grak leads them. …
- Chronik 6 „Kroggs Schlüssel“: … bewachte der Bärenschrat Krogg … / EN: … the bearbrute Krogg guarded …
- Chronik 8 „Graks Fall“: … {name} besiegte den Goblin-Hauptmann. … / EN: … {name} defeated the goblin captain. …
- Chronik-Quest Morwen: … ein Mittel gegen den ersten Hieb eines Bärenschrats. / EN: … a way to blunt a bearbrute's first blow.

## Gegenstände mit SRD-Namen (Vorschlag Homer; mit 870.6, Jerry)

Bei SRD-Namen ersetzen (Zu 458.4); Text und Wirkung bleiben, nur der Name wechselt:

| heute | neu |
| --- | --- |
| Heiltrank / Potion of Healing | Heiltrank / Healing Draught |
| Großer Heiltrank / Potion of Greater Healing | Großer Heiltrank / Great Healing Draught |
| Überragender Heiltrank / Potion of Superior Healing | Kostbarer Heiltrank / Precious Healing Draught |
| Alchemistenfeuer / Alchemist's Fire | Brandflasche / Firebottle |
| Handschuhe der Ogerkraft / Gauntlets of Ogre Power | Kroggs Pranken / Krogg's Gauntlets |
| Umhang des Schutzes / Cloak of Protection | Wehrmantel / Bulwark Cloak |

Weihwasser, Kräutertrank und die übrigen Namen bleiben. Kosten: nur Text.
