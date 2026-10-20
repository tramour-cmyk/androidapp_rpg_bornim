package preview

import de.bornim.core.Build
import de.bornim.core.CharClass
import de.bornim.core.Facing
import de.bornim.core.GameState
import de.bornim.core.Gear
import de.bornim.core.GearSlot
import de.bornim.core.Hero
import de.bornim.core.Race
import de.bornim.core.Rarity
import de.bornim.core.art.CharacterArt
import de.bornim.core.art.MapFigure
import de.bornim.core.art.MapGround
import de.bornim.core.art.PixelImage
import java.awt.Color
import java.awt.Font
import java.awt.RenderingHints
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** Draft (09.10.): the villagers as dolls on the map, starting with Garrick the hunter. NPCDRAFT=1 */
fun renderNpcDraft() {
    var uid = 5000L
    fun dressed(name: String, race: Race, cls: CharClass, build: Build, skin: Int, hair: Int, vararg items: String): Hero {
        val h = GameState.newGame(name, race, cls).hero
        h.build = build; h.skin = skin; h.hair = hair
        h.gear.clear()
        for (b in items) { val g = Gear(uid++, b, Rarity.COMMON, 1); h.gear[g.def.slot] = g }
        return h
    }
    val folk = de.bornim.core.art.MapFolk
    val variants = listOf(
        "vorher: Variante A (18:53)" to { sl: Int, st: Int -> MapFigure.draw(dressed("Garrick", Race.HUMAN, CharClass.ROGUE, Build.STRONG, 2, 1, "hood", "leather", "gloves", "boots", "cloak", "longbow"), sl, st) },
        "neu: Kapuze olivbraun, Bart, dunkles Leder, Bogen und Köcher auf dem Rücken" to { sl: Int, st: Int -> folk.draw(folk.garrick, sl, st) },
    )
    val F = MapFigure
    val slots = listOf(0, 2, 4, 6, 8, 10, 12, 14)
    val lab = 22
    val sheetW = F.W * (slots.size + 1); val rowH = F.H + lab
    val sheet = BufferedImage(sheetW, rowH * variants.size, BufferedImage.TYPE_INT_RGB)
    val g = sheet.createGraphics()
    g.color = Color(0x2E3628); g.fillRect(0, 0, sheet.width, sheet.height)
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.font = Font(Font.SANS_SERIF, Font.BOLD, 13)
    fun paste(img: PixelImage, ox: Int, oy: Int, k: Int = 1) {
        for (y in 0 until img.height * k) for (x in 0 until img.width * k) {
            val q = img[x / k, y / k]; if ((q ushr 24) < 128) continue
            if (ox + x in 0 until sheet.width && oy + y in 0 until sheet.height) sheet.setRGB(ox + x, oy + y, q)
        }
    }
    val old = CharacterArt.npc("hunter", Facing.DOWN)
    variants.forEachIndexed { r, (title, draw) ->
        g.color = Color(0xE8DCC0); g.drawString(title, 6, r * rowH + 16)
        slots.forEachIndexed { i, s -> paste(draw(s, 0), i * F.W, r * rowH + lab) }
    }
    // the former Garrick at the same scale, for comparison
    g.color = Color(0xE8DCC0); g.drawString("bisher", slots.size * F.W + 6, 16)
    paste(old, slots.size * F.W + (F.W - old.width * 2) / 2, lab + F.GROUND - old.height * 2 + 4, 2)
    g.dispose()
    File("build/screens").mkdirs()
    ImageIO.write(sheet, "png", File("build/screens/npc_garrick_ansichten.png"))

    // in place: Garrick at his fire (12,9) facing left, the hero coming up the path to him
    val x0 = 7; val y0 = 5; val tw = 9; val th = 7
    renderFloraSheet("forest:$x0:$y0:$tw:$th")
    val scene = ImageIO.read(File("build/screens/flora_forest_$x0-$y0.png"))
    val S = MapGround.S
    fun place(img: PixelImage, tx: Int, ty: Int) {
        val ox = (tx - x0) * S + S / 2 - F.ANCHOR_X; val oy = (ty - y0) * S + (S * 0.8).toInt() - F.GROUND
        for (y in 0 until img.height) for (x in 0 until img.width) {
            val q = img[x, y]; if ((q ushr 24) < 128) continue
            if (ox + x in 0 until scene.width && oy + y in 0 until scene.height) scene.setRGB(ox + x, oy + y, q)
        }
    }
    val hero = GameState.newGame("Mira", Race.HUMAN, CharClass.FIGHTER).hero
    place(folk.draw(folk.garrick, F.slot(F.yawOf(Facing.LEFT)), 0), 12, 9)
    place(F.draw(hero, F.slot(F.yawOf(Facing.RIGHT)), 1), 10, 9)
    ImageIO.write(scene, "png", File("build/screens/npc_garrick_feuer.png"))
    // all sixteen directions, three times enlarged, to check arms and the bow over the cloak
    val k = 3
    val all = BufferedImage(F.W * 8 * k, F.H * 2 * k, BufferedImage.TYPE_INT_RGB)
    for (s in 0 until 16) {
        val img = folk.draw(folk.garrick, s, 0)
        for (y in 0 until F.H * k) for (x in 0 until F.W * k) {
            val q = img[x / k, y / k]
            all.setRGB((s % 8) * F.W * k + x, (s / 8) * F.H * k + y, if ((q ushr 24) >= 128) q else 0x2E3628)
        }
    }
    ImageIO.write(all, "png", File("build/screens/npc_garrick_16.png"))
    println("wrote npc draft")
}

