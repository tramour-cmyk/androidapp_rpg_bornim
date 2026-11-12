# Kampftexte nach dem BRS (870.14)

Homer 10.11.; Texte für Schritt 5 des Umzugs (`LISTE-UMZUG-BRS.md`, Vorgänge 870.5, 868). Ersetzt die SRD-Stellen in `regeln/mars_texte.gd`, `regeln/mars.gd` (Zustände, 534, 296), `regeln/lohn.gd`, `kampf/marstips.gd`, `kampf/kampf_ui.gd` (Würfelkasten, Kopf). Was hier nicht steht, bleibt wortgleich (die übrigen Zeilen von `mars_texte.gd` nennen keine SRD-Begriffe). Englisch nach `STORY-REGELN.md` Regeln (1)–(7).

**Grundsätze für den Bau:** (1) **Keine Zahlen in Erklärtexten** (Zustände, Ansagen, Tipps): sie überleben jede Messung 444; Zahlen nur in Meldungen mit Platzhalter. (2) **Kein Würfel im Bild:** kein W20, keine „2W6“, kein Wurf neben der Trefferchance. (3) „TP“ bleibt in Meldungen (`STORY-REGELN.md` (3); `DESIGN-BRS.md` 12: Trefferpunkte bleiben). (4) Wirkt eine Handlung im Bau anders als hier beschrieben: Vorgang an Homer, nicht selbst umschreiben.

## Begriffe `[870.14.namen]`

Ergänzt `[423.namen]` (`STORY-HANDBUCH-3.md`); deutsch nach `DESIGN-BRS.md` 12, englisch hier festgelegt, überall gleich.

Schutzwert = Protection (683) · Güte = Quality (Schlecht, Normal, Gut, Meisterhaft = Poor, Common, Fine, Masterwork; 976a A) · Volk = People · Knopf „Können“ = Abilities (nicht „Skills“, das ist die Fertigkeit) · Fertigkeitsbonus = Skill bonus · Abwehrprobe = Resistance roll · Gunst = Favor · Ungunst = Disfavor („mit Gunst“ = with favor, „mit Ungunst“ = at disfavor) · Mana = Mana · Trefferchance = Hit chance · Kurze Erholung = Short Respite (kurz „respite“) · Langes Ausruhen = Long Rest (nie bloß „rest“ für die Erholung) · Kraft schöpfen = Draw Strength · Wehrhaltung = Guarded Stance · Kampfhandlung = Combat move. Zauber: Kleinzauber = Minor Spell, Funkenpfeil = Spark Bolt, Arkanpfeil = Arcane Dart, Glutstrahlen = Ember Rays, Glutkugel = Ember Orb, Flammenfächer = Flame Fan, Arkanhaut = Arcane Skin, Bannschild = Ward, Wundsegen = Woundmend, Gleißstrahl = Glare Ray, Beistand = Succor. Schadensarten (870a 8): Schnitt = Slash, Stich = Pierce, Wucht = Crush, Feuer = Fire, Gift = Poison, Säure = Acid, Licht = Light; im englischen Satz klein (“vulnerable to fire”), in Listen groß.

## Würfelkasten über dem Getroffenen (`kampf_ui.gd` `_roll_tag`)

Nur Ergebnis und Trefferchance; der Wurf von 1 bis 100 erscheint nicht (868: „keine Würfelwerte“). Gold, wenn es der Gruppe hilft, wie heute.

- `[870.14.kasten.treffer]` Treffer · %d %% / EN: Hit · %d%%
- `[870.14.kasten.daneben]` daneben · %d %% / EN: Miss · %d%%
- `[870.14.kasten.kritisch]` kritisch · %d %% / EN: Critical · %d%%
- `[870.14.kasten.gunst]` (Gunst bzw. Ungunst lag an) hinter der Zahl: „ mit Gunst“, „ mit Ungunst“ / EN: “ with favor”, “ at disfavor”
- `[870.14.kasten.abwehr]` (Abwehrprobe; %s nach `[870.14.abwehr.art]`) Abwehr gegen %s · %d %% · gehalten / misslungen. EN: Resist %s · %d%% · held / failed
- `[870.14.abwehr.art]` Gift, Krankheit, Furcht, Zauber, Flächenwirkung / EN: poison, disease, fear, spell, area effect

