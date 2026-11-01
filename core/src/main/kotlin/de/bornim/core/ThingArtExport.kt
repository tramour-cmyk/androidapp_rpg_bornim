package de.bornim.core

import de.bornim.core.art.ItemArt
import de.bornim.core.art.PixelImage
import de.bornim.core.art.SupplyArt
import java.awt.image.BufferedImage
import java.io.File
import javax.imageio.ImageIO

/**
 * 399.1 (Godot, Bilder der Dinge): the pictures of the bag and the shop as the old game draws them, made in the build
 * instead of on the device: every supply and the gold as `ding-<id>.bild` ([SupplyArt], its drawn icon where it has no picture), every
 * piece of gear for each rarity as `stueck-<base>-<RARITY>.bild` ([ItemArt], the stones of its rarity round it). PNG with
 * transparency; the ending keeps Godot from importing them.
 */
object ThingArtExport {
    fun png(img: PixelImage, out: File) {
        val b = BufferedImage(img.width, img.height, BufferedImage.TYPE_INT_ARGB)
        b.setRGB(0, 0, img.width, img.height, img.pixels, 0, img.width)
        ImageIO.write(b, "png", out)
    }

    @JvmStatic
    fun main(args: Array<String>) {
        val dir = File(args.firstOrNull() ?: "dinge")
        dir.mkdirs()
        var n = 0
        for (id in Items.all.map { it.id } + SupplyArt.GOLD) { png(SupplyArt.get(id), File(dir, "ding-$id.bild")); n++ }
        for (b in GearBases.all) for (r in Rarity.entries) { png(ItemArt.get(b.id, r), File(dir, "stueck-${b.id}-${r.name}.bild")); n++ }
        println("Bilder der Dinge: $n -> $dir")
    }
}
