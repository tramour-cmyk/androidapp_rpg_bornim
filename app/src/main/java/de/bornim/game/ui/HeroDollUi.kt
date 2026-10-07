package de.bornim.game.ui

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import de.bornim.core.Hero
import de.bornim.core.art.HeroPortrait
import de.bornim.core.art.PixelImage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.withContext

/**
 * The hero as the doll, slowly turning round; a tap turns it on by hand. The sides are drawn in the background and
 * shown as they come; [key] changes whenever the look or what is worn changes. [fill] draws every people as large,
 * else true to scale.
 */
@Composable
fun HeroTurntable(hero: Hero, key: Any, px: Dp, modifier: Modifier = Modifier, fill: Boolean = true) {
    var side by remember(key) { mutableIntStateOf(0) }
    val last = remember(key) { arrayOfNulls<PixelImage>(1) }
    var drawn by remember(key) { mutableIntStateOf(0) }
    LaunchedEffect(key) {
        withContext(Dispatchers.Default) {
            for (y in HeroPortrait.YAWS) {
                if (!isActive) return@withContext
                HeroPortrait.render(hero, y, fill)
                drawn++
            }
        }
    }
    LaunchedEffect(key) {
        while (true) {
            // a full turn in about six seconds
            delay(250)
            side = (side + 1) % HeroPortrait.YAWS.size
        }
    }
    // the side wanted if it is drawn, else the nearest one before it that is
    val want = HeroPortrait.YAWS.indices.map { (side - it).mod(HeroPortrait.YAWS.size) }
    drawn.hashCode()
    val shown = want.firstNotNullOfOrNull { HeroPortrait.ready(hero, HeroPortrait.YAWS[it], fill) } ?: last[0]
    last[0] = shown
    Box(modifier.size(px * HeroPortrait.W, px * HeroPortrait.H).tap { side = (side + 3) % HeroPortrait.YAWS.size }, contentAlignment = Alignment.Center) {
        shown?.let { PixelSprite(it, px) }
    }
}

/** The hero as the doll, standing still and turned half towards us; drawn in the background, the space kept until then. */
@Composable
fun HeroStill(hero: Hero, key: Any, px: Dp, modifier: Modifier = Modifier, yaw: Double = HeroPortrait.YAWS[0]) {
    var img by remember(key) { androidx.compose.runtime.mutableStateOf(HeroPortrait.ready(hero, yaw)) }
    LaunchedEffect(key) {
        if (img == null) img = withContext(Dispatchers.Default) { HeroPortrait.render(hero, yaw) }
    }
    Box(modifier.size(px * HeroPortrait.W, px * HeroPortrait.H), contentAlignment = Alignment.Center) {
        img?.let { PixelSprite(it, px) }
    }
}
