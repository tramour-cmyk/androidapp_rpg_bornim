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
import de.bornim.core.art.MapFigure
import de.bornim.core.art.MapFolk
import de.bornim.core.art.MapRest
import de.bornim.core.art.MapGlow
import de.bornim.core.art.MapLight
import de.bornim.core.art.MapFlora
import de.bornim.core.art.MapGround
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
                    // the ground sets the pace: brisk on the path, wading through tall grass
                    val ground = de.bornim.core.Terrain.stepFactor(game.map.tile(game.state.place.x, game.state.place.y)).toFloat()
                    val duration = (if (running) 110f else if (routeDir != null) 170f else 200f) * ground * de.bornim.core.Terrain.PACE.toFloat()
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
                if (!vm.menuOpen) game.releaseFlash()
                game.notices.removeFirstOrNull()?.let { vm.toast = it(game.lang) }
                if (game.sounds.isNotEmpty() || game.mode != modeBefore) vm.refresh()
            }
        }
    }

    // Quiet ambient sounds: birds by day, crickets and owls at night, drops in the cave.
    LaunchedEffect(game.state.place.map) {
        val rnd = kotlin.random.Random(game.state.steps)
        fun nearFire(): Boolean {
            val p = game.state.place
            return (-4..4).any { dy -> (-4..4).any { dx -> game.map.tile(p.x + dx, p.y + dy) == Tile.CAMPFIRE } }
        }
        while (isActive) {
            delay(5000L + rnd.nextLong(8000))
            if (game.mode != Mode.Explore || vm.menuOpen) continue
            val sound = when (game.map.kind) {
                // crackling near a fire, dripping elsewhere
                MapKind.CAVE -> if (nearFire()) de.bornim.core.audio.Sound.CRACKLE else de.bornim.core.audio.Sound.DRIP
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

/** How close the map camera is. Near (the new default) shows about 5½ tiles across, far the former 10½. */
object MapZoom {
    /**
     * Tiles across the screen, to try on the phone (10.10., 6.15): 5.6 (near, so far the default), 6.75 and
     * 8.4 in between, 10.5 the former far view. Each is a whole-number zoom on a screen 1080 pixels wide.
     */
    val levels = floatArrayOf(5.6f, 6.75f, 8.4f, 10.5f)
    @Volatile var level = 0

    /** Near: any step but the former far one. */
    var near: Boolean
        get() = level < levels.size - 1
        set(v) { level = if (v) 0 else levels.size - 1 }

    /** Tiles across the screen. */
    val tilesAcross get() = levels[level]
}

private fun camera(game: Game, w: Float, h: Float, progress: Float, fromX: Int, fromY: Int): Cam {
    val map = game.map
    val T = WorldArt.T
    // Whole-number zoom so every art pixel is the same size on screen. Near, the zoom is even, so
    // map pictures drawn at double resolution also land on whole screen pixels.
    // (an odd zoom puts the double-resolution pictures half a pixel off; they are then smoothed a little when drawn)
    val scale = if (MapZoom.near) max(2, (w / (T * MapZoom.tilesAcross)).roundToInt()) else max(2, floor(w / (T * MapZoom.tilesAcross)).toInt())
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

        /** Draws [img] at map pixel ([x], [y]); [density] art pixels per map pixel (2 for the new, finer pictures). */
        fun put(img: PixelImage, x: Int, y: Int, density: Int = 1, alpha: Float = 1f) {
            val sx = (x - camX) * scale
            val sy = (y - camY) * scale
            val dw = img.width * scale / density; val dh = img.height * scale / density
            if (sx > size.width || sy > size.height || sx + dw < 0 || sy + dh < 0) return
            drawImage(
                image = Bitmaps.of(img),
                srcOffset = IntOffset.Zero,
                srcSize = IntSize(img.width, img.height),
                dstOffset = IntOffset(sx, sy),
                dstSize = IntSize(dw, dh),
                alpha = alpha,
                filterQuality = if (density > 1 && scale % density != 0) FilterQuality.Low else FilterQuality.None,
            )
        }

        // 1) ground: in the woods the new ground without a grid (drawn ahead in the background), else the tiles
        val x0 = floor(camX.toFloat() / T).toInt()
        val y0 = floor(camY.toFloat() / T).toInt()
        val x1 = ((camX + viewW) / T).toInt()
        val y1 = ((camY + viewH) / T).toInt()
        val fine = MapGround.supports(map)
        if (fine) {
            MapGround.prepare(map, p.x, p.y)
            val ch = MapGround.CH
            for (cy in Math.floorDiv(y0, ch)..Math.floorDiv(y1, ch)) for (cx in Math.floorDiv(x0, ch)..Math.floorDiv(x1, ch)) {
                // never the former tiles while the new ground is drawn (23:04): the piece the hero stands on right away,
                // the rest stays dark for the moment it takes, drawn on several cores
                val here = cx == Math.floorDiv(p.x, ch) && cy == Math.floorDiv(p.y, ch)
                (if (here) MapGround.chunkNow(map, cx, cy) else MapGround.chunk(map, cx, cy))?.let { put(it, cx * ch * T, cy * ch * T, MapGround.D) }
            }
        }
        for (ty in y0..y1) for (tx in x0..x1) {
            if (!map.inside(tx, ty)) continue
            if (fine && !MapGround.keepsOldTile(map, map.tile(tx, ty))) continue
            put(WorldArt.ground(map, tx, ty, state, frame), tx * T, ty * T)
        }

        // shadows of trees, rocks and stones on the ground, strong by day, gone at night
        if (fine) {
            val sun = ((game.daylight - 0.2f) / 0.6f).coerceIn(0f, 1f)
            if (sun > 0.02f) for (o in MapFlora.shadows(map)) put(o.img, o.x, o.y, o.density, sun)
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

        // a figure near a flame catches its light on the near side, more so at night (09.10.)
        val flames = MapLight.sources(map).filter { it.kind == MapLight.Kind.FIRE || it.kind == MapLight.Kind.TORCH ||
            (it.kind == MapLight.Kind.LAMP && game.daylight < 0.6f) }
        // torches carried about (Garrick warding off a beast): map pixel positions
        val torches = mutableListOf<Pair<Double, Double>>()
        fun warmEdge(img: de.bornim.core.art.PixelImage, fx: Int, fy: Int): de.bornim.core.art.PixelImage {
            if (flames.isEmpty() && torches.isEmpty()) return img
            // from the figure's chest, a little over a tile above its feet
            val cx = fx + T / 2.0; val cy = fy + T - 22.0
            val all = flames.map { it.x to it.y } + torches
            val f = all.minBy { (it.first - cx) * (it.first - cx) + (it.second - cy) * (it.second - cy) }
            val dx = (f.first - cx) / T; val dy = (f.second - cy) / T
            val level = MapGlow.level(kotlin.math.sqrt(dx * dx + dy * dy), game.daylight.toDouble())
            return MapGlow.litCached(img, MapGlow.dir(dx, dy), level)
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
        // a tree crown standing in front of the hero turns half see-through, so the hero is not lost behind it
        fun hides(o: WorldArt.Obj): Boolean {
            if (o.density < 2 || o.sortY <= heroY + T) return false
            val w = o.img.width / o.density; val h = o.img.height / o.density
            return heroX + T - 8 > o.x && heroX + 8 < o.x + w && heroY + T > o.y && heroY - 30 < o.y + h - 6
        }
        for (o in WorldArt.objects(map, state, frame)) {
            val a = if (hides(o)) 0.45f else 1f
            sprites += Sprite(o.sortY.toFloat()) { put(o.img, o.x, o.y, o.density, a) }
        }
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
                // a foe waiting in its lair, like the wandering ones, only shows while the hero can see it
                if (game.fog(npc.x, npc.y) != de.bornim.core.Fog.VISIBLE) continue
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
                val folk = MapFolk.of(npc.id)
                // folk drawn as dolls: they turn smoothly, and look at the hero while the hero is near
                val doll = folk?.let { f ->
                    // away from the hero they keep their own way (Garrick: towards his fire), not the way they turned to talk
                    val home = MapFigure.yawOf(w?.facing ?: npc.facing)
                    val turn = FolkTurn.of(f.id, home)
                    MapFolk.prepare(f, MapFigure.slot(turn.yaw))
                    val dx = heroX - nx; val dy = heroY - ny
                    // a hero standing still nearby for 20 s is no longer worth watching: back to the fire (20:56)
                    val near = MapFolk.watches(dx.toDouble() / T, dy.toDouble() / T, HeroStill.forMs(heroX, heroY, clock))
                    // left alone and standing, they go about their idle loops (Garrick: warming his hands, peering into the woods)
                    // a beast turned back at its safe place: the torch out of the fire and swung at the beast (09.10.)
                    val wo = game.lastWardOff
                    val warding = if (wo != null && wo.x == npc.x && wo.y == npc.y) MapFolk.wardAt(clock - wo.atMs) else null
                    // Garrick sits down at his fire now and then, at night he nods off; he starts up when the hero comes (10.10., 3)
                    val squat = if (near || w != null || warding != null || !MapFolk.squats(f)) null else MapFolk.squatPoseAt(f, clock, game.isNight)
                    val doing = if (near || w != null || warding != null || squat != null) null else MapFolk.doing(f, clock)
                    val homeSlot = MapFigure.slot(home)
                    val target = when {
                        warding != null && wo != null -> if (warding.faceBeast)
                            Math.toDegrees(kotlin.math.atan2((wo.beastX - npc.x).toDouble(), (wo.beastY - npc.y).toDouble())) else home
                        near -> Math.toDegrees(kotlin.math.atan2(dx.toDouble(), dy.toDouble()))
                        doing != null -> (homeSlot + doing.slotOffset) * 360.0 / MapFigure.YAWS
                        else -> home
                    }
                    turn.update(target, clock)
                    val slotNow = MapFigure.slot(turn.yaw)
                    // the loop only once turned all the way, and only when its pictures are ready
                    val idleImg = doing?.let { d ->
                        if (slotNow == Math.floorMod(homeSlot + d.slotOffset, MapFigure.YAWS)) MapFolk.idleFrame(f, slotNow, d.idle, d.frame) else null
                    }
                    // otherwise, standing, the small movements everyone has: breathing, shifting weight, a glance, hands to the belt
                    val squatImg = squat?.let { if (slotNow == homeSlot) MapFolk.squatFrame(f, slotNow, it) else null }
                    val restImg = if (idleImg == null && doing == null && squat == null && !walkingNow && slotNow == MapFigure.slot(target)) {
                        val (rest, breath) = MapRest.at(f.id.hashCode(), clock, handsFree = true, mayLook = !near)
                        MapFolk.restFrame(f, slotNow, rest, breath)
                    } else null
                    val wardImg = warding?.let { wd ->
                        // the torch lights its bearer and whoever stands near; it rides about a tile above the feet
                        torches += (nx + T / 2.0) to (ny - 12.0)
                        MapFolk.wardFrame(f, slotNow, wd.ward, wd.flicker)
                    }
                    wardImg ?: squatImg ?: idleImg ?: restImg ?: MapFolk.frameNow(f, slotNow, if (walkingNow) Math.floorMod((clock / 160).toInt(), MapFigure.STEPS) else 0)
                }
                val img = CharacterArt.npc(npc.look, game.npcFacing(npc), if (walkingNow) (if ((clock / 130) % 2 == 0L) 1 else 2) else 0)
                val dollLit = doll?.let { warmEdge(it, nx, ny) }
                sprites += Sprite((ny + T - 1).toFloat()) {
                    // pictures may be wider than the standing ones (a raised torch): the feet stay in the middle, near the bottom
                    if (dollLit != null) put(dollLit, nx + T / 2 - dollLit.width / 2 / MapFigure.DENSITY,
                        ny + T - 3 - (dollLit.height - MapFigure.FOOT_BELOW) / MapFigure.DENSITY, MapFigure.DENSITY)
                    else put(img, nx, ny - 2)
                }
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
        // the hero as the doll from the battles, turning smoothly; the former figure until it is drawn
        MapFigure.prepare(state.hero, HeroTurn.yaw)
        val target = MapFigure.yawOf(p.facing)
        HeroTurn.update(target, clock)
        val walkStep = if (!walking) 0 else Math.floorMod(state.steps * 2 + (progress * 2).toInt(), MapFigure.STEPS)
        // standing a moment, the hero too breathes, shifts its weight and glances about
        val heroSlot = MapFigure.slot(HeroTurn.yaw)
        val heroRest = if (!walking && heroSlot == MapFigure.slot(target) && HeroStill.forMs(heroX, heroY, clock) > 1_500L) {
            val (rest, breath) = MapRest.at(7, clock, handsFree = false, mayLook = true)
            MapFigure.restFrame(state.hero, heroSlot, rest, breath)
        } else null
        val doll = warmEdge(heroRest ?: MapFigure.frameNow(state.hero, heroSlot, walkStep), heroX, heroY)
        // +0.5 so the hero is drawn after objects standing on the same row
        sprites += Sprite(heroY + T - 0.5f) {
            put(doll, heroX + T / 2 - MapFigure.ANCHOR_X / MapFigure.DENSITY, heroY + T - 3 - MapFigure.GROUND / MapFigure.DENSITY, MapFigure.DENSITY)
            // Feet hidden in tall grass.
            if (map.tile(p.x, p.y) == Tile.TALL_GRASS && progress > 0.5f) {
                // on the new ground the same dark blades stand before the feet; elsewhere the former patch
                if (MapGround.supports(map)) put(MapGround.tallFront((state.steps + (clock / 400).toInt()) % 2), heroX, heroY + T - 14, MapGround.D)
                else put(WorldArt.tallGrassOverlay(), heroX, heroY)
            }
        }
        sprites.sortBy { it.y }
        sprites.forEach { it.draw() }

        // Light of the place: time of day, shade of the crowns, lamps, fires and the lantern.
        if (MapLight.needed(map, game.daylight)) drawMapLight(game, map, clock, camX, camY, scale, heroX, heroY, viewW, viewH)
        // a torch carried about throws a warm, flickering glow around it, the stronger the darker it is
        for ((tx, ty) in torches) {
            val flick = 0.85f + 0.15f * kotlin.math.sin(clock / 70f) * kotlin.math.sin(clock / 113f)
            val c = Offset(((tx - camX) * scale).toFloat(), ((ty - camY) * scale).toFloat())
            val rad = T * 2.1f * scale * flick
            drawCircle(
                androidx.compose.ui.graphics.Brush.radialGradient(
                    listOf(Color(0xFFFFB060).copy(alpha = (0.05f + 0.17f * (1f - game.daylight)) * flick), Color.Transparent),
                    center = c, radius = rad,
                ),
                radius = rad, center = c,
            )
        }
        val outdoors = map.kind == MapKind.TOWN || map.kind == MapKind.FOREST
        if (outdoors) {
            drawCritters(game, map, clock, camX, camY, scale, heroX, heroY, viewW, viewH)
            drawRain(game, map, clock, camX, camY, scale)
        }

        // Fog of war over wild areas: black where unexplored, dimmed where not in sight.
        // Where the map has a light image, the fog is already part of it (soft edges).
        if (game.fogged && !MapLight.needed(map, game.daylight)) drawFog(game, camX, camY, scale, viewW, viewH)
        for ((ax, ay) in alerts) {
            // "!" above a monster that has seen the hero
            val bx = (ax - 4 - camX) * scale
            val by = (ay - 30f - camY) * scale
            drawRoundRect(Color.White, Offset(bx, by), androidx.compose.ui.geometry.Size(9f * scale, 12f * scale), androidx.compose.ui.geometry.CornerRadius(2f * scale))
            drawRect(Color(0xFFD83030), Offset(bx + 3.5f * scale, by + 2f * scale), androidx.compose.ui.geometry.Size(2f * scale, 5f * scale))
            drawRect(Color(0xFFD83030), Offset(bx + 3.5f * scale, by + 8.5f * scale), androidx.compose.ui.geometry.Size(2f * scale, 1.5f * scale))
        }


    }
}

private class Sprite(val y: Float, val draw: () -> Unit)

/** The way the hero faces on the map, turning smoothly towards where it walks instead of snapping round. */
private object HeroTurn : Turn()

/** How long the hero has stood on the same spot of the map. */
private val HeroStill = MapFolk.Stillness()

/** How each of the folk drawn as dolls faces, turning smoothly like the hero. */
private object FolkTurn {
    private val turns = HashMap<String, Turn>()
    fun of(id: String, start: Double): Turn = turns.getOrPut(id) { Turn().also { it.yaw = start } }
}

private open class Turn {
    var yaw = 0.0
    private var last = 0L

    /** Turns towards [target] (degrees) by the shortest way, about half a turn in a quarter of a second. */
    fun update(target: Double, now: Long) {
        val dt = if (last == 0L) 1000L else (now - last).coerceIn(0L, 200L)
        last = now
        var d = ((target - yaw) % 360.0 + 540.0) % 360.0 - 180.0
        val maxStep = dt * 0.75
        if (kotlin.math.abs(d) <= maxStep) yaw = target else yaw += kotlin.math.sign(d) * maxStep
        yaw = (yaw % 360.0 + 360.0) % 360.0
    }
}

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
    // quarter-tile cells, each blending the fog of the four nearest tile centres: soft edges
    val q = T / 4f
    for (ty in y0..y1) for (tx in x0..x1) for (sy in 0..3) for (sx in 0..3) {
        val px = tx + (sx + 0.5f) / 4f - 0.5f
        val py = ty + (sy + 0.5f) / 4f - 0.5f
        val ix = floor(px).toInt(); val iy = floor(py).toInt()
        val fx = px - ix; val fy = py - iy
        val v = (at(ix, iy) * (1 - fx) + at(ix + 1, iy) * fx) * (1 - fy) + (at(ix, iy + 1) * (1 - fx) + at(ix + 1, iy + 1) * fx) * fy
        if (v <= 0.01f) continue
        drawRect(
            color.copy(alpha = v.coerceAtMost(1f) * (if (v > 0.95f) 1f else 0.92f)),
            Offset((tx * T + sx * q - camX) * scale, (ty * T + sy * q - camY) * scale),
            androidx.compose.ui.geometry.Size(q * scale + 0.5f, q * scale + 0.5f),
        )
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
        // Leaves drifting through the forest. They belong to the world, not to the screen (10.10., 4: at
        // dusk these specks were taken for fireflies that move with the picture): each leaf has its
        // place in the world and is wrapped into the view only where it leaves one edge and comes back
        // at the other. Dull, dry colors, darker as the light goes.
        if (map.kind == MapKind.FOREST) {
            val dim = ((day - 0.4f) / 0.4f).coerceIn(0.3f, 1f)
            for (k in 0 until 7) {
                val wx = (hash(k, 11) % 1000) / 1000f * viewW + clock * 0.012f + kotlin.math.sin(clock / 600f + k) * 8f
                val wy = hash(k, 12) % 1000 / 1000f * viewH + clock * 0.02f
                val x = camX + ((wx - camX) % viewW + viewW) % viewW
                val y = camY + ((wy - camY) % viewH + viewH) % viewH
                val c = if (k % 2 == 0) Color(0xFF6E6A34) else Color(0xFF8A5A2A)
                px(x, y, 2f, 1f, Color(c.red * dim, c.green * dim, c.blue * dim))
            }
        }
    }

    // Fireflies (10.10., 4): at their own places in the world, only on some nights and not in the rain
    if (day < 0.4f && game.rainLevel < 0.05f && Fireflies.tonight(game)) {
        val fade = (1f - day / 0.4f).coerceIn(0f, 1f)
        for (f in Fireflies.of(map)) {
            val (x, y) = f.at(clock)
            if (x < camX - 16 || y < camY - 16 || x > camX + viewW + 16 || y > camY + viewH + 16) continue
            val glow = f.glow(clock) * fade
            if (glow <= 0.02f) continue
            val o = Offset((x - camX) * scale, (y - camY) * scale)
            // the faint light it throws on the grass below it
            val g = Offset(o.x, o.y + 7f * scale)
            drawOval(
                androidx.compose.ui.graphics.Brush.radialGradient(listOf(Color(0xFFC8E070).copy(alpha = 0.16f * glow), Color.Transparent), center = g, radius = 10f * scale),
                Offset(g.x - 10f * scale, g.y - 4f * scale), androidx.compose.ui.geometry.Size(20f * scale, 8f * scale),
            )
            // a soft halo, then the bright core
            drawCircle(
                androidx.compose.ui.graphics.Brush.radialGradient(listOf(Color(0xFFE0F878).copy(alpha = 0.45f * glow), Color(0xFFB8E060).copy(alpha = 0.12f * glow), Color.Transparent), center = o, radius = 6f * scale),
                radius = 6f * scale, center = o,
            )
            px(x, y, 1f, 1f, Color(0xFFF8FFC8).copy(alpha = glow))
        }
    }
}

/**
 * Fireflies (10.10., 4): little swarms that keep to their places in the world, over flowers and
 * meadows, at the water's edge and the edge of the wood, over fields in the village; few in the
 * deep wood and none on the paths. Each drifts slowly, now hanging still, now rising or sinking,
 * and flashes for half a second, then stays dark for some seconds, in a rhythm of its own; now and
 * then a neighbour answers just after.
 */
object Fireflies {
    /** [partner]: the offset of the neighbour it sometimes answers, sharing its [period]; null for one that keeps its own time only. */
    class Fly(private val cx: Float, private val cy: Float, private val seed: Int, private val period: Long, private val offset: Long, private val partner: Long?) {
        /** Where it is at [clock], in map pixels. */
        fun at(clock: Long): Pair<Float, Float> {
            val t = clock / 1000f
            val s = seed % 997 / 997f * 6.28f
            // drifting, with pauses: the speed itself swells and dies away
            val pace = 0.5f + 0.5f * kotlin.math.sin(t * 0.21f + s)
            val u = t * (0.35f + 0.25f * pace)
            val x = cx + kotlin.math.sin(u * 0.9f + s) * 14f + kotlin.math.sin(u * 2.3f + s * 2) * 4f
            val y = cy + kotlin.math.cos(u * 0.7f + s * 1.3f) * 9f + kotlin.math.sin(t * 0.45f + s) * 5f
            return x to y
        }

        /** How bright it is at [clock]: a short flash, then long dark. */
        fun glow(clock: Long): Float {
            // sometimes this one answers its neighbour's flash a moment later instead of keeping its own time
            val p = partner
            val answering = p != null && Math.floorMod(hash(((clock + p) / period).toInt(), seed), 3) == 0
            val c = if (answering) clock + p!! - 650 else clock + offset
            val since = Math.floorMod(c, period)
            val len = 520L
            if (since >= len) return 0f
            val u = since / len.toFloat()
            return if (u < 0.25f) u / 0.25f else ((1 - u) / 0.75f).let { it * it }
        }
    }

    private val cache = HashMap<String, List<Fly>>()

    /** Whether there are fireflies this night: some nights, not all (4b). The night belongs to the day it began on. */
    fun tonight(game: Game): Boolean = tonight(game.state.day, game.state.minutes)

    fun tonight(day: Int, minutes: Int): Boolean {
        val night = if (minutes < 12 * 60) day - 1 else day
        return Math.floorMod(hash(night, 77), 5) < 2
    }

    fun of(map: de.bornim.core.MapDef): List<Fly> = synchronized(cache) {
        cache.getOrPut(map.id) {
            if (map.kind != MapKind.FOREST && map.kind != MapKind.TOWN) return@getOrPut emptyList()
            val T = WorldArt.T
            fun t(x: Int, y: Int) = if (map.inside(x, y)) map.tile(x, y) else Tile.TREE
            fun near(x: Int, y: Int, r: Int, what: (Tile) -> Boolean) = (-r..r).any { dy -> (-r..r).any { dx -> what(t(x + dx, y + dy)) } }
            val open = setOf(Tile.GRASS, Tile.FLOWERS, Tile.TALL_GRASS)
            val centres = mutableListOf<Pair<Int, Int>>()
            for (y in 0 until map.height) for (x in 0 until map.width) {
                val here = t(x, y)
                if (here !in open && here != Tile.CROPS && here != Tile.VEG_BED) continue
                // how likely a swarm is here: flowers, water, fields and the wood's edge draw them; the deep wood little
                var p = if (here == Tile.TALL_GRASS) 0.02 else 0.0
                if (here == Tile.FLOWERS) p += 0.35
                if (near(x, y, 1) { it == Tile.WATER }) p += 0.4
                if (here == Tile.CROPS || here == Tile.VEG_BED) p += 0.18
                val trees = (-1..1).sumOf { dy -> (-1..1).count { dx -> t(x + dx, y + dy) == Tile.TREE } }
                if (map.kind == MapKind.FOREST && trees in 1..3) p += 0.14
                if (trees >= 6) p *= 0.3
                if (near(x, y, 1) { it == Tile.PATH || it == Tile.COBBLE }) p *= 0.3
                if (map.id == "deep_forest") p *= 0.3
                if ((hash(x, y, 88) % 1000) / 1000.0 >= p) continue
                if (centres.any { (cx, cy) -> kotlin.math.abs(cx - x) + kotlin.math.abs(cy - y) < 4 }) continue
                centres += x to y
            }
            centres.flatMap { (x, y) ->
                val n = 2 + hash(x, y, 89) % 4
                List(n) { k ->
                    val seed = hash(x * 31 + k, y, 90)
                    // pairs share a rhythm, so the second can answer the first
                    val lead = hash(x * 31 + k / 2 * 2, y, 90)
                    val period = 2600L + lead % 3600
                    Fly(x * T + T / 2f + (seed % 20 - 10), y * T + T / 2f + (seed / 20 % 16 - 8), seed,
                        period = period, offset = (seed / 7 % 9000).toLong(), partner = if (k % 2 == 1) (lead / 7 % 9000).toLong() else null)
                }
            }
        }
    }
}

/** The light image of the current view, redrawn only when hero, view or daylight change. */
private object LightImage {
    var key = ""
    var img: de.bornim.core.art.PixelImage? = null
}

/**
 * Light on the map: the light image multiplied over it (dark where nothing shines), a glow around
 * every light that flickers (fire) or pulses (mushrooms), and small life: sparks over fires, spores
 * over mushrooms, dust in daylight and, in caves, drops falling from the roof.
 */
private fun DrawScope.drawMapLight(
    game: Game, map: de.bornim.core.MapDef, clock: Long, camX: Int, camY: Int, scale: Int, heroX: Int, heroY: Int, viewW: Float, viewH: Float,
) {
    val T = WorldArt.T
    val res = MapLight.RES
    val hx = heroX + T / 2; val hy = heroY + T / 2
    val day = game.daylight
    // the region under the view, aligned to the light image's pixels
    val x0 = Math.floorDiv(camX, res) * res - res; val y0 = Math.floorDiv(camY, res) * res - res
    val w = ((viewW.toInt() / res) + 3) * res; val h = ((viewH.toInt() / res) + 3) * res
    val fog = game.fogged
    val key = "${map.id}/$x0/$y0/$w/$h/${hx / 3}/${hy / 3}/${(day * 64).toInt()}/${if (fog) "${game.state.place.x},${game.state.place.y},${game.state.place.facing}" else ""}"
    if (LightImage.key != key) {
        val img = MapLight.lightmap(map, day, hx, hy, x0, y0, w, h)
        if (fog) {
            // darken by the fog of war, smoothly between tile centres: unexplored black, out of sight dim
            val tx0 = Math.floorDiv(x0, T) - 1; val ty0 = Math.floorDiv(y0, T) - 1
            val tw = w / T + 4; val th = h / T + 4
            val raw = FloatArray(tw * th) { i ->
                when (game.fog(tx0 + i % tw, ty0 + i / tw)) {
                    de.bornim.core.Fog.HIDDEN -> 1f
                    de.bornim.core.Fog.SEEN -> 0.5f
                    de.bornim.core.Fog.VISIBLE -> 0f
                }
            }
            // softened over the neighbouring tiles, so the edge of the unknown is round, not a
            // staircase of tiles (it shows when the map is zoomed in); what is in sight stays clear
            val fa = FloatArray(tw * th) { i ->
                val cx = i % tw; val cy = i / tw
                var sum = 0f; var n = 0f
                for (dy in -1..1) for (dx in -1..1) {
                    val x = (cx + dx).coerceIn(0, tw - 1); val y = (cy + dy).coerceIn(0, th - 1)
                    val wgt = if (dx == 0 && dy == 0) 4f else if (dx == 0 || dy == 0) 2f else 1f
                    sum += raw[y * tw + x] * wgt; n += wgt
                }
                if (raw[i] == 0f) minOf(sum / n, 0.35f) else sum / n
            }
            for (yy in 0 until img.height) for (xx in 0 until img.width) {
                val fx = (x0 + xx * res + res / 2f) / T - 0.5f - tx0; val fy = (y0 + yy * res + res / 2f) / T - 0.5f - ty0
                val ix = floor(fx).toInt().coerceIn(0, tw - 2); val iy = floor(fy).toInt().coerceIn(0, th - 2)
                val ux = (fx - ix).coerceIn(0f, 1f); val uy = (fy - iy).coerceIn(0f, 1f)
                val a = (fa[iy * tw + ix] * (1 - ux) + fa[iy * tw + ix + 1] * ux) * (1 - uy) + (fa[(iy + 1) * tw + ix] * (1 - ux) + fa[(iy + 1) * tw + ix + 1] * ux) * uy
                if (a <= 0f) continue
                val k = 1f - a * (if (a > 0.95f) 1f else 0.92f)
                val c = img.pixels[yy * img.width + xx]
                val r = (((c shr 16) and 0xFF) * k).toInt(); val g = (((c shr 8) and 0xFF) * k).toInt(); val b = ((c and 0xFF) * k).toInt()
                img.pixels[yy * img.width + xx] = (0xFF shl 24) or (r shl 16) or (g shl 8) or b
            }
        }
        LightImage.img = img
        LightImage.key = key
    }
    val grid = LightImage.img ?: return
    drawImage(
        image = Bitmaps.of(grid),
        srcOffset = IntOffset.Zero,
        srcSize = IntSize(grid.width, grid.height),
        dstOffset = IntOffset((x0 - camX) * scale, (y0 - camY) * scale),
        dstSize = IntSize(grid.width * res * scale, grid.height * res * scale),
        // near, the light image is spread smoothly instead of in visible steps
        filterQuality = if (MapZoom.near) FilterQuality.Low else FilterQuality.None,
        blendMode = androidx.compose.ui.graphics.BlendMode.Multiply,
    )
    fun at(x: Double, y: Double) = Offset(((x - camX) * scale).toFloat(), ((y - camY) * scale).toFloat())
    fun visible(o: Offset, r: Float) = o.x > -r && o.y > -r && o.x < size.width + r && o.y < size.height + r
    for ((i, src) in MapLight.sources(map).withIndex()) {
        val c = at(src.x, src.y)
        val r = (src.reach * 0.75 * scale).toFloat()
        // a light the hero has never seen stays dark, one out of sight shines dimmed: it must not light up what the
        // fog of war hides
        val seen = when (game.fog(floor(src.x / T).toInt(), floor(src.y / T).toInt())) {
            de.bornim.core.Fog.HIDDEN -> 0f
            de.bornim.core.Fog.SEEN -> 0.4f
            de.bornim.core.Fog.VISIBLE -> 1f
        }
        val on = MapLight.strength(map, src.shines, day).toFloat() * seen
        if (on <= 0.02f || !visible(c, r)) continue
        val t = clock.toFloat()
        val indoor = map.kind == MapKind.INTERIOR
        val (color, a) = when (src.kind) {
            // a fire in a room flickers more and lights less: the room breathes with it (10.10., 6.7, 6.10)
            MapLight.Kind.FIRE -> if (indoor) {
                val f = 0.72f + 0.16f * kotlin.math.sin(t / 83f + i * 1.7f) + 0.12f * kotlin.math.sin(t / 31f + i) * kotlin.math.sin(t / 211f)
                Color(0xFFFF9A40) to 0.2f * f
            } else {
                val f = 0.8f + 0.12f * kotlin.math.sin(t / 83f + i * 1.7f) + 0.08f * kotlin.math.sin(t / 37f + i)
                Color(0xFFFFA850) to 0.32f * f
            }
            MapLight.Kind.TORCH -> {
                val f = 0.8f + 0.12f * kotlin.math.sin(t / 83f + i * 1.7f) + 0.08f * kotlin.math.sin(t / 37f + i)
                Color(0xFFFFA850) to 0.32f * f
            }
            MapLight.Kind.SHROOM -> Color(0xFF60F0E0) to 0.2f * (0.65f + 0.35f * kotlin.math.sin(t / 900f + i * 2.3f))
            MapLight.Kind.CRYSTAL -> Color(0xFFB890FF) to 0.2f * (0.8f + 0.2f * kotlin.math.sin(t / 600f + i))
            MapLight.Kind.SKY -> Color(0xFFE8F0FF) to 0.32f
            MapLight.Kind.EXIT -> Color(0xFFFFF4D8) to 0.18f
            MapLight.Kind.LAMP -> Color(0xFFFFD088) to 0.3f * (0.94f + 0.06f * kotlin.math.sin(t / 140f + i))
            // a lit window seen from outside is warm; from inside it lets in grey daylight
            MapLight.Kind.WINDOW -> if (indoor) Color(0xFFD8E0EC) to 0.1f else Color(0xFFFFC870) to 0.2f
            MapLight.Kind.CANDLE -> Color(0xFFFFC078) to 0.2f * (0.84f + 0.1f * kotlin.math.sin(t / 97f + i * 1.3f) + 0.06f * kotlin.math.sin(t / 41f + i))
            MapLight.Kind.DOOR -> Color(0xFFE8ECF0) to 0.1f
        }.let { (c, al) -> c to al * on }
        drawCircle(
            androidx.compose.ui.graphics.Brush.radialGradient(listOf(color.copy(alpha = a), color.copy(alpha = a * 0.35f), Color.Transparent), c, r),
            r, c, blendMode = androidx.compose.ui.graphics.BlendMode.Plus,
        )
        val px = scale.toFloat()
        when (src.kind) {
            MapLight.Kind.FIRE, MapLight.Kind.TORCH -> { for (k in 0 until (if (src.kind == MapLight.Kind.FIRE) 5 else 2)) {
                // sparks rising and fading
                val period = 1400 + k * 230
                val ph = ((clock + k * 517 + i * 131) % period) / period.toFloat()
                val sx = src.x + kotlin.math.sin(ph * 6f + k) * 4 + (k - 2) * 2
                val sy = src.y - 6 - ph * 26
                drawRect(Color(0xFFFFC060).copy(alpha = (1 - ph) * 0.9f * seen), at(sx, sy.toDouble()), androidx.compose.ui.geometry.Size(px, px))
            }
                // in a hearth: steam from the kettle, and smoke curling up the soot of the breast (6.11)
                if (src.kind == MapLight.Kind.FIRE && indoor) for (k in 0 until 4) {
                    val period = 2600 + k * 470
                    val ph = ((clock + k * 830 + i * 97) % period) / period.toFloat()
                    val steam = k < 2
                    val sx = src.x + (if (steam) (k - 0.5) * 3 else (k - 2.5) * 10) + kotlin.math.sin(ph * 5f + k) * (2 + ph * 4)
                    val sy = src.y - (if (steam) 22 else 30) - ph * (if (steam) 14 else 24)
                    val rr = (1.5f + ph * (if (steam) 3f else 6f)) * px
                    drawCircle(Color(if (steam) 0xFFC8C4BC else 0xFF6A625A).copy(alpha = kotlin.math.sin(ph * Math.PI.toFloat()) * (if (steam) 0.22f else 0.16f) * seen), rr, at(sx, sy.toDouble()))
                }
            }
            MapLight.Kind.WINDOW, MapLight.Kind.DOOR -> if (indoor && src.shines == MapLight.When.DAY) for (k in 0 until 7) {
                // dust dancing in the daylight falling in (6.12)
                val period = 5200 + k * 760
                val ph = ((clock + k * 1300 + i * 211) % period) / period.toFloat()
                val sx = src.x + ((k * 37 + i * 11) % 24 - 12) + kotlin.math.sin(ph * 4f + k) * 5
                val sy = src.y - 8 + ((k * 23) % 30) + kotlin.math.sin(ph * 3f + k * 2) * 6 + ph * 6
                drawRect(Color(0xFFF0E8D8).copy(alpha = kotlin.math.sin(ph * Math.PI.toFloat()) * 0.55f * on), at(sx, sy), androidx.compose.ui.geometry.Size(px, px))
            }
            MapLight.Kind.SHROOM -> for (k in 0 until 3) {
                // spores drifting up from the mushrooms
                val period = 3200 + k * 700
                val ph = ((clock + k * 1100 + i * 377) % period) / period.toFloat()
                val sx = src.x + (k - 1) * 7 + kotlin.math.sin(ph * 9f + i) * 3
                val sy = src.y + 4 - ph * 30
                drawRect(Color(0xFFA8FFF0).copy(alpha = kotlin.math.sin(ph * Math.PI.toFloat()) * 0.8f * seen), at(sx, sy.toDouble()), androidx.compose.ui.geometry.Size(px, px))
            }
            MapLight.Kind.SKY -> {
                // a slanted shaft of light from the roof, dust dancing in it
                val top = at(src.x - 10, src.y - T * 2.5)
                val path = androidx.compose.ui.graphics.Path().apply {
                    moveTo(top.x - 4 * px, top.y); lineTo(top.x + 8 * px, top.y)
                    val b = at(src.x, src.y)
                    lineTo(b.x + 16 * px, b.y + 8 * px); lineTo(b.x - 16 * px, b.y + 8 * px); close()
                }
                drawPath(path, androidx.compose.ui.graphics.Brush.verticalGradient(listOf(Color(0x10E8F0FF), Color(0x66E8F0FF), Color(0x30E8F0FF)).map { it.copy(alpha = it.alpha * seen) }, top.y, at(src.x, src.y).y + 8 * px), blendMode = androidx.compose.ui.graphics.BlendMode.Plus)
                for (k in 0 until 6) {
                    val period = 4000 + k * 650
                    val ph = ((clock + k * 900) % period) / period.toFloat()
                    val sx = src.x - 8 + ph * 12 + kotlin.math.sin(ph * 7f + k) * 5
                    val sy = src.y - T * 2.2 + ((k * 13) % 50) + ph * 20
                    drawRect(Color(0xFFFFFFFF).copy(alpha = kotlin.math.sin(ph * Math.PI.toFloat()) * 0.7f * seen), at(sx, sy), androidx.compose.ui.geometry.Size(px, px))
                }
            }
            else -> {}
        }
    }
    if (map.kind != MapKind.CAVE) return
    // drops falling from the roof onto the floor, leaving a small ring
    val tx0 = (camX / T).coerceAtLeast(0); val ty0 = (camY / T).coerceAtLeast(0)
    val tw = (viewW / T).toInt() + 2; val th = (viewH / T).toInt() + 2
    for (k in 0 until 7) {
        val period = 2600L + k * 410
        val cycle = (clock + k * 777) / period
        val ph = ((clock + k * 777) % period) / period.toFloat()
        val tx = tx0 + Math.floorMod(hash(k, cycle.toInt()), tw); val ty = ty0 + Math.floorMod(hash(cycle.toInt(), k + 50), th)
        if (!map.tile(tx, ty).walkable) continue
        val dx = tx * T + 6.0 + Math.floorMod(hash(k, 9), 20); val dy = ty * T + 10.0 + Math.floorMod(hash(k, 11), 16)
        if (ph < 0.25f) {
            val fy = dy - (1 - ph / 0.25f) * 26
            drawRect(Color(0xCCB8D8F0), at(dx, fy), androidx.compose.ui.geometry.Size(scale.toFloat(), 2f * scale))
        } else if (ph < 0.6f) {
            val q = (ph - 0.25f) / 0.35f
            val o = at(dx, dy)
            drawOval(
                Color(0xFFB8D8F0).copy(alpha = (1 - q) * 0.6f), Offset(o.x - (2 + q * 5) * scale, o.y - (1 + q * 1.5f) * scale),
                androidx.compose.ui.geometry.Size((4 + q * 10) * scale, (2 + q * 3) * scale), style = androidx.compose.ui.graphics.drawscope.Stroke(0.8f * scale),
            )
        }
    }
}

/**
 * Rain over the view (10.10., 1.2): it thickens and thins ([Game.rainLevel]), comes in gusts that
 * also bend it in the wind, falls in three layers (far: fine, faint and slow; near: few, long and
 * fast), each drop its own length and brightness; the light goes grey under it, drops splash on
 * the ground and ring the water. Now and then, far off, sheet lightning ([Game.flashAt]).
 */
private fun DrawScope.drawRain(game: Game, map: de.bornim.core.MapDef, clock: Long, camX: Int, camY: Int, scale: Int) {
    val level = game.rainLevel
    val T = WorldArt.T
    if (level > 0.01f) {
        // gusts: the rain comes heavier and slants more, then eases
        val gust = 0.5f + 0.5f * kotlin.math.sin(clock / 6100f) * kotlin.math.sin(clock / 2300f + 1.3f)
        val k = level * (0.7f + 0.3f * gust)
        val slant = 0.16f + 0.16f * gust
        // a grey veil: the colours drain under the rain
        drawRect(Color(0xFF3A4450).copy(alpha = 0.22f * level))
        val w = size.width; val h = size.height
        // the layers: count, length, speed (px per ms at scale 1), thickness, brightness
        data class Layer(val n: Int, val len: Float, val speed: Float, val thick: Float, val alpha: Float, val seed: Int)
        val layers = listOf(
            Layer(150, 5f, 0.30f, 0.5f, 0.16f, 41),
            Layer(70, 9f, 0.48f, 0.7f, 0.26f, 42),
            Layer(16, 15f, 0.75f, 1.0f, 0.36f, 43),
        )
        for (l in layers) {
            val n = (l.n * k).toInt()
            for (d in 0 until n) {
                val hv = hash(d, l.seed)
                val sp = l.speed * scale * (0.8f + (hv % 400) / 1000f)
                val len = l.len * scale * (0.6f + (hash(d, l.seed + 7) % 800) / 1000f)
                val period = (h + len) / sp
                val t = ((clock + hash(d, l.seed + 3) % 5000) % period.toLong()) / period
                val y = t * (h + len) - len
                val x0 = (hash(d, l.seed + 5) % 10000) / 10000f * (w + h * slant)
                val x = ((x0 - y * slant) % (w + 40f) + w + 40f) % (w + 40f) - 20f
                val a = l.alpha * (0.6f + (hash(d, l.seed + 9) % 400) / 1000f)
                drawLine(Color(0xFFB8C4D0).copy(alpha = a), Offset(x, y), Offset(x - len * slant, y + len), l.thick * scale)
            }
        }
        // splashes on the ground, rings on the water: each lives a moment at its own spot
        val viewTx = camX / T; val viewTy = camY / T
        val tw = (w / scale / T).toInt() + 2; val th = (h / scale / T).toInt() + 2
        for (d in 0 until (60 * k).toInt()) {
            val life = 380L + hash(d, 50) % 300
            val cycle = (clock + hash(d, 51) % 997) / life
            val ph = ((clock + hash(d, 51) % 997) % life) / life.toFloat()
            val wx = (viewTx + Math.floorMod(hash(d, cycle.toInt(), 52), tw)) * T + Math.floorMod(hash(cycle.toInt(), d, 53), T)
            val wy = (viewTy + Math.floorMod(hash(cycle.toInt(), d, 54), th)) * T + Math.floorMod(hash(d, cycle.toInt(), 55), T)
            val tile = map.tile(wx / T, wy / T)
            val o = Offset(((wx - camX) * scale).toFloat(), ((wy - camY) * scale).toFloat())
            if (tile == de.bornim.core.Tile.WATER) {
                val r = (1.5f + ph * 5f) * scale
                drawOval(Color(0xFFC8D8E8).copy(alpha = (1 - ph) * 0.45f), Offset(o.x - r, o.y - r * 0.45f), androidx.compose.ui.geometry.Size(r * 2, r * 0.9f), style = androidx.compose.ui.graphics.drawscope.Stroke(0.6f * scale))
            } else if (tile.walkable && ph < 0.45f) {
                // a drop striking the ground: a tiny flat spray that spreads and is gone
                val q = ph / 0.45f; val r = (0.7f + q * 1.8f) * scale
                drawOval(Color(0xFFC8D4E0).copy(alpha = (1 - q) * 0.32f), Offset(o.x - r, o.y - r * 0.35f), androidx.compose.ui.geometry.Size(r * 2, r * 0.7f), style = androidx.compose.ui.graphics.drawscope.Stroke(0.5f * scale))
            }
        }
    }
    // sheet lightning far off: the sky lights up twice in quick succession, then fades
    val since = clock - game.flashAt
    if (since in 0..1200) {
        fun pulse(at: Long, len: Long) = if (since in at until at + len) kotlin.math.sin((since - at) / len.toFloat() * Math.PI.toFloat()) else 0f
        val f = maxOf(pulse(0, 110), 0.75f * pulse(170, 140), 0.35f * pulse(420, 700))
        // by day it must outshine the daylight to be seen at all (1.4)
        drawRect(Color(0xFFDDE6F4).copy(alpha = (0.33f + 0.32f * game.daylight) * f))
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
            // The row is always there, even when empty, so the bar keeps its height and the map never jumps.
            run {
                Row(Modifier.padding(top = 1.dp), horizontalArrangement = Arrangement.spacedBy(3.dp), verticalAlignment = Alignment.CenterVertically) {
                    if (chips.isEmpty() && info.points == 0) Txt(" ", size = 11.sp, maxLines = 1)
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