## Kopf der Figur (`kampf_ui.gd` 526)

`[870.14.kopf.mana]` hinter dem Leben: „  Mana %d/%d“ / EN: “  Mana %d/%d” (statt „ZP“/„SP“).

## Meldungen (ersetzen gleichnamige Konstanten)

- `[870.14.nosp]` MSG72_NOSP: Nicht genug Mana. / EN: Not enough mana.
- `[870.14.norest]` MSG72_NOREST (Handlung kommt erst nach dem Langen Ausruhen zurück): Erst nach dem Langen Ausruhen wieder. / EN: Not again until a Long Rest.
- `[870.14.norest.kurz]` (kommt schon nach der Kurzen Erholung zurück): Erst nach einer Erholung wieder. / EN: Not again until a respite.
- `[870.14.flamesback]` MSG72_FLAMESBACK: {0} weicht aus und schleudert {1} einen Funkenpfeil entgegen. / EN: {0} dodges and hurls a spark bolt back at {1}.
- `[870.14.blessed]` MSG72_BLESSED (Beistand wirkt): {0} spürt Beistand. / EN: {0} feels a steadying hand.
- `[870.14.dodges]` MSG72_DODGES unverändert (Abwehrprobe gegen Zauber gehalten): {0} entgeht dem Zauber. / EN: {0} escapes the spell.
- `[870.14.lebensraub]` MSG534_LIFESTEAL unverändert in Worten, Englisch Präsens: {0} saugt {1} TP ab. / EN: {0} drains {1} HP.
- `[870.14.letzter.atemzug]` MSG534_RELENTLESS (Merkmal Letzter Atemzug der Orkblütigen): Letzter Atemzug: {0} bleibt stehen! / EN: Last Breath: {0} stays standing!
- `[870.14.steinblut]` ST_DWARF (Merkmal Steinblut der Zwerge, nur wenn es Gift abwehrt): Steinblut: {0} widersteht dem Gift! / EN: Stoneblood: {0} resists the poison!
- `[870.14.kraft.schoepfen]` neue Konstante für den Helden (Kraft schöpfen; heute MSG72_USES und HEALSSELF): {0} schöpft Kraft: +{1} TP. / EN: {0} draws strength: +{1} HP. MSG72_GATHERS bleibt die Meldung des Gegners zu „Kraft sammeln“.
- `[870.14.satt]` MSG399_FED: {0} ist gut gestärkt: trifft leichter und schlägt härter. / EN: {0} is well fed: lands blows more easily and hits harder.
- `[870.14.flucht]` MSG296_FLED: {0} ist entkommen! / EN: {0} gets away! · MSG296_CANTFLEE: Die Flucht misslingt! / EN: The escape fails! (Ergebnis der Fluchtprobe in Prozent)
- **Wolf vor dem Feuer (915, 705a B; ersetzt `[870.14.gegen.wolf]` in `STORY-BRS-HELD.md`, MSG870_GEGEN_WOLF; gilt für jedes Feuer, auch aus Wurfmitteln):**
  - `[915.wolf.flucht]` Kampfzeile, jedes Mal: Die Wölfe weichen vor dem Feuer zurück, dann sind sie zwischen den Bäumen fort. / EN: The wolves shy from the fire, then they are gone among the trees. · flieht nur einer: Der Wolf weicht vor dem Feuer zurück, dann ist er zwischen den Bäumen fort. / EN: The wolf shies from the fire, then it is gone among the trees.
  - `[915.wolf.erstmals]` gleich danach, nur beim ersten Vertreiben je Spielstand (solange die Gegenwirkung des Wolfs nicht im Bestiarium steht): Feuer verjagt Wölfe, sobald ihr Leitwolf halb tot ist, und mit ihnen gehen Beute und Erfahrung. / EN: Fire drives wolves off once their leader is half dead, and with them go loot and experience.
  - `[915.lohn.vertrieben]` Lohn nach dem Kampf, jedes Mal, wenn danach kein Gegner mehr stand (`kein_lohn`), auch unter dem Autopiloten: Vor dem Feuer geflohen: keine Beute, keine Erfahrung. / EN: Fled from the fire: no loot, no experience.
  - Bedingung: vor dem Feuer geflohene Wölfe bringen weder Beute noch Erfahrung, auch wenn andere Gegner bleiben (heute zählt `erfahrung_des_siegs` sie mit); wer nach 399.2a flieht, weil sein Leitwolf fiel, zählt wie bisher.
