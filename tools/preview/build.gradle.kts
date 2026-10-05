// Desktop harness: compiles the app's Compose UI against Compose Multiplatform with small
// Android stubs and renders screenshots, so the UI can be checked without the Android SDK.
plugins {
    kotlin("jvm") version "2.1.21"
    kotlin("plugin.compose") version "2.1.21"
    application
}

kotlin {
    jvmToolchain(21)
    sourceSets.main {
        kotlin.srcDir("../../app/src/main/java")
        kotlin.exclude("**/MainActivity.kt", "**/audio/MusicPlayer.kt", "**/audio/SfxPlayer.kt")
    }
}

dependencies {
    implementation("de.bornim:core:0.1.0")
    // Compose Multiplatform 1.5 is the newest version whose dependencies are all on Maven Central.
    implementation("org.jetbrains.compose.desktop:desktop-jvm-linux-x64:1.5.12")
    implementation("org.jetbrains.compose.material3:material3-desktop:1.5.12")
}

application {
    mainClass.set("preview.MainKt")
}
