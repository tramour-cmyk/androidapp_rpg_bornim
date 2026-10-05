package de.bornim.game.ui

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.withFrameMillis
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.FilterQuality
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import de.bornim.core.Facing
import de.bornim.core.Game
import de.bornim.core.MapKind
import de.bornim.core.Mode
import de.bornim.core.Move
import de.bornim.core.Story
import de.bornim.core.Tile
import de.bornim.core.Route
import de.bornim.core.actionAhead
import de.bornim.core.route
import de.bornim.core.art.ActionArt
import de.bornim.core.art.CharacterArt
import de.bornim.core.art.MonsterArt
import de.bornim.core.art.PixelImage
import de.bornim.core.art.WorldArt
import de.bornim.game.GameViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlin.math.abs
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.roundToInt

@Composable
fun PlayScreen(vm: GameViewModel) {
    val game = vm.game ?: return
    vm.tick // recompose whenever the game changed
    val mode = game.mode
    when {
        mode is Mode.Fight -> BattleScreen(vm, game, mode.battle)
        mode is Mode.Shop -> ShopScreen(vm, game, mode.stock)
        mode == Mode.ChapterEnd -> ChapterEndScreen(vm, game)
        vm.menuOpen -> MenuScreen(vm, game)
        else -> WorldScreen(vm, game)
    }
}

