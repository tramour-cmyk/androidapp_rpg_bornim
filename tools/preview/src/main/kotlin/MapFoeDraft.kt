package preview

import de.bornim.core.MonsterLook
import de.bornim.core.art.MapFoe
import de.bornim.core.art.PixelImage
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

private fun sheetOf(cells: List<List<PixelImage?>>, cw: Int, ch: Int): BufferedImage {
    val rows = cells.size; val cols = cells.maxOf { it.size }
    val out = BufferedImage(cols * cw, rows * ch, BufferedImage.TYPE_INT_RGB)
    for (r in 0 until rows) for (c in 0 until cols) {
        val img = cells[r].getOrNull(c)
        for (y in 0 until ch) for (x in 0 until cw) {
            val q = if (img != null && x < img.width && y < img.height) img[x, y] else 0
            out.setRGB(c * cw + x, r * ch + y, if ((q ushr 24) >= 128) q else if ((x / 16 + y / 16) % 2 == 0) 0x3A4430 else 0x34402C)
        }
    }
    return out
}

/**
 * MAPFOE: drafts of the monsters on the map (9). MAPFOE=yaws: wolf and goblins in all 16 directions;
 * MAPFOE=walk: the walk of each in four directions; IDS=wolf,goblin picks the kinds.
 */
