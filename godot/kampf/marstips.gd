extends RefCounted
# 536 (Abgleich 512 zu Build 249, Sokrates; Chef 03.11., 23:56: „Tip durch Drücken funktioniert nicht“): was langes Drücken im
# MARS-Kampf sagt, wörtlich aus dem alten Spiel (MarsTips.kt: Homers Texte 204T, 210T, 223T, 259T); [de, en].

const ATTACK := ["Ein Schlag oder Schuss mit der Waffe. Nahkampf erreicht nur die vordere Reihe, solange dort jemand steht, und hat von hinten an einem Freund vorbei Nachteil, außer mit Speer oder Hellebarde. Bogen und Armbrust haben Nachteil, wenn du vorn stehst und auf die vordere Reihe schießt.",
	"One blow or shot with your weapon. Melee reaches only the front row while anyone stands there, and from the back past a friend it has disadvantage, except with a spear or halberd. Bows and crossbows have disadvantage when you stand in front and shoot at the front row."]
const SKILLS := ["Zauber und Fähigkeiten deiner Klasse. Zauber kosten Zauberpunkte, manches geht nur einmal pro Kampf oder bis zur Rast.",
	"Your class's spells and abilities. Spells cost spell points; some things work only once per battle or until you rest."]
const BAG := ["Ein Heiltrank aus dem gemeinsamen Vorrat, für dich oder einen Freund. Kostet den Zug.",
	"A healing potion from the shared stock, for you or a friend. Costs your turn."]
const PLACE := ["In die andere Reihe gehen (steht dort ein Freund, tauscht ihr) oder die Waffe wechseln, oder beides zugleich. Hinten bist du gedeckt, solange vorn ein Freund steht. Ein halber Zug: danach bleibt noch ein Schlag.",
	"Move to the other row (if a friend stands there, you trade places) or switch weapons, or both at once. At the back you are covered while a friend stands in front. Half a turn: one blow remains after it."]
const DEFEND := ["Bis zu deinem nächsten Zug haben Angriffe auf dich Nachteil, Rettungswürfe auf Geschicklichkeit Vorteil. Manchmal ist das die richtige Antwort.",
	"Until your next turn, attacks on you have disadvantage and Dexterity saves have advantage. Sometimes that is the right answer."]
const COVER := ["Nur aus der vorderen Reihe: einen Zug lang zieht der Kämpfer jeden angekündigten Schlag auf Freunde auf sich, jeden mit Ring. Ring perfekt: Gegenschlag.",
	"Front row only: for one turn the fighter draws every announced blow aimed at friends, each with a ring. Perfect ring: a counterblow."]
const MERC := ["Auto: der Söldner kämpft selbst. Selbst: du gibst ihm jeden Befehl.", "Auto: the mercenary fights on their own. Manual: you give every order."]
const AUTOPILOT := ["Spielt deinen Helden: Waffe, Zaubertricks, Heilung für einen schwachen Freund. Fängt den Ring immer gut, nie perfekt. Hält an unter einem Drittel der Lebenspunkte und bei einer starken Absicht; nie gegen Bosse.",
	"Plays your hero: weapon, cantrips, healing for a weak friend. Always hits the ring well, never perfectly. Stops below a third of HP and on a strong intent; never against bosses."]

