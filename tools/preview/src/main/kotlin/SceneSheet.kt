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

private data class Quad4(val a: String, val b: de.bornim.core.Hero, val c: de.bornim.core.art.HeroFigure.Act, val d: de.bornim.core.art.HeroFigure.Strike)

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
            val img = if (act == de.bornim.core.art.HeroFigure.Act.IDLE) de.bornim.core.art.HeroFigure.frame(hero, act, 3)
                else de.bornim.core.art.HeroFigure.frame(hero, act, de.bornim.core.art.HeroFigure.strikeFrame(de.bornim.core.art.HeroFigure.strikes(hero).first()), de.bornim.core.art.HeroFigure.strikes(hero).first())
            paste(out, img, ox + (w * BattleScene.HERO_X - de.bornim.core.art.HeroFigure.ANCHOR_X).toInt(), (h * BattleScene.HERO_Y - de.bornim.core.art.HeroFigure.GROUND).toInt())
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
    // 4: animation frames of each strike, for GIFs
    val F = de.bornim.core.art.HeroFigure
    val anim = File("build/screens/heroanim"); anim.deleteRecursively(); anim.mkdirs()
    val bg = BattleScene.forest(w, h, BattleScene.Spot.CLEARING, BattleScene.Light.DUSK, false, 12)
    val wolf = MonsterArt.battleFrame("wolf", MonsterLook(1), Act.IDLE, 0, 0)
    val F2 = de.bornim.core.art.HeroFigure
    fun idle(hh: de.bornim.core.Hero, n: Int) = (0 until n).map { F2.frame(hh, de.bornim.core.art.HeroFigure.Act.IDLE, it) }
    fun run(hh: de.bornim.core.Hero, act: de.bornim.core.art.HeroFigure.Act, strike: de.bornim.core.art.HeroFigure.Strike = F2.strikes(hh).first(), v: Int = 0) =
        (0 until F2.frameCount(act, strike, v)).map { F2.frame(hh, act, it, strike, v) }
    val clips = listOf(
        "intro" to ((0 until 16).map { F2.frame(geared[0], de.bornim.core.art.HeroFigure.Act.INTRO, it) } + run(geared[0], de.bornim.core.art.HeroFigure.Act.TURN) + idle(geared[0], 10)),
        "ambush" to ((0 until 8).map { F2.frame(geared[1], de.bornim.core.art.HeroFigure.Act.INTRO, it) } + run(geared[1], de.bornim.core.art.HeroFigure.Act.AMBUSHED) + idle(geared[1], 10)),
        "sword" to (idle(geared[0], 10) + run(geared[0], de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SLASH) + idle(geared[0], 8)),
        "thrust" to (idle(geared[0], 10) + run(geared[0], de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.THRUST) + idle(geared[0], 8)),
        "axe" to (idle(geared[4], 10) + run(geared[4], de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SMASH) + idle(geared[4], 8)),
        "bow" to (idle(geared[2], 10) + run(geared[2], de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SHOOT) + idle(geared[2], 8)),
        "cast" to (idle(geared[5], 10) + run(geared[5], de.bornim.core.art.HeroFigure.Act.CAST) + idle(geared[5], 8)),
        "block" to (idle(geared[0], 10) + run(geared[0], de.bornim.core.art.HeroFigure.Act.BLOCK) + idle(geared[0], 8)),
        "hurt" to (idle(geared[1], 10) + run(geared[1], de.bornim.core.art.HeroFigure.Act.HURT) + idle(geared[1], 8)),
    ) + (0 until F2.victoryVariants).map { v -> "victory$v" to (idle(geared[v % 2 * 4], 6) + run(geared[v % 2 * 4], de.bornim.core.art.HeroFigure.Act.VICTORY, v = v) + List(14) { run(geared[v % 2 * 4], de.bornim.core.art.HeroFigure.Act.VICTORY, v = v).last() }) }
    for ((name, seq) in clips) {
        val dir = File(anim, name); dir.mkdirs()
        for ((i, img) in seq.withIndex()) {
            val out = BufferedImage(w * 2, h * 2, BufferedImage.TYPE_INT_RGB)
            for (y in 0 until h) for (x in 0 until w) for (q in 0 until 4) out.setRGB(x * 2 + q % 2, y * 2 + q / 2, bg[x, y])
            paste(out, wolf, (w * BattleScene.FOE_X - wolf.width / 2).toInt(), (h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf")).toInt())
            paste(out, img, (w * BattleScene.HERO_X - F.ANCHOR_X).toInt(), (h * BattleScene.HERO_Y - F.GROUND).toInt())
            ImageIO.write(out.getSubimage(0, 260, w * 2, h * 2 - 260), "png", File(dir, "f%03d.png".format(i)))
        }
    }
    println("wrote hero drafts")
}

/** Turntable of one dressed figure: rows of poses, columns of yaw angles, plus every frame of the turn sequences. */
fun renderDollSheet() {
    val F = de.bornim.core.art.HeroFigure
    var uid = 1L
    fun gear(base: String, r: de.bornim.core.Rarity = de.bornim.core.Rarity.COMMON) = de.bornim.core.Gear(uid++, base, r, 3)
    val st = de.bornim.core.GameState.newGame("Puppe", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.FIGHTER)
    for (g in listOf(gear("plate", de.bornim.core.Rarity.RARE), gear("helmet"), gear("cloak", de.bornim.core.Rarity.RARE), gear("gauntlets"), gear("longsword", de.bornim.core.Rarity.RARE), gear("shield", de.bornim.core.Rarity.UNCOMMON))) st.hero.equip(g)
    val hero = st.hero
    val yaws = (0..12).map { it * 15.0 }
    val rows = listOf("stand" to F.STAND, "ready" to F.READY, "block" to F.BLOCK, "hit" to F.SLASH_HIT)
    val cw = 110; val ch = 150; val k = 2
    fun sheet(cells: List<List<Pair<String, de.bornim.core.art.PixelImage>>>, file: String) {
        val cols = cells.maxOf { it.size }
        val out = BufferedImage(cw * cols * k, ch * cells.size * k, BufferedImage.TYPE_INT_RGB)
        val g = out.createGraphics(); g.color = java.awt.Color(0x6A706A); g.fillRect(0, 0, out.width, out.height)
        for ((ri, row) in cells.withIndex()) for ((ci, cell) in row.withIndex()) {
            val img = cell.second
            val ox = ci * cw + cw / 2 - F.ANCHOR_X; val oy = ri * ch + ch - 4 - F.GROUND
            for (y in 0 until img.height) for (x in 0 until img.width) {
                val p = img[x, y]; if ((p ushr 24) < 128) continue
                val px = ox + x; val py = oy + y
                if (px !in ci * cw until (ci + 1) * cw || py !in ri * ch until (ri + 1) * ch) continue
                for (q in 0 until k * k) out.setRGB(px * k + q % k, py * k + q / k, p)
            }
            g.color = java.awt.Color(0xF0E8D8); g.drawString(cell.first, ci * cw * k + 4, ri * ch * k + 14)
        }
        ImageIO.write(out, "png", File("build/screens/$file"))
    }
    File("build/screens").mkdirs()
    sheet(rows.map { (n, r) -> yaws.map { y -> "$n ${y.toInt()}°" to F.draw(hero, r.copy(yaw = y), "doll/$n/$y") } }, "doll_turntable.png")
    fun seq(act: de.bornim.core.art.HeroFigure.Act) = (0 until F.frameCount(act)).map { "${act.name.lowercase()} $it" to F.frame(hero, act, it) }
    sheet(listOf(seq(de.bornim.core.art.HeroFigure.Act.TURN), seq(de.bornim.core.art.HeroFigure.Act.AMBUSHED), seq(de.bornim.core.art.HeroFigure.Act.BLOCK)), "doll_sequences.png")
    println("wrote doll")
}

/** Every weapon large on a plain background, for checking the drawings. */
fun renderWeaponSheet() {
    val bases = listOf("dagger", "shortsword", "scimitar", "rapier", "longsword", "greatsword", "handaxe", "battleaxe", "greataxe", "mace",
        "warhammer", "maul", "spear", "halberd", "quarterstaff", "staff", "wand", "light_crossbow")
    val cw = 90; val ch = 90; val cols = 6; val k = 3
    val out = BufferedImage(cw * cols * k, ch * ((bases.size + cols - 1) / cols) * 2 * k, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x3A4038); g.fillRect(0, 0, out.width, out.height)
    for ((i, b) in bases.withIndex()) for ((row, r) in listOf(de.bornim.core.Rarity.COMMON, de.bornim.core.Rarity.EPIC).withIndex()) {
        val sc = de.bornim.core.art.Sculpt(cw, ch, 5)
        de.bornim.core.art.WeaponArt(sc).draw(b, r, 22.0, 66.0, -42.0)
        sc.outline(de.bornim.core.art.argb(0x14100E))
        val ox = (i % cols) * cw; val oy = ((i / cols) * 2 + row) * ch
        for (y in 0 until ch) for (x in 0 until cw) {
            val p = sc.img[x, y]
            if ((p ushr 24) < 128) continue
            for (q in 0 until k * k) out.setRGB((ox + x) * k + q % k, (oy + y) * k + q / k, p)
        }
        g.color = java.awt.Color(0xE8E0D0); g.drawString(b + if (row == 1) " (episch)" else "", ox * k + 6, oy * k + 16)
    }
    ImageIO.write(out, "png", File("build/screens/weapons.png"))
    println("wrote weapons")
}

/** The new 3D doll: all peoples side by side, turntables, builds and skin tones. */
fun renderDollModels() {
    val cw = 110; val ch = 182; val k = 3
    val px = 0.75
    fun sheet(rows: List<List<Pair<String, de.bornim.core.art.Doll.() -> de.bornim.core.art.DepthImage>>>, dolls: List<List<de.bornim.core.art.Doll>>, file: String, ruler: Boolean = false) {
        val cols = rows.maxOf { it.size }
        val out = BufferedImage(cw * cols * k, ch * rows.size * k, BufferedImage.TYPE_INT_RGB)
        val g = out.createGraphics(); g.color = java.awt.Color(0x5E625C); g.fillRect(0, 0, out.width, out.height)
        for ((ri, row) in rows.withIndex()) {
            if (ruler) {
                g.color = java.awt.Color(0x6E726A)
                for (cm in listOf(50, 100, 150)) { val y = (ri * ch + 174 - cm * px) * k; g.drawLine(0, y.toInt(), out.width, y.toInt()); g.drawString("$cm cm", 4, y.toInt() - 3) }
            }
            for ((ci, cell) in row.withIndex()) {
                val t0 = System.nanoTime()
                val im = cell.second(dolls[ri][ci]).img
                val ms = (System.nanoTime() - t0) / 1_000_000
                for (y in 0 until im.height) for (x in 0 until im.width) {
                    val p = im[x, y]; if ((p ushr 24) < 128) continue
                    for (q in 0 until k * k) out.setRGB((ci * cw + x) * k + q % k, (ri * ch + y) * k + q / k, p)
                }
                g.color = java.awt.Color(0xF0E8D8); g.drawString(cell.first, ci * cw * k + 6, ri * ch * k + 16)
                println("${cell.first}: $ms ms")
            }
        }
        File("build/screens").mkdirs()
        ImageIO.write(out, "png", File("build/screens/$file"))
    }
    val D = de.bornim.core.art.Doll::class
    fun doll(r: de.bornim.core.Race, s: de.bornim.core.Sex, b: de.bornim.core.Build = de.bornim.core.Build.AVERAGE, skin: Int = 1, hair: Int = 0) = de.bornim.core.art.Doll(r, s, b, skin, hair)
    fun pic(yaw: Double): de.bornim.core.art.Doll.() -> de.bornim.core.art.DepthImage = { render(cw, ch, cw / 2.0, 174.0, px, de.bornim.core.art.Doll.REST.copy(yaw = yaw)) }
    val races = de.bornim.core.Race.entries
    val sexes = de.bornim.core.Sex.entries
    // 1: every people, both sexes, front and three-quarter
    val lineup = races.flatMap { r -> sexes.map { s -> doll(r, s) } }
    sheet(listOf(lineup.map { d -> "${d.race.title.de} ${d.sex.title.de.take(1)}" to pic(20.0) }, lineup.map { "  ${it.height.toInt()} cm" to pic(140.0) }), listOf(lineup, lineup), "doll_voelker.png", ruler = true)
    // 2: turntables
    val turn = listOf(doll(races[0], sexes[0]), doll(races[0], sexes[1], skin = 3, hair = 2), doll(de.bornim.core.Race.DWARF, sexes[0], skin = 0), doll(de.bornim.core.Race.HALF_ORC, sexes[1], skin = 1, hair = 0), doll(de.bornim.core.Race.ELF, sexes[1], skin = 0))
    val yaws = listOf(0.0, 30.0, 60.0, 90.0, 120.0, 150.0, 180.0)
    sheet(turn.map { _ -> yaws.map { y -> "${y.toInt()}°" to pic(y) } }, turn.map { d -> yaws.map { d } }, "doll_drehung.png")
    // 3: builds and skins
    val bs = races.map { r -> de.bornim.core.Build.entries.flatMap { b -> listOf(doll(r, sexes[0], b, skin = b.ordinal), doll(r, sexes[1], b, skin = 3 - b.ordinal, hair = b.ordinal + 1)) } }
    sheet(bs.map { row -> row.map { d -> "${d.build.title.de.take(6)} ${d.sex.title.de.take(1)}" to pic(25.0) } }, bs, "doll_statur.png", ruler = true)
    // 4: close-ups of head and shoulders, large and at game size
    run {
        val bw = 150; val bh = 150; val big = 2.6
        val list = races.flatMap { r -> sexes.map { s -> doll(r, s) } }
        val out = BufferedImage(bw * list.size * 2, bh * 3 * 2, BufferedImage.TYPE_INT_RGB)
        val gg = out.createGraphics(); gg.color = java.awt.Color(0x5E625C); gg.fillRect(0, 0, out.width, out.height)
        for ((i, d) in list.withIndex()) for ((row, yaw) in listOf(15.0, 60.0).withIndex()) {
            val im = d.render(bw, bh, bw / 2.0, bh - 6 + (d.height * 0.7) * big, big, de.bornim.core.art.Doll.REST.copy(yaw = yaw)).img
            for (y in 0 until bh) for (x in 0 until bw) { val p = im[x, y]; if ((p ushr 24) < 128) continue; for (q in 0 until 4) out.setRGB((i * bw + x) * 2 + q % 2, (row * bh + y) * 2 + q / 2, p) }
            // game size, zoomed six times
            val sm = d.render(40, 40, 20.0, 40 - 4 + (d.height * 0.7) * 0.75, 0.75, de.bornim.core.art.Doll.REST.copy(yaw = 15.0)).img
            for (y in 0 until 40) for (x in 0 until 40) { val p = sm[x, y]; if ((p ushr 24) < 128) continue
                for (q in 0 until 36) { val xx = i * bw * 2 + 30 + x * 6 + q % 6; val yy = 2 * bh * 2 + y * 6 + q / 6 - 0; if (yy < out.height) out.setRGB(xx, yy, p) } }
        }
        ImageIO.write(out, "png", File("build/screens/doll_nah.png"))
    }
    println("wrote doll models")
}


/** The 3D doll dressed: several heroes in their gear, in three poses, and one turned all the way round. */
fun renderDollDressed() {
    val cw = 120; val ch = 186; val k = 3; val px = 0.75
    var uid = 1L
    fun g(base: String, r: de.bornim.core.Rarity = de.bornim.core.Rarity.COMMON) = de.bornim.core.Gear(uid++, base, r, 3)
    class H(val name: String, val doll: de.bornim.core.art.Doll, val outfit: de.bornim.core.art.Outfit)
    fun hero(name: String, race: de.bornim.core.Race, sex: de.bornim.core.Sex, cls: de.bornim.core.CharClass, skin: Int, hair: Int, vararg gear: Pair<de.bornim.core.GearSlot, de.bornim.core.Gear>) =
        H(name, de.bornim.core.art.Doll(race, sex, de.bornim.core.Build.AVERAGE, skin, hair), de.bornim.core.art.Outfit(cls, gear.toMap()))
    val M = de.bornim.core.Sex.MALE; val W = de.bornim.core.Sex.FEMALE
    val heroes = listOf(
        hero("Ritter", de.bornim.core.Race.HUMAN, M, de.bornim.core.CharClass.FIGHTER, 1, 0, de.bornim.core.GearSlot.CHEST to g("plate", de.bornim.core.Rarity.RARE), de.bornim.core.GearSlot.HEAD to g("helmet"), de.bornim.core.GearSlot.CLOAK to g("cloak", de.bornim.core.Rarity.RARE), de.bornim.core.GearSlot.ARMS to g("gauntlets"), de.bornim.core.GearSlot.LEGS to g("greaves"), de.bornim.core.GearSlot.MAIN_HAND to g("longsword", de.bornim.core.Rarity.RARE), de.bornim.core.GearSlot.OFF_HAND to g("shield", de.bornim.core.Rarity.UNCOMMON)),
        hero("Zwergenpriester", de.bornim.core.Race.DWARF, M, de.bornim.core.CharClass.CLERIC, 0, 0, de.bornim.core.GearSlot.CHEST to g("chain_mail"), de.bornim.core.GearSlot.HEAD to g("great_helm"), de.bornim.core.GearSlot.CLOAK to g("mantle", de.bornim.core.Rarity.UNCOMMON), de.bornim.core.GearSlot.MAIN_HAND to g("warhammer", de.bornim.core.Rarity.VERY_RARE), de.bornim.core.GearSlot.OFF_HAND to g("shield"), de.bornim.core.GearSlot.LEGS to g("boots")),
        hero("Elfenschurkin", de.bornim.core.Race.ELF, W, de.bornim.core.CharClass.ROGUE, 2, 2, de.bornim.core.GearSlot.CHEST to g("studded_leather", de.bornim.core.Rarity.UNCOMMON), de.bornim.core.GearSlot.HEAD to g("hood"), de.bornim.core.GearSlot.CLOAK to g("cloak", de.bornim.core.Rarity.UNCOMMON), de.bornim.core.GearSlot.LEGS to g("boots"), de.bornim.core.GearSlot.ARMS to g("gloves"), de.bornim.core.GearSlot.MAIN_HAND to g("shortsword"), de.bornim.core.GearSlot.OFF_HAND to g("dagger")),
        hero("Halblingsdiebin", de.bornim.core.Race.HALFLING, W, de.bornim.core.CharClass.ROGUE, 1, 1, de.bornim.core.GearSlot.CHEST to g("leather"), de.bornim.core.GearSlot.HEAD to g("leather_cap"), de.bornim.core.GearSlot.ARMS to g("wraps"), de.bornim.core.GearSlot.MAIN_HAND to g("shortsword")),
        hero("Halbork", de.bornim.core.Race.HALF_ORC, M, de.bornim.core.CharClass.FIGHTER, 1, 0, de.bornim.core.GearSlot.CHEST to g("half_plate", de.bornim.core.Rarity.EPIC), de.bornim.core.GearSlot.MAIN_HAND to g("greataxe", de.bornim.core.Rarity.EPIC), de.bornim.core.GearSlot.ARMS to g("bracers"), de.bornim.core.GearSlot.LEGS to g("chain_leggings"), de.bornim.core.GearSlot.CLOAK to g("cloak", de.bornim.core.Rarity.EPIC)),
        hero("Magierin", de.bornim.core.Race.HUMAN, W, de.bornim.core.CharClass.WIZARD, 3, 2, de.bornim.core.GearSlot.MAIN_HAND to g("staff", de.bornim.core.Rarity.VERY_RARE), de.bornim.core.GearSlot.OFF_HAND to g("orb", de.bornim.core.Rarity.RARE), de.bornim.core.GearSlot.CLOAK to g("cloak", de.bornim.core.Rarity.VERY_RARE)),
        hero("Elfenpriester", de.bornim.core.Race.ELF, M, de.bornim.core.CharClass.CLERIC, 0, 0, de.bornim.core.GearSlot.CHEST to g("breastplate", de.bornim.core.Rarity.RARE), de.bornim.core.GearSlot.HEAD to g("circlet", de.bornim.core.Rarity.RARE), de.bornim.core.GearSlot.MAIN_HAND to g("mace"), de.bornim.core.GearSlot.OFF_HAND to g("shield", de.bornim.core.Rarity.RARE), de.bornim.core.GearSlot.LEGS to g("boots")),
        hero("Schuppenkrieger", de.bornim.core.Race.HUMAN, M, de.bornim.core.CharClass.FIGHTER, 2, 2, de.bornim.core.GearSlot.CHEST to g("scale_mail"), de.bornim.core.GearSlot.HEAD to g("leather_cap"), de.bornim.core.GearSlot.MAIN_HAND to g("spear"), de.bornim.core.GearSlot.LEGS to g("boots"), de.bornim.core.GearSlot.ARMS to g("gloves")),
    )
    val F = de.bornim.core.art.HeroFigure
    val poses = listOf("Bereit" to F.READY, "Kampf" to F.STAND, "Block" to F.BLOCK)
    val out = BufferedImage(cw * heroes.size * k, ch * poses.size * k, BufferedImage.TYPE_INT_RGB)
    val gfx = out.createGraphics(); gfx.color = java.awt.Color(0x5E625C); gfx.fillRect(0, 0, out.width, out.height)
    for ((ci, hh) in heroes.withIndex()) for ((ri, pose) in poses.withIndex()) {
        val t0 = System.nanoTime()
        val rig = if (pose.first == "Block" && hh.outfit.twoHands) F.PARRY else pose.second
        val im = hh.doll.render(cw, ch, cw / 2.0, 178.0, px, rig, hh.outfit).img
        println("${hh.name}/${pose.first}: ${(System.nanoTime() - t0) / 1_000_000} ms")
        for (y in 0 until im.height) for (x in 0 until im.width) { val p = im[x, y]; if ((p ushr 24) < 128) continue; for (q in 0 until k * k) out.setRGB((ci * cw + x) * k + q % k, (ri * ch + y) * k + q / k, p) }
        gfx.color = java.awt.Color(0xF0E8D8); gfx.drawString(hh.name + " – " + pose.first, ci * cw * k + 6, ri * ch * k + 16)
    }
    File("build/screens").mkdirs()
    ImageIO.write(out, "png", File("build/screens/doll_angezogen.png"))
    // turntable of the knight and the dwarf
    val yaws = (0..12).map { it * 15.0 }
    val t = BufferedImage(cw * yaws.size * 2, ch * 2 * 2, BufferedImage.TYPE_INT_RGB)
    val g2 = t.createGraphics(); g2.color = java.awt.Color(0x5E625C); g2.fillRect(0, 0, t.width, t.height)
    for ((ri, hh) in listOf(heroes[0], heroes[1]).withIndex()) for ((ci, yaw) in yaws.withIndex()) {
        val im = hh.doll.render(cw, ch, cw / 2.0, 178.0, px, F.STAND.copy(yaw = yaw), hh.outfit).img
        for (y in 0 until im.height) for (x in 0 until im.width) { val p = im[x, y]; if ((p ushr 24) < 128) continue; for (q in 0 until 4) t.setRGB((ci * cw + x) * 2 + q % 2, (ri * ch + y) * 2 + q / 2, p) }
        g2.color = java.awt.Color(0xF0E8D8); g2.drawString("${yaw.toInt()}°", ci * cw * 2 + 6, ri * ch * 2 + 16)
    }
    ImageIO.write(t, "png", File("build/screens/doll_angezogen_drehung.png"))
    println("wrote dressed dolls")
}

/** Runs every frame of every animation for sword-and-board heroes and reports where a blade passes through the shield. */
fun checkClashes() {
    val F = de.bornim.core.art.HeroFigure
    var uid = 1L
    fun g(base: String) = de.bornim.core.Gear(uid++, base, de.bornim.core.Rarity.COMMON, 3)
    var bad = 0; var total = 0; var rawBad = 0
    val byAct = sortedMapOf<String, Int>()
    var bodyBad = 0
    val bodyAct = sortedMapOf<String, Int>()
    for (race in de.bornim.core.Race.entries) for (weapon in listOf("longsword", "mace", "shortsword", "warhammer", "spear", "scimitar")) {
        val doll = de.bornim.core.art.Doll(race, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE)
        val outfit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.MAIN_HAND to g(weapon), de.bornim.core.GearSlot.OFF_HAND to g("shield")))
        val runs = listOf(de.bornim.core.art.HeroFigure.Act.IDLE to de.bornim.core.art.HeroFigure.Strike.SLASH, de.bornim.core.art.HeroFigure.Act.INTRO to de.bornim.core.art.HeroFigure.Strike.SLASH, de.bornim.core.art.HeroFigure.Act.TURN to de.bornim.core.art.HeroFigure.Strike.SLASH, de.bornim.core.art.HeroFigure.Act.AMBUSHED to de.bornim.core.art.HeroFigure.Strike.SLASH, de.bornim.core.art.HeroFigure.Act.BLOCK to de.bornim.core.art.HeroFigure.Strike.SLASH, de.bornim.core.art.HeroFigure.Act.HURT to de.bornim.core.art.HeroFigure.Strike.SLASH,
            de.bornim.core.art.HeroFigure.Act.ATTACK to de.bornim.core.art.HeroFigure.Strike.SLASH, de.bornim.core.art.HeroFigure.Act.ATTACK to de.bornim.core.art.HeroFigure.Strike.THRUST, de.bornim.core.art.HeroFigure.Act.ATTACK to de.bornim.core.art.HeroFigure.Strike.SMASH) + listOf(0, 2, 3).map { de.bornim.core.art.HeroFigure.Act.VICTORY to de.bornim.core.art.HeroFigure.Strike.SLASH }
        for ((ri, run) in runs.withIndex()) {
            val variant = if (run.first == de.bornim.core.art.HeroFigure.Act.VICTORY) listOf(0, 2, 3)[ri - 9] else 0
            for ((i, rig) in F.sequence(run.first, run.second, variant).withIndex()) {
                total++
                val raw = run { val sk = doll.Skeleton(rig, shieldArm = true); val d = de.bornim.core.art.Dress(doll, sk, doll.body(sk), outfit); d.solids(); d.weaponThroughShield() }
                if (raw != null && run.first == de.bornim.core.art.HeroFigure.Act.VICTORY && rawBad < 400) println("ROH: ${race.name} $weapon v$variant Bild $i bei ${(raw * 100).toInt()} %")
                if (raw != null) { rawBad++; byAct["${run.first}/${run.second}"] = (byAct["${run.first}/${run.second}"] ?: 0) + 1 }
                val dress = doll.fit(rig, outfit).second!!.first
                dress.weaponThroughShield()?.let { t -> bad++; if (bad <= 60) println("DURCH: ${race.name} $weapon ${run.first}/${run.second}/$variant Bild $i bei ${(t * 100).toInt()} %") }
                dress.weaponThroughBody()?.let { t -> bodyBad++; bodyAct["${run.first}/${run.second}"] = (bodyAct["${run.first}/${run.second}"] ?: 0) + 1; if (bodyBad <= 20) println("KÖRPER: ${race.name} $weapon ${run.first}/${run.second}/$variant Bild $i bei ${(t * 100).toInt()} %") }
            }
        }
    }
    for (race in de.bornim.core.Race.entries) {
        val doll = de.bornim.core.art.Doll(race, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE)
        val sk = doll.Skeleton(de.bornim.core.art.HeroFigure.BLOCK, shieldArm = true)
        val fa = sk.wrist[1] - sk.elbow[1]
        val deg = Math.toDegrees(Math.atan2(fa.y, Math.sqrt(fa.x * fa.x + fa.z * fa.z)))
        val ua = sk.elbow[1] - sk.shoulder[1]
        val fwd = Math.toDegrees(Math.atan2(ua.z, Math.abs(ua.x)))
        println("BLOCK ${race.name}: Unterarm ${"%.0f".format(deg)}° zur Waagerechten, Ellbogen ${"%.0f".format(sk.elbow[1].y - sk.shoulder[1].y)} cm über der Schulter, Oberarm ${"%.0f".format(fwd)}° nach vorn (0 = seitlich, 90 = gerade vorn)")
    }
    run {
        val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE)
        for ((n, r) in listOf("Hieb" to de.bornim.core.art.HeroFigure.SLASH_HIT, "Stich" to de.bornim.core.art.HeroFigure.THRUST_HIT, "Schlag" to de.bornim.core.art.HeroFigure.SMASH_HIT)) {
            val sk = doll.Skeleton(r, shieldArm = true)
            val a = sk.elbow[1] - sk.shoulder[1]; val b = sk.wrist[1] - sk.elbow[1]
            val bend = 180 - Math.toDegrees(Math.acos((a.norm() dot b.norm()).coerceIn(-1.0, 1.0)))
            println("$n: Ellbogen ${"%.0f".format(bend)}° (180 = gestreckt)")
        }
    }
    // two-handed: both hands on the grip in every blow, the parry braced by the free forearm
    var twoBad = 0; var twoTotal = 0
    for (race in de.bornim.core.Race.entries) for (weapon in listOf("greatsword", "greataxe", "quarterstaff", "halberd", "maul")) {
        val doll = de.bornim.core.art.Doll(race, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE)
        val outfit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.MAIN_HAND to g(weapon)))
        val runs = listOf(
            Triple(de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Strike.SLASH, 0), Triple(de.bornim.core.art.HeroFigure.Act.BLOCK, de.bornim.core.art.HeroFigure.Strike.SLASH, 1), Triple(de.bornim.core.art.HeroFigure.Act.BLOCK, de.bornim.core.art.HeroFigure.Strike.SLASH, 3),
            Triple(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SLASH, 0), Triple(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SMASH, 0),
            Triple(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.THRUST, 0))
            // staves are never thrust (see HeroFigure.strikes): their back end would run through the hip
            .filter { weapon != "quarterstaff" || it.second != de.bornim.core.art.HeroFigure.Strike.THRUST }
        for (run in runs) for ((i, rig) in F.sequence(run.first, run.second, run.third).withIndex()) {
            twoTotal++
            val dress = doll.fit(rig, outfit).second!!.first
            dress.weaponThroughBody()?.let { t -> twoBad++; if (twoBad <= 10) println("ZWEIHAND: ${race.name} $weapon ${run.first}/${run.second}/${run.third} Bild $i bei ${(t * 100).toInt()} %") }
        }
        if (weapon == "greatsword" || weapon == "greataxe") for ((pn, pr) in listOf("tief" to F.PARRY, "hoch" to F.PARRY_HIGH)) {
            val sk = doll.fit(pr, outfit).first
            val fa = (sk.wrist[0] - sk.elbow[0]).norm()
            val cross = Math.toDegrees(Math.acos(Math.abs(fa dot sk.weapon).coerceIn(0.0, 1.0)))
            val hand = sk.hand(1)
            val mid = sk.elbow[0].lerp(sk.wrist[0], 0.5)
            val along = ((mid - hand) dot sk.weapon) / de.bornim.core.art.Dress.reach(weapon)
            val gap = (0..20).minOf { k -> val q = sk.elbow[0].lerp(sk.wrist[0], k / 20.0) - hand; (q - sk.weapon * (q dot sk.weapon)).len() }
            println("PARADE $pn ${race.name} $weapon: Unterarm ${"%.0f".format(cross)}° zur Waffe, bei ${"%.0f".format(along * 100)} % der Länge, ${"%.0f".format(gap)} cm Abstand Unterarm–Waffe (Berührung bis ~5 cm), Hand auf ${sk.wrist[1].y.toInt()} cm")
        }
    }
    println("Zweihänder: $twoTotal Bilder, Klinge durch Körper: $twoBad")
    println("geprüft: $total Bilder, Klinge im Schild ohne Korrektur: $rawBad, mit Korrektur: $bad")
    println("ohne Korrektur je Ablauf: $byAct")
    println("Klinge durch Kopf oder Körper: $bodyBad, je Ablauf: $bodyAct")
}

