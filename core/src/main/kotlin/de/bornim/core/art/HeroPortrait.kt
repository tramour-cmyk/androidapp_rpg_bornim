package de.bornim.core.art

import de.bornim.core.Hero
import de.bornim.core.art.HeroFigure.Act
import de.bornim.core.art.HeroFigure.Strike

/**
 * The hero standing at rest with everything worn, turned to any side: for the menus and the making of a hero. The
 * figure stands in the middle of the picture. Drawn to fill it, every hero is as tall as a half-orc, so a halfling is
 * seen as well as anyone; drawn true to scale (when a hero is made), a halfling stands small where a half-orc is tall.
 */
object HeroPortrait {
    const val W = 150
    const val H = 230
    /** Art pixels per centimetre, true to scale. */
    const val PX = 0.9
    /** The height in centimetres every hero is drawn as when filling the picture. */
    private const val FILL_CM = 185.0

    /** The sides it is turned to, one after the other in small steps so the turn runs smooth: half towards us first. */
    val YAWS = List(24) { (20.0 + it * 15.0) % 360.0 }

    private fun look(hero: Hero) = "${hero.race}/${hero.sex}/${hero.build}/${hero.skinTone}/${hero.hairTone}/${hero.cls}/" +
        de.bornim.core.GearSlot.entries.joinToString(",") { s -> hero.item(s)?.let { "${it.base}:${it.rarity}" } ?: "-" }

    private val cache = object : LinkedHashMap<String, PixelImage>(32, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, PixelImage>?) = size > 60
    }

    /** The hero turned to [yaw], drawn now if need be (about a twentieth of a second); [fill]s the picture or true to scale. */
    fun render(hero: Hero, yaw: Double, fill: Boolean = true): PixelImage {
        val k = "${look(hero)}|$yaw|$fill"
        synchronized(cache) { cache[k]?.let { return it } }
        val rest = HeroFigure.sequence(Act.IDLE, Strike.SLASH, 0, HeroFigure.stance(hero))[0].copy(yaw = yaw)
        val doll = HeroBattle.doll(hero)
        val px = if (fill) PX * FILL_CM / doll.height else PX
        // the body in the middle, a little low to leave room for a weapon held up above the head
        val ground = (H + doll.height * px * 1.08) / 2
        val img = doll.render(W, H, W / 2.0, ground, px, rest, HeroBattle.outfit(hero)).img
        synchronized(cache) { cache[k] = img }
        return img
    }

    /** The picture if it is drawn already. */
    fun ready(hero: Hero, yaw: Double, fill: Boolean = true): PixelImage? = synchronized(cache) { cache["${look(hero)}|$yaw|$fill"] }

    /** Draws every side ahead; call it off the main thread. */
    fun prepare(hero: Hero, fill: Boolean = true, cancelled: () -> Boolean = { false }) {
        for (y in YAWS) { if (cancelled()) return; render(hero, y, fill) }
    }
}