@Composable
fun WorldScreen(vm: GameViewModel, game: Game) {
    val rev = vm.tick
    var heldDir by remember { mutableStateOf<Facing?>(null) }
    var tappedDir by remember { mutableStateOf<Facing?>(null) }
    var running by remember { mutableStateOf(false) }
    var progress by remember { mutableFloatStateOf(1f) }
    var fromX by remember { mutableIntStateOf(game.state.place.x) }
    var fromY by remember { mutableIntStateOf(game.state.place.y) }
    // A walk planned by tapping on the map.
    var route by remember { mutableStateOf<Route?>(null) }
    var routeIdx by remember { mutableIntStateOf(0) }
    val haptic = LocalHapticFeedback.current
    fun buzz() {
        if (vm.haptics) haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
    }

    val dialog = game.mode as? Mode.Dialog
    var revealed by remember(dialog) { mutableIntStateOf(0) }
    val dialogDone = dialog == null || revealed >= dialog.text.length

    fun pressA() {
        when {
            dialog != null && !dialogDone -> revealed = dialog.text.length
            dialog != null -> game.advance()
            game.mode == Mode.Explore -> {
                if (game.actionAhead() != null) buzz()
                game.interact()
            }
        }
        vm.refresh()
    }

    BackHandler { if (game.mode == Mode.Explore) vm.menuOpen = true }

    // Movement loop: grid steps with a short slide animation.
    LaunchedEffect(game) {
        var bumped: Facing? = null
        while (isActive) {
            val manual = heldDir ?: tappedDir
            tappedDir = null
            if (manual != null) route = null
            val r = route
            val routeDir = if (manual == null && r != null && routeIdx < r.steps.size) r.steps[routeIdx] else null
            val dir = manual ?: routeDir
            if (game.mode != Mode.Explore) route = null
            if (dir != null && game.mode == Mode.Explore) {
                val result = game.move(dir)
                if (result is Move.Stepped) {
                    bumped = null
                    if (routeDir != null) routeIdx++
                    // Set the animation start before redrawing, otherwise one frame shows
                    // the hero already on the target tile and it visibly jumps back.
                    fromX = result.fromX
                    fromY = result.fromY
                    progress = 0f
                    vm.refresh()
                    val duration = if (running) 110f else if (routeDir != null) 170f else 200f
                    val start = withFrameMillis { it }
                    while (progress < 1f) {
                        withFrameMillis { progress = ((it - start) / duration).coerceAtMost(1f) }
                    }
                    game.afterStep()
                    vm.refresh()
                } else {
                    if (routeDir != null) route = null
                    // One short buzz when walking into a wall, not a constant rattle.
                    if (bumped != dir && manual != null) buzz()
                    bumped = dir
                    vm.refresh()
                    delay(150)
                }
            } else if (r != null && routeIdx >= r.steps.size && game.mode == Mode.Explore) {
                // Arrived: turn towards the target and use it.
                route = null
                r.face?.let { game.face(it) }
                if (r.interact) pressA() else vm.refresh()
            } else {
                if (heldDir == null) bumped = null
                withFrameMillis { }
            }
        }
    }

    // Typewriter effect for dialog text.
    LaunchedEffect(dialog) {
        if (dialog == null) return@LaunchedEffect
        while (revealed < dialog.text.length) {
            delay(18)
            revealed++
        }
    }

    val touch = vm.touchControls
    val action = game.actionAhead()
    Column(Modifier.fillMaxSize()) {
        Box(
            Modifier
                .weight(1f)
                .fillMaxWidth()
                .clipToBounds()
                .background(Color.Black)
        ) {
            MapView(game, rev, progress, fromX, fromY, route?.target)
            if (touch) {
                TouchLayer(
                    onDir = { d -> heldDir = d },
                    onRun = { running = it },
                    onTap = { pos, w, h ->
                        if (dialog != null) {
                            pressA()
                        } else if (game.mode == Mode.Explore) {
                            val cam = camera(game, w, h, progress, fromX, fromY)
                            val tx = floor((pos.x / cam.scale + cam.x) / WorldArt.T).toInt()
                            val ty = floor((pos.y / cam.scale + cam.y) / WorldArt.T).toInt()
                            val p = game.state.place
                            if (tx == p.x && ty == p.y) {
                                pressA()
                            } else {
                                route = game.route(tx, ty)
                                routeIdx = 0
                                if (route == null) buzz()
                            }
                        }
                    },
                )
            }
            // Pass the current values: the Game object itself never changes, so Compose
            // would otherwise skip redrawing these after a heal or a map change.
            MapBanner(game.state.place.map, game.map.name(game.lang))
            HudChip(
                game.hero.hp, game.hero.maxHp, game.hero.unspentPoints,
                Modifier.align(Alignment.TopEnd).padding(8.dp),
            ) { if (game.mode == Mode.Explore) vm.menuOpen = true }
            if (touch && dialog == null && action != null) {
                ActionButton(
                    ActionArt.icon(action), 76.dp,
                    Modifier
                        .align(if (vm.leftHanded) Alignment.BottomStart else Alignment.BottomEnd)
                        .padding(22.dp),
                ) { pressed -> if (pressed) pressA() }
            }
            if (dialog != null) {
                DialogBox(
                    speaker = dialog.speaker,
                    text = dialog.text.take(revealed),
                    done = dialogDone,
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .padding(8.dp)
                        .tap { pressA() },
                )
            }
        }
        if (!touch) {
            ClassicControls(
                leftHanded = vm.leftHanded,
                action = when {
                    dialog != null -> ActionArt.icon(ActionArt.Extra.NEXT)
                    action != null -> ActionArt.icon(action)
                    else -> ActionArt.icon(ActionArt.Extra.ACT)
                },
                actionDim = dialog == null && action == null,
                onDir = { d ->
                    if (d != null && heldDir == null) tappedDir = d
                    heldDir = d
                },
                onAction = { pressA() },
                onRun = { pressed -> running = pressed },
            )
        }
    }
}

/** Where the camera is: pixel zoom and the top-left corner of the view in art pixels. */
private class Cam(val scale: Int, val x: Int, val y: Int, val heroX: Int, val heroY: Int)