/** The dressed 3D knight in the forest against the wolf: intro and turn, sword strike, block, as frame folders for GIFs. */
fun renderDollAnims() {
    val w = 270; val h = 370
    var uid = 1L
    fun g(base: String, r: de.bornim.core.Rarity = de.bornim.core.Rarity.COMMON) = de.bornim.core.Gear(uid++, base, r, 3)
    val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0)
    val outfit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(
        de.bornim.core.GearSlot.CHEST to g("plate", de.bornim.core.Rarity.RARE), de.bornim.core.GearSlot.HEAD to g("helmet"), de.bornim.core.GearSlot.CLOAK to g("cloak", de.bornim.core.Rarity.RARE),
        de.bornim.core.GearSlot.ARMS to g("gauntlets"), de.bornim.core.GearSlot.LEGS to g("greaves"), de.bornim.core.GearSlot.MAIN_HAND to g("longsword", de.bornim.core.Rarity.RARE), de.bornim.core.GearSlot.OFF_HAND to g("shield", de.bornim.core.Rarity.UNCOMMON)))
    val bg = BattleScene.forest(w, h, BattleScene.Spot.CLEARING, BattleScene.Light.DUSK, false, 12)
    val wolf = MonsterArt.battleFrame("wolf", MonsterLook(1), Act.IDLE, 0, 0)
    fun seq(a: de.bornim.core.art.HeroFigure.Act, s: de.bornim.core.art.HeroFigure.Strike = de.bornim.core.art.HeroFigure.Strike.SLASH) = de.bornim.core.art.HeroFigure.sequence(a, s, 0)
    val idle = seq(de.bornim.core.art.HeroFigure.Act.IDLE).take(10)
    val clips = listOf(
        "intro" to (seq(de.bornim.core.art.HeroFigure.Act.INTRO).take(10) + seq(de.bornim.core.art.HeroFigure.Act.TURN) + idle),
        "schwert" to (idle + seq(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SLASH) + idle.take(6)),
        "block" to (idle + seq(de.bornim.core.art.HeroFigure.Act.BLOCK) + idle.take(6)),
        "stich" to (idle + seq(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.THRUST) + idle.take(6)),
        "schlag" to (idle + seq(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SMASH) + idle.take(6)),
        "parade" to (idle + de.bornim.core.art.HeroFigure.sequence(de.bornim.core.art.HeroFigure.Act.BLOCK, de.bornim.core.art.HeroFigure.Strike.SLASH, 1) + idle.take(6)),
        "zweihand" to (idle + seq(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SMASH) + idle.take(6)),
        "bogen" to (idle + seq(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SHOOT) + idle.take(6)),
        "zauber_stab" to (idle + de.bornim.core.art.HeroFigure.sequence(de.bornim.core.art.HeroFigure.Act.CAST, de.bornim.core.art.HeroFigure.Strike.CAST, 0) + idle.take(6)),
        "zauber_schild" to (idle + de.bornim.core.art.HeroFigure.sequence(de.bornim.core.art.HeroFigure.Act.CAST, de.bornim.core.art.HeroFigure.Strike.CAST, 3) + idle.take(6)),
        "treffer" to (idle + de.bornim.core.art.HeroFigure.sequence(de.bornim.core.art.HeroFigure.Act.HURT, de.bornim.core.art.HeroFigure.Strike.SLASH, 0) + idle.take(6)),
        "sieg" to (idle.take(4) + de.bornim.core.art.HeroFigure.sequence(de.bornim.core.art.HeroFigure.Act.VICTORY, de.bornim.core.art.HeroFigure.Strike.SLASH, 0) + List(8) { de.bornim.core.art.HeroFigure.VICTORY_POSES[0] }),
        "armbrust" to (List(6) { de.bornim.core.art.HeroFigure.XBOW_LOW } + de.bornim.core.art.HeroFigure.sequence(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SHOOT, 1) + List(6) { de.bornim.core.art.HeroFigure.XBOW_LOW.copy(draw = 0.0) }),
    )
    val dir0 = File("build/screens/dollanim"); dir0.deleteRecursively(); dir0.mkdirs()
    for ((name, rigs) in clips) {
        val dir = File(dir0, name); dir.mkdirs()
        for ((i, rig) in rigs.withIndex()) {
            val cw = 150; val chh = 190
            val kit = when (name) {
                "schlag" -> de.bornim.core.art.Outfit(outfit.cls, outfit.items + (de.bornim.core.GearSlot.MAIN_HAND to g("warhammer", de.bornim.core.Rarity.RARE)))
                "parade", "zweihand" -> de.bornim.core.art.Outfit(outfit.cls, (outfit.items - de.bornim.core.GearSlot.OFF_HAND) + (de.bornim.core.GearSlot.MAIN_HAND to g("greatsword", de.bornim.core.Rarity.RARE)))
                "zauber_stab" -> de.bornim.core.art.Outfit(de.bornim.core.CharClass.WIZARD, mapOf(de.bornim.core.GearSlot.CHEST to g("robe", de.bornim.core.Rarity.RARE), de.bornim.core.GearSlot.MAIN_HAND to g("staff", de.bornim.core.Rarity.RARE)))
                "bogen" -> de.bornim.core.art.Outfit(outfit.cls, (outfit.items - de.bornim.core.GearSlot.OFF_HAND) + (de.bornim.core.GearSlot.MAIN_HAND to g("longbow", de.bornim.core.Rarity.RARE)))
                "armbrust" -> de.bornim.core.art.Outfit(outfit.cls, (outfit.items - de.bornim.core.GearSlot.OFF_HAND) + (de.bornim.core.GearSlot.MAIN_HAND to g("light_crossbow", de.bornim.core.Rarity.RARE)))
                else -> outfit
            }
            val im = doll.render(cw, chh, 70.0, 184.0, 0.75, rig, kit).img
            val out = BufferedImage(w * 2, h * 2, BufferedImage.TYPE_INT_RGB)
            for (y in 0 until h) for (x in 0 until w) for (q in 0 until 4) out.setRGB(x * 2 + q % 2, y * 2 + q / 2, bg[x, y])
            fun paste(img: de.bornim.core.art.PixelImage, ox: Int, oy: Int) {
                for (y in 0 until img.height) for (x in 0 until img.width) { val p = img[x, y]; if ((p ushr 24) < 128) continue
                    for (q in 0 until 4) { val px = (ox + x) * 2 + q % 2; val py = (oy + y) * 2 + q / 2; if (px in 0 until out.width && py in 0 until out.height) out.setRGB(px, py, p) } }
            }
            paste(wolf, (w * BattleScene.FOE_X - wolf.width / 2).toInt(), (h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf")).toInt())
            paste(im, (w * BattleScene.HERO_X - 70).toInt(), (h * BattleScene.HERO_Y - 184).toInt())
            ImageIO.write(out.getSubimage(0, 260, w * 2, h * 2 - 260), "png", File(dir, "f%03d.png".format(i)))
        }
    }
    println("wrote doll anims")
}


/** The block, large, from four sides, to judge the arms. */
fun renderBlockViews() {
    var uid = 1L
    fun g(base: String, r: de.bornim.core.Rarity = de.bornim.core.Rarity.COMMON) = de.bornim.core.Gear(uid++, base, r, 3)
    val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0)
    val outfit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(
        de.bornim.core.GearSlot.CHEST to g("chain_shirt"), de.bornim.core.GearSlot.MAIN_HAND to g("longsword"), de.bornim.core.GearSlot.OFF_HAND to g("shield")))
    val yaws = listOf(20.0, 90.0, 138.0, 180.0, 270.0)
    val cw = 300; val ch = 300; val px = 1.5
    val two = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("greatsword")))
    val axe = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.CHEST to g("half_plate"), de.bornim.core.GearSlot.MAIN_HAND to g("greataxe")))
    val rows = listOf<Pair<de.bornim.core.art.HeroFigure.Rig, de.bornim.core.art.Outfit?>>(
        de.bornim.core.art.HeroFigure.PARRY to two, de.bornim.core.art.HeroFigure.PARRY_HIGH to axe, de.bornim.core.art.HeroFigure.BLOCK_LOW to outfit)
    val out = BufferedImage(cw * yaws.size, ch * rows.size, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x5E625C); gg.fillRect(0, 0, out.width, out.height)
    for ((ri, row) in rows.withIndex()) for ((i, yaw) in yaws.withIndex()) {
        val im = doll.render(cw, ch, cw / 2.0, ch - 10.0 + 0.0, px, row.first.copy(yaw = yaw), row.second).img
        for (y in 0 until ch) for (x in 0 until cw) { val p = im[x, y]; if ((p ushr 24) >= 128) out.setRGB(i * cw + x, ri * ch + y, p) }
        gg.color = java.awt.Color(0xF0E8D8); gg.drawString("${yaw.toInt()}°", i * cw + 6, ri * ch + 16)
    }
    ImageIO.write(out, "png", File("build/screens/block_views.png"))
    println("wrote block views")
}


