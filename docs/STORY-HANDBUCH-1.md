# Spielerhandbuch Bornimer Rollenspielsystem, Teil 1 (423)

Entwurf Homer, 01.11.; Quelle allein das Nachschlagewerk `DESIGN-BRS.md` (gültig seit 422). Teil 1: Grundidee, Held, Fertigkeiten, Stufe. Teil 2 `STORY-HANDBUCH-2.md`: Pfad, Meisterschaften, Kampf, Welt, Ruf, Herstellen, Abnutzung. Verzeichnis `STORY-REGELN.md`. Prüfpunkte für den Chef in `docs/chefsache/ansehen/423-handbuch.md`.

**Für Tom (Bau erst nach Abnahme durch den Chef und nach 444):**
- Ersetzt die Anleitung 352 (`alt/STORY-ANLEITUNG.md`), sobald das Bornimer Rollenspielsystem (BRS, vormals Spielsystem 2.0; 451) im Spiel ist; Aufbau wie dort: Seite mit Abschnitten, fetter Kopf, Absatz, oben Sprungmarken.
- **Platzhalter statt Zahlen, die 444 noch festlegt** (Chef 01.11., 12:3x, Archiv 423): `{schlüssel}` füllt das Spiel aus derselben Datendatei, nach der es rechnet; nie eine Zahl in den Text schreiben. `|prozent` heißt: Anteil als ganze Prozentzahl (0,4 → „40 %“, englisch „40%“). Schlüssel wie in `tools/sim444/werte.json`; die mit * gibt es dort noch nicht, Tom legt sie in der Datendatei an (Wert aus dem Nachschlagewerk, Abschnitt 4 und 5):
  - `{erfahrung.fertigkeit_deckel|prozent}` Anteil der Erfahrung je Stufe aus Fertigkeiten (`[423.stufe.deckel]`)
  - `{held.kapitelgrenze}` Stufengrenze des laufenden Kapitels; `{held.grenze_weich_stufen}`* Stufen darüber; `{held.grenze_weich_anteil|prozent}`* Erfahrung darüber (`[423.stufe.grenze]`)
  - `{held.startfertigkeit}` Startwert der Fertigkeiten aus Herkunft oder Wahl (`[423.herkunft]`)
  - `{pruefung.zwischen_kapitel}`*, `{pruefung.geselle_kapitel}`*, `{pruefung.meister_kapitel}`* Kapitel, ab dem die Prüfung beim Lehrmeister offen ist (`[423.pruefung.takt]`)
- Zahlen, die entschieden sind, stehen im Text (9 Punkte ab 3, höchstens 8, Ränge 0 bis 100, 9 Stufen, 1 von 100). Ein neuer Platzhalter nur über Homer.
- Ein Absatz über einen Pfad, eine Meisterschaft oder eine Fertigkeit erscheint erst, wenn das Spiel sie hat; die Tabellen sind das Ganze, das Spiel zeigt, was gebaut ist.
- Feste Namen (auch Englisch) stehen in `[423.namen]` in Teil 3 (`STORY-HANDBUCH-3.md`: Herstellen, Abnutzung, Namen).

## Seite

`[423.titel]` Handbuch
EN: Handbook

`[423.vorweg]` Niemand sagt dir, wer du wirst. Die Chronik hält fest, was du tust, und daraus wächst dein Held. Hier steht, was du dafür wissen musst; der Rest zeigt sich unterwegs.
EN: No one tells you who to become. The chronicle records what you do, and your hero grows from it. Here is what you need to know; the rest reveals itself on the road.

`[423.blick]` **Auf einen Blick.** Vier Dinge machen deinen Helden aus. Die **Herkunft**: wie seine Geschichte anfängt; einmal gewählt, freiwillig. Die **Fertigkeiten**: was er kann; sie wachsen, wenn du sie gebrauchst, und am Ende jedes Rangs wartet eine Prüfung. Der **Pfad**: wohin er sich spezialisiert; ein Lehrmeister bietet ihn an, wenn du die passenden Fertigkeiten übst. Die **Heldenstufe**: wie stark er insgesamt ist; sie steigt mit der Erfahrung.
EN: **At a glance.** Four things make your hero. **Origin**: how his story begins; chosen once, if you wish. **Skills**: what he can do; they grow as you use them, and at the end of each rank a trial awaits. **Path**: where he specialises; a mentor offers it once you practise the right skills. **Hero level**: how strong he is overall; it rises with experience.

