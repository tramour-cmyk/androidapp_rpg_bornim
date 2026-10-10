package preview

import de.bornim.core.CharClass
import de.bornim.core.GameState
import de.bornim.core.Hero
import de.bornim.core.Race
import de.bornim.core.Sex
import de.bornim.core.art.Doll
import de.bornim.core.art.HeroBattle
import de.bornim.core.art.HeroFigure
import de.bornim.core.art.PixelImage
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** The doll as it could walk on the map: at rest, arms down, weapon lowered; a step by stride and arm swing. */
private fun mapRig(yaw: Double, step: Int): HeroFigure.Rig {
    val st = listOf(0.0, 11.0, 0.0, -11.0)[step % 4]
    return Doll.REST.copy(
        yaw = yaw, stride = st, spread = 5.0,
        // the weapon hangs down along the leg, the shield at the side, the arms swing a little with the step
        rh = HeroFigure.V(17.0, 56.0, 2.0 - st * 0.35), lh = HeroFigure.V(-17.0, 54.0, 3.0 + st * 0.6),
        weapon = HeroFigure.V(0.08, -1.0, 0.12), aim = 1.0,
        shieldFace = HeroFigure.V(-1.0, 0.0, 0.25),
        bodyY = if (step % 2 == 1) 1.0 else 0.0,
    )
}

private const val PITCH = 38.0
private const val PX = 0.5

fun mapFigure(hero: Hero, yaw: Double, step: Int, w: Int = 110, h: Int = 120): PixelImage =
    HeroBattle.doll(hero).render(w, h, w / 2.0, h - 8.0, PX, mapRig(yaw, step), HeroBattle.outfit(hero).withShieldOnBack(), pitch = PITCH).img

/** MAPFIG: drafts of the doll on the map — the four ways to walk, a step, the classes, and a scene in the clearing. */
fun renderMapFigureDraft() {
    File("build/screens").mkdirs()
    val bg1 = 0x3A4430; val bg2 = 0x34402C
    fun sheet(cols: Int, rows: Int, cw: Int, ch: Int, cell: (Int, Int) -> PixelImage?): BufferedImage {
        val out = BufferedImage(cols * cw * 2, rows * ch * 2, BufferedImage.TYPE_INT_RGB)
        for (r in 0 until rows) for (c in 0 until cols) {
            val img = cell(c, r)
            for (y in 0 until ch * 2) for (x in 0 until cw * 2) {
                val q = img?.get(x / 2, y / 2) ?: 0
                out.setRGB(c * cw * 2 + x, r * ch * 2 + y, if ((q ushr 24) >= 128) q else if ((x / 16 + y / 16) % 2 == 0) bg1 else bg2)
            }
        }
        return out
    }
    val fighter = GameState.newGame("Mira", Race.HUMAN, CharClass.FIGHTER).hero
    // 1: the four directions (down, left, up, right), each with the four steps of a walk
    val dirs = listOf(0.0, 270.0, 180.0, 90.0)
    ImageIO.write(sheet(4, 4, 110, 120) { c, r -> mapFigure(fighter, dirs[r], c) }, "png", File("build/screens/mapfig_walk.png"))
    // 2: classes and folk, facing down and half turned
    val heroes = listOf(
        Triple(Race.HUMAN, CharClass.FIGHTER, Sex.MALE), Triple(Race.ELF, CharClass.WIZARD, Sex.FEMALE),
        Triple(Race.DWARF, CharClass.CLERIC, Sex.MALE), Triple(Race.HALFLING, CharClass.ROGUE, Sex.FEMALE),
        Triple(Race.HALF_ORC, CharClass.FIGHTER, Sex.MALE),
    ).map { (race, cls, sex) -> GameState.newGame("X", race, cls).hero.also { it.sex = sex } }
    ImageIO.write(sheet(heroes.size, 2, 110, 120) { c, r -> mapFigure(heroes[c], if (r == 0) 20.0 else 225.0, 0) }, "png", File("build/screens/mapfig_folk.png"))
    // 3: a scene at Garrick's fire, old figures (left) against the doll (right), on the new wood
    val map = de.bornim.core.World["forest"]
    de.bornim.core.art.MapGround.prepareNow(map)
    val S = de.bornim.core.art.MapGround.S
    val x0 = 8; val y0 = 7; val tw = 7; val th = 6
    fun scene(newStyle: Boolean): BufferedImage {
        val w = tw * S; val h = th * S
        val out = BufferedImage(w, h, BufferedImage.TYPE_INT_RGB)
        fun blend(img: PixelImage, ax: Int, ay: Int, k: Int) {
            for (y in 0 until img.height * k) for (x in 0 until img.width * k) {
                val px = ax + x - x0 * S; val py = ay + y - y0 * S
                if (px !in 0 until w || py !in 0 until h) continue
                val c = img[x / k, y / k]; val a = (c ushr 24) and 0xFF
                if (a == 0) continue
                val d = out.getRGB(px, py)
                fun chn(sh: Int) = (((c shr sh) and 0xFF) * a + ((d shr sh) and 0xFF) * (255 - a)) / 255
                out.setRGB(px, py, (0xFF shl 24) or (chn(16) shl 16) or (chn(8) shl 8) or chn(0))
            }
        }
        val ch = de.bornim.core.art.MapGround.CH
        for (cy in 0..(map.height / ch)) for (cx in 0..(map.width / ch)) de.bornim.core.art.MapGround.chunk(map, cx, cy)?.let { blend(it, cx * ch * S, cy * ch * S, 1) }
        for (o in de.bornim.core.art.MapFlora.shadows(map)) blend(o.img, o.x * 2, o.y * 2, 1)
        val state = GameState.newGame("Mira", Race.HUMAN, CharClass.FIGHTER)
        val garrick = GameState.newGame("Garrick", Race.HUMAN, CharClass.ROGUE).hero
        class Thing(val sortY: Int, val draw: () -> Unit)
        val things = mutableListOf<Thing>()
        for (o in de.bornim.core.art.WorldArt.objects(map, state, 0)) things += Thing(o.sortY * 2) { blend(o.img, o.x * 2, o.y * 2, 2 / o.density) }
        // the hero just west of the fire, Garrick east of it
        val hx = (10 * S + S / 2); val hy = (9 * S + S - 4)
        val gx = (12 * S + S / 2); val gy = (9 * S + S - 4)
        if (newStyle) {
            val shadow = de.bornim.core.art.WorldArt.shadow()
            things += Thing(hy) { blend(shadow, hx - 24, hy - 10, 2); val f = mapFigure(state.hero, 90.0, 0); blend(f, hx - f.width / 2, hy - f.height + 8, 1) }
            things += Thing(gy) { blend(shadow, gx - 24, gy - 10, 2); val f = mapFigure(garrick, 270.0, 0); blend(f, gx - f.width / 2, gy - f.height + 8, 1) }
        } else {
            things += Thing(hy) { val f = de.bornim.core.art.CharacterArt.hero(state.hero, de.bornim.core.Facing.RIGHT); blend(f, hx - f.width, hy - f.height * 2 + 2, 2) }
            things += Thing(gy) { val f = de.bornim.core.art.CharacterArt.npc("hunter", de.bornim.core.Facing.LEFT, 0); blend(f, gx - f.width, gy - f.height * 2 + 2, 2) }
        }
        for (t in things.sortedBy { it.sortY }) t.draw()
        return out
    }
    val a = scene(false); val b = scene(true)
    val both = BufferedImage(a.width * 2 + 12, a.height, BufferedImage.TYPE_INT_RGB)
    both.graphics.drawImage(a, 0, 0, null); both.graphics.drawImage(b, a.width + 12, 0, null)
    ImageIO.write(both, "png", File("build/screens/mapfig_scene.png"))
    println("wrote mapfig")
}


