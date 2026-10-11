package de.bornim.core.art

import de.bornim.core.Tile
import de.bornim.core.World
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/** 5h.1: a house's windows seen outside are those of its room inside, on the same walls. */
class HouseWindowsTest {
    @Test
    fun windowsOutsideMatchTheRoom() {
        val village = World["village"]
        val withRoom = MapTownIso.houses(village).map { it.first }.mapNotNull { f -> MapTownIso.roomOf(village, f)?.let { f to it } }
        assertEquals(4, withRoom.size, "inn, shop, elder, temple")
        for ((f, room) in withRoom) {
            val letters = (0 until f.n).joinToString("") { when (village.tile(f.x + it, f.y)) { Tile.WINDOW -> "W"; Tile.DOOR -> "D"; else -> "#" } }
            val (front, side) = MapTownIso.windowsFromRoom(room, f.n, f.d, letters.indexOf('D'))
            // the map's front row (also drawn seen straight, and lit at night) is the room's south wall
            assertEquals(letters, front, "${room.id}: front")
            val inSouth = (1 until room.width - 1).count { room.tile(it, room.height - 1) == Tile.WINDOW }
            assertEquals(inSouth, front.count { it == 'W' }, "${room.id}: as many windows outside as in the south wall")
            val inEast = (1 until room.height - 1).count { room.tile(room.width - 1, it) == Tile.WINDOW }
            assertTrue(inEast > 0 && side.count { it == 'W' } in 1..inEast, "${room.id}: east wall windows $side")
        }
    }
}