private fun camera(game: Game, w: Float, h: Float, progress: Float, fromX: Int, fromY: Int): Cam {
    val map = game.map
    val T = WorldArt.T
    // Whole-number zoom so every art pixel is the same size on screen.
    val scale = max(2, floor(w / (T * 10.5f)).toInt())
    val viewW = w / scale
    val viewH = h / scale
    val p = game.state.place
    val t = if (progress < 1f) progress else 1f
    // Positions in art pixels, rounded so tiles and sprites move in lockstep.
    val heroX = ((fromX + (p.x - fromX) * t) * T).roundToInt()
    val heroY = ((fromY + (p.y - fromY) * t) * T).roundToInt()
    val mapW = map.width * T
    val mapH = map.height * T
    val camX = (if (mapW <= viewW) (mapW - viewW) / 2f else (heroX + T / 2f - viewW / 2f).coerceIn(0f, mapW - viewW)).roundToInt()
    val camY = (if (mapH <= viewH) (mapH - viewH) / 2f else (heroY + T / 2f - viewH / 2f).coerceIn(0f, mapH - viewH)).roundToInt()
    return Cam(scale, camX, camY, heroX, heroY)
}

/**
 * Touch movement: dragging shows a small joystick under the finger and walks in the dragged
 * direction (snapped to the four grid directions, far = run); a short tap reports its position.
 */
@Composable
private fun TouchLayer(onDir: (Facing?) -> Unit, onRun: (Boolean) -> Unit, onTap: (Offset, Float, Float) -> Unit) {
    var origin by remember { mutableStateOf<Offset?>(null) }
    var knob by remember { mutableStateOf(Offset.Zero) }
    var stickDir by remember { mutableStateOf<Facing?>(null) }
    val density = LocalDensity.current
    val slop = with(density) { 14.dp.toPx() }
    val runAt = with(density) { 70.dp.toPx() }
    val radius = with(density) { 46.dp.toPx() }
    Box(
        Modifier
            .fillMaxSize()
            .pointerInput(Unit) {
                awaitEachGesture {
                    val down = awaitFirstDown()
                    val start = down.position
                    val t0 = down.uptimeMillis
                    var dragging = false
                    var dir: Facing? = null
                    var last = down.uptimeMillis
                    while (true) {
                        val event = awaitPointerEvent()
                        val change = event.changes.firstOrNull { it.id == down.id } ?: break
                        last = change.uptimeMillis
                        if (!change.pressed) break
                        val d = change.position - start
                        if (!dragging && d.getDistance() > slop) {
                            dragging = true
                            origin = start
                        }
                        if (dragging) {
                            change.consume()
                            val len = d.getDistance()
                            knob = if (len > radius) d * (radius / len) else d
                            // Snap to the grid directions; the current one wins near the diagonal.
                            val ax = abs(d.x); val ay = abs(d.y)
                            val horizontal = when (dir) {
                                Facing.LEFT, Facing.RIGHT -> ax * 1.3f >= ay
                                Facing.UP, Facing.DOWN -> ax > ay * 1.3f
                                null -> ax > ay
                            }
                            val nd = if (len < slop) dir
                            else if (horizontal) (if (d.x > 0) Facing.RIGHT else Facing.LEFT)
                            else (if (d.y > 0) Facing.DOWN else Facing.UP)
                            if (nd != dir) {
                                dir = nd
                                stickDir = nd
                                onDir(nd)
                            }
                            onRun(len > runAt)
                        }
                    }
                    if (dragging) {
                        onDir(null)
                        onRun(false)
                    } else if (last - t0 < 450) {
                        onTap(start, size.width.toFloat(), size.height.toFloat())
                    }
                    origin = null
                    stickDir = null
                    knob = Offset.Zero
                }
            }
    ) {
        val o = origin
        if (o != null) {
            Canvas(Modifier.fillMaxSize()) {
                drawCircle(Color.White.copy(alpha = 0.12f), radius, o)
                drawCircle(Color.White.copy(alpha = 0.45f), radius, o, style = androidx.compose.ui.graphics.drawscope.Stroke(3.dp.toPx()))
                drawCircle(Color.White.copy(alpha = 0.7f), radius * 0.42f, o + knob)
            }
        }
    }
}

