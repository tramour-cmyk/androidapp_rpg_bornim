package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.size
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import de.bornim.core.GearSlot
import de.bornim.core.GearCompare
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

/** 59 Händler: the shop in the look of the text box (in the game since 59d, 12.10.); what the preview opens on. */
object ShopLook {
    /** Preview only: the tab to open on (0 buy, 1 sell, 2 sell with things to buy back) and a dialog (gear index, 100 supply, 101 sell all of a supply). */
    @Volatile var previewTab = 0
    @Volatile var previewDialog = -1
}

@Composable
fun ShopScreen(vm: GameViewModel, game: Game, stock: List<String>, brewing: Boolean = false) {
    androidx.compose.runtime.CompositionLocalProvider(LocalVeil provides true) {
        androidx.compose.foundation.layout.Box(Modifier.fillMaxSize().background(Color.Black)) { ShopBody(vm, game, stock, brewing) }
    }
}

@Composable
private fun ShopBody(vm: GameViewModel, game: Game, stock: List<String>, brewing: Boolean) {
    vm.tick
    val lang = vm.lang
    val veil = LocalVeil.current
    var buying by remember { mutableStateOf(ShopLook.previewTab == 0) }
    var brewTab by remember { mutableStateOf(false) }
    var message by remember { mutableStateOf<String?>(null) }
    var dialog by remember { mutableStateOf<DialogSpec?>(null) }
    // 59.5: a supply being bought or sold, with how many; its window is made anew as the number changes
    var supply by remember { mutableStateOf<String?>(null) }
    var amount by remember { mutableStateOf(1) }
    val de = lang == Lang.DE
    val cancel = if (de) "Abbrechen" else "Cancel"
    fun close() {
        game.advance()
        vm.refresh()
    }
    val back = { if (dialog != null || supply != null) { dialog = null; supply = null } else close() }
    BackHandler { back() }

    @Composable
    fun goldLine(price: Int, buy: Boolean) {
        val gold = game.state.gold
        val ok = !buy || gold >= price
        Spacer(Modifier.height(8.dp))
        Txt("${Ui.gold(lang)}: $gold → ${if (buy) gold - price else gold + price}", size = 15.sp, color = if (ok) Colors.textDim else Colors.accent)
        if (!ok) Txt(Ui.notEnoughGold(lang), size = 15.sp, color = Colors.accent)
    }
    fun gearDialog(g: Gear, buy: Boolean) {
        val price = if (buy) game.buyPrice(g) else game.sellPrice(g)
        dialog = DialogSpec(
            title = g.name(lang), icon = g.def.icon, gear = g, titleColor = rarityColor(g.rarity),
            confirm = (if (buy) Ui.buy(lang) else Ui.sell(lang)) + " · " + Ui.price.f(lang, price),
            cancel = cancel, confirmEnabled = !buy || game.state.gold >= price,
            onConfirm = {
                fun deal() {
                    message = if (buy) game.buyGear(g) else game.sellGear(g)
                    vm.refresh()
                }
                // 59e: selling something rare or better asks once more (switch "Safety questions" in the menu)
                if (buy || g.rarity < Rarity.RARE || !vm.confirmations) deal()
                else dialog = DialogSpec(
                    title = if (de) "Wirklich verkaufen?" else "Really sell?", titleColor = rarityColor(g.rarity),
                    confirm = Ui.sell(lang) + " · " + Ui.price.f(lang, price), cancel = cancel, onConfirm = { deal() },
                ) {
                    Txt(g.name(lang) + " (" + g.rarity.title(lang) + ")", size = 15.sp, bold = true, color = rarityColor(g.rarity))
                }
            },
        ) {
            GearDetails(g, game, lang)
            goldLine(price, buy)
        }
    }
    /** What is worn, to look at (59.2): the details without a price. */
    fun wornDialog(g: Gear) {
        dialog = DialogSpec(title = g.name(lang), icon = g.def.icon, gear = g, titleColor = rarityColor(g.rarity),
            confirm = "OK", cancel = "", onConfirm = {}) { GearDetails(g, game, lang) }
    }

    @Composable
    fun heading(text: String, modifier: Modifier = Modifier) {
        if (veil) VeilHead(text, modifier.padding(top = 6.dp, bottom = 2.dp)) else Txt(text, modifier, size = 17.sp, bold = true)
    }

    @Composable
    fun gearList(gear: List<Gear>, buy: Boolean) {
        // 59.2: what the hero can wear first; the rest below in a block of its own, dimmed and marked
        val (wearable, not) = gear.partition { game.hero.canWear(it) }
        wearable.forEach { g ->
            GearRow(g, lang, game, vm.tick, trailing = Ui.price.f(lang, if (buy) game.buyPrice(g) else game.sellPrice(g))) { gearDialog(g, buy) }
        }
        if (not.isNotEmpty()) {
            Spacer(Modifier.height(6.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                NoEntry(14.dp)
                Spacer(Modifier.width(6.dp))
                heading((if (de) "Nicht tragbar" else "Can't wear") + " (${not.size})")
            }
            not.forEach { g ->
                androidx.compose.foundation.layout.Box(Modifier.alpha(0.5f)) {
                    GearRow(g, lang, game, vm.tick, trailing = Ui.price.f(lang, if (buy) game.buyPrice(g) else game.sellPrice(g))) { gearDialog(g, buy) }
                    NoEntry(16.dp, Modifier.padding(start = 28.dp, top = 28.dp))
                }
            }
        }
    }

    androidx.compose.foundation.layout.Box(Modifier.fillMaxSize()) {
    Column(
        Modifier
            .fillMaxSize()
            .padding(10.dp)
    ) {
        Panel(Modifier.fillMaxWidth()) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                // D2.12: Morwen's hut is no shop
                val head = if (brewing) (if (de) "Morwens Hütte" else "Morwen's hut") else Ui.shop(lang)
                if (veil) VeilHead(head, Modifier.weight(1f))
                else Txt(head, Modifier.weight(1f), size = 22.sp, bold = true)
                Txt("${game.state.gold} G", size = 20.sp, bold = true, color = if (veil) Veil.gold else Colors.accent)
            }
        }
        Spacer(Modifier.height(8.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            PixelButton(Ui.buy(lang), Modifier.weight(1f), selected = buying && !brewTab) { buying = true; brewTab = false }
            PixelButton(Ui.sell(lang), Modifier.weight(1f), selected = !buying && !brewTab) { buying = false; brewTab = false }
            if (brewing) PixelButton(if (de) "Brauen" else "Brew", Modifier.weight(1f), selected = brewTab) { brewTab = true }
        }
        Spacer(Modifier.height(8.dp))
        // 59.2: when selling, the nine worn pieces in a strip above, to see what is better at a glance
        if (!buying && !brewTab && !brewing) {
            Panel(Modifier.fillMaxWidth()) {
                Column {
                    heading(if (de) "Angelegt" else "Worn")
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        val hero = game.hero
                        listOf(GearSlot.HEAD, GearSlot.CLOAK, GearSlot.CHEST, GearSlot.ARMS, GearSlot.LEGS, GearSlot.AMULET, GearSlot.RING, GearSlot.MAIN_HAND, GearSlot.OFF_HAND).forEach { slot ->
                            val twoHanded = slot == GearSlot.OFF_HAND && hero.weapon?.def?.twoHanded == true
                            val g = if (twoHanded) hero.weapon else hero.item(slot)
                            GearIcon(g, 34.dp, Modifier.alpha(if (twoHanded) 0.5f else 1f).tap { g?.let { wornDialog(it) } })
                        }
                    }
                }
            }
            Spacer(Modifier.height(8.dp))
        }
        Panel(
            Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            Column(Modifier.verticalScroll(rememberScrollState()), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                if (brewTab) {
                    BrewList(game, lang) { r ->
                        val out = Items[r.output]
                        dialog = DialogSpec(
                            title = out.name(lang), icon = out.icon, supply = out.id, titleColor = rarityColor(out.rarity),
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
                    // --- 59.4: buy back what was sold in this visit, for what it fetched
                    if (!buying && game.buyback.isNotEmpty()) {
                        heading(if (de) "Zurückkaufen" else "Buy back")
                        game.buyback.toList().forEach { s ->
                            val ok = game.state.gold >= s.price
                            Row(
                                Modifier.fillMaxWidth().tap { message = game.buyBack(s); vm.refresh() }.padding(vertical = 4.dp),
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                if (s.gear != null) GearIcon(s.gear, 42.dp) else SupplyPicture(s.item!!, 36.dp)
                                Spacer(Modifier.width(8.dp))
                                Txt(s.name(lang), Modifier.weight(1f), size = 16.sp, bold = true,
                                    color = if (ok) rarityColor(s.gear?.rarity ?: Items[s.item!!].rarity) else Colors.textDim, maxLines = 2)
                                Txt(Ui.price.f(lang, s.price), Modifier.width(76.dp), size = 15.sp, bold = true, align = TextAlign.End)
                            }
                        }
                        Spacer(Modifier.height(8.dp))
                    }
                    // --- supplies
                    heading(if (de) "Vorräte" else "Supplies")
                    val supplies = if (buying) stock.map { it to null } else game.state.inventory.entries.filter { Items[it.key].sellable }.map { it.key to it.value }
                    if (supplies.isEmpty()) Txt(Ui.nothing(lang), size = 14.sp, color = Colors.textDim)
                    supplies.forEach { (id, count) ->
                        val def = Items[id]
                        val price = if (buying) game.buyPrice(id) else game.sellPrice(id)
                        val affordable = !buying || game.state.gold >= price
                        Row(
                            Modifier
                                .fillMaxWidth()
                                .tap { amount = 1; supply = id }
                                .padding(vertical = 4.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            SupplyPicture(def.id, 36.dp)
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
                    // --- equipment (Morwen trades only in herbs and potions)
                    if (!(brewing && buying)) {
                        Spacer(Modifier.height(8.dp))
                        val gear = if (buying) game.shopGear()
                        else game.state.bag.sortedWith(compareByDescending<Gear> { it.rarity }.thenBy { it.slot.ordinal })
                        heading((if (de) "Ausrüstung" else "Equipment") + " (${gear.size})")
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            if (!buying && gear.any { it.rarity == Rarity.COMMON }) {
                                PixelButton(if (de) "Gewöhnliche verkaufen" else "Sell commons", Modifier.height(36.dp), size = 13.sp) {
                                    fun sellAll() {
                                        val n = game.sellAllCommon()
                                        message = if (de) "$n gewöhnliche Gegenstände verkauft." else "Sold $n common items."
                                        vm.refresh()
                                    }
                                    val commons = gear.filter { it.rarity == Rarity.COMMON }
                                    if (!vm.confirmations) sellAll()
                                    else dialog = DialogSpec(
                                        title = if (de) "Alle gewöhnlichen verkaufen?" else "Sell all commons?",
                                        confirm = (if (de) "Verkaufen · " else "Sell · ") + Ui.price.f(lang, commons.sumOf { game.sellPrice(it) }),
                                        cancel = cancel, onConfirm = { sellAll() },
                                    ) {
                                        Txt(
                                            if (de) "${commons.size} Gegenstände:" else "${commons.size} items:",
                                            size = 15.sp, bold = true,
                                        )
                                        Txt(commons.joinToString(", ") { it.name(lang) }, size = 14.sp, color = Colors.textDim)
                                    }
                                }
                            }
                        }
                        if (buying) Txt(if (de) "Neue Ware nach jeweils 8 Siegen." else "New stock every 8 victories.", size = 12.sp, color = Colors.textDim)
                        if (gear.isEmpty()) Txt(Ui.nothing(lang), size = 14.sp, color = Colors.textDim)
                        gearList(gear, buying)
                    }
                }
            }
        }
        Spacer(Modifier.height(8.dp))
        message?.let { Panel(Modifier.fillMaxWidth()) { Txt(it, size = 15.sp) } }
        Spacer(Modifier.height(8.dp))
        BackRow(Ui.close(lang)) { back() }
    }
    // preview: open a window at once
    androidx.compose.runtime.LaunchedEffect(Unit) {
        val d = ShopLook.previewDialog
        if (d == 100) { amount = 5; supply = stock.first() }
        else if (d == 101) { amount = Int.MAX_VALUE; supply = game.state.inventory.keys.first { Items[it].sellable } }
        else if (d >= 0) (if (buying) game.shopGear() else game.state.bag)
            .filter { game.hero.canWear(it) && GearCompare.of(game.hero, it).verdict != null }.sortedByDescending { GearCompare.of(game.hero, it).verdict }.getOrNull(d)?.let { gearDialog(it, buying) }
    }
    supply?.let { id -> ConfirmDialog(supplyDialog(game, id, buying, amount, cancel, lang, onAmount = { amount = it }) { n ->
        fun deal() {
            message = if (buying) game.buy(id, n) else game.sell(id, n)
            vm.refresh()
        }
        // 59e: selling all of a supply asks once more (switch "Safety questions" in the menu)
        if (buying || amount != Int.MAX_VALUE || n < 2 || !vm.confirmations) deal()
        else dialog = DialogSpec(
            title = if (de) "Alle verkaufen?" else "Sell all?", supply = id, titleColor = rarityColor(Items[id].rarity),
            confirm = Ui.sell(lang) + " ×$n · " + Ui.price.f(lang, game.sellPrice(id) * n), cancel = cancel, onConfirm = { deal() },
        ) {
            Txt(Items[id].name(lang) + " ×$n", size = 15.sp, bold = true)
        }
    }) { supply = null } }
    dialog?.let { ConfirmDialog(it) { dialog = null } }
    }
}

/** 59.5: a supply to buy or sell, with ×1 or ×5, when selling also all of it (59e: buying "all" is gone); the price follows the number. */
private fun supplyDialog(game: Game, id: String, buy: Boolean, amount: Int, cancel: String, lang: Lang, onAmount: (Int) -> Unit, onDone: (Int) -> Unit): DialogSpec {
    val de = lang == Lang.DE
    val def = Items[id]
    val unit = if (buy) game.buyPrice(id) else game.sellPrice(id)
    val most = if (buy) game.canBuy(id) else game.state.count(id)
    val n = amount.coerceIn(1, maxOf(1, most))
    val price = unit * n
    return DialogSpec(
        title = def.name(lang), icon = def.icon, supply = def.id, titleColor = rarityColor(def.rarity),
        confirm = (if (buy) Ui.buy(lang) else Ui.sell(lang)) + (if (n > 1) " ×$n" else "") + " · " + Ui.price.f(lang, price),
        cancel = cancel, confirmEnabled = most >= 1,
        onConfirm = { onDone(n) },
    ) {
        ItemDetails(def, lang)
        Spacer(Modifier.height(10.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
            Txt(if (de) "Menge" else "Amount", Modifier.width(64.dp), size = 15.sp, color = Colors.textDim)
            (listOf(1 to "×1", 5 to "×5") + if (buy) emptyList() else listOf(Int.MAX_VALUE to (if (de) "Alle" else "All"))).forEach { (k, label) ->
                val pick = if (k == Int.MAX_VALUE) most else k
                // "All" stays marked as such (it asks once more), even when it is 1 or 5
                val on = if (amount == Int.MAX_VALUE) k == Int.MAX_VALUE else k != Int.MAX_VALUE && n == pick
                PixelButton(label, Modifier.weight(1f).height(40.dp), enabled = pick in 1..most, selected = on, size = 15.sp) { onAmount(k) }
            }
        }
        val gold = game.state.gold
        val ok = !buy || gold >= price
        Spacer(Modifier.height(8.dp))
        Txt((if (de) "Im Besitz: " else "Owned: ") + game.state.count(id) + " → " + (game.state.count(id) + if (buy) n else -n), size = 15.sp, color = Colors.textDim)
        Txt("${Ui.gold(lang)}: $gold → ${if (buy) gold - price else gold + price}", size = 15.sp, color = if (ok) Colors.textDim else Colors.accent)
        if (most < 1) Txt(if (buy) Ui.notEnoughGold(lang) else Ui.nothing(lang), size = 15.sp, color = Colors.accent)
    }
}

/** 59.2: the mark of what the hero can't wear, a ring with a bar across, drawn so it looks the same on every phone. */
@Composable
private fun NoEntry(size: androidx.compose.ui.unit.Dp, modifier: Modifier = Modifier) {
    val c = if (LocalVeil.current) Veil.warn else Colors.accent
    androidx.compose.foundation.Canvas(modifier.size(size)) {
        val w = this.size.minDimension * 0.14f
        drawCircle(Color.Black.copy(alpha = 0.6f), radius = this.size.minDimension / 2)
        drawCircle(c, radius = this.size.minDimension / 2 - w / 2, style = androidx.compose.ui.graphics.drawscope.Stroke(w))
        val r = this.size.minDimension / 2 - w
        val o = r * 0.7071f
        drawLine(c, center.copy(x = center.x - o, y = center.y - o), center.copy(x = center.x + o, y = center.y + o), strokeWidth = w)
    }
}

/** Morwen's recipes with what the hero has of each ingredient. */
@Composable
private fun BrewList(game: Game, lang: Lang, onPick: (Recipe) -> Unit) {
    val de = lang == Lang.DE
    // D2.12: a heading like the other parts of the shop
    val head = if (de) "Morwens Rezepte" else "Morwen's recipes"
    if (LocalVeil.current) VeilHead(head, Modifier.padding(top = 6.dp, bottom = 2.dp)) else Txt(head, size = 17.sp, bold = true)
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
            SupplyPicture(out.id, 36.dp)
            Spacer(Modifier.width(8.dp))
            Column(Modifier.weight(1f)) {
                Txt(out.name(lang), size = 16.sp, bold = true, color = if (ok) rarityColor(out.rarity) else Colors.textDim)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    r.ingredients.forEach { (id, n) ->
                        val have = game.state.count(id)
                        SupplyPicture(id, 18.dp)
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
    // D2.1: in the look of the text box (60), black with a thin gold rim like menu and shop
    androidx.compose.runtime.CompositionLocalProvider(LocalVeil provides true) {
        androidx.compose.foundation.layout.Box(Modifier.fillMaxSize().background(Color.Black)) { ChapterEndBody(vm, game) }
    }
}

@Composable
private fun ChapterEndBody(vm: GameViewModel, game: Game) {
    vm.tick
    val lang = vm.lang
    Column(
        Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Spacer(Modifier.height(24.dp))
        Txt(Ui.title(lang), size = 28.sp, bold = true, color = Veil.bright, align = TextAlign.Center)
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