/** MAPFIGYAWS: the in-game map figure in all 16 directions with every kind of weapon, to check every turn. */
fun renderMapFigureYaws() {
    val F = de.bornim.core.art.MapFigure
    // WEAPONS=a,b,c: only these rows (e.g. the weapons put away at the hip)
    val weapons = System.getenv("WEAPONS")?.split(",") ?: listOf("longsword", "spear", "quarterstaff", "greatsword", "greataxe", "halberd", "staff", "longbow", "light_crossbow", "dagger", "-cleric", "-rogue", "-wizard", "-dwarf", "-halfling")
    var uid = 900L
    val heroes = weapons.map { w ->
        when (w) {
            "-cleric" -> GameState.newGame("Mira", Race.HUMAN, CharClass.CLERIC).hero
            "-rogue" -> GameState.newGame("Mira", Race.ELF, CharClass.ROGUE).hero
            "-wizard" -> GameState.newGame("Mira", Race.ELF, CharClass.WIZARD).hero
            "-dwarf" -> GameState.newGame("Mira", Race.DWARF, CharClass.CLERIC).hero
            "-halfling" -> GameState.newGame("Mira", Race.HALFLING, CharClass.ROGUE).hero
            else -> GameState.newGame("Mira", Race.HUMAN, if (w == "staff") CharClass.WIZARD else CharClass.FIGHTER).hero.also { h ->
                h.equip(de.bornim.core.Gear(uid++, w, de.bornim.core.Rarity.COMMON, 3)) }
        } }
    val out = BufferedImage(F.W * 16, F.H * heroes.size, BufferedImage.TYPE_INT_RGB)
    for (r in heroes.indices) for (s in 0 until 16) {
        val hero = heroes[r]
        val img = F.draw(hero, s, 1)
        for (y in 0 until F.H) for (x in 0 until F.W) { val q = img[x, y]; out.setRGB(s * F.W + x, r * F.H + y, if ((q ushr 24) >= 128) q else 0x3A4430) }
    }
    ImageIO.write(out, "png", File("build/screens/mapfig_16.png"))
    println("wrote mapfig16")
}
