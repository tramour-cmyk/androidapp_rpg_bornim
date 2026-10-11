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

/**
 * The proposed new sounds next to the ones in the game now, as WAV files: alt_NAME_n.wav and neu_NAME_n.wav.
 * env KLANGPROBEN=1 for all, =2 for the second round only, =MONSTER for the creatures' voices, or a list of names (KLANGPROBEN=OWL,DRIP).
 */
fun writeSoundProposals(which: String = "1") {
    val dir = File("build/screens/klangproben").apply { deleteRecursively(); mkdirs() }
    fun wav(pcm: ShortArray, f: File) {
        val bytes = java.nio.ByteBuffer.allocate(pcm.size * 2).order(java.nio.ByteOrder.LITTLE_ENDIAN).also { b -> pcm.forEach { b.putShort(it) } }.array()
        val fmt = javax.sound.sampled.AudioFormat(de.bornim.core.audio.Synth.SAMPLE_RATE.toFloat(), 16, 1, true, false)
        javax.sound.sampled.AudioSystem.write(javax.sound.sampled.AudioInputStream(java.io.ByteArrayInputStream(bytes), fmt, pcm.size.toLong()),
            javax.sound.sampled.AudioFileFormat.Type.WAVE, f)
    }
    val all = de.bornim.core.audio.Sfx.PROPOSED + de.bornim.core.audio.Sfx.PROPOSED_2
    val sounds = when (which) {
        "1" -> all
        "2" -> de.bornim.core.audio.Sfx.PROPOSED_2
        "MONSTER", "monster" -> emptyList()
        else -> which.split(",").map { de.bornim.core.audio.Sound.valueOf(it.trim().uppercase()) }
    }
    for (s in sounds) {
        val n = s.name.lowercase()
        for (v in 0 until de.bornim.core.audio.Sfx.variants(s)) wav(de.bornim.core.audio.Sfx.render(s, v), File(dir, "alt_${n}_${v + 1}.wav"))
        for (v in 0..2) wav(de.bornim.core.audio.Sfx.proposal(s, v), File(dir, "neu_${n}_${v + 1}.wav"))
    }
    if (which == "1" || which.uppercase() == "MONSTER") for (id in de.bornim.core.audio.Sfx.MONSTER_PROPOSED) for (cue in de.bornim.core.audio.Sfx.MONSTER_CUES)
        for (v in 0..2) wav(de.bornim.core.audio.Sfx.monsterProposal(id, cue, v), File(dir, "monster_${id}_${cue}_${v + 1}.wav"))
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

/** Drafts of the vermin (VERMINDRAFT=1 or a kind): each kind in its three looks, as it threatens and from the side. */
fun renderVerminDrafts() {
    val arg = System.getenv("VERMINDRAFT")
    val kinds = de.bornim.core.art.Vermin.Kind.entries.filter { arg == "1" || it.name.equals(arg, true) }
    for (kind in kinds) {
        val (px, groundK) = when (kind) {
            de.bornim.core.art.Vermin.Kind.SPIDER -> 1.0 to 0.9
            de.bornim.core.art.Vermin.Kind.CENTIPEDE -> 1.7 to 0.8
            de.bornim.core.art.Vermin.Kind.BAT -> 0.95 to 0.95
            de.bornim.core.art.Vermin.Kind.STIRGE -> 2.6 to 0.95
            de.bornim.core.art.Vermin.Kind.JELLY -> 1.5 to 0.85
        }
        val threat = when (kind) {
            de.bornim.core.art.Vermin.Kind.SPIDER -> de.bornim.core.art.Vermin.Rig(rear = 30.0, jaw = 0.8)
            de.bornim.core.art.Vermin.Kind.CENTIPEDE -> de.bornim.core.art.Vermin.Rig(rear = 25.0, jaw = 0.9)
            de.bornim.core.art.Vermin.Kind.JELLY -> de.bornim.core.art.Vermin.Rig(rear = 10.0, surge = 0.3)
            else -> de.bornim.core.art.Vermin.Rig(jaw = 0.9, spread = 1.0, beat = -0.3)
        }
        val poses = listOf("droht" to threat, "seitlich" to threat.copy(yaw = -95.0), "von vorn" to threat.copy(yaw = -20.0))
        val cw = 380; val ch = 300
        val out = BufferedImage(cw * poses.size, ch * 3, BufferedImage.TYPE_INT_RGB)
        val g = out.createGraphics(); g.color = java.awt.Color(0x2E3530); g.fillRect(0, 0, out.width, out.height)
        for (v in 0..2) for ((ci, pp) in poses.withIndex()) {
            val im = de.bornim.core.art.Vermin(kind, v).render(cw, ch, cw / 2.0, ch * groundK, px, pp.second)
            for (y in 0 until ch) for (x in 0 until cw) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(ci * cw + x, v * ch + y, q and 0xFFFFFF) }
            g.color = java.awt.Color(0xF0E8D8); g.drawString("Variante ${v + 1} – ${pp.first}", ci * cw + 4, v * ch + 14)
        }
        ImageIO.write(out, "png", File("build/screens/entwurf_${kind.name.lowercase()}.png"))
        println("wrote draft $kind")
    }
}

