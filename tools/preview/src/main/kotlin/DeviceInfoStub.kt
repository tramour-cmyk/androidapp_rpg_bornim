package de.bornim.game

/** Rechner-Ersatz für die Geräteangaben (DeviceInfo.kt ist von der Vorschau ausgeschlossen, 266). */
object DeviceInfo {
    fun lines(): Map<String, String> = linkedMapOf("Gerät" to "Vorschau am Rechner", "Prozessor" to "${Runtime.getRuntime().availableProcessors()} Kerne")
    fun gcNow() = Triple(0L, 0L, 0L)
}
