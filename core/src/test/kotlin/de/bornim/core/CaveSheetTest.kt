package de.bornim.core

import de.bornim.core.art.MapCave
import de.bornim.core.art.MapCaveIso
import de.bornim.core.art.MapGround
import de.bornim.core.art.MapRoomIso
import de.bornim.core.art.PixelImage
import de.bornim.core.art.WorldArt
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO
import kotlin.test.Test

/**
 * 13e: the whole cave seen diagonally in seconds, without the app: the ground and the cave's things as the game puts
 * them, no light, no fog. Only with CAVESHEET=1 (a picture for the eye, not a check); writes build/preview/hoehle_plan.png.
 */
class CaveSheetTest {
    @Test
    fun sheet() {
        if (System.getenv("CAVESHEET") == null) return
        MapCaveIso.draft = true
        val map = World["cave"]
        val tw = MapRoomIso.TW; val th = MapRoomIso.TH
        val ox = map.height * tw / 2 + 40; val oy = 260.0
        val w = ((map.width + map.height) * tw / 2 + 80).toInt(); val h = ((map.width + map.height) * th / 2 + oy + 40).toInt()
        val out = BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB)
        // the ground: each pixel back onto the map
        val S = MapGround.S; val CH = MapGround.CH
        val chunks = HashMap<Long, PixelImage>()
        for (py in 0 until h) for (px in 0 until w) {
            val a = (px + 0.5 - ox) / (tw / 2); val b = (py + 0.5 - oy) / (th / 2)
            val gi = (a + b) / 2; val gj = (b - a) / 2
            if (gi < 0 || gj < 0 || gi >= map.width || gj >= map.height) { out.setRGB(px, py, 0xFF000000.toInt()); continue }
            val x = (gi * S).toInt(); val y = (gj * S).toInt()
            val cx = x / (CH * S); val cy = y / (CH * S)
            val ch = chunks.getOrPut(cx * 1000L + cy) { MapCave.ground(map, cx, cy) }
            out.setRGB(px, py, ch[x - cx * CH * S, y - cy * CH * S] or (0xFF shl 24))
        }
        // the things, sorted as the game sorts them
        val objs = ArrayList<WorldArt.Obj>()
        for (ty in 0 until map.height) for (tx in 0 until map.width)
            objs += MapCaveIso.objects(map, tx, ty, 0, false, false) ?: MapCave.objects(map, tx, ty, 0, false, false).orEmpty()
        objs.sortBy { it.sortY + it.x + it.img.width / it.density / 2f }
        val T = WorldArt.T.toDouble()
        for (o in objs) {
            if (!o.corner) continue
            val fx = (o.x + o.img.width / (2.0 * o.density)) / T; val fy = (o.y + o.img.height.toDouble() / o.density) / T
            val sx = ox + (fx - fy) * tw / 2; val sy = oy + (fx + fy) * th / 2
            val x0 = (sx - o.img.width / 2.0).toInt(); val y0 = (sy - o.img.height).toInt()
            for (y in 0 until o.img.height) for (x in 0 until o.img.width) {
                val c = o.img[x, y]; val al = c ushr 24
                if (al == 0) continue
                val px = x0 + x; val py = y0 + y
                if (px !in 0 until w || py !in 0 until h) continue
                out.setRGB(px, py, if (al == 255) c else de.bornim.core.art.mix(out.getRGB(px, py), c or (0xFF shl 24), al / 255.0))
            }
        }
        File("build/preview").mkdirs()
        ImageIO.write(out, "png", File("build/preview/hoehle_plan.png"))
        // 13e.2: the things up close, each kind's tiles cut out of the plan at twice the size
        val things = listOf(Tile.GLOWSHROOM, Tile.CRYSTAL, Tile.STALAGMITE, Tile.RUBBLE, Tile.CHEST, Tile.CRATE, Tile.BEDROLL)
        val spots = ArrayList<Pair<Int, Int>>()
        for (k in things) for (ty in 0 until map.height) for (tx in 0 until map.width) if (map.tile(tx, ty) == k) spots += tx to ty
        if (spots.isEmpty()) return
        val cw = 180; val chh = 150; val cols = 4; val rows = (spots.size + cols - 1) / cols
        val sheet = BufferedImage(cols * cw * 2, rows * chh * 2, BufferedImage.TYPE_INT_ARGB)
        for ((n, s) in spots.withIndex()) {
            val (tx, ty) = s
            val sx = (ox + (tx + 0.5 - (ty + 0.5)) * tw / 2).toInt(); val sy = (oy + (tx + ty + 1.0) * th / 2).toInt()
            for (y in 0 until chh * 2) for (x in 0 until cw * 2) {
                val px = sx - cw / 2 + x / 2; val py = sy - chh * 2 / 3 + y / 2
                sheet.setRGB((n % cols) * cw * 2 + x, (n / cols) * chh * 2 + y, if (px in 0 until w && py in 0 until h) out.getRGB(px, py) else 0xFF000000.toInt())
            }
        }
        ImageIO.write(sheet, "png", File("build/preview/hoehle_dinge.png"))
        // every look of each, on plain floor, twice the size: chests shut and open, crates, sleeping places
        val looks = listOf(Tile.CHEST to false, Tile.CHEST to true, Tile.CRATE to false, Tile.BEDROLL to false)
        val gw = 100; val gh = 150
        val gal = BufferedImage(3 * gw * 2, looks.size * gh * 2, BufferedImage.TYPE_INT_ARGB)
        for ((r, look) in looks.withIndex()) for (v in 0 until 3) {
            val img = MapCaveIso.sample(look.first, v, look.second)
            for (y in 0 until gh * 2) for (x in 0 until gw * 2) {
                val ix = x / 2 - (gw - img.width) / 2; val iy = y / 2 - (gh - 10 - img.height)
                var c = 0xFF3A332C.toInt()
                if (ix in 0 until img.width && iy in 0 until img.height) {
                    val p = img[ix, iy]; val al = p ushr 24
                    if (al > 0) c = de.bornim.core.art.mix(c, p or (0xFF shl 24), al / 255.0)
                }
                gal.setRGB(v * gw * 2 + x, r * gh * 2 + y, c)
            }
        }
        ImageIO.write(gal, "png", File("build/preview/hoehle_varianten.png"))
    }
}
