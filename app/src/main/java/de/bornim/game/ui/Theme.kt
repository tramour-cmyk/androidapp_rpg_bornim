package de.bornim.game.ui

import android.graphics.Bitmap
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.FilterQuality
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.art.PixelImage
import de.bornim.game.R

val PixelFont = FontFamily(
    Font(R.font.jersey10, FontWeight.Normal),
)

/**
 * 60b: the serif of the black screens (text box, shop, menus). [choice] picks among the free fonts on trial,
 * 0 is the device's serif as before; [scale] evens out their sizes, as some are small on the line.
 */
object TypeLook {
    var choice = 2
    val names = listOf("Gerät (Serif)", "EB Garamond", "Alegreya", "IM Fell English")
    private val families by lazy {
        listOf(
            FontFamily.Serif,
            FontFamily(Font(R.font.ebgaramond_regular, FontWeight.Normal), Font(R.font.ebgaramond_semibold, FontWeight.SemiBold)),
            FontFamily(Font(R.font.alegreya_regular, FontWeight.Normal), Font(R.font.alegreya_semibold, FontWeight.SemiBold)),
            FontFamily(Font(R.font.imfell_regular, FontWeight.Normal)),
        )
    }
    private val scales = listOf(1f, 1.1f, 1.04f, 1.08f)
    val serif: FontFamily get() = families[choice]
    val scale: Float get() = scales[choice]

    /** 60.4: the face of the title: 0 the serif in capitals, 1 Cinzel, 2 the small capitals of Alegreya. */
    var title = 1
    private val titles by lazy { listOf(FontFamily(Font(R.font.cinzel_semibold, FontWeight.SemiBold)), FontFamily(Font(R.font.alegreya_sc_medium, FontWeight.Medium))) }
    val titleFace: FontFamily get() = if (title == 0) serif else titles[title - 1]
}

/** The serif of the black screens, as chosen in [TypeLook]. */
val Serif: FontFamily get() = TypeLook.serif

object Colors {
    val night = Color(0xFF1C1A2E)
    val nightLight = Color(0xFF2C2A48)
    val panel = Color(0xFFF8F4E8)
    val panelDark = Color(0xFFE4DCC8)
    val border = Color(0xFF3A4060)
    val borderLight = Color(0xFF8890B8)
    val text = Color(0xFF2A2830)
    val textDim = Color(0xFF7A7488)
    val textLight = Color(0xFFF4F0FF)
    val accent = Color(0xFFE05A3A)
    val gold = Color(0xFFF0C040)
    val hpGreen = Color(0xFF48C858)
    val hpYellow = Color(0xFFF0C030)
    val hpRed = Color(0xFFE04030)
    val sp = Color(0xFF4890F0)
    val xp = Color(0xFF40B8F0)
    val selected = Color(0xFFFFE08A)
}

/** Plays the button click; provided by the app root. */
val LocalClick = androidx.compose.runtime.staticCompositionLocalOf<() -> Unit> { {} }

val BaseText = TextStyle(fontFamily = PixelFont, color = Colors.text, fontSize = 18.sp)

/** Converts core pixel art to bitmaps once and keeps them. */
object Bitmaps {
    // Animated sprites create many images over time, so only the most recent ones are kept; 346: by their size, not
    // their count (400 light images of the deep forest held some 120 MB of the heap and as much again outside it)
    private val cache = de.bornim.core.art.SizedCache<PixelImage, ImageBitmap>(de.bornim.core.art.SizedCache.pictureBudget(), de.bornim.core.art.SizedCache.Companion::bytesOf)

    /** 30.2: memory short: lets go of every bitmap; made again when drawn. Main thread only. */
    fun clear() = cache.clear()

    fun of(p: PixelImage): ImageBitmap = cache.getOrPut(p) {
        Bitmap.createBitmap(p.pixels, p.width, p.height, Bitmap.Config.ARGB_8888).asImageBitmap()
    }
}