- `[870.14.nobattle]` MSG72_NOBATTLE: In diesem Kampf schon genutzt. / EN: Already used in this battle.
- ST_SHRUGS, ST_STEADFAST, ST_SHAKES: Wortlaut bleibt; sie sind jetzt das Ergebnis einer Abwehrprobe in Prozent.
- Englisch nach Regel (1) in `mars_texte.gd` nachziehen: „smouldering“ → „smoldering“, „creeps round“ → „creeps around“ (MSG72_FLANKEMPTY, MSG130_SIGN_FLANK).
- **Quelle:** `mars_texte.gd` wird heute aus `Skirmish.kt` erzeugt; mit dem Umzug (Schritt 8) wird die Godot-Datei selbst die Quelle, der Generator entfällt, Änderungen von Hand (Tom/Jerry).

## Zustände: Tipp auf das Zeichen (`mars.gd` STATUS_DESC)

Namen und Kurzzeichen bleiben. Ohne Zahlen:

- `[870.14.zustand.gift]` POISON: Schaden zu Beginn jeder Runde. Abwehr mit Zähigkeit. / EN: Damage at the start of each round. Resisted with Toughness.
- `[870.14.zustand.brand]` BURN: Starker Schaden zu Beginn jeder Runde. / EN: Heavy damage at the start of each round.
- `[870.14.zustand.blut]` BLEED: Schaden jede Runde, Heilung nur halb so stark. / EN: Damage each round; healing is halved.
- `[870.14.zustand.betaeubt]` STUN: Setzt die nächste Runde aus. / EN: Loses the next turn.
- `[870.14.zustand.langsam]` SLOW: Trifft schlechter und weicht schlechter aus. / EN: Hits less often and dodges less well.
- `[870.14.zustand.schwach]` WEAK: Trifft schlechter und macht weniger Schaden. / EN: Hits less often and deals less damage.
- `[870.14.zustand.blind]` BLIND: Angriffe mit Ungunst. / EN: Attacks at disfavor.
- `[870.14.zustand.betrunken]` DRUNK: Angriffe und Flucht mit Ungunst, bis zur nächsten Rast. / EN: Attacks and fleeing at disfavor, until your next rest.

## Lohn nach dem Kampf (`lohn.gd`)

