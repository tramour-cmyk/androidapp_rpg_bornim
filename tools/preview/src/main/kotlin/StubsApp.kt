@file:Suppress("unused", "UNUSED_PARAMETER", "PackageDirectoryMismatch")

package android.content

interface SharedPreferences {
    fun getString(key: String, def: String?): String?
    fun getBoolean(key: String, def: Boolean): Boolean
    fun getInt(key: String, def: Int): Int
    fun getLong(key: String, def: Long): Long
    fun contains(key: String): Boolean
    fun edit(): Editor

    interface Editor {
        fun putString(key: String, value: String): Editor
        fun putBoolean(key: String, value: Boolean): Editor
        fun putInt(key: String, value: Int): Editor
        fun putLong(key: String, value: Long): Editor
        fun remove(key: String): Editor
        fun apply()
    }
}

open class Context {
    private val store = HashMap<String, String>()

    fun getSharedPreferences(name: String, mode: Int): SharedPreferences = object : SharedPreferences {
        override fun getString(key: String, def: String?) = store[key] ?: def
        override fun getBoolean(key: String, def: Boolean) = store[key]?.toBoolean() ?: def
        override fun getInt(key: String, def: Int) = store[key]?.toIntOrNull() ?: def
        override fun getLong(key: String, def: Long) = store[key]?.toLongOrNull() ?: def
        override fun contains(key: String) = key in store
        override fun edit() = object : SharedPreferences.Editor {
            override fun putString(key: String, value: String) = apply { store[key] = value }
            override fun putBoolean(key: String, value: Boolean) = apply { store[key] = value.toString() }
            override fun putInt(key: String, value: Int) = apply { store[key] = value.toString() }
            override fun putLong(key: String, value: Long) = apply { store[key] = value.toString() }
            override fun remove(key: String) = apply { store.remove(key) }
            override fun apply() {}
        }
    }

    companion object {
        const val MODE_PRIVATE = 0
    }
}
