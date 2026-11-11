# Erschaffung: Erklärung bei langem Druck (954)

Homer 11.11.; Vorgang 954.1 für den Bau 954 (Tom): Gedrückthalten auf Grundwert, Volk, Herkunft oder Fertigkeit zeigt Name und einen Satz, wie im Systemmenü (`menue.gd` `erklaere_zeichen`). Begriffe englisch nach `[423.namen]`, `[870.14.namen]`; US-Schreibung (`STORY-REGELN.md`). Keine Zahlen: was die Punkte genau bringen, zeigt der Heldenreiter (`[870.14.wert.…]`). Fremd geprüft 11.11., 14:15, gegen den Code.

**Bauregel (wie 817, 870.14):** jeder Satz sagt, wozu etwas da ist. Steht seine Wirkung beim Bau nicht im Code, folgt dem Satz `[954.1.spaeter]`; ein Satzteil ohne Wirkung entfällt, und Tom schreibt es in den Vorrat Homer. Stand der Prüfung: `claude/tom-870-4-held` (`9a34fec2a`), 11.11.

`[954.1.spaeter]` In diesem Kapitel wirkt das noch nicht. / EN: This has no effect yet in this chapter.

## Grundwerte `[954.1.wert.…]`

- `[954.1.wert.kraft]` Mehr Schaden mit Nahkampfwaffen und Fäusten, außer mit Dolchen. / EN: More damage with melee weapons and fists, except daggers.
- `[954.1.wert.gewandtheit]` Mehr Schaden mit Dolchen, Bögen und Wurfwaffen; dazu Ausweichen, kritische Treffer, wer zuerst handelt und ob du entkommst. / EN: More damage with daggers, bows and throwing weapons; also dodging, critical hits, who acts first and whether you get away.
- `[954.1.wert.zaehigkeit]` Mehr Leben und Ausdauer; Gift, Betäubung und Blendung wehrst du leichter ab. / EN: More life and stamina; you resist poison, stunning and blinding more easily.
- `[954.1.wert.verstand]` Wissen: mit hohem Verstand erkennst du Schwächen und Stärken der Gegner, bevor du kämpfst. / EN: Lore: with high Wits you spot a foe's weaknesses and strengths before you fight. (870d; `kennt_schwaechen` liest heute keiner, Vorgang 960: bis dahin mit `[954.1.spaeter]`)
- `[954.1.wert.wille]` Mehr Mana und Ausdauer und stärkere Zauber, auch beim Heilen. / EN: More mana and stamina, and stronger spells, healing included.
- `[954.1.wert.wahrnehmung]` Du triffst besser mit Fernwaffen, gerätst seltener in einen Hinterhalt und findest mehr Kräuter. / EN: You hit better at range, fall into ambushes less often and find more herbs.

## Völker `[954.1.volk.…]` (das Merkmal; Vorteil und Nachteil zeigt die Zeile darunter)

- `[954.1.volk.mensch]` Wandelbar: ein freier Punkt, wohin du willst, und eine Fertigkeit mehr zum Start. / EN: Adaptable: one free point wherever you like, and one extra skill at the start.
- `[954.1.volk.elf]` Wachsame Sinne: dich lähmt nichts. / EN: Watchful Senses: nothing can paralyze you.
- `[954.1.volk.zwerg]` Steinblut: Gift wehrst du oft ganz ab, und was durchkommt, schadet dir nur halb. / EN: Stoneblood: you often shrug off poison entirely, and what gets through hurts you only half as much.
- `[954.1.volk.huegelvolk]` Glückskind: das Glück steht dir bei, wenn es darauf ankommt. / EN: Child of Fortune: luck is on your side when it matters. (im MARS ohne Wirkung, nur im alten `klassisch.gd`: heute mit `[954.1.spaeter]`; Chefsache 954a)
- `[954.1.volk.orkbluetiger]` Letzter Atemzug: einmal je Kampf lässt dich ein tödlicher Treffer mit dem letzten Rest Leben stehen. / EN: Last Breath: once per battle, a killing blow leaves you standing with your last scrap of life.

## Herkünfte `[954.1.herkunft.…]` (Fertigkeiten und „führt zu“ stehen schon auf dem Schirm)

