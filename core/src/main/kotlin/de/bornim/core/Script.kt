package de.bornim.core

/** Commands that story scripts are made of. The game controller runs them in order. */
sealed interface Cmd {
    /** A line of dialogue. "{name}" in the text is replaced with the hero's name. */
    data class Say(val speaker: T?, val text: T) : Cmd
    data class SetFlag(val flag: String) : Cmd
    data class Give(val item: String, val count: Int = 1) : Cmd
    data class Take(val item: String, val count: Int = 1) : Cmd
    data class GiveGold(val amount: Int) : Cmd
    /** Starts a battle. The rest of the script only runs if the hero wins; [winFlag] is set on victory. */
    data class Fight(val monster: String, val winFlag: String? = null) : Cmd
    data class OpenShop(val stock: List<String>) : Cmd
    /** Full heal and makes the current spot the respawn point. */
    data object Rest : Cmd
    data object ChapterEnd : Cmd
}

class ScriptBuilder {
    val cmds = mutableListOf<Cmd>()
    fun say(speaker: T?, de: String, en: String) { cmds += Cmd.Say(speaker, T(de, en)) }
    fun narrate(de: String, en: String) { cmds += Cmd.Say(null, T(de, en)) }
    fun flag(f: String) { cmds += Cmd.SetFlag(f) }
    fun give(item: String, count: Int = 1) { cmds += Cmd.Give(item, count) }
    fun take(item: String, count: Int = 1) { cmds += Cmd.Take(item, count) }
    fun gold(n: Int) { cmds += Cmd.GiveGold(n) }
    fun fight(monster: String, winFlag: String? = null) { cmds += Cmd.Fight(monster, winFlag) }
    fun shop(stock: List<String>) { cmds += Cmd.OpenShop(stock) }
    fun rest() { cmds += Cmd.Rest }
    fun chapterEnd() { cmds += Cmd.ChapterEnd }
}

fun script(block: ScriptBuilder.() -> Unit): List<Cmd> = ScriptBuilder().apply(block).cmds