fun renderMapFoeDraft() {
    File("build/screens/mapfoe").mkdirs()
    val mode = System.getenv("MAPFOE") ?: "yaws"
    val ids = (System.getenv("IDS") ?: "wolf,goblin").split(",")
    val looks = ids.flatMap { id -> (0 until 3).map { id to MonsterLook(it) } }.take(if (mode == "yaws") 99 else ids.size).let { all ->
        if (mode == "yaws") all else ids.map { it to MonsterLook(0) } }
    when (mode) {
        "yaws" -> {
            val cells = looks.map { (id, l) -> (0 until 16).map { s -> MapFoe.draw(id, l, s, 0) } }
            ImageIO.write(sheetOf(cells, MapFoe.W, MapFoe.H), "png", File("build/screens/mapfoe/yaws.png"))
        }
        "scene" -> {
            val a = foeScene(false); val b = foeScene(true)
            val both = BufferedImage(a.width * 2 + 12, a.height, BufferedImage.TYPE_INT_RGB)
            both.graphics.drawImage(a, 0, 0, null); both.graphics.drawImage(b, a.width + 12, 0, null)
            ImageIO.write(both, "png", File("build/screens/mapfoe/scene.png"))
        }
        "dirs" -> {
            // eight directions, standing: down, down-right, right, up-right, up, up-left, left, down-left
            val rows = listOf("wolf" to 0, "wolf" to 2, "goblin" to 0, "goblin" to 1, "goblin" to 2)
            val cells = rows.map { (id, l) -> (0 until 8).map { d -> MapFoe.draw(id, MonsterLook(l), d * 2, 0) } }
            ImageIO.write(sheetOf(cells, MapFoe.W, MapFoe.H), "png", File("build/screens/mapfoe/dirs.png"))
        }
        "idle" -> {
            // every stance standing, breathing in, half turned towards us; Grimfang with the wolves
            val rows = listOf("wolf" to MapFoe.Idle.entries.take(6), "dire_wolf" to MapFoe.Idle.entries.take(6),
                "goblin" to (listOf(MapFoe.Idle.STAND, MapFoe.Idle.LOOK_L, MapFoe.Idle.LOOK_R) + MapFoe.Idle.entries.drop(6)))
            val f = MapFoe.frame("dire_wolf")
            val cells = rows.map { (id, idles) -> idles.map { MapFoe.drawIdle(id, MonsterLook(0), 2, it, 1) } }
            ImageIO.write(sheetOf(cells, f.w, f.h), "png", File("build/screens/mapfoe/idle.png"))
        }
        "ease" -> {
            // 9h: each stance going in, step by step, from standing (left) to fully in it (right)
            val rows = listOf("wolf" to MapFoe.Idle.SNIFF, "wolf" to MapFoe.Idle.SNARL, "wolf" to MapFoe.Idle.LOOK_L, "goblin" to MapFoe.Idle.CROUCH, "goblin" to MapFoe.Idle.HEFT)
            val cells = rows.map { (id, idle) -> (0..MapFoe.LEVELS).map { lv -> MapFoe.drawIdle(id, MonsterLook(0), 2, idle, 0, level = lv) } }
            ImageIO.write(sheetOf(cells, MapFoe.W, MapFoe.H), "png", File("build/screens/mapfoe/ease.png"))
        }
        "others" -> {
            // 9, the other foes: the former sprite (left), then the draft facing down, right, up and left
            val ids = (System.getenv("IDS") ?: "boar,giant_rat,kobold,skeleton,zombie,ghoul,goblin_shaman,bugbear,hobgoblin_captain,giant_spider,giant_centipede,giant_bat,stirge,ochre_jelly").split(",")
            val f = MapFoe.frame("dire_wolf")
            fun old(id: String): PixelImage {
                val o = de.bornim.core.art.MonsterArt.mapSprite(id, MonsterLook(0), 0, mirrored = false)
                val big = PixelImage(f.w, f.h)
                // twice as large (one map pixel is two art pixels), the feet on the same line
                for (y in 0 until o.height * 2) for (x in 0 until o.width * 2) {
                    val px = f.ax - o.width + x; val py = f.gy + 4 - o.height * 2 + y
                    if (px in 0 until f.w && py in 0 until f.h) big.set(px, py, o[x / 2, y / 2])
                }
                return big
            }
            val cells = ids.map { id -> listOf(old(id)) + listOf(0, 4, 8, 12).map { s ->
                val img = MapFoe.draw(id, MonsterLook(0), s, 0)
                val fr = MapFoe.frame(id)
                // into the larger cell, the feet on the same line
                val out = PixelImage(f.w, f.h)
                for (y in 0 until img.height) for (x in 0 until img.width) {
                    val px = x - fr.ax + f.ax; val py = y - fr.gy + f.gy
                    if (px in 0 until f.w && py in 0 until f.h) out.set(px, py, img[x, y])
                }
                out
            } }
            ImageIO.write(sheetOf(cells, f.w, f.h), "png", File("build/screens/mapfoe/others.png"))
        }
        "cave" -> {
            // 9, the other foes in the Bloodfang Cave by the fire: the former sprites (left) against the drafts
            val foes = listOf(listOf("giant_spider", 0, 15, 13, 2, 0), listOf("kobold", 0, 17, 14, 13, 0), listOf("giant_bat", 0, 18, 13, 14, 0),
                listOf("ochre_jelly", 0, 15, 15, 1, 0), listOf("giant_centipede", 0, 15, 16, 12, 0), listOf("skeleton", 0, 17, 16, 12, 0))
            val a = foeScene(false, "cave", 12, 12, 8, 5, 13 to 16, foes); val b = foeScene(true, "cave", 12, 12, 8, 5, 13 to 16, foes)
            val both = BufferedImage(a.width * 2 + 12, a.height, BufferedImage.TYPE_INT_RGB)
            both.graphics.drawImage(a, 0, 0, null); both.graphics.drawImage(b, a.width + 12, 0, null)
            ImageIO.write(both, "png", File("build/screens/mapfoe/cave.png"))
        }
        "wood" -> {
            // 9, the other foes of the wood and the night: boar, rat, zombie, ghoul, shaman, skeleton
            val foes = listOf(listOf("boar", 0, 13, 8, 12, 0), listOf("giant_rat", 0, 13, 10, 13, 0), listOf("zombie", 0, 8, 10, 3, 0),
                listOf("ghoul", 0, 9, 11, 2, 0), listOf("goblin_shaman", 0, 11, 10, 1, 0), listOf("skeleton", 1, 8, 8, 4, 0))
            val a = foeScene(false, foes = foes); val b = foeScene(true, foes = foes)
            val both = BufferedImage(a.width * 2 + 12, a.height, BufferedImage.TYPE_INT_RGB)
            both.graphics.drawImage(a, 0, 0, null); both.graphics.drawImage(b, a.width + 12, 0, null)
            ImageIO.write(both, "png", File("build/screens/mapfoe/wood.png"))
        }
        "side" -> {
            // 9k: the goblins and the scout seen from the side, standing and in a stride
            val rows = listOf("goblin" to 0, "goblin" to 1, "goblin" to 2, "goblin_archer" to 0)
            val cells = rows.map { (id, l) -> listOf(4, 12, 3, 13).flatMap { s -> listOf(MapFoe.draw(id, MonsterLook(l), s, 0), MapFoe.draw(id, MonsterLook(l), s, 2)) } }
            ImageIO.write(sheetOf(cells, MapFoe.W, MapFoe.H), "png", File("build/screens/mapfoe/side.png"))
        }
        "walk" -> {
            val cells = looks.flatMap { (id, l) -> listOf(2, 4, 6, 12).map { s -> (0 until MapFoe.STEPS).map { st -> MapFoe.draw(id, l, s, st) } } }
            ImageIO.write(sheetOf(cells, MapFoe.W, MapFoe.H), "png", File("build/screens/mapfoe/walk.png"))
        }
    }
    println("wrote mapfoe $mode")
}