## Die Grundidee

`[423.idee]` **Du wirst, was du tust.** Das ist der Leitsatz der Regeln dieses Spiels, des Bornimer Rollenspielsystems, kurz BRS. Es gibt keine Klasse, die du am Anfang wählst. Wer oft den Bogen spannt, trifft besser. Wer zaubert, zaubert stärker. Wer schleicht und Dolche führt, bekommt eines Tages Besuch von jemandem, der ihm einen Pfad anbietet.
EN: **You become what you do.** That is the guiding line of this game's rules, the Bornim Roleplaying System, BRS for short. There is no class to pick at the start. Draw the bow often and you shoot truer. Cast spells and your spells grow stronger. Creep and wield daggers, and one day someone will come to offer you a path.

`[423.idee.frei]` **Alles geht, nichts muss.** Kampf, Handwerk, Sammeln: jeder Weg bringt dich voran, keiner ist Pflicht. Du darfst dieselben Wälder wieder und wieder durchstreifen; nötig ist es nie. Wiederkehrende Gegner bringen Beute und Übung, aber kaum noch Erfahrung.
EN: **Everything is possible, nothing is required.** Battle, craft, gathering: every way takes you forward, none is a must. You may roam the same woods again and again; you never have to. Returning foes bring loot and practice, but hardly any experience.

`[423.idee.zufall]` **Wenig Zufall.** Es wird nicht gewürfelt. Was zählt, sind Stufe, Fertigkeit, Waffe und Grundwerte; der Zufall streut nur ein wenig.
EN: **Little chance.** No dice decide. What counts is level, skill, weapon and attributes; chance only scatters the result a little.

## Der Held

`[423.werte]` **Die sechs Grundwerte.** **Kraft**: Schaden im Nahkampf, Tragkraft, Aufbrechen und Heben. **Gewandtheit**: Tempo, Ausweichen, Fingerfertigkeit, kritische Treffer. **Zähigkeit**: Leben, Rüstung tragen, Widerstand gegen Gift, Krankheit und Kälte. **Verstand**: Wissen, Handwerk, Alchemie, wie schnell du lernst. **Wille**: Mana, Stärke der Zauber, Konzentration, Mut, Überzeugungskraft. **Wahrnehmung**: Treffen im Fernkampf, Hinterhalte bemerken, Fährten; sie hilft dem Spähen, Verstecktes und Fallen zu finden.
EN: **The six attributes.** **Strength**: melee damage, carrying, forcing and lifting. **Agility**: speed, dodging, nimble fingers, critical hits. **Toughness**: life, wearing armor, resisting poison, sickness and cold. **Wits**: knowledge, craft, alchemy, how fast you learn. **Will**: mana, spell power, focus, courage, persuasion. **Perception**: aim at range, noticing ambushes, tracks; it helps scouting find what is hidden, traps included.

`[423.werte.ab]` **Leben, Ausdauer, Mana.** Leben kommt aus Zähigkeit und Stufe, Ausdauer aus Zähigkeit und Wille, Mana aus Wille. Eine Gabe, andere zu bezaubern, gibt es nicht: wie die Leute dir begegnen, hängt an deinem Ruf und an deinen Worten.
EN: **Life, stamina, mana.** Life comes from Toughness and level, stamina from Toughness and Will, mana from Will. There is no gift of charm: how people meet you depends on your reputation and your words.

`[423.schaffen]` **Der Anfang.** Jeder Grundwert beginnt bei 3. Du verteilst 9 Punkte, kein Wert steigt dabei über 8: du kannst einen Wert stark machen oder mehrere ein wenig.
EN: **The beginning.** Every attribute starts at 3. You spend 9 points, and none may go above 8 this way: make one value strong, or raise several a little.
(933.1, Chef 11.11., 13:07 „933 A“; ersetzt „beginnt bei 1, 21 Punkte“.)

`[423.volk]` **Dein Volk** gibt einen kleinen Vorteil, meist auch einen kleinen Nachteil, und ein Merkmal, das man merkt. Es kann Werte auf 9 heben oder auf 2 senken. Die Leute in der Welt sehen, wer du bist, und begegnen dir danach.
EN: **Your people** grant a small boon, usually a small flaw, and a trait you will notice. They may lift values to 9 or lower them to 2. The folk of the world see what you are and meet you accordingly.
(933.1: Volk senkt bis 2, Archiv 933 A; „meist“, weil der Mensch kein Minus hat.)

