package de.bornim.game.ui

import de.bornim.core.Items
import de.bornim.core.Lang
import de.bornim.core.Skill
import de.bornim.core.T

/** 204: what a long press on a button of the MARS fight says (Homer's text, 204T). */
object MarsTips {
    val attack = T("Ein Schlag oder Schuss mit der Waffe. Nahkampf erreicht nur die vordere Reihe, solange dort jemand steht.",
        "One blow or shot with your weapon. Melee reaches only the front row while anyone stands there.")
    val skills = T("Zauber und Fähigkeiten deiner Klasse. Zauber kosten Zauberpunkte, manches geht nur einmal pro Kampf oder bis zur Rast.",
        "Your class's spells and abilities. Spells cost spell points; some things work only once per battle or until you rest.")
    val bag = T("Ein Heiltrank aus dem gemeinsamen Vorrat, für dich oder einen Freund. Kostet den Zug.",
        "A healing potion from the shared stock, for you or a friend. Costs your turn.")
    // (72.10a.8: half a turn; the weapon switch of .11 comes with its build)
    val place = T("Mit einem Freund tauschen oder auf einen freien Platz gehen. Hinten bist du gedeckt, solange vorn ein Freund steht. Ein halber Zug: danach bleibt noch ein Schlag.",
        "Swap with a friend or move to a free place. At the back you are covered while a friend stands in front. Half a turn: one blow remains after it.")
    val merc = T("Auto: der Söldner kämpft selbst. Selbst: du gibst ihm jeden Befehl.", "Auto: the Söldner fights on their own. Manual: you give every order.")
    val autopilot = T("Spielt deinen Helden: Waffe, Zaubertricks, Heilung für einen schwachen Freund. Fängt den Ring immer gut, nie perfekt. Hält an unter einem Drittel der Lebenspunkte und bei einer starken Absicht; nie gegen Bosse.",
        "Plays your hero: weapon, cantrips, healing for a weak friend. Always meets the ring with good, never perfect. Stops below a third of life points and on a strong intent; never against bosses.")
    private val wounds = T("Auch für einen Freund, über alle Reihen.", "Also for a friend, across all rows.")
    private val potion = T("Heilt 2W4+2 TP.", "Heals 2d4+2 HP.")

    /** 210: what a long press on a foe's intent says (Homer's text, 210T); none yet, then the press does nothing. */
    private val intents: Map<String, T> = emptyMap()

    /** 210: the hero's insight in the log at an intent's first sight (210T). */
    private val insights: Map<String, T> = emptyMap()

    fun intent(id: String, lang: Lang): String? = intents[id]?.invoke(lang)
    fun insight(id: String, lang: Lang): String? = insights[id]?.invoke(lang)

    /** A skill: its description, and for some a word on how it works in MARS. */
    fun skill(s: Skill, lang: Lang): String = s.desc(lang) + if (s == Skill.CURE_WOUNDS) "\n" + wounds(lang) else ""

    /** A potion: its description, and the healing where the description does not name it. */
    fun item(id: String, lang: Lang): String = Items[id].desc(lang) + if (id == "potion") "\n" + potion(lang) else ""
}