/** Back and side views of the bare doll, large, upper body only: to compare the shoulders with real people. */
fun renderBackViews() {
    val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0)
    val F = de.bornim.core.art.HeroFigure
    val rigs = listOf("Grundhaltung" to F.STAND, "Block" to F.BLOCK, "Ausholen" to F.SLASH_WIND)
    val yaws = listOf(90.0, 138.0, 160.0, 180.0)
    val cw = 260; val ch = 260; val px = 3.0
    val out = BufferedImage(cw * yaws.size, ch * rigs.size, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x5E625C); gg.fillRect(0, 0, out.width, out.height)
    for ((ri, r) in rigs.withIndex()) for ((i, yaw) in yaws.withIndex()) {
        val im = doll.render(cw, ch, cw / 2.0, ch + 75 * px, px, r.second.copy(yaw = yaw), null).img
        for (y in 0 until ch) for (x in 0 until cw) { val p = im[x, y]; if ((p ushr 24) >= 128) out.setRGB(i * cw + x, ri * ch + y, p) }
        gg.color = java.awt.Color(0xF0E8D8); gg.drawString("${r.first} ${yaw.toInt()}°", i * cw + 6, ri * ch + 16)
    }
    ImageIO.write(out, "png", File("build/screens/back_views.png"))
    println("wrote back views")
}


/** Key frames of each blow, large: dressed and bare, from the fighting view and the front. */
fun renderAttackViews() {
    var uid = 1L
    fun g(base: String) = de.bornim.core.Gear(uid++, base, de.bornim.core.Rarity.COMMON, 3)
    val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0)
    fun kit(w: String) = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.CHEST to g("chain_shirt"), de.bornim.core.GearSlot.MAIN_HAND to g(w), de.bornim.core.GearSlot.OFF_HAND to g("shield")))
    val F = de.bornim.core.art.HeroFigure
    val rows = listOf(
        Triple("Hieb", kit("longsword"), listOf(F.STAND, F.SLASH_WIND, F.SLASH_OVER, F.SLASH_OVER.lerp(F.SLASH_HIT, 0.5), F.SLASH_HIT, F.SLASH_FOLLOW)),
        Triple("Stich", kit("longsword"), listOf(F.STAND, F.THRUST_WIND, F.THRUST_WIND.lerp(F.THRUST_HIT, 0.33), F.THRUST_WIND.lerp(F.THRUST_HIT, 0.66), F.THRUST_HIT)),
        Triple("Schlag", kit("mace"), listOf(F.SMASH_RAISE, F.SMASH_WIND, F.SMASH_WIND.lerp(F.SMASH_OVER, 0.5), F.SMASH_OVER, F.SMASH_OVER.lerp(F.SMASH_HIT, 0.5), F.SMASH_HIT)),
    )
    val cw = 240; val ch = 280; val px = 1.25
    val views = listOf(138.0, 30.0, 90.0)
    val cols = rows.maxOf { it.third.size }
    val out = BufferedImage(cw * cols * views.size, ch * rows.size * 2, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x5E625C); gg.fillRect(0, 0, out.width, out.height)
    for ((ri, row) in rows.withIndex()) for ((vi, yaw) in views.withIndex()) for ((ci, rig) in row.third.withIndex()) for (bare in 0..1) {
        val im = doll.render(cw, ch, cw / 2.0 - 20, ch - 8.0, px, rig.copy(yaw = rig.yaw - de.bornim.core.art.HeroFigure.FIGHT_YAW + yaw), if (bare == 1) null else row.second).img
        val ox = (vi * cols + ci) * cw; val oy = (ri * 2 + bare) * ch
        for (y in 0 until ch) for (x in 0 until cw) { val p = im[x, y]; if ((p ushr 24) >= 128) out.setRGB(ox + x, oy + y, p) }
        gg.color = java.awt.Color(0xF0E8D8); gg.drawString("${row.first} ${ci + 1} – ${yaw.toInt()}°", ox + 6, oy + 16)
    }
    ImageIO.write(out, "png", File("build/screens/attack_views.png"))
    println("wrote attack views")
}