/** Draft (09.10.): Garrick's idle loops, warming his hands and peering into the woods. NPCIDLE=1 */
fun renderNpcIdle() {
    val folk = de.bornim.core.art.MapFolk
    val F = MapFigure
    val k = 3
    // NPCIDLE=rowena (D1.10): Rowena wiping her counter and pouring from a jug, as she faces in the inn and a little turned
    val rowena = System.getenv("NPCIDLE") == "rowena"
    val who = if (rowena) folk.rowena else folk.garrick
    val home = F.slot(F.yawOf(de.bornim.core.Facing.DOWN))
    val rows = if (rowena) listOf(
        Triple("Theke wischen (wie in der Schänke)", de.bornim.core.art.MapFolk.Idle.WIPE, home),
        Triple("einschenken (wie in der Schänke)", de.bornim.core.art.MapFolk.Idle.POUR, home),
        Triple("Theke wischen, schräg", de.bornim.core.art.MapFolk.Idle.WIPE, home + 2),
        Triple("einschenken, schräg", de.bornim.core.art.MapFolk.Idle.POUR, home + 2),
    ) else listOf(
        Triple("Hände wärmen, zum Feuer (links)", de.bornim.core.art.MapFolk.Idle.WARM, 12),
        Triple("Hände wärmen, schräg vorn", de.bornim.core.art.MapFolk.Idle.WARM, 14),
        Triple("in den Wald spähen, schräg vorn", de.bornim.core.art.MapFolk.Idle.PEER, 2),
        Triple("in den Wald spähen, von der Seite", de.bornim.core.art.MapFolk.Idle.PEER, 4),
        Triple("in den Wald spähen, von hinten", de.bornim.core.art.MapFolk.Idle.PEER, 8),
    )
    val lab = 26
    val out = BufferedImage(F.W * k * 5, (F.H * k + lab) * rows.size, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.color = Color(0x2E3628); g.fillRect(0, 0, out.width, out.height)
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.font = Font(Font.SANS_SERIF, Font.BOLD, 18); g.color = Color(0xE8DCC0)
    rows.forEachIndexed { r, (title, idle, slot) ->
        val y0 = r * (F.H * k + lab)
        g.drawString(title, 8, y0 + 20)
        for (i in 0 until idle.pictures) {
            val img = folk.drawIdle(who, slot, idle, i)
            for (y in 0 until F.H * k) for (x in 0 until F.W * k) {
                val q = img[x / k, y / k]; if ((q ushr 24) < 128) continue
                out.setRGB(i * F.W * k + x, y0 + lab + y, q)
            }
        }
    }
    g.dispose()
    ImageIO.write(out, "png", File(if (rowena) "build/screens/npc_rowena_arbeit.png" else "build/screens/npc_garrick_leerlauf.png"))
    println("wrote idle draft")
}

/** Draft (09.10.): the resting stances every figure gets, for Garrick and the hero, each breathing out and in. NPCREST=1 */
fun renderNpcRest() {
    val folk = de.bornim.core.art.MapFolk
    val F = MapFigure
    val hero = GameState.newGame("Mira", Race.HUMAN, CharClass.FIGHTER).hero
    val rests = if (System.getenv("SPEER55") != null) listOf(de.bornim.core.art.MapRest.Rest.NEUTRAL, de.bornim.core.art.MapRest.Rest.SPEAR)
        else de.bornim.core.art.MapRest.Rest.entries
    val k = 3
    val lab = 26
    // RUHE55=1 (55.1, draft): two of the village folk in lighter clothes, where the arms show better
    // SPEER55=1 (55.1b, draft): Jorin grounding his spear, from four sides
    val speer = System.getenv("SPEER55") != null
    val who = if (speer) listOf(folk.jorin) else if (System.getenv("RUHE55") != null) listOf(folk.gwenna, folk.bram) else listOf(folk.garrick)
    val rows = if (speer) listOf("Jorin von vorn" to 0, "Jorin schräg" to 2, "Jorin Seite" to 4, "Jorin hinten" to 8, "Jorin schräg vorn" to 14)
        else if (who.size > 1) listOf("Gwenna von vorn" to 0, "Gwenna schräg" to 2, "Bram von vorn" to 0, "Bram schräg" to 14)
        else listOf("Garrick von vorn" to 0, "Garrick schräg" to 2, "Held von vorn" to -1)
    val out = BufferedImage(F.W * k * rests.size, (F.H * k + lab) * rows.size * (if (speer) 1 else 2), BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.color = Color(0x2E3628); g.fillRect(0, 0, out.width, out.height)
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.font = Font(Font.SANS_SERIF, Font.BOLD, 18); g.color = Color(0xE8DCC0)
    var row = 0
    for ((title, slot) in rows) for (breath in 0..(if (speer) 0 else 1)) {
        val y0 = row * (F.H * k + lab)
        rests.forEachIndexed { i, rest ->
            if (slot < 0 && rest.handsFree) return@forEachIndexed
            g.drawString((if (i == 0) "$title, " + (if (breath == 1) "einatmen: " else "ausatmen: ") else "") + rest.name, i * F.W * k + 8, y0 + 20)
            val f = if (who.size > 1 && title.startsWith("Bram")) folk.bram else who.first()
            val img = if (slot < 0) F.drawRest(hero, 0, rest, breath) else folk.drawRest(f, slot, rest, breath)
            for (y in 0 until F.H * k) for (x in 0 until F.W * k) {
                val q = img[x / k, y / k]; if ((q ushr 24) < 128) continue
                out.setRGB(i * F.W * k + x, y0 + lab + y, q)
            }
        }
        row++
    }
    g.dispose()
    ImageIO.write(out, "png", File("build/screens/ruhe_entwurf" + (if (speer) "_speer" else "") + ".png"))
    println("wrote rest draft")
}

/** Draft (09.10.): Garrick warding off a beast with a brand from the fire. NPCTORCH=1 */
fun renderNpcTorch() {
    val folk = de.bornim.core.art.MapFolk
    val F = MapFigure
    val wards = de.bornim.core.art.MapFolk.Ward.entries
    val k = 3
    val lab = 26
    val rows = listOf("zum Feuer (links)" to 12, "schräg vorn" to 14, "von vorn" to 0, "von der Seite" to 4, "von hinten" to 8)
    val WW = de.bornim.core.art.MapFolk.WARD_W; val WH = de.bornim.core.art.MapFolk.WARD_H
    val out = BufferedImage(WW * k * (wards.size + 2), (WH * k + lab) * rows.size, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.color = Color(0x1E2418); g.fillRect(0, 0, out.width, out.height)
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.font = Font(Font.SANS_SERIF, Font.BOLD, 18); g.color = Color(0xE8DCC0)
    rows.forEachIndexed { r, (title, slot) ->
        val y0 = r * (WH * k + lab)
        val cells = wards.map { it to 0 } + listOf(de.bornim.core.art.MapFolk.Ward.LEFT to 1, de.bornim.core.art.MapFolk.Ward.LEFT to 2)
        cells.forEachIndexed { i, (w, fl) ->
            g.drawString((if (i == 0) "$title: " else "") + w.name + (if (fl > 0) " Flamme $fl" else ""), i * WW * k + 8, y0 + 20)
            val img = folk.drawWard(folk.garrick, slot, w, fl)
            for (y in 0 until WH * k) for (x in 0 until WW * k) {
                val q = img[x / k, y / k]; if ((q ushr 24) < 128) continue
                out.setRGB(i * WW * k + x, y0 + lab + y, q)
            }
        }
    }
    g.dispose()
    ImageIO.write(out, "png", File("build/screens/fackel_entwurf.png"))
    println("wrote torch draft")
}

/** Draft (night of 09.10.): the village folk as dolls, front, at a slant, side and back, beside the former figure. VILLAGEDRAFT=1 */
fun renderVillageDraft() {
    val folk = de.bornim.core.art.MapFolk
    val F = MapFigure
    val looks = mapOf("rowena" to "innkeeper", "aldric" to "elder", "thessa" to "merchant", "osric" to "priest", "lyra" to "lyra", "jorin" to "guard",
        "pim" to "child", "bram" to "farmer", "liska" to "maid", "gwenna" to "villager", "borin" to "dwarf", "morwen" to "herbalist")
    val names = mapOf("rowena" to "Wirtin Rowena", "aldric" to "Ältester Aldric", "thessa" to "Händlerin Thessa", "osric" to "Bruder Osric", "lyra" to "Schwester Lyra",
        "jorin" to "Wache Jorin", "pim" to "Pim", "bram" to "Bauer Bram", "liska" to "Magd Liska", "gwenna" to "Gwenna", "borin" to "Zwerg Borin", "morwen" to "Kräuterfrau Morwen")
    val k = 2; val lab = 24; val slots = listOf(0, 2, 4, 8)
    for ((part, group) in folk.drafts.chunked(6).withIndex()) {
        val cw = F.W * k; val ch = F.H * k + lab
        val out = BufferedImage(cw * (slots.size + 1), ch * group.size, BufferedImage.TYPE_INT_RGB)
        val g = out.createGraphics()
        g.color = Color(0x2A3024); g.fillRect(0, 0, out.width, out.height)
        g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
        g.font = Font(Font.SANS_SERIF, Font.BOLD, 15); g.color = Color(0xE8DCC0)
        group.forEachIndexed { r, f ->
            val y0 = r * ch
            g.drawString(names[f.id] ?: f.id, 6, y0 + 17)
            g.drawString("bisher", slots.size * cw + 6, y0 + 17)
            slots.forEachIndexed { i, s ->
                val img = folk.draw(f, s, 0)
                for (y in 0 until F.H * k) for (x in 0 until F.W * k) {
                    val q = img[x / k, y / k]; if ((q ushr 24) < 128) continue
                    out.setRGB(i * cw + x, y0 + lab + y, q)
                }
            }
            val old = CharacterArt.npc(looks[f.id] ?: "villager", Facing.DOWN)
            val ox = slots.size * cw + (cw - old.width * 2 * k / 2) / 2; val oy = y0 + lab + F.GROUND * k - old.height * k
            for (y in 0 until old.height * k) for (x in 0 until old.width * k) {
                val q = old[x / k, y / k]; if ((q ushr 24) < 128) continue
                if (ox + x < out.width) out.setRGB(ox + x, oy + y, q)
            }
        }
        g.dispose()
        ImageIO.write(out, "png", File("build/screens/dorfbewohner_${part + 1}.png"))
    }
    println("wrote village draft")
}

/** Draft (night of 09.10.): Garrick down at his fire, squatting, stirring the embers, dozing. SQUATDRAFT=1 */
fun renderSquatDraft() {
    val folk = de.bornim.core.art.MapFolk
    val F = MapFigure
    val poses = de.bornim.core.art.MapFolk.Squat.entries
    val rows = listOf("zum Feuer (links)" to 12, "schräg vorn" to 14, "von vorn" to 0, "von der Seite" to 4, "von hinten" to 8)
    val k = 3; val lab = 24
    val out = BufferedImage(F.W * k * poses.size, (F.H * k + lab) * rows.size, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.color = Color(0x2A3024); g.fillRect(0, 0, out.width, out.height)
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
    g.font = Font(Font.SANS_SERIF, Font.BOLD, 17); g.color = Color(0xE8DCC0)
    rows.forEachIndexed { r, (title, slot) ->
        val y0 = r * (F.H * k + lab)
        poses.forEachIndexed { i, p ->
            g.drawString((if (i == 0) "$title: " else "") + p.name, i * F.W * k + 6, y0 + 18)
            val img = folk.drawSquat(folk.garrick, slot, p)
            for (y in 0 until F.H * k) for (x in 0 until F.W * k) {
                val q = img[x / k, y / k]; if ((q ushr 24) < 128) continue
                out.setRGB(i * F.W * k + x, y0 + lab + y, q)
            }
        }
    }
    g.dispose()
    ImageIO.write(out, "png", File("build/screens/garrick_hocken.png"))
    println("wrote squat draft")
}

/** Draft (55.2): Borin sitting at the table, four things he does, in four directions (SITDRAFT=1). */
fun renderSitDraft() {
    val F = MapFigure
    val k = 2; val slots = listOf(0, 2, 4, 6)
    val cw = F.W * k; val ch = F.H * k
    val out = BufferedImage(cw * slots.size, ch * 4, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.color = Color(0x3A2C20); g.fillRect(0, 0, out.width, out.height)
    for (pose in 0 until 4) slots.forEachIndexed { i, sl ->
        val img = de.bornim.core.art.MapFolk.borinSits(sl, pose)
        for (y in 0 until F.H * k) for (x in 0 until F.W * k) {
            val q = img[x / k, y / k]; if ((q ushr 24) < 128) continue
            out.setRGB(i * cw + x, pose * ch + y, q)
        }
    }
    val dir = java.io.File("build/screens").apply { mkdirs() }
    javax.imageio.ImageIO.write(out, "png", java.io.File(dir, "sitzen_borin.png"))
    println("wrote sitzen_borin")
}

/** 55.1b (test of 0.1.670): Jorin grounding his spear, every turn by every step of the ease. SPEERSTUFEN=1 */
fun renderSpearSteps() {
    val F = MapFigure
    val jorin = de.bornim.core.art.MapFolk.jorin
    val k = 2
    val levels = 0..de.bornim.core.art.MapRest.LEVELS
    val out = BufferedImage(F.W * k * levels.count(), F.H * k * F.YAWS, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.color = Color(0x2E3628); g.fillRect(0, 0, out.width, out.height)
    g.font = Font(Font.SANS_SERIF, Font.BOLD, 16); g.color = Color(0xE8DCC0)
    for (slot in 0 until F.YAWS) for (lv in levels) {
        val img = de.bornim.core.art.MapFolk.drawRest(jorin, slot, de.bornim.core.art.MapRest.Rest.SPEAR, 0, lv)
        for (y in 0 until F.H * k) for (x in 0 until F.W * k) {
            val q = img[x / k, y / k]; if ((q ushr 24) < 128) continue
            out.setRGB(lv * F.W * k + x, slot * F.H * k + y, q)
        }
        g.drawString("$slot/$lv", lv * F.W * k + 4, slot * F.H * k + 16)
    }
    g.dispose()
    ImageIO.write(out, "png", File("build/screens/speer_stufen.png"))
    println("wrote spear steps")
}

/** 55.1b: where the grounded spear shows when Jorin is turned [SPEERRF] (slot): hand r across, f down. SPEERRF=2 */
fun renderSpearGrid(slot: Int) {
    val F = MapFigure
    val jorin = de.bornim.core.art.MapFolk.jorin
    val k = 2
    val rs = listOf(-10.0, -4.0, 4.0, 10.0, 19.0, 26.0); val fs = listOf(-10.0, -4.0, 3.0, 9.0, 15.0)
    val out = BufferedImage(F.W * k * rs.size, F.H * k * fs.size, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.color = Color(0x2E3628); g.fillRect(0, 0, out.width, out.height)
    g.font = Font(Font.SANS_SERIF, Font.BOLD, 16); g.color = Color(0xE8DCC0)
    val base = de.bornim.core.art.MapRest.rig(MapFigure.rig(slot * 360.0 / F.YAWS, 0, jorin.carry), de.bornim.core.art.MapRest.Rest.SPEAR, 0)
    for ((i, r) in rs.withIndex()) for ((j, f) in fs.withIndex()) {
        val img = F.render(jorin.doll, jorin.outfit, base.copy(rh = de.bornim.core.art.HeroFigure.V(r, base.rh.u, f), weapon = de.bornim.core.art.HeroFigure.V(0.0, 1.0, 0.04)))
        for (y in 0 until F.H * k) for (x in 0 until F.W * k) {
            val q = img[x / k, y / k]; if ((q ushr 24) < 128) continue
            out.setRGB(i * F.W * k + x, j * F.H * k + y, q)
        }
        g.drawString("r${r.toInt()} f${f.toInt()}", i * F.W * k + 4, j * F.H * k + 16)
    }
    g.dispose()
    ImageIO.write(out, "png", File("build/screens/speer_raster.png"))
    println("wrote spear grid")
}

/**
 * 134.2: everyone's gesture with the golden sign, one row each, every picture of it from the start (GESTEN=slot:
 * 0 facing the viewer, 14 half turned). Who: GESTENWER=aldric,pim …
 */
fun renderGestures(arg: String) {
    val folk = de.bornim.core.art.MapFolk
    val slot = arg.toIntOrNull()?.takeIf { it in 0 until MapFigure.YAWS } ?: 0
    val who = System.getenv("GESTENWER")?.split(",") ?: listOf("aldric", "rowena", "borin", "osric", "gwenna", "pim", "thessa", "jorin", "morwen", "lyra", "garrick", "liska", "bram")
    val rows = who.map { folk.of(it)!! }
    val cols = rows.maxOf { folk.gesturePoses(it).size }
    val w = folk.WARD_W; val h = folk.WARD_H; val lab = 18
    val out = BufferedImage(w * cols, (h + lab) * rows.size, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.color = Color(0x2E3628); g.fillRect(0, 0, out.width, out.height)
    g.font = Font(Font.SANS_SERIF, Font.BOLD, 13); g.color = Color(0xE8DCC0)
    rows.forEachIndexed { r, f ->
        val y0 = r * (h + lab)
        folk.gesturePoses(f).forEachIndexed { i, p ->
            g.drawString(if (i == 0) "${f.id}: ${folk.gesture(f)}" else "${p.from.name.take(2)}>${p.to.name.take(2)} ${p.k}", i * w + 4, y0 + 14)
            val img = folk.drawGesture(f, slot, p)
            for (y in 0 until h) for (x in 0 until w) {
                val q = img[x, y]; if ((q ushr 24) < 128) continue
                out.setRGB(i * w + x, y0 + lab + y, q)
            }
        }
    }
    g.dispose()
    File("build/screens").mkdirs()
    ImageIO.write(out, "png", File("build/screens/gesten_$slot.png"))
    println("wrote gesten_$slot")
}
