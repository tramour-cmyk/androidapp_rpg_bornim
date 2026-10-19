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

`[203.abwehr]` {0} geht in Abwehrhaltung. / EN: {0} takes a defensive stance. (wie im alten Kampf, 203)

## Gegner mit Absichten (130.3, MARS)

Vier Gegner, je zwei Absichten; jede verlangt eine andere Antwort, damit keine Taste immer richtig ist. Je Absicht: **Name** (für `{1}` in „{0} kündigt an: {1}.“), **Zeichen** (eine Zeile direkt danach: was man sieht), **Folge** (wenn die Antwort sitzt bzw. die Absicht wirkt). Die Spalte „Antwort“ ist Homers Vorschlag für den Bau; Zahlen und Balance entscheidet der Chef.

| Gegner | Absicht | Antwort |
|---|---|---|
| Grak | Schwerer Hieb · Rudel rufen · Kraft sammeln | Abwehr und den Ring treffen, oder vorher hart zuschlagen · Anführer treffen · angreifen |
| Wolf (zu zweit oder dritt) | Anspringen · Einkreisen | Platz tauschen · den Leitwolf treffen |
| Riesenspinne (hintere Reihe) | Gift sammeln · Netz werfen | angreifen, bevor es wirkt · ausweichen (Ring) |
| Goblin-Späher (hintere Reihe) | Anlegen · In den Schatten | Abwehr (ducken) · jetzt angreifen |

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
`[130.3.spaeher.duckt]` (Ziel in Abwehr) {1} duckt sich, der Pfeil schlägt ins Holz. / EN: {1} ducks; the arrow thuds into wood.
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

Ersetzt den vorläufigen Wortlaut in `Skirmish.kt` (`Msg72.covers`, `strikesBack`, `stepsBehind`, `prays`, `flamesBack`). Ohne „er“ oder „ihn“, weil {0} jede Figur sein kann.

`[72.10a.9.decken]` Taste (Kämpfer) Decken / EN: Cover
`[72.10a.9.deckt]` {0} stellt sich vor die anderen und zieht jeden Schlag auf sich. / EN: {0} stands before the others and draws every blow.
`[72.10a.9.zurueck]` (Kämpfer, Ring perfekt) {0} fängt den Schlag ab und schlägt zurück. / EN: {0} catches the blow and strikes back.
`[72.10a.9.ruecken]` (Schurke, perfekt) {0} gleitet {1} in den Rücken: der nächste Schlag hat Vorteil. / EN: {0} slips behind {1}: the next blow has advantage.
`[72.10a.9.gebet]` (Kleriker, perfekt; danach die Heilmeldung) {0} murmelt ein Gebet. / EN: {0} murmurs a prayer.
`[72.10a.9.feuer]` (Magier, perfekt, 219.3T; {1} ist der Angreifer; danach die Schadensmeldung) {0} weicht aus und schleudert {1} einen Feuerpfeil entgegen. / EN: {0} dodges and hurls a fire bolt back at {1}.

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

`[201.absicht]` **Der Gegner sagt an.** Jeder Gegner kündigt seinen nächsten Zug an: was er vorhat, gegen wen, und ein Zeichen, woran du es erkennst. Rot heißt: das wird wehtun. Ein harter Treffer vor seinem Zug vereitelt manche Absicht. Andere verlangen eine andere Antwort: den Platz wechseln, in Abwehr gehen, schnell zuschlagen. Lies die Zeichen.
EN: **The foe announces.** Every foe announces its next move: what it intends, against whom, and a sign to recognise it by. Red means: this will hurt. A hard hit before its turn foils some intents. Others ask for a different answer: change places, defend, strike fast. Read the signs.

`[201.ring]` **Der Ring.** Trägt eine Ansage das Zeichen ◯, zieht sich beim Schlag ein Ring um die getroffene Figur zusammen. Tippe, wenn er sich schließt. Gut: halber Schaden. Perfekt: ganz ausgewichen, und deine Klasse antwortet. Alles andere kommt ohne Ring. (geändert 219T)
EN: **The ring.** When an announcement carries the sign ◯, a ring closes around the figure it strikes. Tap as it closes. Good: half damage. Perfect: no damage at all, and your class answers. Everything else comes without a ring.

