package de.bornim.game

import android.app.ActivityManager
import android.app.ApplicationExitInfo
import android.content.Context
import android.os.Build
import android.os.Debug
import de.bornim.core.Guard
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * 30.1: what ended the app last time, for the test tab. A crash of any thread is written to a file before the app
 * ends; errors caught in the background ([Guard]) are kept there too. On Android 11 and later the system also tells
 * why the app ended (killed for memory, a crash in native code, not answering), which no handler sees.
 */
object CrashLog {
    private var dir: File? = null
    private var am: ActivityManager? = null

    /** What the app did when it ended, filled in by the app: screen, map, fight. */
    @Volatile var where: () -> String = { "?" }

    /** The last crash read at this start (and its time), null when there was none. */
    var lastCrash: String? = null
        private set

    /** Why the app ended last time, by the system (Android 11+), null when unknown. */
    var lastExit: String? = null
        private set

    private const val CRASH = "letzter-absturz.txt"
    private const val CAUGHT = "abgefangen.txt"

    fun install(context: Context) {
        val d = File(context.filesDir, "absturz").apply { mkdirs() }
        dir = d
        am = context.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
        lastCrash = File(d, CRASH).takeIf { it.exists() }?.let { f -> runCatching { f.readText() }.getOrNull() }
        lastExit = runCatching { exitReason(context) }.getOrNull()
        Guard.about = ::about
        Guard.sink = { text -> append(text) }
        val before = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { t, e ->
            try {
                val text = "Zeit: ${now()}\n" + Guard.describe(e, "Absturz", about(), t.name)
                File(d, CRASH).writeText(text)
            } catch (_: Throwable) {}
            before?.uncaughtException(t, e)
        }
        watchMain()
    }

    /** How long the main thread may stand before it counts as hanging (257; Android asks to wait after 5 s). */
    private const val HANG_MS = 2500L

    /**
     * 257 (Chef 20.10.: „App hängt, warten oder schließen, ging dann weiter“): a thread of its own pings the main
     * thread; does it stand longer than [HANG_MS], what it is doing then is kept with the errors caught (test tab).
     * Once per hang: it waits until the main thread runs again.
     */
    private fun watchMain() {
        val looper = android.os.Looper.getMainLooper()
        val main = android.os.Handler(looper)
        Thread({
            while (true) {
                val done = java.util.concurrent.CountDownLatch(1)
                main.post { done.countDown() }
                if (!done.await(HANG_MS, java.util.concurrent.TimeUnit.MILLISECONDS)) {
                    val stack = looper.thread.stackTrace
                    val t0 = System.currentTimeMillis()
                    runCatching {
                        val e = Throwable("Hauptfaden steht über ${HANG_MS / 1000.0} s").apply { stackTrace = stack }
                        append(Guard.describe(e, "Hänger", about(), looper.thread.name))
                    }
                    done.await()
                    runCatching { append("Hänger vorbei nach etwa ${(HANG_MS + System.currentTimeMillis() - t0) / 1000.0} s") }
                }
                Thread.sleep(500)
            }
        }, "haenger-waechter").apply { isDaemon = true }.start()
    }

    /** Version, screen, memory of the app and of the device. */
    fun about(): Map<String, String> {
        val m = linkedMapOf("Version" to "${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})",
            "Gerät" to "${Build.MANUFACTURER} ${Build.MODEL}, Android ${Build.VERSION.RELEASE}",
            "Bildschirm" to runCatching { where() }.getOrElse { "?" })
        m.putAll(Guard.heap())
        m["Nativ belegt"] = "${Debug.getNativeHeapAllocatedSize() / (1024 * 1024)} MB"
        am?.let { a ->
            val mi = ActivityManager.MemoryInfo().also { a.getMemoryInfo(it) }
            m["Gerät frei"] = "${mi.availMem / (1024 * 1024)} von ${mi.totalMem / (1024 * 1024)} MB" + if (mi.lowMemory) " (knapp)" else ""
            m["App-Grenze"] = "${a.memoryClass} MB, groß ${a.largeMemoryClass} MB"
        }
        return m
    }

    /** Errors caught in the background since this start, the newest last; the file holds at most a few. */
    fun caught(): String? = dir?.let { File(it, CAUGHT) }?.takeIf { it.exists() }?.let { runCatching { it.readText() }.getOrNull() }

    @Synchronized private fun append(text: String) {
        val f = File(dir ?: return, CAUGHT)
        val old = if (f.exists()) f.readText() else ""
        // only the newest few, so the file stays small
        val all = (old.split(SEP).filter { it.isNotBlank() } + "Zeit: ${now()}\n$text").takeLast(KEEP)
        f.writeText(all.joinToString(SEP))
    }

    /** At start: the errors caught last time are of no more use beside the new ones. */
    fun clearCaught() { dir?.let { File(it, CAUGHT).delete() } }

    /** Forgets the last crash (after it was copied). */
    fun clearCrash() { dir?.let { File(it, CRASH).delete() }; lastCrash = null }

    private fun exitReason(context: Context): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return null
        val info = am?.getHistoricalProcessExitReasons(context.packageName, 0, 1)?.firstOrNull() ?: return null
        val why = when (info.reason) {
            ApplicationExitInfo.REASON_LOW_MEMORY -> "Speicher knapp, vom System beendet"
            ApplicationExitInfo.REASON_CRASH -> "Absturz (Kotlin/Java)"
            ApplicationExitInfo.REASON_CRASH_NATIVE -> "Absturz in nativem Code"
            ApplicationExitInfo.REASON_ANR -> "reagierte nicht (ANR)"
            ApplicationExitInfo.REASON_SIGNALED -> "vom System beendet (Signal ${info.status})"
            ApplicationExitInfo.REASON_EXCESSIVE_RESOURCE_USAGE -> "zu viel Verbrauch"
            ApplicationExitInfo.REASON_USER_REQUESTED -> "vom Nutzer beendet"
            ApplicationExitInfo.REASON_USER_STOPPED -> "vom Nutzer gestoppt"
            ApplicationExitInfo.REASON_EXIT_SELF -> "selbst beendet"
            ApplicationExitInfo.REASON_DEPENDENCY_DIED -> "Abhängigkeit beendet"
            ApplicationExitInfo.REASON_PERMISSION_CHANGE -> "Berechtigung geändert"
            ApplicationExitInfo.REASON_INITIALIZATION_FAILURE -> "Start fehlgeschlagen"
            // newer reasons as plain numbers, their constants need a newer Android (30.8: 16 read as "other")
            13 -> "anderer Grund (vom System)"
            14 -> "eingefroren und beendet"
            15 -> "App aktiviert oder deaktiviert"
            16 -> "App aktualisiert"
            else -> "anderer Grund (${info.reason})"
        }
        return "${time(info.timestamp)}: $why" +
            (info.description?.let { "\n$it" } ?: "") +
            "\nSpeicher beim Ende: PSS ${info.pss / 1024} MB, RSS ${info.rss / 1024} MB, Wichtigkeit ${info.importance}"
    }

    private fun now() = time(System.currentTimeMillis())

    private fun time(ms: Long) = SimpleDateFormat("dd.MM., HH:mm:ss", Locale.GERMANY)
        .apply { timeZone = TimeZone.getTimeZone("Europe/Berlin") }.format(Date(ms))

    private const val SEP = "\n\n----\n\n"
    private const val KEEP = 5
}
