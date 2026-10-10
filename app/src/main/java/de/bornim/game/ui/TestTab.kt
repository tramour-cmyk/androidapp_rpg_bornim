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
    var showWeapons by remember { mutableStateOf(false) }
    var opening by remember { mutableStateOf(Opening.NORMAL) }
    fun gearName(id: String) = GearBases[id].let { if (german) it.de else it.en }

    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Txt(t("Testmodus", "Test mode"), size = 18.sp, bold = true)

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
        PixelButton(t("Wetterleuchten mit Donner (draußen)", "Sheet lightning with thunder (outdoors)"), Modifier.fillMaxWidth(), size = 14.sp) {
            game.cheatFlash()
            vm.refresh()
            vm.toast = t("Das Wetterleuchten kommt, sobald die Karte wieder läuft.", "The lightning comes as soon as the map runs again.")
        }
        // to test Garrick nodding off (10.10., 3a); to be removed again
        var doze by remember { mutableStateOf(de.bornim.core.art.MapFolk.forceDoze) }
        PixelButton(t("Garrick döst jetzt: ", "Garrick dozes now: ") + (if (doze) t("an", "on") else t("aus", "off")), Modifier.fillMaxWidth(), size = 14.sp) {
            de.bornim.core.art.MapFolk.forceDoze = !de.bornim.core.art.MapFolk.forceDoze
            doze = de.bornim.core.art.MapFolk.forceDoze
        }
        PixelButton(t("Alle Vorräte auf mindestens 10", "All supplies to at least 10"), Modifier.fillMaxWidth(), size = 14.sp) {
            game.cheatSupplies(10)
            vm.refresh()
            vm.toast = t("Tränke, Flaschen, Essen und Zutaten aufgefüllt.", "Draughts, flasks, food and ingredients filled up.")
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
        PixelButton(t("Wolfsrudel und Goblin mit Späher herholen", "Bring a wolf pack and a goblin with its scout"), Modifier.fillMaxWidth(), size = 14.sp) {
            val n = game.cheatBringPacks()
            vm.refresh()
            vm.toast = if (n > 0) t("In der Nähe: ein Wolfsrudel und ein Goblin mit Späher.", "Nearby: a wolf pack and a goblin with its scout.") else t("Hier ist kein Platz für sie.", "No room for them here.")
        }
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
        // the diagonal view while it is being built (13): straight or turned by 45°
        var diagonal by remember { mutableStateOf(MapSight.diagonal) }
        PixelButton(t("Sicht: ", "View: ") + (if (diagonal) t("diagonal (im Bau)", "diagonal (being built)") else t("gerade", "straight")), Modifier.fillMaxWidth(), size = 14.sp) {
            MapSight.diagonal = !MapSight.diagonal
            diagonal = MapSight.diagonal
            vm.refresh()
            vm.toast = if (diagonal) t("Karte diagonal: Wirtshaus zuerst, alles andere noch mit den alten Bildern.", "Map diagonal: the inn first, all else still with the former pictures.") else t("Karte wieder gerade.", "Map straight again.")
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
        // the village and the rooms in the new style are drafts (night of 09.10.): to look at on the phone
        var town by remember { mutableStateOf(de.bornim.core.art.MapGround.townDraft) }
        PixelButton(t("Dorf und Räume: ", "Village and rooms: ") + (if (town) t("Entwurf neuer Stil", "draft new style") else t("bisher", "former")), Modifier.fillMaxWidth(), size = 14.sp) {
            de.bornim.core.art.MapGround.townDraft = !de.bornim.core.art.MapGround.townDraft
            town = de.bornim.core.art.MapGround.townDraft
            game.state.place.let { p -> de.bornim.core.art.MapGround.prepare(de.bornim.core.World[p.map], p.x, p.y) }
            vm.refresh()
            vm.toast = if (town) t("Dorf und Innenräume im Entwurf des neuen Stils.", "Village and rooms in the draft of the new style.") else t("Dorf und Innenräume wieder wie bisher.", "Village and rooms as before.")
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

        Spacer(Modifier.height(4.dp))
        Txt(t("Kampf auslösen", "Start a fight"), size = 16.sp, bold = true)
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
        PixelButton(if (showMonsters) t("Monsterliste schließen", "Hide monsters") else t("Monster wählen …", "Choose monster..."), Modifier.fillMaxWidth(), size = 14.sp) {
            showMonsters = !showMonsters
        }
        if (showMonsters) {
            fun fight(id: String, boss: Boolean, kit: Int?) {
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
