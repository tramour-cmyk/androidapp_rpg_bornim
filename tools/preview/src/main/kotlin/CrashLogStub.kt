package de.bornim.game

/** Rechner-Ersatz für die Android-Absturzdatei (CrashLog.kt ist von der Vorschau ausgeschlossen). */
object CrashLog {
    var lastCrash: String? = null
    var lastExit: String? = null
    fun caught(): String? = null
    fun clearCaught() {}
    fun note(text: String) = runCatching { println("CrashLog: $text") }
    fun clearCrash() { lastCrash = null }
    fun about(): Map<String, String> = emptyMap()
}
