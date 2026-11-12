# Held, Truhe, Wanderer, Schwächen nach dem BRS (870.14)

Homer 10.11.; Texte für Schritt 4 und 5 des Umzugs (`LISTE-UMZUG-BRS.md`; Vorgänge 870.4, 870.5, 839). Begriffe englisch nach `[423.namen]` und `[870.14.namen]` (`STORY-BRS-KAMPF.md`). Grundsätze wie dort: keine Würfel, Zahlen nur als Platzhalter aus den Regelwerten.

## Heldenreiter: Grundwerte (ersetzt `[817.…]` in `STORY-MENUE.md` mit dem Umzug)

**Bauregel (wie 817):** nur Zeilen bauen, deren Wirkung im Code steht; fehlt eine, entfällt ihre Zeile, und Tom schreibt es in den Vorrat Homer. Platzhalter %d aus den Regelwerten (`werte.json`).

`[870.14.wert.kopf]` Wert %d / EN: Value %d (Grundwert 2–9 (933); in Kapitel 1 fest, 870a 4)

`[870.14.wert.kraft]` Kraft / Strength
- Schaden mit Nahkampfwaffen und Fäusten, außer Dolchen. / EN: Damage with melee weapons and fists, except daggers.
- ruht (Bauregel, Tom 11.11.): „Wie viel du tragen kannst.“ / “How much you can carry.”; „Truhen und Türen aufbrechen.“ / “Forcing chests and doors.”; kommen dazu, sobald sie wirken.

`[870.14.wert.gewandtheit]` Gewandtheit / Agility
- Schaden mit Dolchen, Bögen und Wurfwaffen. / EN: Damage with daggers, bows and throwing weapons.
- Wer ausweicht, ist schwerer zu treffen: +%d je Punkt. / EN: When you dodge, you are harder to hit: +%d per point.
- Kritische Treffer (anderthalbfacher Schaden) mit Nahkampfwaffen und Fäusten, außer Dolchen; die Waffenfertigkeit zählt mit. / EN: Critical hits (half again as much damage) with melee weapons and fists, except daggers; weapon skill counts as well. (1008, nach 952 D; ohne Zahl, die Aussicht mit der Hauptwaffe zeigen die Kampfwerte `[870.14.kw.krit]`)
- Wer im Kampf zuerst handelt, und die Aussicht zu fliehen. / EN: Who acts first in combat, and your chance to flee.
- ruht (Bauregel, 1008): „Abwehr gegen Flächenwirkungen wie Feuer.“ / “Resisting area effects such as fire.”; keine Abwehrprobe rechnet mit Gewandtheit (`mars.gd` `_inflict` nur Zähigkeit). Nicht bauen, bis sie wirkt.

`[870.14.wert.zaehigkeit]` Zähigkeit / Toughness
- Leben: +%d je Punkt. / EN: Life: +%d per point.
- Ausdauer, zusammen mit Wille. / EN: Stamina, together with Will.
- Abwehr gegen Gift, Betäubung und Blendung. / EN: Resisting poison, stunning and blinding. (1008: Abwehrproben mit Zähigkeit gegen Gift, Betäubung, Blindheit, `mars.gd` `_inflict`; 963: Krankheit gibt es in Kapitel 1 nicht; „und Krankheit“ / “and disease” kommt dazu, sobald es sie gibt)

`[870.14.wert.verstand]` Verstand / Wits
- Schaden mit Evokation. / EN: Damage with Evocation. (1008, nach 952 D; Illusion und Beschwörung kommen dazu, sobald es Zauber dieser Schulen gibt)
- Wissen: ab Wert %d Schwächen und Stärken der Gegner vorher erkennen. / EN: Lore: from value %d, spotting a foe's weaknesses and strengths beforehand. (1008: 870d, %d = `welt` „wissen_verstand_ab“; erst bauen, wenn `BrsHeld.kennt_schwaechen` im Spiel wirkt, heute ruft es nur der Test)
- ruht (Bauregel, 1008): „Handwerk und Alchemie gelingen besser.“ / “Crafting and alchemy go better.”; Brauen hängt an der Fertigkeit Alchemie, nicht am Verstand. Kommt dazu, sobald der Verstand dort wirkt.

`[870.14.wert.wille]` Wille / Will
- Mana: +%d je Punkt. / EN: Mana: +%d per point.
- Heilung und Schaden mit Heilmagie. / EN: Healing and damage with Healing Magic. (1008, nach 952 D; Schutzmagie und Beistand hängen nicht am Willen)
- Kritische Treffer (anderthalbfacher Schaden) mit Evokation; die Fertigkeit zählt mit. / EN: Critical hits (half again as much damage) with Evocation; the skill counts as well. (1008; Heil- und Schutzmagie treffen nie kritisch; Illusion und Beschwörung wie beim Verstand)
- Ausdauer, zusammen mit Zähigkeit. / EN: Stamina, together with Toughness.
- ruht (Bauregel, 1008): „Abwehr gegen Furcht und Zauber.“ / “Resisting fear and spells.”; keine Probe rechnet mit Wille. Nicht bauen, bis sie wirkt.