/** A pixel image; [flash] > 0 paints it towards white (a crumbling undead), [hurt] > 0 darkens it towards blood red (a hit). */
@Composable
fun PixelImageView(image: PixelImage, size: Dp, modifier: Modifier = Modifier, alpha: Float = 1f, flash: Float = 0f, shade: Color? = null, hurt: Float = 0f) {
    Image(
        bitmap = Bitmaps.of(image),
        contentDescription = null,
        modifier = modifier.size(size),
        alpha = alpha,
        filterQuality = FilterQuality.None,
        colorFilter = when {
            flash > 0f -> ColorFilter.tint(Color.White.copy(alpha = flash.coerceIn(0f, 1f)), BlendMode.SrcAtop)
            // evening and night light on sprites, darkened towards blood red where struck
            shade != null || hurt > 0f -> ColorFilter.tint(hurtTint(shade, hurt), BlendMode.Modulate)
            else -> null
        },
    )
}

/** A pixel image at [px] dp per art pixel, keeping its own aspect ratio. */
@Composable
fun PixelSprite(image: PixelImage, px: Dp, modifier: Modifier = Modifier, alpha: Float = 1f, flash: Float = 0f, shade: Color? = null, overflow: Boolean = false, hurt: Float = 0f) {
    Image(
        bitmap = Bitmaps.of(image),
        contentDescription = null,
        // with [overflow], drawn at its full size from its top left corner even where it is wider than the room around it
        // (a foe's frame leaves space for its lunge and is wider than the scene): never squeezed, so feet and body stay put
        modifier = (if (overflow) modifier.wrapContentSize(Alignment.TopStart, unbounded = true) else modifier).size(px * image.width, px * image.height),
        alpha = alpha,
        filterQuality = FilterQuality.None,
        colorFilter = when {
            flash > 0f -> ColorFilter.tint(Color.White.copy(alpha = flash.coerceIn(0f, 1f)), BlendMode.SrcAtop)
            shade != null || hurt > 0f -> ColorFilter.tint(hurtTint(shade, hurt), BlendMode.Modulate)
            else -> null
        },
    )
}

/** The light on a sprite ([shade], or none), darkened towards blood red by [hurt] (0..1): the shading stays. */
private fun hurtTint(shade: Color?, hurt: Float): Color {
    val s = shade ?: Color.White
    val h = hurt.coerceIn(0f, 1f)
    return Color(s.red * (1f - 0.2f * h), s.green * (1f - 0.42f * h), s.blue * (1f - 0.42f * h), 1f)
}

/**
 * 59: inside a window in the look of the text box (42b, the black screens): black, a thin gold rim, off-white serif.
 * [Txt], [Panel], [PixelButton] and [GearIcon] turn dark by themselves, so the details and lists need no copy of their own.
 */
val LocalVeil = androidx.compose.runtime.staticCompositionLocalOf { false }

/** The ink of the black screens (as the text box); the light colors of the panels map onto it. */
object Veil {
    val text = Color(0xFFE6DDCB)
    val dim = Color(0xFF948A78)
    val gold = Color(0xFFB59A6A)
    /** 60.4: the title's gold, brighter than the headings. */
    val bright = Color(0xFFD9BC82)
    val rim = Color(0xAAB59A6A)
    /** 326: rims, rules and rings of the player's menu, a muted gold that does not read grey on black; the chosen one [gold]. */
    val line = Color(0xFF9A8155)
    val warn = Color(0xFFD9785A)
    val good = Color(0xFF86C46E)
    val raised = Color(0xFF17140F)

    /** A color meant for the light panels, as it reads on black: rarities lightened, text off-white. */
    fun of(c: Color): Color = when (c) {
        Colors.text -> text
        Colors.textDim -> dim
        Colors.textLight -> text // D2.6: no cold white on black
        Colors.accent -> warn
        Colors.border -> gold // the dark blue of notes (a people's gift), unreadable on black
        Color(0xFF5E5E68) -> Color(0xFFBDB6A8) // common
        Color(0xFF2A8A3A) -> good // uncommon, better
        Color(0xFF2A62C8) -> Color(0xFF82AAF2) // rare, affixes
        Color(0xFF7A38C0) -> Color(0xFFBC8EF2) // very rare
        Color(0xFFD0680A) -> Color(0xFFF29E50) // epic
        Color(0xFFB08800) -> Color(0xFFEAC650) // divine
        else -> c
    }
}

