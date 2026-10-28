# 348.7 (296.2): what a won fight brings, as the old fight's Battle.finishWin: experience by the leader's worth (higher
# monster levels and each pack mate worth more), gold and the items the leader may leave; levels by experience, up to
# the chapter's cap. Still missing until the hero and the bag are ported (Tom, 348.6): gear drops (Loot.drops), elite and
# shimmering foes, the bonuses of gear and perks (passed in as factors), the bag the items go into.
extends RefCounted

# Battle.kt Msg
const GAIN_XP := ["{0} erhält {1} EP.", "{0} gained {1} XP."]
const CAPPED := ["Höchststufe für Kapitel 1 erreicht – keine weiteren EP in diesem Kapitel. Beute und Ausrüstung gibt es weiterhin.",
	"Highest level for chapter 1 reached – no further XP in this chapter. Loot and gear still drop."]
const GAIN_GOLD := ["Du erbeutest {0} Gold.", "You got {0} gold."]
const LOOT := ["Beute: {0}!", "Loot: {0}!"]
const LEVEL_UP := ["{0} erreicht Stufe {1}!", "{0} grew to level {1}!"]
const NEW_SKILL := ["Neue Fähigkeit: {0}!", "New ability: {0}!"]
const RESTORED := ["TP und ZP von {0} sind vollständig aufgefüllt!", "{0}'s HP and SP are fully restored!"]
const POINTS := ["+{0} Attributspunkt(e) – verteile sie im Menü.", "+{0} ability point(s) – spend them in the menu."]
# Rules.abilityLevels
const ABILITY_LEVELS := [4, 8, 12, 16, 19]
const MAX_LEVEL := 20


## The reward of the won fight [mars] for its hero (the party's first): [xp] the hero's experience before, [over] how
## many levels the hero stands above the place (Battle.over), [cap] the highest level, null for the chapter's.
## Returns {xp, gold, items, level, levels, xp_total, lines}; nothing is added anywhere, the caller does that.
static func reward(mars, xp: int, dice, over := 0, cap = null, xp_factor := 1.0, gold_factor := 1.0) -> Dictionary:
	assert(mars.outcome == "WON")
	var tables_xp: Array = mars.xp_for_level
	var top: int = int(mars.level_cap) if cap == null else int(cap)
	var hero = mars.all[0]
	var lang: int = mars.lang
	var foes: Array = mars.all.filter(func(f): return f.side == "FOES" and f.monster != null and not f.called_in)
	# the old fight had one foe with its pack: the worthiest is the leader, the others its companions
	var leader = foes[0]
	for f in foes:
		if int(f.monster.xp) > int(leader.monster.xp):
			leader = f
	foes.erase(leader)
	var m: Dictionary = leader.monster
	var pack = mars.packs.get(m.id)
	var mates := 0
	if pack != null:
		mates = foes.filter(func(f): return f.monster.id == pack.mate).size()
	var scale := 1.0 + 0.35 * over + 0.05 * over * over
	var share: float = float(pack.xpShare) if pack != null else 0.0
	var worth := int(int(m.xp) * scale * (1.0 + share * mates) * xp_factor)
	var gold := int(dice.roll_expr(m.gold) * (1.0 + over * 0.3) * gold_factor)
	var items: Array = []
	for e in m.get("loot", []):
		if dice.chance(float(e.chance)) and mars.items.has(e.item):
			items.append(e.item)
	var level: int = hero.level()
	var total := xp + worth
	var target := level
	while target < mini(MAX_LEVEL, top) and total >= int(tables_xp[target + 1]):
		target += 1
	# at a chapter's level cap no further experience is gathered (Hero.gainXp)
	if top < MAX_LEVEL:
		total = mini(total, int(tables_xp[top]))
	var earned := maxi(0, total - xp)
	var name: String = hero.name(lang)
	var lines: Array = []
	if earned > 0:
		lines.append(_f(GAIN_XP, lang, [name, earned]))
	if earned < worth and top < MAX_LEVEL and target >= top:
		lines.append(CAPPED[lang])
	if gold > 0:
		lines.append(_f(GAIN_GOLD, lang, [gold]))
	for it in items:
		lines.append(_f(LOOT, lang, [[mars.items[it].de, mars.items[it].en][lang]]))
	for lvl in range(level + 1, target + 1):
		lines.append(_f(LEVEL_UP, lang, [name, lvl]))
		for s in mars.skills.values():
			if s.cls == hero.hero.cls and int(s.level) == lvl:
				lines.append(_f(NEW_SKILL, lang, [[s.de, s.en][lang]]))
	if target > level:
		lines.append(_f(RESTORED, lang, [name]))
		var points := 2 * (ABILITY_LEVELS.filter(func(a): return a <= target).size() - ABILITY_LEVELS.filter(func(a): return a <= level).size())
		if points > 0:
			lines.append(_f(POINTS, lang, [points]))
	return {"xp": earned, "gold": gold, "items": items, "level": target, "levels": target - level, "xp_total": total, "lines": lines}


static func _f(t: Array, lang: int, args: Array) -> String:
	var s: String = t[lang]
	for i in args.size():
		s = s.replace("{%d}" % i, str(args[i]))
	return s
