package de.bornim.game.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.getValue
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Affix
import de.bornim.core.BaseKind
import de.bornim.core.DiceExpr
import de.bornim.core.Game
import de.bornim.core.Gear
import de.bornim.core.GearSlot
import de.bornim.core.Lang
import de.bornim.core.Rarity
import de.bornim.core.GearCompare
import de.bornim.core.Rules
import de.bornim.core.Ui
import de.bornim.core.Weight
import de.bornim.core.art.IconArt
import de.bornim.core.art.ItemArt

/** Rarity colors, dark enough to read on the light panels. */
fun rarityColor(r: Rarity): Color = when (r) {
    Rarity.COMMON -> Color(0xFF5E5E68)
    Rarity.UNCOMMON -> Color(0xFF2A8A3A)
    Rarity.RARE -> Color(0xFF2A62C8)
    Rarity.VERY_RARE -> Color(0xFF7A38C0)
    Rarity.EPIC -> Color(0xFFD0680A)
    Rarity.DIVINE -> Color(0xFFB08800)
}

/** Light background tint behind an item icon. */
private fun rarityTint(r: Rarity): Color = when (r) {
    Rarity.COMMON -> Color(0xFFE6E2D6)
    Rarity.UNCOMMON -> Color(0xFFD8EED6)
    Rarity.RARE -> Color(0xFFD6E2F6)
    Rarity.VERY_RARE -> Color(0xFFE6D8F4)
    Rarity.EPIC -> Color(0xFFF8E0C4)
    Rarity.DIVINE -> Color(0xFFFFF0B0)
}

/** Item icon in a frame colored by rarity. Empty slots show a faint placeholder. */
@Composable
fun GearIcon(g: Gear?, size: Dp, modifier: Modifier = Modifier) {
    val shape = RoundedCornerShape(6.dp)
    Box(
        modifier
            .size(size)
            .clip(shape)
            .background(g?.let { rarityTint(it.rarity) } ?: Color(0xFFDAD4C4))
            .border(if (g != null && g.rarity >= Rarity.EPIC) 3.dp else 2.dp, g?.let { rarityColor(it.rarity) } ?: Color(0xFFB8B0A0), shape),
        contentAlignment = Alignment.Center,
    ) {
        if (g != null) GearPicture(g.base, g.rarity, size * 0.78f)
        // Two-handed weapons carry a small "2H" tag, at the top: the rarity's stones sit at the foot.
        if (g != null && g.def.isWeapon && g.def.twoHanded) {
            Box(
                Modifier
                    .align(Alignment.TopEnd)
                    .padding(2.dp)
                    .clip(RoundedCornerShape(3.dp))
                    .background(Color(0xE0302838))
                    .padding(horizontal = 2.dp)
            ) { Txt("2H", size = (size.value / 5f).coerceIn(8f, 12f).sp, color = Color.White, bold = true) }
        }
    }
}

/**
 * A piece of gear as it looks when worn, built from its solids, with a stone for each step of rarity. It is drawn in
 * the background the first time; until then its old drawn icon stands in.
 */
@Composable
fun GearPicture(base: String, rarity: Rarity, size: Dp, modifier: Modifier = Modifier) {
    val img by androidx.compose.runtime.produceState(ItemArt.ready(base, rarity), base, rarity) {
        if (value == null) value = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.Default) { ItemArt.get(base, rarity) }
    }
    PixelImageView(img ?: IconArt.get(de.bornim.core.GearBases[base].icon), size, modifier)
}

/** One line in the bag or shop: icon, colored name, rarity and type, optional trailing text. */
@Composable
fun GearRow(g: Gear, lang: Lang, game: Game, revision: Int, trailing: String? = null, onClick: () -> Unit) {
    revision.hashCode() // upgrade arrows depend on what is equipped right now
    Row(
        Modifier
            .fillMaxWidth()
            .tap(onClick)
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        GearIcon(g, 42.dp)
        Spacer(Modifier.width(8.dp))
        Column(Modifier.weight(1f)) {
            Txt(g.name(lang), size = 16.sp, bold = true, color = rarityColor(g.rarity), maxLines = 2)
            val wearable = game.hero.canWear(g)
            Txt(
                g.listLine(lang) + (if (!wearable) (if (lang == Lang.DE) " · nicht tragbar" else " · can't wear") else ""),
                size = 12.sp, color = if (wearable) Colors.textDim else Colors.accent,
            )
        }
        val verdict = upgradeVerdict(g, game)
        if (verdict != null) Txt(verdict.first, Modifier.padding(horizontal = 4.dp), size = 18.sp, color = verdict.second)
        if (trailing != null) Txt(trailing, Modifier.width(76.dp), size = 15.sp, bold = true, align = TextAlign.End)
    }
}

