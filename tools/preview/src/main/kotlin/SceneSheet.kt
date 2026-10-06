package preview

import de.bornim.core.MonsterLook
import de.bornim.core.art.Act
import de.bornim.core.art.BattleScene
import de.bornim.core.art.MonsterArt
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** All forest spots by time of day, with the wolf standing where it would in a fight. */
fun renderSceneSheet() {
    val w = 270; val h = 370
    val spots = BattleScene.Spot.entries
    for ((name, deep) in listOf("forest" to false, "deep" to true)) {
        val lights = BattleScene.Light.entries
        val out = BufferedImage(w * spots.size, h * lights.size, BufferedImage.TYPE_INT_RGB)
        for ((r, light) in lights.withIndex()) for ((c, spot) in spots.withIndex()) {
            val img = BattleScene.forest(w, h, spot, light, deep, 11 + c * 7 + r)
            val wolf = MonsterArt.battleFrame("wolf", MonsterLook(c), Act.IDLE, 0, 0)
            val fx = (w * BattleScene.FOE_X - wolf.width / 2).toInt(); val fy = (h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf")).toInt()
            for (y in 0 until h) for (x in 0 until w) out.setRGB(c * w + x, r * h + y, img[x, y])
            for (y in 0 until wolf.height) for (x in 0 until wolf.width) {
                val p = wolf[x, y]
                if ((p ushr 24) > 128) out.setRGB(c * w + fx + x, r * h + fy + y, p)
            }
        }
        File("build/screens").mkdirs()
        ImageIO.write(out, "png", File("build/screens/scenes_$name.png"))
    }
    println("wrote scenes")
}

/** Frames of the wolf on a dusk scene for an animated preview: idle, bite, idle, pounce, hurt. */
fun renderWolfAnim() {
    val w = 270; val h = 370
    val bg = BattleScene.forest(w, h, BattleScene.Spot.CLEARING, BattleScene.Light.DUSK, false, 11)
    val look = MonsterLook(4)
    val seq = mutableListOf<Pair<de.bornim.core.art.PixelImage, Int>>()
    fun idle(n: Int) = repeat(n) { seq += MonsterArt.battleFrame("wolf", look, Act.IDLE, 0, it % 16) to 86 }
    fun act(a: Act, v: Int, ms: Int) = repeat(MonsterArt.frameCount("wolf", a, v)) { seq += MonsterArt.battleFrame("wolf", look, a, v, it) to ms }
    if (System.getenv("HOWL") != null) { idle(16); act(Act.HOWL, 0, 110); repeat(8) { seq += seq.last() }; idle(16) }
    else { idle(32); act(Act.ATTACK, 0, 45); idle(16); act(Act.ATTACK, 1, 45); idle(16); act(Act.HURT, 0, 60); idle(16) }
    File("build/screens/anim2").mkdirs()
    val durations = StringBuilder()
    for ((i, fr) in seq.withIndex()) {
        val (img, ms) = fr
        val out = BufferedImage(200 * 3, 120 * 3, BufferedImage.TYPE_INT_RGB)
        val fx = (w * BattleScene.FOE_X - img.width / 2).toInt(); val fy = (h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf")).toInt()
        for (y in 0 until 360) for (x in 0 until 600) {
            val sx = 70 + x / 3; val sy = 125 + y / 3
            val p = img[sx - fx, sy - fy]
            out.setRGB(x, y, if ((p ushr 24) > 128) de.bornim.core.art.mix(p, de.bornim.core.art.argb(0xE8B4A8), 0.0).let { c ->
                // dusk light on the sprite
                val r = ((c shr 16) and 0xFF) * 0xE8 / 255; val g = ((c shr 8) and 0xFF) * 0xB4 / 255; val b = (c and 0xFF) * 0xA8 / 255
                (0xFF shl 24) or (r shl 16) or (g shl 8) or b
            } else bg[sx, sy])
        }
        ImageIO.write(out, "png", File("build/screens/anim2/f%03d.png".format(i)))
        durations.append(ms).append('\n')
    }
    File("build/screens/anim2/durations.txt").writeText(durations.toString())
    println("wrote anim")
}

/** All cave spots by light, with the wolf standing where it would in a fight. */
fun renderCaveSheet() {
    val w = 270; val h = 370
    val spots = de.bornim.core.art.CaveScene.Spot.entries
    val lights = de.bornim.core.art.CaveScene.Light.entries
    val out = BufferedImage(w * spots.size, h * lights.size, BufferedImage.TYPE_INT_RGB)
    File("build/screens/caves").mkdirs()
    for ((r, light) in lights.withIndex()) for ((c, spot) in spots.withIndex()) {
        val img = de.bornim.core.art.CaveScene.cave(w, h, spot, light, 11 + c * 7 + r)
        val wolf = MonsterArt.battleFrame("wolf", MonsterLook(c), Act.IDLE, 0, 0)
        val fx = (w * BattleScene.FOE_X - wolf.width / 2).toInt(); val fy = (h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf")).toInt()
        val one = BufferedImage(w * 2, h * 2, BufferedImage.TYPE_INT_RGB)
        for (y in 0 until h) for (x in 0 until w) {
            val wp = wolf[x - fx, y - fy]
            val t = de.bornim.core.art.CaveScene.tint(spot, light)
            fun mul(a: Int, sh: Int) = ((a shr sh) and 0xFF) * ((t shr sh) and 0xFF) / 255 shl sh
            val p = if ((wp ushr 24) > 128) (0xFF shl 24) or mul(wp, 16) or mul(wp, 8) or mul(wp, 0) else img[x, y]
            out.setRGB(c * w + x, r * h + y, p)
            for (q in 0 until 4) one.setRGB(x * 2 + q % 2, y * 2 + q / 2, p)
        }
        ImageIO.write(one, "png", File("build/screens/caves/${spot.name.lowercase()}_${light.name.lowercase()}.png"))
    }
    ImageIO.write(out, "png", File("build/screens/scenes_cave.png"))
    println("wrote caves")
}

/** The whole cave map with its light, without characters: an overview for drafts. */
fun renderCaveMap() = renderMapOverview(de.bornim.core.Story.cave, lit = true, hero = 11 to 17)

/** A whole map without characters; caves with their light. */
fun renderMapOverview(map: de.bornim.core.MapDef, lit: Boolean = true, daylight: Float = 1f, hero: Pair<Int, Int> = -20 to -20, name: String = map.id) {
    val vm = de.bornim.game.GameViewModel(android.app.Application())
    vm.newGame("Grom", de.bornim.core.Race.HALF_ORC, de.bornim.core.CharClass.FIGHTER)
    val state = vm.game!!.state
    val T = de.bornim.core.art.WorldArt.T
    val w = map.width * T; val h = map.height * T
    val pix = IntArray(w * h)
    for (ty in 0 until map.height) for (tx in 0 until map.width) {
        val g = de.bornim.core.art.WorldArt.ground(map, tx, ty, state, 0)
        for (y in 0 until T) for (x in 0 until T) pix[(ty * T + y) * w + tx * T + x] = g[x, y]
    }
    for (o in de.bornim.core.art.WorldArt.objects(map, state, 0).sortedBy { it.sortY }) {
        for (y in 0 until o.img.height) for (x in 0 until o.img.width) {
            val p = o.img[x, y]; val px = o.x + x; val py = o.y + y
            if ((p ushr 24) > 128 && px in 0 until w && py in 0 until h) pix[py * w + px] = p
        }
    }
    val grid = if (lit) de.bornim.core.art.MapLight.lightmap(map, daylight, hero.first * T + 16, hero.second * T + 16, 0, 0, w, h) else null
    val cell = de.bornim.core.art.MapLight.RES
    val out = BufferedImage(w, h, BufferedImage.TYPE_INT_RGB)
    for (y in 0 until h) for (x in 0 until w) {
        // smooth the light grid between cell centres
        fun ch(s: Int): Int {
            val light = if (grid == null) 255 else (grid[x / cell, y / cell] shr s) and 0xFF
            return (((pix[y * w + x] shr s) and 0xFF) * light / 255).coerceIn(0, 255)
        }
        out.setRGB(x, y, (ch(16) shl 16) or (ch(8) shl 8) or ch(0))
    }
    File("build/screens").mkdirs()
    ImageIO.write(out, "png", File("build/screens/map_$name.png"))
    println("wrote map ${map.id}")
}

/** Draft sheets for the new hero figure: old versus new in a scene, all races, attack pose. */
fun renderHeroDrafts() {
    val w = 270; val h = 370
    var uid = 1L
    fun gear(base: String, r: de.bornim.core.Rarity = de.bornim.core.Rarity.COMMON) = de.bornim.core.Gear(uid++, base, r, 3)
    fun hero(race: de.bornim.core.Race, cls: de.bornim.core.CharClass, vararg extra: de.bornim.core.Gear, off: de.bornim.core.Gear? = null): de.bornim.core.Hero {
        val st = de.bornim.core.GameState.newGame("Test", race, cls)
        for (g in extra) st.hero.equip(g)
        off?.let { if (it.def.isWeapon) st.hero.equipOffHand(it) else st.hero.equip(it) }
        return st.hero
    }
    fun paste(out: BufferedImage, img: de.bornim.core.art.PixelImage, ox: Int, oy: Int, k: Int = 2, sx: Double = 1.0) {
        val ww = (img.width * sx).toInt(); val hh = (img.height * sx).toInt()
        for (y in 0 until hh) for (x in 0 until ww) {
            val p = img[(x / sx).toInt(), (y / sx).toInt()]
            if ((p ushr 24) < 128) continue
            for (q in 0 until k * k) {
                val px = (ox + x) * k + q % k; val py = (oy + y) * k + q / k
                if (px in 0 until out.width && py in 0 until out.height) out.setRGB(px, py, p)
            }
        }
    }
    fun scene(out: BufferedImage, col: Int, hero: de.bornim.core.Hero, newStyle: Boolean, act: de.bornim.core.art.HeroFigure.Act = de.bornim.core.art.HeroFigure.Act.IDLE, light: BattleScene.Light = BattleScene.Light.DUSK) {
        val bg = BattleScene.forest(w, h, BattleScene.Spot.CLEARING, light, false, 11 + col)
        val ox = col * w
        for (y in 0 until h) for (x in 0 until w) for (q in 0 until 4) out.setRGB((ox + x) * 2 + q % 2, y * 2 + q / 2, bg[x, y])
        val wolf = MonsterArt.battleFrame("wolf", MonsterLook(col), Act.IDLE, 0, 0)
        paste(out, wolf, ox + (w * BattleScene.FOE_X - wolf.width / 2).toInt(), (h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf")).toInt())
        if (newStyle) {
            val img = de.bornim.core.art.HeroFigure.frame(hero, act, 3)
            paste(out, img, ox + (w * BattleScene.HERO_X - img.width / 2).toInt(), (h * BattleScene.HERO_Y - de.bornim.core.art.HeroFigure.GROUND).toInt())
        } else {
            val img = de.bornim.core.art.HeroArt.battle(hero, de.bornim.core.art.Pose.IDLE, 3)
            val sx = 1.8
            paste(out, img, ox + (w * BattleScene.HERO_X - img.width * sx / 2).toInt(), (h * BattleScene.HERO_Y - img.height * sx * 0.97).toInt(), 2, sx)
        }
    }
    File("build/screens").mkdirs()
    // 1: old and new, four classes as they start
    val starts = listOf(de.bornim.core.CharClass.FIGHTER, de.bornim.core.CharClass.ROGUE, de.bornim.core.CharClass.WIZARD, de.bornim.core.CharClass.CLERIC).map { hero(de.bornim.core.Race.HUMAN, it) }
    val s1 = BufferedImage(w * 8 * 2, h * 2, BufferedImage.TYPE_INT_RGB)
    for ((i, hh) in starts.withIndex()) { scene(s1, i * 2, hh, false); scene(s1, i * 2 + 1, hh, true) }
    ImageIO.write(s1, "png", File("build/screens/hero_old_new.png"))
    // 2: races with better gear
    val geared = listOf(
        hero(de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.FIGHTER, gear("plate", de.bornim.core.Rarity.RARE), gear("helmet", de.bornim.core.Rarity.RARE), gear("cloak", de.bornim.core.Rarity.RARE), gear("gauntlets"), gear("longsword", de.bornim.core.Rarity.RARE), off = gear("shield", de.bornim.core.Rarity.UNCOMMON)),
        hero(de.bornim.core.Race.DWARF, de.bornim.core.CharClass.CLERIC, gear("chain_mail"), gear("great_helm"), gear("warhammer", de.bornim.core.Rarity.VERY_RARE), gear("cloak", de.bornim.core.Rarity.UNCOMMON), off = gear("shield")),
        hero(de.bornim.core.Race.ELF, de.bornim.core.CharClass.ROGUE, gear("studded_leather", de.bornim.core.Rarity.UNCOMMON), gear("hood"), gear("longbow", de.bornim.core.Rarity.RARE), gear("cloak", de.bornim.core.Rarity.UNCOMMON)),
        hero(de.bornim.core.Race.HALFLING, de.bornim.core.CharClass.ROGUE, gear("leather"), gear("shortsword"), gear("cloak"), off = gear("dagger")),
        hero(de.bornim.core.Race.HALF_ORC, de.bornim.core.CharClass.FIGHTER, gear("half_plate", de.bornim.core.Rarity.EPIC), gear("greataxe", de.bornim.core.Rarity.EPIC), gear("cloak", de.bornim.core.Rarity.EPIC), gear("greaves")),
        hero(de.bornim.core.Race.ELF, de.bornim.core.CharClass.WIZARD, gear("robe", de.bornim.core.Rarity.VERY_RARE), gear("staff", de.bornim.core.Rarity.VERY_RARE), gear("cloak", de.bornim.core.Rarity.VERY_RARE), off = gear("orb", de.bornim.core.Rarity.RARE)),
    )
    val s2 = BufferedImage(w * geared.size * 2, h * 2, BufferedImage.TYPE_INT_RGB)
    for ((i, hh) in geared.withIndex()) scene(s2, i, hh, true, light = if (i % 3 == 1) BattleScene.Light.NIGHT else if (i % 3 == 2) BattleScene.Light.DAY else BattleScene.Light.DUSK)
    ImageIO.write(s2, "png", File("build/screens/hero_races.png"))
    // 3: attack and hurt poses
    val s3 = BufferedImage(w * 4 * 2, h * 2, BufferedImage.TYPE_INT_RGB)
    scene(s3, 0, geared[0], true, de.bornim.core.art.HeroFigure.Act.ATTACK)
    scene(s3, 1, geared[4], true, de.bornim.core.art.HeroFigure.Act.ATTACK)
    scene(s3, 2, geared[2], true, de.bornim.core.art.HeroFigure.Act.ATTACK)
    scene(s3, 3, geared[0], true, de.bornim.core.art.HeroFigure.Act.HURT)
    ImageIO.write(s3, "png", File("build/screens/hero_poses.png"))
    println("wrote hero drafts")
}
