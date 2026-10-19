# Spieltexte: Kampf, Rast, Zustände

Texte, die in allen Kapiteln gelten und nicht zur Blende gehören (Regeln in `STORY-REGELN.md`). Höchstens etwa 15 KB.

## Kampfmeldungen MARS (72.10a.T, mit 72.10)

Zeilen im Kampfprotokoll (`Skirmish.kt` `Msg72`). Knapp, Gegenwart, ohne Ausrufezeichen außer beim Gegnerzug. Punkte immer „TP“ (wie Rast, Regeln, Leiste), nie „Lebenspunkte“. Trankname ohne Artikel in Klammern, weil „Großer Heiltrank“ sich sonst beugen müsste.

`[72.10a.T.zauber]` (Zauber, Kosten ZP oder Zaubertrick: Magier, Kleriker)
{0} wirkt {1}.
EN: {0} casts {1}.

`[72.10a.T.faehigkeit]` (Fähigkeit ohne Zauber: Kämpfer, Schurke, z. B. Zweiter Atem, Tatendrang, Finte)
{0} setzt {1} ein.
EN: {0} uses {1}.

`[72.10a.T.segen]` (Segnen)
{0} ist gesegnet.
EN: {0} is blessed.

`[72.10a.T.entgeht]` (Rettungswurf geschafft, Zauber ohne halben Schaden, z. B. Heilige Flamme)
{0} entgeht dem Zauber.
EN: {0} escapes the spell.

`[72.10a.T.heilt]` (heilt einen anderen)
{0} heilt {1}: +{2} TP.
EN: {0} heals {1}: +{2} HP.

`[72.10a.T.heiltsich]` (heilt sich selbst)
{0} heilt sich: +{1} TP.
EN: {0} heals: +{1} HP.

`[72.10a.T.trinkt]` (Trank selbst)
{0} trinkt ({1}): +{2} TP.
EN: {0} drinks a {1}: +{2} HP.

`[72.10a.T.reicht]` (Trank an einen Verbündeten)
{0} reicht {1} einen Trank ({2}): +{3} TP.
EN: {0} hands {1} a {2}: +{3} HP.

`[72.10a.T.keinezp]` (Zauber, zu wenig ZP)
Nicht genug Zauberpunkte.
EN: Not enough spell points.

`[72.10a.T.kampf]` (einmal pro Kampf, schon genutzt)
In diesem Kampf schon genutzt.
EN: Already used in this fight.

`[72.10a.T.rast]` (einmal pro Rast, z. B. Tatendrang)
Erst nach einer Rast wieder.
EN: Not again until you rest.

`[72.10a.T.wurf]` (Angriffswurf am Ziel; Abzug als „12 − 1“, nie „12 + -1“; bei 20 statt „Treffer“ „kritisch“)
{w} + {b} = {s} gegen RK {rk} · Treffer / daneben / kritisch
EN: {w} + {b} = {s} vs AC {rk} · hit / miss / critical

`[72.10a.T.rw]` (Rettungswurf des Ziels; Vorsilbe zeigt, dass das Ziel würfelt)
RW {w} + {b} = {s} gegen SG {sg} · geschafft / misslungen
EN: Save {w} + {b} = {s} vs DC {sg} · made / failed

Aus 72.10 geändert (übrige Platzhalter bleiben wortgleich):

`[72.10.ansetzen]` (Gegner zeigt Absicht) {0} setzt an: {1}. / EN: {0} readies: {1}.

`[72.10.bewusstlos]` {0} sinkt bewusstlos zu Boden. / EN: {0} sinks to the ground, unconscious.

`[72.10.kraft]` {0} sammelt Kraft: +{1} TP. / EN: {0} gathers strength: +{1} HP.

`[72.10.herbei]` (statt „Ein {0}“, passt für jedes Geschlecht) Verstärkung: {0} eilt herbei. / EN: Reinforcement: {0} comes running.

`[72.10.taumelt]` {0} taumelt: {1} vereitelt. / EN: {0} staggers: {1} foiled.

## Gegner mit Absichten (130.3, MARS)