- `[954.1.herkunft.wachsoldat]` Du hast Wache gestanden: mit Schild, Einhandwaffe und Rüstung stehst du vorn und hältst viel aus. / EN: You stood watch: with shield, weapon and armor you hold the front and take a beating.
- `[954.1.herkunft.jaegerkind]` Du bist im Wald groß geworden: du triffst aus der Ferne und gerätst selten in einen Hinterhalt. / EN: You grew up in the woods: you strike from afar and rarely walk into an ambush.
- `[954.1.herkunft.zauberlehrling]` Du hast bei einem Magier gelernt: deine ersten Zauber kannst du schon, doch ohne Rüstung trifft dich jeder Schlag hart. / EN: You learned under a mage: you already know your first spells, but without armor every blow hits you hard.
- `[954.1.herkunft.klosterschueler]` Im Kloster hast du heilen gelernt: mit Wundsegen schließt du Wunden, deine und die deiner Gefährten. / EN: You learned to heal in the cloister: with Woundmend you close wounds, your own and your companions'.
- `[954.1.herkunft.kraeutersammler]` Du kennst die Kräuter am Wegrand: du findest mehr davon und holst beim Brauen mehr heraus. / EN: You know the herbs by the wayside: you find more of them and get more out of every brew.
- `[954.1.herkunft.schmiedelehrling]` Am Amboss bist du stark geworden: Hammer und Hitze haben dich gehärtet, du schlägst kräftig zu. / EN: You grew strong at the anvil: hammer and heat have hardened you, and you hit hard.
- `[954.1.herkunft.herumtreiber]` Du hast dich auf der Straße durchgeschlagen: flink, rasch mit dem Dolch und schwer zu fassen. / EN: You scraped by on the streets: nimble, quick with a dagger and hard to pin down.
- `[954.1.herkunft.wanderer]` Ohne Herkunft: du verteilst die Punkte selbst und wählst deine Fertigkeiten. / EN: No origin: you spend the points yourself and pick your own skills.

## Fertigkeiten `[954.1.fert.…]` (Schlüssel = Name im Code; Bergbau nicht wählbar)

Vor dem Doppelpunkt steht der Name: er ist der Kopf der Blase, nicht Teil des Satzes; der Satz beginnt im Bau groß („Große Schwerter, Äxte …“). Bei den Völkern dagegen gehört das Merkmal zum Satz (Kopf ist das Volk).

Mit Wirkung im Umzugszweig: Waffen außer Wurfwaffen, alle Rüstungen, Ausweichen, Evokation, Schutzmagie, Heilmagie, Handeln, Kräuterkunde, Alchemie, Kochen. Ohne (heute mit `[954.1.spaeter]`): Wurfwaffen (keine Waffe gehört dazu), Schleichen, Spähen, Schlösser knacken, Fallen entschärfen, Illusion, Beschwörung, Tiere beruhigen, Überreden, Einschüchtern, Angeln, Jagd, Schmieden, Lederarbeit, Runenkunde, Heilkunde (Überreden, Heilkunde mit 842, Einschüchtern mit 841).

**Waffen**
- `[954.1.fert.einhaender]` Einhänder: Schwerter, Äxte und andere Waffen für eine Hand; die zweite bleibt frei für einen Schild. / EN: Swords, axes and other one-handed weapons; your other hand stays free for a shield.
- `[954.1.fert.zweihaender]` Zweihänder: große Schwerter, Äxte und Hämmer für beide Hände, kein Schild dazu; keine Nahkampfwaffe trifft schwerer. / EN: Great swords, axes and hammers for both hands, no shield with them; no melee weapon hits harder.
- `[954.1.fert.stange]` Stangenwaffen: Speere und andere lange Waffen; mit der Spitze hältst du den Gegner auf Abstand. / EN: Spears and other long weapons; with the point you keep the foe at bay.
- `[954.1.fert.stumpf]` Stumpfe Waffen: Streitkolben, Hammer und Stab schlagen mit Wucht statt mit der Schneide. / EN: Maces, hammers and staves strike with weight, not with an edge.
- `[954.1.fert.dolche]` Dolche: kurze Klingen, geführt mit Gewandtheit statt Kraft; am schlimmsten für den, der dich nicht kommen sieht. / EN: Short blades, wielded with Agility rather than Strength; worst for a foe who never saw you coming.
- `[954.1.fert.faust]` Faustkampf: mit bloßen Fäusten, wenn nichts anderes zur Hand ist; ein harter Griff hält den Gegner am Platz. / EN: Bare fists when nothing else is at hand; a hard grip holds the foe in place.
- `[954.1.fert.schild]` Schild: fängt Schläge ab und deckt später auch, wer neben dir steht. / EN: Catches blows, and later covers whoever stands beside you too.
- `[954.1.fert.bogen]` Bogen: Pfeile aus der Ferne; Gewandtheit gibt ihnen Wucht, Wahrnehmung lenkt sie ins Ziel. / EN: Arrows from afar; Agility drives them, Perception guides them home.
- `[954.1.fert.armbrust]` Armbrust: Bolzen schlagen hart ein, ganz gleich, wie stark oder gewandt du bist. / EN: Bolts hit hard, however strong or agile you are.
- `[954.1.fert.wurf]` Wurfwaffen: Wurfmesser und Ähnliches, mit Gewandtheit geschleudert. / EN: Throwing knives and the like, hurled with Agility.

