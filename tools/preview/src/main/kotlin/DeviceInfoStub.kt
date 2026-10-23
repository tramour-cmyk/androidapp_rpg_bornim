package de.bornim.game

/** Rechner-Ersatz für die Geräteangaben (DeviceInfo.kt ist von der Vorschau ausgeschlossen, 266). */
object DeviceInfo {
    fun lines(): Map<String, String> = linkedMapOf("Gerät" to "Vorschau am Rechner", "Prozessor" to "${Runtime.getRuntime().availableProcessors()} Kerne")
    fun gcNow() = Triple(0L, 0L, 0L)
    /** 335: ECKE= the radius of the screen's rounded corners in dp, as a phone reports it (0 by default). */
    fun cornerDp(): Float = System.getenv("ECKE")?.toFloat() ?: 0f
}
