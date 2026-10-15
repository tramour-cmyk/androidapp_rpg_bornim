package preview

import de.bornim.core.art.CutsceneArt
import de.bornim.core.art.CutsceneArt.Shot
import java.awt.Color
import java.awt.Font
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/** The painted pictures of the cutscenes (70, draft) at three times their size, each with its text below as in the app: intro (69) and temple (68). */
fun renderIntroSheet() {
    renderCutscene("intro69", listOf(
        Shot.ROAD to "Drei Tage nach Norden. Die Straße ist leer, nur der Mond geht mit.",
        Shot.BRIDGE to "Hinter der Brücke ein paar Lichter. Bornim. Ein Bett für eine Nacht, mehr willst du nicht.",
        Shot.SQUARE to "Der Platz schläft. Nur am Tempel wandern Fackeln. Eine späte Andacht, denkst du.",
        Shot.INN to "Im »Schlafenden Greif« brennt noch Licht. Die Wirtin fragt nicht viel.",
    ))
    renderCutscene("tempel68", listOf(
        Shot.TEMPLE_FULL to "Der Tempel ist voll. Tagelang war er kalt und leer.",
        Shot.TEMPLE_GIVE to "Aldric gibt Lyra das Amulett. Sie hält es lange, als könnte es zerbrechen.",
        Shot.TEMPLE_PRAY to "Osric hält die Kerze ruhig. Lyra betet in Worten, die älter sind als der Tempel selbst.",
        Shot.TEMPLE_DAWN to "Das erste Licht des Tages fällt durchs Fenster. Das Amulett fängt es auf.",
        Shot.TEMPLE_LYRA to "Bornim atmet auf. Nur Lyra sieht noch lange ins Grau hinaus.",
    ))
}

private fun renderCutscene(name: String, shots: List<Pair<Shot, String>>) {
    val z = 3; val w = CutsceneArt.W * z; val h = CutsceneArt.H * z; val box = 110
    val rows = (shots.size + 1) / 2
    val out = BufferedImage(w * 2, (h + box) * rows, BufferedImage.TYPE_INT_RGB)
    val g = out.createGraphics()
    g.color = Color(0x101014); g.fillRect(0, 0, out.width, out.height)
    for ((i, st) in shots.withIndex()) {
        val img = CutsceneArt.paint(st.first)
        val ox = i % 2 * w; val oy = i / 2 * (h + box)
        for (y in 0 until h) for (x in 0 until w) out.setRGB(ox + x, oy + y, img[x / z, y / z] and 0xFFFFFF)
        g.color = Color(0x96784A); g.drawRect(ox + 20, oy + h + 12, w - 40, box - 24)
        g.color = Color(0xEBE1C8); g.font = Font(Font.SANS_SERIF, Font.PLAIN, 24)
        var line = ""; var ly = oy + h + 46
        for (word in st.second.split(" ")) {
            if (g.fontMetrics.stringWidth("$line $word") > w - 80) { g.drawString(line.trim(), ox + 36, ly); ly += 32; line = "" }
            line += " $word"
        }
        g.drawString(line.trim(), ox + 36, ly)
    }
    File("build/screens").mkdirs()
    ImageIO.write(out, "png", File("build/screens/$name.png"))
    println("wrote build/screens/$name.png")
}
