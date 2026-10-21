package de.bornim.game.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.EliteTrait
import de.bornim.core.Facing
import de.bornim.core.Game
import de.bornim.core.Gender
import de.bornim.core.CharClass
import de.bornim.core.Lang
import de.bornim.core.GearBases
import de.bornim.core.GearSlot
import de.bornim.core.MonsterKits
import de.bornim.core.Monsters
import de.bornim.core.Opening
import de.bornim.core.Place
import de.bornim.core.Rarity
import de.bornim.game.GameViewModel

/** Cheats for testing, only visible in test mode (tap the copyright on the title screen 7 times). */
@Composable
fun TestTab(vm: GameViewModel, game: Game, lang: Lang) {
    vm.tick // redraw after every change
    val german = lang == Lang.DE
    fun t(d: String, e: String) = if (german) d else e
    val h = game.hero
    // 0 = normal, 1..6 = elite trait, 7 = shimmering
    var variant by remember { mutableIntStateOf(0) }
    var showMonsters by remember { mutableStateOf(false) }
    // 9i: tapping a monster in the list fights it, or brings it onto the map beside the hero to watch
    var bring by remember { mutableStateOf(false) }
    var showWeapons by remember { mutableStateOf(false) }
    var opening by remember { mutableStateOf(Opening.NORMAL) }
    fun gearName(id: String) = GearBases[id].let { if (german) it.de else it.en }

    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Txt(t("Testmodus", "Test mode"), size = 18.sp, bold = true)
        CrashBox(vm, ::t)

        Spacer(Modifier.height(4.dp))
        // 218: the test tab in groups by purpose, each under its heading
        Txt(t("Anzeigen und Messwerte", "Displays and readings"), size = 16.sp, bold = true)
        val readings = mutableListOf<String>()
        // 24.1: how long the last black screen between places waited until everything was drawn
        readings += t("Blende: bereit nach ", "Veil: ready after ") + (VeilMemory.readyAfterMs?.let { "%.1f s".format(it / 1000f) } ?: "–")
        // 175: the first 10 s after it: the longest pause between two pictures, and how many paused over 50 ms
        readings += t("Danach 10 s: längste Bildpause ", "Then 10 s: longest frame pause ") + (VeilMemory.afterLongestMs?.let { "$it ms" } ?: "–") +
            t(", über 50 ms: ", ", over 50 ms: ") + (if (VeilMemory.afterLongestMs != null) "${VeilMemory.afterSlow}" else "–") +
            (VeilMemory.afterCutMs?.let { t(" (abgebrochen nach ", " (cut short after ") + "%.1f s)".format(it / 1000f) } ?: "")
        // 267: what drew in the background during those slow pictures, and the runtime's collections of garbage meanwhile
        VeilMemory.afterBy?.let { by ->
            readings += t("Langsame Bilder während: ", "Slow pictures during: ") +
                (by.entries.sortedByDescending { it.value }.map { (k, n) -> t(k.de, k.en) + " $n" } + t("nichts ", "nothing ") + VeilMemory.afterAlone).joinToString(", ")
        }
        VeilMemory.afterGc?.let { (all, held, ms) ->
            readings += t("Speicherbereinigung danach: ", "Garbage collections then: ") + all + t(", davon anhaltend ", ", of them halting ") + held + " ($ms ms)"
        }
        // 24.13: how long the hero took until drawn in full, also beyond the veil's 4 s
        readings += t("Held ganz gezeichnet nach ", "Hero fully drawn after ") + (de.bornim.core.art.MapFigure.lastFullMs?.let { "%.1f s".format(it / 1000f) } ?: "–") +
            (if (de.bornim.core.art.MapFigure.lastFromShelf) t(" (gespeichert)", " (kept)") else "")
        // 24.5: how long the last fight waited for its frames: the hero's opening, all of the hero's, the foe's
        de.bornim.core.art.BattleAhead.let { a ->
            fun s(ms: Long?) = ms?.let { "%.1f s".format(it / 1000f) } ?: "–"
            readings += t("Kampf bereit: Eröffnung ", "Fight ready: opening ") + s(a.openingMs) + t(", Held ", ", hero ") + s(a.heroMs) +
                t(", Gegner ", ", foe ") + s(a.foeMs)
            // 24.16: what it found drawn ahead on the map, and how long the drawing ahead waited for the map
            a.report?.let { r ->
                readings += t("Vorgezeichnet: Held ", "Drawn ahead: hero ") + "${r.heroReady}/${r.heroAll}" + (if (r.kept) t(" (gespeichert)", " (kept)") else "") + t(", Gegner ", ", foe ") + r.foe + " ${r.foeDrawn}" +
                    t(if (r.foeDone) " (fertig)" else " (nicht fertig)", if (r.foeDone) " (all)" else " (not all)") +
                    t(", gewartet ", ", waited ") + s(r.waitedMs) + t(", Gegner nahe ", ", foe near ") + s(r.nearMs) +
                    t(", Speicher ", ", memory ") + "${Runtime.getRuntime().maxMemory() / (1024 * 1024)} MB"
            }
        }
        for (r in readings) Txt(r, size = 13.sp)
        DeviceBox(vm, ::t, readings)
        // 27m: frames per second over the map, to see whether the wood beyond the edge slows the phone
        PixelButton(t("Bildrate anzeigen: ", "Show frame rate: ") + (if (FrameMeter.on) t("an", "on") else t("aus", "off")), Modifier.fillMaxWidth(), size = 14.sp) {
            FrameMeter.on = !FrameMeter.on
        }
        // 86.1: the hero's map and tile over the map, to name a place when reporting
        PixelButton(t("Standort anzeigen: ", "Show position: ") + (if (PlaceMeter.on) t("an", "on") else t("aus", "off")), Modifier.fillMaxWidth(), size = 14.sp) {
            PlaceMeter.on = !PlaceMeter.on
        }

        Spacer(Modifier.height(4.dp))
        Txt(t("Held", "Hero"), size = 16.sp, bold = true)
        Txt(t("Stufe", "Level") + ": ${h.level}   ·   " + t("Gold", "Gold") + ": ${game.state.gold}", size = 16.sp)
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            for (d in listOf(-5, -1, 1, 5)) {
                PixelButton(if (d > 0) "+$d" else "$d", Modifier.weight(1f), size = 15.sp) {
                    game.cheatLevel(h.level + d)
                    vm.refresh()
                }
            }
        }
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            PixelButton("+1000 " + t("Gold", "gold"), Modifier.weight(1f), size = 14.sp) {
                game.cheatGold(1000)
                vm.refresh()
            }
            PixelButton(t("Heilen", "Heal"), Modifier.weight(1f), size = 14.sp) {
                game.cheatHeal()
                vm.refresh()
            }
        }
        PixelButton(t("Alle Vorräte auf mindestens 10", "All supplies to at least 10"), Modifier.fillMaxWidth(), size = 14.sp) {
            game.cheatSupplies(10)
            vm.refresh()
            vm.toast = t("Tränke, Flaschen, Essen und Zutaten aufgefüllt, zwei Fackeln und ein Rauchbündel dazu.", "Draughts, flasks, food, ingredients, two torches and a smoke bundle filled up.")
        }
        // what the hero fights with
        val main = h.item(GearSlot.MAIN_HAND)
        PixelButton(t("Waffe des Helden", "Hero's weapon") + ": " + (main?.let { gearName(it.base) } ?: t("keine", "none")) + if (showWeapons) "  ▾" else "  ›", Modifier.fillMaxWidth(), size = 14.sp) {
            showWeapons = !showWeapons
        }
        if (showWeapons) {
            val weapons = listOf<String?>(null) + GearBases.all.filter { it.isWeapon }.map { it.id }
            weapons.chunked(2).forEach { pair ->
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    pair.forEach { w ->
                        val twoHanded = w != null && GearBases[w].twoHanded
                        PixelButton((w?.let { gearName(it) } ?: t("Ohne Waffe", "No weapon")) + if (twoHanded) " ²" else "", Modifier.weight(1f), size = 12.sp) {
                            game.cheatWeapon(w)
                            showWeapons = false
                            vm.refresh()
                        }
                    }
                    if (pair.size == 1) Spacer(Modifier.weight(1f))
                }
            }
        }
        val offOptions = listOf<String?>(null, "shield", "round_shield", "dagger")
        val off = h.item(GearSlot.OFF_HAND)?.base
        PixelButton(t("Andere Hand", "Other hand") + ": " + (off?.let { gearName(it) } ?: t("leer", "empty")) + "  ›", Modifier.fillMaxWidth(), size = 14.sp) {
            val next = offOptions[(offOptions.indexOf(off) + 1).mod(offOptions.size)]
            game.cheatOffHand(next)
            vm.refresh()
        }

        Spacer(Modifier.height(4.dp))
        Txt(t("Welt", "World"), size = 16.sp, bold = true)
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            PixelButton(t("Uhrzeit +3 h", "Time +3 h") + "  (%02d:%02d)".format(game.state.minutes / 60, game.state.minutes % 60), Modifier.weight(1f), size = 13.sp) {
                game.cheatTime(3)
                vm.refresh()
            }
            // the switch shows its setting; a tap moves it on: chance, always, never
            val rain = when (de.bornim.core.Weather.mode) {
                de.bornim.core.Weather.Mode.RANDOM -> t("Regen: zufällig", "Rain: chance")
                de.bornim.core.Weather.Mode.ALWAYS -> t("Regen: immer", "Rain: always")
                de.bornim.core.Weather.Mode.NEVER -> t("Regen: nie", "Rain: never")
            }
            PixelButton(rain, Modifier.weight(1f), size = 13.sp) {
                game.cheatRain()
                vm.refresh()
            }
        }
        // the zoom in four steps, to find the right one on the phone (10.10., 6.15)
        var zoom by remember { mutableStateOf(MapZoom.level) }
        fun tiles(l: Int) = MapZoom.levels[l].toString().replace(".", ",") + t(" Kacheln", " tiles") +
            when (l) { 0 -> t(" (nah)", " (near)"); MapZoom.levels.size - 1 -> t(" (weit, bisher)", " (far, former)"); else -> "" }
        PixelButton(t("Kartenzoom: ", "Map zoom: ") + tiles(zoom), Modifier.fillMaxWidth(), size = 14.sp) {
            MapZoom.level = (MapZoom.level + 1) % MapZoom.levels.size
            zoom = MapZoom.level
            vm.refresh()
            vm.toast = t("Karte: ", "Map: ") + tiles(zoom) + t(" quer", " across")
        }
        // 9f: to watch the monsters on the map go about without being set upon
        var ignore by remember { mutableStateOf(de.bornim.core.Game.monstersIgnoreHero) }
        PixelButton(t("Monster beachten mich nicht: ", "Monsters ignore me: ") + (if (ignore) t("an", "on") else t("aus", "off")), Modifier.fillMaxWidth(), size = 14.sp) {
            de.bornim.core.Game.monstersIgnoreHero = !de.bornim.core.Game.monstersIgnoreHero
            ignore = de.bornim.core.Game.monstersIgnoreHero
            vm.toast = if (ignore) t("Monster laufen und stehen wie sonst, greifen aber nicht an. Wer selbst hineinläuft, kämpft.", "Monsters go about as ever but never attack. Walk into one to fight.") else t("Monster jagen dich wieder.", "Monsters hunt you again.")
        }
        var seeAll by remember { mutableStateOf(de.bornim.core.Game.seeAll) }
        PixelButton(t("Sichtlinie aus (alles sichtbar): ", "Line of sight off (see all): ") + (if (seeAll) t("an", "on") else t("aus", "off")), Modifier.fillMaxWidth(), size = 14.sp) {
            de.bornim.core.Game.seeAll = !de.bornim.core.Game.seeAll
            seeAll = de.bornim.core.Game.seeAll
            vm.refresh()
            vm.toast = if (seeAll) t("Kein Nebel, keine Sichtlinie: alle Monster der Karte sind zu sehen. Erkundet wird wie sonst.", "No fog, no line of sight: every monster on the map shows.") else t("Sichtlinie und Nebel wieder wie im Spiel.", "Line of sight and fog back as in the game.")
        }
        PixelButton(t("Bosse zurücksetzen (Krogg, Grak)", "Respawn bosses (Krogg, Grak)"), Modifier.fillMaxWidth(), size = 14.sp) {
            game.cheatRespawnBosses()
            vm.refresh()
            vm.toast = t("Krogg und Grak sind zurück in der Höhle.", "Krogg and Grak are back in the cave.")
        }

        Spacer(Modifier.height(4.dp))
        Txt(t("Teleport", "Teleport"), size = 16.sp, bold = true)
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            val places = listOf(
                t("Dorf", "Village") to Place("village", 11, 7, Facing.DOWN),
                t("Wald", "Forest") to Place("forest", 10, 20, Facing.UP),
                t("Höhle", "Cave") to Place("cave", 10, 18, Facing.UP),
            )
            for ((label, place) in places) {
                PixelButton(label, Modifier.weight(1f), size = 14.sp) {
                    game.cheatWarp(place)
                    vm.menuOpen = false
                    vm.refresh()
                }
            }
        }
        // 100: straight to the end of chapter 1, to test the temple scene without playing it through
        PixelButton(t("Kapitel 1 bis kurz vor Ende", "Chapter 1 to just before its end"), Modifier.fillMaxWidth(), size = 14.sp) {
            game.cheatChapterEnd()
            vm.menuOpen = false
            vm.refresh()
            vm.toast = t("Höhle geschafft, Lyra frei, Amulett in der Tasche: sprich mit Aldric.", "Cave cleared, Lyra free, the amulet in your bag: talk to Aldric.")
        }

        Spacer(Modifier.height(4.dp))
        Txt(t("Kampfhilfen", "Fight aids"), size = 16.sp, bold = true)
        var failSaves by remember { mutableStateOf(de.bornim.core.Battle.foesFailSaves) }
        PixelButton(t("Gegner bestehen keine Rettungswürfe: ", "Foes fail every save: ") + (if (failSaves) t("an", "on") else t("aus", "off")), Modifier.fillMaxWidth(), size = 14.sp) {
            de.bornim.core.Battle.foesFailSaves = !de.bornim.core.Battle.foesFailSaves
            failSaves = de.bornim.core.Battle.foesFailSaves
            vm.toast = if (failSaves) t("Untote vertreiben, Heilige Flamme und Co. gelingen jetzt immer.", "Turn Undead, Sacred Flame and the like now always work.") else t("Rettungswürfe wieder normal.", "Saves back to normal.")
        }
        var crits by remember { mutableStateOf(de.bornim.core.Battle.heroCritsAlways) }
        PixelButton(t("Held trifft immer kritisch: ", "Hero always crits: ") + (if (crits) t("an", "on") else t("aus", "off")), Modifier.fillMaxWidth(), size = 14.sp) {
            de.bornim.core.Battle.heroCritsAlways = !de.bornim.core.Battle.heroCritsAlways
            crits = de.bornim.core.Battle.heroCritsAlways
            vm.toast = if (crits) t("Jeder Waffentreffer ist kritisch: so lässt sich der Killerschlag testen.", "Every weapon hit is critical: to test the killing blow.") else t("Kritische Treffer wieder normal.", "Critical hits back to normal.")
        }

        Spacer(Modifier.height(4.dp))
        // 218: monsters can be fought or brought beside the hero, hence both
        Txt(t("Monster/Kampf beschwören", "Summon monster/fight"), size = 16.sp, bold = true)
        val variantLabel = when (variant) {
            0 -> t("Normal", "Normal")
            7 -> t("Schimmernd", "Shimmering")
            else -> "Elite: " + EliteTrait.entries[variant - 1].adjective(lang, Gender.M)
        }
        PixelButton(t("Variante", "Variant") + ": $variantLabel  ›", Modifier.fillMaxWidth(), size = 14.sp) {
            variant = (variant + 1) % 8
        }
        // who strikes first: as usual, the foe from hiding, or the hero
        val openingLabel = when (opening) {
            Opening.NORMAL -> t("Normal", "Normal")
            Opening.AMBUSHED -> t("Hinterhalt (Gegner zuerst)", "Ambush (foe first)")
            Opening.HERO_FIRST -> t("Held zuerst", "Hero first")
        }
        PixelButton(t("Eröffnung", "Opening") + ": $openingLabel  ›", Modifier.fillMaxWidth(), size = 14.sp) {
            opening = Opening.entries[(opening.ordinal + 1) % Opening.entries.size]
        }
        PixelButton(if (showMonsters) t("Monsterliste schließen", "Hide monsters") else t("Monster wählen …", "Choose monster..."), Modifier.fillMaxWidth(), size = 14.sp) {
            showMonsters = !showMonsters
        }
        if (showMonsters) {
            PixelButton(t("Antippen: ", "Tap: ") + (if (bring) t("neben den Helden holen", "bring beside the hero") else t("Kampf starten", "start a fight")), Modifier.fillMaxWidth(), size = 14.sp) {
                bring = !bring
            }
            fun fight(id: String, boss: Boolean, kit: Int?) {
                if (bring) {
                    vm.menuOpen = false
                    val n = game.cheatBring(listOf(id), calmMs = 120_000)
                    vm.refresh()
                    vm.toast = if (n > 0) t("In der Nähe, 2 Minuten friedlich (auch Rudel).", "Nearby, peaceful for 2 minutes (packs too).") else t("Hier ist kein Platz.", "No room here.")
                    return
                }
                val trait = if (variant in 1..6 && !boss) EliteTrait.entries[variant - 1] else null
                vm.menuOpen = false
                game.cheatFight(id, trait, variant == 7 && !boss, opening, kit)
                vm.refresh()
            }
            Monsters.all.chunked(2).forEach { pair ->
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    pair.forEach { m ->
                        PixelButton(m.name(lang) + if (m.boss) " ★" else "", Modifier.weight(1f), size = 13.sp) { fight(m.id, m.boss, null) }
                    }
                    if (pair.size == 1) Spacer(Modifier.weight(1f))
                }
            }
            // foes with several kits: each one on its own, named by what it carries
            for (m in Monsters.all.filter { MonsterKits.variants(it.id) > 0 }) {
                Txt(m.name(lang) + " – " + t("mit Ausrüstung", "with kit"), size = 13.sp)
                for (k in 0 until MonsterKits.variants(m.id)) {
                    val kit = MonsterKits.of(m.id, k)!!
                    val label = listOf(GearSlot.MAIN_HAND, GearSlot.OFF_HAND, GearSlot.HEAD).mapNotNull { kit.items[it]?.let(::gearName) }.joinToString(", ")
                    PixelButton(label, Modifier.fillMaxWidth(), size = 12.sp) { fight(m.id, m.boss, k) }
                }
            }
        }

        Spacer(Modifier.height(4.dp))
        Txt(t("MARS-Probekampf", "MARS trial fight"), size = 16.sp, bold = true)
        // 72.10: MARS, the new fight; hero and a Söldner of the chosen class against Grak, both on level 3 (72.10a.10)
        Txt(t("MARS: Held und Söldner gegen ", "MARS: hero and Söldner against ") + probeFoeName(vm.probeFoe, lang), size = 14.sp)
        PixelButton(t("Gegner wechseln  ›", "Change foes  ›"), Modifier.fillMaxWidth(), size = 14.sp) {
            val all = de.bornim.core.Skirmish.Companion.ProbeFoe.entries
            vm.probeFoe = all[(vm.probeFoe.ordinal + 1) % all.size]
        }
        // 259: light fights need the hero 4 levels above the foes; wolves and goblins are 1/4, so 5 is light, 8 halves the damage, 11 takes none
        PixelButton(t("Stufe Held und Söldner: ", "Level hero and Söldner: ") + vm.probeLevel + "  ›", Modifier.fillMaxWidth(), size = 14.sp) {
            val all = listOf(de.bornim.core.Skirmish.PROBE_LEVEL, 5, 6, 8, 11)
            vm.probeLevel = all[(all.indexOf(vm.probeLevel) + 1) % all.size]
        }
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            for (c in CharClass.entries) PixelButton(c.title(lang), Modifier.weight(1f), size = 12.sp) {
                vm.menuOpen = false
                vm.startProbe(c)
            }
        }

        Spacer(Modifier.height(4.dp))
        Txt(t("Beute erzeugen", "Create loot"), size = 16.sp, bold = true)
        Rarity.entries.chunked(3).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                row.forEach { r ->
                    PixelButton(r.title(lang), Modifier.weight(1f), size = 12.sp) {
                        val g = game.cheatLoot(r)
                        vm.refresh()
                        vm.toast = t("Erhalten: ", "Received: ") + g.name(lang)
                    }
                }
            }
        }
    }
}