`[870.14.wert.wahrnehmung]` Wahrnehmung / Perception
- Treffen im Fernkampf: +%d %% je Punkt. / EN: Ranged accuracy: +%d%% per point.
- Kritische Treffer (anderthalbfacher Schaden) mit Dolchen, Bögen, Armbrüsten und Wurfwaffen; die Waffenfertigkeit zählt mit. / EN: Critical hits (half again as much damage) with daggers, bows, crossbows and throwing weapons; weapon skill counts as well. (1008, nach 952 D)
- Hinterhalte bemerken. / EN: Noticing ambushes.
- Aussicht auf ein Kraut mehr beim Sammeln. / EN: A chance of an extra herb when foraging. (963: nur das wirkt, `laden.gd` `kraut_chance`; „Hilft dem Spähen, Verstecktes und Fallen zu finden.“ / “Helps Scouting find hidden things and traps.” kommt als eigene Zeile davor, sobald Spähen wirkt)

## Heldenreiter: Kampfwerte (`menue.gd` 1319–1331)

Überschrift bleibt „Kampfwerte“. Zeilen in dieser Folge:

- `[870.14.kw.leben]` Leben / Life: %d/%d
- `[870.14.kw.mana]` Mana / Mana: %d/%d (nur, wenn der Held Mana hat)
- `[870.14.kw.ausdauer]` Ausdauer / Stamina: %d
- `[870.14.kw.schutz]` Schutzwert / Protection: %d
- `[870.14.kw.schaden]` Schaden / Damage: %d (Zahl, kein Würfel; die Zeile „Nebenhand“ entfällt, kein Zweiwaffenkampf, 870a 3)
- `[870.14.kw.krit]` Kritisch / Critical: %d %% (EN %d%%)
- „Angriff“, „Kritisch ab“, „Zauberangriff / SG“ entfallen; ebenso Lebensraub, Schadensminderung, Goldfund, EP-Bonus (nicht in der Liste `DESIGN-BRS.md` 11). Magiefund bleibt mit heutigem Namen nur, wenn Sokrates ihn behält (13 offen).

## Gegenstandsfenster und Vergleich (`menue.gd` 721–754, 1250–1290)

- Schaden als Zahl mit Schadensart: `[870.14.ding.schaden]` Schaden %d · %s / EN: Damage %d · %s (Schnitt, Stich, Wucht …, `[870.14.namen]`)
- `[870.14.ding.fertigkeit]` (Waffe, Rüstung, Schild) Fertigkeit: %s / EN: Skill: %s
- „Deine Klasse kann das nicht tragen“ entfällt (jeder darf alles, `DESIGN-BRS.md` 7). Dafür, nur wenn zutreffend:
  - `[870.14.ding.metall]` Metall: Evokation, Illusion und Beschwörung wirken darin nicht. / EN: Metal: Evocation, Illusion and Summoning will not work in it.
  - `[870.14.ding.klirrt]` Schwere Rüstung: darin kannst du nicht schleichen. / EN: Heavy armor: you cannot sneak in it. (963: ruht, bis Schleichen im Spiel wirkt; vorher nicht bauen, ein Verbot ohne das Erlaubte verwirrt)
  - `[870.14.ding.zweihand]` Braucht beide Hände: kein Schild dazu. / EN: Needs both hands: no shield with it.
  - `[870.14.ding.stufe]` Erst ab Heldenstufe %d. / EN: Only from Hero Level %d.