## 210: langes Drücken auf die Ansage eines Gegners (210T)
const INTENTS := {
	"heavy": ["Schwerer Hieb: die Axt mit voller Wucht, 2W6 mehr Schaden, gegen eine Figur. Hilft: vorher ein Fünftel seiner Lebenspunkte abnehmen, dann taumelt er und der Zug ist verloren; sonst Abwehr, Decken oder den Ring treffen.",
		"Heavy blow: the axe at full force, 2d6 extra damage, against one figure. Counter: take a fifth of his HP first and he staggers, his turn lost; otherwise Defend, Cover or meet the ring."],
	"call": ["Rudel rufen: ein Goblin kommt, beim zweiten Mal ein Späher, mehr nicht. Hilft: Verhindern lässt es sich nicht; nutze den Zug, um Grak selbst zuzusetzen oder dich aufzustellen.",
		"Call the pack: a goblin comes, the second time a scout, no more. Counter: it cannot be stopped; use the turn to wear Grak down or to set your line."],
	"gather": ["Kraft sammeln: er heilt sich um 2W10 Lebenspunkte. Hilft: ein Fünftel seiner Lebenspunkte vorher abnehmen, dann bleibt die Heilung aus.",
		"Gather strength: he regains 2d10 HP. Counter: take a fifth of his HP first and the healing fails."],
	"breakthrough": ["Durchbrechen: er stößt die Figur vorn nach hinten und schlägt die dahinter, die nun vorn steht, mit 1W6 mehr Schaden. Hilft: der Bedrohte tritt selbst nach vorn, dann bleibt ein einfacher Schlag; oder ein Fünftel seiner Lebenspunkte vorher.",
		"Break through: he shoves the front figure back and strikes the one behind, now in front, with 1d6 extra damage. Counter: the threatened one steps forward, leaving a plain blow; or a fifth of his HP first."],
	"stab": ["Stich: ein einfacher Schlag, ohne Ring. Hilft: Abwehr gibt ihm Nachteil; meist lohnt der eigene Angriff mehr.",
		"Stab: a plain blow, without a ring. Counter: Defend gives it disadvantage; usually your own attack is worth more."],
	"flank": ["Flanke: er läuft um die Reihe und sticht eine Figur hinten, ohne Deckung. Hilft: die Figur wechselt die Reihe, dann sticht er ins Leere; oder jeder Treffer auf ihn, auch ein leichter.",
		"Flank: he runs around the line and stabs a figure at the back, without cover. Counter: that figure switches rows and he stabs at nothing; or any hit on him, however light."],
	"pounce": ["Anspringen: trifft er, macht er Schaden und bringt die Figur aus dem Gleichgewicht: in ihrem nächsten Zug handelt sie, kann aber weder die Reihe wechseln noch eine Waffe ziehen. Hilft: die Figur wechselt vorher die Reihe, dann springt er ins Leere; ein Wechsel kostet nur einen halben Zug.",
		"Pounce: if it hits, it deals damage and throws the figure off balance: on its next turn it acts, but can neither switch rows nor draw a weapon. Counter: the figure switches rows beforehand and it leaps at nothing; a switch costs only half a turn."],
	"circle": ["Einkreisen: alle Wölfe beißen zugleich dieselbe Figur. Hilft: jeder Treffer auf den Wolf, der es ansagt, auch ein leichter, zerstreut das Rudel.",
		"Circle: every wolf bites the same figure at once. Counter: any hit on the wolf that calls it, however light, scatters the pack."],
	"venom": ["Gift sammeln: der nächste Biss hat 2W6 mehr Schaden, ohne Ring. Hilft: ein Fünftel ihrer Lebenspunkte vorher, dann versiegt das Gift; sonst Abwehr.",
		"Gather venom: the next bite deals 2d6 extra damage, without a ring. Counter: a fifth of her HP first and the venom dries up; otherwise Defend."],
	"web": ["Netz werfen: trifft es, verliert die Figur ihren nächsten Zug. Hilft: den Ring perfekt treffen; Abwehr gibt ihr Nachteil.",
		"Throw web: if it hits, the figure loses its next turn. Counter: meet the ring perfectly; Defend gives her disadvantage."],
	"aim": ["Anlegen: ein Schuss mit 1W6 mehr Schaden, ohne Ring. Hilft: die Figur geht in Abwehr, dann duckt sie sich und der Pfeil geht vorbei.",
		"Take aim: a shot with 1d6 extra damage, without a ring. Counter: that figure Defends, ducks, and the arrow misses."],
	"shadow": ["In den Schatten: er verschwindet, bis zu seinem nächsten Zug haben Angriffe auf ihn Nachteil. Hilft: jeder Treffer vorher, auch ein leichter, hält ihn im Licht.",
		"Into the shadows: he vanishes; until his next turn, attacks on him have disadvantage. Counter: any hit beforehand, however light, keeps him in the light."],
}
