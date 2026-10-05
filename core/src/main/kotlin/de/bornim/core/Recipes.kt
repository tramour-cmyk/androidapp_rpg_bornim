package de.bornim.core

/** A potion Hedda brews from ingredients and a little gold. */
class Recipe(val output: String, val ingredients: Map<String, Int>, val gold: Int) {
    fun affordable(s: GameState): Boolean = s.gold >= gold && ingredients.all { (id, n) -> s.count(id) >= n }

    /** "2× Heilkräuter, 5 Gold". */
    fun cost(lang: Lang): String =
        (ingredients.map { (id, n) -> "$n× ${Items[id].name(lang)}" } + (if (gold > 0) listOf("$gold Gold") else emptyList())).joinToString(", ")
}

object Recipes {
    val all = listOf(
        Recipe("potion", mapOf("herbs" to 2), 5),
        Recipe("remedy", mapOf("herbs" to 2), 2),
        Recipe("greater_potion", mapOf("herbs" to 3, "bat_wing" to 1), 15),
        Recipe("alchemist_fire", mapOf("spider_gland" to 1), 5),
    )
}