`[201.klassen]` (ab .9) **Perfekt je Klasse.** Der Kämpfer schlägt zurück, der Schurke gleitet dem Gegner in den Rücken, der Kleriker heilt mit einem Gebet.
EN: **Perfect, by class.** The fighter strikes back, the rogue slips behind the foe, the cleric heals with a prayer.

`[201.zug]` **Dein Zug.** Angriff mit der Waffe. Können: Zauber und Fähigkeiten; Heilung erreicht jeden Freund. Tasche: Heiltränke aus einem gemeinsamen Vorrat, für dich oder einen Freund. Platz: mit einem Freund tauschen oder auf einen freien Platz gehen. Abwehr: bis zu deinem nächsten Zug haben Angriffe auf dich Nachteil. Die Leiste oben zeigt, wer als Nächstes dran ist. Jeder Wurf zeigt kurz am Ziel seine Zahlen.
EN: **Your turn.** Attack with your weapon. Skills: spells and abilities; healing reaches any friend. Bag: healing potions from a shared stock, for you or a friend. Place: swap with a friend or move to a free place. Defend: until your next turn, attacks on you have disadvantage. The bar at the top shows who acts next. Every roll briefly shows its numbers at the target.

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

## Tiptexte MARS (204T, Chef 19.10.)

Bei langem Druck auf einen Knopf. Fähigkeiten und Gegenstände zeigen ihre Beschreibung aus `Rules.kt` bzw. `Items.kt`; dahinter, nur wo angegeben, ein Zusatz für MARS. „Abwarten“ heißt seit 203 „Abwehr“ (SRD Ausweichen).

`[204T.angriff]` Ein Schlag oder Schuss mit der Waffe. Nahkampf erreicht nur die vordere Reihe, solange dort jemand steht.
EN: One blow or shot with your weapon. Melee reaches only the front row while anyone stands there.

`[204T.koennen]` Zauber und Fähigkeiten deiner Klasse. Zauber kosten Zauberpunkte, manches geht nur einmal pro Kampf oder bis zur Rast.
EN: Your class's spells and abilities. Spells cost spell points; some things work only once per battle or until you rest.

`[204T.tasche]` Ein Heiltrank aus dem gemeinsamen Vorrat, für dich oder einen Freund. Kostet den Zug.
EN: A healing potion from the shared stock, for you or a friend. Costs your turn.

`[204T.platz]` Mit einem Freund tauschen oder auf einen freien Platz gehen. Hinten bist du gedeckt, solange vorn ein Freund steht. Kostet den Zug.
EN: Swap with a friend or move to a free place. At the back you are covered while a friend stands in front. Costs your turn.
(ab .8 statt „Kostet den Zug.“:) Ein halber Zug: danach bleibt noch ein Schlag. / EN: Half a turn: one blow remains after it.
(ab .11 dazu:) Hier wechselst du auch die Waffe. / EN: This is also where you switch weapons.

`[204T.abwarten]` (Knopf „Abwehr“, 203) Bis zu deinem nächsten Zug haben Angriffe auf dich Nachteil, Rettungswürfe auf Geschicklichkeit Vorteil. Manchmal ist das die richtige Antwort.
EN: (button “Defend”, 203) Until your next turn, attacks on you have disadvantage and Dexterity saves have advantage. Sometimes that is the right answer.

`[204T.soeldner]` Auto: der Söldner kämpft selbst. Selbst: du gibst ihm jeden Befehl.
EN: Auto: the Söldner fights on their own. Manual: you give every order.

