package preview

import de.bornim.core.art.Beast
import de.bornim.core.art.WolfArt
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** Drafts of the new four-legged foes: each coat in a few poses and views, large enough to judge. */
fun renderBeastDrafts() {
    val boarCoats = listOf(
        "dunkel" to WolfArt.Coat(0x3A302A, 0x141010, 0x2E2622, 0xD82A18),
        "grau, Narben" to WolfArt.Coat(0x5E5248, 0x221C18, 0x4A3E36, 0xE84A1A, scar = true),
        "rostig, Ohr" to WolfArt.Coat(0x5A3A26, 0x1E1410, 0x463024, 0xC81E14, scar = true, tornEar = true))
    val ratCoats = listOf(
        "braun" to WolfArt.Coat(0x4A3C34, 0x2A201C, 0x6A5C50, 0xE01E14),
        "grau, Räude" to WolfArt.Coat(0x55504C, 0x2A2826, 0x7A726A, 0xF03A20, scar = true),
        "schwarz, Ohr" to WolfArt.Coat(0x2A2624, 0x121010, 0x4A4240, 0xF04A28, tornEar = true))
    val poses = listOf(
        "Wache" to Beast.Rig(neck = -6.0, nod = 4.0, snarl = 0.6, mouth = 0.1, ears = -0.3),
        "wütend" to Beast.Rig(neck = -12.0, nod = 10.0, snarl = 1.0, mouth = 0.7, ears = -1.0, crouch = 3.0),
        "seitlich" to Beast.Rig(neck = -6.0, nod = 4.0, snarl = 0.6, mouth = 0.35, ears = -0.3, yaw = -90.0),
        "von vorn" to Beast.Rig(neck = -6.0, nod = 4.0, snarl = 0.8, mouth = 0.5, ears = -0.3, yaw = -25.0))
    for ((kind, coats, px) in listOf(Triple(Beast.Kind.BOAR, boarCoats, 1.5), Triple(Beast.Kind.RAT, ratCoats, 3.4))) {
        val cw = 330; val ch = 250
        val out = BufferedImage(cw * poses.size, ch * coats.size, BufferedImage.TYPE_INT_RGB)
        val g = out.createGraphics(); g.color = java.awt.Color(0x3A3E36); g.fillRect(0, 0, out.width, out.height)
        for ((ri, cc) in coats.withIndex()) for ((ci, pp) in poses.withIndex()) {
            val im = Beast(1.0, cc.second, kind).render(cw, ch, cw / 2.0 + (if (kind == Beast.Kind.RAT) 75 else 20), ch - 16.0, px * (if (kind == Beast.Kind.RAT) 0.85 else 1.0), pp.second)
            for (y in 0 until ch) for (x in 0 until cw) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(ci * cw + x, ri * ch + y, q and 0xFFFFFF) }
            g.color = java.awt.Color(0xF0E8D8); g.drawString("${cc.first} – ${pp.first}", ci * cw + 4, ri * ch + 14)
        }
        ImageIO.write(out, "png", File("build/screens/entwurf_${kind.name.lowercase()}.png"))
        println("wrote draft $kind")
    }
}