- `[870.14.lohn.ep]` GAIN_XP: {0} erhält {1} EP. / EN: {0} gains {1} XP.
- `[870.14.lohn.gold]` GAIN_GOLD: Du erbeutest {0} Gold. / EN: You take {0} gold.
- `[870.14.lohn.stufe]` LEVEL_UP: {0} erreicht Heldenstufe {1}! / EN: {0} reaches Hero Level {1}!
- `[870.14.lohn.grenze]` (ersetzt CAPPED; Kapitelgrenze erreicht, weiche Grenze beginnt): Die Grenze von Kapitel 1 ist erreicht. Erfahrung gibt es nur noch zu einem Viertel; Beute und Ausrüstung wie bisher. / EN: You have reached the limit of Chapter 1. From now on you gain only a quarter of the experience; loot and gear drop as before.
- `[870.14.lohn.ende]` (zwei Stufen darüber, nichts mehr): Weiter trägt dich Kapitel 1 nicht. Erfahrung gibt es keine mehr; Beute und Ausrüstung wie bisher. / EN: Chapter 1 can take you no further. You gain no more experience; loot and gear drop as before.
- `[870.14.lohn.deckel]` (Deckel 40 % aus Fertigkeitsaufstiegen erreicht; einmal je Stufe): Aus deinen Fertigkeiten ist für diese Stufe genug Erfahrung gekommen. Den Rest bringen Kämpfe, Quests und Prüfungen. / EN: Your skills have given all the experience they can for this level. The rest comes from combat, quests and trials.
- `[870.14.lohn.topf]` (Erfahrungstopf des Gebiets leer; einmal je Gebiet): Hier hast du gelernt, was es zu lernen gab. Die Gegner dieser Gegend lehren dich kaum noch etwas. / EN: You have learned what there is to learn here. The foes of these parts teach you little now.
- `[870.14.lohn.voll]` RESTORED: Leben und Mana von {0} sind wieder voll. / EN: {0}'s life and mana are full again.
- NEW_SKILL („Neue Fähigkeit“) und POINTS („Attributspunkte“) entfallen; neue Fertigkeiten meldet `[423.…]` („Neue Fertigkeit: Schleichen“, `DESIGN-BRS.md` 3).
- `[870.14.osric]` Ersatz der drei Wortlaute von `[504.osric.heilung]` (`geschichte.gd` 115, `varianten.gd` 416–423): jeweils der letzte Satz „TP und ZP sind vollständig wiederhergestellt.“ / “HP and SP are fully restored.” wird „Leben und Mana sind wieder voll.“ / “Life and mana are full again.”; der erste Satz bleibt.

## Tipps bei langem Druck (`marstips.gd`)

- `[870.14.tip.angriff]` ATTACK: Ein Schlag oder Schuss mit der Waffe. Nahkampf erreicht nur die vordere Reihe, solange dort jemand steht, und hat von hinten an einem Freund vorbei Ungunst, außer mit Stangenwaffen. Bogen und Armbrust haben Ungunst auf die vordere Reihe, wenn du vorn stehst und ein Freund neben dir; allein vorn schießt du frei. / EN: One blow or shot with your weapon. Melee reaches only the front row while anyone stands there, and from the back past a friend it is at disfavor, except with polearms. Bows and crossbows are at disfavor against the front row when you stand in front with a friend beside you; alone in front you shoot freely. (899, 870c 2 A)
- `[870.14.tip.koennen]` SKILLS: Zauber und Kampfhandlungen, die deine Fertigkeiten dir geben. Zauber kosten Mana; manches geht nur einmal je Kampf oder erst nach dem Langen Ausruhen wieder. / EN: Spells and combat moves your skills give you. Spells cost mana; some work only once per battle or not again until a Long Rest.
- `[870.14.knopf.koennen]` Knopf (`kampf_ui.gd` 695): Können / EN: Abilities.
- `[974.tip.tasche]` BAG (974, Homer 11.11.; ersetzt `[204T.tasche]` „Ein Heiltrank aus dem gemeinsamen Vorrat …“; Grundlage 532, 935: Tasche mit allen Tränken samt Kräutertrank und Wurfmitteln, `werte.json` „kampftasche“, `kampf_ui.gd` 833–877 auf Build 277; fremd geprüft 16:57): Ein Griff in die Tasche: ein Trank für dich oder einen Freund, oder ein Wurfmittel auf einen Gegner. Kräutertränke heilen wenig, nehmen aber Gift und andere Zustände. Kostet den Zug. / EN: A reach into your bag: a potion for you or a friend, or something to throw at a foe. Herbal remedies heal little but take away poison and other conditions. Costs your turn.
- `[870.14.tip.abwehr]` DEFEND: Bis zu deinem nächsten Zug haben Angriffe auf dich Ungunst, deine Abwehr gegen Flächenwirkungen hat Gunst. Manchmal ist das die richtige Antwort. / EN: Until your next turn, attacks on you are at disfavor and you resist area effects with favor. Sometimes that is the right answer.
- `[870.14.tip.decken]` COVER (nur, solange es den Knopf gibt: Decken ist Fähigkeit des Wächters, `DESIGN-BRS.md` 7 (3); ob er in Kapitel 1 bleibt, klärt Jerry in 870.3): Nur aus der vorderen Reihe: einen Zug lang ziehst du jeden angekündigten Schlag auf Freunde auf dich, jeden mit Ring. Ring perfekt: Gegenschlag. / EN: Front row only: for one turn you draw every announced blow aimed at friends, each with a ring. Perfect ring: a counterblow.
- `[870.14.tip.automatik]` AUTOPILOT: Spielt deinen Helden: Waffe, Kleinzauber, Heilung für einen schwachen Freund. Fängt den Ring immer gut, nie perfekt. Hält an unter einem Drittel des Lebens und bei einer starken Absicht; nie gegen Bosse. / EN: Plays your hero: weapon, minor spells, healing for a weak friend. Always meets the ring well, never perfectly. Stops below a third of life and on a strong intent; never against bosses.
- BAG, PLACE, MERC bleiben.