`[204T.automatik]` Spielt deinen Helden: Waffe, Zaubertricks, Heilung für einen schwachen Freund. Fängt den Ring immer gut, nie perfekt. Hält an unter einem Drittel der Lebenspunkte und bei einer starken Absicht; nie gegen Bosse.
EN: Plays your hero: weapon, cantrips, healing for a weak friend. Always meets the ring with good, never perfect. Stops below a third of life points and on a strong intent; never against bosses.

`[204T.decken]` (ab .9, Kämpfer) Einen Zug lang zieht der Kämpfer jeden angekündigten Schlag auf Freunde auf sich. Ring perfekt: Gegenschlag.
EN: For one turn the fighter draws every announced blow aimed at friends. Perfect ring: a counterblow.

Zusätze hinter der Beschreibung (neue Zeile):

`[204T.wunden]` (Wunden heilen) Auch für einen Freund, über alle Reihen. / EN: Also for a friend, across all rows.
`[204T.finte]` (Finte, ab .9) Aus der hinteren Reihe, wenn vorn ein Freund steht: erreicht jeden Gegner ohne Deckung. / EN: From the back row, with a friend in front: reaches any foe without cover.
`[204T.feuerball]` (Feuerball, ab Stufe 5, nicht im Probekampf) Trifft die ganze Reihe des Ziels. / EN: Strikes the target's whole row.
`[204T.trank]` (Heiltrank; die Beschreibung nennt die Heilung nicht) Heilt 2W4+2 TP. / EN: Heals 2d4+2 HP.

Nebenbefund für Jerry: Tatendrang macht in MARS (`Skirmish.useSkill`) auf Stufe 3 zwei Schläge, die Beschreibung verspricht einen (zwei erst ab Stufe 5). Beschreibung oder Code angleichen; Balance entscheidet der Chef.

## Ansagen erklärt (210T, Chef 19.10.)

(A) Bei langem Druck auf die Ansage eines Gegners: Satz 1 sagt, was sie tut, Satz 2, was hilft und was beim Vereiteln bleibt. (B) Beim ersten Auftreten jeder Ansage einmal je Spielstand eine Zeile im Kampfbericht, die Eingebung des Helden (eigene Farbe oder kursiv). Regeln nachgesehen in `Skirmish.kt` (Zweig `claude/jerry-203-abwehr`, 19.10.); ändert Jerry eine Regel, ändert Homer den Text. „Ein Fünftel seiner Lebenspunkte“ folgt `BREAK_SHARE`.

**Grak**

`[210T.heavy]` Schwerer Hieb: die Keule mit voller Wucht, 2W6 mehr Schaden, gegen eine Figur. Hilft: vorher ein Fünftel seiner Lebenspunkte abnehmen, dann taumelt er und der Zug ist verloren; sonst Abwehr, Decken oder den Ring treffen.
EN: Heavy blow: the club at full force, 2d6 extra damage, against one figure. Helps: take a fifth of his life points first and he staggers, his turn lost; otherwise Defend, Guard or meet the ring.
`[210T.heavy.eingebung]` Er holt zu weit aus. Treffe ich ihn jetzt hart, kommt er aus dem Tritt.
EN: He winds up too far. If I hit him hard now, he loses his footing.

`[210T.call]` Rudel rufen: ein Goblin kommt, beim zweiten Mal ein Späher, mehr nicht. Hilft: Verhindern lässt es sich nicht; nutze den Zug, um Grak selbst zuzusetzen oder dich aufzustellen.
EN: Call the pack: a goblin comes, the second time a scout, no more. Helps: it cannot be stopped; use the turn to wear Grak down or to set your line.
`[210T.call.eingebung]` Er ruft Hilfe. Die halte ich nicht auf, aber ihn kann ich treffen, solange er brüllt.
EN: He calls for help. That I cannot stop, but I can hit him while he roars.

`[210T.gather]` Kraft sammeln: er heilt sich um 2W10 Lebenspunkte. Hilft: ein Fünftel seiner Lebenspunkte vorher abnehmen, dann bleibt die Heilung aus.
EN: Gather strength: he heals 2d10 life points. Helps: take a fifth of his life points first and the healing fails.
`[210T.gather.eingebung]` Er holt Luft. Jetzt nachsetzen, sonst steht er gleich wieder voll da.
EN: He is catching his breath. Press now, or he stands whole again.