/** Archery and crossbow, large from several sides, with measurements of the draw. */
fun renderRangedViews() {
    var uid = 1L
    fun g(base: String) = de.bornim.core.Gear(uid++, base, de.bornim.core.Rarity.UNCOMMON, 3)
    val F = de.bornim.core.art.HeroFigure
    val elf = de.bornim.core.art.Doll(de.bornim.core.Race.ELF, de.bornim.core.Sex.FEMALE, de.bornim.core.Build.AVERAGE, 1, 1)
    val bow = de.bornim.core.art.Outfit(de.bornim.core.CharClass.ROGUE, mapOf(de.bornim.core.GearSlot.CHEST to g("leather"), de.bornim.core.GearSlot.MAIN_HAND to g("longbow")))
    val dwarf = de.bornim.core.art.Doll(de.bornim.core.Race.DWARF, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 1)
    val xbow = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.CHEST to g("chain_shirt"), de.bornim.core.GearSlot.MAIN_HAND to g("light_crossbow")))
    for (race in de.bornim.core.Race.entries) {
        val d = de.bornim.core.art.Doll(race, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE)
        val sk = d.fit(F.BOW_AIM, bow).first
        val a = sk.elbow[0] - sk.shoulder[0]; val b = sk.wrist[0] - sk.elbow[0]
        val bend = 180 - Math.toDegrees(Math.acos((a.norm() dot b.norm()).coerceIn(-1.0, 1.0)))
        val jaw = sk.head.apply(d.headC + de.bornim.core.art.P3(0.12 * d.hh, -0.3 * d.hh, 0.2 * d.hh))
        val toJaw = (sk.hand(1) - jaw).len()
        val arrow = (sk.hand(0) - sk.hand(1)).norm()
        val off = Math.toDegrees(Math.acos((arrow dot de.bornim.core.art.P3.Z).coerceIn(-1.0, 1.0)))
        val elbowH = sk.elbow[1].y - sk.hand(1).y
        // the drawing arm must stay clear of the head: nearest point of upper arm and forearm to the head's middle
        val hc = sk.head.apply(d.headC)
        fun segDist(p: de.bornim.core.art.P3, q: de.bornim.core.art.P3): Double { val dq = q - p; val t = (((hc - p) dot dq) / (dq dot dq)).coerceIn(0.0, 1.0); return (p + dq * t - hc).len() }
        val clear = segDist(sk.shoulder[1], sk.elbow[1]) - d.hh * 0.5
        val clearF = segDist(sk.elbow[1], sk.wrist[1]) - d.hh * 0.5
        val fa = sk.hand(1) - sk.elbow[1]
        val foreTop = Math.toDegrees(Math.atan2(fa.x, fa.z))
        val behind = sk.hand(1).z - sk.elbow[1].z
        println("BOGEN ${race.name}: Bogenarm ${"%.0f".format(bend)}° (180 gestreckt), Zughand ${"%.0f".format(toJaw)} cm vom Kinn, Pfeil ${"%.0f".format(off)}° neben der Gegnerrichtung, Zugellbogen ${"%.0f".format(elbowH)} cm über der Pfeilhöhe, " +
            "${"%.0f".format(behind)} cm hinter der Hand, Unterarm von oben ${"%.0f".format(foreTop)}° neben der Pfeillinie, Oberarm ${"%.0f".format(clear)} / Unterarm ${"%.0f".format(clearF)} cm vom Kopf frei")
        val xs = d.fit(F.XBOW_AIM, xbow).first
        val aimX = xs.weapon
        val s0 = xs.hand(1) + de.bornim.core.art.P3.Y * (de.bornim.core.art.Doll.STOCK_ABOVE_HAND * d.height)
        val plate = s0 - aimX * (de.bornim.core.art.Doll.STOCK_BACK * d.height) - de.bornim.core.art.P3.Y * (de.bornim.core.art.Doll.BUTT_DROP * d.height)
        val eye = xs.head.apply(d.headC + de.bornim.core.art.P3(0.0, 0.05 * d.hh, 0.0))
        val fore = s0 + aimX * (0.2 * d.height)
        val under = xs.hand(0)
        val lv = Math.toDegrees(Math.asin(aimX.y))
        val rel = plate - xs.shoulder[1]
        // how far the plate's back face is from the body: negative means pressed in, positive a gap
        val back = plate - aimX * (de.bornim.core.art.Doll.BUTT_HALF * d.height)
        val solids = d.body(xs)
        val gap = solids.minOf { it.dist(back) }
        println("ARMBRUST ${race.name}: Schaft ${"%.0f".format(lv)}° zur Waagerechten, Kolbenkappe ${"%.0f".format(rel dot aimX)} cm vor und ${"%.0f".format(rel.y)} cm über dem Schultergelenk, Abstand Kappe–Körper ${"%.1f".format(gap)} cm, " +
            "Schaft ${"%.0f".format(eye.y - s0.y)} cm unter Augenhöhe und ${"%.0f".format(s0.x - eye.x)} cm seitlich, Stützhand ${"%.0f".format(fore.y - under.y)} cm unter dem Schaft bei ${"%.0f".format(((under - s0) dot aimX))} cm vor dem Abzug, seitlich ${"%.0f".format(under.x - s0.x)} cm")
    }
    val rows = listOf(Triple(elf, bow, listOf(F.STAND, F.BOW_NOCK, F.BOW_AIM, F.BOW_RELEASE)), Triple(dwarf, xbow, listOf(F.STAND, F.XBOW_AIM, F.XBOW_RECOIL)))
    val views = listOf(138.0, 90.0, 30.0, 0.0)
    val cw = 230; val ch = 260; val px = 1.25
    val out = BufferedImage(cw * 4 * views.size, ch * rows.size, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x5E625C); gg.fillRect(0, 0, out.width, out.height)
    for ((ri, row) in rows.withIndex()) for ((vi, yaw) in views.withIndex()) for ((ci, rig) in row.third.withIndex()) {
        val im = row.first.render(cw, ch, cw / 2.0 - 10, ch - 8.0, px, rig.copy(yaw = rig.yaw - F.FIGHT_YAW + yaw), row.second).img
        val ox = (vi * 4 + ci) * cw; val oy = ri * ch
        for (y in 0 until ch) for (x in 0 until cw) { val p = im[x, y]; if ((p ushr 24) >= 128) out.setRGB(ox + x, oy + y, p) }
        gg.color = java.awt.Color(0xF0E8D8); gg.drawString("${ci + 1} – ${yaw.toInt()}°", ox + 6, oy + 16)
    }
    ImageIO.write(out, "png", File("build/screens/ranged_views.png"))
    // the aim, large: dressed and bare, from all round and from above
    val human = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0)
    val bareBow = de.bornim.core.art.Outfit(de.bornim.core.CharClass.ROGUE, mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("longbow")))
    val bareX = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("light_crossbow")))
    val big = listOf(Triple(elf, bow, F.BOW_AIM), Triple(human, bareBow, F.BOW_AIM), Triple(dwarf, xbow, F.XBOW_AIM), Triple(human, bareX, F.XBOW_AIM))
    val cams = listOf(0.0 to 15.0, 45.0 to 15.0, 90.0 to 15.0, 138.0 to 15.0, 180.0 to 15.0, 270.0 to 15.0, 138.0 to 80.0)
    val bw = 300; val bh = 330
    val out2 = BufferedImage(bw * cams.size, bh * big.size, BufferedImage.TYPE_INT_RGB)
    val g2 = out2.createGraphics(); g2.color = java.awt.Color(0x5E625C); g2.fillRect(0, 0, out2.width, out2.height)
    for ((ri, row) in big.withIndex()) for ((ci, cam) in cams.withIndex()) {
        val top = cam.second > 45
        val im = row.first.render(bw, bh, bw / 2.0, if (top) bh * 0.75 else bh - 8.0, 1.7, row.third.copy(yaw = row.third.yaw - F.FIGHT_YAW + cam.first), row.second, cam.second).img
        for (y in 0 until bh) for (x in 0 until bw) { val p = im[x, y]; if ((p ushr 24) >= 128) out2.setRGB(ci * bw + x, ri * bh + y, p) }
        g2.color = java.awt.Color(0xF0E8D8); g2.drawString(if (top) "von oben" else "${cam.first.toInt()}°", ci * bw + 6, ri * bh + 16)
    }
    ImageIO.write(out2, "png", File("build/screens/ranged_big.png"))
    // every frame of both sequences, from the side and half front, to catch a bad in-between
    val seqs = listOf(Triple(elf, bow, F.sequence(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SHOOT, 0)), Triple(dwarf, xbow, F.sequence(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SHOOT, 1)))
    val sw = 150; val sh = 190
    val n = seqs.maxOf { it.third.size }
    val out3 = BufferedImage(sw * n, sh * 4, BufferedImage.TYPE_INT_RGB)
    val g3 = out3.createGraphics(); g3.color = java.awt.Color(0x5E625C); g3.fillRect(0, 0, out3.width, out3.height)
    for ((si, sq) in seqs.withIndex()) for ((vi, yaw) in listOf(90.0, 40.0).withIndex()) for ((fi, rig) in sq.third.withIndex()) {
        val im = sq.first.render(sw, sh, sw / 2.0, sh - 6.0, 0.95, rig.copy(yaw = rig.yaw - F.FIGHT_YAW + yaw), sq.second).img
        val oy = (si * 2 + vi) * sh
        for (y in 0 until sh) for (x in 0 until sw) { val p = im[x, y]; if ((p ushr 24) >= 128) out3.setRGB(fi * sw + x, oy + y, p) }
        g3.color = java.awt.Color(0xF0E8D8); g3.drawString("$fi", fi * sw + 4, oy + 14)
    }
    ImageIO.write(out3, "png", File("build/screens/ranged_seq.png"))
    println("wrote ranged views")
}


/** Spells by what is cast with: key poses large from all round, every frame of each, and a check for staves through the body. */
fun renderCastViews() {
    var uid = 1L
    fun g(base: String, r: de.bornim.core.Rarity = de.bornim.core.Rarity.UNCOMMON) = de.bornim.core.Gear(uid++, base, r, 3)
    val F = de.bornim.core.art.HeroFigure
    fun kit(cls: de.bornim.core.CharClass, vararg items: Pair<de.bornim.core.GearSlot, String>) = de.bornim.core.art.Outfit(cls, items.associate { it.first to g(it.second) })
    val casters = listOf(
        Triple(de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 2), kit(de.bornim.core.CharClass.WIZARD, de.bornim.core.GearSlot.CHEST to "robe", de.bornim.core.GearSlot.MAIN_HAND to "staff"), "Stab"),
        Triple(de.bornim.core.art.Doll(de.bornim.core.Race.ELF, de.bornim.core.Sex.FEMALE, de.bornim.core.Build.SLIM, 1, 0), kit(de.bornim.core.CharClass.WIZARD, de.bornim.core.GearSlot.CHEST to "robe", de.bornim.core.GearSlot.MAIN_HAND to "wand", de.bornim.core.GearSlot.OFF_HAND to "tome"), "Zauberstab und Buch"),
        Triple(de.bornim.core.art.Doll(de.bornim.core.Race.HALFLING, de.bornim.core.Sex.FEMALE, de.bornim.core.Build.AVERAGE, 2, 1), kit(de.bornim.core.CharClass.WIZARD, de.bornim.core.GearSlot.CHEST to "robe", de.bornim.core.GearSlot.MAIN_HAND to "dagger", de.bornim.core.GearSlot.OFF_HAND to "orb"), "Kugel"),
        Triple(de.bornim.core.art.Doll(de.bornim.core.Race.DWARF, de.bornim.core.Sex.MALE, de.bornim.core.Build.STRONG, 1, 3), kit(de.bornim.core.CharClass.CLERIC, de.bornim.core.GearSlot.CHEST to "chain_shirt", de.bornim.core.GearSlot.MAIN_HAND to "mace", de.bornim.core.GearSlot.OFF_HAND to "holy_symbol"), "Heiligensymbol"),
        Triple(de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.FEMALE, de.bornim.core.Build.AVERAGE, 0, 1), kit(de.bornim.core.CharClass.CLERIC, de.bornim.core.GearSlot.CHEST to "chain_shirt", de.bornim.core.GearSlot.MAIN_HAND to "mace", de.bornim.core.GearSlot.OFF_HAND to "shield"), "Waffe und Schild"),
        Triple(de.bornim.core.art.Doll(de.bornim.core.Race.HALF_ORC, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0), kit(de.bornim.core.CharClass.WIZARD, de.bornim.core.GearSlot.MAIN_HAND to "staff"), "Stab, ohne Rüstung"),
    )
    fun variant(o: de.bornim.core.art.Outfit) = F.castVariant(o.items[de.bornim.core.GearSlot.MAIN_HAND]?.def, o.items[de.bornim.core.GearSlot.OFF_HAND]?.def)
    // the check: no staff, wand or weapon through head or body in any frame, for every people
    var bad = 0; var total = 0
    for (race in de.bornim.core.Race.entries) for ((_, o, name) in casters) {
        val d = de.bornim.core.art.Doll(race, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE)
        for ((i, rig) in F.sequence(de.bornim.core.art.HeroFigure.Act.CAST, de.bornim.core.art.HeroFigure.Strike.CAST, variant(o)).withIndex()) {
            total++
            val dress = d.fit(rig, o).second!!.first
            (dress.weaponThroughBody() ?: dress.weaponThroughShield())?.let { t -> bad++; if (bad <= 30) println("ZAUBER DURCH: ${race.name} $name Bild $i bei ${(t * 100).toInt()} %") }
        }
    }
    println("Zauber: $total Bilder, Waffe/Stab durch Körper oder Schild: $bad")
    val cams = listOf(20.0, 90.0, 138.0, 180.0, 270.0)
    val cw = 220; val ch = 270
    val keys = casters.flatMap { c -> val seq = F.sequence(de.bornim.core.art.HeroFigure.Act.CAST, de.bornim.core.art.HeroFigure.Strike.CAST, variant(c.second)); listOf(Triple(c, seq[7], "sammeln"), Triple(c, seq[10], "loslassen")) }
    val out = BufferedImage(cw * cams.size, ch * keys.size, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x4A4E48); gg.fillRect(0, 0, out.width, out.height)
    fun blend(dst: BufferedImage, x: Int, y: Int, p: Int) {
        val a = (p ushr 24) / 255.0; if (a <= 0.0) return
        val q = dst.getRGB(x, y)
        fun ch(sh: Int) = (((p shr sh) and 0xFF) * a + ((q shr sh) and 0xFF) * (1 - a)).toInt()
        dst.setRGB(x, y, (ch(16) shl 16) or (ch(8) shl 8) or ch(0))
    }
    for ((ri, k) in keys.withIndex()) for ((ci, yaw) in cams.withIndex()) {
        val im = k.first.first.render(cw, ch, cw / 2.0, ch - 8.0, 1.25, k.second.copy(yaw = k.second.yaw - F.FIGHT_YAW + yaw), k.first.second).img
        for (y in 0 until ch) for (x in 0 until cw) blend(out, ci * cw + x, ri * ch + y, im[x, y])
        gg.color = java.awt.Color(0xF0E8D8); gg.drawString("${k.first.third} – ${k.third} – ${yaw.toInt()}°", ci * cw + 6, ri * ch + 16)
    }
    ImageIO.write(out, "png", File("build/screens/cast_views.png"))
    val sw = 120; val sh = 160
    val n = 19
    val out2 = BufferedImage(sw * n, sh * casters.size * 2, BufferedImage.TYPE_INT_RGB)
    val g2 = out2.createGraphics(); g2.color = java.awt.Color(0x4A4E48); g2.fillRect(0, 0, out2.width, out2.height)
    for ((ci, c) in casters.withIndex()) for ((vi, yaw) in listOf(F.FIGHT_YAW, 60.0).withIndex()) for ((fi, rig) in F.sequence(de.bornim.core.art.HeroFigure.Act.CAST, de.bornim.core.art.HeroFigure.Strike.CAST, variant(c.second)).withIndex()) {
        val im = c.first.render(sw, sh, sw / 2.0, sh - 6.0, 0.75, rig.copy(yaw = rig.yaw - F.FIGHT_YAW + yaw), c.second).img
        val oy = (ci * 2 + vi) * sh
        for (y in 0 until sh) for (x in 0 until sw) blend(out2, fi * sw + x, oy + y, im[x, y])
        g2.color = java.awt.Color(0xF0E8D8); g2.drawString("$fi", fi * sw + 4, oy + 14)
    }
    ImageIO.write(out2, "png", File("build/screens/cast_seq.png"))
    println("wrote cast views")
}