Vier Gegner, je zwei Absichten; jede verlangt eine andere Antwort, damit keine Taste immer richtig ist. Je Absicht: **Name** (für `{1}` in „{0} kündigt an: {1}.“), **Zeichen** (eine Zeile direkt danach: was man sieht), **Folge** (wenn die Antwort sitzt bzw. die Absicht wirkt). Die Spalte „Antwort“ ist Homers Vorschlag für den Bau; Zahlen und Balance entscheidet der Chef.

| Gegner | Absicht | Antwort |
|---|---|---|
| Grak | Schwerer Hieb · Rudel rufen · Kraft sammeln | abwarten und den Ring treffen, oder vorher hart zuschlagen · Anführer treffen · angreifen |
| Wolf (zu zweit oder dritt) | Anspringen · Einkreisen | Platz tauschen · den Leitwolf treffen |
| Riesenspinne (hintere Reihe) | Gift sammeln · Netz werfen | angreifen, bevor es wirkt · ausweichen (Ring) |
| Goblin-Späher (hintere Reihe) | Anlegen · In den Schatten | abwarten (ducken) · jetzt angreifen |

**Grak** (Name und Werte bleiben, nur Zeichen neu)

`[130.3.grak.hieb]` Zeichen: Er reißt die Keule hinter den Kopf. / EN: He hauls the club back behind his head.
`[130.3.grak.rudel]` Zeichen: Er stampft, brüllt in den Wald. Irgendwo antwortet Kreischen. / EN: He stamps and roars into the woods. Somewhere, shrieks answer.
`[130.3.grak.kraft]` Zeichen: Er weicht zurück und atmet schwer, die Narben glühen. / EN: He falls back, breathing hard, his scars aglow.

**Wolf**

`[130.3.wolf.sprung]` Name: Anspringen (auf {2}) / EN: Pounce (at {2}). Zeichen: Er duckt sich flach, die Augen auf {2}. / EN: He crouches low, eyes on {2}.
`[130.3.wolf.sprung.leer]` (Ziel hat den Platz getauscht) Der Sprung geht ins Leere. / EN: The pounce lands on nothing.
`[130.3.wolf.sprung.um]` (trifft) {0} reißt {1} zu Boden. / EN: {0} drags {1} to the ground.
`[130.3.wolf.kreis]` Name: Einkreisen / EN: Circle. Zeichen: Die Wölfe ziehen auseinander, einer bleibt zurück und knurrt. / EN: The wolves spread out; one hangs back, growling.
`[130.3.wolf.leit]` (Name des zurückbleibenden Wolfs) Leitwolf / EN: Pack leader
`[130.3.wolf.kreis.zu]` (wirkt) Der Kreis schließt sich. Die Wölfe greifen gemeinsam an. / EN: The circle closes. The wolves strike together.
`[130.3.wolf.kreis.auf]` (Leitwolf getroffen) Der Leitwolf jault. Das Rudel zögert. / EN: The pack leader yelps. The pack hesitates.

**Riesenspinne**

`[130.3.spinne.gift]` Name: Gift sammeln / EN: Gather venom. Zeichen: Gift tropft von ihren Kieferklauen, sie zielt auf {2}. / EN: Venom drips from her fangs; she takes aim at {2}.
`[130.3.spinne.gift.los]` (wirkt) Ein Strahl Gift trifft {1}. / EN: A jet of venom strikes {1}.
`[130.3.spinne.gift.weg]` (vorher hart getroffen) Sie zuckt zusammen, das Gift versickert im Moos. / EN: She flinches; the venom soaks into the moss.
`[130.3.spinne.netz]` Name: Netz werfen / EN: Cast web. Zeichen: Sie hebt den Hinterleib, ein Faden spannt sich. / EN: She raises her abdomen; a thread pulls taut.
`[130.3.spinne.netz.fest]` (trifft) {1} hängt im Netz fest und verliert den nächsten Zug. / EN: {1} is caught in the web and loses the next turn.

**Goblin-Späher**