/** One sheet of all the vermin (VERMINSHEET=1): a row per kind, its three looks side by side as it threatens. */
fun renderVerminSheet() {
    val cw = 360; val ch = 270
    val kinds = de.bornim.core.art.Vermin.Kind.entries
    val out = BufferedImage(cw * 3, ch * kinds.size, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x262B28); g.fillRect(0, 0, out.width, out.height)
    val names = mapOf("SPIDER" to "Riesenspinne", "CENTIPEDE" to "Riesenhundertfüßer", "BAT" to "Riesenfledermaus", "STIRGE" to "Stirge", "JELLY" to "Ockergallerte")
    for ((ri, kind) in kinds.withIndex()) {
        val (px, groundK, rig) = when (kind) {
            de.bornim.core.art.Vermin.Kind.SPIDER -> Triple(1.15, 0.92, de.bornim.core.art.Vermin.Rig(rear = 30.0, jaw = 0.8, yaw = -50.0))
            de.bornim.core.art.Vermin.Kind.CENTIPEDE -> Triple(1.9, 0.8, de.bornim.core.art.Vermin.Rig(rear = 28.0, jaw = 0.9, yaw = -50.0))
            de.bornim.core.art.Vermin.Kind.BAT -> Triple(1.1, 1.05, de.bornim.core.art.Vermin.Rig(jaw = 0.9, spread = 1.0, beat = -0.3, yaw = -35.0))
            de.bornim.core.art.Vermin.Kind.STIRGE -> Triple(2.6, 0.98, de.bornim.core.art.Vermin.Rig(jaw = 0.9, spread = 1.0, beat = -0.3, yaw = -40.0))
            de.bornim.core.art.Vermin.Kind.JELLY -> Triple(1.35, 0.86, de.bornim.core.art.Vermin.Rig(rear = 10.0, surge = 0.3, yaw = -45.0))
        }
        for (v in 0..2) {
            val im = de.bornim.core.art.Vermin(kind, v).render(cw, ch, cw / 2.0 + 20, ch * groundK, px, rig)
            for (y in 0 until ch) for (x in 0 until cw) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(v * cw + x, ri * ch + y, q and 0xFFFFFF) }
            g.color = java.awt.Color(0xF0E8D8); g.drawString("${names[kind.name]} – Variante ${v + 1}", v * cw + 6, ri * ch + 16)
        }
    }
    ImageIO.write(out, "png", File("build/screens/tiere_uebersicht.png"))
    println("wrote vermin sheet")
}

/** One vermin close (VERMINCLOSE=bat): its three looks at three times the size, to judge the face. */
fun renderVerminClose() {
    val kind = de.bornim.core.art.Vermin.Kind.valueOf(System.getenv("VERMINCLOSE").uppercase())
    val cw = 420; val ch = 380
    val out = BufferedImage(cw * 3, ch, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x262B28); g.fillRect(0, 0, out.width, out.height)
    val (px, ground) = when (kind) {
        de.bornim.core.art.Vermin.Kind.BAT -> 3.2 to 640.0
        de.bornim.core.art.Vermin.Kind.STIRGE -> 5.0 to 560.0
        de.bornim.core.art.Vermin.Kind.CENTIPEDE -> 4.0 to 560.0
        else -> 2.0 to 360.0
    }
    for (v in 0..2) {
        val im = de.bornim.core.art.Vermin(kind, v).render(cw, ch, cw / 2.0, ground, px, de.bornim.core.art.Vermin.Rig(jaw = 0.9, rear = 28.0, beat = -0.3, yaw = -30.0))
        for (y in 0 until ch) for (x in 0 until cw) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(v * cw + x, y, q and 0xFFFFFF) }
    }
    ImageIO.write(out, "png", File("build/screens/nah_${kind.name.lowercase()}.png"))
    println("wrote close $kind")
}