@Composable
fun Txt(
    text: String,
    modifier: Modifier = Modifier,
    size: TextUnit = 18.sp,
    color: Color = Colors.text,
    bold: Boolean = false,
    align: TextAlign? = null,
    maxLines: Int = Int.MAX_VALUE,
    pixel: Boolean = false,
    /** 2923: figures of one width, so the numbers of a fight stand still as they change. */
    tabular: Boolean = false,
) {
    // 60c: [pixel] keeps the pixel font for the small numbers of a fight (hit points, level), also on black
    // 326: on black a heading is gold spaced capitals, and no writing is smaller than 13 sp
    if (LocalVeil.current && !pixel && bold && size.value >= 15f && color == Colors.text) { MenuHead(text, modifier); return }
    val size = if (LocalVeil.current && !pixel && size.value < 13.7f) 13.7.sp else size
    if (LocalVeil.current && !pixel) {
        Text(
            text = text,
            modifier = modifier,
            // lining figures: Alegreya and Fell draw old-style ones by default, uneven in a column of values
            style = TextStyle(fontFamily = Serif, fontFeatureSettings = if (tabular) "lnum, tnum" else "lnum"),
            fontSize = size * 0.95f * TypeLook.scale,
            color = Veil.of(color),
            fontWeight = if (bold) FontWeight.SemiBold else FontWeight.Normal,
            letterSpacing = 0.2.sp,
            textAlign = align,
            maxLines = maxLines,
            overflow = androidx.compose.ui.text.style.TextOverflow.Ellipsis, // D2.8: cut text ends in "…"
            lineHeight = size * 1.35f,
        )
        return
    }
    Text(
        text = text,
        modifier = modifier,
        style = LocalTextStyle.current.merge(BaseText),
        fontSize = size * 1.3f, // Jersey 10 is a compact font
        color = if (LocalVeil.current) Veil.of(color) else color,
        fontWeight = FontWeight.Normal,
        letterSpacing = if (bold) 0.5.sp else 0.3.sp,
        textAlign = align,
        maxLines = maxLines,
        overflow = androidx.compose.ui.text.style.TextOverflow.Ellipsis,
        lineHeight = size * 1.5f,
    )
}

/** A heading in the black windows: small, spaced capitals in gold, as the speaker in the text box. */
@Composable
fun VeilHead(text: String, modifier: Modifier = Modifier, color: Color = Veil.gold) {
    Text(text.uppercase(), modifier, color = color, style = TextStyle(fontFamily = Serif, fontSize = 12.sp * TypeLook.scale, letterSpacing = 3.sp))
}

/** The classic double-bordered text box. */
@Composable
fun Panel(modifier: Modifier = Modifier, background: Color = Colors.panel, content: @Composable BoxScope.() -> Unit) {
    if (LocalVeil.current) {
        Box(modifier.background(Color.Black).border(1.dp, Veil.line).padding(horizontal = 14.dp, vertical = 10.dp), content = content)
        return
    }
    Box(
        modifier
            .clip(RoundedCornerShape(8.dp))
            .background(Colors.border)
            .padding(3.dp)
            .clip(RoundedCornerShape(6.dp))
            .background(Colors.borderLight)
            .padding(2.dp)
            .clip(RoundedCornerShape(5.dp))
            .background(background)
            .padding(horizontal = 12.dp, vertical = 10.dp),
        content = content,
    )
}