`[130.3.spaeher.anlegen]` Name: Anlegen (auf {2}) / EN: Take aim (at {2}). Zeichen: Die Sehne knarrt. Die Pfeilspitze sucht {2}. / EN: The bowstring creaks. The arrowhead seeks {2}.
`[130.3.spaeher.duckt]` (Ziel wartet ab) {1} duckt sich, der Pfeil schlägt ins Holz. / EN: {1} ducks; the arrow thuds into wood.
`[130.3.spaeher.schatten]` Name: In den Schatten / EN: Into the shadows. Zeichen: Er huscht zurück, zwischen die Bäume. / EN: He slips back between the trees.
`[130.3.spaeher.weg]` (nicht angegriffen) Er ist verschwunden. Der nächste Pfeil kommt von irgendwo. / EN: He is gone. The next arrow comes from somewhere.

Platzhalter: {0} Gegner, {1} getroffene Figur, {2} angepeilte Figur.

## Absichten gegen die Aufstellung (72.10a.8, MARS)

Ersetzt den vorläufigen Wortlaut in `Skirmish.kt` (`Msg72.breaksThrough`, `braced`, `flankEmpty`); die Namen „Durchbrechen“ und „Flanke“ bleiben. Zeichen wie bei 130.3 direkt nach der Ankündigung.

`[72.10a.8.bruch]` Zeichen (Grak, Durchbrechen): Er senkt die Schulter. Sein Blick geht an der vorderen Reihe vorbei, zu {2}. / EN: He lowers his shoulder. His eyes slide past the front row to {2}.
`[72.10a.8.flanke]` Zeichen (Goblin, Flanke): Er löst sich aus der Reihe und schleicht seitlich auf {2} zu. / EN: He slips out of the line and creeps sideways toward {2}.
`[72.10a.8.bruch.durch]` (wirkt; {1} ist die nach hinten gestoßene Figur) {0} bricht durch und stößt {1} nach hinten. / EN: {0} breaks through and shoves {1} back.
`[72.10a.8.bruch.vorn]` (Ziel ist selbst vorgetreten; danach der gewöhnliche Schlag) {1} stellt sich {0} vorn entgegen. Kein Durchkommen. / EN: {1} meets {0} at the front. No way through.
`[72.10a.8.flanke.leer]` (Ziel hat den Platz getauscht) {0} schleicht um die Reihe, doch {1} ist nicht mehr dort. / EN: {0} creeps round the line, but {1} is gone.
`[72.10a.8.halb]` (Zusatz am Zug nach dem Tausch) · halber Zug / EN: · half a turn

## Rolle je Klasse (72.10a.9, MARS)

Ersetzt den vorläufigen Wortlaut in `Skirmish.kt` (`Msg72.covers`, `strikesBack`, `stepsBehind`, `prays`). Ohne „er“ oder „ihn“, weil {0} jede Figur sein kann.

`[72.10a.9.decken]` Taste (Kämpfer) Decken / EN: Cover
`[72.10a.9.deckt]` {0} stellt sich vor die anderen und zieht jeden Schlag auf sich. / EN: {0} stands before the others and draws every blow.
`[72.10a.9.zurueck]` (Kämpfer, Ring perfekt) {0} fängt den Schlag ab und schlägt zurück. / EN: {0} catches the blow and strikes back.
`[72.10a.9.ruecken]` (Schurke, perfekt) {0} gleitet {1} in den Rücken: der nächste Schlag hat Vorteil. / EN: {0} slips behind {1}: the next blow has advantage.
`[72.10a.9.gebet]` (Kleriker, perfekt; danach die Heilmeldung) {0} murmelt ein Gebet. / EN: {0} murmurs a prayer.

## Zweitwaffe (72.10a.11, MARS)

Ersetzt `Msg72.draws`; {1} ist der Waffenname ohne Artikel.

`[72.10a.11.wechsel]` {0} wechselt die Waffe: {1}. / EN: {0} switches weapons: {1}.
`[72.10a.11.knopf]` (Knopf unter „Platz“) Waffe: {Waffenname} / EN: Weapon: {weapon}
`[72.10a.11.platz]` (Zusatz beim Platz) hinten + {Waffenname} / EN: back + {weapon}

