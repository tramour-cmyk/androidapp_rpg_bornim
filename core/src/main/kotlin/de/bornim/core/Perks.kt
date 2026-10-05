package de.bornim.core

import kotlin.math.roundToInt

/**
 * What each ability does for every hero, on top of the class basics (attack, armor class, hit
 * points, spells). Effects are small and grow with the ability modifier, so no ability is a dead
 * stat, yet none of them breaks the balance.
 */
object Perks {
    private fun mod(h: Hero, a: Ability) = h.mod(a)
    private fun plus(h: Hero, a: Ability) = maxOf(0, h.mod(a))

    // ---------------------------------------------------------------- Charisma: trading and presence

    /** Price factor when buying: 5 % cheaper per point, at most 20 % (and dearer with a negative modifier). */
    fun buyFactor(h: Hero): Double = 1.0 - 0.05 * mod(h, Ability.CHA).coerceIn(-4, 4)

    /** Price factor when selling: 5 % more per point, at most 20 %. */
    fun sellFactor(h: Hero): Double = 1.0 + 0.05 * mod(h, Ability.CHA).coerceIn(-4, 4)

    fun buyPrice(h: Hero, base: Int): Int = maxOf(1, (base * buyFactor(h)).roundToInt())
    fun sellPrice(h: Hero, base: Int): Int = maxOf(1, (base * sellFactor(h)).roundToInt())

    /** Chance that an ordinary foe hesitates, cowed by the hero, and loses its first round. */
    fun cowChance(h: Hero): Double = 0.08 * plus(h, Ability.CHA)

    // ---------------------------------------------------------------- Intelligence: knowledge

    /** From INT 12 on the hero recognises a foe's weaknesses and resistances. */
    fun knowsWeaknesses(h: Hero): Boolean = mod(h, Ability.INT) >= 1

    /** Chance per point that Morwen's brew yields an extra potion. */
    fun extraBrewChance(h: Hero): Double = 0.10 * plus(h, Ability.INT)

    /** Experience factor: 3 % more per point. */
    fun xpFactor(h: Hero): Double = 1.0 + 0.03 * plus(h, Ability.INT)

    // ---------------------------------------------------------------- Wisdom: perception

    /** Extra sight in the fog, in tiles: half a tile per point. */
    fun sightBonus(h: Hero): Double = 0.5 * plus(h, Ability.WIS)

    /** Factor on the chance of an ambush: 15 % less per point, down to 40 %. */
    fun ambushFactor(h: Hero): Double = maxOf(0.4, 1.0 - 0.15 * plus(h, Ability.WIS))

    /** Chance per point of an extra herb when picking. */
    fun extraHerbChance(h: Hero): Double = 0.15 * plus(h, Ability.WIS)

    // ---------------------------------------------------------------- Strength: force

    /** Extra damage of thrown flasks (alchemist's fire, holy water). */
    fun throwBonus(h: Hero): Int = plus(h, Ability.STR)

    // ---------------------------------------------------------------- Dexterity: stealth

    /** How close a hunting monster must come to notice the hero: one tile less per two points, at least 2. */
    fun noticeRange(h: Hero, base: Int = 4): Int = maxOf(2, base - plus(h, Ability.DEX) / 2)

    // ---------------------------------------------------------------- Constitution: toughness

    /** Poison and bleeding carried out of a fight wear off this many rounds sooner. */
    fun ailmentShortening(h: Hero): Int = plus(h, Ability.CON)

    /** Extra HP from a meal. */
    fun mealBonus(h: Hero): Int = plus(h, Ability.CON)

    // ---------------------------------------------------------------- explanations for the hero tab