`[423.volk.liste]` **Mensch**: einen Punkt, wohin du willst; Wandelbar, eine Fertigkeit mehr zum Start. **Elf**: Gewandtheit und Wahrnehmung höher, Zähigkeit niedriger; Wachsame Sinne. **Zwerg**: Zähigkeit und Verstand höher, Gewandtheit niedriger; Steinblut. **Hügelvolk**: Gewandtheit und Wille höher, Kraft niedriger; Glückskind. **Orkblütiger**: Kraft und Zähigkeit höher, Wille niedriger; Letzter Atemzug. **Aschgeborener**: Wille und Wahrnehmung höher, Gewandtheit niedriger; Aschenerbe, Zauber deiner Feinde verletzen dich weniger.
EN: **Human**: one point wherever you like; Adaptable, one extra skill at the start. **Elf**: Agility and Perception higher, Toughness lower; Watchful Senses. **Dwarf**: Toughness and Wits higher, Agility lower; Stoneblood. **Hill Folk**: Agility and Will higher, Strength lower; Child of Fortune. **Orc-blooded**: Strength and Toughness higher, Will lower; Last Breath. **Ashborn**: Will and Perception higher, Agility lower; Ashen Legacy, your enemies' spells wound you less.
(Aschgeborener: entschieden 432.3, Chef 02.11., 22:05; ins Spiel erst mit dem Bau nach dem Meilenstein.)

`[423.herkunft]` **Herkunft, wenn du willst.** Eine Herkunft verteilt die Punkte für dich vor, gibt dir zwei oder drei Fertigkeiten mit dem Wert {held.startfertigkeit} und die Ausrüstung dazu. Ein Satz sagt dir, wohin sie meist führt. Die Punkte darfst du danach noch ändern. Wer keine Herkunft will, ist **Wanderer**: er verteilt selbst und wählt zwei Fertigkeiten, ebenfalls mit dem Wert {held.startfertigkeit}.
EN: **Origin, if you wish.** An origin spends the points for you, gives you two or three skills at {held.startfertigkeit} and the gear to match. One line tells you where it usually leads. You may still move the points afterwards. Whoever wants no origin is a **Wanderer**: he spends his own points and picks two skills, likewise at {held.startfertigkeit}.

`[423.herkunft.liste]` **Wachsoldat**: Schild, Mittlere Rüstung, Einhänder; führt zu Wächter oder Paladin. **Jägerkind**: Bogen, Wurfwaffen, Spähen; zu Waldläufer oder Scharfschütze. **Zauberlehrling**: Evokation, Schutzmagie; zu Magier oder Kriegsmagier. **Klosterschüler**: Heilmagie, Heilkunde, Kräutersammeln; zu Heiler oder Paladin. **Kräutersammler**: Kräutersammeln, Alchemie, Spähen; zum Alchemisten. **Schmiedelehrling**: Schmieden, Bergbau, Stumpfe Waffen; zum Schmied. **Herumtreiber**: Schleichen, Spähen, Dolche; zu Assassine oder Schatzjäger.
EN: **Watch Soldier**: Shield, Medium Armor, One-handed; leads to Warden or Paladin. **Hunter's Child**: Bow, Throwing, Scouting; to Ranger or Marksman. **Apprentice Mage**: Evocation, Warding; to Mage or Battlemage. **Cloister Pupil**: Healing Magic, Medicine, Foraging; to Healer or Paladin. **Herb Gatherer**: Foraging, Alchemy, Scouting; to Alchemist. **Smith's Apprentice**: Smithing, Mining, Blunt Weapons; to Smith. **Drifter**: Stealth, Scouting, Daggers; to Assassin or Treasure Hunter.

## Fertigkeiten