- „Ungeübt: kein Fertigkeitsbonus“ wird: `[870.14.ding.neu]` (Fertigkeit noch 0) Noch nie benutzt: du fängst bei null an. / EN: Never used: you start from nothing.
- `[870.14.ding.guete]` (statt „Angriff +%d“ der alten Verbesserung) Güte: Normal / Gut / Meisterhaft. EN: Quality: Standard / Fine / Masterwork.
- `[870.14.ding.grundwert]` (statt „Finesse: trifft mit GES oder STÄ“, „Fernkampf: trifft mit GES“) Schaden mit %s / EN: Damage with %s (Kraft oder Gewandtheit nach `werte.json`); Armbrust: `[870.14.ding.armbrust]` Schaden ohne Grundwert. / EN: Damage without an attribute.
- Rüstung: nur „Schutzwert %d“ (ohne „+ GES (max 2)“ und ohne „Obergrenze“-Zeilen). „Vielseitig, mit beiden Händen“ samt Würfeltext, „Als %s kannst du das nicht tragen“ (Vergleich), „Zauberkraft +%d“ und „Zauberkraft nützt nur Zauberwirkern“ entfallen (Zauberkraft steht nicht in der Liste 11).
- Zusatzeigenschaften nur nach `DESIGN-BRS.md` 11: „+%d Kraft“ usw., „+%d Schutzwert“, „+%d Leben“, „+%d Mana“, „+%d %% kritisch“, „+%d %% Zauberschaden“, „+%d %% Abwehrprobe“; EN „+%d Strength“, „+%d Protection“, „+%d Life“, „+%d Mana“, „+%d%% critical“, „+%d%% spell damage“, „+%d%% resistance roll“.
- `[925.namen.abwehr]` **Namensteile der Zusatzeigenschaft Abwehrprobe** (Kennung ABWEHR; Muster wie die übrigen, `Gear.kt` `Affix`): Vorsilbe **Wehrhaft** (+ Endung je Geschlecht: Wehrhafter Umhang, Wehrhaftes Amulett), Endung **des Hexenjägers** (Schild des Hexenjägers). EN: Vorsilbe **Defiant** (Defiant Cloak), Endung **of the Witch Hunter** (Shield of the Witch Hunter). Abwehrprobe fällt heute an Schild, Umhang, Amulett (`werte.json`). Wehrhaft = wehrt ab, ohne Gefeitheit zu versprechen; der Hexenjäger trotzt Gift, Furcht und Zauber.

## Die Truhe in der Blutzahnhöhle (cave_3, 632)

Die Truhe gibt die Waffe zur stärksten Waffenfertigkeit des Helden. Ist eine Magieschule höher als jede Waffenfertigkeit: Glutstab (Evokation, Illusion, Beschwörung) oder Morgenröte (Heil-, Schutzmagie). Bei Gleichstand gewinnt die Fertigkeit, die in dieser Folge zuerst kommt: Einhänder, Zweihänder, Stangenwaffen, Stumpfe Waffen, Dolche, Bogen, Armbrust, Wurfwaffen, Evokation, Heilmagie, Schutzmagie, Illusion, Beschwörung (Jägerkind: Bogen; Zauberlehrling: Glutstab). Die vier Stücke bleiben mit Namen und Text (`gegenstaende.json`):

| stärkste Fertigkeit | Stück |
| --- | --- |
| Einhänder | Klinge von Bornim / Blade of Bornim |
| Dolche | Flüsterklinge / Whisperblade (Text passt auch zu einem langen Dolch; Grundform entscheidet Jerry, 870.6) |
| Stumpfe Waffen, Heil- oder Schutzmagie | Morgenröte / Dawnbringer |
| Evokation, Illusion, Beschwörung | Glutstab / Staff of Embers |

Für die übrigen Waffengruppen fünf neue Einzelstücke (Werte, Modell: Jerry, 870.6; ohne sie gibt die Truhe die Waffe der nächststärkeren Fertigkeit mit Stück):

- `[870.14.truhe.zweihand]` Die Namenlose / The Nameless (Zweihänder): Ein Zweihänder mit schartiger Schneide. In die Klinge ist ein Name geritzt, den keiner mehr lesen kann. / EN: A greatsword with a notched edge. Scratched into the blade is a name no one can read anymore.
- `[870.14.truhe.stange]` Wolfsspieß / Wolfspear (Stangenwaffen): Ein Spieß mit eiserner Querstange. Am Schaft Kerben, eine für jeden Wolf. / EN: A spear with an iron crossbar. Notches on the shaft, one for every wolf.
- `[870.14.truhe.bogen]` Schwarzeibe / Blackyew (Bogen): Ein Langbogen aus dunkler Eibe, die Griffwicklung von vielen Händen glatt. / EN: A longbow of dark yew, its grip worn smooth by many hands.
- `[870.14.truhe.armbrust]` Nachtwache / Nightwatch (Armbrust): Eine Armbrust mit dem verblassten Zeichen der Dorfwache. Der Spannhebel quietscht. / EN: A crossbow with the faded mark of the village watch. The lever squeaks. (934: nur die Grundform Armbrust)
- `[870.14.truhe.wurf]` Elstern / Magpies (Wurfwaffen): Drei Wurfmesser in einem Lederband, so blank, dass sie das Licht stehlen. / EN: Three throwing knives in a leather band, so bright they steal the light.
- Faustkampf und Schild haben kein Stück: die Truhe nimmt die nächststärkere Waffenfertigkeit.

## Wanderer (Herkunftstabelle, Plan Abschnitt 3)