    /** What [a] does for this hero, line by line, with the current numbers. */
    fun describe(a: Ability, h: Hero, lang: Lang): List<String> {
        val de = lang == Lang.DE
        val m = h.mod(a)
        val p = maxOf(0, m)
        fun pct(x: Double) = "${(x * 100).roundToInt()} %"
        fun num(x: Double) = "%.1f".format(java.util.Locale.ROOT, x).let { if (de) it.replace('.', ',') else it }
        val lines = mutableListOf<String>()
        lines += (if (de) "Wert ${h.score(a)}, Modifikator " else "Score ${h.score(a)}, modifier ") + Rules.signed(m)
        when (a) {
            Ability.STR -> {
                lines += if (de) "• Treffer und Schaden mit Nahkampfwaffen (außer Finesse-Waffen, wenn GES höher ist)." else "• Hit and damage with melee weapons (except finesse weapons if DEX is higher)."
                lines += if (de) "• Rettungswurf gegen Umwerfen, z. B. durch Wölfe." else "• Saving throw against being knocked down, e.g. by wolves."
                lines += if (de) "• Wurfgeschosse (Alchemistenfeuer, Weihwasser): +$p Schaden." else "• Thrown flasks (alchemist's fire, holy water): +$p damage."
            }
            Ability.DEX -> {
                lines += if (de) "• Rüstungsklasse ohne, mit leichter und (bis +2) mittlerer Rüstung." else "• Armor class without armor, with light and (up to +2) medium armor."
                lines += if (de) "• Treffer und Schaden mit Fernkampf- und Finesse-Waffen." else "• Hit and damage with ranged and finesse weapons."
                lines += if (de) "• Initiative und Fluchtchance; Rettungswurf gegen Netze." else "• Initiative and chance to flee; saving throw against webs."
                lines += if (de) "• Schleichen: Jagende Monster bemerken dich erst ab ${noticeRange(h)} Feldern (normal 4)." else "• Stealth: hunting monsters only notice you within ${noticeRange(h)} tiles (normally 4)."
            }
            Ability.CON -> {
                lines += if (de) "• Trefferpunkte pro Stufe." else "• Hit points per level."
                lines += if (de) "• Rettungswürfe gegen Gift, Lähmung und ähnliche Zustände." else "• Saving throws against poison, paralysis and similar conditions."
                lines += if (de) "• Gift und Blutung klingen nach dem Kampf $p Runden schneller ab." else "• Poison and bleeding wear off $p rounds sooner after a fight."
                lines += if (de) "• Mahlzeiten heilen +$p TP." else "• Meals heal +$p HP."
            }
            Ability.INT -> {
                if (h.cls == CharClass.WIZARD) lines += if (de) "• Magier: Zauberangriff und Zauber-Schwierigkeitsgrad." else "• Wizard: spell attack and spell save DC."
                lines += if (de) "• Wissen: " + (if (knowsWeaknesses(h)) "Du erkennst Schwächen und Resistenzen deiner Gegner." else "Ab INT 12 erkennst du Schwächen und Resistenzen deiner Gegner.")
                    else "• Knowledge: " + (if (knowsWeaknesses(h)) "You recognise your foes' weaknesses and resistances." else "From INT 12 on you recognise your foes' weaknesses and resistances.")
                lines += if (de) "• Alchemie: ${pct(extraBrewChance(h))} Chance auf einen zusätzlichen Trank beim Brauen." else "• Alchemy: ${pct(extraBrewChance(h))} chance of an extra potion when brewing."
                lines += if (de) "• Lernen: +${pct(xpFactor(h) - 1)} Erfahrung." else "• Learning: +${pct(xpFactor(h) - 1)} experience."
            }
            Ability.WIS -> {
                if (h.cls == CharClass.CLERIC) lines += if (de) "• Kleriker: Zauberangriff, Zauber-SG, Heilung und Spirituelle Waffe." else "• Cleric: spell attack, spell DC, healing and spiritual weapon."
                lines += if (de) "• Rettungswurf gegen Flüche." else "• Saving throw against curses."
                lines += if (de) "• Wahrnehmung: +${num(sightBonus(h))} Felder Sicht im Nebel, ${pct(1 - ambushFactor(h))} seltener Hinterhalte." else "• Perception: +${num(sightBonus(h))} tiles of sight in the fog, ${pct(1 - ambushFactor(h))} fewer ambushes."
                lines += if (de) "• Kräuterkunde: ${pct(extraHerbChance(h))} Chance auf ein zusätzliches Kraut beim Pflücken." else "• Herb lore: ${pct(extraHerbChance(h))} chance of an extra herb when picking."
            }
            Ability.CHA -> {
                val buy = ((1 - buyFactor(h)) * 100).roundToInt()
                lines += if (de) "• Handeln: " + (if (buy >= 0) "$buy % günstiger einkaufen und $buy % teurer verkaufen." else "${-buy} % teurer einkaufen und ${-buy} % billiger verkaufen.")
                    else "• Trading: " + (if (buy >= 0) "buy $buy % cheaper and sell $buy % dearer." else "buy ${-buy} % dearer and sell ${-buy} % cheaper.")
                lines += if (de) "• Auftreten: ${pct(cowChance(h))} Chance, dass ein normaler Gegner eingeschüchtert zögert und seine erste Runde verliert." else "• Presence: ${pct(cowChance(h))} chance that an ordinary foe hesitates, cowed, and loses its first round."
            }
        }
        return lines
    }
}
