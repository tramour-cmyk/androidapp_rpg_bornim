package de.bornim.core.art

import de.bornim.core.Hero
import de.bornim.core.art.HeroFigure.Act
import de.bornim.core.art.HeroFigure.Strike

/**
 * The hero standing at rest with everything worn, turned to any side: for the equipment menu and the making of a
 * hero. Every people is drawn at the same scale, so a halfling stands small beside a half-orc.
 */
object HeroPortrait {
    const val W = 150
    const val H = 230
    /** Art pixels per centimetre. */
    const val PX = 0.9

    /** The sides it is turned to, one after the other: half towards us first. */
    val YAWS = listOf(20.0, 60.0, 100.0, 140.0, 180.0, 220.0, 260.0, 300.0, 340.0)

    private fun look(hero: Hero) = "${hero.race}/${hero.sex}/${hero.build}/${hero.skinTone}/${hero.hairTone}/${hero.cls}/" +
        de.bornim.core.GearSlot.entries.joinToString(",") { s -> hero.item(s)?.let { "${it.base}:${it.rarity}" } ?: "-" }

    private val cache = object : LinkedHashMap<String, PixelImage>(32, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 40
    }

    /** The hero turned to [yaw], drawn now if need be (about a twentieth of a second). */
    fun render(hero: Hero, yaw: Double): PixelImage {
        val k = "${look(hero)}|$yaw"
        synchronized(cache) { cache[k]?.let { return it } }
        val rest = HeroFigure.sequence(Act.IDLE, Strike.SLASH, 0, HeroFigure.stance(hero))[0].copy(yaw = yaw)
        val img = HeroBattle.doll(hero).render(W, H, W / 2.0, H - 6.0, PX, rest, HeroBattle.outfit(hero)).img
        synchronized(cache) { cache[k] = img }
        return img
    }

    /** The picture if it is drawn already. */
    fun ready(hero: Hero, yaw: Double): PixelImage? = synchronized(cache) { cache["${look(hero)}|$yaw"] }

    /** Draws every side ahead; call it off the main thread. */
    fun prepare(hero: Hero, cancelled: () -> Boolean = { false }) {
        for (y in YAWS) { if (cancelled()) return; render(hero, y) }
    }
}