- Name, Satz der Erschaffung: bleiben (`erschaffung_brs.gd` 54, `[423.herkunft]`).
- `[870.14.wanderer.kapitel]` Kapitelschirm und Spielstände: „Name · Volk · Herkunft · Heldenstufe n“; beim Wanderer steht „Wanderer“. EN: “Name · People · Origin · Hero Level n” (eingesetzt werden die Namen, etwa “Ada · Human · Wanderer · Hero Level 2”). Gilt für alle Herkünfte statt der Klasse; hat der Held einen Pfad, steht der Pfad statt der Herkunft.
- `[870.14.wanderer.tracht]` Tracht (Vorschlag zum Aussehen, Bild an den Chef vor B1): abgetragener Reisemantel mit Kapuze, Gürteltasche, keine Abzeichen; wer nichts mitbringt, sieht nach Weg aus. Kosten: eine Tracht aus vorhandenen Teilen (Umhang, Gürtel), keine neue Zeichnung.
- Startvorrat: kein Text; Inhalt legt Tom fest.

## Schwächen und Stärken (870a 8 A; `LISTE-BESTIARIUM.md`)

**Rückfrage 870.14 a (an Sokrates, Besitzer `DESIGN-BRS.md`):** `DESIGN-BRS.md` 7 sagt „mit der Fertigkeit Wissen sieht man sie vorher“; eine Fertigkeit Wissen gibt es unter den 37 nicht (Abschnitt 3), „Wissen“ steht beim Grundwert Verstand (2). Vorschlag Homer: Verstand ab einem Wert aus 444 zeigt Schwäche und Stärke vorher (wie heute `talente.gd` „ab INT 12“); die Texte unten passen zu beiden Wegen.

Meldungen im Kampf (einmal je Art, beim ersten Treffer mit der Schadensart):
- `[870.14.schwach]` {0} ist verwundbar gegen {1}! / EN: {0} is vulnerable to {1}!
- `[870.14.stark]` {1} richtet bei {0} wenig aus. / EN: {1} does little against {0}.
- `[870.14.immun]` {1} prallt an {0} ab. / EN: {1} has no effect on {0}.
- Kasten am Schaden (wie „kritisch“): `[870.14.kasten.schwach]` verwundbar / EN: vulnerable · `[870.14.kasten.stark]` widersteht / EN: resists

Gegenwirkung (beim ersten Mal, sichtbar):
- `[870.14.gegen.wolf]` Wolf, Feuer: ersetzt durch `[915.wolf.flucht]`, `[915.wolf.erstmals]`, `[915.lohn.vertrieben]` in `STORY-BRS-KAMPF.md` (915).
- `[870.14.gegen.schwein]` Wildschwein, Feuer: Das Feuer macht {0} rasend. / EN: The fire drives {0} into a frenzy.
- `[870.14.gegen.spinne]` Riesenspinne, Feuer: Die Seide der Spinne verbrennt zu Asche. / EN: The spider's silk burns to ash.
- `[870.14.gegen.flueger]` Blutflügler, Held blutet: {0} wittert dein Blut und saugt gieriger. / EN: {0} smells your blood and feeds more greedily.
- `[870.14.gegen.zombie]` Zombie, Feuer oder Licht: {0} zerfällt. Diesmal steht er nicht wieder auf. / EN: {0} crumbles. This time it does not rise again.
- `[870.14.gegen.schleim]` Ockerschleim, Schnitt oder Wucht: Der Schleim teilt sich. / EN: The slime splits in two.

Vorher erkannt (Wissen) im Ziel-Tipp und im Bestiarium:
- `[870.14.wissen]` Verwundbar: %s. Widersteht: %s. / EN: Vulnerable: %s. Resists: %s. (fehlt eins: „–“)
- `[870.14.wissen.gegen]` (Art mit Gegenwirkung) Vorsicht: %s. / EN: Beware: %s. Kurztexte: Wolf „Feuer vertreibt das Rudel samt Beute und Erfahrung, sobald sein Leitwolf halb tot ist“ / “fire drives off the pack, loot, experience and all, once its leader is half dead” (899, 870c 3 A; 915); Wildschwein „Feuer macht es rasend“ / “fire sends it into a frenzy”; Spinne „Feuer verbrennt die Seide“ / “fire burns the silk”; Blutflügler „Blut lockt ihn“ / “blood draws it”; Zombie „Feuer und Licht halten ihn liegen“ / “fire and light keep it down”; Ockerschleim „Schnitt und Wucht teilen ihn“ / “slash and crush split it”.
- `[870.14.wissen.unbekannt]` (nicht erkannt, noch nie bekämpft) Schwächen: unbekannt. / EN: Weaknesses: unknown.