/** Hurt, ambush and victory, large, for sword and shield and for a two-handed weapon: the key poses from the battle view and from the side. */
fun renderReactViews() {
    var uid = 1L
    fun g(base: String) = de.bornim.core.Gear(uid++, base, de.bornim.core.Rarity.UNCOMMON, 3)
    val F = de.bornim.core.art.HeroFigure
    val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0)
    val sword = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.CHEST to g("chain_shirt"), de.bornim.core.GearSlot.MAIN_HAND to g("longsword"), de.bornim.core.GearSlot.OFF_HAND to g("shield")))
    val great = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.CHEST to g("half_plate"), de.bornim.core.GearSlot.MAIN_HAND to g("greatsword")))
    val poses = listOf("Treffer" to F.HURT, "Hinterhalt" to F.STAGGER, "Sieg 1" to F.VICTORY_POSES[0], "Sieg 2" to F.VICTORY_POSES[1], "Sieg 3" to F.VICTORY_POSES[2], "Sieg 4" to F.VICTORY_POSES[3])
    val cw = 230; val ch = 280
    val rows = listOf(sword to null, sword to 90.0, great to null, great to 90.0)
    val out = BufferedImage(cw * poses.size, ch * rows.size, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x5E625C); gg.fillRect(0, 0, out.width, out.height)
    for ((ri, row) in rows.withIndex()) for ((ci, p) in poses.withIndex()) {
        val rig = if (row.second == null) p.second else p.second.copy(yaw = p.second.yaw + row.second!!)
        val im = doll.render(cw, ch, cw / 2.0, ch - 8.0, 1.3, rig, row.first).img
        for (y in 0 until ch) for (x in 0 until cw) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(ci * cw + x, ri * ch + y, q) }
        gg.color = java.awt.Color(0xF0E8D8); gg.drawString("${p.first}${if (row.second != null) " – seitlich" else ""}", ci * cw + 6, ri * ch + 16)
    }
    ImageIO.write(out, "png", File("build/screens/react_views.png"))
    println("wrote react views")
}


/** The rest of each stance, the turn to the foe, the shot or spell and the victory, for bow, crossbow and staff. */
fun renderStanceViews() {
    var uid = 1L
    fun g(base: String) = de.bornim.core.Gear(uid++, base, de.bornim.core.Rarity.UNCOMMON, 3)
    val F = de.bornim.core.art.HeroFigure
    val kits = listOf(
        Triple(de.bornim.core.art.Doll(de.bornim.core.Race.ELF, de.bornim.core.Sex.FEMALE, de.bornim.core.Build.AVERAGE, 1, 1),
            de.bornim.core.art.Outfit(de.bornim.core.CharClass.ROGUE, mapOf(de.bornim.core.GearSlot.CHEST to g("leather"), de.bornim.core.GearSlot.MAIN_HAND to g("longbow"), de.bornim.core.GearSlot.CLOAK to g("cloak"))), "Bogen"),
        Triple(de.bornim.core.art.Doll(de.bornim.core.Race.DWARF, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 1),
            de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.CHEST to g("chain_shirt"), de.bornim.core.GearSlot.MAIN_HAND to g("light_crossbow"))), "Armbrust"),
        Triple(de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 2),
            de.bornim.core.art.Outfit(de.bornim.core.CharClass.WIZARD, mapOf(de.bornim.core.GearSlot.CHEST to g("robe"), de.bornim.core.GearSlot.MAIN_HAND to g("staff"))), "Stab"),
        Triple(de.bornim.core.art.Doll(de.bornim.core.Race.HALFLING, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 2, 0),
            de.bornim.core.art.Outfit(de.bornim.core.CharClass.ROGUE, mapOf(de.bornim.core.GearSlot.CHEST to g("leather"), de.bornim.core.GearSlot.MAIN_HAND to g("quarterstaff"))), "Kampfstab"),
    )
    // the check: staves through the body in every act, for every people
    var bad = 0; var total = 0
    for (race in de.bornim.core.Race.entries) for ((_, o, name) in kits) {
        val d = de.bornim.core.art.Doll(race, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE)
        val st = F.stance(o.items[de.bornim.core.GearSlot.MAIN_HAND]?.def)
        val acts = listOf(de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Act.INTRO, de.bornim.core.art.HeroFigure.Act.TURN, de.bornim.core.art.HeroFigure.Act.AMBUSHED, de.bornim.core.art.HeroFigure.Act.HURT, de.bornim.core.art.HeroFigure.Act.CAST)
        val runs = acts.map { it to 0 } + listOf(de.bornim.core.art.HeroFigure.Act.VICTORY to 0, de.bornim.core.art.HeroFigure.Act.VICTORY to 1, de.bornim.core.art.HeroFigure.Act.ATTACK to 0, de.bornim.core.art.HeroFigure.Act.ATTACK to 1)
        for ((act, v) in runs) {
            val strike = if (act == de.bornim.core.art.HeroFigure.Act.ATTACK) (if (st == de.bornim.core.art.HeroFigure.Stance.BOW || st == de.bornim.core.art.HeroFigure.Stance.CROSSBOW) de.bornim.core.art.HeroFigure.Strike.SHOOT else if (v == 0) de.bornim.core.art.HeroFigure.Strike.SMASH else de.bornim.core.art.HeroFigure.Strike.SLASH) else de.bornim.core.art.HeroFigure.Strike.SLASH
            val cv = if (act == de.bornim.core.art.HeroFigure.Act.CAST) F.castVariant(o.items[de.bornim.core.GearSlot.MAIN_HAND]?.def, null) else if (act == de.bornim.core.art.HeroFigure.Act.ATTACK) 0 else v
            for ((i, rig) in F.sequence(act, strike, cv, st).withIndex()) {
                total++
                d.fit(rig, o).second!!.first.weaponThroughBody()?.let { t -> bad++; if (bad <= 25) println("HALTUNG DURCH: ${race.name} $name $act/$v Bild $i bei ${(t * 100).toInt()} %") }
            }
        }
    }
    println("Haltungen: $total Bilder, Waffe durch Körper: $bad")
    // the rest from three sides, the turned-to-us intro and both victories
    val cols = listOf("Ruhe 138°" to 0, "Ruhe 90°" to 1, "Ruhe 30°" to 2, "Einstieg" to 3, "Sieg 1" to 4, "Sieg 2" to 5)
    val cw = 230; val ch = 280
    val out = BufferedImage(cw * cols.size, ch * kits.size, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x5E625C); gg.fillRect(0, 0, out.width, out.height)
    for ((ri, k) in kits.withIndex()) {
        val st = F.stance(k.second.items[de.bornim.core.GearSlot.MAIN_HAND]?.def)
        val rest = F.sequence(de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Strike.SLASH, 0, st)[0]
        for ((ci, c) in cols.withIndex()) {
            val rig = when (c.second) {
                0 -> rest; 1 -> rest.copy(yaw = 90.0); 2 -> rest.copy(yaw = 30.0)
                3 -> F.sequence(de.bornim.core.art.HeroFigure.Act.INTRO, de.bornim.core.art.HeroFigure.Strike.SLASH, 0, st)[0]
                else -> F.sequence(de.bornim.core.art.HeroFigure.Act.VICTORY, de.bornim.core.art.HeroFigure.Strike.SLASH, c.second - 4, st).last()
            }
            val im = k.first.render(cw, ch, cw / 2.0, ch - 8.0, 1.2, rig, k.second).img
            for (y in 0 until ch) for (x in 0 until cw) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(ci * cw + x, ri * ch + y, q) }
            gg.color = java.awt.Color(0xF0E8D8); gg.drawString("${k.third} – ${c.first}", ci * cw + 6, ri * ch + 16)
        }
    }
    ImageIO.write(out, "png", File("build/screens/stance_views.png"))
    println("wrote stance views")
}

/** How long each weapon drawing is, in cm on a human, before and behind the hand; and how its reach for the checks compares. */
fun measureWeapons() {
    val bases = de.bornim.core.GearBases.all.filter { it.slot == de.bornim.core.GearSlot.MAIN_HAND || it.slot == de.bornim.core.GearSlot.OFF_HAND }.filter { it.isWeapon }.map { it.id }
    val k = 1.636
    for (b in bases) {
        val s = de.bornim.core.art.Sculpt(900, 200, 31)
        s.transform(0.0, 0.0, 1.0, 1.0, 450.0, 100.0)
        de.bornim.core.art.WeaponArt(s).draw(b, de.bornim.core.Rarity.COMMON, 450.0, 100.0, 0.0, 0.0, 1.0)
        var lo = 9999; var hi = -9999; var top = 9999; var bot = -9999
        for (y in 0 until 200) for (x in 0 until 900) if ((s.img[x, y] ushr 24) >= 128) { lo = minOf(lo, x); hi = maxOf(hi, x); top = minOf(top, y); bot = maxOf(bot, y) }
        if (hi < 0) { println("WAFFE $b: nicht gezeichnet"); continue }
        val front = (hi - 450) * k; val back = (450 - lo) * k
        println("WAFFE $b: vorn ${"%.0f".format(front)} cm, hinten ${"%.0f".format(back)} cm, gesamt ${"%.0f".format(front + back)} cm, quer ${"%.0f".format((bot - top) * k)} cm; Prüflänge ${de.bornim.core.art.Dress.reach(b).toInt()} cm")
    }
}


/** Every weapon in a hand, human and halfling side by side, to judge their sizes against the body. */
fun renderWeaponSizes() {
    var uid = 1L
    fun g(base: String) = de.bornim.core.Gear(uid++, base, de.bornim.core.Rarity.COMMON, 3)
    val F = de.bornim.core.art.HeroFigure
    val weapons = listOf("dagger", "shortsword", "scimitar", "rapier", "longsword", "greatsword", "handaxe", "battleaxe", "greataxe", "mace", "warhammer", "maul", "spear", "halberd", "quarterstaff", "staff")
    val dolls = listOf(de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE), de.bornim.core.art.Doll(de.bornim.core.Race.HALFLING, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE))
    val cw = 150; val ch = 300
    val out = BufferedImage(cw * weapons.size, ch, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x5E625C); gg.fillRect(0, 0, out.width, out.height)
    for ((i, w) in weapons.withIndex()) {
        val o = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.MAIN_HAND to g(w)))
        val st = F.stance(o.items[de.bornim.core.GearSlot.MAIN_HAND]?.def)
        // the weapon held out level to the side, so its whole length shows
        val rig = if (st == de.bornim.core.art.HeroFigure.Stance.STAFF) F.sequence(de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Strike.SLASH, 0, st)[0].copy(yaw = 0.0)
            else F.VICTORY_POSES[0].copy(yaw = 0.0, rh = de.bornim.core.art.HeroFigure.V(16.0, 70.0, 10.0), weapon = de.bornim.core.art.HeroFigure.V(0.15, 1.0, 0.0))
        for ((di, d) in dolls.withIndex()) {
            val im = d.render(cw, ch, cw / 2.0 + (if (di == 0) -22.0 else 30.0), ch - 6.0, 0.95, rig, o).img
            for (y in 0 until ch) for (x in 0 until cw) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(i * cw + x, y, q) }
        }
        gg.color = java.awt.Color(0xF0E8D8); gg.drawString(w, i * cw + 4, 14)
    }
    // a scale: one metre marks
    gg.color = java.awt.Color(0xC8C0B0)
    for (m in 0..2) { val y = (ch - 6 - m * 100 * 0.95).toInt(); gg.drawLine(0, y, out.width, y) }
    ImageIO.write(out, "png", File("build/screens/weapon_sizes.png"))
    println("wrote weapon sizes")
}

/** Bare arms in a few poses and a cloak in motion, to judge the arm muscles and how the cloth hangs. */
fun renderArmsAndCloak() {
    var uid = 1L
    fun g(base: String, r: de.bornim.core.Rarity = de.bornim.core.Rarity.UNCOMMON) = de.bornim.core.Gear(uid++, base, r, 3)
    val F = de.bornim.core.art.HeroFigure
    val cw = 220; val ch = 270
    val bare = listOf(de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.STRONG), de.bornim.core.art.Doll(de.bornim.core.Race.ELF, de.bornim.core.Sex.FEMALE, de.bornim.core.Build.AVERAGE))
    val poses = listOf(F.STAND.copy(yaw = 30.0), F.SLASH_WIND.copy(yaw = 30.0), F.BLOCK.copy(yaw = 90.0), F.THRUST_HIT.copy(yaw = 90.0), F.SMASH_WIND.copy(yaw = 180.0), F.BOW_AIM.copy(yaw = 60.0))
    val cloaked = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.CHEST to g("chain_shirt"), de.bornim.core.GearSlot.CLOAK to g("cloak"), de.bornim.core.GearSlot.MAIN_HAND to g("longsword"), de.bornim.core.GearSlot.OFF_HAND to g("shield")))
    val mantle = de.bornim.core.art.Outfit(de.bornim.core.CharClass.WIZARD, mapOf(de.bornim.core.GearSlot.CHEST to g("robe"), de.bornim.core.GearSlot.CLOAK to g("mantle", de.bornim.core.Rarity.RARE), de.bornim.core.GearSlot.MAIN_HAND to g("staff")))
    val cl = listOf(F.STAND, F.SLASH_HIT, F.THRUST_HIT, F.SMASH_HIT, F.STAND.copy(yaw = 180.0), F.SLASH_HIT.copy(yaw = 200.0))
    val out = BufferedImage(cw * 6, ch * 4, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x5E625C); gg.fillRect(0, 0, out.width, out.height)
    fun put(im: de.bornim.core.art.PixelImage, cx: Int, cy: Int) { for (y in 0 until ch) for (x in 0 until cw) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(cx * cw + x, cy * ch + y, q) } }
    for ((ri, d) in bare.withIndex()) for ((ci, r) in poses.withIndex()) put(d.render(cw, ch, cw / 2.0, ch - 8.0, 1.2, r, null).img, ci, ri)
    val hd = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0)
    for ((ci, r) in cl.withIndex()) { put(hd.render(cw, ch, cw / 2.0, ch - 8.0, 1.2, r, cloaked).img, ci, 2); put(hd.render(cw, ch, cw / 2.0, ch - 8.0, 1.2, r, mantle).img, ci, 3) }
    ImageIO.write(out, "png", File("build/screens/arms_cloak.png"))
    println("wrote arms and cloak")
}

