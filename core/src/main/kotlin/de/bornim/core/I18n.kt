package de.bornim.core

import kotlinx.serialization.Serializable

@Serializable
enum class Lang { DE, EN }

/** A text in both supported languages. Placeholders are written as {0}, {1}, ... */
data class T(val de: String, val en: String) {
    operator fun invoke(lang: Lang): String = if (lang == Lang.DE) de else en

    fun f(lang: Lang, vararg args: Any): String {
        var s = invoke(lang)
        args.forEachIndexed { i, a -> s = s.replace("{$i}", a.toString()) }
        return s
    }
}

/** UI texts shared between screens. Story texts live in [Story]. */
object Ui {
    const val copyright = "© WireStormTCS/rahasof 2026"
    val title = T("Chroniken von Bornim", "Chronicles of Bornim")
    val subtitle = T("Kapitel 1: Der Blutzahn-Stamm", "Chapter 1: The Bloodfang Tribe")
    val newGame = T("Neues Spiel", "New Game")
    val continueGame = T("Fortsetzen", "Continue")
    val language = T("Sprache: Deutsch", "Language: English")
    val musicOn = T("Musik: An", "Music: On")
    val musicOff = T("Musik: Aus", "Music: Off")
    val sfxOn = T("Effekte: An", "Sound FX: On")
    val sfxOff = T("Effekte: Aus", "Sound FX: Off")
    val controlsTouch = T("Steuerung: Touch", "Controls: Touch")
    val controlsClassic = T("Steuerung: Steuerkreuz", "Controls: D-pad")
    val actionRight = T("Aktionstaste: rechts", "Action button: right")
    val actionLeft = T("Aktionstaste: links", "Action button: left")
    val hapticsOn = T("Vibration: An", "Vibration: On")
    val hapticsOff = T("Vibration: Aus", "Vibration: Off")
    val touchHint = T(
        "Ziehen zum Laufen (weit ziehen = rennen), Tippen zum Hinlaufen. Tippe auf Personen oder Truhen, um sie direkt anzusprechen oder zu öffnen.",
        "Drag to walk (drag far to run), tap to walk there. Tap people or chests to talk to them or open them right away.",
    )
    val about = T("Über das Spiel", "About")
    val back = T("Zurück", "Back")
    val next = T("Weiter", "Next")
    val start = T("Abenteuer beginnen", "Begin adventure")
    val yourName = T("Name deines Helden", "Your hero's name")
    val chooseRace = T("Wähle dein Volk", "Choose your race")
    val chooseClass = T("Wähle deine Klasse", "Choose your class")
    val summary = T("Dein Held", "Your hero")
    val defaultName = T("Alrik", "Alric")

    val menu = T("Menü", "Menu")
    val hero = T("Held", "Hero")
    val bag = T("Tasche", "Bag")
    val equipment = T("Ausrüstung", "Equipment")
    val gearShort = T("Ausrüst.", "Gear")
    val system = T("System", "System")
    val save = T("Speichern", "Save")
    val saved = T("Spielstand gespeichert.", "Game saved.")
    val toTitle = T("Zum Titelbild", "Title screen")
    val close = T("Schließen", "Close")
    val quest = T("Auftrag", "Quest")

    val level = T("Stufe", "Level")
    val xp = T("EP", "XP")
    val hp = T("TP", "HP")
    val sp = T("ZP", "SP")
    val ac = T("RK", "AC")
    val gold = T("Gold", "Gold")
    val proficiency = T("Übungsbonus", "Proficiency")
    val attack = T("Angriff", "Attack")
    val damage = T("Schaden", "Damage")
    val points = T("Attributspunkte: {0}", "Ability points: {0}")
    val raise = T("+", "+")
    val skills = T("Fähigkeiten", "Abilities")
    val passive = T("passiv", "passive")
    val unlimited = T("∞", "∞")
    val fromLevel = T("ab Stufe {0}", "from level {0}")
    val traits = T("Merkmal", "Trait")
    val hitDie = T("Trefferwürfel", "Hit die")
    val primary = T("Hauptattribut", "Primary ability")
    val armorProf = T("Rüstung", "Armor")

    val use = T("Benutzen", "Use")
    val equip = T("Anlegen", "Equip")
    val unequip = T("Ablegen", "Unequip")
    val equipped = T("angelegt", "equipped")
    val empty = T("— leer —", "— empty —")
    val nothing = T("Nichts", "Nothing")
    val cannotEquipArmor = T("Mit dieser Rüstung bist du nicht vertraut.", "You are not proficient with this armor.")
    val cannotUseHere = T("Das kannst du hier nicht benutzen.", "You can't use that here.")
    val alreadyFull = T("Deine TP sind bereits voll.", "Your HP are already full.")

    val fight = T("Kampf", "Fight")
    val flee = T("Flucht", "Run")
    val whatWillDo = T("Was wird {0} tun?", "What will {0} do?")
    val cost = T("Kosten", "Cost")
    val usesLeft = T("{0}/{1}", "{0}/{1}")

    val shop = T("Laden", "Shop")
    val buy = T("Kaufen", "Buy")
    val sell = T("Verkaufen", "Sell")
    val price = T("{0} G", "{0} G")
    val notEnoughGold = T("Du hast nicht genug Gold.", "You don't have enough gold.")
    val bought = T("{0} gekauft.", "Bought {0}.")
    val sold = T("{0} verkauft.", "Sold {0}.")
    val cannotSell = T("Das kann nicht verkauft werden.", "That can't be sold.")

    val nothingHere = T("Hier ist nichts.", "There's nothing here.")
    val chestEmpty = T("Die Truhe ist leer.", "The chest is empty.")
    val found = T("Erhalten: {0}!", "Received: {0}!")
    val foundGold = T("Erhalten: {0} Gold!", "Received: {0} gold!")
    val rested = T("Du rastest am Feuer. TP und ZP sind vollständig wiederhergestellt.", "You rest by the fire. HP and SP are fully restored.")

    val aboutText = T(
        "Ein Fan-Rollenspiel im Stil klassischer Handheld-RPGs.\n\nRegeln, Klassen, Völker, Zauber und Monster sind vereinfacht und basieren auf dem System Reference Document 5.1 (SRD 5.1) von Wizards of the Coast LLC, verfügbar unter https://dnd.wizards.com/resources/systems-reference-document. Das SRD 5.1 ist lizenziert unter der Creative Commons Namensnennung 4.0 International (https://creativecommons.org/licenses/by/4.0/legalcode).\n\nGeschichte, Orte und Figuren sind eigene Erfindungen.",
        "A fan role-playing game in the style of classic handheld RPGs.\n\nRules, classes, races, spells and monsters are simplified and based on the System Reference Document 5.1 (SRD 5.1) by Wizards of the Coast LLC, available at https://dnd.wizards.com/resources/systems-reference-document. The SRD 5.1 is licensed under the Creative Commons Attribution 4.0 International License (https://creativecommons.org/licenses/by/4.0/legalcode).\n\nThe story, places and characters are original."
    )
}
