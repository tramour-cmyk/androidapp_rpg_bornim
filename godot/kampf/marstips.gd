extends RefCounted
# 536 (Abgleich 512 zu Build 249, Sokrates; Chef 03.11., 23:56: „Tip durch Drücken funktioniert nicht“): was langes Drücken im
# MARS-Kampf sagt, wörtlich aus dem alten Spiel (MarsTips.kt: Homers Texte 204T, 210T, 223T, 259T); [de, en]. 870.5/868: nach dem
# BRS neu von Homer ([870.14.tip.*], [870.14.ansage.*], STORY-BRS-KAMPF.md), ohne Würfel und Zahlen.

const ATTACK := ["Ein Schlag oder Schuss mit der Waffe. Nahkampf erreicht nur die vordere Reihe, solange dort jemand steht, und hat von hinten an einem Freund vorbei Ungunst, außer mit Stangenwaffen. Bogen und Armbrust haben Ungunst auf die vordere Reihe, wenn du vorn stehst und ein Freund neben dir; allein vorn schießt du frei.",
	"One blow or shot with your weapon. Melee reaches only the front row while anyone stands there, and from the back past a friend it is at disfavor, except with polearms. Bows and crossbows are at disfavor against the front row when you stand in front with a friend beside you; alone in front you shoot freely."]
const SKILLS := ["Zauber und Kampfhandlungen, die deine Fertigkeiten dir geben. Zauber kosten Mana; manches geht nur einmal je Kampf oder erst nach dem Langen Ausruhen wieder.",
	"Spells and combat moves your skills give you. Spells cost mana; some work only once per battle or not again until a Long Rest."]
const BAG := ["Ein Heiltrank aus dem gemeinsamen Vorrat, für dich oder einen Freund. Kostet den Zug.",
	"A healing potion from the shared stock, for you or a friend. Costs your turn."]
const PLACE := ["In die andere Reihe gehen (steht dort ein Freund, tauscht ihr) oder die Waffe wechseln, oder beides zugleich. Hinten bist du gedeckt, solange vorn ein Freund steht. Ein halber Zug: danach bleibt noch ein Schlag.",
	"Move to the other row (if a friend stands there, you trade places) or switch weapons, or both at once. At the back you are covered while a friend stands in front. Half a turn: one blow remains after it."]
const DEFEND := ["Bis zu deinem nächsten Zug haben Angriffe auf dich Ungunst, deine Abwehr gegen Flächenwirkungen hat Gunst. Manchmal ist das die richtige Antwort.",
	"Until your next turn, attacks on you are at disfavor and you resist area effects with favor. Sometimes that is the right answer."]
const COVER := ["Nur aus der vorderen Reihe: einen Zug lang ziehst du jeden angekündigten Schlag auf Freunde auf dich, jeden mit Ring. Ring perfekt: Gegenschlag.",
	"Front row only: for one turn you draw every announced blow aimed at friends, each with a ring. Perfect ring: a counterblow."]
const MERC := ["Auto: der Söldner kämpft selbst. Selbst: du gibst ihm jeden Befehl.", "Auto: the mercenary fights on their own. Manual: you give every order."]
const AUTOPILOT := ["Spielt deinen Helden: Waffe, Kleinzauber, Heilung für einen schwachen Freund. Fängt den Ring immer gut, nie perfekt. Hält an unter einem Drittel des Lebens und bei einer starken Absicht; nie gegen Bosse.",
	"Plays your hero: weapon, minor spells, healing for a weak friend. Always meets the ring well, never perfectly. Stops below a third of life and on a strong intent; never against bosses."]

