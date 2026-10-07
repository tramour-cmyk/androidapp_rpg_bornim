package de.bornim.game.ui

import android.graphics.Bitmap
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
    // Animated sprites create many images over time, so only the most recent ones are kept.
    private val cache = object : LinkedHashMap<PixelImage, ImageBitmap>(64, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<PixelImage, ImageBitmap>?) = size > 400
    }

    fun of(p: PixelImage): ImageBitmap = cache.getOrPut(p) {
        Bitmap.createBitmap(p.pixels, p.width, p.height, Bitmap.Config.ARGB_8888).asImageBitmap()
    }
}

/** A pixel image; [flash] > 0 paints it towards white (hit flash). */
@Composable
fun PixelImageView(image: PixelImage, size: Dp, modifier: Modifier = Modifier, alpha: Float = 1f, flash: Float = 0f, shade: Color? = null) {
    Image(
        bitmap = Bitmaps.of(image),
        contentDescription = null,
        modifier = modifier.size(size),
        alpha = alpha,
        filterQuality = FilterQuality.None,
        colorFilter = when {
            flash > 0f -> ColorFilter.tint(Color.White.copy(alpha = flash.coerceIn(0f, 1f)), BlendMode.SrcAtop)
            // evening and night light on sprites
            shade != null -> ColorFilter.tint(shade, BlendMode.Modulate)
            else -> null
        },
    )
}

/** A pixel image at [px] dp per art pixel, keeping its own aspect ratio. */
@Composable
fun PixelSprite(image: PixelImage, px: Dp, modifier: Modifier = Modifier, alpha: Float = 1f, flash: Float = 0f, shade: Color? = null, overflow: Boolean = false) {
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
            shade != null -> ColorFilter.tint(shade, BlendMode.Modulate)
            else -> null
        },
    )
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
) {
    Text(
        text = text,
        modifier = modifier,
        style = LocalTextStyle.current.merge(BaseText),
        fontSize = size * 1.3f, // Jersey 10 is a compact font
        color = color,
        fontWeight = FontWeight.Normal,
        letterSpacing = if (bold) 0.5.sp else 0.3.sp,
        textAlign = align,
        maxLines = maxLines,
        lineHeight = size * 1.5f,
    )
}

/** The classic double-bordered text box. */
@Composable
fun Panel(modifier: Modifier = Modifier, background: Color = Colors.panel, content: @Composable BoxScope.() -> Unit) {
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
    onClick: () -> Unit,
) {
    val click = LocalClick.current
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
            .clickable(enabled = enabled) {
                click()
                onClick()
            }
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

@Composable
fun Bar(fraction: Float, color: Color, modifier: Modifier = Modifier, height: Dp = 8.dp) {
    Box(
        modifier
            .height(height)
            .clip(RoundedCornerShape(3.dp))
            .background(Color(0xFF404048))
            .padding(1.dp)
    ) {
        Box(
            Modifier
                .fillMaxWidth(fraction.coerceIn(0f, 1f))
                .height(height)
                .clip(RoundedCornerShape(2.dp))
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