`[423.fert]` **Was du kannst.** Jede Fertigkeit gehört zu einer Handlung, die du im Spiel tust, und sie wirkt, wo du es merkst. Waffen übst du, wenn du triffst; Rüstung, wenn man dich trifft; Ausweichen, wenn du einem Hieb entgehst; Schatten beim Anschleichen, Umsehen, an Truhen und Fallen; Magie beim Zaubern; Tiere beruhigen, wenn du ein feindliches Tier vor dem Kampf besänftigst; Gesellschaft im Gespräch und im Laden; Sammeln beim Ernten, Angeln und Zerlegen; Handwerk beim Herstellen.
EN: **What you can do.** Every skill belongs to something you do in the game, and it works where you feel it. Weapons you train by hitting; armor by being hit; dodging by escaping a blow; shadow skills by sneaking, looking around, at chests and traps; magic by casting; calming beasts by soothing a hostile beast before the fight; society in talk and in shops; gathering by harvesting, fishing and butchering; craft by making things.

`[423.fert.liste]` **Waffen**: Einhänder, Zweihänder, Stangenwaffen, Stumpfe Waffen, Dolche, Faustkampf, Schild, Bogen, Armbrust, Wurfwaffen. **Rüstung**: Leichte, Mittlere, Schwere Rüstung, Ausweichen. **Schatten**: Schleichen, Spähen, Schlösser knacken, Fallen entschärfen. **Magie**: Evokation, Schutzmagie, Heilmagie, Illusion, Beschwörung (mit Nekromantie). **Wildnis**: Tiere beruhigen. **Gesellschaft**: Überreden (mit Täuschen), Einschüchtern, Handeln. **Sammeln**: Kräutersammeln, Bergbau, Angeln, Jagd (Zerlegen, Fährten). **Handwerk**: Schmieden (Metall, Reparieren, Dietriche), Schneidern (Gerben, Nähen, Reparieren), Alchemie (mit Giften), Kochen, Runenkunde (Verzaubern), Heilkunde.
EN: **Weapons**: One-handed, Two-handed, Polearms, Blunt Weapons, Daggers, Brawling, Shield, Bow, Crossbow, Throwing. **Armor**: Light, Medium, Heavy Armor, Dodge. **Shadow**: Stealth, Scouting, Lockpicking, Disarming Traps. **Magic**: Evocation, Warding, Healing Magic, Illusion, Summoning (with necromancy). **Wilds**: Calming Beasts. **Society**: Persuasion (with deceit), Intimidation, Haggling. **Gathering**: Foraging, Mining, Fishing, Hunting (butchering, tracking). **Craft**: Smithing (metal, repairs, lockpicks), Tailoring (tanning, sewing, repairs), Alchemy (with poisons), Cooking, Runecraft (enchanting), Medicine.

`[423.fert.neu]` **Erst wenn du es tust.** Eine Fertigkeit erscheint auf deinem Heldenblatt, sobald du sie zum ersten Mal gebrauchst. Hier im Handbuch stehen alle.
EN: **Only once you do it.** A skill appears on your hero sheet the first time you use it. This handbook lists them all.

`[423.fert.wachsen]` **Wie sie wachsen.** Jeder Gebrauch gegen ein passendes Ziel bringt Übung. Was zu leicht ist, lehrt dich kaum etwas. Je besser du schon bist, desto mehr Übung braucht der nächste Schritt. Steigt eine Fertigkeit, siehst du es sofort („Bogen ↑“).
EN: **How they grow.** Every use against a fitting target brings practice. What is too easy teaches you little. The better you already are, the more practice the next step needs. When a skill rises, you see it at once ("Bow ↑").

`[423.rang]` **Ränge.** Jede Fertigkeit hat einen Wert von 0 bis 100 in vier Rängen: **Anfänger** bis 24, **Geselle** bis 49, **Meister** bis 74, **Großmeister** bis 100. Bei 100 ist sie vollendet.
EN: **Ranks.** Every skill has a value from 0 to 100 in four ranks: **Novice** up to 24, **Journeyman** up to 49, **Master** up to 74, **Grandmaster** up to 100. At 100 it is complete.