/** 266: what the device is (model, processor, graphics, memory, screen, warmth) with the [readings] above, to copy into a report. */
@Composable
private fun DeviceBox(vm: GameViewModel, t: (String, String) -> String, readings: List<String>) {
    val clip = androidx.compose.ui.platform.LocalClipboardManager.current
    var open by remember { mutableStateOf(false) }
    val all = if (open) (runCatching { de.bornim.game.DeviceInfo.lines() }.getOrElse { mapOf("Fehler" to "$it") }
        .map { (k, v) -> "$k: $v" } + readings).joinToString("\n") else ""
    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        PixelButton(if (open) t("Gerät schließen", "Hide device") else t("Gerät zeigen …", "Show device ..."), Modifier.weight(2f), size = 14.sp) { open = !open }
        if (open) PixelButton(t("Kopieren", "Copy"), Modifier.weight(1f), size = 14.sp) {
            clip.setText(androidx.compose.ui.text.AnnotatedString(all))
            vm.toast = t("Geräteangaben kopiert.", "Device details copied.")
        }
    }
    if (open) Txt(all, size = 11.sp)
}

/** 30.1: the last crash, why the system ended the app, and errors caught in the background; each to copy. */
@Composable
private fun CrashBox(vm: GameViewModel, t: (String, String) -> String) {
    val clip = androidx.compose.ui.platform.LocalClipboardManager.current
    var crash by remember { mutableStateOf(de.bornim.game.CrashLog.lastCrash) }
    val exit = de.bornim.game.CrashLog.lastExit
    val caught = de.bornim.core.Guard.caught.get()
    val caughtText = de.bornim.game.CrashLog.caught()
    var open by remember { mutableStateOf(false) }
    Txt(t("Letztes Ende der App: ", "Last end of the app: ") + (exit?.lineSequence()?.first() ?: "–"), size = 13.sp)
    Txt(t("Letzter Absturz: ", "Last crash: ") + (crash?.lineSequence()?.firstOrNull { it.startsWith("Zeit:") }?.removePrefix("Zeit: ") ?: "–") +
        t("  ·  abgefangen seit Start: ", "  ·  caught since start: ") + caught, size = 13.sp)
    // 227: the report folded (a recursion's hundreds of equal lines once, "… n× gleich"), so its caller stays in view;
    // "Kopieren" beside the switch at the top, not under the long stack
    val all = if (open) de.bornim.core.CrashText.fold(buildString {
        append("Ende laut System:\n").append(exit ?: "–").append("\n\n")
        append("Letzter Absturz:\n").append(crash ?: "–").append("\n\n")
        append("Abgefangen (neueste zuletzt):\n").append(caughtText ?: "–")
    }) else ""
    if (crash != null || exit != null || caughtText != null) {
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            PixelButton(if (open) t("Absturzbericht schließen", "Hide crash report") else t("Absturzbericht zeigen …", "Show crash report ..."), Modifier.weight(2f), size = 14.sp) { open = !open }
            if (open) PixelButton(t("Kopieren", "Copy"), Modifier.weight(1f), size = 14.sp) {
                clip.setText(androidx.compose.ui.text.AnnotatedString(all))
                vm.toast = t("Absturzbericht kopiert.", "Crash report copied.")
            }
        }
    }
    if (open) {
        Txt(all.take(3000) + if (all.length > 3000) "\n…" else "", size = 10.sp)
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            PixelButton(t("Vergessen", "Forget"), Modifier.weight(1f), size = 14.sp) {
                de.bornim.game.CrashLog.clearCrash()
                de.bornim.game.CrashLog.clearCaught()
                crash = null
                open = false
            }
        }
    }
}
