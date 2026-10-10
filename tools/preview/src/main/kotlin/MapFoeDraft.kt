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
        "walk" -> {
            val cells = looks.flatMap { (id, l) -> listOf(2, 4, 6, 12).map { s -> (0 until MapFoe.STEPS).map { st -> MapFoe.draw(id, l, s, st) } } }
            ImageIO.write(sheetOf(cells, MapFoe.W, MapFoe.H), "png", File("build/screens/mapfoe/walk.png"))
        }
    }
    println("wrote mapfoe $mode")
}

/** Wolves and goblins near Garrick's fire with the hero, the former sprites ([newStyle] false) or the drafts. */
private fun foeScene(newStyle: Boolean): BufferedImage {
    val map = de.bornim.core.World["forest"]
    de.bornim.core.art.MapGround.prepareNow(map)
    val S = de.bornim.core.art.MapGround.S
    val x0 = 8; val y0 = 7; val tw = 7; val th = 6
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
    val (hx, hy) = foot(10, 9)
    things += Thing(hy) {
        if (newStyle) { blend(shadow, hx - 24, hy - 10, 2); val f = de.bornim.core.art.MapFigure.draw(state.hero, 4, 0)
            blend(f, hx - de.bornim.core.art.MapFigure.ANCHOR_X, hy - de.bornim.core.art.MapFigure.GROUND, 1) }
        else { val f = de.bornim.core.art.CharacterArt.hero(state.hero, de.bornim.core.Facing.RIGHT); blend(f, hx - f.width, hy - f.height * 2 + 2, 2) }
    }
    // (kind, look, tile x, tile y, direction slot, step)
    val foes = listOf(
        listOf("wolf", 0, 13, 8, 12, 1), listOf("wolf", 1, 13, 10, 13, 5), listOf("dire_wolf", 0, 8, 7, 3, 3),
        listOf("goblin", 0, 8, 10, 3, 1), listOf("goblin", 1, 9, 11, 2, 3), listOf("goblin", 2, 11, 10, 1, 6),
    )
    for (f in foes) {
        val id = f[0] as String; val look = MonsterLook(f[1] as Int); val slot = f[4] as Int
        val (fx, fy) = foot(f[2] as Int, f[3] as Int)
        things += Thing(fy) {
            if (newStyle) {
                val img = MapFoe.draw(id, look, slot, f[5] as Int)
                blend(shadow, fx - 24, fy - 10, 2)
                blend(img, fx - MapFoe.ANCHOR_X, fy - MapFoe.GROUND, 1)
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