## Regelseite MARS (201T, Chef 19.10.)

Scrollbare Seite beim Start des MARS-Probekampfs aus dem Systemmenü. Je Marke ein Absatz, Überschriften fett. Absätze mit „(ab .8)“, „(ab .9)“, „(ab .11)“ nur, wenn der Bau im selben Build steckt, sonst den Satz in Klammern weglassen. Unten eine Taste.

`[201.titel]` MARS – Probekampf / EN: MARS – Trial fight

`[201.vorweg]` Ein neues Kampfsystem, noch im Bau. Dein Held und ein Söldner kämpfen gegen eine kleine Gruppe, beide auf Stufe 3. Dein Held und deine Tasche bleiben, wie sie sind: hier geht nichts verloren und nichts wird gewonnen.
EN: A new combat system, still being built. Your hero and a Söldner fight a small group, both at level 3. Your hero and your bag stay as they are: nothing is lost here, and nothing is won.

`[201.reihen]` **Zwei Reihen.** Jede Seite steht in zwei Reihen. Nahkampf erreicht nur die vordere Reihe, solange dort jemand steht; Fernkampf und Zauber erreichen jeden. Wer hinten steht, ist gedeckt, solange vorn ein Freund steht: Angriffe auf ihn haben Nachteil. Wer von vorn mit Bogen oder Armbrust auf die vordere Reihe schießt, hat ebenfalls Nachteil.
EN: **Two rows.** Each side stands in two rows. Melee reaches only the front row while anyone stands there; ranged attacks and spells reach everyone. Whoever stands at the back is covered while a friend stands in front: attacks on them have disadvantage. Shooting a bow or crossbow from the front row at the front row has disadvantage too.

`[201.absicht]` **Der Gegner sagt an.** Jeder Gegner kündigt seinen nächsten Zug an: was er vorhat, gegen wen, und ein Zeichen, woran du es erkennst. Rot heißt: das wird wehtun. Ein harter Treffer vor seinem Zug vereitelt manche Absicht. Andere verlangen eine andere Antwort: den Platz wechseln, abwarten, schnell zuschlagen. Lies die Zeichen.
EN: **The foe announces.** Every foe announces its next move: what it intends, against whom, and a sign to recognise it by. Red means: this will hurt. A hard hit before its turn foils some intents. Others ask for a different answer: change places, wait, strike fast. Read the signs.

`[201.ring]` **Der Ring.** Trifft eine angekündigte Absicht deine Figur, zieht sich ein Ring um sie zusammen. Tippe, wenn er sich schließt. Gut: halber Schaden. Perfekt: ganz ausgewichen. Kleine Schläge ohne Ansage kommen ohne Ring.
EN: **The ring.** When an announced intent strikes one of your figures, a ring closes around it. Tap as it closes. Good: half damage. Perfect: no damage at all. Small blows without an announcement come without a ring.

`[201.klassen]` (ab .9) **Perfekt je Klasse.** Der Kämpfer schlägt zurück, der Schurke gleitet dem Gegner in den Rücken, der Kleriker heilt mit einem Gebet.
EN: **Perfect, by class.** The fighter strikes back, the rogue slips behind the foe, the cleric heals with a prayer.

`[201.zug]` **Dein Zug.** Angriff mit der Waffe. Können: Zauber und Fähigkeiten; ein Feuerball trifft eine ganze Reihe, Heilung jeden Freund. Tasche: Heiltränke aus einem gemeinsamen Vorrat, für dich oder einen Freund. Platz: mit einem Freund tauschen oder auf einen freien Platz gehen. Abwarten. Die Leiste oben zeigt, wer als Nächstes dran ist. Jeder Wurf zeigt kurz am Ziel seine Zahlen.
EN: **Your turn.** Attack with your weapon. Skills: spells and abilities; a fireball strikes a whole row, healing reaches any friend. Bag: healing potions from a shared stock, for you or a friend. Place: swap with a friend or move to a free place. Wait. The bar at the top shows who acts next. Every roll briefly shows its numbers at the target.