`[210T.breakthrough]` Durchbrechen: er stößt die Figur vorn nach hinten und schlägt die dahinter, die nun vorn steht, mit 1W6 mehr Schaden. Hilft: der Bedrohte tritt selbst nach vorn, dann bleibt ein einfacher Schlag; oder ein Fünftel seiner Lebenspunkte vorher.
EN: Break through: he shoves the front figure back and strikes the one behind, now in front, with 1d6 extra damage. Helps: the threatened one steps forward, leaving a plain blow; or a fifth of his life points first.
`[210T.breakthrough.eingebung]` Er will durch die Reihe. Steht der Bedrohte schon vorn, läuft er ins Leere.
EN: He means to break the line. If the threatened one already stands in front, he charges into nothing.

**Goblin**

`[210T.stab]` Stich: ein einfacher Schlag, ohne Ring. Hilft: Abwehr gibt ihm Nachteil; meist lohnt der eigene Angriff mehr.
EN: Stab: a plain blow, without a ring. Helps: Defend gives it disadvantage; usually your own attack is worth more.
`[210T.stab.eingebung]` Nur ein Stich. Dafür lohnt kein Ausweichen.
EN: Just a stab. Not worth dodging.

`[210T.flank]` Flanke: er läuft um die Reihe und sticht eine Figur hinten, ohne Deckung. Hilft: die Figur wechselt den Platz, dann sticht er ins Leere; oder jeder Treffer auf ihn, auch ein leichter.
EN: Flank: he runs round the line and stabs a figure at the back, without cover. Helps: that figure changes places and he stabs at nothing; or any hit on him, however light.
`[210T.flank.eingebung]` Er will hintenrum. Ein Kratzer hält ihn auf, ein Platzwechsel auch.
EN: He means to go round. A scratch stops him, and so does a change of place.

**Wolf**

`[210T.pounce]` Anspringen: trifft er, verliert die Figur ihren nächsten Zug. Hilft: die Figur wechselt den Platz, dann springt er ins Leere; ein Platztausch kostet nur einen halben Zug.
EN: Pounce: if it hits, the figure loses its next turn. Helps: that figure changes places and it leaps at nothing; a swap costs only half a turn.
`[210T.pounce.eingebung]` Er duckt sich zum Sprung. Wer nicht mehr dort steht, wird nicht getroffen.
EN: It crouches to leap. Whoever no longer stands there is not struck.

`[210T.circle]` Einkreisen: alle Wölfe beißen zugleich dieselbe Figur. Hilft: jeder Treffer auf den Wolf, der es ansagt, auch ein leichter, zerstreut das Rudel.
EN: Circle: every wolf bites the same figure at once. Helps: any hit on the wolf that calls it, however light, scatters the pack.
`[210T.circle.eingebung]` Der eine führt das Rudel. Den treffen, egal wie leicht.
EN: That one leads the pack. Hit it, however lightly.

**Riesenspinne**

`[210T.venom]` Gift sammeln: der nächste Biss hat 2W6 mehr Schaden, ohne Ring. Hilft: ein Fünftel ihrer Lebenspunkte vorher, dann versiegt das Gift; sonst Abwehr.
EN: Gather venom: the next bite deals 2d6 extra damage, without a ring. Helps: a fifth of her life points first and the venom dries up; otherwise Defend.
`[210T.venom.eingebung]` Das Gift kommt ohne Warnung. Ich muss sie treffen, bevor sie beißt.
EN: The venom comes without warning. I must hit her before she bites.

`[210T.web]` Netz werfen: trifft es, verliert die Figur ihren nächsten Zug. Hilft: den Ring perfekt treffen; Abwehr gibt ihr Nachteil.
EN: Cast web: if it hits, the figure loses its next turn. Helps: meet the ring perfectly; Defend gives her disadvantage.
`[210T.web.eingebung]` Das Netz fliegt langsam. Wer den Moment trifft, ist frei.
EN: The web flies slowly. Catch the moment and you are free.