/** ▲ green if the piece would be better all round, ▼ red if worse; nothing if mixed or no change (see [GearCompare]). */
private fun upgradeVerdict(g: Gear, game: Game): Pair<String, Color>? {
    val hero = game.hero
    if (!hero.canWear(g) || hero.gear.values.any { it.uid == g.uid }) return null
    return when (GearCompare.of(hero, g).verdict) {
        1 -> "▲" to Color(0xFF2A8A3A)
        -1 -> "▼" to Colors.accent
        else -> null
    }
}

/** Everything about a piece of gear, with a before/after comparison against what is equipped. */
@Composable
fun GearDetails(g: Gear, game: Game, lang: Lang) {
    val de = lang == Lang.DE
    val hero = game.hero
    val d = g.def
    g.kindLine(lang)?.let { Txt(it, size = 14.sp, color = rarityColor(g.rarity)) }
    // where it is worn, in red when it takes both hands (a shield has to come off)
    Txt(g.wearLine(lang) + " · " + (if (de) "Stufe " else "Level ") + g.ilvl +
        (if (d.weight != Weight.NONE) " · " + d.weight.title(lang) else ""), size = 13.sp, bold = d.isWeapon && d.twoHanded,
        color = if (d.isWeapon && d.twoHanded) Colors.accent else Colors.textDim)
    // what comes off for it: the piece in its place, and a shield for a two-handed weapon (or the other way round)
    val cmp = if (g in game.state.bag && hero.canWear(g)) GearCompare.of(hero, g) else null
    cmp?.replaced?.takeIf { it.isNotEmpty() }?.let { off ->
        val other = off.any { it.slot != d.slot }
        Txt((if (de) "Ersetzt: " else "Replaces: ") + off.joinToString(", ") { it.name(lang) }, size = 13.sp, bold = other,
            color = if (other) Colors.accent else Colors.textDim)
    }
    // the verdict at once, so it is seen without scrolling; the table below says why
    cmp?.let { c -> Txt(c.summary(lang), size = 14.sp, bold = true, color = when (c.verdict) { 1 -> Color(0xFF2A8A3A); -1 -> Colors.accent; else -> Colors.text }) }
    Spacer(Modifier.height(6.dp))
    // base numbers
    d.damage?.let { dmg ->
        val withPlus = dmg.copy(bonus = dmg.bonus + g.plus)
        Txt("${Ui.damage(lang)}: ${withPlus.label(lang)} ${d.damageType.title(lang)}", size = 16.sp, bold = true)
        d.versatile?.let { v ->
            Txt((if (de) "Mit beiden Händen (andere Hand leer): " else "In both hands (other hand empty): ") + v.copy(bonus = v.bonus + g.plus).label(lang), size = 14.sp, color = Colors.textDim)
        }
        if (g.plus > 0) Txt("${Ui.attack(lang)} +${g.plus}", size = 15.sp, bold = true)
        val traits = buildList {
            if (d.finesse) add(if (de) "Finesse" else "Finesse")
            if (d.ranged) add(if (de) "Fernkampf" else "Ranged")
        }
        if (traits.isNotEmpty()) Txt(traits.joinToString(" · "), size = 13.sp, color = Colors.textDim)
    }
    if (d.slot == GearSlot.CHEST && d.armor > 0) {
        val dex = when (d.weight) {
            Weight.LIGHT -> if (de) " + GES" else " + DEX"
            Weight.MEDIUM -> if (de) " + GES (max 2)" else " + DEX (max 2)"
            else -> ""
        }
        Txt("${Ui.ac(lang)} ${d.armor + g.plus}$dex", size = 16.sp, bold = true)
    }
    if (d.kind == BaseKind.SHIELD) Txt("${Ui.ac(lang)} +${d.armor + g.plus}", size = 16.sp, bold = true)
    if (d.focus > 0) Txt((if (de) "Zauberkraft +" else "Spell power +") + d.focus, size = 16.sp, bold = true)
    // affixes
    if (g.rolls.isNotEmpty()) Spacer(Modifier.height(4.dp))
    g.rolls.forEach { r ->
        val text = if (r.affix == Affix.ALL_STATS) "+${r.value} ${Affix.ALL_STATS.title(lang)}" else r.affix.line(lang, r.value)
        Txt(text, size = 16.sp, color = Color(0xFF2A62C8))
    }

    // warnings
    Spacer(Modifier.height(6.dp))
    when {
        !hero.canWear(g) -> Txt(if (de) "Deine Klasse kann das nicht tragen." else "Your class can't wear this.", size = 15.sp, color = Colors.accent)
        d.isWeapon && !hero.proficientWith(g) -> Txt(
            if (de) "Ungeübt: kein Übungsbonus auf Angriffe." else "Not proficient: no proficiency bonus to attacks.",
            size = 15.sp, color = Colors.accent,
        )
    }
    if (d.focus > 0 && !hero.cls.caster) Txt(if (de) "Zauberkraft nützt nur Zauberwirkern." else "Spell power only helps spellcasters.", size = 13.sp, color = Colors.textDim)

    // comparison: everything that changes, what is worn now beside what it would be, gains green and losses red
    if (cmp == null) return
    Spacer(Modifier.height(8.dp))
    Row(Modifier.fillMaxWidth()) {
        Txt(if (de) "Vergleich" else "Compare", Modifier.weight(1.8f), size = 15.sp, bold = true)
        Txt(if (de) "Angelegt" else "Worn", Modifier.weight(0.9f), size = 13.sp, color = Colors.textDim)
        Txt(if (de) "Neu" else "New", Modifier.weight(0.9f), size = 13.sp, color = Colors.textDim)
    }
    Box(Modifier.fillMaxWidth().padding(vertical = 3.dp).height(1.dp).background(Colors.textDim.copy(alpha = 0.35f)))
    val good = Color(0xFF2A8A3A)
    cmp.rows.forEach { r ->
        Row(Modifier.fillMaxWidth()) {
            Txt(r.label(lang), Modifier.weight(1.8f), size = 15.sp, maxLines = 2)
            Txt(r.before, Modifier.weight(0.9f), size = 15.sp, color = Colors.textDim)
            Txt(r.after, Modifier.weight(0.9f), size = 15.sp, bold = r.better != null,
                color = when (r.better) { true -> good; false -> Colors.accent; null -> Colors.textDim })
        }
        r.note?.let { Txt(it(lang), Modifier.padding(start = 10.dp), size = 12.sp, color = Colors.textDim) }
    }
}

