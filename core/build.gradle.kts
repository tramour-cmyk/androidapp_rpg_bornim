import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    kotlin("jvm") version "2.1.21"
    kotlin("plugin.serialization") version "2.1.21"
}

group = "de.bornim"
version = "0.1.0"

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.8.1")
    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}

// 348.6: Karten als JSON fuer Godot und Blender (MapExport.kt)
tasks.register<JavaExec>("exportMaps") {
    classpath = sourceSets["main"].runtimeClasspath
    mainClass.set("de.bornim.core.MapExport")
    args((findProperty("out") as String?) ?: layout.buildDirectory.file("karten.json").get().asFile.path)
}

// 390: Texte der Oberflaeche in beiden Sprachen fuer Godot (TextExport.kt)
tasks.register<JavaExec>("exportTexts") {
    classpath = sourceSets["main"].runtimeClasspath
    mainClass.set("de.bornim.core.TextExport")
    args((findProperty("out") as String?) ?: layout.buildDirectory.file("texte.json").get().asFile.path)
}

// 390: Regeln und Proben des Helden fuer Godot (HeroExport.kt)
tasks.register<JavaExec>("exportHero") {
    classpath = sourceSets["main"].runtimeClasspath
    mainClass.set("de.bornim.core.HeroExport")
    args(listOfNotNull((findProperty("out") as String?) ?: layout.buildDirectory.file("held.json").get().asFile.path, findProperty("proben") as String?))
}

// 399.1: Kartenblaetter fuer den Reiter Karte in Godot (MapSheetExport.kt)
tasks.register<JavaExec>("exportMapSheets") {
    classpath = sourceSets["main"].runtimeClasspath
    mainClass.set("de.bornim.core.MapSheetExport")
    args((findProperty("out") as String?) ?: layout.buildDirectory.dir("kartenblatt").get().asFile.path)
}
