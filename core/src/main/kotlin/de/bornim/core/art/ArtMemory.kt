package de.bornim.core.art

/** 30.2: when memory runs short, the pictures not needed on the map shown now are let go; they are drawn again when wanted. */
object ArtMemory {
    fun trim() {
        MapGround.trim()
        MapFolk.keepOnly(MapFolk.shown?.let { MapFolk.idsOn(it) } ?: emptySet())
    }
}