/** Time per battle frame, dressed, for a fighter and a wizard, as the battle will draw them. */
fun benchRender() {
    run {
        val hero = de.bornim.core.GameState.newGame("Alrik", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.FIGHTER).hero
        var n = 0
        val t0 = System.nanoTime()
        de.bornim.core.art.HeroBattle.prepare(hero, "wolf", false)
        val ms = (System.nanoTime() - t0) / 1e6
        println("VORAB: alle Kampfbilder eines Kämpfers in ${"%.1f".format(ms / 1000)} s; Ausrüstung: ${hero.gear.values.joinToString { it.base }}")
    }
    var uid = 1L
    fun g(base: String, r: de.bornim.core.Rarity = de.bornim.core.Rarity.RARE) = de.bornim.core.Gear(uid++, base, r, 3)
    val F = de.bornim.core.art.HeroFigure
    val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0)
    val kits = listOf(
        "Kämpfer" to de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.CHEST to g("plate"), de.bornim.core.GearSlot.HEAD to g("helmet"), de.bornim.core.GearSlot.CLOAK to g("cloak"),
            de.bornim.core.GearSlot.ARMS to g("gauntlets"), de.bornim.core.GearSlot.LEGS to g("greaves"), de.bornim.core.GearSlot.MAIN_HAND to g("longsword"), de.bornim.core.GearSlot.OFF_HAND to g("shield"))),
        "Magier" to de.bornim.core.art.Outfit(de.bornim.core.CharClass.WIZARD, mapOf(de.bornim.core.GearSlot.CHEST to g("robe"), de.bornim.core.GearSlot.CLOAK to g("mantle"), de.bornim.core.GearSlot.MAIN_HAND to g("staff"))))
    for ((name, o) in kits) {
        val st = F.stance(o.items[de.bornim.core.GearSlot.MAIN_HAND]?.def)
        val rigs = F.sequence(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SLASH, 0, st) + F.sequence(de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Strike.SLASH, 0, st)
        repeat(3) { doll.render(150, 190, 70.0, 184.0, 0.75, rigs[it], o) }
        val t0 = System.nanoTime()
        for (r in rigs) doll.render(150, 190, 70.0, 184.0, 0.75, r, o)
        val ms = (System.nanoTime() - t0) / 1e6 / rigs.size
        val t1 = System.nanoTime()
        for (r in rigs.take(6)) doll.render(300, 380, 140.0, 368.0, 1.5, r, o)
        val ms2 = (System.nanoTime() - t1) / 1e6 / 6
        val t2 = System.nanoTime()
        for (r in rigs) doll.fit(r, o)
        val fitMs = (System.nanoTime() - t2) / 1e6 / rigs.size
        println("ANPASSEN $name: ${"%.0f".format(fitMs)} ms je Bild")
        println("TEMPO $name: ${"%.0f".format(ms)} ms je Kampfbild (${rigs.size} Bilder), ${"%.0f".format(ms2)} ms je doppelt großem Bild")
    }
}

/** A few frames written raw, to compare the renderer's output before and after a change. */
fun dumpFrames(dir: String) {
    var uid = 1L
    fun g(base: String, r: de.bornim.core.Rarity = de.bornim.core.Rarity.RARE) = de.bornim.core.Gear(uid++, base, r, 3)
    val F = de.bornim.core.art.HeroFigure
    val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0)
    val o = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.CHEST to g("plate"), de.bornim.core.GearSlot.HEAD to g("helmet"), de.bornim.core.GearSlot.CLOAK to g("cloak"), de.bornim.core.GearSlot.MAIN_HAND to g("longsword"), de.bornim.core.GearSlot.OFF_HAND to g("shield")))
    File(dir).mkdirs()
    for ((i, r) in listOf(F.STAND, F.SLASH_WIND, F.SLASH_HIT, F.BLOCK, F.THRUST_HIT, F.STAND.copy(yaw = 30.0)).withIndex()) {
        val im = doll.render(150, 190, 70.0, 184.0, 0.75, r, o).img
        val b = BufferedImage(150, 190, BufferedImage.TYPE_INT_ARGB)
        for (y in 0 until 190) for (x in 0 until 150) b.setRGB(x, y, im[x, y])
        ImageIO.write(b, "png", File(dir, "f$i.png"))
    }
    println("dumped")
}

/** A fight as the battle screen plays it, with the frames HeroBattle hands out: start, blows, block, hit, spell, victory. */
fun renderBattleRun() {
    val B = de.bornim.core.art.HeroBattle
    val w = 270; val h = 370
    val heroes = listOf(
        "kampf_kaempfer" to de.bornim.core.GameState.newGame("Alrik", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.FIGHTER).hero,
        "kampf_magierin" to de.bornim.core.GameState.newGame("Ilse", de.bornim.core.Race.ELF, de.bornim.core.CharClass.WIZARD).hero.also { it.sex = de.bornim.core.Sex.FEMALE },
        "kampf_klerikerin" to de.bornim.core.GameState.newGame("Hedwig", de.bornim.core.Race.DWARF, de.bornim.core.CharClass.CLERIC).hero.also { it.sex = de.bornim.core.Sex.FEMALE; it.build = de.bornim.core.Build.STRONG },
        "kampf_schurke" to de.bornim.core.GameState.newGame("Fenn", de.bornim.core.Race.HALFLING, de.bornim.core.CharClass.ROGUE).hero,
    )
    val bg = BattleScene.forest(w, h, BattleScene.Spot.CLEARING, BattleScene.Light.DUSK, false, 12)
    val wolf = MonsterArt.battleFrame("wolf", MonsterLook(1), Act.IDLE, 0, 0)
    for ((name, hero) in heroes) {
        val F = de.bornim.core.art.HeroFigure
        val plan = mutableListOf<de.bornim.core.art.PixelImage>()
        // how far along the lunge each frame is, and for which blow
        val lunge = mutableListOf<Pair<Double, de.bornim.core.art.HeroFigure.Strike>>()
        fun seq(act: de.bornim.core.art.HeroFigure.Act, strike: de.bornim.core.art.HeroFigure.Strike = de.bornim.core.art.HeroFigure.Strike.SLASH, v: Int = 0) {
            for (i in 0 until B.frameCount(hero, act, strike, v)) {
                plan += B.frame(hero, act, strike, v, i)
                lunge += (if (act == de.bornim.core.art.HeroFigure.Act.ATTACK) B.lungeAt(hero, strike, i) else 0.0) to strike
            }
        }
        fun idle(n: Int) { for (i in 0 until n) { plan += B.frame(hero, de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Strike.SLASH, 0, i); lunge += 0.0 to de.bornim.core.art.HeroFigure.Strike.SLASH } }
        seq(de.bornim.core.art.HeroFigure.Act.TURN); idle(6)
        val strikes = B.strikes(hero)
        seq(de.bornim.core.art.HeroFigure.Act.ATTACK, strikes[0]); idle(5)
        seq(de.bornim.core.art.HeroFigure.Act.BLOCK, v = B.blockVariant(hero, "wolf")); idle(4)
        seq(de.bornim.core.art.HeroFigure.Act.HURT); idle(4)
        if (hero.cls == de.bornim.core.CharClass.WIZARD || hero.cls == de.bornim.core.CharClass.CLERIC) { seq(de.bornim.core.art.HeroFigure.Act.CAST, de.bornim.core.art.HeroFigure.Strike.CAST, B.castVariant(hero)); idle(4) }
        seq(de.bornim.core.art.HeroFigure.Act.ATTACK, strikes[1 % strikes.size]); idle(4)
        seq(de.bornim.core.art.HeroFigure.Act.VICTORY, v = B.variant(hero, de.bornim.core.art.HeroFigure.Act.VICTORY, "wolf", 1)); repeat(8) { plan += plan.last(); lunge += 0.0 to de.bornim.core.art.HeroFigure.Strike.SLASH }
        val dir = File("build/screens/battlerun/$name"); dir.deleteRecursively(); dir.mkdirs()
        for ((i, im) in plan.withIndex()) {
            val out = BufferedImage(w * 2, h * 2, BufferedImage.TYPE_INT_RGB)
            for (y in 0 until h) for (x in 0 until w) for (q in 0 until 4) out.setRGB(x * 2 + q % 2, y * 2 + q / 2, bg[x, y])
            fun paste(img: de.bornim.core.art.PixelImage, ox: Int, oy: Int) {
                for (y in 0 until img.height) for (x in 0 until img.width) { val p = img[x, y]; val al = (p ushr 24) / 255.0; if (al <= 0.02) continue
                    for (q in 0 until 4) { val px = (ox + x) * 2 + q % 2; val py = (oy + y) * 2 + q / 2; if (px in 0 until out.width && py in 0 until out.height) {
                        val c = out.getRGB(px, py)
                        fun ch(sh: Int) = (((p shr sh) and 0xFF) * al + ((c shr sh) and 0xFF) * (1 - al)).toInt()
                        out.setRGB(px, py, (ch(16) shl 16) or (ch(8) shl 8) or ch(0)) } } }
            }
            paste(wolf, (w * BattleScene.FOE_X - wolf.width / 2).toInt(), (h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf")).toInt())
            val (f, st) = lunge[i]
            val feetX = w * BattleScene.HERO_X; val feetY = h * BattleScene.HERO_Y
            val (ax, ay) = B.aimAt((w * BattleScene.FOE_X).toDouble(), (h * BattleScene.FOE_Y).toDouble(), wolf.width.toDouble(), MonsterArt.groundLine("wolf").toDouble())
            val (ox, oy) = if (f > 0) B.lungeOffset(hero, st, feetX.toDouble(), feetY.toDouble(), ax, ay) else 0.0 to 0.0
            val sc = 1 - (1 - B.LUNGE_SCALE) * f
            // the frame shrunk about the feet, as the battle screen draws it
            val scaled = de.bornim.core.art.PixelImage(im.width, im.height)
            for (y in 0 until im.height) for (x in 0 until im.width) {
                val sx = (B.ANCHOR_X + (x + 0.5 - B.ANCHOR_X) / sc).toInt(); val sy = (B.GROUND + (y + 0.5 - B.GROUND) / sc).toInt()
                scaled.set(x, y, im[sx, sy])
            }
            paste(scaled, (feetX + ox * f - B.ANCHOR_X).toInt(), (feetY + oy * f - B.GROUND).toInt())
            ImageIO.write(out.getSubimage(0, 260, w * 2, h * 2 - 260), "png", File(dir, "f%03d.png".format(i)))
        }
        println("$name: Trefferbilder ${lunge.indices.filter { lunge[it].first >= 0.999 }}")
        println("$name: ${plan.size} Bilder, Ausrüstung ${hero.gear.values.joinToString { it.base }}")
    }
}

/** Every people in a few looks, as the making of a hero and the equipment menu show them. */
fun renderPortraits() {
    val P = de.bornim.core.art.HeroPortrait
    val looks = listOf(
        Triple(de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 0), Triple(de.bornim.core.Sex.FEMALE, de.bornim.core.Build.SLIM, 1),
        Triple(de.bornim.core.Sex.MALE, de.bornim.core.Build.STRONG, 2), Triple(de.bornim.core.Sex.FEMALE, de.bornim.core.Build.AVERAGE, 3))
    val classes = listOf(de.bornim.core.CharClass.FIGHTER, de.bornim.core.CharClass.WIZARD, de.bornim.core.CharClass.ROGUE, de.bornim.core.CharClass.CLERIC)
    val races = de.bornim.core.Race.entries
    val out = BufferedImage(P.W * looks.size * races.size / 2 + 0, P.H * 2, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x3C3A36); gg.fillRect(0, 0, out.width, out.height)
    var col = 0
    for ((ri, race) in races.withIndex()) for ((li, l) in looks.withIndex()) {
        val hero = de.bornim.core.GameState.newGame("Test", race, classes[li]).hero
        hero.sex = l.first; hero.build = l.second; hero.skin = l.third; hero.hair = (l.third + ri) % 4
        val im = P.render(hero, if (li % 2 == 0) 20.0 else 340.0)
        val cx = (col % (out.width / P.W)) * P.W; val cy = (col / (out.width / P.W)) * P.H
        for (y in 0 until P.H) for (x in 0 until P.W) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(cx + x, cy + y, q) }
        col++
    }
    ImageIO.write(out, "png", File("build/screens/portraits.png"))
    println("wrote portraits ${out.width}x${out.height}")
}

/** How far the weapon's point is from the foe at the moment a blow lands, in scene pixels. */
fun measureReach() {
    val B = de.bornim.core.art.HeroBattle
    val w = 270; val h = 370
    val foe = Pair(w * BattleScene.FOE_X, h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf") * 0.45)
    for (cls in listOf(de.bornim.core.CharClass.FIGHTER, de.bornim.core.CharClass.ROGUE)) {
        val hero = de.bornim.core.GameState.newGame("A", de.bornim.core.Race.HUMAN, cls).hero
        val d = B.doll(hero); val o = B.outfit(hero)
        for (s in B.strikes(hero)) {
            val rig = B.frames(hero, de.bornim.core.art.HeroFigure.Act.ATTACK, s, 0)[B.strikeFrame(s)]
            val img = d.render(B.W, B.H, B.ANCHOR_X, B.GROUND, B.PX, rig, o)
            val sk = d.fit(rig, o).first
            val tip = sk.hand(1) + sk.weapon * de.bornim.core.art.Dress.reach(hero.weapon!!.base)
            val (tx, ty, _) = img.project(tip)
            val sx = w * BattleScene.HERO_X - B.ANCHOR_X + tx; val sy = h * BattleScene.HERO_Y - B.GROUND + ty
            println("REICHWEITE ${cls} $s: Spitze bei (${sx.toInt()}, ${sy.toInt()}), Gegnermitte (${foe.first.toInt()}, ${foe.second.toInt()}), Abstand ${Math.hypot(sx - foe.first, sy - foe.second).toInt()} px; Held ${B.H} px hoch, Wolfbild ${MonsterArt.battleFrame("wolf", MonsterLook(1), Act.IDLE, 0, 0).width} px breit")
        }
    }
}

/** The moment a spell or shot is let go: where it leaves the hero, the flash there, and its path to the foe. */
fun renderLaunch() {
    val B = de.bornim.core.art.HeroBattle
    val F = de.bornim.core.art.HeroFigure
    val w = 270; val h = 370
    fun hero(name: String, race: de.bornim.core.Race, cls: de.bornim.core.CharClass, vararg gear: Pair<de.bornim.core.GearSlot, String>) =
        de.bornim.core.GameState.newGame(name, race, cls).hero.also { hr -> var u = 900L; for ((sl, b) in gear) hr.gear[sl] = de.bornim.core.Gear(u++, b, de.bornim.core.Rarity.UNCOMMON, 3) }
    val casters = listOf(
        "Stab" to hero("Ilse", de.bornim.core.Race.ELF, de.bornim.core.CharClass.WIZARD, de.bornim.core.GearSlot.MAIN_HAND to "staff"),
        "Zauberstab und Buch" to hero("Ilse", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.WIZARD, de.bornim.core.GearSlot.MAIN_HAND to "wand", de.bornim.core.GearSlot.OFF_HAND to "tome"),
        "Heiligensymbol" to hero("Hedwig", de.bornim.core.Race.DWARF, de.bornim.core.CharClass.CLERIC, de.bornim.core.GearSlot.OFF_HAND to "holy_symbol"),
        "Bogen" to hero("Fenn", de.bornim.core.Race.ELF, de.bornim.core.CharClass.ROGUE, de.bornim.core.GearSlot.MAIN_HAND to "longbow"),
        "Armbrust" to hero("Borin", de.bornim.core.Race.DWARF, de.bornim.core.CharClass.FIGHTER, de.bornim.core.GearSlot.MAIN_HAND to "light_crossbow"),
    )
    val bg = BattleScene.forest(w, h, BattleScene.Spot.CLEARING, BattleScene.Light.DUSK, false, 12)
    val wolf = MonsterArt.battleFrame("wolf", MonsterLook(1), Act.IDLE, 0, 0)
    val cols = 5
    val out = BufferedImage(w * cols, (h - 130) * casters.size, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING, java.awt.RenderingHints.VALUE_ANTIALIAS_ON)
    for ((ri, c) in casters.withIndex()) {
        val (label, hr) = c
        val cast = hr.weapon?.def?.ranged != true
        val act = if (cast) de.bornim.core.art.HeroFigure.Act.CAST else de.bornim.core.art.HeroFigure.Act.ATTACK
        val strike = if (cast) de.bornim.core.art.HeroFigure.Strike.CAST else de.bornim.core.art.HeroFigure.Strike.SHOOT
        val v = if (cast) B.castVariant(hr) else 0
        val rel = B.strikeFrame(strike)
        val l = B.launch(hr, act, v)
        val feetX = w * BattleScene.HERO_X; val feetY = h * BattleScene.HERO_Y
        val lx = feetX + l.x - B.ANCHOR_X; val ly = feetY + l.y - B.GROUND
        val fx = w * BattleScene.FOE_X; val fy = h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf") * 0.55
        for (ci in 0 until cols) {
            val i = rel - 2 + ci
            val im = B.frame(hr, act, strike, v, i)
            val tile = BufferedImage(w, h, BufferedImage.TYPE_INT_RGB)
            for (y in 0 until h) for (x in 0 until w) tile.setRGB(x, y, bg[x, y])
            fun paste(img: de.bornim.core.art.PixelImage, ox: Int, oy: Int) {
                for (y in 0 until img.height) for (x in 0 until img.width) { val p = img[x, y]; val al = (p ushr 24) / 255.0; if (al <= 0.02) continue
                    val px = ox + x; val py = oy + y; if (px !in 0 until w || py !in 0 until h) continue
                    val q = tile.getRGB(px, py); fun ch(sh: Int) = (((p shr sh) and 0xFF) * al + ((q shr sh) and 0xFF) * (1 - al)).toInt()
                    tile.setRGB(px, py, (ch(16) shl 16) or (ch(8) shl 8) or ch(0)) }
            }
            paste(wolf, (fx - wolf.width / 2).toInt(), (h * BattleScene.FOE_Y - MonsterArt.groundLine("wolf")).toInt())
            paste(im, (feetX - B.ANCHOR_X).toInt(), (feetY - B.GROUND).toInt())
            val tg = tile.createGraphics(); tg.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING, java.awt.RenderingHints.VALUE_ANTIALIAS_ON)
            val col = java.awt.Color(l.rgb)
            // from the release on: the flash at the point it leaves, and the bolt on its way, a quarter of the path per frame
            val k = i - rel
            if (k >= 0 && cast) for ((r, a) in listOf(9.0 + 5 * k to 80, 5.0 + 2 * k to 170, 2.5 to 240)) {
                tg.color = java.awt.Color(if (r < 3) 0xFFFFFF else l.rgb).let { java.awt.Color(it.red, it.green, it.blue, (a * (1 - k / 3.0)).toInt().coerceIn(0, 255)) }
                tg.fill(java.awt.geom.Ellipse2D.Double(lx - r, ly - r, 2 * r, 2 * r))
            }
            if (k >= 0) {
                val t = ((k + 1) / 4.0).coerceAtMost(1.0)
                tg.color = col; tg.stroke = java.awt.BasicStroke(2f)
                tg.draw(java.awt.geom.Line2D.Double(lx, ly, lx + (fx - lx) * t, ly + (fy - ly) * t))
                tg.fill(java.awt.geom.Ellipse2D.Double(lx + (fx - lx) * t - 3, ly + (fy - ly) * t - 3, 6.0, 6.0))
            }
            tg.color = java.awt.Color(0xF0E8D8); tg.drawString("$label – " + (if (k < 0) "sammeln" else if (k == 0) "loslassen" else "+$k"), 6, 144)
            g.drawImage(tile.getSubimage(0, 130, w, h - 130), ci * w, ri * (h - 130), null)
        }
    }
    ImageIO.write(out, "png", File("build/screens/launch.png"))
    println("wrote launch")
}

/** The hero hurt: no, few and many wounds from the front and the back, the stains following a blow; and a flask thrown. */
fun renderWounds() {
    val B = de.bornim.core.art.HeroBattle
    val F = de.bornim.core.art.HeroFigure
    val fighter = de.bornim.core.GameState.newGame("Alrik", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.FIGHTER).hero
    val rogue = de.bornim.core.GameState.newGame("Fenn", de.bornim.core.Race.HALFLING, de.bornim.core.CharClass.ROGUE).hero
    val cw = 200; val ch = 250
    val out = BufferedImage(cw * 6, ch * 3, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x5E625C); g.fillRect(0, 0, out.width, out.height)
    fun put(im: de.bornim.core.art.PixelImage, c: Int, r: Int, label: String) {
        for (y in 0 until ch) for (x in 0 until cw) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(c * cw + x, r * ch + y, q) }
        g.color = java.awt.Color(0xF0E8D8); g.drawString(label, c * cw + 4, r * ch + 14)
    }
    val d = B.doll(fighter); val o = B.outfit(fighter)
    for (w in 0..2) {
        put(d.render(cw, ch, cw / 2.0, ch - 6.0, 1.1, F.STAND.copy(yaw = 20.0), o, wounds = w).img, w * 2, 0, "Wunden $w – vorn")
        put(d.render(cw, ch, cw / 2.0, ch - 6.0, 1.1, F.STAND.copy(yaw = 200.0), o, wounds = w).img, w * 2 + 1, 0, "Wunden $w – hinten")
    }
    val seq = B.frames(fighter, de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SLASH, 0)
    for ((c, i) in listOf(0, 4, 7, 9, 12, 16).withIndex()) put(d.render(cw, ch, cw / 2.0, ch - 6.0, 1.1, seq[i].copy(yaw = 60.0), o, wounds = 2).img, c, 1, "Hieb, Bild $i")
    val t = B.frames(rogue, de.bornim.core.art.HeroFigure.Act.THROW, de.bornim.core.art.HeroFigure.Strike.CAST, B.throwVariant(rogue))
    val dr = B.doll(rogue); val or = B.outfit(rogue)
    for ((c, i) in listOf(0, 4, 8, 9, 10, 12).withIndex()) put(dr.render(cw, ch, cw / 2.0, ch - 6.0, 1.1, t[i].copy(yaw = 90.0), or, wounds = 1).img, c, 2, "Wurf, Bild $i")
    ImageIO.write(out, "png", File("build/screens/wounds.png"))
    println("wrote wounds")
}


