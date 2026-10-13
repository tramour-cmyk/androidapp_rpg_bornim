package preview

import de.bornim.core.art.IntroArt
import java.awt.Color
import java.awt.Font
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** The four pictures of the intro (69, draft) side by side at three times their size, each with its text below as in the app. */
fun renderIntroSheet() {
    val z = 3; val w = IntroArt.W * z; val h = IntroArt.H * z; val box = 110
    val texts = listOf(
        "Drei Tage nach Norden. Die Straße ist leer, nur der Mond geht mit.",
        "Hinter der Brücke ein paar Lichter. Bornim. Ein Bett für eine Nacht, mehr willst du nicht.",
        "Der Platz schläft. Nur am Tempel wandern Fackeln. Eine späte Andacht, denkst du.",
        "Im »Schlafenden Greif« brennt noch Licht. Die Wirtin fragt nicht viel.",
    )
    val out = BufferedImage(w * 2, (h + box) * 2, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.color = Color(0x101014); g.fillRect(0, 0, out.width, out.height)
    for ((i, shot) in IntroArt.Shot.entries.withIndex()) {
        val img = IntroArt.paint(shot)
        val ox = i % 2 * w; val oy = i / 2 * (h + box)
        for (y in 0 until h) for (x in 0 until w) out.setRGB(ox + x, oy + y, img[x / z, y / z] and 0xFFFFFF)
        g.color = Color(0x96784A); g.drawRect(ox + 20, oy + h + 12, w - 40, box - 24)
        g.color = Color(0xEBE1C8); g.font = Font(Font.SANS_SERIF, Font.PLAIN, 24)
        val words = texts[i].split(" "); var line = ""; var ly = oy + h + 46
        for (word in words) {
            if (g.fontMetrics.stringWidth("$line $word") > w - 80) { g.drawString(line.trim(), ox + 36, ly); ly += 32; line = "" }
            line += " $word"
        }
        g.drawString(line.trim(), ox + 36, ly)
    }
    File("build/screens").mkdirs()
    ImageIO.write(out, "png", File("build/screens/intro69.png"))
    println("wrote build/screens/intro69.png")
}