@Composable
fun PixelButton(
    label: String,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    selected: Boolean = false,
    size: TextUnit = 18.sp,
    /** 204: a long press, for a short explanation of the button; it works on a grey button too. */
    onLongClick: (() -> Unit)? = null,
    /** 211: the MARS fight's main orders stand a little taller. */
    height: Dp = 48.dp,
    /** 326: the label's color on black when enabled, e.g. gold for the hero's plus; null: the text color. */
    ink: Color? = null,
    onClick: () -> Unit,
) {
    val click = LocalClick.current
    if (LocalVeil.current) {
        Box(
            modifier
                .height(height)
                .background(if (selected) Veil.raised else Color.Black)
                .border(if (selected) 1.5.dp else 1.dp, if (!enabled) Veil.dim.copy(alpha = 0.4f) else if (selected) Veil.bright else Veil.line)
                .press(enabled, { click(); onClick() }, onLongClick)
                .padding(horizontal = 6.dp),
            contentAlignment = Alignment.Center,
        ) {
            val u = label.uppercase()
            // a word is never broken (60, test 0.1.650: „TASC HE“ in the menu tabs): smaller until it fits
            var shrink by remember(u, size) { mutableStateOf(1f) }
            Text(
                u, color = if (!enabled) Veil.dim.copy(alpha = 0.6f) else if (selected) Veil.bright else ink ?: Veil.text,
                style = TextStyle(fontFamily = Serif, fontSize = (size.value * 0.7f).coerceAtLeast(13f).sp * TypeLook.scale * shrink, letterSpacing = 1.2.sp * shrink, fontFeatureSettings = "lnum"), textAlign = TextAlign.Center,
                maxLines = if (' ' in u) 2 else 1, softWrap = ' ' in u,
                onTextLayout = { r ->
                    val broken = r.hasVisualOverflow || (1 until r.lineCount).any { r.getLineStart(it) in 1..u.length && u[r.getLineStart(it) - 1] != ' ' }
                    if (broken && shrink > 0.55f) shrink *= 0.9f
                },
            )
        }
        return
    }
    val bg = when {
        !enabled -> Colors.panelDark
        selected -> Colors.selected
        else -> Colors.panel
    }
    Box(
        modifier
            .height(48.dp)
            .clip(RoundedCornerShape(8.dp))
            .border(3.dp, Colors.border, RoundedCornerShape(8.dp))
            .background(bg)
            .press(enabled, { click(); onClick() }, onLongClick)
            .padding(horizontal = 10.dp),
        contentAlignment = Alignment.Center,
    ) {
        Txt(
            label,
            size = size,
            color = if (enabled) Colors.text else Colors.textDim,
            bold = true,
            align = TextAlign.Center,
            maxLines = 2,
        )
    }
}

/** A tap, and with [onLongClick] also a long press, which a grey button takes as well (204). */
@OptIn(ExperimentalFoundationApi::class)
private fun Modifier.press(enabled: Boolean, onClick: () -> Unit, onLongClick: (() -> Unit)?): Modifier =
    if (onLongClick == null) clickable(enabled = enabled, onClick = onClick)
    else combinedClickable(onLongClick = onLongClick) { if (enabled) onClick() }

@Composable
fun Bar(fraction: Float, color: Color, modifier: Modifier = Modifier, height: Dp = 8.dp) {
    Box(
        modifier
            .height(height)
            .clip(RoundedCornerShape(1.dp))
            .background(Color(0xFF2A251D)) // D2.6: a warm dark track, not grey
            .padding(1.dp)
    ) {
        Box(
            Modifier
                .fillMaxWidth(fraction.coerceIn(0f, 1f))
                .height(height)
                .clip(RoundedCornerShape(1.dp))
                .background(color)
        )
    }
}

fun hpColor(fraction: Float): Color = when {
    fraction > 0.5f -> Colors.hpGreen
    fraction > 0.2f -> Colors.hpYellow
    else -> Colors.hpRed
}

/** Clickable without ripple, for full-area taps. */
@Composable
fun Modifier.tap(onClick: () -> Unit): Modifier {
    val source = remember { MutableInteractionSource() }
    return this.clickable(interactionSource = source, indication = null, onClick = onClick)
}