/** The turning hero of the equipment menu, every side in order, written out for a moving picture. */
fun renderTurntable() {
    val P = de.bornim.core.art.HeroPortrait
    val hero = de.bornim.core.GameState.newGame("Alrik", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.FIGHTER).hero
    val dir = File("build/screens/turntable"); dir.deleteRecursively(); dir.mkdirs()
    for ((i, y) in P.YAWS.withIndex()) {
        val im = P.render(hero, y)
        val b = BufferedImage(P.W * 2, P.H * 2, BufferedImage.TYPE_INT_RGB)
        for (yy in 0 until P.H * 2) for (x in 0 until P.W * 2) { val q = im[x / 2, yy / 2]; b.setRGB(x, yy, if ((q ushr 24) >= 128) q else 0x3C3A36) }
        ImageIO.write(b, "png", File(dir, "f%03d.png".format(i)))
    }
    println("wrote turntable")
}

/** The four heroes of the title screen, as it draws them. */
fun renderTitleHeroes() {
    val P = de.bornim.core.art.HeroPortrait
    val races = listOf(de.bornim.core.Race.HUMAN, de.bornim.core.Race.ELF, de.bornim.core.Race.DWARF, de.bornim.core.Race.HALF_ORC)
    val out = BufferedImage(P.W * 4, P.H, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x1C2030); g.fillRect(0, 0, out.width, out.height)
    de.bornim.core.CharClass.entries.forEachIndexed { i, cls ->
        val h = de.bornim.core.Hero.create("Held $i", races[i % 4], cls).also {
            it.sex = if (i % 2 == 1) de.bornim.core.Sex.FEMALE else de.bornim.core.Sex.MALE; it.skin = (i * 3 + 1) % 4; it.hair = i % 4
        }
        val im = P.render(h, P.YAWS[0])
        for (y in 0 until P.H) for (x in 0 until P.W) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(i * P.W + x, y, q) }
    }
    ImageIO.write(out, "png", File("build/screens/title_heroes.png"))
    println("wrote title heroes")
}

/** Fighter and cleric side by side from several sides, and the cleric blocking and casting. */
fun renderClericShield() {
    val P = de.bornim.core.art.HeroPortrait
    val B = de.bornim.core.art.HeroBattle
    val yaws = listOf(20.0, 95.0, 160.0, 250.0, 340.0)
    val heroes = listOf(de.bornim.core.CharClass.FIGHTER, de.bornim.core.CharClass.CLERIC).map { cls ->
        de.bornim.core.Hero.create("Held", de.bornim.core.Race.HUMAN, cls).also { it.sex = de.bornim.core.Sex.MALE; it.skin = 1; it.hair = 0 }
    }
    val out = BufferedImage(P.W * yaws.size, P.H * 2 + B.H, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x3C3A36); g.fillRect(0, 0, out.width, out.height)
    fun put(im: de.bornim.core.art.PixelImage, ox: Int, oy: Int) { for (y in 0 until im.height) for (x in 0 until im.width) { val q = im[x, y]; if ((q ushr 24) >= 128 && ox + x < out.width) out.setRGB(ox + x, oy + y, q) } }
    for ((r, h) in heroes.withIndex()) for ((i, y) in yaws.withIndex()) put(P.render(h, y), i * P.W, r * P.H)
    val c = heroes[1]
    val shots = listOf(
        B.frame(c, de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Strike.SLASH, 0, 0),
        B.frame(c, de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SMASH, 0, B.strikeFrame(de.bornim.core.art.HeroFigure.Strike.SMASH)),
        B.frame(c, de.bornim.core.art.HeroFigure.Act.BLOCK, de.bornim.core.art.HeroFigure.Strike.SLASH, 0, 4),
        B.frame(c, de.bornim.core.art.HeroFigure.Act.CAST, de.bornim.core.art.HeroFigure.Strike.CAST, B.castVariant(c), B.strikeFrame(de.bornim.core.art.HeroFigure.Strike.CAST)),
        B.frame(c, de.bornim.core.art.HeroFigure.Act.BLOCK, de.bornim.core.art.HeroFigure.Strike.SLASH, 2, 4))
    for ((i, im) in shots.withIndex()) put(im, i * P.W, P.H * 2)
    ImageIO.write(out, "png", File("build/screens/cleric_shield.png"))
    println("wrote cleric shield")
}

/** The cleric with a quarterstaff and round shield: from every side, then every act of a fight frame by frame. */
fun renderClericStaff() {
    val P = de.bornim.core.art.HeroPortrait
    val B = de.bornim.core.art.HeroBattle
    val Act = de.bornim.core.art.HeroFigure.Act.entries.associateBy { it.name }
    val St = de.bornim.core.art.HeroFigure.Strike.entries.associateBy { it.name }
    val c = de.bornim.core.Hero.create("Held", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.CLERIC).also { it.sex = de.bornim.core.Sex.MALE; it.skin = 1; it.hair = 0 }
    c.equip(de.bornim.core.Gear(9001, "quarterstaff", de.bornim.core.Rarity.COMMON, 1))
    val strikes = B.strikes(c)
    val rows = mutableListOf<Pair<String, List<de.bornim.core.art.PixelImage>>>()
    for (s in strikes) rows += "ATTACK/$s" to List(B.frameCount(c, Act["ATTACK"]!!, s)) { B.frame(c, Act["ATTACK"]!!, s, 0, it) }
    for ((a, v) in listOf("IDLE" to 0, "INTRO" to 0, "TURN" to 0, "BLOCK" to 0, "BLOCK" to 2, "CAST" to B.castVariant(c), "THROW" to B.throwVariant(c), "HURT" to 0, "AMBUSHED" to 0) + B.victoryVariants(c).map { "VICTORY" to it }) {
        val act = Act[a]!!; val s = if (a == "CAST" || a == "THROW") St["CAST"]!! else St["SLASH"]!!
        rows += "$a/$v" to List(B.frameCount(c, act, s, v)) { B.frame(c, act, s, v, it) }
    }
    val cols = maxOf(8, rows.maxOf { it.second.size }).coerceAtMost(12)
    val yaws = listOf(20.0, 95.0, 160.0, 250.0, 340.0)
    val fw = 110; val fh = B.H
    val out = BufferedImage(maxOf(cols * fw, yaws.size * P.W), P.H + rows.size * fh, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x3C3A36); g.fillRect(0, 0, out.width, out.height)
    fun put(im: de.bornim.core.art.PixelImage, ox: Int, oy: Int, cut: Int = 0) { for (y in 0 until im.height) for (x in cut until im.width) { val q = im[x, y]; val X = ox + x - cut; if ((q ushr 24) >= 128 && X < out.width && X >= 0) out.setRGB(X, oy + y, q) } }
    for ((i, y) in yaws.withIndex()) put(P.render(c, y), i * P.W, 0)
    g.color = java.awt.Color(0xE0D8C0)
    for ((r, row) in rows.withIndex()) {
        val step = maxOf(1, (row.second.size + cols - 1) / cols)
        row.second.filterIndexed { i, _ -> i % step == 0 }.take(cols).forEachIndexed { i, im -> put(im, i * fw, P.H + r * fh, 20) }
        g.drawString(row.first, 2, P.H + r * fh + 12)
    }
    ImageIO.write(out, "png", File("build/screens/cleric_staff.png"))
    println("wrote cleric staff, strikes $strikes")
}

/** Counts frames in which the cleric's quarterstaff passes through body or round shield, every people, sex and build. */
fun checkClericStaff() {
    val F = de.bornim.core.art.HeroFigure
    var total = 0; var body = 0; var shield = 0
    val where = sortedMapOf<String, Int>()
    for (race in de.bornim.core.Race.entries) for (sex in de.bornim.core.Sex.entries) for (build in de.bornim.core.Build.entries) {
        val hero = de.bornim.core.Hero.create("Held", race, de.bornim.core.CharClass.CLERIC).also { it.sex = sex; it.build = build }
        hero.equip(de.bornim.core.Gear(9001, "quarterstaff", de.bornim.core.Rarity.COMMON, 1))
        val B = de.bornim.core.art.HeroBattle
        val doll = B.doll(hero); val outfit = B.outfit(hero)
        val acts = mutableListOf<Triple<de.bornim.core.art.HeroFigure.Act, de.bornim.core.art.HeroFigure.Strike, Int>>()
        for (s in B.strikes(hero)) acts += Triple(de.bornim.core.art.HeroFigure.Act.ATTACK, s, 0)
        for (a in listOf(de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Act.INTRO, de.bornim.core.art.HeroFigure.Act.TURN, de.bornim.core.art.HeroFigure.Act.HURT, de.bornim.core.art.HeroFigure.Act.AMBUSHED)) acts += Triple(a, de.bornim.core.art.HeroFigure.Strike.SLASH, 0)
        acts += Triple(de.bornim.core.art.HeroFigure.Act.BLOCK, de.bornim.core.art.HeroFigure.Strike.SLASH, 0); acts += Triple(de.bornim.core.art.HeroFigure.Act.BLOCK, de.bornim.core.art.HeroFigure.Strike.SLASH, 2)
        acts += Triple(de.bornim.core.art.HeroFigure.Act.CAST, de.bornim.core.art.HeroFigure.Strike.CAST, B.castVariant(hero)); acts += Triple(de.bornim.core.art.HeroFigure.Act.THROW, de.bornim.core.art.HeroFigure.Strike.CAST, B.throwVariant(hero))
        for (v in B.victoryVariants(hero)) acts += Triple(de.bornim.core.art.HeroFigure.Act.VICTORY, de.bornim.core.art.HeroFigure.Strike.SLASH, v)
        for ((a, s, v) in acts) for ((i, rig) in B.frames(hero, a, s, v).withIndex()) {
            total++
            val dress = doll.fit(rig, outfit).second!!.first
            val k = "$a/$s/$v"
            dress.weaponThroughBody()?.let { t -> body++; where["K $k"] = (where["K $k"] ?: 0) + 1; if (body <= 25) println("KÖRPER $race $sex $build $k Bild $i bei ${(t * 100).toInt()} %") }
            dress.weaponThroughShield()?.let { t -> shield++; where["S $k"] = (where["S $k"] ?: 0) + 1; if (shield <= 25) println("SCHILD $race $sex $build $k Bild $i bei ${(t * 100).toInt()} %") }
        }
    }
    println("Bilder $total, durch Körper $body, durch Schild $shield")
    where.forEach { (k, n) -> println("  $k: $n") }
}

