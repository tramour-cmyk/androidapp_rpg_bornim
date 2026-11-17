# Englisch: Korrekturliste (338.1a Homer → 338.1b Team Tom)

Homer, 24.10., 21:50. Stand `main` c963ae7. Gelesen wurden alle 1315 Textpaare `T(…)`/`t(…)`/`say`/`narrate` und 234 Stellen `if (de) … else …` (Werkzeug: fünf Lesehelfer, Funde von Homer gegen Quelle und `STORY-REGELN.md` geprüft; Auszugsfehler verworfen). Zeilen = Stand c963ae7; bei Abweichung über den alten Text suchen. **Nur das Englische ändern**, das Deutsche bleibt. Wo ein Text Platz braucht (Knopf, Reiter), kürzer wählen und vermerken.

## Regeln für alle englischen Texte (entschieden von Homer)

1. **US-Schreibung** überall (UI schreibt schon „Armor“): colour→color, grey→gray, smoulder→smolder, recognise→recognize, practise (Verb)→practice, traveller→traveler, towards→toward, any more→anymore, dreamt→dreamed, round (Präposition)→around, dearer→more expensive/„for more“.
2. **Feste Namen** (`STORY-REGELN.md` Z. 12): Temple of the **Dawnlight** (nie „Morning Light“), Morwen the **Herbalist** (nie „herbwoman“), **Deep Whisperwood** (nie „deep woods“), Aufträge = **Quests** (nie „Task“, „Odd jobs“: Hauptauftrag = **Main quest**, Nebenaufträge = **Side quests**), **the Elder** groß.
3. **HP**, nie „life points“; Trefferpunkte = hit points.
4. **Auslassung „…“** (ein Zeichen, ohne Leerzeichen davor), nie „...“; **Anführung “…”**, nie `\"…\"`, nie »…«.
5. **5e-Begriffe:** ability scores (Attribute), Armor Class, Hit Die, Proficiency Bonus (wo Platz), spell save DC, knocked prone, attack and damage rolls, racial bonus, Dwarven Resilience, Handaxe, Potion of Healing / Potion of Greater Healing / Potion of Superior Healing; Zaubernamen groß (Fire Bolt, Spiritual Weapon, Spirit Guardians).
6. **Ein Wort je Sache:** Fähigkeiten/Können (Kampfknopf) = **Skills**; Decken = **Cover**; Reihe wechseln = **switch rows** / „switch“; Automatik = **Autopilot**; Kampf in Menüs und Regeln = **Combat**/**battle**, nicht „fight“ (Ausnahme „Easy fight“, s. u.); Tränke = **potions**; Ausrüstung = **gear**; Laden = **shop**; Leuchtfunke = **Lightspark**; angelegt = **Equipped**.
7. Kampfmeldungen im **Präsens** (gains, reaches, loot); keine Pokémon-Sätze.

## Einzelstellen

Format: Datei:Zeile – alt → neu.

**Spieltexte (Story, Zwischenszenen, Aufträge)**
- Chronicle.kt:14 – The Task → The Quest
- Chronicle.kt:21 – keeps the beasts away from his fire with a torch → keeps the beasts at bay with a torch by his fire
- Chronicle.kt:24 – warned anyone who went on → warned off anyone going further
- Chronicle.kt:36 – Morning Light → Dawnlight
- Chronicle.kt:42 – deep woods → Deep Whisperwood
- Chronicle.kt:54 – a means against a bugbear's first blow → a way to blunt a bugbear's first blow
- Story.kt:56 – herbwoman → herbalist; knows how to take the first blow out of one like him → knows how to rob one like him of his first strike
- Story.kt:183 – → „Gwenna lives here. Ever since her husband didn't come back, the door has stayed locked.“
- Story.kt:185 – → „The house of Dorran the smith. He must be in his workshop.“
- Story.kt:214 – → „The Elder told me about you. Well then, let's go.“
- Story.kt:216 – loosens the rope → releases the rope
- Story.kt:222 – → „Since you beat Grak, I've been sleeping soundly again. Thanks, {name}!“
- Story.kt:236 – → „If you get meat in the forest, roast it over a campfire – that's when it tastes best. And it makes you strong!“
- Story.kt:238 – → „Now that the goblins are gone, even my hens sleep soundly again.“
- Story.kt:279 – → „The road south is not passable yet. Chapter 2 is coming in a later update.“
- Story.kt:281 – won't let you go → won't leave your mind
- Story.kt:316 – Hand it over, it'll be → Hand it over – it'll be
- Story.kt:350 – like a rock → like a log
- Story.kt:451 – won't wait for long → won't wait long
- Story.kt:583 – take these → take this (DE „das“; nur wenn ein Gegenstand)
- Story.kt:772 – crashes to the ground → sinks to the ground
- Story.kt:822 – grow stronger → strengthen your hero
- Story.kt:834 – deep into the night → late into the night
- Interlude.kt:53 – The mouth of the Bloodfang Cave → The entrance of the Bloodfang Cave
- Interlude.kt:58, :60 – elder → Elder
- Interlude.kt:67 – The door bell rings. → The bell above the door rings.
- Interlude.kt:87 – → „The altar has looked bare since the Sun Amulet went missing.“
- Interlude.kt:118 – It turns its back on you. → Its back is turned to you.
- Interlude.kt:145–147 – None wants to be first. → No one wants to go first. / Too many for a single mistake. → Too many to risk a single mistake. / They wait for one to strike. → They wait for one of them to strike first.
- Interlude.kt:228 – → „Longer than your arm, it wriggles out of a crack.“
- Interlude.kt:256 – → „A yellow mass creeps toward you; the stone beneath it hisses.“
- Interlude.kt:282 – He has time. → He is in no hurry.
- Interlude.kt:327 – → „Whoever empties a mug with me pays. Whoever weeps with me does not.“
- Interlude.kt:345 – → „Whoever sows will reap, if he's allowed.“
- Intro.kt:56 – nothing more → that's all you want
- Intro.kt:58 – A late prayer → A late service
- Intro.kt:60 – → „A light still burns at the Sleeping Griffin. The innkeeper doesn't ask many questions.“
- Jobs.kt:47 – Winter comes early → Winter is coming early
- Jobs.kt:58 – Bring me the ring at least. → At least bring me the ring.
- Jobs.kt:60 – a healing potion → a Potion of Healing
- Jobs.kt:63 – That's it. → That's the one.
- Jobs.kt:69 (und Folgezeile) – grip plates → handle scales
- Jobs.kt:93 – → „It isn't goblins; they shun the stones.“; I may not leave → I'm not allowed to leave
- Jobs.kt:97 – → „There was no one left at the standing stones. Only cold ash, …“
- Jobs.kt:98 – guardroom, it's more use → guardroom; it's more use
- MapPeople.kt:26 – keeps the Sleeping Griffin → innkeeper at the Sleeping Griffin
- Game.kt:1027 – Colourful → Colorful
- Game.kt:1036 – sooty kettle → sooty pot
- Game.kt:1043 – empty holder → empty mount
- Game.kt:1086 – Guard Jorin → Jorin the guard
- Game.kt:1479 – ... → …

**Regeln, Gegenstände, Werte**
- I18n.kt:42–43 – Safety questions: On/Off → Confirmations: On/Off (ebenso MenuSigns.kt:202 Confirm → Confirmations)
- I18n.kt:80 – Proficiency → Proficiency Bonus (wenn Platz)
- I18n.kt:85 – Abilities → Skills
- I18n.kt:90 – Hit die → Hit Die
- I18n.kt:102 – Your HP are already full. → Your HP is already full.
- I18n.kt:128 – gather loot in six rarities → gather loot of six rarity tiers; carry the Chronicles of Bornim onward → continue the Chronicles of Bornim
- Gear.kt:24–25 – Off hand → Off-hand
- Gear.kt:104, MenuScreen.kt:880 – Critical from {n} → Critical on {n}–20
- Items.kt:39–43 – Greater Healing Potion → Potion of Greater Healing; Superior Healing Potion → Potion of Superior Healing
- Light.kt:43 – lightspark → Lightspark; Light.kt:50 – You drink the flask. → You drain the vial.
- MonsterKit.kt:36 – Hand Axe → Handaxe
- Monsters.kt:37 – Burning → Glowing (DE „Glühend“)
- Rules.kt:106 – → „Humans have a little talent for everything.“
- Rules.kt:107 – +1 to all abilities → +1 to all ability scores
- Rules.kt:241 – „from level 5 on each round“: Tom nennt die Regel, Homer formuliert (unklar, was gemeint ist)
- Resting.kt:54 – → „Full stamina, regain a quarter of your HP“
- Resting.kt:63 – Go on → Continue
- Resting.kt:89 – the breath lasts twice as long → your stamina lasts twice as long
- Resting.kt:90 – → „The stamina draught lasts until your next rest.“
- Appearance.kt:17 – Strong → Sturdy (Körperbau); Appearance.kt:50 – Grey-green → Gray-green
- Perks.kt:81, :87 – Hit and damage with … → Attack and damage rolls with …
- Perks.kt:82 – knocked down → knocked prone
- Perks.kt:86 – Armor class → Armor Class
- Perks.kt:99–100 – → „At INT 12 or higher, you recognize …“ (recognise → recognize)
- Perks.kt:105 – spell DC, healing and spiritual weapon → spell save DC, healing and Spiritual Weapon
- Perks.kt:112–113 – → „buy for $buy% less and sell for $buy% more“ / „buy for ${-buy}% more and sell for ${-buy}% less“
- MenuScreen.kt:598 – → „Maximum level for Chapter 1 reached. No more XP this chapter; fights still pay off in loot and gear.“
- MenuScreen.kt:607 – Spell DC → Spell save DC
- GearCompare.kt:39 – → „Adds nothing you don't already have.“
- CreateScreen.kt:187 – Assign abilities → Assign ability scores
- CreateScreen.kt:197 – → „… before racial bonus. Higher scores cost more …“

**Kampf (MARS, Klassisch, Meldungen)**
- Battle.kt:1151 – A wild {0} appears! → Look out! {0} appears!
- Battle.kt:1156 – It missed! → Miss!
- Battle.kt:1174–1175 – {0} got away safely! → {0} escaped! / Couldn't get away! → The escape fails!
- Battle.kt:1189 – lean hard on the weapon → lean hard on their weapon
- Battle.kt:1191, 1192, 1198, 1239 – „...“ bzw. „ …“ → „…“
- Battle.kt:1200 – gained → gains; :1201 recognises → recognizes
- Battle.kt:1205 – → „Level cap for Chapter 1 reached“
- Battle.kt:1206 – You got {0} gold. → You loot {0} gold.
- Battle.kt:1212 – → „{0} is still caught off guard and can't react!“
- Battle.kt:1231 – Dwarven resilience → Dwarven Resilience
- Battle.kt:1250 – {0} grew to level {1}! → {0} reaches level {1}!
- MarsRules.kt:37 – practise → practice; :42 Likewise → Conversely; :45 The foe announces. → The foe calls its move.; :46 recognise → recognize; :69 falls on them → is drawn to them
- MarsRules.kt:73, MarsTips.kt:29 – meets the ring with good, never perfect → hits the ring well, never perfectly; life points → HP
- MarsRules.kt:77 – rolls for the order → rolls initiative
- MarsTips.kt:32 – Light fights only → Easy fights only; without pictures, on automatic → without animation, on Autopilot; → „At 7+ levels apart, half damage; at 10+, none.“
- MarsTips.kt:41–63 – Guard → Cover; Helps: → Counter:; life points → HP; heals 2d10 → regains 2d10 HP; runs round → runs around; changes places / swap / change of place → switches rows / switch / change of row; Cast web → Throw web; goes on the defensive → Defends; any hit before → any hit beforehand
- MarsTips.kt:69 – → „He's winding up too wide. If I hit him hard now, he'll lose his rhythm.“
- MarsTips.kt:71 – or he stands whole again → or he'll be back at full strength
- MarsTips.kt:75 – → „If you're not there, it can't hit you.“
- MarsTips.kt:84 – → „… tap when it lies exactly on it. Just off: half damage; exact: no damage at all.“
- Skirmish.kt:132 – Cast web → Shoot web
- Skirmish.kt:482 – life points → HP; :484 Strong intent announced. → Strong attack announced.
- Skirmish.kt:1279 – waits on guard → stays on guard; :1290 Reinforcement: → Reinforcements:
- Skirmish.kt:1299 – stands before the others → steps in front of the others; :1302 the guard is open → their guard is open
- Skirmish.kt:1313 (und Folgezeile) – {0} drinks a {1} → {0} drinks {1}
- Skirmish.kt:1319–1320 – half catches the blow → partly blocks the blow; turns the blow half aside → partly deflects the blow
- Skirmish.kt:1333 – → „The next arrow could come from anywhere.“
- Skirmish.kt:1344 – driven to the knees → driven to their knees
- Skirmish.kt:1362 – smouldering → smoldering
- Skirmish.kt:1402–1405 – mark → target
- Packs.kt:34, :52 – from behind → from the back ranks; :44 snaps! → snaps at you!; :62 → „One of the bodyguard wolves bites!“
- SkirmishScreen.kt:625 – leap from the coil → leap from a crouch
- SkirmishScreen.kt:763 – Quick stops: below a third of life points → Quick stopped: below a third of HP
- SkirmishScreen.kt:1379 – whole log → full log; :1399 Light fight → Easy fight
- SkirmishScreen.kt:1936 – made / failed → success / failure

**Menüs und Einstellungen**
- BoardScreen.kt:74 – Take up / Taken → Accept / Accepted; :96 Odd jobs → Side quests
- ChronicleTab.kt:47 – So far → Story so far; :71 Main task → Main quest; :85 Odd jobs → Side quests; :96 Ready to hand in – to X → Ready to turn in to X
- GearUi.kt:231, ShopScreen.kt:171 – Worn → Equipped
- ShopScreen.kt:259, :268 – commons → common items; :336 Amount → Quantity
- IntroScreen.kt:160 – → „This ends the cutscene; you can watch it again in the Chronicle.“
- MenuSigns.kt:185 – → „Opens the MARS battle system rules for reference.“; :189 Fight → Combat; :193 By itself → Auto; :197 → „How fast turns and text play out in battle.“; :200 → „… or advance automatically after a pause for reading.“; :207 Handling → Input
- MenuSigns.kt:215 – → „Inside the ring you walk; beyond it you run. Fine: small ring. Calm: large ring.“; :218 → „Button: adds a separate run button.“
- MenuSigns.kt:225–226 – Nearer → Close; → „Map zoom. Close shows less of your surroundings, but larger.“; :228 a way is blocked → a path is blocked
- SoundSettings.kt:47 – Effects and places → Effects and ambience; :49 Dark tones → Shadows; :51 → „Adjust until the sign is barely visible.“
- Testreiter (TestTab.kt, nur Tester): :58/:60 Veil → Fade; :67 Slow pictures → Slow frames; :71 then → afterwards; :125 → „Potions, flasks, food and ingredients refilled; two torches and a smoke bundle added.“; :165 Rain: chance → Rain: random; :196 → „… every monster on the map is visible. Exploration works as usual.“; :263 Hide monsters → Hide monster list; :293 kit → gear; :311 → „Hero and mercenary level:“; :346 Hide device → Hide device info; :364 → „Last app exit:“

**Danach:** alle übrigen UK-Formen und „...“ nach Regel 1 und 4 per Suche angleichen (grey, colour, towards, any more, traveller, dreamt, round, Ellipsen in Story.kt 451–784). Offene Kleinigkeiten aus Toms Bestand (Vergleichssatz `GearCompare`, leerer Menütext, Absturzbericht und Geräteinfo nur deutsch) bleiben bei Tom.