`[423.pruefung]` **Die Prüfung am Ende des Rangs.** Am Ende eines Rangs bleibt der Wert stehen, bis du eine Prüfung bestanden hast; was du bis dahin übst, wird ein wenig aufgehoben. Fertigkeiten deines Pfads prüft dein Lehrmeister; eine bestandene Prüfung öffnet den nächsten Rang für alle Kernfertigkeiten des Pfads zugleich. Für alle anderen gibt es eine **Bewährungsprobe** in der Welt; sie steht auf deinem Heldenblatt, etwa „drei Gegner deiner Stufe nur mit dem Schwert, ohne Heiltrank“ oder „einen Fisch über drei Kilo fangen“. Ohne Pfad oder Meisterschaft endet eine Fertigkeit beim Meister; Großmeister wird man nur auf dem eigenen Weg.
EN: **The trial at the end of a rank.** At the end of a rank the value stands still until you pass a trial; what you practise meanwhile is kept, a little. Skills of your path are tested by your mentor; a trial passed opens the next rank for all core skills of the path at once. For all others there is a **proving** out in the world; it is written on your hero sheet, such as "three foes of your level with the sword alone, no healing potion" or "catch a fish over three kilos". Without a path or a mastery a skill ends at Master; only on your own way do you become a Grandmaster.

`[423.pruefung.takt]` **Mit der Chronik.** Welche Prüfungen dir offenstehen, hängt davon ab, wie weit die Geschichte ist. Was heute verschlossen ist, öffnet ein späteres Kapitel: beim Lehrmeister die Prüfung zum Eingeweihten ab Kapitel {pruefung.zwischen_kapitel}, die zum Titel ab Kapitel {pruefung.geselle_kapitel}, die zum hohen Titel ab Kapitel {pruefung.meister_kapitel}.
EN: **With the chronicle.** Which trials are open to you depends on how far the story has come. What is closed today, a later chapter opens: with your mentor, the trial to become Initiate from chapter {pruefung.zwischen_kapitel}, the trial for the title from chapter {pruefung.geselle_kapitel}, the trial for the high title from chapter {pruefung.meister_kapitel}.

## Heldenstufe und Erfahrung

`[423.stufe]` **Die Heldenstufe** bestimmt dein Leben, deine Stärke im Kampf und welche Rezepte und Prüfungen dir offenstehen. Sie steigt mit Erfahrung: aus gewonnenen Kämpfen, aus Quests, aus der Geschichte, aus bestandenen Prüfungen und Bewährungsproben und aus jedem Aufstieg einer Fertigkeit. Bloßes Üben bringt keine Erfahrung, erst der Aufstieg.
EN: **Hero level** decides your life, your strength in battle and which recipes and trials are open to you. It rises with experience: from battles won, from quests, from the story, from trials and provings passed, and from every rise of a skill. Mere practice brings no experience; only the rise does.

`[423.stufe.deckel]` **Nicht nur durch Üben.** Höchstens {erfahrung.fertigkeit_deckel|prozent} der Erfahrung für die nächste Stufe dürfen aus Fertigkeiten stammen; den Rest holst du dir in Kampf, Quest, Geschichte und Prüfungen. Ist dieser Teil voll, sagt es dir eine Anzeige.
EN: **Not by practice alone.** At most {erfahrung.fertigkeit_deckel|prozent} of the experience for the next level may come from skills; the rest you earn in battle, quest, story and trials. When that share is full, a sign tells you.

`[423.stufe.grenze]` **Jedes Kapitel hat seine Grenze,** in diesem Stufe {held.kapitelgrenze}. Bis dahin wächst du frei; bis zu {held.grenze_weich_stufen} Stufen darüber hinaus kommst du nur mühsam, mit {held.grenze_weich_anteil|prozent} der Erfahrung, und das nächste Kapitel hebt die Grenze. Eine höchste Stufe gibt es nicht.
EN: **Every chapter has its limit,** in this one level {held.kapitelgrenze}. Up to it you grow freely; up to {held.grenze_weich_stufen} levels beyond it you climb only slowly, on {held.grenze_weich_anteil|prozent} of the experience, and the next chapter raises the limit. There is no highest level.

`[423.stufe.topf]` **Jedes Gebiet gibt, was es hat.** Hast du jede Quest erledigt und jeden Gegner einmal besiegt, hast du die Erfahrung des Kapitels ausgeschöpft. Wer dann weiterkämpft, findet Beute und Übung, aber kaum noch Erfahrung. Gegner, die 9 Stufen und mehr unter dir stehen, geben gar keine Erfahrung mehr.
EN: **Every land gives what it has.** Once you have finished every quest and beaten every foe once, you have drawn all the chapter's experience. Fight on and you find loot and practice, but hardly any experience. Foes 9 levels or more below you give no experience at all.
