package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Game
import de.bornim.core.Gear
import de.bornim.core.Items
import de.bornim.core.Rarity
import de.bornim.core.Recipe
import de.bornim.core.Recipes
import de.bornim.core.Lang
import de.bornim.core.Story
import de.bornim.core.Ui
import de.bornim.core.art.IconArt
import de.bornim.game.GameViewModel

@Composable
fun ShopScreen(vm: GameViewModel, game: Game, stock: List<String>, brewing: Boolean = false) {
    vm.tick
    val lang = vm.lang
    var buying by remember { mutableStateOf(true) }
    var brewTab by remember { mutableStateOf(false) }
    var message by remember { mutableStateOf<String?>(null) }
    var dialog by remember { mutableStateOf<DialogSpec?>(null) }
    val de = lang == Lang.DE
    fun close() {
        game.advance()
        vm.refresh()
    }
    val back = { if (dialog != null) dialog = null else close() }
    BackHandler { back() }

    androidx.compose.foundation.layout.Box(Modifier.fillMaxSize()) {
    Column(
        Modifier
            .fillMaxSize()
            .padding(10.dp)
    ) {
        Panel(Modifier.fillMaxWidth()) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Txt(Ui.shop(lang), Modifier.weight(1f), size = 22.sp, bold = true)
                Txt("${game.state.gold} G", size = 20.sp, bold = true, color = Colors.accent)
            }
        }
        Spacer(Modifier.height(8.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            PixelButton(Ui.buy(lang), Modifier.weight(1f), selected = buying && !brewTab) { buying = true; brewTab = false }
            PixelButton(Ui.sell(lang), Modifier.weight(1f), selected = !buying && !brewTab) { buying = false; brewTab = false }
            if (brewing) PixelButton(if (de) "Brauen" else "Brew", Modifier.weight(1f), selected = brewTab) { brewTab = true }
        }
        Spacer(Modifier.height(8.dp))
        Panel(
            Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            Column(Modifier.verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                val cancel = if (de) "Abbrechen" else "Cancel"
                fun goldLine(price: Int, buy: Boolean): @Composable () -> Unit = {
                    val gold = game.state.gold
                    val ok = !buy || gold >= price
                    Spacer(Modifier.height(8.dp))
                    Txt("${Ui.gold(lang)}: $gold → ${if (buy) gold - price else gold + price}", size = 15.sp, color = if (ok) Colors.textDim else Colors.accent)
                    if (!ok) Txt(Ui.notEnoughGold(lang), size = 15.sp, color = Colors.accent)
                }
                if (brewTab) {
                    BrewList(game, lang) { r ->
                        val out = Items[r.output]
                        dialog = DialogSpec(
                            title = out.name(lang), icon = out.icon, titleColor = rarityColor(out.rarity),
                            confirm = if (de) "Brauen" else "Brew", cancel = cancel, confirmEnabled = r.affordable(game.state),
                            onConfirm = {
                                message = game.brew(r)
                                vm.refresh()
                            },
                        ) {
                            ItemDetails(out, lang)
                            Spacer(Modifier.height(8.dp))
                            Txt((if (de) "Zutaten: " else "Ingredients: ") + r.cost(lang), size = 15.sp, color = if (r.affordable(game.state)) Colors.textDim else Colors.accent)
                        }
                    }
                } else {
                    // --- supplies
                    Txt(if (de) "Vorräte" else "Supplies", size = 17.sp, bold = true)
                    val supplies = if (buying) stock.map { it to null } else game.state.inventory.entries.filter { Items[it.key].sellable }.map { it.key to it.value }
                    if (supplies.isEmpty()) Txt(Ui.nothing(lang), size = 14.sp, color = Colors.textDim)
                    supplies.forEach { (id, count) ->
                        val def = Items[id]
                        val price = if (buying) def.price else game.sellPrice(id)
                        val affordable = !buying || game.state.gold >= price
                        Row(
                            Modifier
                                .fillMaxWidth()
                                .tap {
                                    val buy = buying
                                    dialog = DialogSpec(
                                        title = def.name(lang), icon = def.icon, titleColor = rarityColor(def.rarity),
                                        confirm = (if (buy) Ui.buy(lang) else Ui.sell(lang)) + " · " + Ui.price.f(lang, price),
                                        cancel = cancel, confirmEnabled = affordable,
                                        onConfirm = {
                                            message = if (buy) game.buy(id) else game.sell(id)
                                            vm.refresh()
                                        },
                                    ) {
                                        ItemDetails(def, lang)
                                        goldLine(price, buy)()
                                    }
                                }
                                .padding(vertical = 4.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            PixelImageView(IconArt.get(def.icon), 36.dp)
                            Spacer(Modifier.width(8.dp))
                            Column(Modifier.weight(1f)) {
                                Txt(def.name(lang) + (count?.let { "  ×$it" } ?: ""), size = 16.sp, bold = true, color = if (affordable) rarityColor(def.rarity) else Colors.textDim)
                                Txt(def.stats(lang), size = 12.sp, color = Colors.textDim)
                                val owned = game.state.count(id)
                                if (buying && owned > 0) Txt((if (de) "Im Besitz: " else "Owned: ") + owned, size = 12.sp, color = Colors.textDim)
                            }
                            Txt(Ui.price.f(lang, price), Modifier.width(72.dp), size = 16.sp, bold = true, align = TextAlign.End)
                        }
                    }
                    // --- equipment (Hedda trades only in herbs and potions)
                    if (!(brewing && buying)) {
                        Spacer(Modifier.height(8.dp))
                        val gear = if (buying) game.shopGear()
                        else game.state.bag.sortedWith(compareByDescending<Gear> { it.rarity }.thenBy { it.slot.ordinal })
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Txt((if (de) "Ausrüstung" else "Equipment") + " (${gear.size})", Modifier.weight(1f), size = 17.sp, bold = true)
                            if (!buying && gear.any { it.rarity == Rarity.COMMON }) {
                                PixelButton(if (de) "Gewöhnliche verkaufen" else "Sell commons", Modifier.height(36.dp), size = 13.sp) {
                                    val n = game.sellAllCommon()
                                    message = if (de) "$n gewöhnliche Gegenstände verkauft." else "Sold $n common items."
                                    vm.refresh()
                                }
                            }
                        }
                        if (buying) Txt(if (de) "Neue Ware nach jeweils 8 Siegen." else "New stock every 8 victories.", size = 12.sp, color = Colors.textDim)
                        if (gear.isEmpty()) Txt(Ui.nothing(lang), size = 14.sp, color = Colors.textDim)
                        gear.forEach { g ->
                            val price = if (buying) g.price else game.sellPrice(g)
                            GearRow(g, lang, game, vm.tick, trailing = Ui.price.f(lang, price)) {
                                val buy = buying
                                dialog = DialogSpec(
                                    title = g.name(lang), icon = g.def.icon, titleColor = rarityColor(g.rarity),
                                    confirm = (if (buy) Ui.buy(lang) else Ui.sell(lang)) + " · " + Ui.price.f(lang, price),
                                    cancel = cancel, confirmEnabled = !buy || game.state.gold >= price,
                                    onConfirm = {
                                        message = if (buy) game.buyGear(g) else game.sellGear(g)
                                        vm.refresh()
                                    },
                                ) {
                                    GearDetails(g, game, lang)
                                    goldLine(price, buy)()
                                }
                            }
                        }
                    }
                }
            }
        }
        Spacer(Modifier.height(8.dp))
        message?.let { Panel(Modifier.fillMaxWidth()) { Txt(it, size = 15.sp) } }
        Spacer(Modifier.height(8.dp))
        BackRow(Ui.close(lang)) { back() }
    }
    dialog?.let { ConfirmDialog(it) { dialog = null } }
    }
}