`[201.halb]` (ab .8; mit .11 den zweiten Satz dazu) Ein Platztausch kostet nur einen halben Zug, danach bleibt noch ein Schlag. (ab .11) Unter „Platz“ wechselst du auch die Waffe, Nahkampf oder Fern, ebenfalls für einen halben Zug.
EN: A swap costs only half a turn; one blow remains after it. Under "Place" you can also switch weapons, melee or ranged, likewise for half a turn.

`[201.decken]` (ab .9) Der Kämpfer kann **Decken**: einen Zug lang zieht er jeden angekündigten Schlag auf sich.
EN: The fighter can **Cover**: for one turn, every announced blow falls on them.

`[201.auto]` **Automatik.** Der Söldner kämpft auf Wunsch selbst, sonst steuerst du ihn. Die Automatik spielt auch deinen Helden: Waffe, Zaubertricks, Heilung, wenn ein Freund schwach ist; den Ring trifft sie immer gut, nie perfekt. Sie hält an, wenn dein Held unter ein Drittel seiner Lebenspunkte fällt oder ein Gegner etwas Starkes ansagt, und gegen Bosse läuft sie nie.
EN: **Autopilot.** The Söldner can fight on their own, or you steer them. The autopilot can play your hero too: weapon, cantrips, healing when a friend is weak; it always meets the ring with good, never perfect. It stops when your hero drops below a third of their life points or a foe announces something strong, and it never runs against bosses.

`[201.fallen]` **Wer fällt.** Ein Söldner, der fällt, ist bewusstlos, nicht tot. Wer außer Atem in den Kampf geht, würfelt die Reihenfolge mit Nachteil.
EN: **Who falls.** A Söldner who falls is unconscious, not dead. Whoever enters the fight out of breath rolls for the order with disadvantage.

`[201.feedback]` Grak, Wölfe, Spinne, Späher: jeder Gegner verlangt eine andere Antwort. Sag uns, was sich gut anfühlt und was nicht.
EN: Grak, wolves, spider, scout: each foe asks for a different answer. Tell us what feels good and what doesn't.

`[201.taste]` Zum Kampf / EN: To battle

## Feuerball (72.14)

`[72.14.feuerball]` (Beschreibung `Rules.kt` FIREBALL, ersetzt „Verjagt Begleiter …“)
8W6 Feuerschaden, GES-Rettungswurf halbiert. Verjagt Rudel und Späher des Gegners, die ihren Rettungswurf nicht schaffen. Einmal pro Kampf.
EN: 8d6 fire damage, DEX save for half. Drives off the foe's pack and scouts that fail their save. Once per battle.

## Rast, Met, Zimmer (86)

`Resting.kt`; Platzhalter, die hier nicht stehen, bleiben wortgleich.

`[86.kurzwirkt]` Ausdauer voll, ein Viertel der TP zurück / EN: Stamina full, a quarter of HP back

`[86.langwirkt]` TP, ZP und Ausdauer voll, Zustände geheilt / EN: HP, SP and stamina full, conditions cured

`[86.zimmerwirkt]` Ein Bett für die Nacht: lange Rast / EN: A bed for the night: long rest

`[86.kurzfertig]` Eine Stunde Ruhe. Die Ausdauer ist voll, +{0} TP. / EN: An hour of rest. Your stamina is full, +{0} HP.

`[86.langfertig]` Acht Stunden Schlaf. TP, ZP und Ausdauer sind voll. / EN: Eight hours of sleep. HP, SP and stamina are full.

`[86.met]` (Met getrunken, noch nicht betrunken) Der Met wärmt. Die Ausdauer ist voll. / EN: The mead warms you. Your stamina is full.

`[86.metzuviel]` (der Met, der betrunken macht) Ein Met zu viel. Du bist betrunken bis zur nächsten Rast. / EN: One mead too many. You are drunk until your next rest.

`[86.rowena.met]` (Rowena, wenn das Feld „Schänke“ aufgeht; Wechsel mit `[86.rowena.zimmer]`)
Ein Met wärmt die Beine. Nach dem vierten findest du die Tür aber nicht mehr.
EN: A mead warms the legs. After the fourth, though, you won't find the door.