/** Paper doll: the hero as the doll in the middle, slowly turning, and the nine equipment slots on both sides. */
@Composable
fun PaperDoll(game: Game, lang: Lang, revision: Int, onSlot: (GearSlot) -> Unit) {
    // The Game object never changes identity, so the revision makes Compose redraw after (un)equipping.
    revision.hashCode()
    val hero = game.hero
    val left = listOf(GearSlot.HEAD, GearSlot.CLOAK, GearSlot.CHEST, GearSlot.ARMS, GearSlot.LEGS)
    val right = listOf(GearSlot.AMULET, GearSlot.RING, GearSlot.MAIN_HAND, GearSlot.OFF_HAND)
    @Composable
    fun slotCell(slot: GearSlot) {
        // A two-handed weapon also fills the off-hand frame.
        val twoHanded = slot == GearSlot.OFF_HAND && hero.weapon?.def?.twoHanded == true
        val g = if (twoHanded) hero.weapon else hero.item(slot)
        Column(
            Modifier
                .width(78.dp)
                .tap { onSlot(if (twoHanded) GearSlot.MAIN_HAND else slot) },
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            GearIcon(g, 48.dp)
            Txt(slot.title(lang), size = 11.sp, color = Colors.textDim, maxLines = 1)
        }
    }
    // what is worn, so the doll is drawn anew after every change
    val worn = GearSlot.entries.joinToString(",") { s -> hero.item(s)?.let { "${it.base}:${it.rarity}" } ?: "-" }
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) { left.forEach { slotCell(it) } }
        HeroTurntable(hero, worn + "/" + hero.sex + hero.build + hero.skinTone + hero.hairTone, 1.1.dp)
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) { right.forEach { slotCell(it) } }
    }
}