/** Wolves and goblins near Garrick's fire with the hero, the former sprites ([newStyle] false) or the drafts. */
private fun foeScene(newStyle: Boolean, mapId: String = "forest", x0: Int = 8, y0: Int = 7, tw: Int = 7, th: Int = 6,
    heroAt: Pair<Int, Int> = 10 to 9, foes: List<List<Any>> = listOf(
        listOf("wolf", 0, 13, 8, 12, 1), listOf("wolf", 1, 13, 10, 13, 5), listOf("dire_wolf", 0, 8, 7, 3, 3),
        listOf("goblin", 0, 8, 10, 3, 1), listOf("goblin", 1, 9, 11, 2, 3), listOf("goblin", 2, 11, 10, 1, 6),
    )): BufferedImage {
    val map = de.bornim.core.World[mapId]
    de.bornim.core.art.MapGround.prepareNow(map)
    val S = de.bornim.core.art.MapGround.S
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
    val state = de.bornim.core.GameState.newGame("Mira", de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.FIGHTER)
    class Thing(val sortY: Int, val draw: () -> Unit)
    val things = mutableListOf<Thing>()
    for (o in de.bornim.core.art.WorldArt.objects(map, state, 0)) things += Thing(o.sortY * 2) { blend(o.img, o.x * 2, o.y * 2, 2 / o.density) }
    val shadow = de.bornim.core.art.WorldArt.shadow()
    fun foot(tx: Int, ty: Int) = (tx * S + S / 2) to (ty * S + S - 4)
    // the hero west of the fire, looking right
    val (hx, hy) = foot(heroAt.first, heroAt.second)
    things += Thing(hy) {
        if (newStyle) { blend(shadow, hx - 24, hy - 10, 2); val f = de.bornim.core.art.MapFigure.draw(state.hero, 4, 0)
            blend(f, hx - de.bornim.core.art.MapFigure.ANCHOR_X, hy - de.bornim.core.art.MapFigure.GROUND, 1) }
        else { val f = de.bornim.core.art.CharacterArt.hero(state.hero, de.bornim.core.Facing.RIGHT); blend(f, hx - f.width, hy - f.height * 2 + 2, 2) }
    }
    // foes: (kind, look, tile x, tile y, direction slot, step)
    for (f in foes) {
        val id = f[0] as String; val look = MonsterLook(f[1] as Int); val slot = f[4] as Int
        val (fx, fy) = foot(f[2] as Int, f[3] as Int)
        things += Thing(fy) {
            if (newStyle) {
                val img = MapFoe.draw(id, look, slot, f[5] as Int)
                val fr = MapFoe.frame(id)
                blend(shadow, fx - 24, fy - 10, 2)
                blend(img, fx - fr.ax, fy - fr.gy, 1)
            } else {
                // the former sprite only looks left or right
                val right = slot in 1..7
                val img = de.bornim.core.art.MonsterArt.mapSprite(id, look, 0, mirrored = right)
                blend(shadow, fx - 24, fy - 10, 2)
                blend(img, fx - img.width, fy - img.height * 2 + 2, 2)
            }
        }
    }
    for (t in things.sortedBy { it.sortY }) t.draw()
    return out
}
