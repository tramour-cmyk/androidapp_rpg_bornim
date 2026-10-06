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
    for (race in de.bornim.core.Race.entries) for (weapon in listOf("longsword", "mace", "shortsword", "warhammer")) {
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
    for (race in de.bornim.core.Race.entries) for (weapon in listOf("greatsword", "greataxe", "quarterstaff")) {
        val doll = de.bornim.core.art.Doll(race, de.bornim.core.Sex.MALE, de.bornim.core.Build.AVERAGE)
        val outfit = de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(de.bornim.core.GearSlot.MAIN_HAND to g(weapon)))
        val runs = listOf(
            Triple(de.bornim.core.art.HeroFigure.Act.IDLE, de.bornim.core.art.HeroFigure.Strike.SLASH, 0), Triple(de.bornim.core.art.HeroFigure.Act.BLOCK, de.bornim.core.art.HeroFigure.Strike.SLASH, 1),
            Triple(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SLASH, 0), Triple(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.SMASH, 0),
            Triple(de.bornim.core.art.HeroFigure.Act.ATTACK, de.bornim.core.art.HeroFigure.Strike.THRUST, 0))
        for (run in runs) for ((i, rig) in F.sequence(run.first, run.second, run.third).withIndex()) {
            twoTotal++
            val dress = doll.fit(rig, outfit).second!!.first
            dress.weaponThroughBody()?.let { t -> twoBad++; if (twoBad <= 10) println("ZWEIHAND: ${race.name} $weapon ${run.first}/${run.second}/${run.third} Bild $i bei ${(t * 100).toInt()} %") }
        }
        if (weapon == "greatsword") {
            val sk = doll.fit(F.PARRY, outfit).first
            val fa = sk.wrist[0] - sk.elbow[0]
            val deg = Math.toDegrees(Math.atan2(fa.y, Math.sqrt(fa.x * fa.x + fa.z * fa.z)))
            val wdeg = Math.toDegrees(Math.asin(sk.weapon.y.coerceIn(-1.0, 1.0)))
            val headGap = (sk.wrist[0].lerp(sk.elbow[0], 0.5) - sk.head.apply(doll.headC)).len() - doll.hh * 0.45
            val hc = sk.head.apply(doll.headC)
            println("  Hand ${sk.wrist[1].y.toInt()}/${sk.wrist[1].z.toInt()}  Kopfmitte ${hc.y.toInt()}/${hc.z.toInt()}  Stützellbogen ${sk.elbow[0].x.toInt()}/${sk.elbow[0].y.toInt()}/${sk.elbow[0].z.toInt()}")
            println("PARADE ${race.name}: Stützunterarm ${"%.0f".format(deg)}° zur Waagerechten, Waffe ${"%.0f".format(wdeg)}° zur Waagerechten, Abstand Unterarm–Kopf ${"%.0f".format(headGap)} cm")
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
    )
    val dir0 = File("build/screens/dollanim"); dir0.deleteRecursively(); dir0.mkdirs()
    for ((name, rigs) in clips) {
        val dir = File(dir0, name); dir.mkdirs()
        for ((i, rig) in rigs.withIndex()) {
            val cw = 150; val chh = 190
            val kit = when (name) {
                "schlag" -> de.bornim.core.art.Outfit(outfit.cls, outfit.items + (de.bornim.core.GearSlot.MAIN_HAND to g("warhammer", de.bornim.core.Rarity.RARE)))
                "parade", "zweihand" -> de.bornim.core.art.Outfit(outfit.cls, (outfit.items - de.bornim.core.GearSlot.OFF_HAND) + (de.bornim.core.GearSlot.MAIN_HAND to g("greatsword", de.bornim.core.Rarity.RARE)))
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
        de.bornim.core.art.HeroFigure.PARRY to two, de.bornim.core.art.HeroFigure.PARRY to axe, de.bornim.core.art.HeroFigure.BLOCK to outfit)
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