@Composable
private fun MapView(game: Game, rev: Int, progress: Float, fromX: Int, fromY: Int, marker: Pair<Int, Int>?) {
    val time = rememberTime()
    val frame = ((time / 450) % 2).toInt()
    Canvas(Modifier.fillMaxSize()) {
        rev.hashCode() // read so the canvas redraws on game changes
        val state = game.state
        val map = game.map
        val T = WorldArt.T
        val cam = camera(game, size.width, size.height, progress, fromX, fromY)
        val scale = cam.scale
        val viewW = size.width / scale
        val viewH = size.height / scale
        val p = state.place
        val heroX = cam.heroX
        val heroY = cam.heroY
        val camX = cam.x
        val camY = cam.y

        fun put(img: PixelImage, x: Int, y: Int) {
            val sx = (x - camX) * scale
            val sy = (y - camY) * scale
            if (sx > size.width || sy > size.height || sx + img.width * scale < 0 || sy + img.height * scale < 0) return
            drawImage(
                image = Bitmaps.of(img),
                srcOffset = IntOffset.Zero,
                srcSize = IntSize(img.width, img.height),
                dstOffset = IntOffset(sx, sy),
                dstSize = IntSize(img.width * scale, img.height * scale),
                filterQuality = FilterQuality.None,
            )
        }

        // 1) ground
        val x0 = floor(camX.toFloat() / T).toInt()
        val y0 = floor(camY.toFloat() / T).toInt()
        val x1 = ((camX + viewW) / T).toInt()
        val y1 = ((camY + viewH) / T).toInt()
        for (ty in y0..y1) for (tx in x0..x1) {
            if (!map.inside(tx, ty)) continue
            put(WorldArt.ground(map, tx, ty, state, frame), tx * T, ty * T)
        }

        // Target of a tapped walk: a softly pulsing frame.
        if (marker != null) {
            val pulse = 0.5f + 0.5f * kotlin.math.sin(time / 160f)
            val inset = 2f + pulse * 2f
            drawRect(
                Color.White.copy(alpha = 0.55f + 0.3f * pulse),
                Offset((marker.first * T - camX + inset) * scale, (marker.second * T - camY + inset) * scale),
                androidx.compose.ui.geometry.Size((T - 2 * inset) * scale, (T - 2 * inset) * scale),
                style = androidx.compose.ui.graphics.drawscope.Stroke(1.5f * scale),
            )
        }

        // 2) shadows under characters
        val visibleNpcs = map.npcs.filter { it.visible(state) }
        for (npc in visibleNpcs) if (!npc.look.startsWith("monster:")) put(WorldArt.shadow(), npc.x * T + 4, npc.y * T + 26)
        put(WorldArt.shadow(), heroX + 4, heroY + 26)

        // 3) objects and characters, sorted by their foot line
        val sprites = mutableListOf<Sprite>()
        for (o in WorldArt.objects(map, state, frame)) sprites += Sprite(o.sortY.toFloat()) { put(o.img, o.x, o.y) }
        for (npc in visibleNpcs) {
            val bottom = npc.y * T + T - 1
            if (npc.look.startsWith("monster:")) {
                val img = MonsterArt.get(npc.look.removePrefix("monster:"))
                sprites += Sprite(bottom.toFloat()) { put(img, npc.x * T + T / 2 - img.width / 2, bottom + 1 - img.height) }
            } else {
                val img = CharacterArt.npc(npc.look, game.npcFacing(npc))
                sprites += Sprite(bottom.toFloat()) { put(img, npc.x * T, npc.y * T - 2) }
            }
        }
        val walking = progress < 1f
        val step = if (!walking) 0 else if (state.steps % 2 == 0) 1 else 2
        val hero = CharacterArt.hero(state.hero.race, state.hero.cls, p.facing, step)
        // +0.5 so the hero is drawn after objects standing on the same row
        sprites += Sprite(heroY + T - 0.5f) {
            put(hero, heroX, heroY - 2)
            // Feet hidden in tall grass.
            if (map.tile(p.x, p.y) == Tile.TALL_GRASS && progress > 0.5f) put(WorldArt.tallGrassOverlay(), heroX, heroY)
        }
        sprites.sortBy { it.y }
        sprites.forEach { it.draw() }

        if (map.kind == MapKind.CAVE) {
            // A soft vignette around the hero, like a torch light.
            val center = Offset((heroX - camX + T / 2f) * scale, (heroY - camY + T / 2f) * scale)
            drawCircle(
                brush = androidx.compose.ui.graphics.Brush.radialGradient(
                    0.0f to Color.Transparent, 0.55f to Color.Transparent, 1f to Color(0xCC000000),
                    center = center, radius = size.maxDimension * 0.62f,
                ),
                radius = size.maxDimension * 2f, center = center,
            )
        }
    }
}