/** Drafts of the goblin shaman (a goblin in its trappings, three kits) and the ghoul (three looks), whole and the head close. */
fun renderShamanGhoulDrafts() {
    val D = de.bornim.core.art.Doll
    val W = 150; val H = 230; val sc = 2
    val HW = 110; val HH = 110
    fun gear(slot: de.bornim.core.GearSlot, base: String) = slot to de.bornim.core.Gear(0, base, de.bornim.core.Rarity.COMMON, 1)
    val shamanKits = listOf(
        de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(gear(de.bornim.core.GearSlot.CHEST, "robe"), gear(de.bornim.core.GearSlot.MAIN_HAND, "staff")), rusty = true, crude = true, fetish = true),
        de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(gear(de.bornim.core.GearSlot.MAIN_HAND, "staff")), rusty = true, crude = true, pelt = true, fetish = true),
        de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(gear(de.bornim.core.GearSlot.CHEST, "robe"), gear(de.bornim.core.GearSlot.MAIN_HAND, "staff")), rusty = true, crude = true, pelt = true, fetish = true))
    val ghoulKits = listOf(
        null,
        de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(gear(de.bornim.core.GearSlot.CHEST, "leather")), rusty = true, crude = true),
        de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(gear(de.bornim.core.GearSlot.CHEST, "robe")), rusty = true, crude = true))
    for ((name, kind, kits) in listOf(Triple("schamane", de.bornim.core.art.Doll.Creature.GOBLIN, shamanKits), Triple("ghul", de.bornim.core.art.Doll.Creature.GHOUL, ghoulKits))) {
        val img = BufferedImage((W * 3 + HW * 3) * sc, H * sc, BufferedImage.TYPE_INT_ARGB)
        val g = img.createGraphics(); g.color = java.awt.Color(0x3A4436); g.fillRect(0, 0, img.width, img.height)
        for (v in 0 until 3) {
            val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.entries[v], v, v, kind, 0.95 + 0.05 * v)
            val base = de.bornim.core.art.HeroFigure.STAND.copy(lean = 0.4, crouch = 4.0, rh = de.bornim.core.art.HeroFigure.V(18.0, 55.0, 4.0), lh = de.bornim.core.art.HeroFigure.V(-18.0, 55.0, 4.0))
            val rest = base.copy(yaw = listOf(20.0, 340.0, 200.0)[v])
            val px = (H - 20) / (doll.height * 1.08)
            val p = doll.render(W, H, W / 2.0, H - 10.0, px, rest, kits[v]).img
            for (y in 0 until H) for (x in 0 until W) { val q = p[x, y]; if ((q ushr 24) < 128) continue
                g.color = java.awt.Color(q, true); g.fillRect(v * W * sc + x * sc, y * sc, sc, sc) }
            val hp = 85.0 / doll.hh
            val h2 = doll.render(HW, HH, HW / 2.0, HH / 2.0 + (doll.height - doll.hh * 0.5) * 0.966 * hp, hp, base.copy(lean = 0.0, crouch = 0.0, yaw = listOf(25.0, 0.0, 330.0)[v]), kits[v]).img
            for (y in 0 until HH) for (x in 0 until HW) { val q = h2[x, y]; if ((q ushr 24) < 128) continue
                g.color = java.awt.Color(q, true); g.fillRect((3 * W + v * HW) * sc + x * sc, 20 * sc + y * sc, sc, sc) }
        }
        ImageIO.write(img, "png", File("build/screens/entwurf_$name.png"))
    }
    println("wrote shaman ghoul drafts")
}

/** The proposed new sounds next to the ones in the game now, as WAV files: alt_NAME_n.wav and neu_NAME_n.wav. */
fun writeSoundProposals() {
    val dir = File("build/screens/klangproben").apply { deleteRecursively(); mkdirs() }
    fun wav(pcm: ShortArray, f: File) {
        val bytes = java.nio.ByteBuffer.allocate(pcm.size * 2).order(java.nio.ByteOrder.LITTLE_ENDIAN).also { b -> pcm.forEach { b.putShort(it) } }.array()
        val fmt = javax.sound.sampled.AudioFormat(de.bornim.core.audio.Synth.SAMPLE_RATE.toFloat(), 16, 1, true, false)
        javax.sound.sampled.AudioSystem.write(javax.sound.sampled.AudioInputStream(java.io.ByteArrayInputStream(bytes), fmt, pcm.size.toLong()),
            javax.sound.sampled.AudioFileFormat.Type.WAVE, f)
    }
    for (s in de.bornim.core.audio.Sfx.PROPOSED) {
        val n = s.name.lowercase()
        for (v in 0 until de.bornim.core.audio.Sfx.variants(s)) wav(de.bornim.core.audio.Sfx.render(s, v), File(dir, "alt_${n}_${v + 1}.wav"))
        for (v in 0..2) wav(de.bornim.core.audio.Sfx.proposal(s, v), File(dir, "neu_${n}_${v + 1}.wav"))
    }
    println("wrote sound proposals")
}