## Ansagen der Gegner (`marstips.gd` INTENTS)

Würfel raus, „Nachteil“ → „Ungunst“, „Lebenspunkte“ → „Leben“; sonst wie 210T.

- `[870.14.ansage.heavy]` Schwerer Hieb: die Axt mit voller Wucht, weit mehr Schaden, gegen eine Figur. Hilft: vorher ein Fünftel seines Lebens nehmen, dann taumelt er und der Zug ist verloren; sonst Abwehr oder den Ring treffen. / EN: Heavy blow: the axe at full force, far more damage, against one figure. Counter: take a fifth of his life first and he staggers, his turn lost; otherwise Defend or meet the ring. (Bleibt Decken, kommt „, Decken“ / “, Cover” nach „Abwehr“ zurück.)
- `[870.14.ansage.call]` (899, 870c 1 A; ersetzt 210T, auch den Namen `I_CALL` in `mars.gd` 155 „Rudel rufen“ / “Call the pack”): Hilfe rufen: ein Goblin kommt, höchstens einmal im Kampf. Hilft: Verhindern lässt es sich nicht; nutze den Zug, um Grak selbst zuzusetzen oder dich aufzustellen. / EN: Call for help: a goblin comes, at most once per battle. Counter: it cannot be stopped; use the turn to wear Grak down or to set your line.
- `[870.14.ansage.gather]` Kraft sammeln: er heilt sich um einen guten Teil seines Lebens. Hilft: vorher ein Fünftel seines Lebens nehmen, dann bleibt die Heilung aus. / EN: Gather strength: he heals a good part of his life. Counter: take a fifth of his life first and the healing fails.
- `[870.14.ansage.breakthrough]` Durchbrechen: er stößt die Figur vorn nach hinten und schlägt die dahinter, die nun vorn steht, härter als sonst. Hilft: der Bedrohte tritt selbst nach vorn, dann bleibt ein einfacher Schlag; oder vorher ein Fünftel seines Lebens. / EN: Break through: he shoves the front figure back and strikes the one behind, now in front, harder than usual. Counter: the threatened one steps forward, leaving a plain blow; or a fifth of his life first.
- `[870.14.ansage.stab]` Stich: ein einfacher Schlag, ohne Ring. Hilft: Abwehr gibt ihm Ungunst; meist lohnt der eigene Angriff mehr. / EN: Stab: a plain blow, without a ring. Counter: Defend puts it at disfavor; usually your own attack is worth more.
- `[870.14.ansage.venom]` Gift sammeln: der nächste Biss macht weit mehr Schaden, ohne Ring. Hilft: vorher ein Fünftel ihres Lebens, dann versiegt das Gift; sonst Abwehr. / EN: Gather venom: the next bite deals far more damage, without a ring. Counter: a fifth of her life first and the venom dries up; otherwise Defend.
- `[870.14.ansage.web]` Netz werfen: trifft es, verliert die Figur ihren nächsten Zug. Hilft: den Ring perfekt treffen; Abwehr gibt ihr Ungunst. / EN: Throw web: if it hits, the figure loses its next turn. Counter: meet the ring perfectly; Defend puts her at disfavor.
- `[870.14.ansage.aim]` Anlegen: ein Schuss, härter als sonst, ohne Ring. Hilft: die Figur geht in Abwehr, dann duckt sie sich und der Pfeil geht vorbei. / EN: Take aim: a shot harder than usual, without a ring. Counter: that figure Defends, ducks, and the arrow misses.
- `[870.14.ansage.shadow]` In den Schatten: er verschwindet; bis zu seinem nächsten Zug haben Angriffe auf ihn Ungunst. Hilft: jeder Treffer vorher, auch ein leichter, hält ihn im Licht. / EN: Into the shadows: he vanishes; until his next turn, attacks on him are at disfavor. Counter: any hit beforehand, however light, keeps him in the light.
- flank, pounce, circle: bleiben (keine SRD-Wörter).