**Rüstung**
- `[954.1.fert.leicht]` Leichte Rüstung: Leder; schützt wenig und hindert kaum. / EN: Leather; little protection, hardly in your way.
- `[954.1.fert.mittel]` Mittlere Rüstung: mehr Schutz als Leder, weniger als schwere Rüstung. / EN: More protection than leather, less than heavy armor.
- `[954.1.fert.schwer]` Schwere Rüstung: der beste Schutz, doch ohne genug Kraft geht dir darin bald der Atem aus. / EN: The best protection, but without enough Strength you soon run out of breath in it.
- `[954.1.fert.ausweichen]` Ausweichen: du entgehst Hieben, statt sie abzufangen; Gewandtheit hilft dabei. / EN: You slip blows instead of catching them; Agility helps.

**Schatten**
- `[954.1.fert.schleichen]` Schleichen: ungesehen an Gegner herankommen und zuerst zuschlagen. / EN: Get close to foes unseen and strike first.
- `[954.1.fert.spaehen]` Spähen: stehen bleiben und umsehen, um Verstecktes und Fallen zu finden. / EN: Stop and look around to find hidden things and traps.
- `[954.1.fert.schloesser]` Schlösser knacken: verschlossene Truhen und Türen ohne Schlüssel öffnen. / EN: Open locked chests and doors without a key.
- `[954.1.fert.fallen]` Fallen entschärfen: Fallen unschädlich machen, bevor sie zuschnappen. / EN: Render traps harmless before they spring.

**Magie** (die Sperre in Metall, `[870.14.ding.metall]`, prüft der Kampf heute nicht; erst wenn sie gebaut ist, hängt Tom „; in Metall wirkt sie nicht“ / „; it will not work in metal“ an Evokation, Illusion, Beschwörung)
- `[954.1.fert.evokation]` Evokation: Feuer und reine Kraft gegen deine Gegner. / EN: Fire and pure force against your foes.
- `[954.1.fert.schutz]` Schutzmagie: Schilde und Häute aus Kraft, die Schläge dämpfen. / EN: Shields and skins of force that dull blows.
- `[954.1.fert.heil]` Heilmagie: Wunden schließen und grelles Licht gegen deine Gegner rufen. / EN: Close wounds and call harsh light down on your foes.
- `[954.1.fert.illusion]` Illusion: Trugbilder, die Gegner täuschen und verwirren. / EN: Phantoms that deceive and confuse your foes.
- `[954.1.fert.beschwoerung]` Beschwörung: Wesen rufen, die für dich kämpfen, bis hin zur Macht über die Toten. / EN: Call up beings that fight for you, even command over the dead.

**Wildnis, Gesellschaft**
- `[954.1.fert.tiere]` Tiere beruhigen: ein feindliches Tier vor dem Kampf besänftigen, damit es abzieht. / EN: Soothe a hostile beast before battle so it moves off.
- `[954.1.fert.ueberreden]` Überreden: andere mit Worten umstimmen, notfalls mit einer Lüge. / EN: Win others over with words, with a lie if need be.
- `[954.1.fert.einschuechtern]` Einschüchtern: mit Blick und Drohung Gegner vertreiben, bevor es zum Kampf kommt. / EN: Drive foes off with a look and a threat before it comes to blows.
- `[954.1.fert.handeln]` Handeln: im Laden günstiger kaufen und teurer verkaufen. / EN: Buy for less and sell for more in shops.

**Sammeln**
- `[954.1.fert.kraeuter]` Kräuterkunde (857a: „Kräutersammeln“, EN Foraging, sobald der Code umbenennt, 875): Kräuter am Wegrand finden und pflücken; je besser du bist, desto mehr. / EN: Find and pick herbs by the wayside; the better you are, the more you get.
- `[954.1.fert.angeln]` Angeln: Fische fangen, an Bach und See. / EN: Catch fish in streams and lakes.
- `[954.1.fert.jagd]` Jagd: erlegte Tiere zerlegen und Fährten lesen. / EN: Dress slain beasts and read tracks.

**Handwerk**
- `[954.1.fert.schmieden]` Schmieden: Waffen und Rüstung aus Metall fertigen und flicken, auch Dietriche. / EN: Make and mend metal weapons and armor, lockpicks too.
- `[954.1.fert.leder]` Lederarbeit: gerben, schneidern, Leder und Stoff flicken, für leichte Rüstung, Taschen und Köcher. / EN: Tan, tailor and mend leather and cloth, for light armor, bags and quivers.
- `[954.1.fert.alchemie]` Alchemie: wer sich auf Tränke versteht, bekommt beim Brauen öfter einen zweiten dazu. / EN: If you know your potions, a brew more often yields a second one.
- `[954.1.fert.kochen]` Kochen: was du isst, stärkt dich mehr. / EN: What you eat does you more good.
- `[954.1.fert.runen]` Runenkunde: Runen und Verzauberungen auf deine Ausrüstung legen. / EN: Lay runes and enchantments on your gear.
- `[954.1.fert.heilkunde]` Heilkunde: Wunden verbinden; wer sich darauf versteht, holt aus einem Verband mehr heraus. / EN: Bind wounds; the more you know of it, the more a bandage mends.
