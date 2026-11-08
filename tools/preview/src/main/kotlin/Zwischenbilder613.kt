package preview

import java.awt.Color
import java.awt.RenderingHints
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * 613 / 302.3 (Chef 08.11., 15:08; 23.10., 10:45): every picture of the intro and the temple scene drawn again with the line of
 * ink in the painter (`DESIGN-STIL.md` Signatur 2), a little heavier than intro picture 4 of c8cc89dd. `ZWISCHEN613=app` writes
 * them as the app's assets (`app/src/main/assets/intro`, `…/tempel` with `leben.txt`; Godot takes them from there, godot.yml)
 * and, for the look, each picture before and after side by side in `build/screens/zwischen613_<n>.png`, a contact sheet of all
 * inked pictures, and how far each plain picture is from the asset it replaces (so nothing but the line has changed).
 */
fun renderZwischen613() {
    val out = File("build/screens").apply { mkdirs() }
    val intro = File("../../app/src/main/assets/intro")
    val report = StringBuilder()
    val inked = ArrayList<Pair<String, BufferedImage>>()

    fun keep(name: String, plain: BufferedImage, ink: BufferedImage, asset: File?) {
        ImageIO.write(sideBySide(plain, ink), "png", File(out, "zwischen613_$name.png"))
        inked += name to ink
        if (asset != null && asset.exists()) report.append("$name: Abstand ohne Linie zum alten Bild ${"%.2f".format(java.util.Locale.ROOT, meanDiff(plain, ImageIO.read(asset)))} (0..255)\n")
        report.append("$name: Anteil Tusche ${"%.1f".format(java.util.Locale.ROOT, 100 * inkShare(plain, ink))} % der Bildfläche\n")
    }

    // intro 1, 2, 4: one picture each
    for ((n, make) in listOf<Pair<Int, () -> BridgePainter>>(1 to { RoadPainter() }, 2 to { BridgePainter(detail = true) }, 4 to { InnPainter() })) {
        val plain = make().paint()
        val ink = make().apply { tusche = true; litMap = lightMap(plain) }.paint()
        keep("intro_$n", plain, ink, File(intro, "intro_$n.jpg"))
        writeJpeg613(ink, File(intro, "intro_$n.jpg"))
    }
    // intro 3: the picture under the life, the bearers' sheet, the temple in front; light as in the picture under the life
    run {
        val plainBase = SquarePainter().apply { part = SquarePainter.Part.BASE }.paint()
        val light = lightMap(plainBase)
        val base = SquarePainter().apply { part = SquarePainter.Part.BASE; tusche = true; litMap = light }.paint()
        keep("intro_3", plainBase, base, File(intro, "intro_3.jpg"))
        writeJpeg613(base, File(intro, "intro_3.jpg"))
        // the sheet holds the bearers at their slots, not where they walk: no light map there, the whole sheet counts as dark
        ImageIO.write(SquarePainter().apply { part = SquarePainter.Part.GROUP; tusche = true }.paint(), "png", File(intro, "intro_3_zug.png"))
        ImageIO.write(SquarePainter().apply { part = SquarePainter.Part.FRONT; tusche = true; litMap = light }.paint(), "png", File(intro, "intro_3_vorn.png"))
        // the whole square as one picture with the bearers where they are 1.5 s into it, for the look
        val plainAll = SquarePainter().paint()
        keep("intro_3_zug", plainAll, SquarePainter().apply { tusche = true; litMap = lightMap(plainAll) }.paint(), null)
    }
    // the temple scene: five pictures and where their candles and the sun shaft lie (TempleProbe `TEMPEL68=app`)
    for ((n, plain, ink) in writeTempleAssets(ink = true)) keep("tempel_$n", plain, ink, null)

    // a contact sheet of all inked pictures, three in a row
    val cols = 3; val tw = 360; val th = 400
    val rows = (inked.size + cols - 1) / cols
    val sheet = BufferedImage(cols * tw, rows * th, BufferedImage.TYPE_INT_RGB)
    sheet.createGraphics().apply {
        setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC)
        color = Color.BLACK; fillRect(0, 0, sheet.width, sheet.height)
        for ((i, p) in inked.withIndex()) drawImage(p.second, (i % cols) * tw, (i / cols) * th, tw, th, null)
    }
    ImageIO.write(sheet, "png", File(out, "zwischen613_alle.png"))
    File(out, "zwischen613.txt").writeText(report.toString())
    print(report)
    println("wrote build/screens/zwischen613_*.png, app/src/main/assets/intro, app/src/main/assets/tempel")
}

/** [a] (left, before) and [b] (right, after) side by side with a thin black gap. */
private fun sideBySide(a: BufferedImage, b: BufferedImage): BufferedImage {
    val out = BufferedImage(a.width + 12 + b.width, maxOf(a.height, b.height), BufferedImage.TYPE_INT_RGB)
    out.createGraphics().apply { color = Color.BLACK; fillRect(0, 0, out.width, out.height); drawImage(a, 0, 0, null); drawImage(b, a.width + 12, 0, null) }
    return out
}

/** The mean difference per channel between two pictures of the same size (0 = the same). */
private fun meanDiff(a: BufferedImage, b: BufferedImage): Double {
    if (a.width != b.width || a.height != b.height) return 255.0
    var s = 0L
    for (y in 0 until a.height) for (x in 0 until a.width) {
        val p = a.getRGB(x, y); val q = b.getRGB(x, y)
        s += Math.abs(((p shr 16) and 0xFF) - ((q shr 16) and 0xFF)) + Math.abs(((p shr 8) and 0xFF) - ((q shr 8) and 0xFF)) + Math.abs((p and 0xFF) - (q and 0xFF))
    }
    return s / (3.0 * a.width * a.height)
}

/** How much of the picture the line darkened (a pixel counts when it got darker by more than 24 of 255). */
private fun inkShare(plain: BufferedImage, ink: BufferedImage): Double {
    var n = 0
    for (y in 0 until plain.height) for (x in 0 until plain.width) {
        val p = plain.getRGB(x, y); val q = ink.getRGB(x, y)
        val lp = ((p shr 16) and 0xFF) + ((p shr 8) and 0xFF) + (p and 0xFF); val lq = ((q shr 16) and 0xFF) + ((q shr 8) and 0xFF) + (q and 0xFF)
        if (lp - lq > 72) n++
    }
    return n.toDouble() / (plain.width * plain.height)
}

/** A JPEG at a quality that keeps the night's soft gradients free of blocks (as the intro's assets). */
internal fun writeJpeg613(img: BufferedImage, file: File) {
    val rgb = BufferedImage(img.width, img.height, BufferedImage.TYPE_INT_RGB).also { it.createGraphics().drawImage(img, 0, 0, null) }
    val writer = ImageIO.getImageWritersByFormatName("jpg").next()
    val param = writer.defaultWriteParam.apply { compressionMode = javax.imageio.ImageWriteParam.MODE_EXPLICIT; compressionQuality = 0.9f }
    javax.imageio.stream.FileImageOutputStream(file).use { o -> writer.output = o; writer.write(null, javax.imageio.IIOImage(rgb, null, null), param) }
    writer.dispose()
}
