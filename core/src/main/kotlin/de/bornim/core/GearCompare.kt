package de.bornim.core

/**
 * What putting on a piece of gear would change, line by line: the main numbers, every ability and every other
 * property of the pieces coming off and going on, with a note where a limit swallows a bonus. The bag's arrow and
 * the details both come from here, so they always agree.
 */
class GearCompare private constructor(
    /** What comes off for it: the piece in its place, and a shield for a two-handed weapon (or the other way round). */
    val replaced: List<Gear>,
    val rows: List<Row>,
) {
    /** One line: what it is, the value now and with the piece on, and whether that is better (null: no change). */
    class Row(val label: T, val before: String, val after: String, val better: Boolean?, val note: T? = null)

    /** +1 better, -1 worse, 0 mixed, null nothing changes. */
    val verdict: Int?
        get() {
            val up = rows.any { it.better == true }
            val down = rows.any { it.better == false }
            return when {
                up && down -> 0
                up -> 1
                down -> -1
                else -> null
            }
        }

    /** One sentence on the whole: "Besser", "Schlechter", "Gemischt: …, aber …", "Bringt nichts". */
    fun summary(lang: Lang): String {
        val de = lang == Lang.DE
        val gains = rows.filter { it.better == true }.map { it.label(lang) }
        val losses = rows.filter { it.better == false }.map { it.label(lang) }
        fun list(xs: List<String>) = xs.take(3).joinToString(", ") + if (xs.size > 3) (if (de) " und mehr" else " and more") else ""
        return when (verdict) {
            1 -> (if (de) "Besser: " else "Better: ") + list(gains) + "."
            -1 -> (if (de) "Schlechter: " else "Worse: ") + list(losses) + "."
            0 -> (if (de) "Gemischt: mehr " else "Mixed: more ") + list(gains) + (if (de) ", aber weniger " else ", but less ") + list(losses) + "."
            else -> if (de) "Bringt nichts, was du nicht schon hast." else "Adds nothing you do not have already."
        }
    }

    companion object {
        private val ABILITY_AFFIX = mapOf(
            Ability.STR to Affix.STR, Ability.DEX to Affix.DEX, Ability.CON to Affix.CON,
            Ability.INT to Affix.INT, Ability.WIS to Affix.WIS, Ability.CHA to Affix.CHA,
        )
        /** Properties shown as a line of their own; the others feed the main numbers above. */
        private val OWN_LINE = listOf(
            Affix.CRIT, Affix.FIRE, Affix.RADIANT, Affix.LIFESTEAL, Affix.RESIST, Affix.POISON_HIT, Affix.BLEED_HIT,
            Affix.STUN_HIT, Affix.TENACITY, Affix.GOLD_FIND, Affix.MAGIC_FIND, Affix.XP,
        )

        /** Damage as dice, or a plain number for bare fists (a die of one side). */
        private fun dmg(d: DiceExpr) = if (d.sides == 1) "${d.count + d.bonus} (Faust)" else d.label(Lang.DE)

        private class Snap(
            val ac: Int, val attack: Int, val damage: DiceExpr, val hp: Int, val spellAttack: Int, val sp: Int,
            val scores: Map<Ability, Int>, val raw: Map<Affix, Int>, val eff: Map<Affix, Int>, val gearScore: Map<Ability, Int>,
        )

        private fun snap(h: Hero) = Snap(
            h.armorClass, h.attackBonus, h.weaponDamage, h.maxHp, h.spellAttack, h.maxSp,
            Ability.entries.associateWith { h.score(it) }, Affix.entries.associateWith { h.rawBonus(it) },
            Affix.entries.associateWith { h.bonus(it) }, Ability.entries.associateWith { h.gearBonus(it) },
        )

        /** How [g] compares with what [hero] wears now. Leaves the hero untouched. */
        fun of(hero: Hero, g: Gear): GearCompare {
            val saved = hero.gear.toMap()
            val hp = hero.hp; val sp = hero.sp
            val a = snap(hero)
            val removed = hero.equip(g)
            val b = snap(hero)
            hero.gear.clear(); hero.gear.putAll(saved); hero.hp = hp; hero.sp = sp
            val replaced = removed.filter { it.uid != g.uid }
            val rows = mutableListOf<Row>()
            fun capped(vararg affixes: Affix) = affixes.any { b.raw.getValue(it) > a.raw.getValue(it) && b.eff.getValue(it) == a.eff.getValue(it) }
            val limit = T("Bonus wirkt nicht: Obergrenze für dieses Kapitel erreicht", "Bonus has no effect: this chapter's limit is reached")
            fun num(label: T, x: Int, y: Int, signed: Boolean = false, note: T? = null) {
                if (x == y && note == null) return
                fun f(v: Int) = if (signed) Rules.signed(v) else "$v"
                rows += Row(label, f(x), f(y), if (x == y) null else y > x, note)
            }
            num(T("Rüstungsklasse", "Armor Class"), a.ac, b.ac, note = if (a.ac == b.ac && capped(Affix.AC)) limit else null)
            num(T("Angriff", "Attack"), a.attack, b.attack, signed = true, note = if (a.attack == b.attack && capped(Affix.ATTACK)) limit else null)
            fun avg(d: DiceExpr) = d.count * (d.sides + 1) / 2.0 + d.bonus
            if (a.damage != b.damage) {
                val x = avg(a.damage); val y = avg(b.damage)
                fun one(v: Double) = if (v % 1.0 == 0.0) "${v.toInt()}" else "%.1f".format(v).replace('.', ',')
                rows += Row(T("Schaden", "Damage"), dmg(a.damage), dmg(b.damage), if (x == y) null else y > x,
                    T("im Schnitt ${one(y)} statt ${one(x)}", "on average ${one(y).replace(',', '.')} instead of ${one(x).replace(',', '.')}"))
            } else if (capped(Affix.DAMAGE, Affix.FIRE, Affix.RADIANT)) rows += Row(T("Schaden", "Damage"), dmg(a.damage), dmg(b.damage), null, limit)
            num(T("Trefferpunkte", "Hit points"), a.hp, b.hp, note = if (a.hp == b.hp && capped(Affix.HP)) limit else null)
            if (hero.cls.caster) {
                num(T("Zauberangriff", "Spell attack"), a.spellAttack, b.spellAttack, signed = true, note = if (a.spellAttack == b.spellAttack && capped(Affix.SPELL)) limit else null)
                num(T("Zauberpunkte", "Spell points"), a.sp, b.sp)
            }
            // abilities: what the hero's scores become; a bonus that a limit swallows is named
            val lost = mutableListOf<Ability>()
            for ((ab, af) in ABILITY_AFFIX) {
                val rawUp = b.raw.getValue(af) + b.raw.getValue(Affix.ALL_STATS) > a.raw.getValue(af) + a.raw.getValue(Affix.ALL_STATS)
                if (rawUp && b.gearScore.getValue(ab) == a.gearScore.getValue(ab)) lost += ab
                else num(ab.full, a.scores.getValue(ab), b.scores.getValue(ab))
            }
            // abilities whose bonus a limit swallows: one line for them all
            if (lost.isNotEmpty()) rows += Row(T("Attribute", "Abilities"), "", "", null,
                T(lost.joinToString(", ") { it.full.de } + ": Bonus wirkt nicht, Obergrenze für dieses Kapitel erreicht",
                    lost.joinToString(", ") { it.full.en } + ": no effect, this chapter's limit is reached"))
            // everything else, with the percent sign where it is one
            for (af in OWN_LINE) {
                val x = a.eff.getValue(af); val y = b.eff.getValue(af)
                val swallowed = b.raw.getValue(af) > a.raw.getValue(af) && x == y
                if (x == y && !swallowed) continue
                fun f(v: Int) = when {
                    v == 0 -> "–"
                    af == Affix.CRIT -> "ab ${20 - v}"
                    af.percent -> "$v %"
                    else -> "+$v"
                }
                rows += Row(af.title, f(x), f(y), if (x == y) null else y > x, if (swallowed) limit else null)
            }
            return GearCompare(replaced, rows)
        }
    }
}