/** VERMINANIM=giant_spider:0,stirge:2: every act of a vermin in battle, eight frames each, the strike framed red. */
fun renderVerminAnim() {
    val M = de.bornim.core.art.MonsterArt
    val acts = listOf(de.bornim.core.art.Act.IDLE to 0) + listOf(de.bornim.core.art.Act.ATTACK, de.bornim.core.art.Act.HURT, de.bornim.core.art.Act.DODGE, de.bornim.core.art.Act.DIE).flatMap { a -> (0..2).map { a to it } }
    val cw = 280; val chh = 200; val cols = 8
    for (case in System.getenv("VERMINANIM").split(",")) {
        val id = case.substringBefore(":"); val look = de.bornim.core.MonsterLook(case.substringAfter(":").toInt())
        val out = BufferedImage(cw * cols, chh * acts.size, BufferedImage.TYPE_INT_RGB)
        val g = out.createGraphics(); g.color = java.awt.Color(0x3C3A36); g.fillRect(0, 0, out.width, out.height)
        for ((r, av) in acts.withIndex()) {
            val (act, v) = av
            val n = M.frameCount(id, look, act, v)
            val strike = if (act == de.bornim.core.art.Act.ATTACK) M.strikeFrame(id, look, v) else -1
            val picks = if (n <= cols) (0 until n).toList() else (0 until cols).map { it * (n - 1) / (cols - 1) }.toMutableList().also { l -> if (strike >= 0 && strike !in l) l[l.indexOfFirst { it > strike }.coerceAtLeast(0)] = strike }
            for ((c, i) in picks.withIndex()) {
                val im = M.battleFrame(id, look, act, v, i)
                for (y in 0 until minOf(chh, im.height)) for (x in 0 until minOf(cw, im.width)) { val q = im[x, y]; if ((q ushr 24) >= 128) out.setRGB(c * cw + x, r * chh + y, q and 0xFFFFFF) }
                g.color = java.awt.Color(0x6A6A60); g.drawLine(c * cw, r * chh + M.groundLine(id).toInt(), (c + 1) * cw, r * chh + M.groundLine(id).toInt())
                if (i == strike) { g.color = java.awt.Color(0xC04030); g.drawRect(c * cw, r * chh, cw - 1, chh - 1) }
            }
            g.color = java.awt.Color(0xE0D8C0); g.drawString("$act/$v", 2, r * chh + 12)
        }
        ImageIO.write(out, "png", File("build/screens/vermin_${id}_${look.seed}.png"))
        println("wrote vermin anim $id")
    }
}

/** JELLYWOUND=1: the ochre jelly healthy, below half and below a quarter, with its wound stains, in the forest light. */
fun renderJellyWounds() {
    val M = de.bornim.core.art.MonsterArt
    val look = de.bornim.core.MonsterLook(1)
    val cw = 280; val chh = 200
    val out = BufferedImage(cw * 3, chh, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics(); g.color = java.awt.Color(0x4E6A38); g.fillRect(0, 0, out.width, out.height)
    for (w in 0..2) {
        val base = M.battleFrame("ochre_jelly", look, de.bornim.core.art.Act.IDLE, 0, 0, w)
        val im = if (w == 0) base else de.bornim.core.art.Glow.wounds(base, w, 0x241606, look.seed, cracks = false)
        for (y in 0 until minOf(chh, base.height)) for (x in 0 until minOf(cw, base.width)) {
            val q0 = base[x, y]; val q1 = im[x, y]
            val q = if ((q1 ushr 24) >= 128) q1 else q0
            if ((q ushr 24) >= 128) out.setRGB(w * cw + x, y, q and 0xFFFFFF)
        }
        g.color = java.awt.Color(0xF0E8D8); g.drawString(listOf("gesund", "unter halben TP", "unter einem Viertel")[w], w * cw + 6, 14)
    }
    ImageIO.write(out, "png", File("build/screens/gallerte_wunden.png"))
    println("wrote jelly wounds")
}
