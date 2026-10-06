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
import androidx.compose.runtime.mutableLongStateOf
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
import de.bornim.core.Ui
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
        mode is Mode.Shop -> ShopScreen(vm, game, mode.stock, mode.brewing)
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

    // Monsters on the map move in real time; the clock also drives their animation.
    var clock by remember { mutableLongStateOf(0L) }
    LaunchedEffect(game) {
        while (isActive) {
            withFrameMillis { ms ->
                clock = ms
                val modeBefore = game.mode
                game.update(ms)
                game.notices.removeFirstOrNull()?.let { vm.toast = it(game.lang) }
                if (game.sounds.isNotEmpty() || game.mode != modeBefore) vm.refresh()
            }
        }
    }

    // Quiet ambient sounds: birds by day, crickets and owls at night, drops in the cave.
    LaunchedEffect(game.state.place.map) {
        val rnd = kotlin.random.Random(game.state.steps)
        while (isActive) {
            delay(5000L + rnd.nextLong(8000))
            if (game.mode != Mode.Explore || vm.menuOpen) continue
            val sound = when (game.map.kind) {
                MapKind.CAVE -> de.bornim.core.audio.Sound.DRIP
                MapKind.TOWN, MapKind.FOREST -> when {
                    game.raining -> null
                    game.isNight -> if (game.map.kind == MapKind.FOREST && rnd.nextInt(3) == 0) de.bornim.core.audio.Sound.OWL else de.bornim.core.audio.Sound.CRICKET
                    else -> de.bornim.core.audio.Sound.BIRD
                }
                else -> null
            }
            sound?.let { vm.play(it, 0.3f) }
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
        // Fixed bar above the map: it never covers any part of the map.
        HudChip(
            HudInfo.of(game), game.lang,
            Modifier.fillMaxWidth(), bar = true,
        ) { if (game.mode == Mode.Explore) vm.menuOpen = true }
        Box(
            Modifier
                .weight(1f)
                .fillMaxWidth()
                .clipToBounds()
                .background(Color.Black)
        ) {
            MapView(game, rev, progress, fromX, fromY, route?.target, clock)
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
private fun MapView(game: Game, rev: Int, progress: Float, fromX: Int, fromY: Int, marker: Pair<Int, Int>?, clock: Long) {
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
        // Strolling villagers slide between tiles like the hero.
        fun npcPos(npc: de.bornim.core.Npc): Pair<Int, Int> {
            val w = game.walkerOf(npc) ?: return npc.x * T to npc.y * T
            val t = ((clock - w.movedAt).toFloat() / w.moveMs).coerceIn(0f, 1f)
            return ((w.fromX + (w.x - w.fromX) * t) * T).roundToInt() to ((w.fromY + (w.y - w.fromY) * t) * T).roundToInt()
        }
        for (npc in visibleNpcs) if (!npc.look.startsWith("monster:")) {
            val (nx, ny) = npcPos(npc)
            put(WorldArt.shadow(), nx + 4, ny + 26)
        }
        put(WorldArt.shadow(), heroX + 4, heroY + 26)

        // 3) objects and characters, sorted by their foot line
        val sprites = mutableListOf<Sprite>()
        for (o in WorldArt.objects(map, state, frame)) sprites += Sprite(o.sortY.toFloat()) { put(o.img, o.x, o.y) }
        // Healing herbs on the flower meadows, swaying gently so they catch the eye.
        if (map.kind == MapKind.FOREST) for (ty in 0 until map.height) for (tx in 0 until map.width) {
            if (map.tile(tx, ty) != Tile.FLOWERS || !game.herbAt(tx, ty)) continue
            val img = WorldArt.herb()
            val sway = if ((clock / 600 + tx + ty) % 2 == 0L) 0 else 1
            val bottom = ty * T + T - 4
            sprites += Sprite(bottom.toFloat()) {
                put(WorldArt.shadow(), tx * T + 4, bottom - 5)
                put(img, tx * T + T / 2 - img.width / 2 + sway, bottom - img.height + 1)
            }
        }
        for (npc in visibleNpcs) {
            val bottom = npc.y * T + T - 1
            if (npc.look.startsWith("monster:")) {
                val id = npc.look.removePrefix("monster:")
                val img = MonsterArt.get(id)
                sprites += Sprite(bottom.toFloat()) { put(img, npc.x * T + T / 2 - img.width / 2, bottom + 1 - img.height) }
                // A boss with a bodyguard: the guards sit at its sides.
                de.bornim.core.Packs[id]?.let { pack ->
                    for (i in 0 until de.bornim.core.Packs.size(id, de.bornim.core.MonsterLook())) {
                        val left = i % 2 == 0
                        val mate = MonsterArt.mapSprite(pack.mate, de.bornim.core.MonsterLook(101 * (i + 1)), ((clock / 260 + i) % 4).toInt(), mirrored = !left, scale = mapMateScale(pack))
                        val mx = npc.x * T + T / 2 - mate.width / 2 + (if (left) -(img.width / 2 + 4) else img.width / 2 + 4)
                        sprites += Sprite((bottom + 1).toFloat()) { put(mate, mx, bottom + 3 - mate.height) }
                    }
                }
            } else {
                val (nx, ny) = npcPos(npc)
                val w = game.walkerOf(npc)
                val walkingNow = w != null && clock - w.movedAt < w.moveMs
                val img = CharacterArt.npc(npc.look, game.npcFacing(npc), if (walkingNow) (if ((clock / 130) % 2 == 0L) 1 else 2) else 0)
                sprites += Sprite((ny + T - 1).toFloat()) { put(img, nx, ny - 2) }
            }
        }
        // Monsters walking around; only those in sight are shown, the "!" of a hunter is heard from anywhere.
        val alerts = mutableListOf<Pair<Float, Float>>()
        for (r in game.roamers) {
            val t = ((clock - r.movedAt).toFloat() / r.moveMs).coerceIn(0f, 1f)
            if (clock < r.alertUntil) alerts += ((r.fromX + (r.x - r.fromX) * t) * T + T / 2f) to ((r.fromY + (r.y - r.fromY) * t) * T)
            if (game.fog(r.x, r.y) != de.bornim.core.Fog.VISIBLE) continue
            val rx = ((r.fromX + (r.x - r.fromX) * t) * T).roundToInt()
            val ry = ((r.fromY + (r.y - r.fromY) * t) * T).roundToInt()
            val img = MonsterArt.mapSprite(r.monster, r.look, ((clock / 240) % 4).toInt(), mirrored = r.facing == Facing.RIGHT)
            val foot = ry + T - 1
            // A pack walks together: its mates trail just behind the leader.
            val pack = de.bornim.core.Packs[r.monster]
            val mates = de.bornim.core.Packs.size(r.monster, r.look)
            if (pack != null) for (i in 0 until mates) {
                val mate = MonsterArt.mapSprite(
                    pack.mate, de.bornim.core.MonsterLook(r.look.seed + 101 * (i + 1)), ((clock / 240 + i + 1) % 4).toInt(),
                    mirrored = r.facing == Facing.RIGHT, scale = mapMateScale(pack),
                )
                val ox = if (i == 0) -11 else 11
                val oy = if (i == 0) -7 else -9
                sprites += Sprite((foot + oy).toFloat()) { put(mate, rx + T / 2 - mate.width / 2 + ox, foot + 1 + oy - mate.height) }
            }
            sprites += Sprite(foot.toFloat()) {
                val sx = rx + T / 2 - img.width / 2
                val sy = foot + 1 - img.height
                put(WorldArt.shadow(), rx + 4, ry + 26)
                r.trait?.let { tr ->
                    // Elites glow in the color of their trait.
                    val pulse = 0.5f + 0.5f * kotlin.math.sin(clock / 220f)
                    drawCircle(
                        androidx.compose.ui.graphics.Brush.radialGradient(
                            listOf(Color(tr.color).copy(alpha = 0.35f + 0.25f * pulse), Color.Transparent),
                            center = Offset((rx + T / 2f - camX) * scale, (ry + T / 2f - camY) * scale),
                            radius = T * 0.75f * scale,
                        ),
                        radius = T * 0.75f * scale,
                        center = Offset((rx + T / 2f - camX) * scale, (ry + T / 2f - camY) * scale),
                    )
                }
                put(img, sx, sy)
                if (r.shiny) {
                    // a few twinkling pixels
                    for (k in 0 until 3) {
                        val phase = ((clock / 180 + k * 3 + r.uid) % 8).toInt()
                        if (phase > 3) continue
                        val px = sx + 6 + ((r.uid * 7 + k * 11) % 20)
                        val py = sy + 4 + ((r.uid * 5 + k * 13) % 18)
                        drawRect(Color.White, Offset((px - camX) * scale.toFloat(), (py - camY) * scale.toFloat()), androidx.compose.ui.geometry.Size(scale.toFloat(), scale.toFloat()))
                    }
                }
            }
        }

        val walking = progress < 1f
        val step = if (!walking) 0 else if (state.steps % 2 == 0) 1 else 2
        val hero = CharacterArt.hero(state.hero, p.facing, step)
        // +0.5 so the hero is drawn after objects standing on the same row
        sprites += Sprite(heroY + T - 0.5f) {
            put(hero, heroX, heroY - 2)
            // Feet hidden in tall grass.
            if (map.tile(p.x, p.y) == Tile.TALL_GRASS && progress > 0.5f) put(WorldArt.tallGrassOverlay(), heroX, heroY)
        }
        sprites.sortBy { it.y }
        sprites.forEach { it.draw() }

        val outdoors = map.kind == MapKind.TOWN || map.kind == MapKind.FOREST
        if (outdoors) {
            drawCritters(game, map, clock, camX, camY, scale, heroX, heroY, viewW, viewH)
            drawWeatherAndNight(game, map, clock, camX, camY, scale, heroX, heroY)
        }

        // Fog of war over wild areas: black where unexplored, dimmed where not in sight.
        if (game.fogged) drawFog(game, camX, camY, scale, viewW, viewH)
        for ((ax, ay) in alerts) {
            // "!" above a monster that has seen the hero
            val bx = (ax - 4 - camX) * scale
            val by = (ay - 30f - camY) * scale
            drawRoundRect(Color.White, Offset(bx, by), androidx.compose.ui.geometry.Size(9f * scale, 12f * scale), androidx.compose.ui.geometry.CornerRadius(2f * scale))
            drawRect(Color(0xFFD83030), Offset(bx + 3.5f * scale, by + 2f * scale), androidx.compose.ui.geometry.Size(2f * scale, 5f * scale))
            drawRect(Color(0xFFD83030), Offset(bx + 3.5f * scale, by + 8.5f * scale), androidx.compose.ui.geometry.Size(2f * scale, 1.5f * scale))
        }

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

/**
 * Draws the fog in half-tile cells; each cell blends the fog of its tile with the neighbours
 * on that side, so the edges of the sight cone are soft instead of blocky.
 */
private fun DrawScope.drawFog(game: Game, camX: Int, camY: Int, scale: Int, viewW: Float, viewH: Float) {
    val T = WorldArt.T
    val x0 = floor(camX.toFloat() / T).toInt() - 1
    val y0 = floor(camY.toFloat() / T).toInt() - 1
    val x1 = ((camX + viewW) / T).toInt() + 1
    val y1 = ((camY + viewH) / T).toInt() + 1
    val w = x1 - x0 + 1
    val h = y1 - y0 + 1
    val a = FloatArray(w * h)
    for (ty in y0..y1) for (tx in x0..x1) {
        a[(ty - y0) * w + (tx - x0)] = when (game.fog(tx, ty)) {
            de.bornim.core.Fog.HIDDEN -> 1f
            de.bornim.core.Fog.SEEN -> 0.5f
            de.bornim.core.Fog.VISIBLE -> 0f
        }
    }
    fun at(tx: Int, ty: Int) = if (tx < x0 || ty < y0 || tx > x1 || ty > y1) 1f else a[(ty - y0) * w + (tx - x0)]
    val color = Color(0xFF080A12)
    val half = T / 2f
    for (ty in y0..y1) for (tx in x0..x1) {
        val self = at(tx, ty)
        for (sy in 0..1) for (sx in 0..1) {
            val nx = if (sx == 0) -1 else 1
            val ny = if (sy == 0) -1 else 1
            val v = self * 0.5f + (at(tx + nx, ty) + at(tx, ty + ny)) * 0.2f + at(tx + nx, ty + ny) * 0.1f
            if (v <= 0.01f) continue
            drawRect(
                color.copy(alpha = v.coerceAtMost(1f) * (if (v > 0.9f) 1f else 0.92f)),
                Offset((tx * T + sx * half - camX) * scale, (ty * T + sy * half - camY) * scale),
                androidx.compose.ui.geometry.Size(half * scale + 0.5f, half * scale + 0.5f),
            )
        }
    }
}

private fun hash(a: Int, b: Int, c: Int = 0): Int {
    var n = a * 374761393 + b * 668265263 + c * 1442695041
    n = (n xor (n ushr 13)) * 1274126177
    return (n xor (n ushr 16)) and 0x7fffffff
}

/** Butterflies, birds, chimney smoke, fireflies and leaves: small things that make the world feel alive. */
private fun DrawScope.drawCritters(
    game: Game, map: de.bornim.core.MapDef, clock: Long, camX: Int, camY: Int, scale: Int,
    heroX: Int, heroY: Int, viewW: Float, viewH: Float,
) {
    val T = WorldArt.T
    val day = game.daylight
    fun px(x: Float, y: Float, w: Float, h: Float, c: Color) =
        drawRect(c, Offset((x - camX) * scale, (y - camY) * scale), androidx.compose.ui.geometry.Size(w * scale, h * scale))
    val tx0 = (camX / T) - 1; val ty0 = (camY / T) - 1
    val tx1 = ((camX + viewW) / T).toInt() + 1; val ty1 = ((camY + viewH) / T).toInt() + 1

    // Chimney smoke, day and night
    for ((cx, cy) in WorldArt.chimneys(map)) for (k in 0 until 4) {
        val p = ((clock / 2200f) + k / 4f) % 1f
        val x = cx + kotlin.math.sin(p * 6f + k) * 2f + p * 7f
        val y = cy - p * 24f
        val r = 2f + p * 4f
        drawCircle(Color(0xFFD8D8E0).copy(alpha = 0.45f * (1f - p)), r * scale, Offset((x - camX) * scale, (y - camY) * scale))
    }

    if (day > 0.4f && !game.raining) {
        // Butterflies over flowers
        for (ty in ty0..ty1) for (tx in tx0..tx1) {
            if (map.tile(tx, ty) != Tile.FLOWERS || hash(tx, ty) % 4 != 0) continue
            val seed = hash(tx, ty, 7) % 1000
            val x = tx * T + 16 + kotlin.math.sin(clock / 700f + seed) * 12f
            val y = ty * T + 8 + kotlin.math.cos(clock / 530f + seed * 0.7f) * 7f
            val open = (clock / 90 + seed) % 2 == 0L
            val c = listOf(Color.White, Color(0xFFF8E060), Color(0xFFF0A040), Color(0xFF80B8F8))[seed % 4]
            if (open) {
                px(x - 2, y, 2f, 2f, c); px(x + 1, y, 2f, 2f, c)
            } else {
                px(x - 1, y - 1, 1f, 2f, c); px(x + 1, y - 1, 1f, 2f, c)
            }
            px(x, y, 1f, 2f, Color(0xFF302020))
        }
        // Birds pecking on the grass fly off when the hero comes close
        for (ty in ty0..ty1) for (tx in tx0..tx1) {
            val t = map.tile(tx, ty)
            if ((t != Tile.GRASS && t != Tile.PATH) || hash(tx, ty, 3) % 23 != 0) continue
            val bx = tx * T + 10f + hash(tx, ty, 4) % 12
            val by = ty * T + 18f
            val dist = kotlin.math.hypot((bx - heroX - 16).toDouble(), (by - heroY - 16).toDouble())
            val flee = ((80.0 - dist) / 30.0).coerceIn(0.0, 1.0).toFloat()
            val fx = bx + flee * 70f
            val fy = by - flee * 90f
            if (flee >= 1f) continue
            val brown = Color(0xFF7A5030)
            val hop = if (flee == 0f && (clock / 140 + hash(tx, ty)) % 9 == 0L) 1f else 0f
            px(fx, fy - hop, 3f, 2f, brown)
            px(fx + 3, fy - 1 - hop, 1f, 1f, brown)
            px(fx + 4, fy - 1 - hop, 1f, 1f, Color(0xFFE0A030))
            if (flee > 0f) {
                val wing = if ((clock / 70) % 2 == 0L) -2f else 1f
                px(fx - 1, fy + wing, 2f, 1f, brown); px(fx + 2, fy + wing, 2f, 1f, brown)
            }
        }
        // Chickens scratching around the hay bales
        for (ty in ty0..ty1) for (tx in tx0..tx1) {
            if (map.tile(tx, ty) != Tile.HAY) continue
            for (k in 0 until 3) {
                val seed = hash(tx, ty, 20 + k) % 1000
                val t = clock / 2600f + seed
                // slow wandering on a little loop beside the bale, pecking now and then
                val cx = tx * T + 16f + kotlin.math.sin(t * 0.9f + k * 2.1f) * 26f + (if (k == 1) -30f else 0f)
                val cy = ty * T + 28f + kotlin.math.cos(t * 0.7f + k) * 8f
                val faceLeft = kotlin.math.cos(t * 0.9f + k * 2.1f) < 0
                val peck = (clock / 180 + seed) % 11 < 2
                val dir = if (faceLeft) -1f else 1f
                val white = Color(0xFFF4F0E8); val shade = Color(0xFFC8C0B0)
                px(cx - 3, cy - 4, 6f, 4f, white)
                px(cx - 3, cy - 1, 6f, 1f, shade)
                px(cx - 3 * dir - (if (faceLeft) 1 else 0), cy - 4, 1f, 2f, shade) // tail
                val hx = cx + 3 * dir - (if (faceLeft) 1 else 0)
                val hy = if (peck) cy - 3 else cy - 6
                px(hx, hy, 2f, 2f, white)
                px(hx, hy - 1, 1f, 1f, Color(0xFFD83030)) // comb
                px(hx + dir * 2 - (if (faceLeft) 1 else 0), hy + 1, 1f, 1f, Color(0xFFE8A020)) // beak
                px(cx - 1, cy, 1f, 1f, Color(0xFFE8A020)); px(cx + 1, cy, 1f, 1f, Color(0xFFE8A020)) // legs
            }
        }
        // Leaves drifting through the forest
        if (map.kind == MapKind.FOREST) for (k in 0 until 7) {
            val sx = (hash(k, 11) % 1000) / 1000f * viewW
            val x = camX + (sx + clock * 0.012f + kotlin.math.sin(clock / 600f + k) * 8f) % viewW
            val y = camY + (hash(k, 12) % 1000 / 1000f * viewH + clock * 0.02f) % viewH
            px(x, y, 2f, 1f, if (k % 2 == 0) Color(0xFF8AB040) else Color(0xFFE09030))
        }
    }

    if (day < 0.5f && map.kind == MapKind.FOREST) {
        // Fireflies
        for (k in 0 until 18) {
            val x = camX + (hash(k, 21) % 1000) / 1000f * viewW + kotlin.math.sin(clock / 900f + k) * 10f
            val y = camY + (hash(k, 22) % 1000) / 1000f * viewH + kotlin.math.cos(clock / 1100f + k * 1.7f) * 8f
            val glow = kotlin.math.sin(clock / 380f + k * 2.1f).coerceAtLeast(0f) * (1f - day * 2f)
            if (glow <= 0.05f) continue
            drawCircle(Color(0xFFE8F870).copy(alpha = 0.3f * glow), 4f * scale, Offset((x - camX) * scale, (y - camY) * scale))
            px(x, y, 1f, 1f, Color(0xFFF8FFB0).copy(alpha = glow))
        }
    }
}

/** Night darkness with a lantern glow around the hero, lit windows, and rain. */
private fun DrawScope.drawWeatherAndNight(
    game: Game, map: de.bornim.core.MapDef, clock: Long, camX: Int, camY: Int, scale: Int, heroX: Int, heroY: Int,
) {
    val T = WorldArt.T
    val dark = (1f - game.daylight) * 0.8f + if (game.raining) 0.18f else 0f
    if (dark > 0.01f) {
        val center = Offset((heroX - camX + T / 2f) * scale, (heroY - camY + T / 2f) * scale)
        val night = Color(0xFF0A1236)
        drawRect(
            androidx.compose.ui.graphics.Brush.radialGradient(
                0f to night.copy(alpha = dark * 0.15f),
                0.14f to night.copy(alpha = dark * 0.45f),
                0.4f to night.copy(alpha = dark),
                center = center, radius = size.maxDimension * 0.9f,
            ),
        )
    }
    val nightness = 1f - game.daylight
    if (nightness > 0.2f) {
        // warm light from windows and fires
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            val t = map.tile(tx, ty)
            if (t != Tile.WINDOW && t != Tile.CAMPFIRE && t != Tile.LAMP) continue
            val c = Offset((tx * T + T / 2f - camX) * scale, (ty * T + T / 2f - camY) * scale)
            if (c.x < -200 || c.y < -200 || c.x > size.width + 200 || c.y > size.height + 200) continue
            val flicker = if (t == Tile.CAMPFIRE) 0.85f + 0.15f * kotlin.math.sin(clock / 90f) else 1f
            val r = (if (t == Tile.CAMPFIRE) 2.2f else 1.5f) * T * scale * flicker
            drawCircle(
                androidx.compose.ui.graphics.Brush.radialGradient(
                    listOf(Color(0xFFFFC870).copy(alpha = 0.7f * nightness), Color(0xFFFFB050).copy(alpha = 0.25f * nightness), Color.Transparent), c, r,
                ),
                r, c,
            )
        }
    }
    if (game.raining) {
        val rain = Color(0xFFC8DCF8).copy(alpha = 0.7f)
        for (k in 0 until 220) {
            val x = ((hash(k, 31) % 1000) / 1000f * size.width + clock * 0.25f) % size.width
            val y = ((hash(k, 32) % 1000) / 1000f * size.height + clock * 1.1f) % size.height
            drawLine(rain, Offset(x, y), Offset(x - 3f * scale, y + 10f * scale), 0.9f * scale)
        }
    }
}


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

/** Pack mates on the map are a little smaller than their leader, though less so than in battle. */
private fun mapMateScale(pack: de.bornim.core.PackDef): Float = 0.5f + pack.scale / 2

/** Everything the HUD shows, as plain values so Compose redraws it whenever one of them changes. */
private data class HudInfo(
    val hp: Int, val maxHp: Int, val sp: Int, val maxSp: Int,
    val level: Int, val xpFraction: Float?, val points: Int,
    val day: Int, val minutes: Int, val night: Boolean,
    val ailments: List<de.bornim.core.Status>,
    val wellFed: Boolean,
) {
    companion object {
        fun of(game: de.bornim.core.Game): HudInfo {
            val h = game.hero
            val from = de.bornim.core.Rules.xpForLevel[h.level]
            val xp = if (de.bornim.core.Story.capped(game.state)) 1f else de.bornim.core.Rules.xpToNext(h.level)?.let { to -> ((h.xp - from).toFloat() / (to - from)).coerceIn(0f, 1f) }
            val ailments = de.bornim.core.Status.entries.filter { game.state.ailment(it) > 0 }
            return HudInfo(h.hp, h.maxHp, h.sp, h.maxSp, h.level, xp, h.unspentPoints, game.state.day, game.state.minutes, game.isNight, ailments, game.state.wellFed)
        }
    }
}

@Composable
private fun HudChip(info: HudInfo, lang: de.bornim.core.Lang, modifier: Modifier, bar: Boolean = false, onMenu: () -> Unit) {
    val german = lang == de.bornim.core.Lang.DE
    // Compact: bars on the left, level, points and time on the right, so the map stays visible.
    Row(
        (if (bar) modifier.background(Color(0xFF14141E)) else modifier.clip(RoundedCornerShape(8.dp)).background(Color(0xAA000000)))
            .tap(onMenu)
            .padding(horizontal = if (bar) 10.dp else 6.dp, vertical = 3.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column {
            val hpFrac = info.hp.toFloat() / info.maxHp
            HudBar(Ui.hp(lang), hpFrac, hpColor(hpFrac), "${info.hp}/${info.maxHp}", Colors.accent)
            if (info.maxSp > 0) HudBar(Ui.sp(lang), info.sp.toFloat() / info.maxSp, Colors.sp, "${info.sp}/${info.maxSp}", Colors.sp)
            HudBar(Ui.xp(lang), info.xpFraction ?: 1f, Colors.gold, (if (german) "St. " else "Lv ") + info.level, Colors.gold)
        }
        Spacer(Modifier.width(6.dp))
        Column(horizontalAlignment = Alignment.End) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                PixelImageView(ActionArt.icon(if (info.night) ActionArt.Extra.MOON else ActionArt.Extra.SUN), 13.dp)
                Spacer(Modifier.width(2.dp))
                Txt(
                    (if (german) "Tag ${info.day} · " else "Day ${info.day} · ") + "%02d:%02d".format(info.minutes / 60, info.minutes % 60),
                    size = 11.sp, color = Colors.textLight, maxLines = 1,
                )
            }
            val chips = info.ailments.map { it.short(lang) to Color(it.color) } +
                (if (info.wellFed) listOf((if (german) "Satt" else "Fed") to Color(0xFFB07A30)) else emptyList())
            if (chips.isNotEmpty() || info.points > 0) {
                Row(Modifier.padding(top = 1.dp), horizontalArrangement = Arrangement.spacedBy(3.dp), verticalAlignment = Alignment.CenterVertically) {
                    chips.forEach { (label, color) ->
                        Box(
                            Modifier
                                .clip(RoundedCornerShape(3.dp))
                                .background(color)
                                .padding(horizontal = 3.dp)
                        ) { Txt(label, size = 9.sp, color = Color.White, bold = true, maxLines = 1) }
                    }
                    if (info.points > 0) Txt("★ +${info.points}", size = 11.sp, color = Colors.gold, maxLines = 1)
                }
            }
        }
        if (bar) Spacer(Modifier.weight(1f)) else Spacer(Modifier.width(6.dp))
        // The bag opens the menu.
        PixelImageView(ActionArt.icon(ActionArt.Extra.MENU), 28.dp)
    }
}

/** One labelled bar of the HUD: label, bar and value in a row. */
@Composable
private fun HudBar(label: String, fraction: Float, color: Color, value: String, labelColor: Color) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Txt(label, Modifier.width(18.dp), size = 9.sp, color = labelColor, bold = true, maxLines = 1)
        Bar(fraction, color, Modifier.width(56.dp), 5.dp)
        Spacer(Modifier.width(4.dp))
        Txt(value, Modifier.width(42.dp), size = 10.sp, color = Colors.textLight, bold = true, maxLines = 1)
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