## 210: langes Drücken auf die Ansage eines Gegners (210T)
const INTENTS := {
	"heavy": ["Schwerer Hieb: die Axt mit voller Wucht, weit mehr Schaden, gegen eine Figur. Hilft: vorher ein Fünftel seines Lebens nehmen, dann taumelt er und der Zug ist verloren; sonst Abwehr oder den Ring treffen.",
		"Heavy blow: the axe at full force, far more damage, against one figure. Counter: take a fifth of his life first and he staggers, his turn lost; otherwise Defend or meet the ring."],     # 986 (5): ohne „Decken“, wie [870.14.ansage.heavy],
	"call": ["Hilfe rufen: ein Goblin kommt, höchstens einmal im Kampf. Hilft: Verhindern lässt es sich nicht; nutze den Zug, um Grak selbst zuzusetzen oder dich aufzustellen.",
		"Call for help: a goblin comes, at most once per battle. Counter: it cannot be stopped; use the turn to wear Grak down or to set your line."],
	"gather": ["Kraft sammeln: er heilt sich um einen guten Teil seines Lebens. Hilft: vorher ein Fünftel seines Lebens nehmen, dann bleibt die Heilung aus.",
		"Gather strength: he heals a good part of his life. Counter: take a fifth of his life first and the healing fails."],
	"breakthrough": ["Durchbrechen: er stößt die Figur vorn nach hinten und schlägt die dahinter, die nun vorn steht, härter als sonst. Hilft: der Bedrohte tritt selbst nach vorn, dann bleibt ein einfacher Schlag; oder vorher ein Fünftel seines Lebens.",
		"Break through: he shoves the front figure back and strikes the one behind, now in front, harder than usual. Counter: the threatened one steps forward, leaving a plain blow; or a fifth of his life first."],
	"stab": ["Stich: ein einfacher Schlag, ohne Ring. Hilft: Abwehr gibt ihm Ungunst; meist lohnt der eigene Angriff mehr.",
		"Stab: a plain blow, without a ring. Counter: Defend puts it at disfavor; usually your own attack is worth more."],
	"flank": ["Flanke: er läuft um die Reihe und schlägt eine Figur hinten, ohne Deckung. Hilft: die Figur wechselt die Reihe, dann schlägt er ins Leere; oder jeder Treffer auf ihn, auch ein leichter.",
		"Flank: he runs around the line and strikes a figure at the back, without cover. Counter: that figure switches rows and he strikes at nothing; or any hit on him, however light."],     # [986.flank.tip],
	"pounce": ["Anspringen: trifft er, macht er Schaden und bringt die Figur aus dem Gleichgewicht: in ihrem nächsten Zug handelt sie, kann aber weder die Reihe wechseln noch eine Waffe ziehen. Hilft: die Figur wechselt vorher die Reihe, dann springt er ins Leere; ein Wechsel kostet nur einen halben Zug.",
		"Pounce: if it hits, it deals damage and throws the figure off balance: on its next turn it acts, but can neither switch rows nor draw a weapon. Counter: the figure switches rows beforehand and it leaps at nothing; a switch costs only half a turn."],
	"circle": ["Einkreisen: alle Wölfe beißen zugleich dieselbe Figur. Hilft: jeder Treffer auf den Wolf, der es ansagt, auch ein leichter, vereitelt das Einkreisen.",
		"Circle: every wolf bites the same figure at once. Counter: any hit on the wolf that calls it, however light, foils the circle."],     # [986.circle.tip],
	"venom": ["Gift sammeln: der nächste Biss macht weit mehr Schaden, ohne Ring. Hilft: vorher ein Fünftel ihres Lebens, dann versiegt das Gift; sonst Abwehr.",
		"Gather venom: the next bite deals far more damage, without a ring. Counter: a fifth of her life first and the venom dries up; otherwise Defend."],
	"web": ["Netz werfen: trifft es, verliert die Figur ihren nächsten Zug. Hilft: den Ring perfekt treffen; Abwehr gibt ihr Ungunst.",
		"Throw web: if it hits, the figure loses its next turn. Counter: meet the ring perfectly; Defend puts her at disfavor."],
	"aim": ["Anlegen: ein Schuss, härter als sonst, ohne Ring. Hilft: die Figur geht in Abwehr, dann duckt sie sich und der Pfeil geht vorbei.",
		"Take aim: a shot harder than usual, without a ring. Counter: that figure Defends, ducks, and the arrow misses."],
	"shadow": ["In den Schatten: er verschwindet; bis zu seinem nächsten Zug haben Angriffe auf ihn Ungunst. Hilft: jeder Treffer vorher, auch ein leichter, hält ihn im Licht.",
		"Into the shadows: he vanishes; until his next turn, attacks on him are at disfavor. Counter: any hit beforehand, however light, keeps him in the light."],
}