private class Sprite(val y: Float, val draw: () -> Unit)


@Composable
private fun MapBanner(mapId: String, mapName: String) {
    var visible by remember { mutableStateOf(false) }
    LaunchedEffect(mapId) {
        visible = true
        delay(2200)
        visible = false
    }
    AnimatedVisibility(visible, enter = fadeIn(), exit = fadeOut(), modifier = Modifier.padding(8.dp)) {
        Panel { Txt(mapName, size = 18.sp, bold = true) }
    }
}

@Composable
private fun HudChip(hp: Int, maxHp: Int, points: Int, modifier: Modifier, onMenu: () -> Unit) {
    Row(
        modifier
            .clip(RoundedCornerShape(8.dp))
            .background(Color(0xAA000000))
            .tap(onMenu)
            .padding(horizontal = 8.dp, vertical = 5.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(horizontalAlignment = Alignment.End) {
            Txt("$hp/$maxHp", size = 14.sp, color = Colors.textLight, bold = true)
            Bar(hp.toFloat() / maxHp, hpColor(hp.toFloat() / maxHp), Modifier.width(70.dp), 6.dp)
            if (points > 0) Txt("★ +$points", size = 12.sp, color = Colors.gold)
        }
        Spacer(Modifier.width(8.dp))
        // The bag opens the menu.
        PixelImageView(ActionArt.icon(ActionArt.Extra.MENU), 36.dp)
    }
}

@Composable
fun DialogBox(speaker: String?, text: String, done: Boolean, modifier: Modifier = Modifier) {
    val time = rememberTime()
    Column(modifier.fillMaxWidth()) {
        if (speaker != null) {
            Panel(Modifier.offset(y = 6.dp)) { Txt(speaker, size = 15.sp, bold = true, color = Colors.accent) }
        }
        Panel(
            Modifier
                .fillMaxWidth()
                .height(120.dp)
        ) {
            Txt(text, size = 18.sp)
            if (done && (time / 400) % 2 == 0L) {
                Txt("▼", Modifier.align(Alignment.BottomEnd), size = 14.sp, color = Colors.accent)
            }
        }
    }
}

/** The classic layout: D-pad on one side, action and run buttons on the other. */
@Composable
private fun ClassicControls(
    leftHanded: Boolean, action: PixelImage, actionDim: Boolean,
    onDir: (Facing?) -> Unit, onAction: () -> Unit, onRun: (Boolean) -> Unit,
) {
    Row(
        Modifier
            .fillMaxWidth()
            .background(Colors.nightLight)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween,
    ) {
        val buttons: @Composable () -> Unit = {
            Box(Modifier.size(width = 140.dp, height = 140.dp)) {
                ActionButton(ActionArt.icon(ActionArt.Extra.RUN), 58.dp,
                    Modifier.align(if (leftHanded) Alignment.BottomEnd else Alignment.BottomStart).padding(bottom = 6.dp), onPress = onRun)
                ActionButton(action, 70.dp, Modifier.align(if (leftHanded) Alignment.TopStart else Alignment.TopEnd).padding(top = 6.dp), dim = actionDim) { pressed ->
                    if (pressed) onAction()
                }
            }
        }
        if (leftHanded) {
            buttons()
            DPad(onDir)
        } else {
            DPad(onDir)
            buttons()
        }
    }
}

/** Round button showing a pixel icon; reports press and release. */
@Composable
fun ActionButton(icon: PixelImage, size: androidx.compose.ui.unit.Dp, modifier: Modifier, dim: Boolean = false, onPress: (Boolean) -> Unit) {
    var pressed by remember { mutableStateOf(false) }
    Box(
        modifier
            .size(size)
            .clip(CircleShape)
            .background(
                androidx.compose.ui.graphics.Brush.radialGradient(
                    if (pressed) listOf(Color(0xFF3A3A5A), Color(0xFF24243A)) else listOf(Color(0xFF5A5A86), Color(0xFF2E2E4A)),
                ),
            )
            .border(3.dp, if (dim) Color(0xFF3A3A50) else Colors.gold.copy(alpha = 0.85f), CircleShape)
            .pointerInput(Unit) {
                awaitEachGesture {
                    awaitFirstDown().consume()
                    pressed = true
                    onPress(true)
                    do {
                        val event = awaitPointerEvent()
                        event.changes.forEach { it.consume() }
                    } while (event.changes.any { it.pressed })
                    pressed = false
                    onPress(false)
                }
            },
        contentAlignment = Alignment.Center,
    ) { PixelImageView(icon, size * 0.55f, alpha = if (dim) 0.35f else 1f) }
}

@Composable
private fun DPad(onDir: (Facing?) -> Unit) {
    var current by remember { mutableStateOf<Facing?>(null) }
    val sizeDp = 150.dp
    Box(
        Modifier
            .size(sizeDp)
            .pointerInput(Unit) {
                fun dirFor(pos: Offset): Facing? {
                    val dx = pos.x - size.width / 2f
                    val dy = pos.y - size.height / 2f
                    if (abs(dx) < size.width * 0.1f && abs(dy) < size.height * 0.1f) return null
                    return if (abs(dx) > abs(dy)) (if (dx > 0) Facing.RIGHT else Facing.LEFT)
                    else (if (dy > 0) Facing.DOWN else Facing.UP)
                }
                awaitEachGesture {
                    val down = awaitFirstDown()
                    current = dirFor(down.position)
                    onDir(current)
                    do {
                        val event = awaitPointerEvent()
                        val change = event.changes.firstOrNull { it.pressed }
                        if (change != null) {
                            val d = dirFor(change.position)
                            if (d != current) {
                                current = d
                                onDir(d)
                            }
                        }
                    } while (event.changes.any { it.pressed })
                    current = null
                    onDir(null)
                }
            }
    ) {
        val arm = 50.dp
        val dark = Color(0xFF2A2A3A)
        val lit = Color(0xFF4A4A66)
        // vertical and horizontal bars of the cross
        Box(Modifier.align(Alignment.Center).size(arm, sizeDp).clip(RoundedCornerShape(8.dp)).background(dark))
        Box(Modifier.align(Alignment.Center).size(sizeDp, arm).clip(RoundedCornerShape(8.dp)).background(dark))
        val arrows = listOf(
            Triple(Facing.UP, Alignment.TopCenter, "▲"), Triple(Facing.DOWN, Alignment.BottomCenter, "▼"),
            Triple(Facing.LEFT, Alignment.CenterStart, "◀"), Triple(Facing.RIGHT, Alignment.CenterEnd, "▶"),
        )
        for ((f, align, label) in arrows) {
            Box(
                Modifier
                    .align(align)
                    .size(arm)
                    .clip(RoundedCornerShape(8.dp))
                    .background(if (current == f) lit else dark),
                contentAlignment = Alignment.Center,
            ) { Txt(label, size = 18.sp, color = Color(0xFF9090B0)) }
        }
    }
}

/** A full-width closing button; the Android back gesture does the same. */
@Composable
fun BackRow(label: String, onBack: () -> Unit) {
    PixelButton(label, Modifier.fillMaxWidth(), onClick = onBack)
}
