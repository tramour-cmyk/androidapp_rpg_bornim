package de.bornim.game

import android.app.ActivityManager
import android.content.Context
import android.hardware.display.DisplayManager
import android.opengl.EGL14
import android.opengl.GLES20
import android.os.Build
import android.os.PowerManager
import android.view.Display
import java.io.File

/**
 * 266 (Chef 20.10.: "einen Schalter …, mit dem ich dir wesentliche Infos zur Hardware auslesen kann"): what the device
 * is, for the test tab to show and copy into a report: model, Android, processor, graphics, memory, screen, power.
 * Nothing leaves the device by itself.
 */
object DeviceInfo {
    /** The graphics chip once asked (it takes a small GL context of its own), null until then. */
    private var gpu: String? = null
    private var app: Context? = null

    fun install(context: Context) { app = context.applicationContext }

    fun lines(): Map<String, String> {
        val context = app ?: return mapOf("Gerät" to "${Build.MANUFACTURER} ${Build.MODEL}")
        val m = linkedMapOf<String, String>()
        m["App"] = "${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE}, ${BuildConfig.BUILD_TYPE})"
        m["Gerät"] = "${Build.MANUFACTURER} ${Build.MODEL} (${Build.DEVICE})"
        m["Android"] = "${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})"
        m["Prozessor"] = (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) "${Build.SOC_MANUFACTURER} ${Build.SOC_MODEL}" else Build.HARDWARE) +
            ", ${Runtime.getRuntime().availableProcessors()} Kerne" + (runCatching { clocks() }.getOrNull()?.let { ", $it" } ?: "") +
            ", ${Build.SUPPORTED_ABIS.joinToString("/")}"
        m["Grafik"] = gpu ?: runCatching { glRenderer() }.getOrNull()?.also { gpu = it } ?: "?"
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
        am?.let { a ->
            val mi = ActivityManager.MemoryInfo().also { a.getMemoryInfo(it) }
            m["Arbeitsspeicher"] = "${mi.totalMem / (1024 * 1024)} MB, frei ${mi.availMem / (1024 * 1024)} MB" +
                (if (mi.lowMemory) " (knapp)" else "") + (if (a.isLowRamDevice) ", Gerät mit wenig Speicher" else "")
            m["App-Grenze"] = "${a.memoryClass} MB, groß ${a.largeMemoryClass} MB, Heap max ${Runtime.getRuntime().maxMemory() / (1024 * 1024)} MB"
        }
        runCatching { screen(context) }.getOrNull()?.let { m["Bildschirm"] = it }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && Build.VERSION.MEDIA_PERFORMANCE_CLASS > 0)
            m["Leistungsklasse"] = "${Build.VERSION.MEDIA_PERFORMANCE_CLASS}"
        (context.getSystemService(Context.POWER_SERVICE) as? PowerManager)?.let { p ->
            m["Energie"] = (if (p.isPowerSaveMode) "Stromsparen an" else "Stromsparen aus") +
                (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) ", Wärme ${thermal(p.currentThermalStatus)}" else "")
        }
        return m
    }

    /** The highest clock of each core, grouped: "4× 2,0 GHz + 4× 1,8 GHz". */
    private fun clocks(): String? {
        val khz = (0 until Runtime.getRuntime().availableProcessors()).mapNotNull { i ->
            File("/sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq").takeIf { it.canRead() }?.readText()?.trim()?.toLongOrNull()
        }
        if (khz.isEmpty()) return null
        return khz.groupingBy { it }.eachCount().entries.sortedByDescending { it.key }
            .joinToString(" + ") { (f, n) -> "$n× " + "%.1f GHz".format(java.util.Locale.GERMANY, f / 1_000_000.0) }
    }

    /** The screen as the device has it: pixels, dots per inch, pictures a second. */
    private fun screen(context: Context): String {
        val d = (context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager).getDisplay(Display.DEFAULT_DISPLAY)
        val dm = context.resources.displayMetrics
        val mode = d.mode
        return "${mode.physicalWidth}×${mode.physicalHeight} px, ${dm.densityDpi} dpi, " +
            "${context.resources.configuration.smallestScreenWidthDp} dp schmal, ${"%.0f".format(d.refreshRate)} Hz"
    }

    private fun thermal(s: Int) = when (s) {
        PowerManager.THERMAL_STATUS_NONE -> "normal"
        PowerManager.THERMAL_STATUS_LIGHT -> "leicht"
        PowerManager.THERMAL_STATUS_MODERATE -> "mäßig"
        PowerManager.THERMAL_STATUS_SEVERE -> "stark"
        else -> "kritisch ($s)"
    }

    /** The graphics chip and its OpenGL ES version, from a small context of its own made and dropped at once. */
    private fun glRenderer(): String? {
        val dpy = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
        // the display is the one the app draws on too: initialised, never terminated
        if (dpy == EGL14.EGL_NO_DISPLAY || !EGL14.eglInitialize(dpy, IntArray(2), 0, IntArray(2), 1)) return null
        val configs = arrayOfNulls<android.opengl.EGLConfig>(1); val n = IntArray(1)
        val want = intArrayOf(EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT, EGL14.EGL_SURFACE_TYPE, EGL14.EGL_PBUFFER_BIT, EGL14.EGL_NONE)
        if (!EGL14.eglChooseConfig(dpy, want, 0, configs, 0, 1, n, 0) || n[0] == 0) return null
        val ctx = EGL14.eglCreateContext(dpy, configs[0], EGL14.EGL_NO_CONTEXT, intArrayOf(EGL14.EGL_CONTEXT_CLIENT_VERSION, 2, EGL14.EGL_NONE), 0)
        if (ctx == EGL14.EGL_NO_CONTEXT) return null
        val surf = EGL14.eglCreatePbufferSurface(dpy, configs[0], intArrayOf(EGL14.EGL_WIDTH, 1, EGL14.EGL_HEIGHT, 1, EGL14.EGL_NONE), 0)
        try {
            if (surf == EGL14.EGL_NO_SURFACE || !EGL14.eglMakeCurrent(dpy, surf, surf, ctx)) return null
            return "${GLES20.glGetString(GLES20.GL_RENDERER)} (${GLES20.glGetString(GLES20.GL_VERSION)})"
        } finally {
            EGL14.eglMakeCurrent(dpy, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT)
            if (surf != EGL14.EGL_NO_SURFACE) EGL14.eglDestroySurface(dpy, surf)
            EGL14.eglDestroyContext(dpy, ctx)
        }
    }
}
