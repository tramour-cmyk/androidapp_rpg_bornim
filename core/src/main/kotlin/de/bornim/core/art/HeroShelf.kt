package de.bornim.core.art

import java.io.DataInputStream
import java.io.DataOutputStream
import java.io.File
import java.nio.ByteBuffer
import java.util.zip.Deflater
import java.util.zip.DeflaterOutputStream
import java.util.zip.InflaterInputStream

/**
 * The hero's map pictures kept on the device (24.4): once all pictures of a look are drawn they are written
 * to [dir], so the next start, or putting on gear worn before, needs no drawing. The app gives a folder of its
 * own per build, so pictures from older drawing code are never shown. Only the [KEEP] newest looks are kept.
 */
object HeroShelf {
    /** Where the pictures go; null (previews, tests) keeps nothing. */
    @Volatile var dir: File? = null

    /** Room for the looks worn lately and those of new loot drawn ahead (24.15). */
    const val KEEP = 12
    private const val MAGIC = 0x42484631 // "BHF1"

    private fun file(look: String): File? {
        val d = dir ?: return null
        val sha = java.security.MessageDigest.getInstance("SHA-1").digest(look.toByteArray())
        return File(d, sha.joinToString("") { "%02x".format(it) } + ".pix")
    }

    /** Whether all pictures of [look] are kept. */
    fun has(look: String): Boolean = file(look)?.isFile == true

    /** All pictures of [look] by (direction, step), or null when not kept or unreadable. */
    fun load(look: String): Map<Pair<Int, Int>, PixelImage>? {
        val f = file(look)?.takeIf { it.isFile } ?: return null
        return try {
            DataInputStream(InflaterInputStream(f.inputStream().buffered(1 shl 16))).use { inp ->
                if (inp.readInt() != MAGIC || inp.readUTF() != look) return null
                val n = inp.readInt()
                val out = HashMap<Pair<Int, Int>, PixelImage>(n * 2)
                repeat(n) {
                    val s = inp.readInt(); val st = inp.readInt(); val w = inp.readInt(); val h = inp.readInt()
                    val bytes = ByteArray(w * h * 4)
                    inp.readFully(bytes)
                    val px = IntArray(w * h)
                    ByteBuffer.wrap(bytes).asIntBuffer().get(px)
                    out[s to st] = PixelImage(w, h, px)
                }
                f.setLastModified(System.currentTimeMillis())
                out
            }
        } catch (e: Exception) {
            f.delete(); null
        }
    }

    /** Keeps all pictures of [look]; written to a side file first, so a half-written one is never read. */
    fun save(look: String, pics: Map<Pair<Int, Int>, PixelImage>) {
        val f = file(look) ?: return
        try {
            f.parentFile?.mkdirs()
            val tmp = File(f.path + ".tmp")
            DataOutputStream(DeflaterOutputStream(tmp.outputStream().buffered(1 shl 16), Deflater(Deflater.BEST_SPEED))).use { out ->
                out.writeInt(MAGIC); out.writeUTF(look); out.writeInt(pics.size)
                for ((k, img) in pics) {
                    out.writeInt(k.first); out.writeInt(k.second); out.writeInt(img.width); out.writeInt(img.height)
                    val bb = ByteBuffer.allocate(img.pixels.size * 4)
                    bb.asIntBuffer().put(img.pixels)
                    out.write(bb.array())
                }
            }
            if (!tmp.renameTo(f)) tmp.delete()
            // only the newest few looks stay
            f.parentFile?.listFiles { x -> x.name.endsWith(".pix") }?.sortedByDescending { it.lastModified() }?.drop(KEEP)?.forEach { it.delete() }
        } catch (e: Exception) {
            // nothing kept: drawn again next time
        }
    }
}