/** Hedda's recipes with what the hero has of each ingredient. */
@Composable
private fun BrewList(game: Game, lang: Lang, onPick: (Recipe) -> Unit) {
    val de = lang == Lang.DE
    Txt(if (de) "Heddas Rezepte" else "Hedda's recipes", size = 17.sp, bold = true)
    Txt(
        if (de) "Kräuter wachsen auf Blumenwiesen im Wald – einfach darüberlaufen." else "Herbs grow in the forest's flower meadows – just walk over them.",
        size = 12.sp, color = Colors.textDim,
    )
    Recipes.all.forEach { r ->
        val out = Items[r.output]
        val ok = r.affordable(game.state)
        Row(
            Modifier
                .fillMaxWidth()
                .tap { onPick(r) }
                .padding(vertical = 4.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            PixelImageView(IconArt.get(out.icon), 36.dp)
            Spacer(Modifier.width(8.dp))
            Column(Modifier.weight(1f)) {
                Txt(out.name(lang), size = 16.sp, bold = true, color = if (ok) rarityColor(out.rarity) else Colors.textDim)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    r.ingredients.forEach { (id, n) ->
                        val have = game.state.count(id)
                        PixelImageView(IconArt.get(Items[id].icon), 18.dp)
                        Txt(" $have/$n  ", size = 12.sp, bold = true, color = if (have >= n) Colors.text else Colors.accent)
                    }
                    if (r.gold > 0) Txt("${r.gold} G", size = 12.sp, bold = true, color = if (game.state.gold >= r.gold) Colors.text else Colors.accent)
                }
            }
        }
    }
}

@Composable
fun ChapterEndScreen(vm: GameViewModel, game: Game) {
    vm.tick
    val lang = vm.lang
    Column(
        Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(Modifier.height(24.dp))
        Txt(Ui.title(lang), size = 28.sp, bold = true, color = Colors.gold, align = TextAlign.Center)
        Spacer(Modifier.height(16.dp))
        Panel(
            Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            Column(Modifier.verticalScroll(rememberScrollState())) {
                Txt(Story.chapterEndText(lang), size = 18.sp)
                Spacer(Modifier.height(12.dp))
                val h = game.hero
                Txt("${h.name} · ${h.race.title(lang)} · ${h.cls.title(lang)} · ${Ui.level(lang)} ${h.level}", size = 15.sp, bold = true)
            }
        }
        Spacer(Modifier.height(12.dp))
        PixelButton(Ui.next(lang), Modifier.fillMaxWidth()) {
            game.advance()
            vm.save()
            vm.refresh()
        }
    }
}