## Eingebungen der Ansagen (986)

Eine Zeile im Kampfbericht beim ersten Auftreten der Ansage, einmal je Spielstand, gebaut wie der Wolfssprung `[830.sprung]` (840, `mars.gd` EINGEBUNG). Gegen die Regeln nach BRS gelesen in `godot/regeln/mars.gd` (main `e53f01365`, 11.11.): Brechen bei einem Fünftel des Lebens (`BREAK_SHARE`; heavy, gather, venom, breakthrough) oder bei jedem Schaden über 0 (flank, circle, shadow); Ring nur bei heavy, web, breakthrough (nur perfekt hält vom Netz frei; Automatik fängt nie perfekt); Abwehr (Knopf, `"wait"`) gibt Ungunst und lässt den Späher an der angezielten Figur vorbeischießen; Kraft sammeln heilt einen guten Teil, nicht alles; Einkreisen und Knurren kommen von jedem Wolf, auch Jungwolf und Leibwache. Bekannte Grenze: ein Treffer ohne Schaden (Rüstung) bricht nichts, „Kratzer“ und „egal wie leicht“ meinen Schaden über 0. Ändert Jerry eine Regel, ändert Homer den Text.

Bleiben im Wortlaut von `STORY-SPIEL.md` „Ansagen erklärt“: `[210T.heavy.eingebung]`, `[210T.call.eingebung]` (Name jetzt „Hilfe rufen“, passt), `[210T.shadow.eingebung]`; Wolf: `[830.sprung]` (fest, Chef 10.11.; Fremdprüfung 19:16: Anspringen zielt auch auf den Söldner, „Stehe ich“ stimmt dann nicht; Wortlaut bleibt bis zum Urteil des Chefs). Neu statt der alten:

- `[986.stab]` (ersetzt `[210T.stab.eingebung]`: „Ausweichen“ ist im BRS eine Abwehrfertigkeit und wirkt immer; gemeint ist der Knopf Abwehr; „Stich“ sagen viele an, auch Krogg und der giftige Hundertfüßer, darum „meist“) Nur ein Stich. Meist lohnt mein eigener Schlag mehr als die Abwehr. / EN: Just a stab. My own blow is usually worth more than a Defend.
- `[986.hieb]` (ersetzt `[210T.hieb.eingebung]`, Ansage `slash`; Grund wie oben) Nur ein Hieb. Meist lohnt mein eigener Schlag mehr als die Abwehr. / EN: Just a slash. My own blow is usually worth more than a Defend.
- `[986.flank]` (ersetzt `[210T.flank.eingebung]`: EN nach Regel (6) „switch rows“) Er will hintenrum. Ein Kratzer hält ihn auf, ein Wechsel der Reihe auch. / EN: He means to go around. A scratch stops him, and so does switching rows.
- `[986.circle]` (ersetzt `[210T.circle.eingebung]`: einkreisen kann jeder Wolf, nicht nur der Leitwolf) Der da ruft das Rudel zusammen. Den treffen, egal wie leicht. / EN: That one calls the pack together. Hit it, however lightly.
- `[986.growl]` (ersetzt `[210T.growl.eingebung]`: auch die Leibwache knurrt; „Erst der Große“ ließ sich doppelt lesen) Der hier hält sich zurück. Erst den Leitwolf treffen. / EN: This one holds back. Hit the lead wolf first.
- `[986.web]` (ersetzt `[210T.web.eingebung]`: nur perfekt hält frei) Das Netz fliegt langsam. Nur wer den Moment genau trifft, bleibt frei. / EN: The web flies slowly. Only perfect timing keeps you free.
- `[986.gather]` (ersetzt `[210T.gather.eingebung]`: er heilt einen guten Teil, nicht alles, `[870.14.ansage.gather]`) Er holt Luft. Jetzt nachsetzen, sonst kommt er wieder zu Kräften. / EN: He is catching his breath. Press now, or he regains his strength.
- `[986.breakthrough]` (ersetzt `[210T.breakthrough.eingebung]`: steht der Bedrohte vorn, schlägt Grak trotzdem zu, nur einfach, `MSG72_BRACED`) Er will durch die Reihe. Tritt der Bedrohte vorher selbst nach vorn, bleibt Grak nur ein einfacher Schlag. / EN: He means to break the line. If the threatened one steps forward first, Grak is left with a plain blow.
- `[986.venom]` (ersetzt `[210T.venom.eingebung]`: die Ansage ist die Warnung, es fehlt nur der Ring; brechen erst bei einem Fünftel) Gegen den Giftbiss hilft kein Ring. Treffe ich sie vorher hart, versiegt das Gift. / EN: No ring helps against the venom bite. If I hit her hard first, the venom dries up.
- `[986.aim]` (ersetzt `[210T.aim.eingebung]`: er zielt oft auf einen Gefährten, „auf mich“ stimmte dann nicht; nennt den Knopf wie `[830.sprung]`) Er legt an. Geht der Anvisierte in Abwehr, duckt er sich, und der Pfeil geht vorbei. / EN: He takes aim. If the one in his sights Defends, the arrow flies past.

Lange Ansagetexte (`marstips.gd` INTENTS), mit 986 nachgezogen:

- `[986.flank.tip]` (ersetzt `[210T.flank]`; Code hat noch „sticht“, 348.12 „schlägt“) Flanke: er läuft um die Reihe und schlägt eine Figur hinten, ohne Deckung. Hilft: die Figur wechselt die Reihe, dann schlägt er ins Leere; oder jeder Treffer auf ihn, auch ein leichter. / EN: Flank: he runs around the line and strikes a figure at the back, without cover. Counter: that figure switches rows and he strikes at nothing; or any hit on him, however light.
- `[986.circle.tip]` (ersetzt `[210T.circle]`: gebrochen wird nur das Einkreisen, kein Wolf flieht) Einkreisen: alle Wölfe beißen zugleich dieselbe Figur. Hilft: jeder Treffer auf den Wolf, der es ansagt, auch ein leichter, vereitelt das Einkreisen. / EN: Circle: every wolf bites the same figure at once. Counter: any hit on the wolf that calls it, however light, foils the circle.

Ohne Eingebung: `bite`, `claw` (einfache Schläge; Ratte, Fledermaus, Grabhund, Wiedergänger; der Biss des Grabhunds lähmt, Zweig 506: eigene Ansage mit Eingebung erst, wenn der Grabhund auf main kommt). Für den Bau (Jerry): (1) Knurren übergeht `_say_announce` (`if intent.effect == "GROWL": return`), seine Eingebung gehört an die erste Zeile `MSG399_GROWLS` in `_foe_turn`. (2) Der von Grak gerufene Goblin (`_summon`) und der abgespaltene Schleim werden nur mit `announce` angekündigt, ohne `_say_announce`; ihre erste Ansage steht nicht im Bericht, die Eingebung fehlt dort. (3) Die Leibwache ist nicht angreifbar, darf also kein Einkreisen ansagen (sonst stimmt `[986.circle]` nicht). (4) `I_WEB` heißt im Code „Cast web“, `[870.14.ansage.web]` „Throw web“: Code angleichen. (5) `marstips.gd` „heavy“ nennt noch „Decken“, `[870.14.ansage.heavy]` nicht (den Knopf gibt es nach BRS nicht).

Kampfhandlungen und Zauber: `STORY-BRS-KOENNEN.md`.