/** One halfling cleric's low block, frames 0–6, large. */
fun renderHalflingBlock() {
    val B = de.bornim.core.art.HeroBattle
    val c = de.bornim.core.Hero.create("Held", de.bornim.core.Race.HALFLING, de.bornim.core.CharClass.CLERIC).also { it.sex = de.bornim.core.Sex.FEMALE; it.build = de.bornim.core.Build.SLIM }
    c.equip(de.bornim.core.Gear(9001, "quarterstaff", de.bornim.core.Rarity.COMMON, 1))
    val out = BufferedImage(110 * 4, B.H, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x3C3A36); g.fillRect(0, 0, out.width, out.height)
    for (i in 0..3) { val im = B.frame(c, de.bornim.core.art.HeroFigure.Act.BLOCK, de.bornim.core.art.HeroFigure.Strike.SLASH, 2, i); for (y in 0 until im.height) for (x in 20 until im.width) { val q = im[x, y]; if ((q ushr 24) >= 128 && i * 110 + x - 20 < out.width) out.setRGB(i * 110 + x - 20, y, q) } }
    ImageIO.write(out, "png", File("build/screens/halfling_block.png"))
}

/** The cleric's tabard without the shield in front of it, to see the sun on the breast. */
fun renderClericSun() {
    val P = de.bornim.core.art.HeroPortrait
    val yaws = listOf(0.0, 20.0, 340.0, 60.0)
    val out = BufferedImage(P.W * yaws.size, P.H, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x3C3A36); g.fillRect(0, 0, out.width, out.height)
    for ((i, y) in yaws.withIndex()) {
        val c = de.bornim.core.Hero.create("Sonne$i", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.CLERIC).also { it.skin = 1; it.hair = 0 }
        c.unequip(de.bornim.core.GearSlot.OFF_HAND)
        val im = P.render(c, y)
        for (yy in 0 until im.height) for (x in 0 until im.width) { val q = im[x, yy]; if ((q ushr 24) >= 128) out.setRGB(i * P.W + x, yy, q) }
    }
    ImageIO.write(out, "png", File("build/screens/cleric_sun.png"))
}

/** Every people in the picture as the menus show it (filled) and as the making of a hero does (true to scale), framed. */
fun renderPortraitFill() {
    val P = de.bornim.core.art.HeroPortrait
    val races = de.bornim.core.Race.entries
    val classes = listOf(de.bornim.core.CharClass.CLERIC, de.bornim.core.CharClass.FIGHTER, de.bornim.core.CharClass.ROGUE, de.bornim.core.CharClass.WIZARD, de.bornim.core.CharClass.CLERIC)
    val out = BufferedImage(P.W * races.size, P.H * 2, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x3C3A36); g.fillRect(0, 0, out.width, out.height)
    for ((row, fill) in listOf(true, false).withIndex()) for ((i, race) in races.withIndex()) {
        val h = de.bornim.core.Hero.create("Rahmen$i", race, classes[i]).also { it.sex = if (i % 2 == 0) de.bornim.core.Sex.FEMALE else de.bornim.core.Sex.MALE; it.skin = i % 4; it.hair = (i + 1) % 4 }
        val im = P.render(h, P.YAWS[0], fill)
        for (y in 0 until im.height) for (x in 0 until im.width) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(i * P.W + x, row * P.H + y, q) }
        g.color = java.awt.Color(0x6A665E); g.drawRect(i * P.W, row * P.H, P.W - 1, P.H - 1)
        g.drawLine(i * P.W, row * P.H + P.H / 2, i * P.W + 8, row * P.H + P.H / 2)
    }
    ImageIO.write(out, "png", File("build/screens/portrait_fill.png"))
}

/** The map figure of cleric and fighter from every side, large. */
fun renderMapShields() {
    val CA = de.bornim.core.art.CharacterArt
    val facings = listOf(de.bornim.core.Facing.DOWN, de.bornim.core.Facing.LEFT, de.bornim.core.Facing.UP, de.bornim.core.Facing.RIGHT)
    val heroes = listOf(de.bornim.core.CharClass.CLERIC, de.bornim.core.CharClass.FIGHTER).map { de.bornim.core.Hero.create("Karte", de.bornim.core.Race.HUMAN, it) }
    val k = 8
    val out = BufferedImage(32 * k * 4, 32 * k * 2, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x5A8A3A); g.fillRect(0, 0, out.width, out.height)
    for ((r, h) in heroes.withIndex()) for ((c, f) in facings.withIndex()) {
        val im = CA.hero(h, f, 0)
        for (y in 0 until 32) for (x in 0 until 32) { val q = im[x, y]; if ((q ushr 24) >= 128) { g.color = java.awt.Color(q and 0xFFFFFF); g.fillRect(c * 32 * k + x * k, r * 32 * k + y * k, k, k) } }
    }
    ImageIO.write(out, "png", File("build/screens/map_shields.png"))
}

/** Draft: goblin and skeleton on the hero's doll, bare and armed, from several sides, a human beside them for size. */
fun renderFoeDrafts() {
    val HF = de.bornim.core.art.HeroFigure
    var uid = 1L
    fun g(base: String) = de.bornim.core.Gear(uid++, base, de.bornim.core.Rarity.COMMON, 1)
    val W = 150; val H = 230; val px = 0.9
    val rest = HF.sequence(de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Strike.SLASH, 0, de.bornim.core.art.HeroFigure.Stance.MELEE)[0]
    // a goblin stoops, knees bent, head pushed forward
    val stoop = de.bornim.core.art.HeroFigure.READY.copy(lean = 0.42, crouch = 4.5, headDown = -2.5, headTurn = 0.0)
    val yaws = listOf(-30.0, 0.0, -90.0, 160.0)
    val G = de.bornim.core.art.Doll.Creature.GOBLIN; val S = de.bornim.core.art.Doll.Creature.SKELETON
    val gob = { sex: de.bornim.core.Sex, skin: Int -> de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, sex, de.bornim.core.Build.AVERAGE, skin, 0, G) }
    val skel = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 0, 0, S)
    val human = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0)
    val gobKit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.ROGUE, mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("scimitar"), de.bornim.core.GearSlot.CHEST to g("leather"), de.bornim.core.GearSlot.OFF_HAND to g("round_shield")), rusty = true, crude = true)
    val skelKit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("shortsword"), de.bornim.core.GearSlot.HEAD to g("helmet")), rusty = true)
    val heroKit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("longsword"), de.bornim.core.GearSlot.CHEST to g("chain_shirt"), de.bornim.core.GearSlot.OFF_HAND to g("shield")))
    data class Cell(val doll: de.bornim.core.art.Doll, val rig: de.bornim.core.art.HeroFigure.Rig, val kit: de.bornim.core.art.Outfit?)
    val rows = listOf(
        yaws.map { Cell(gob(de.bornim.core.Sex.MALE, 0), stoop.copy(yaw = it), null) },
        yaws.map { Cell(gob(de.bornim.core.Sex.MALE, 1), stoop.copy(yaw = it), gobKit) },
        yaws.map { Cell(skel, rest.copy(yaw = it), null) },
        yaws.map { Cell(skel, rest.copy(yaw = it), skelKit) },
    )
    val cols = yaws.size + 1
    val out = BufferedImage(W * cols, H * rows.size, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x3C3A36); gg.fillRect(0, 0, out.width, out.height)
    fun put(im: de.bornim.core.art.PixelImage, ox: Int, oy: Int) { for (y in 0 until im.height) for (x in 0 until im.width) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(ox + x, oy + y, q) } }
    for ((r, row) in rows.withIndex()) {
        for ((c, cell) in row.withIndex()) put(cell.doll.render(W, H, W / 2.0, H - 6.0, px, cell.rig, cell.kit).img, c * W, r * H)
        // the hero for size, turned towards them
        put(human.render(W, H, W / 2.0, H - 6.0, px, rest.copy(yaw = 30.0), heroKit).img, yaws.size * W, r * H)
    }
    ImageIO.write(out, "png", File("build/screens/foe_drafts.png"))
    println("wrote foe drafts")
}

/** Draft in place: goblin and skeleton where the foe stands, in the forest and the cave, the hero in front; the wolf for comparison. */
fun renderFoeInScene() {
    val HF = de.bornim.core.art.HeroFigure
    val B = de.bornim.core.art.HeroBattle
    val BS = de.bornim.core.art.BattleScene
    var uid = 1L
    fun g(base: String) = de.bornim.core.Gear(uid++, base, de.bornim.core.Rarity.COMMON, 1)
    val sw = 270; val sh = 410
    val hero = de.bornim.core.Hero.create("Borin", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.FIGHTER)
    val heroImg = B.frame(hero, de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Strike.SLASH, 0, 0)
    val rest = HF.sequence(de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Strike.SLASH, 0, de.bornim.core.art.HeroFigure.Stance.MELEE)[0]
    val stoop = de.bornim.core.art.HeroFigure.READY.copy(lean = 0.42, crouch = 4.5, headDown = -2.5, headTurn = 0.0)
    val gob = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 1, 0, de.bornim.core.art.Doll.Creature.GOBLIN)
    val skel = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, 0, 0, de.bornim.core.art.Doll.Creature.SKELETON)
    val gobKit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.ROGUE, mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("scimitar"), de.bornim.core.GearSlot.CHEST to g("leather"), de.bornim.core.GearSlot.OFF_HAND to g("round_shield")), rusty = true, crude = true)
    val skelKit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.MAIN_HAND to g("shortsword"), de.bornim.core.GearSlot.HEAD to g("helmet")), rusty = true)
    // the foe stands further off than the hero: a little smaller per centimetre
    val foePx = 0.66
    val fw = 150; val fh = 200
    // turned to face the hero, down at the left
    val gobImg = gob.render(fw, fh, fw / 2.0, fh - 6.0, foePx, stoop.copy(yaw = -35.0), gobKit).img
    val skelImg = skel.render(fw, fh, fw / 2.0, fh - 6.0, foePx, rest.copy(yaw = -35.0), skelKit).img
    val wolfImg = de.bornim.core.art.MonsterArt.battleFrame("wolf", de.bornim.core.MonsterLook(3), de.bornim.core.art.Act.IDLE, 0, 0)
    val forest = BS.forest(sw, sh, de.bornim.core.art.BattleScene.Spot.entries[0], de.bornim.core.art.BattleScene.Light.DAY, false, 7)
    val CS = de.bornim.core.art.CaveScene
    val cave = CS.cave(sw, sh, de.bornim.core.art.CaveScene.Spot.HALL, de.bornim.core.art.CaveScene.Light.TORCH, 7)
    val tint = CS.tint(de.bornim.core.art.CaveScene.Spot.HALL, de.bornim.core.art.CaveScene.Light.TORCH)
    fun shade(c: Int, t: Int?): Int {
        if (t == null) return c
        val r = ((c shr 16) and 255) * ((t shr 16) and 255) / 255; val gg = ((c shr 8) and 255) * ((t shr 8) and 255) / 255; val b = (c and 255) * (t and 255) / 255
        return (c and 0xFF000000.toInt()) or (r shl 16) or (gg shl 8) or b
    }
    val k = 2
    val panels = listOf(Triple(forest, gobImg, null as Int?), Triple(cave, skelImg, tint), Triple(forest, wolfImg, null as Int?))
    val out = BufferedImage((sw * panels.size + 10 * (panels.size - 1)) * k, sh * k, BufferedImage.TYPE_INT_RGB)
    for ((pi, pan) in panels.withIndex()) {
        val (bg, foe, t) = pan
        val canvas = IntArray(sw * sh) { bg.pixels[it] }
        fun blit(im: de.bornim.core.art.PixelImage, ox: Int, oy: Int, tt: Int?) {
            for (y in 0 until im.height) for (x in 0 until im.width) { val q = im[x, y]; val X = ox + x; val Y = oy + y
                if ((q ushr 24) >= 128 && X in 0 until sw && Y in 0 until sh) canvas[Y * sw + X] = shade(q, tt) }
        }
        val isWolf = foe === wolfImg
        val feet = if (isWolf) de.bornim.core.art.MonsterArt.groundLine("wolf").toInt() else fh - 6
        blit(foe, (sw * BS.FOE_X).toInt() - foe.width / 2, (sh * BS.FOE_Y).toInt() - feet, t)
        blit(heroImg, (sw * BS.HERO_X - B.ANCHOR_X).toInt(), (sh * BS.HERO_Y - B.GROUND).toInt(), t)
        for (y in 0 until sh * k) for (x in 0 until sw * k) out.setRGB(pi * (sw + 10) * k + x, y, canvas[(y / k) * sw + x / k] and 0xFFFFFF)
    }
    ImageIO.write(out, "png", File("build/screens/foe_in_scene.png"))
    println("wrote foe in scene")
}

/** Every kit of goblin, goblin scout and skeleton, turned to the hero, two seeds each so skin tones vary as well. */
fun renderFoeKits() {
    val W = 120; val H = 200; val px = 0.9
    val ids = listOf("goblin", "goblin_archer", "skeleton")
    val out = BufferedImage(W * 6, H * ids.size, BufferedImage.TYPE_INT_RGB)
    val gg = out.createGraphics(); gg.color = java.awt.Color(0x3C3A36); gg.fillRect(0, 0, out.width, out.height)
    fun put(im: de.bornim.core.art.PixelImage, ox: Int, oy: Int) { for (y in 0 until im.height) for (x in 0 until im.width) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(ox + x, oy + y, q) } }
    for ((r, id) in ids.withIndex()) for (c in 0 until 6) {
        val seed = c % 3 + 3 * (c / 3) * 5
        val kit = de.bornim.core.MonsterKits.of(id, seed)!!
        val creature = if (id == "skeleton") de.bornim.core.art.Doll.Creature.SKELETON else de.bornim.core.art.Doll.Creature.GOBLIN
        val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE, de.bornim.core.MonsterKits.tone(seed), 0, creature)
        val stance = de.bornim.core.art.HeroFigure.stance(de.bornim.core.GearBases[kit.items.getValue(de.bornim.core.GearSlot.MAIN_HAND)])
        val base = if (stance == de.bornim.core.art.HeroFigure.Stance.MELEE) de.bornim.core.art.HeroFigure.READY.copy(headTurn = 0.0)
            else de.bornim.core.art.HeroFigure.sequence(de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Strike.SLASH, 0, stance)[0]
        // goblins stoop and crouch; the dead stand stiff
        val rig = (if (creature == de.bornim.core.art.Doll.Creature.GOBLIN) base.copy(lean = 0.42, crouch = 4.5, headDown = -2.5) else base).copy(yaw = -35.0)
        put(doll.render(W, H, W / 2.0, H - 6.0, px, rig, de.bornim.core.art.Outfit.of(kit)).img, c * W, r * H)
    }
    ImageIO.write(out, "png", File("build/screens/foe_kits.png"))
    println("wrote foe kits")
}