**Goblin-Späher**

`[210T.aim]` Anlegen: ein Schuss mit 1W6 mehr Schaden, ohne Ring. Hilft: die Figur geht in Abwehr, dann duckt sie sich und der Pfeil geht vorbei.
EN: Take aim: a shot with 1d6 extra damage, without a ring. Helps: that figure goes on the defensive, ducks, and the arrow misses.
`[210T.aim.eingebung]` Er zielt auf mich. Ducke ich mich, verfehlt er.
EN: He is aiming at me. If I duck, he misses.

`[210T.shadow]` In den Schatten: er verschwindet, bis zu seinem nächsten Zug haben Angriffe auf ihn Nachteil. Hilft: jeder Treffer vorher, auch ein leichter, hält ihn im Licht.
EN: Into the shadows: he vanishes; until his next turn, attacks on him have disadvantage. Helps: any hit before, however light, keeps him in the light.
`[210T.shadow.eingebung]` Er sucht das Dunkel. Ein Kratzer jetzt, und er bleibt sichtbar.
EN: He seeks the dark. A scratch now, and he stays in sight.

## Der Ring erklärt (219T, Chef 19.10.)

Ring heute nur bei Schwerer Hieb, Netz werfen, Durchbrechen (`ring = true` in `Skirmish.kt`, Zweig `claude/jerry-build-34`, nachgesehen 19.10.). Ändert Jerry das, ändert sich nur, wo das Zeichen steht.

**Zeichen (Entscheid Homer, Aussehen):** ein kleiner goldener Ring, gezeichnet wie der echte Ring (Kreislinie, nicht gefüllt, etwa so hoch wie die Schrift), zwischen dem bisherigen Zeichen und dem Namen: „!! ◯ Schwerer Hieb“. Gezeichnet statt Schriftzeichen, damit er auf jedem Gerät gleich aussieht und an den Ring erinnert. Auch in der Zugleiste und im Popup der Ansage (210T A), falls dort ein Zeichen steht.

`[219T.erster]` (einmal je Spielstand, Zeile im Kampfbericht wie die Eingebung, 210T B; wenn ein Gegner zum ersten Mal eine Ansage mit Ring gegen eine Figur ansagt, die der Spieler steuert, also vor dem Schlag, nicht erst beim Ring) Das Zeichen ◯ heißt: dieser Schlag kommt mit Ring; tippe, wenn er sich um deine Figur schließt, dann nimmst du halben Schaden, im genauen Moment gar keinen.
EN: The sign ◯ means: this blow comes with a ring; tap as it closes around your figure and you take half damage, at the exact moment none at all.

`[219T.jetzt]` (nur beim ersten Ring je Spielstand, kurz über dem Ring, bis getippt oder vorbei) Jetzt tippen, wenn er sich schließt!
EN: Tap as it closes!

Ergebnis am Ziel (219.2, Wortlaut aus dem Vorgangsarchiv), statt des bloßen Worts:

`[219.ring.perfekt]` Perfekt: ausgewichen / EN: Perfect: dodged

`[219.ring.gut]` Gut: halber Schaden / EN: Good: half damage

`[219.ring.verpasst]` Verpasst / EN: Missed

Die Antwort der Klasse auf „Perfekt“ steht als Kampfzeile (`[72.10a.9.…]`), die des Magiers als `[72.10a.9.feuer]` (219.3T).

## Laden: neue Ware (59e.1T)

Ersetzt „Neue Ware nach jeweils 8 Siegen.“ im Laden. Bewusst vage: wann genau, findet der Spieler selbst heraus.

`[59e.1T.hinweis]` Neue Ware kommt, wenn sich draußen etwas tut. Und wenn du stärker wirst.
EN: New stock comes when something stirs out there. And when you grow stronger.

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
