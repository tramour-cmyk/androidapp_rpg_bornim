@file:Suppress("unused", "PackageDirectoryMismatch")

package androidx.lifecycle

open class AndroidViewModel(private val app: android.app.Application) {
    protected open fun onCleared() {}
}