/** Drafts of drinking a draught in battle: three ways, for a few heroes, as seen in battle and turned towards us. */
fun renderDrinkDrafts() {
    val B = de.bornim.core.art.HeroBattle
    val heroes = listOf(
        Triple(de.bornim.core.CharClass.FIGHTER, de.bornim.core.Race.HUMAN, 0x9A1C1C),
        Triple(de.bornim.core.CharClass.CLERIC, de.bornim.core.Race.DWARF, 0x5A8A2A),
        Triple(de.bornim.core.CharClass.WIZARD, de.bornim.core.Race.ELF, 0x9A1C1C))
    val cols = 8; val cw = 150; val ch = 190
    val rows = heroes.size * 3 * 2
    val img = BufferedImage(cw * cols, ch * rows, BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics(); g.color = java.awt.Color(0x3A4436); g.fillRect(0, 0, img.width, img.height)
    var row = 0
    for ((cls, race, rgb) in heroes) {
        val hero = de.bornim.core.GameState.newGame("Alrik", race, cls).hero
        val base = B.outfit(hero)
        val outfit = de.bornim.core.art.Outfit(base.cls, base.items, bothHands = base.bothHands, flaskRgb = rgb)
        val doll = B.doll(hero)
        val st = de.bornim.core.art.HeroFigure.stance(hero)
        for (v in 0..2) {
            val seq = de.bornim.core.art.HeroFigure.drink(st, v)
            for (view in 0..1) {
                for (c in 0 until cols) {
                    val i = c * (seq.size - 1) / (cols - 1)
                    val rig = if (view == 0) seq[i] else seq[i].copy(yaw = seq[i].yaw + 150.0)
                    val p = doll.render(cw, ch, cw / 2.0, ch - 12.0, 1.0, rig, outfit).img
                    for (y in 0 until ch) for (x in 0 until cw) { val q = p[x, y]; if ((q ushr 24) >= 128) img.setRGB(c * cw + x, row * ch + y, q and 0xFFFFFF) }
                }
                g.color = java.awt.Color(0xF0E8D8); g.drawString("${cls.name.lowercase()} – Variante ${v + 1} – ${if (view == 0) "im Kampf" else "von vorn"}", 4, row * ch + 14)
                row++
            }
        }
    }
    ImageIO.write(img, "png", File("build/screens/entwurf_trinken.png"))
    println("wrote drink drafts")
}

/** Drafts of the hero struck down: three falls for a few heroes, in the battle frame (its edge drawn) to see what is cut off. */
fun renderHeroFallDrafts() {
    val B = de.bornim.core.art.HeroBattle
    val heroes = listOf(de.bornim.core.CharClass.FIGHTER to de.bornim.core.Race.HUMAN, de.bornim.core.CharClass.CLERIC to de.bornim.core.Race.DWARF,
        de.bornim.core.CharClass.WIZARD to de.bornim.core.Race.ELF, de.bornim.core.CharClass.ROGUE to de.bornim.core.Race.HALFLING)
    val cols = 7
    val fw = B.W_FALL; val fh = B.H
    val img = BufferedImage(fw * cols, fh * heroes.size * 3, BufferedImage.TYPE_INT_RGB)
    val g = img.createGraphics(); g.color = java.awt.Color(0x3A4436); g.fillRect(0, 0, img.width, img.height)
    var row = 0
    for ((cls, race) in heroes) {
        val hero = de.bornim.core.GameState.newGame("Alrik", race, cls).hero
        for (v in 0..2) {
            val n = B.frameCount(hero, de.bornim.core.art.HeroFigure.Act.DIE, de.bornim.core.art.HeroFigure.Strike.SLASH, v)
            for (c in 0 until cols) {
                val i = c * (n - 1) / (cols - 1)
                val im = B.frame(hero, de.bornim.core.art.HeroFigure.Act.DIE, de.bornim.core.art.HeroFigure.Strike.SLASH, v, i)
                for (y in 0 until im.height) for (x in 0 until im.width) { val q = im[x, y]; if ((q ushr 24) >= 128) img.setRGB(c * fw + x, row * fh + y, q and 0xFFFFFF) }
                g.color = java.awt.Color(0x6A5040); g.drawRect(c * fw, row * fh, fw - 1, fh - 1)
            }
            g.color = java.awt.Color(0xF0E8D8); g.drawString("${cls.name.lowercase()} – Sturz ${v + 1}", 4, row * fh + 14)
            row++
        }
    }
    ImageIO.write(img, "png", File("build/screens/entwurf_heldensturz.png"))
    println("wrote hero falls")
}

/**
 * The goblin shaman reworked (SHAMANDRAFT=1): in each of its three kits, as it stands in battle, gathering a curse at
 * the staff's skull, and thrusting the curse out of its free hand; below, the painted faces close.
 */
fun renderShamanDraft() {
    val W = 170; val H = 200; val sc = 3
    fun gear(slot: de.bornim.core.GearSlot, base: String) = slot to de.bornim.core.Gear(0, base, de.bornim.core.Rarity.COMMON, 1)
    val kits = listOf(
        de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(gear(de.bornim.core.GearSlot.CHEST, "robe"), gear(de.bornim.core.GearSlot.MAIN_HAND, "staff")), rusty = true, crude = true, fetish = true),
        de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(gear(de.bornim.core.GearSlot.MAIN_HAND, "staff")), rusty = true, crude = true, pelt = true, fetish = true),
        de.bornim.core.art.Outfit(de.bornim.core.CharClass.FIGHTER, mapOf(gear(de.bornim.core.GearSlot.CHEST, "robe"), gear(de.bornim.core.GearSlot.MAIN_HAND, "staff")), rusty = true, crude = true, pelt = true, fetish = true))
    // as the battle shows a goblin: stooped, knees bent, turned to face the hero on the left
    fun goblin(r: de.bornim.core.art.HeroFigure.Rig) = r.copy(lean = r.lean + 0.35, crouch = r.crouch + 4.0, headDown = r.headDown - 2.5, yaw = r.yaw - 180.0)
    val rest = de.bornim.core.art.HeroFigure.STAFF_REST.copy(lh = de.bornim.core.art.HeroFigure.V(-24.0, 70.0, 24.0), glow = 0.35, freeHand = 1.0)
    val gather = de.bornim.core.art.HeroFigure.STAFF_GATHER.copy(lh = de.bornim.core.art.HeroFigure.V(-28.0, 84.0, 30.0))
    val curse = de.bornim.core.art.HeroFigure.STAFF_REST.copy(rh = de.bornim.core.art.HeroFigure.V(19.0, 66.0, 6.0), lh = de.bornim.core.art.HeroFigure.V(-12.0, 86.0, 44.0), glow = 1.0, glowAt = 1.0, freeHand = 1.0, lean = 0.3, stride = 6.0)
    val poses = listOf(rest, gather, curse).map(::goblin)
    val img = BufferedImage(W * 3 * sc, (H * 3 + 110) * sc, BufferedImage.TYPE_INT_ARGB)
    val g = img.createGraphics(); g.color = java.awt.Color(0x2E3530); g.fillRect(0, 0, img.width, img.height)
    for (v in 0 until 3) {
        val doll = de.bornim.core.art.Doll(de.bornim.core.Race.HUMAN, de.bornim.core.Sex.MALE, de.bornim.core.Build.entries[v], v, v, de.bornim.core.art.Doll.Creature.GOBLIN, 1.0 + 0.05 * v)
        val px = 1.25
        for ((row, rig) in poses.withIndex()) {
            val p = doll.render(W, H, W / 2.0 + 15, H - 12.0, px, rig, kits[v]).img
            for (y in 0 until H) for (x in 0 until W) { val q = p[x, y]; if ((q ushr 24) < 128) continue
                g.color = java.awt.Color(q, true); g.fillRect((v * W + x) * sc, (row * H + y) * sc, sc, sc) }
        }
        val hp = 85.0 / doll.hh
        val HW = 110; val HH = 110
        val h2 = doll.render(HW, HH, HW / 2.0, HH / 2.0 + (doll.height - doll.hh * 0.5) * 0.966 * hp, hp, de.bornim.core.art.HeroFigure.STAFF_REST.copy(yaw = listOf(-20.0, 0.0, 20.0)[v]), kits[v]).img
        for (y in 0 until HH) for (x in 0 until HW) { val q = h2[x, y]; if ((q ushr 24) < 128) continue
            g.color = java.awt.Color(q, true); g.fillRect((v * W + 30 + x) * sc, (3 * H + y) * sc, sc, sc) }
    }
    ImageIO.write(img, "png", File("build/screens/entwurf_schamane2.png"))
    println("wrote shaman draft")
}
