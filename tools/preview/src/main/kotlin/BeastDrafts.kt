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