`[86.rowena.zimmer]`
Oben ist ein Zimmer frei. Frische Laken, und keiner schnarcht durch die Wand. Meistens.
EN: There's a room free upstairs. Fresh sheets, and nobody snores through the wall. Mostly.

`[86.rowena.genug]` (Held betrunken)
Genug für heute, {name}. Geh schlafen, die Treppe ist links.
EN: Enough for today, {name}. Go to bed, the stairs are on the left.

## Zustände außerhalb des Kampfs (86.9)

Wie die übrigen Zustände in `Status.kt` (Name, Kurzwort, Text), Zeichen in der oberen Leiste und im Kampf. Nicht „Vergiftet“ nennen: „Vergiftet“ heißt im Spiel Schaden jede Runde, das trifft hier nicht zu.

`[86.9.betrunken]` Betrunken · Kurz: Betrunken (Zustand, nicht Ursache; Chef 18.10.) · Angriffe und Flucht mit Nachteil, bis zur nächsten Rast.
EN: Drunk · Short: Drunk · Attacks and fleeing at a disadvantage, until your next rest.

`[86.9.atem]` (Kampfzeile, wenn der Held außer Atem in den Kampf kommt) {0} ist außer Atem: Initiative mit Nachteil.
EN: {0} is out of breath: initiative at a disadvantage.

## Licht: Fackel und Leuchtfunke (84.1, 84.5)

`Light.kt`, `Items.kt`, `Gear.kt`. Du-Form wie bei der Rast. Fackel und Funke ändern nur im Dunkeln etwas; Meldungen zur Fackel darum nur im Dunkeln (Nacht draußen, immer in der Höhle).

`[84.1.name]` Fackel / EN: Torch (bleibt)

`[84.1.laden]` (Beschreibung im Laden und in der Ausrüstung) Pech und Werg auf einem Stock. In der Nebenhand, statt eines Schilds. Im Dunkeln siehst du weiter als mit einem Leuchtfunken. Brennt, solange du sie trägst.
EN: Pitch and tow on a stick. Held in the off hand, instead of a shield. In the dark you see further than with a lightspark. Burns as long as you carry it.

`[84.1.an]` (Fackel in die Nebenhand gelegt, im Dunkeln) Du zündest die Fackel an.
EN: You light the torch.

`[84.1.aus]` (Fackel abgelegt, im Dunkeln) Du drückst die Fackel aus. Das Dunkel rückt heran.
EN: You snuff out the torch. The dark closes in.

`[84.5.name]` Leuchtfunke / EN: Lightspark (bleibt)

`[84.5.laden]` (Beschreibung im Laden und im Beutel) Ein Fläschchen, von Morwen gebraut. Getrunken steigt ein Funke auf und leuchtet über dir bis zur nächsten Rast. Im Dunkeln siehst du weiter, aber Monster bemerken dich früher. Nicht im Kampf.
EN: A flask brewed by Morwen. Drink it, and a spark rises to glow above you until your next rest. In the dark you see further, but monsters notice you sooner. Not in battle.

`[84.5.trinken]` Du trinkst das Fläschchen. Ein Funke steigt auf und bleibt über deinem Kopf stehen.
EN: You drink the flask. A spark rises and settles above your head.

`[84.5.schon]` (Funke leuchtet schon; nichts verbraucht) Dein Funke leuchtet noch.
EN: Your spark is still glowing.

`[84.5.taste]` (Taste in der Zeile „Leuchtfunke“ im Beutel) Löschen
EN: Put out

`[84.5.aus]` (nach der Taste) Der Funke verglimmt. Weg ist weg.
EN: The spark fades. Gone is gone.

`[84.5.rast]` (nach einer Rast, nur wenn der Funke brannte; hinter die Meldung der Rast; nach einem Morgen in einer Szene als erste Zeile nach dem Aufwachen, vor jeder Rede, 84.1T.1) Dein Funke ist verglommen.
EN: Your spark has faded.
