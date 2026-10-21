package de.bornim.game.ui

import androidx.activity.compose.BackHandler
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
import androidx.compose.foundation.layout.heightIn
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
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.FilterQuality
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.withTransform
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
import de.bornim.core.actionAt
import de.bornim.core.art.BattleAhead
import de.bornim.core.art.MapFigure
import de.bornim.core.art.MapFoe
import de.bornim.core.art.MapFollow
import de.bornim.core.art.MapFolk
import de.bornim.core.art.MapRest
import de.bornim.core.art.MapGlow
import de.bornim.core.art.MapLight
import de.bornim.core.art.MapFlora
import de.bornim.core.art.MapGround
import de.bornim.core.Ui
import de.bornim.core.Route
import de.bornim.core.actionAhead
import de.bornim.core.actionPlace
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
        mode == Mode.Board -> BoardScreen(vm, game)
        mode is Mode.Rest -> RestScreen(vm, game, mode.spot)
        vm.menuOpen -> MenuScreen(vm, game)
        else -> WorldScreen(vm, game)
    }
}

@Composable
fun WorldScreen(vm: GameViewModel, game: Game) {
    val rev = vm.tick
    var heldDir by remember { mutableStateOf<Facing?>(null) }
    var running by remember { mutableStateOf(false) }
    // 131: the run button beside the joystick, a switch: on until tapped again, the hero stops or is out of breath
    var runLatch by remember { mutableStateOf(false) }
    // A walk planned by tapping on the map.
    var route by remember { mutableStateOf<Route?>(null) }
    var routeIdx by remember { mutableIntStateOf(0) }
    // free walking (13g): the drag of the stick on the screen, and the tile centres of a tapped walk
    var stick by remember { mutableStateOf<Offset?>(null) }
    var waypoints by remember { mutableStateOf<List<Pair<Double, Double>>>(emptyList()) }
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
        var lastFrame = 0L
        val feet = de.bornim.core.audio.Footsteps.Feet()
        val breath = de.bornim.core.audio.Panting.Breath()
        var wasMoving = false
        var pace = 0.0
        while (isActive) {
            // turned round at the edge of the map (67): once the line is read, one step back the way the hero came
            if (game.mode == Mode.Explore && !VeilMemory.active) game.stepBack?.let { d ->
                game.stepBack = null
                val p = game.state.place
                val tx = p.x + d.dx; val ty = p.y + d.dy
                if (game.free(tx, ty)) {
                    route = Route(listOf(d), target = tx to ty)
                    routeIdx = 0
                    waypoints = listOf((tx + 0.5) to (ty + 0.5))
                }
            }
            // free walking (13g): any direction, the world and its rules still on the tiles
            val fw = game.freeWalk
            fw.sync()
            // behind the black screen between places the hero stands still (24.1)
            val sv = if (VeilMemory.active) null else stick ?: heldDir?.let { Offset(it.dx.toFloat(), it.dy.toFloat()) }
            var vx = 0.0; var vy = 0.0
            val r = route
            if (game.mode != Mode.Explore || VeilMemory.active) { route = null; waypoints = emptyList() }
            if (sv != null) {
                route = null; waypoints = emptyList()
                // the drag on the screen, turned into the map
                vx = (sv.x + 2.0 * sv.y) / 2; vy = (2.0 * sv.y - sv.x) / 2
            } else if (r != null && waypoints.isNotEmpty()) {
                // walk straight to the furthest tile centre of the planned way that can be reached in a line
                val wp = waypoints
                var k = 0
                for (i in wp.indices.reversed()) if (fw.clear(wp[i].first, wp[i].second)) { k = i; break }
                val (gx, gy) = wp[k]
                val dx = gx - fw.x; val dy = gy - fw.y
                if (k == wp.size - 1 && dx * dx + dy * dy < 0.01) {
                    // arrived: turn towards the target and use it
                    route = null; waypoints = emptyList()
                    r.face?.let { game.face(it) }
                    if (r.interact) pressA() else vm.refresh()
                } else { vx = dx; vy = dy }
            } else if (r != null) {
                route = null
                r.face?.let { game.face(it) }
                if (r.interact) pressA()
            }
            withFrameMillis { now ->
                val dt = if (lastFrame == 0L) 16L else (now - lastFrame).coerceIn(0L, 100L)
                lastFrame = now
                // 86.3: running uses up breath; out of breath, the hero walks
                val moves = vx != 0.0 || vy != 0.0
                val runs = de.bornim.core.Stamina.step(game.state, dt, moves, running || runLatch)
                if (runLatch && (game.state.winded || (wasMoving && !moves))) runLatch = false
                wasMoving = moves
                // 95: out of breath, the hero pants (Team Jerry)
                breath.due(game.state, now)?.let { vm.play(de.bornim.core.audio.Panting.sound(game.state.hero.sex), it) }
                if (vx != 0.0 || vy != 0.0) {
                    // a tapped walk slows down for the last bit so it does not overshoot the middle of the tile
                    val left = if (sv == null && waypoints.isNotEmpty()) kotlin.math.hypot(vx, vy) else 9.0
                    // 131.1: between walking and running the pace eases over a moment
                    pace = de.bornim.core.FreeWalk.ease(pace, de.bornim.core.FreeWalk.pace(game.state.hero, runs) * (if (sv == null) 1.15 else 1.0), dt)
                    fw.walk(vx, vy, dt, pace * minOf(1.0, 0.25 + left * 4), now)
                } else { pace = 0.0; fw.walk(0.0, 0.0, dt, 0.0, now) }
                // 74: a step's sound each time a foot sets down, by the ground under it
                if (feet.fell(fw.walked, runs) && fw.moving && vm.stepsOn) {
                    val tile = game.map.tile(kotlin.math.floor(fw.x).toInt(), kotlin.math.floor(fw.y).toInt())
                    vm.play(de.bornim.core.audio.Footsteps.sound(game.map, tile), de.bornim.core.audio.Footsteps.volume(tile, runs))
                }
            }
            vm.refresh()
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
                if (game.sounds.isNotEmpty() || game.placedSounds.isNotEmpty() || game.mode != modeBefore) vm.refresh()
            }
        }
    }

    // Quiet ambient sounds (84, D3.15): birds by day, crickets and owls at night, none of them in the deep forest;
    // rarely, far off from one side, a wolf in the deep forest and the mountain rumbling in the cave.
    LaunchedEffect(game.state.place.map) {
        val rnd = kotlin.random.Random(game.state.steps)
        val wild = de.bornim.core.audio.WildSound
        val kind = wild.kindOf(game.map)
        var now = 0L
        var nextLife = wild.LIFE_MIN_MS + rnd.nextLong(wild.LIFE_SPAN_MS)
        var nextFar = wild.firstFarMs(rnd)
        while (isActive) {
            val wait = minOf(nextLife, nextFar) - now
            delay(wait); now += wait
            val calm = game.mode == Mode.Explore && !vm.menuOpen
            if (now >= nextLife) {
                if (calm) wild.life(kind, game.isNight, game.raining, rnd)?.let { vm.play(it, wild.LIFE_VOLUME) }
                nextLife = now + wild.LIFE_MIN_MS + rnd.nextLong(wild.LIFE_SPAN_MS)
            }
            if (now >= nextFar) {
                if (calm) wild.far(kind)?.let { vm.playFrom(it, wild.farVolume(it, rnd), wild.side(rnd)) }
                nextFar = now + wild.farGapMs(kind, game.isNight, rnd)
            }
        }
    }

    // The fire's crackle swells as the hero walks up to a campfire or a hearth and fades as he leaves it or a fight
    // starts (18i): one take loops without a seam and stays until it has faded out, the next fire picks a new one (18k).
    // Drops fall in the cave on their own, fire or not (18h), the first at once.
    // The sound of the place (24.8) starts with the black screen, before the picture: wind outside, the temple's hall
    // swell in and loop, and die away in 0.6 s when the place is left (24.8.5); the inn's people and the houses' wood
    // make single sounds now and then (24.8.4).
    LaunchedEffect(game.state.place.map) {
        val rnd = kotlin.random.Random(game.state.steps + 1)
        val tick = 100L
        var fire = 0f
        var crackle = 0
        var now = 0L
        var nextDrip = 300L + rnd.nextLong(500)
        val place = de.bornim.core.audio.PlaceSound.kindOf(game.map)
        val bedSound = de.bornim.core.audio.PlaceSound.bed(place)
        var bed = 0f
        var bedStream = 0
        var nextEvent = de.bornim.core.audio.PlaceSound.firstMs(place, rnd)
        var lastEvent: de.bornim.core.audio.Sound? = null
        // D1.10: what the people do with their hands is heard with the movement, on the clock their pictures run on
        var folkHeardTo = clock
        val folkStill = MapFolk.Stillness()
        // the pond (27j): calls of the frogs on the bank and dragonflies darting close, the chorus at dusk
        val outside = game.map.kind == MapKind.TOWN || game.map.kind == MapKind.FOREST
        val pond = if (outside) de.bornim.core.art.PondLife.of(game.map).takeIf { it.frogs.isNotEmpty() || it.flies.isNotEmpty() } else null
        val ear = pond?.let { de.bornim.core.audio.PondSound.Ear(it) }
        var chorus = 0f
        var chorusStream = 0
        // the river (D6.4): running water rushes, swelling towards the bank and the bridge
        var river = 0f
        var riverStream = 0
        // the rain (D3.10): out of doors as heavy as it falls
        var rain = 0f
        var rainStream = 0
        // the hens (83c): clucking, scratching, alarm and wings, from what each hen is doing
        val henEar = if (game.map.kind == MapKind.TOWN) de.bornim.core.art.MapHen.of(game.map).takeIf { it.isNotEmpty() }?.let { de.bornim.core.audio.HenSound.Ear(it) } else null
        // the small birds pecking on the grass (84): wings as one flies up, now and then a scratch as it hops
        val birdEar = if (outside) de.bornim.core.audio.WildSound.BirdEar(game.map) else null
        try {
            while (isActive) {
                delay(tick)
                now += tick
                val calm = game.mode == Mode.Explore && !vm.menuOpen
                val p = game.state.place
                val target = if (calm) de.bornim.core.audio.Ambience.fireTarget(de.bornim.core.audio.Ambience.nearestFire(game.map, p.x, p.y)) else 0f
                fire = de.bornim.core.audio.Ambience.approach(fire, target, tick)
                when {
                    fire > 0f && crackle == 0 -> crackle = vm.sfx.loop(de.bornim.core.audio.Sound.CRACKLE, fire)
                    fire == 0f && crackle != 0 -> { vm.sfx.stop(crackle); crackle = 0 }
                    else -> vm.sfx.volume(crackle, fire)
                }
                if (bedSound != null) {
                    bed = de.bornim.core.audio.PlaceSound.approach(bed, if (calm) de.bornim.core.audio.PlaceSound.BED_VOLUME else 0f, tick)
                    when {
                        bed > 0f && bedStream == 0 -> bedStream = vm.sfx.loop(bedSound, bed)
                        bed == 0f && bedStream != 0 -> { vm.sfx.stop(bedStream); bedStream = 0 }
                        else -> vm.sfx.volume(bedStream, bed)
                    }
                }
                if (now >= nextEvent) {
                    if (calm) {
                        val events = de.bornim.core.audio.PlaceSound.events(place, de.bornim.core.audio.PlaceSound.present(game.map, game.state))
                        de.bornim.core.audio.PlaceSound.pick(events, lastEvent, rnd)?.let { vm.play(it, de.bornim.core.audio.PlaceSound.EVENT_VOLUME); lastEvent = it }
                    }
                    nextEvent = now + de.bornim.core.audio.PlaceSound.gapMs(place, rnd)
                }
                val folkTo = clock
                if (calm) for (s in de.bornim.core.audio.PlaceSound.folk(game.map, game.state, folkHeardTo, folkTo, p.x, p.y, folkStill.forMs(p.x, p.y, folkTo)))
                    vm.play(s, de.bornim.core.audio.PlaceSound.EVENT_VOLUME)
                folkHeardTo = folkTo
                if (pond != null && ear != null && de.bornim.core.art.PondLife.draft) {
                    val hx = (p.x + 0.5f) * de.bornim.core.art.WorldArt.T; val hy = (p.y + 0.5f) * de.bornim.core.art.WorldArt.T
                    val dusk = game.daylight < 0.55f
                    val heard = ear.hear(clock, hx, hy, dusk, flying = game.daylight > 0.4f && !game.raining)
                    if (calm) for ((s, v) in heard) vm.play(s, v)
                    val want = if (calm) de.bornim.core.audio.PondSound.chorusTarget(pond, hx, hy, dusk) else 0f
                    chorus = de.bornim.core.audio.PlaceSound.approach(chorus, want, tick)
                    when {
                        chorus > 0f && chorusStream == 0 -> chorusStream = vm.sfx.loop(de.bornim.core.audio.Sound.FROG_CHORUS, chorus)
                        chorus == 0f && chorusStream != 0 -> { vm.sfx.stop(chorusStream); chorusStream = 0 }
                        else -> vm.sfx.volume(chorusStream, chorus)
                    }
                }
                if (outside) {
                    val want = if (calm) de.bornim.core.audio.RiverSound.target(de.bornim.core.audio.RiverSound.nearest(game.map, p.x, p.y)) else 0f
                    river = de.bornim.core.audio.RiverSound.approach(river, want, tick)
                    when {
                        river > 0f && riverStream == 0 -> riverStream = vm.sfx.loop(de.bornim.core.audio.Sound.RIVER, river)
                        river == 0f && riverStream != 0 -> { vm.sfx.stop(riverStream); riverStream = 0 }
                        else -> vm.sfx.volume(riverStream, river)
                    }
                }
                rain = de.bornim.core.audio.RainSound.approach(rain, de.bornim.core.audio.RainSound.target(game.map.kind, game.rainLevel, calm), tick)
                when {
                    rain > 0f && rainStream == 0 -> rainStream = vm.sfx.loop(de.bornim.core.audio.Sound.RAIN, rain)
                    rain == 0f && rainStream != 0 -> { vm.sfx.stop(rainStream); rainStream = 0 }
                    else -> vm.sfx.volume(rainStream, rain)
                }
                if (henEar != null && de.bornim.core.art.MapHen.draft) {
                    val heard = henEar.hear((p.x + 0.5f) * de.bornim.core.art.WorldArt.T, (p.y + 0.5f) * de.bornim.core.art.WorldArt.T)
                    if (calm) for ((s, v) in heard) vm.play(s, v)
                }
                if (birdEar != null) {
                    val fw = game.freeWalk
                    val out = calm && de.bornim.core.art.MapBirds.out(game.map, game.daylight, game.raining)
                    for ((s, v) in birdEar.hear(clock, ((fw.x - 0.5) * de.bornim.core.art.WorldArt.T).roundToInt(), ((fw.y - 0.5) * de.bornim.core.art.WorldArt.T).roundToInt(), out)) vm.play(s, v)
                }
                if (game.map.kind == MapKind.CAVE && now >= nextDrip) {
                    if (calm) vm.play(de.bornim.core.audio.Sound.DRIP, de.bornim.core.audio.Ambience.dripVolume(fire))
                    nextDrip = now + de.bornim.core.audio.Ambience.DRIP_MIN_MS + rnd.nextLong(de.bornim.core.audio.Ambience.DRIP_SPAN_MS)
                }
            }
        } finally {
            // leaving the place: its loops die away instead of breaking off (24.8.5)
            vm.sfx.fadeOut(crackle, fire)
            vm.sfx.fadeOut(bedStream, bed)
            vm.sfx.fadeOut(chorusStream, chorus)
            vm.sfx.fadeOut(riverStream, river)
            vm.sfx.fadeOut(rainStream, rain)
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
            // 86.2: the map sign beside the bag, not while talking or fighting
            onMap = if (game.mode == Mode.Explore) ({ vm.openMap() }) else null,
        ) { if (game.mode == Mode.Explore) vm.menuOpen = true }
        Box(
            Modifier
                .weight(1f)
                .fillMaxWidth()
                .clipToBounds()
                .background(Color.Black)
        ) {
            MapView(game, rev, route?.target, clock)
            // test tab (27m, 86.1): frame rate and the hero's place, top left over the map
            TestReadout(game, rev, Modifier.align(Alignment.TopStart))
            StaminaBar(game.state, rev, Modifier.align(Alignment.CenterEnd).padding(end = 10.dp))
            if (touch) {
                TouchLayer(
                    feel = vm.stickFeel,
                    runs = game.state.running,
                    haptics = vm.haptics,
                    onDir = { d -> heldDir = d },
                    onStick = { stick = it },
                    onRun = { running = it },
                    onTap = { pos, w, h ->
                        if (dialog != null) {
                            pressA()
                        } else if (game.mode == Mode.Explore) {
                            val cam = camera(game, w, h)
                            val fx = floor(cam.mapX(pos.x, pos.y) / WorldArt.T).toInt()
                            val fy = floor(cam.mapY(pos.x, pos.y) / WorldArt.T).toInt()
                            // seen diagonally in a room, the thing whose picture is tapped counts, not the floor behind it (13p.5)
                            val (tx, ty) = tappedThing(game, cam, pos.x, pos.y, fx, fy) ?: (fx to fy)
                            val p = game.state.place
                            if (tx == p.x && ty == p.y) {
                                pressA()
                            } else {
                                route = game.route(tx, ty)
                                routeIdx = 0
                                // walking freely (13g), the planned way becomes tile centres to walk through
                                waypoints = route?.let { rt ->
                                    var cx = p.x; var cy = p.y
                                    rt.steps.map { d -> cx += d.dx; cy += d.dy; (cx + 0.5) to (cy + 0.5) }
                                } ?: emptyList()
                                if (route == null) buzz()
                            }
                        }
                    },
                )
            }
            if (touch && dialog == null && action != null) {
                ActionButton(
                    ActionArt.icon(action), 76.dp,
                    Modifier
                        .align(if (vm.leftHanded) Alignment.BottomStart else Alignment.BottomEnd)
                        .padding(22.dp),
                ) { pressed -> if (pressed) pressA() }
                // 215: where the way out leads; 254: beside the button, the run button above it hid it
                game.actionPlace()?.let { place ->
                    Txt(place(game.lang), Modifier.align(if (vm.leftHanded) Alignment.BottomStart else Alignment.BottomEnd)
                        .padding(start = 106.dp, end = 106.dp, bottom = 46.dp)
                        .background(Colors.nightLight.copy(alpha = 0.85f), RoundedCornerShape(6.dp)).padding(horizontal = 8.dp, vertical = 3.dp),
                        size = 14.sp, bold = true, color = Colors.gold)
                }
            }
            // 131: the run button, if chosen in the menu, above the action button
            if (touch && vm.runButton && dialog == null && game.mode == Mode.Explore) {
                ActionButton(
                    ActionArt.icon(ActionArt.Extra.RUN), 58.dp,
                    Modifier
                        .align(if (vm.leftHanded) Alignment.BottomStart else Alignment.BottomEnd)
                        .padding(start = 31.dp, end = 31.dp, bottom = 112.dp),
                    dim = !runLatch,
                ) { pressed -> if (pressed) runLatch = !runLatch }
            }
            // Pass the current values: the Game object itself never changes, so Compose
            // would otherwise skip redrawing these after a heal or a map change.
            // t60: drawn after the buttons, so the black screen covers them too
            MapVeil(game, game.state.place.map)
            if (dialog != null) {
                DialogBox(
                    speaker = dialog.speaker,
                    text = dialog.text.take(revealed),
                    full = dialog.text,
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
                    heldDir = d
                },
                onAction = { pressA() },
                onRun = { pressed -> running = pressed },
            )
        }
    }
}

/** Where the camera is: pixel zoom and the top-left corner of the view in art pixels. */
/**
 * The map camera. Drawing code works in "straight" screen pixels, (map pixel − ([x], [y])) × [scale], as
 * before. Seen diagonally (13), straight pixels are mapped onto the screen by [toScreenX]/[toScreenY]: the
 * map turned by 45° into diamonds (2:1), so the ground can be drawn as before under that mapping, while
 * upright things stand at the mapped point of their feet. [viewW]/[viewH] is the part of the map to draw,
 * in map pixels from ([x], [y]).
 */
private class Cam(
    val scale: Int, val x: Int, val y: Int, val heroX: Int, val heroY: Int,
    val viewW: Float, val viewH: Float,
    /** Translation of the diagonal mapping, in screen pixels. */
    val tx: Float = 0f, val ty: Float = 0f,
) {
    private val k = MapSight.K
    fun toScreenX(sx: Float, sy: Float) = k * (sx - sy) + tx
    fun toScreenY(sx: Float, sy: Float) = k / 2 * (sx + sy) + ty

    /** The map pixel under a point of the screen. */
    fun mapX(px: Float, py: Float): Float {
        val u = (px - tx) / k; val v = (py - ty) * 2 / k
        return (u + v) / 2 / scale + x
    }
    fun mapY(px: Float, py: Float): Float {
        val u = (px - tx) / k; val v = (py - ty) * 2 / k
        return (v - u) / 2 / scale + y
    }

    /** The mapping as a matrix for the canvas. */
    fun matrix(): androidx.compose.ui.graphics.Matrix = androidx.compose.ui.graphics.Matrix().apply {
        values[androidx.compose.ui.graphics.Matrix.ScaleX] = k
        values[androidx.compose.ui.graphics.Matrix.SkewX] = -k
        values[androidx.compose.ui.graphics.Matrix.SkewY] = k / 2
        values[androidx.compose.ui.graphics.Matrix.ScaleY] = k / 2
        values[androidx.compose.ui.graphics.Matrix.TranslateX] = tx
        values[androidx.compose.ui.graphics.Matrix.TranslateY] = ty
    }
}

/** The see-through of what stands in front of the hero, fading softly in and out instead of jumping (test of 0.1.576). */
private object SeeThrough {
    private val now = HashMap<Long, Float>()
    private var mapId = ""
    private var last = 0L
    private var step = 0f

    /** Called once a frame, before [alpha]: a new place starts with everything solid. */
    fun frame(map: String, clock: Long) {
        if (map != mapId) { mapId = map; now.clear() }
        step = ((clock - last).coerceIn(0L, 100L) / 300f)
        last = clock
    }

    /** The alpha of the thing [key] this frame, a step closer to [target]: about 0.3 s from solid to clear. */
    fun alpha(key: Long, target: Float): Float {
        val cur = now[key] ?: 1f
        val next = if (cur < target) minOf(target, cur + step) else maxOf(target, cur - step)
        if (next >= 1f) now.remove(key) else now[key] = next
        return next
    }
}

/** The diagonal view of the map (13); the straight one is gone (13t). */
object MapSight {
    /** Every doll is drawn turned by 45° on the screen ([de.bornim.core.art.MapFigure.viewYaw]). */
    fun follow() { de.bornim.core.art.MapFigure.viewYaw = -45.0 }

    /** A tile's diamond is 2·[K]·T map pixels wide and half as high: its diagonal as long as a tile's side (45 for 32). */
    const val K = 0.703125f
}

/** How close the map camera is. Near (the new default) shows about 5½ tiles across, far the former 10½. */
object MapZoom {
    /**
     * Tiles across the screen, to try on the phone (10.10., 6.15): 5.6 (near, so far the default), 6.75 and
     * 8.4 in between, 10.5 the former far view. Each is a whole-number zoom on a screen 1080 pixels wide.
     */
    val levels = floatArrayOf(5.6f, 6.75f, 8.4f, 10.5f)
    /** 6.75 tiles for now (10.10., 16:15; the final step is decided later). */
    @Volatile var level = 1

    /** Near: any step but the former far one. */
    var near: Boolean
        get() = level < levels.size - 1
        set(v) { level = if (v) 0 else levels.size - 1 }

    /** Tiles across the screen. */
    val tilesAcross get() = levels[level]
}

private fun camera(game: Game, w: Float, h: Float): Cam {
    val map = game.map
    MapSight.follow()
    val T = WorldArt.T
    // Whole-number zoom so every art pixel is the same size on screen. Near, the zoom is even, so
    // map pictures drawn at double resolution also land on whole screen pixels.
    // (an odd zoom puts the double-resolution pictures half a pixel off; they are then smoothed a little when drawn)
    val scale = if (MapZoom.near) max(2, (w / (T * MapZoom.tilesAcross)).roundToInt()) else max(2, floor(w / (T * MapZoom.tilesAcross)).toInt())
    val viewW = w / scale
    val viewH = h / scale
    // Positions in art pixels, rounded so tiles and sprites move in lockstep.
    // walking freely (13g, with the diagonal view), the hero stands between the tiles
    val fw = game.freeWalk.also { it.sync() }
    val heroX = ((fw.x - 0.5) * T).roundToInt()
    val heroY = ((fw.y - 0.5) * T).roundToInt()
    // the hero's feet in the middle of the screen, a little below the centre; the part of the map
    // under the screen's corners decides what is drawn (a turned rectangle, so somewhat more)
    val k = MapSight.K
    val hx = heroX + T / 2f; val hy = heroY + T * 0.3f
    val camPX = k * (hx - hy) - viewW / 2; val camPY = k / 2 * (hx + hy) - viewH * 0.55f
    fun wx(u: Float, v: Float) = (u / k + 2 * v / k) / 2
    fun wy(u: Float, v: Float) = (2 * v / k - u / k) / 2
    val us = floatArrayOf(camPX, camPX + viewW); val vs = floatArrayOf(camPY, camPY + viewH)
    var x0 = Float.MAX_VALUE; var x1 = -Float.MAX_VALUE; var y0 = Float.MAX_VALUE; var y1 = -Float.MAX_VALUE
    for (u in us) for (v in vs) { val a = wx(u, v); val b = wy(u, v); x0 = minOf(x0, a); x1 = maxOf(x1, a); y0 = minOf(y0, b); y1 = maxOf(y1, b) }
    // room above for tall things standing below the screen's lower edge
    val camX = floor(x0).toInt() - T; val camY = floor(y0).toInt() - T
    val vw = x1 - x0 + 3 * T; val vh = y1 - y0 + 3 * T
    val tx = scale * (k * (camX - camY) - camPX); val ty = scale * (k / 2 * (camX + camY) - camPY)
    return Cam(scale, camX, camY, heroX, heroY, vw, vh, tx, ty)
}

/**
 * Touch movement: dragging shows a small joystick under the finger and walks in the dragged
 * direction (snapped to the four grid directions, far = run); a short tap reports its position.
 */
/**
 * Seen diagonally in a room (13p.5): the tile of the frontmost upright thing whose picture lies under the
 * tap at ([px], [py]), if the hero can walk onto it or use it; null to take the floor tile ([fx], [fy])
 * under the tap. A low thing stands out of its tile towards the back, so its upper part covers the floor
 * of the tile behind it (a barrel, a wall), which a tap would otherwise choose.
 */
private fun tappedThing(game: Game, cam: Cam, px: Float, py: Float, fx: Int, fy: Int): Pair<Int, Int>? {
    if (game.map.kind != MapKind.INTERIOR) return null
    val map = game.map
    val walls = setOf(Tile.WALL, Tile.WINDOW, Tile.HEARTH, Tile.DOOR)
    var best: Pair<Int, Int>? = null
    var bestKey = -Float.MAX_VALUE
    // pictures stand up from their tile, so only tiles at or in front of the tapped floor can cover it
    for (ty in fy - 1..fy + 3) for (tx in fx - 1..fx + 3) {
        if (!map.inside(tx, ty) || map.tile(tx, ty) in walls) continue
        val objs = de.bornim.core.art.MapRoomIso.objects(map, tx, ty) ?: continue
        for (o in objs) {
            val dw = o.img.width.toFloat() * cam.scale / o.density; val dh = o.img.height.toFloat() * cam.scale / o.density
            val sx = (o.x - cam.x) * cam.scale + dw / 2f; val sy = (o.y - cam.y) * cam.scale + dh
            val left = cam.toScreenX(sx, sy) - dw / 2f; val top = cam.toScreenY(sx, sy) - dh
            val ix = ((px - left) * o.density / cam.scale).toInt(); val iy = ((py - top) * o.density / cam.scale).toInt()
            if (ix !in 0 until o.img.width || iy !in 0 until o.img.height) continue
            if ((o.img[ix, iy] ushr 24) < 60) continue
            // drawn along the diagonal: the later, the further in front
            val key = o.sortY + o.x + o.img.width / o.density / 2f
            if (key > bestKey) { bestKey = key; best = tx to ty }
        }
    }
    val b = best ?: return null
    return b.takeIf { (x, y) -> game.free(x, y) || game.actionAt(x, y) != null }
}

@Composable
private fun TouchLayer(feel: Int, runs: Boolean, haptics: Boolean, onDir: (Facing?) -> Unit, onStick: (Offset?) -> Unit, onRun: (Boolean) -> Unit, onTap: (Offset, Float, Float) -> Unit) {
    var origin by remember { mutableStateOf<Offset?>(null) }
    var knob by remember { mutableStateOf(Offset.Zero) }
    var stickDir by remember { mutableStateOf<Facing?>(null) }
    val density = LocalDensity.current
    // 86.4: the menu's joystick setting, how far a drag goes before the hero walks and runs
    val slop = with(density) { StickFeel.walkAt(feel).dp.toPx() }
    // 131: inside the ring the hero walks, pushed past it he runs
    val runAt = with(density) { StickFeel.runAt(feel).dp.toPx() }
    val radius = runAt * 1.15f
    // 131: a short buzz when the hero starts or stops running, the ring turns gold while he runs
    val haptic = LocalHapticFeedback.current
    var ranBefore by remember { mutableStateOf(runs) }
    if (runs != ranBefore) {
        ranBefore = runs
        if (haptics && origin != null) haptic.performHapticFeedback(if (runs) HapticFeedbackType.LongPress else HapticFeedbackType.TextHandleMove)
    }
    Box(
        Modifier
            .fillMaxSize()
            .pointerInput(feel) {
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
                            // Snap to the grid directions; the current one wins near the diagonal. Seen diagonally
                            // (13), the grid runs slanted on the screen: the drag is turned into the map first.
                            val g = Offset((d.x + 2 * d.y) / 2, (2 * d.y - d.x) / 2)
                            val ax = abs(g.x); val ay = abs(g.y)
                            val horizontal = when (dir) {
                                Facing.LEFT, Facing.RIGHT -> ax * 1.3f >= ay
                                Facing.UP, Facing.DOWN -> ax > ay * 1.3f
                                null -> ax > ay
                            }
                            val nd = if (len < slop) dir
                            else if (horizontal) (if (g.x > 0) Facing.RIGHT else Facing.LEFT)
                            else (if (g.y > 0) Facing.DOWN else Facing.UP)
                            if (nd != dir) {
                                dir = nd
                                stickDir = nd
                                onDir(nd)
                            }
                            onRun(len > runAt)
                            // the drag itself, for walking freely in any direction (13g)
                            onStick(if (len < slop) null else d)
                        }
                    }
                    if (dragging) {
                        onDir(null)
                        onStick(null)
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
                drawCircle(Color.White.copy(alpha = 0.07f), runAt, o)
                if (runs) drawCircle(Colors.gold.copy(alpha = 0.9f), runAt, o, style = androidx.compose.ui.graphics.drawscope.Stroke(4.dp.toPx()))
                else drawCircle(Color.White.copy(alpha = 0.4f), runAt, o, style = androidx.compose.ui.graphics.drawscope.Stroke(2.dp.toPx()))
                drawCircle((if (runs) Colors.gold else Color.White).copy(alpha = 0.7f), 19.dp.toPx(), o + knob)
            }
        }
    }
}

@Composable
private fun MapView(game: Game, rev: Int, marker: Pair<Int, Int>?, clock: Long) {
    val time = rememberTime()
    val frame = ((time / 450) % 2).toInt()
    Canvas(Modifier.fillMaxSize()) {
        rev.hashCode() // read so the canvas redraws on game changes
        if (FrameMeter.on) FrameMeter.tick(System.nanoTime())
        val state = game.state
        val map = game.map
        val T = WorldArt.T
        val cam = camera(game, size.width, size.height)
        val scale = cam.scale
        val viewW = cam.viewW
        val viewH = cam.viewH
        val p = state.place
        val heroX = cam.heroX
        val heroY = cam.heroY
        val camX = cam.x
        val camY = cam.y
        // seen diagonally: true while drawing what lies flat on the ground (drawn under the turned mapping)
        var flat = false
        /** Draws what lies on the ground; seen diagonally, under the turned mapping. */
        fun ground(block: () -> Unit) {
            flat = true
            withTransform({ transform(cam.matrix()) }) { block() }
            flat = false
        }

        /**
         * Draws [img] at map pixel ([x], [y]); [density] art pixels per map pixel (2 for the new, finer pictures).
         * Seen diagonally, a picture drawn outside [ground] stands upright on the mapped point of its lower middle.
         */
        /** Where on the screen [put] draws the top left corner of [img]. */
        fun placeOf(img: PixelImage, x: Int, y: Int, density: Int = 1, corner: Boolean = false): IntOffset {
            val dw = img.width * scale / density; val dh = img.height * scale / density
            val sx = (x - camX) * scale
            val sy = (y - camY) * scale
            if (flat) return IntOffset(sx, sy)
            // pictures made for the straight view stand on the lower edge of their tile: seen diagonally their feet
            // go to the tile's middle, half a tile up (13p, 6: the hero stood in the tile's front left corner);
            // the rooms' pictures seen diagonally ([corner]) are made with the tile's front corner at their foot
            val lift = if (corner) 0 else T / 2 * scale
            val fx = sx + dw / 2f; val fy = (sy + dh - lift).toFloat()
            return IntOffset((cam.toScreenX(fx, fy) - dw / 2f).roundToInt(), (cam.toScreenY(fx, fy) - dh).roundToInt())
        }

        // while true, [put] cuts the picture out of what is drawn below it (the lit windows behind something in front)
        var cutting = false
        fun put(img: PixelImage, x: Int, y: Int, density: Int = 1, alpha: Float = 1f, corner: Boolean = false, bleed: Int = 0,
                filter: androidx.compose.ui.graphics.ColorFilter? = null) {
            val dw = img.width * scale / density + bleed; val dh = img.height * scale / density + bleed
            val (sx, sy) = placeOf(img, x, y, density, corner)
            if (!flat && (sx > size.width || sy > size.height || sx + dw < 0 || sy + dh < 0)) return
            drawImage(
                image = Bitmaps.of(img),
                srcOffset = IntOffset.Zero,
                srcSize = IntSize(img.width, img.height),
                dstOffset = IntOffset(sx, sy),
                dstSize = IntSize(dw, dh),
                alpha = alpha,
                colorFilter = filter,
                filterQuality = if (density > 1 && scale % density != 0) FilterQuality.Low else FilterQuality.None,
                blendMode = if (cutting) androidx.compose.ui.graphics.BlendMode.DstOut else DrawScope.DefaultBlendMode,
            )
        }
        /** Whether the picture of [o] on the screen meets the screen rectangle [box]. */
        fun overlaps(o: WorldArt.Obj, box: androidx.compose.ui.geometry.Rect): Boolean {
            val (sx, sy) = placeOf(o.img, o.x, o.y, o.density, o.corner)
            val dw = o.img.width * scale / o.density; val dh = o.img.height * scale / o.density
            return sx < box.right && sx + dw > box.left && sy < box.bottom && sy + dh > box.top
        }

        // the shadow layer of the sun and how strongly it shows now (by day, faded in)
        val sunNow = ((game.daylight - 0.2f) / 0.6f).coerceIn(0f, 1f)
        val sunLayer = if (sunNow > 0.02f) MapFlora.shadowsReady(map) else null
        val sunShade = sunLayer?.let { sunNow * ((System.nanoTime() - it.at) / 4e8).toFloat().coerceIn(0f, 1f) } ?: 0f
        /**
         * 89: a person standing in the shadow of a house or a crown is drawn as dark as the ground there; [fx], [fy] the
         * feet in map pixels. Steps of 1/32, so the filters are few.
         */
        val shaded = HashMap<Int, androidx.compose.ui.graphics.ColorFilter>()
        fun shadeAt(fx: Int, fy: Int): androidx.compose.ui.graphics.ColorFilter? {
            val r = sunLayer ?: return null
            val b = 1f - (1f - de.bornim.core.art.MapSun.bright(r, fx.toDouble() / T, fy.toDouble() / T)) * sunShade
            val q = ((1f - b) * 32).roundToInt()
            if (q <= 0) return null
            return shaded.getOrPut(q) { (1f - q / 32f).let { m -> androidx.compose.ui.graphics.ColorFilter.lighting(Color(m, m, m), Color.Black) } }
        }

        ground {
        // 1) ground: without a grid, drawn ahead in the background
        val x0 = floor(camX.toFloat() / T).toInt()
        val y0 = floor(camY.toFloat() / T).toInt()
        val x1 = ((camX + viewW) / T).toInt()
        val y1 = ((camY + viewH) / T).toInt()
        MapGround.prepare(map, p.x, p.y)
        val ch = MapGround.CH
        for (cy in Math.floorDiv(y0, ch)..Math.floorDiv(y1, ch)) for (cx in Math.floorDiv(x0, ch)..Math.floorDiv(x1, ch)) {
            // the piece the hero stands on right away, the rest stays dark for the moment it takes, drawn on several cores (23:04)
            val here = cx == Math.floorDiv(p.x, ch) && cy == Math.floorDiv(p.y, ch)
            (if (here) MapGround.chunkNow(map, cx, cy) else MapGround.chunk(map, cx, cy))?.let {
                // turned, the edges of a piece are smoothed and the black below showed through as a thin seam (27):
                // each piece reaches two pixels into the next
                put(it, cx * ch * T, cy * ch * T, MapGround.D, bleed = 2)
            }
        }

        // shadows of trees, rocks and stones on the ground, strong by day, gone at night
        // D9.2: drawn in the background; once there they fade in over 0.4 s rather than appear at once
        if (sunLayer != null) for (o in sunLayer.pieces) put(o.img, o.x, o.y, o.density, sunShade)
        // 221: glints drifting on the water
        if (map.kind == MapKind.FOREST || map.kind == MapKind.TOWN) drawWaterGlints(game, map, clock, camX, camY, scale, viewW, viewH)

        // draft (idea 7): blood where a foe fell, footprints in the wet ground, dust kicked up running
        if (de.bornim.core.Tracks.draft) drawTracks(game.tracks.on(map.id, clock), clock, camX, camY, scale)

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
        /** D3.6: a shadow as wide as [pic] (a monster on the map, in map pixels), under the tile's middle like a person's. */
        fun putShadow(pic: MapFoe.Pic?, x: Int, y: Int) {
            val sh = if (pic == null) WorldArt.shadow() else WorldArt.shadow(pic.img.width * 4 / (5 * MapFigure.DENSITY))
            put(sh, x + T / 2 - sh.width / 2, y + 30 - sh.height / 2)
        }
        val visibleNpcs = map.npcs.filter { it.visible(state) && !game.indoors(it) }
        // Strolling villagers slide between tiles like the hero.
        fun npcPos(npc: de.bornim.core.Npc): Pair<Int, Int> {
            // standing still: close to the fire (Garrick, 3b) or up to the counter (87.2)
            val w = game.walkerOf(npc) ?: return de.bornim.core.art.MapFolk.nudge(npc, map).let { (ox, oy) -> npc.x * T + ox to npc.y * T + oy }
            val t = ((clock - w.movedAt).toFloat() / w.moveMs).coerceIn(0f, 1f)
            return ((w.fromX + (w.x - w.fromX) * t) * T).roundToInt() to ((w.fromY + (w.y - w.fromY) * t) * T).roundToInt()
        }
        // 89: by day under the open sky the people throw their shadow by the sun, lying on the ground with the rest
        val sunUp = ((game.daylight - 0.2f) / 0.6f).coerceIn(0f, 1f)
        if (sunUp > 0.02f && (map.kind == MapKind.FOREST || map.kind == MapKind.TOWN)) ground {
            val f = de.bornim.core.art.MapSun.figure()
            for (npc in visibleNpcs) if (!npc.look.startsWith("monster:")) npcPos(npc).let { (nx, ny) -> put(f.img, nx + T / 2 - f.fx, ny + 14 - f.fy, alpha = sunUp) }
            put(f.img, heroX + T / 2 - f.fx, heroY + 14 - f.fy, alpha = sunUp)
        }
        for (npc in visibleNpcs) if (!npc.look.startsWith("monster:")) {
            val (nx, ny) = npcPos(npc)
            put(WorldArt.shadow(), nx + 4, ny + 26)
        }
        put(WorldArt.shadow(), heroX + 4, heroY + 26)

        // 3) objects and characters, sorted by their foot line
        val sprites = mutableListOf<Sprite>()
        val glowing = mutableListOf<Triple<WorldArt.Obj, Float, Sprite>>()
        // a tree crown standing in front of the hero turns half see-through, so the hero is not lost behind it
        fun hides(o: WorldArt.Obj): Boolean {
            val w = o.img.width / o.density; val h = o.img.height / o.density
            // seen diagonally, anything taller than a knee can stand in front of the hero
            if (h < 24 || o.low) return false
            // a house's strip (27d): the hero stands where free walking stops him, often closer to the wall than the
            // tile's middle the strips are sorted by; south of its front wall or east of its side wall the house
            // cannot cover him, however its strips lie
            o.area?.let { f -> if (heroY + T / 2 > (f.y + 1) * T || heroX + T / 2 > (f.x + f.n) * T) return false }
            // seen diagonally: in front of the hero (further down the diagonal) and over it on the screen
            val k = MapSight.K
            val fx = o.x + w / 2f; val fy = (o.y + h).toFloat() - (if (o.corner) 0f else T / 2f)
            val hx = heroX + T / 2f; val hy = heroY + T / 2f
            if (o.sortY + o.x + w / 2f <= hx + hy) return false
            val ox = k * (fx - fy); val oy = k / 2 * (fx + fy)
            val px = k * (hx - hy); val py = k / 2 * (hx + hy)
            if (!(px + 8 > ox - w / 2f && px - 8 < ox + w / 2f && py > oy - h + 6 && py - 38 < oy)) return false
            // only when something drawn really lies over the hero's body (5.2: a well beside the hero stays solid), and
            // over the upper body: what reaches no higher than the hips (a counter, a bench, a chest, a fence) covers
            // only the legs and stays solid (test of 0.1.590: Thessa's counter faded away)
            for (dy in 18..38 step 4) for (dx in -6..6 step 6) {
                val ix = ((px + dx - (ox - w / 2f)) * o.density).toInt(); val iy = ((py - dy - (oy - h)) * o.density).toInt()
                if (o.img.opaque(ix, iy)) return true
            }
            return false
        }
        // seen diagonally, the fire in a room's hearth flickers through more pictures, each standing an uneven while (13n)
        val flicker = if (map.kind == MapKind.INTERIOR) de.bornim.core.art.MapRoomIso.fireFrame(clock) else 0
        val objs = WorldArt.objects(map, state, frame, flicker)
        // a house cut into strips (5.1) turns see-through as a whole when any strip of it stands in front of the hero
        val hidingGroups = objs.filter { it.group != 0 && hides(it) }.mapTo(HashSet()) { it.group }
        val hiding = objs.mapTo(ArrayList()) { if (it.group != 0) it.group in hidingGroups else hides(it) }
        // (43; test of 0.1.576: 0.2 too strong; 27e.1: 35 % too weak): together the things in front of the hero cover him
        // to half, however many stand one behind the other, and they fade softly in and out; the same for crowns, houses
        // and furniture, seen straight too (27e: in the deep forest three crowns one behind the other hid him wholly)
        val layers = objs.indices.filter { hiding[it] }.map { objs[it].let { o -> if (o.group != 0) -o.group.toLong() else o.x.toLong() * 100_003 + o.y } }.distinct().size
        val clear = 1f - Math.pow(0.5, 1.0 / maxOf(1, layers)).toFloat()
        SeeThrough.frame(map.id, clock)
        for ((i, o) in objs.withIndex()) {
            val a = SeeThrough.alpha(if (o.group != 0) -o.group.toLong() else o.x.toLong() * 100_003 + o.y, if (hiding[i]) clear else 1f)
            val sp = Sprite(o.sortY.toFloat(), o.x + o.img.width / o.density / 2f, o) { put(o.img, o.x, o.y, o.density, a, o.corner) }
            sprites += sp
            if (o.glow != null) glowing += Triple(o, a, sp)
        }
        // Healing herbs on the flower meadows, swaying gently so they catch the eye.
        if (map.kind == MapKind.FOREST) for (ty in 0 until map.height) for (tx in 0 until map.width) {
            if (map.tile(tx, ty) != Tile.FLOWERS || !game.herbAt(tx, ty)) continue
            // seen diagonally (56): a herb drawn in the slant like the other things of the woods
            val o = de.bornim.core.art.MapWoodIso.herbObj(tx, ty, clock)
            sprites += Sprite(o.sortY.toFloat(), o.x + o.img.width / o.density / 2f, o) { put(o.img, o.x, o.y, o.density, 1f, o.corner) }
        }
        for (npc in visibleNpcs) {
            val bottom = npc.y * T + T - 1
            if (npc.look.startsWith("monster:")) {
                // a foe waiting in its lair, like the wandering ones, only shows while the hero can see it
                val id = npc.look.removePrefix("monster:")
                if (id in MapFoe.ON) {
                    // 9e: Grimfang and his guard as their battle models. Near the hero they turn to watch it and bare
                    // their fangs; else they stand about like the others (9d). Drawn ahead, before they come into sight.
                    val look = de.bornim.core.MonsterLook()
                    val bx = npc.x * T; val by = npc.y * T
                    val home = MapFigure.yawOf(npc.facing)
                    val hdx = (heroX - bx).toDouble(); val hdy = (heroY - by).toDouble()
                    val near = hdx * hdx + hdy * hdy < 25.0 * T * T
                    val turn = FolkTurn.of("boss:${npc.id}", home).also { it.update(if (near) Math.toDegrees(kotlin.math.atan2(hdx, hdy)) else home, clock) }
                    val slot = MapFigure.slot(turn.yaw)
                    val beast = id in de.bornim.core.art.BeastArt.KINDS
                    fun standPic(fid: String, flook: de.bornim.core.MonsterLook, seed: Int, scale: Double = 1.0): MapFoe.Pic? {
                        val st = MapFoe.idleAt(fid, seed, clock)
                        // baring the fangs comes on and goes off through in-between pictures (9h)
                        val bare = if (beast) BossMood.level("${npc.id}", near, clock) else 0
                        return if (bare > 0) MapFoe.idleNow(fid, flook, slot, MapFoe.Idle.SNARL, st.breath, scale, bare)
                            else MapFoe.idleNow(fid, flook, slot, st.idle, st.breath, scale, st.level)
                    }
                    val pic = standPic(id, look, npc.id.hashCode())
                    val pack = de.bornim.core.Packs[id]
                    val guards = if (pack == null) emptyList() else (0 until de.bornim.core.Packs.size(id, look)).map { i ->
                        standPic(pack.mate, de.bornim.core.MonsterLook(101 * (i + 1)), npc.id.hashCode() * 31 + i + 1,
                            if (pack.mate in de.bornim.core.art.BeastArt.KINDS) mapMateScale(pack).toDouble() else 1.0)
                    }
                    if (pic != null) {
                        if (game.fog(npc.x, npc.y) != de.bornim.core.Fog.VISIBLE) continue
                        val lit = warmEdge(pic.img, bx, by)
                        sprites += Sprite(bottom.toFloat(), bx + T / 2f) {
                            putShadow(pic, bx, by)
                            put(lit, bx + T / 2 - pic.ax / MapFigure.DENSITY, by + T - 3 - pic.ay / MapFigure.DENSITY, MapFigure.DENSITY)
                        }
                        // the guards at its sides, a little behind, whichever way it faces
                        guards.forEachIndexed { i, g0 ->
                            // each guard keeps its place at the boss's side, walking round when the boss turns (9g)
                            val (tx, ty) = MapFollow.place(bx, by, turn.yaw, 8.0, 30.0, if (i % 2 == 0) -1 else 1)
                            val f = MapFollow.update("boss:${npc.id}:$i", tx, ty, T * 1.4 / 480.0, clock, turn.yaw)
                            val gx = f.x.roundToInt(); val gy = f.y.roundToInt()
                            val gLook = de.bornim.core.MonsterLook(101 * (i + 1))
                            val gScale = if (pack!!.mate in de.bornim.core.art.BeastArt.KINDS) mapMateScale(pack).toDouble() else 1.0
                            val g = if (f.moving) MapFoe.pictureNow(pack.mate, gLook, MapFigure.slot(f.yaw),
                                Math.floorMod((f.dist / T * MapFoe.STEPS).toInt(), MapFoe.STEPS), gScale) else g0
                            if (g != null) {
                                val gl = warmEdge(g.img, gx, gy)
                                sprites += Sprite((gy + T - 1).toFloat(), gx + T / 2f) {
                                    putShadow(g, gx, gy)
                                    put(gl, gx + T / 2 - g.ax / MapFigure.DENSITY, gy + T - 3 - g.ay / MapFigure.DENSITY, MapFigure.DENSITY)
                                }
                            }
                        }
                        continue
                    }
                }
                if (game.fog(npc.x, npc.y) != de.bornim.core.Fog.VISIBLE) continue
                val img = MonsterArt.get(id)
                sprites += Sprite(bottom.toFloat(), npc.x * T + T / 2f) { put(img, npc.x * T + T / 2 - img.width / 2, bottom + 1 - img.height) }
                // A boss with a bodyguard: the guards sit at its sides.
                de.bornim.core.Packs[id]?.let { pack ->
                    for (i in 0 until de.bornim.core.Packs.size(id, de.bornim.core.MonsterLook())) {
                        val left = i % 2 == 0
                        val mate = MonsterArt.mapSprite(pack.mate, de.bornim.core.MonsterLook(101 * (i + 1)), ((clock / 260 + i) % 4).toInt(), mirrored = !left, scale = mapMateScale(pack))
                        val mx = npc.x * T + T / 2 - mate.width / 2 + (if (left) -(img.width / 2 + 4) else img.width / 2 + 4)
                        sprites += Sprite((bottom + 1).toFloat(), mx + mate.width / 2f) { put(mate, mx, bottom + 3 - mate.height) }
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
                    // on their way somewhere (5l) they look where they go, not at the hero: else they walk backwards (5la.2, test 0.1.650)
                    val enRoute = w != null && clock - w.movedAt < w.moveMs + 900
                    val near = !enRoute && MapFolk.watches(dx.toDouble() / T, dy.toDouble() / T, HeroStill.forMs(heroX, heroY, clock))
                    // left alone and standing, they go about their idle loops (Garrick: warming his hands, peering into the woods)
                    // a beast turned back at its safe place: the torch out of the fire and swung at the beast (09.10.)
                    val wo = game.lastWardOff
                    val warding = if (wo != null && wo.x == npc.x && wo.y == npc.y) MapFolk.wardAt(clock - wo.atMs) else null
                    // Garrick sits down at his fire now and then, at night he nods off; he starts up when the hero comes (10.10., 3),
                    // rising from where he is, not in one picture, and stays up until that squat is over (239)
                    val squat = if (w != null || !MapFolk.squats(f)) null else MapFolk.SquatGate.of(f.id).at(f, clock, game.isNight, roused = near || warding != null)
                    val doing = if (near || w != null || warding != null || squat != null) null else MapFolk.doing(f, clock)
                    val homeSlot = MapFigure.slot(home)
                    val target = when {
                        // seated at his table (55.2) he stays turned to it
                        MapFolk.sits(f) -> home
                        // still getting up from his fire (239): turned to it until he stands
                        squat != null -> home
                        warding != null && wo != null -> if (warding.faceBeast)
                            Math.toDegrees(kotlin.math.atan2((wo.beastX - npc.x).toDouble(), (wo.beastY - npc.y).toDouble())) else home
                        near -> Math.toDegrees(kotlin.math.atan2(dx.toDouble(), dy.toDouble()))
                        doing != null -> (homeSlot + doing.slotOffset) * 360.0 / MapFigure.YAWS - MapFigure.viewYaw
                        else -> home
                    }
                    turn.update(target, clock)
                    val slotNow = MapFigure.slot(turn.yaw)
                    // the loop only once turned all the way, and only when its pictures are ready
                    val idleImg = doing?.let { d ->
                        if (slotNow == Math.floorMod(homeSlot + d.slotOffset, MapFigure.YAWS)) MapFolk.idleFrame(f, slotNow, d.idle, d.frame, d.level) else null
                    }
                    // otherwise, standing, the small movements everyone has: breathing, shifting weight, a glance, hands to the belt
                    val squatImg = squat?.let { if (slotNow == homeSlot) MapFolk.squatFrame(f, slotNow, it) else null }
                    val restImg = if (idleImg == null && doing == null && squat == null && !walkingNow && slotNow == MapFigure.slot(target)) {
                        // a spear or staff on the shoulder stays there: no hands to the belt (5.3)
                        // 55.1b (draft): a spear can be grounded and leaned on
                        val spear = f.outfit.items[de.bornim.core.GearSlot.MAIN_HAND]?.base == "spear"
                        val ps0 = MapRest.pose(f.id.hashCode(), clock, handsFree = f.carry == MapFigure.Carry.FREE, mayLook = !near,
                            spear = spear && (w == null || npc.patrol.isEmpty()))
                        // a guard on his round grounds his spear at each longer watch (55.1b, test of 0.1.662)
                        val ps = (if (spear && w != null && npc.patrol.isNotEmpty() && MapRest.draft) {
                            val stopped = w.movedAt + w.moveMs
                            MapRest.spearWatch(clock - stopped, w.nextMoveAt - clock, w.nextMoveAt - stopped, ps0.breath)
                                ?.also { MapFolk.prepareRest(f, slotNow, MapRest.Rest.SPEAR) }
                        } else null) ?: ps0
                        MapFolk.restFrame(f, slotNow, ps.rest, ps.breath, ps.level)
                    } else null
                    val wardImg = warding?.let { wd ->
                        // the torch lights its bearer and whoever stands near: kept at the bearer's feet on the map, drawn
                        // raised above them on the screen (D3.5)
                        torches += (nx + T / 2.0) to (ny + T * 0.85)
                        MapFolk.wardFrame(f, slotNow, wd.ward, wd.flicker)
                    }
                    // draft (55.2): Borin sits at his table, now and then drinking, eating, looking round, at chance moments
                    val sitImg = if (MapFolk.sits(f)) MapFolk.seatFrame(f, homeSlot, MapFolk.seatPoseAt(f, clock)) else null
                    // 134.2: with the golden sign a short gesture of their own; drawn ahead while the hero comes near
                    val gestSlot = if (MapFolk.sits(f)) homeSlot else slotNow
                    if (game.hailSoon(npc)) MapFolk.prepareGesture(f, if (MapFolk.sits(f)) homeSlot else MapFigure.slot(Math.toDegrees(kotlin.math.atan2(dx.toDouble(), dy.toDouble()))))
                    val gestImg = if (walkingNow || warding != null) null
                        else game.hailAge(npc)?.let { de.bornim.core.Hail.gestureMs(it) }?.let { MapFolk.gestureAt(f, it) }?.let { MapFolk.gestureFrame(f, gestSlot, it) }
                    gestImg ?: sitImg ?: wardImg ?: squatImg ?: idleImg ?: restImg ?: MapFolk.frameNow(f, slotNow, if (walkingNow) Math.floorMod((clock / 80).toInt(), MapFigure.STEPS) else 0)
                }
                val img = CharacterArt.npc(npc.look, game.npcFacing(npc), if (walkingNow) (if ((clock / 130) % 2 == 0L) 1 else 2) else 0)
                val dollLit = doll?.let { warmEdge(it, nx, ny) }
                val dark = shadeAt(nx + T / 2, ny + 14)
                sprites += Sprite((ny + T - 1).toFloat(), nx + T / 2f) {
                    // pictures may be wider than the standing ones (a raised torch): the feet stay in the middle, near the bottom
                    if (dollLit != null) put(dollLit, nx + T / 2 - dollLit.width / 2 / MapFigure.DENSITY,
                        ny + T - 3 - (dollLit.height - MapFigure.FOOT_BELOW) / MapFigure.DENSITY, MapFigure.DENSITY, filter = dark)
                    else put(img, nx, ny - 2, filter = dark)
                }
            }
        }
        // 134.1: people with news for the hero hail him briefly with a golden sign over their head
        val hails = visibleNpcs.filter { game.hailing(it) }.map { npcPos(it).let { (nx, ny) -> nx + T / 2f to ny.toFloat() } }
        // Monsters walking around; only those in sight are shown, the "!" of a hunter is heard from anywhere.
        val alerts = mutableListOf<Pair<Float, Float>>()
        for (r in game.roamers) {
            val t = ((clock - r.movedAt).toFloat() / r.moveMs).coerceIn(0f, 1f)
            if (clock < r.alertUntil) alerts += ((r.fromX + (r.x - r.fromX) * t) * T + T / 2f) to ((r.fromY + (r.y - r.fromY) * t) * T)
            // drawn ahead, before it comes into sight, so the former sprite hardly ever shows
            if (r.monster in MapFoe.ON) {
                val s0 = MapFigure.slot(MapFigure.yawOf(r.facing))
                MapFoe.picture(r.monster, r.look, s0, 0)
                de.bornim.core.Packs[r.monster]?.let { pk -> if (pk.mate in MapFoe.ON) for (i in 0 until de.bornim.core.Packs.size(r.monster, r.look))
                    MapFoe.picture(pk.mate, de.bornim.core.MonsterLook(r.look.seed + 101 * (i + 1)), s0, 0,
                        if (pk.mate in de.bornim.core.art.BeastArt.KINDS) mapMateScale(pk).toDouble() else 1.0) }
            }
            if (game.fog(r.x, r.y) != de.bornim.core.Fog.VISIBLE) continue
            val rx = ((r.fromX + (r.x - r.fromX) * t) * T).roundToInt()
            val ry = ((r.fromY + (r.y - r.fromY) * t) * T).roundToInt()
            val img = MonsterArt.mapSprite(r.monster, r.look, ((clock / 240) % 4).toInt(), mirrored = r.facing == Facing.RIGHT)
            val foot = ry + T - 1
            // 9: wolves and goblins as their battle models, turning smoothly, walking with every leg; the former sprite until drawn
            val turn = FolkTurn.of("roamer:${r.uid}", MapFigure.yawOf(r.facing)).also { it.update(MapFigure.yawOf(r.facing), clock) }
            val slot = MapFigure.slot(turn.yaw)
            val step = if (t < 1f) (t * MapFoe.STEPS).toInt().coerceAtMost(MapFoe.STEPS - 1) else 0
            val standing = t >= 1f
            // standing, it is never still: it breathes, looks about, sniffs or snarls (9d), each in its own time
            fun foePic(id: String, look: de.bornim.core.MonsterLook, seed: Int, stepNow: Int, scale: Double = 1.0) =
                if (standing) MapFoe.idleAt(id, seed, clock).let { st -> MapFoe.idleNow(id, look, slot, st.idle, st.breath, scale, st.level) }
                else MapFoe.pictureNow(id, look, slot, stepNow, scale)
            val pic = if (r.monster in MapFoe.ON) foePic(r.monster, r.look, r.uid, step) else null
            // A pack walks together: each mate has a place behind the leader, one to each side, and walks to it in its
            // own time and its own way, turning as it goes; when the leader turns, the mates follow round in an arc (9g)
            val pack = de.bornim.core.Packs[r.monster]
            val mates = de.bornim.core.Packs.size(r.monster, r.look)
            if (pack != null) for (i in 0 until mates) {
                val mateLook = de.bornim.core.MonsterLook(r.look.seed + 101 * (i + 1))
                val beastMate = pack.mate in de.bornim.core.art.BeastArt.KINDS
                // an animal is long: its mates keep a body's length behind
                val (tx, ty) = MapFollow.place(rx, ry, turn.yaw, if (beastMate) 24.0 else 13.0, 10.0, if (i == 0) -1 else 1)
                val f = MapFollow.update("roamer:${r.uid}:$i", tx, ty, T * 1.4 / r.moveMs, clock, turn.yaw)
                val mx = f.x.roundToInt(); val my = f.y.roundToInt()
                val mSlot = MapFigure.slot(f.yaw)
                val mStep = Math.floorMod((f.dist / T * MapFoe.STEPS).toInt(), MapFoe.STEPS)
                val mScale = if (beastMate) mapMateScale(pack).toDouble() else 1.0
                val matePic = if (pack.mate !in MapFoe.ON) null
                    else if (f.moving) MapFoe.pictureNow(pack.mate, mateLook, mSlot, mStep, mScale)
                    else MapFoe.idleAt(pack.mate, r.uid * 31 + i + 1, clock).let { st -> MapFoe.idleNow(pack.mate, mateLook, mSlot, st.idle, st.breath, mScale, st.level) }
                if (matePic != null) {
                    val lit = warmEdge(matePic.img, mx, my)
                    sprites += Sprite((my + T - 1).toFloat(), mx + T / 2f) {
                        putShadow(matePic, mx, my)
                        put(lit, mx + T / 2 - matePic.ax / MapFigure.DENSITY, my + T - 3 - matePic.ay / MapFigure.DENSITY, MapFigure.DENSITY)
                    }
                    continue
                }
                // the former sprite (kobolds), looking the way the mate goes
                val mate = MonsterArt.mapSprite(
                    pack.mate, mateLook, ((clock / 240 + i + 1) % 4).toInt(),
                    mirrored = kotlin.math.sin(Math.toRadians(f.yaw)) > 0.2, scale = mapMateScale(pack),
                )
                sprites += Sprite((my + T - 1).toFloat(), mx + T / 2f) {
                    put(WorldArt.shadow(), mx + 4, my + 26)
                    put(mate, mx + T / 2 - mate.width / 2, my + T - mate.height)
                }
            }
            val picLit = pic?.let { warmEdge(it.img, rx, ry) }
            sprites += Sprite(foot.toFloat(), rx + T / 2f, cuts = false) {
                val sx = if (pic != null) rx + T / 2 - pic.ax / MapFigure.DENSITY else rx + T / 2 - img.width / 2
                val sy = if (pic != null) ry + T - 3 - pic.ay / MapFigure.DENSITY else foot + 1 - img.height
                putShadow(pic, rx, ry)
                r.trait?.let { tr ->
                    // Elites glow in the color of their trait.
                    val pulse = 0.5f + 0.5f * kotlin.math.sin(clock / 220f)
                    // D3.5: round the body, through the camera's turn like the figure standing on the tile's middle
                    val gx = (rx + T / 2f - camX) * scale; val gy = (ry + T / 2f - camY) * scale
                    val c = Offset(cam.toScreenX(gx, gy), cam.toScreenY(gx, gy) - T * 0.4f * scale)
                    drawCircle(
                        androidx.compose.ui.graphics.Brush.radialGradient(
                            listOf(Color(tr.color).copy(alpha = 0.35f + 0.25f * pulse), Color.Transparent),
                            center = c,
                            radius = T * 0.75f * scale,
                        ),
                        radius = T * 0.75f * scale,
                        center = c,
                    )
                }
                if (pic != null && picLit != null) put(picLit, sx, sy, MapFigure.DENSITY) else put(img, sx, sy)
                if (r.shiny) {
                    // a few twinkling pixels, on the picture where it is drawn (D3.5)
                    val at = if (pic != null) placeOf(pic.img, sx, sy, MapFigure.DENSITY) else placeOf(img, sx, sy)
                    for (k in 0 until 3) {
                        val phase = ((clock / 180 + k * 3 + r.uid) % 8).toInt()
                        if (phase > 3) continue
                        val px = 6 + ((r.uid * 7 + k * 11) % 20)
                        val py = 4 + ((r.uid * 5 + k * 13) % 18)
                        drawRect(Color.White, Offset((at.x + px * scale).toFloat(), (at.y + py * scale).toFloat()), androidx.compose.ui.geometry.Size(scale.toFloat(), scale.toFloat()))
                    }
                }
            }
        }

        val walking = game.freeWalk.moving
        // the hero as the doll from the battles, turning smoothly; the former figure until it is drawn
        // 255: the torch burns only in the dark, held out it is drawn without its flame
        MapFigure.out = !game.torchBurns
        MapFigure.prepare(state.hero, HeroTurn.yaw)
        // 24.5: a foe near, its fight is drawn ahead in the background, once the map itself is drawn
        // t60: and the hero in full, else both drawing at once make the map stutter
        if (game.mode == Mode.Explore) {
            val heroMap = game.map; val px = p.x; val py = p.y
            BattleAhead.consider(state.hero, BattleAhead.near(game.roamers, px, py).map { it.monster to it.look }) {
                VeilMemory.active || MapFigure.urgent || !MapFigure.full(state.hero) || !MapGround.readyNear(heroMap, px, py) || !MapFolk.standing(heroMap)
            }
        }
        // walking freely, the hero faces the way it walks, in any direction
        val target = game.freeWalk.yaw
        HeroTurn.update(target, clock)
        // 245: running in pictures of its own, the stride going on when the pace changes
        val stride = HeroStride.at(game.freeWalk.walked, state.running)
        val walkStep = if (!walking) 0 else stride
        // standing a moment, the hero too breathes, shifts its weight and glances about
        val heroSlot = MapFigure.slot(HeroTurn.yaw)
        val heroRest = if (!walking && heroSlot == MapFigure.slot(target) && HeroStill.forMs(heroX, heroY, clock) > 1_500L) {
            val ps = MapRest.pose(7, clock, handsFree = false, mayLook = true)
            MapFigure.restFrame(state.hero, heroSlot, ps.rest, ps.breath, ps.level, MapFigure.flame(clock))
        } else null
        // 257: standing, the torch's flame still flickers (before it moved only with the steps)
        val heroTorch = if (!walking && heroRest == null && game.torchBurns)
            MapFigure.restFrame(state.hero, heroSlot, MapRest.Rest.NEUTRAL, 0, MapRest.LEVELS, MapFigure.flame(clock)) else null
        // 17: just stopped, the cloak swings on forward and back
        if (walking) HeroSwing.walkedAt = clock
        val swingMs = clock - HeroSwing.walkedAt
        // draft: the inn's cat sleeps by the hearth and now and then moves to another spot
        if (de.bornim.core.art.MapCat.draft && map.id == "inn") {
            val c = de.bornim.core.art.MapCat.at(if (HeroSwing.now) de.bornim.core.art.MapCat.shift else clock)
            val cs = MapFigure.slot(c.yaw)
            val cimg = if (HeroSwing.now) de.bornim.core.art.MapCat.frameNow(c, cs) else de.bornim.core.art.MapCat.frame(c, cs)
            if (cimg != null) {
                val cx = (c.x * T).toInt(); val cy = (c.y * T).toInt()
                sprites += Sprite((cy + T - 2).toFloat(), cx + T / 2f) {
                    put(cimg, cx + T / 2 - de.bornim.core.art.MapCat.AX / MapFigure.DENSITY, cy + T - 4 - de.bornim.core.art.MapCat.GY / MapFigure.DENSITY, MapFigure.DENSITY)
                }
            }
        }
        // D29.3 (draft): the village dog dozes in the east of Bornim and now and then trots to another spot
        if (de.bornim.core.art.MapDog.draft && map.id == "village") {
            val d = de.bornim.core.art.MapDog.at(if (HeroSwing.now) de.bornim.core.art.MapDog.shift else clock)
            val ds = MapFigure.slot(d.yaw)
            val dimg = if (HeroSwing.now) de.bornim.core.art.MapDog.frameNow(d, ds) else de.bornim.core.art.MapDog.frame(d, ds)
            if (dimg != null) {
                val dx = (d.x * T).toInt(); val dy = (d.y * T).toInt()
                sprites += Sprite((dy + T - 2).toFloat(), dx + T / 2f) {
                    put(WorldArt.smallShadow(), dx + T / 2 - 6, dy + T - 7)
                    put(dimg, dx + T / 2 - de.bornim.core.art.MapDog.AX / MapFigure.DENSITY, dy + T - 4 - de.bornim.core.art.MapDog.GY / MapFigure.DENSITY, MapFigure.DENSITY)
                }
            }
        }
        // 83b: the hens by the hay bales; they run off flapping when the hero comes close, and in the rain and at dusk
        // they hurry off under the trees (94, D7.1)
        if (de.bornim.core.art.MapHen.draft) {
            val away = game.daylight <= 0.3f || game.raining
            for (h in de.bornim.core.art.MapHen.of(map)) {
                val a = h.at(clock, heroX + T / 2f, heroY + T - 3f, map, away)
                if (a.shown <= 0f) continue
                val hs = MapFigure.slot(a.yaw)
                val himg = (if (HeroSwing.now) de.bornim.core.art.MapHen.frameNow(a, hs) else de.bornim.core.art.MapHen.frame(a, hs)) ?: continue
                val fx = a.x.toInt(); val fy = a.y.toInt()
                sprites += Sprite(fy + 2f, a.x) {
                    put(WorldArt.smallShadow(), fx - 6, fy - 3, alpha = a.shown)
                    put(himg, fx - de.bornim.core.art.MapHen.AX / MapFigure.DENSITY, fy - de.bornim.core.art.MapHen.GY / MapFigure.DENSITY, MapFigure.DENSITY, alpha = a.shown)
                }
            }
        }
        val heroSwing = if (MapFigure.swingDraft && heroRest == null && MapFigure.cloaked(state.hero) && !walking && swingMs < MapFigure.SWING_MS) {
            val lv = MapFigure.swingLevel(swingMs)
            if (HeroSwing.now) MapFigure.swingFrameNow(state.hero, heroSlot, lv) else MapFigure.swingFrame(state.hero, heroSlot, lv)
        } else null
        val doll = warmEdge(heroRest ?: heroSwing ?: heroTorch ?: MapFigure.frameNow(state.hero, heroSlot, walkStep), heroX, heroY)
        // +0.5 so the hero is drawn after objects standing on the same row
        val heroDark = shadeAt(heroX + T / 2, heroY + 14)
        sprites += Sprite(heroY + T - 0.5f, heroX + T / 2f) {
            put(doll, heroX + T / 2 - MapFigure.ANCHOR_X / MapFigure.DENSITY, heroY + T - 3 - MapFigure.GROUND / MapFigure.DENSITY, MapFigure.DENSITY, filter = heroDark)
            // Feet hidden in tall grass.
            if (map.tile(p.x, p.y) == Tile.TALL_GRASS) {
                // the same dark blades of the ground stand before the feet
                put(MapGround.tallFront((state.steps + (clock / 400).toInt()) % 2), heroX, heroY + T - 14, MapGround.D)
            }
        }
        sprites.sortBy { it.depth }
        sprites.forEach { it.draw() }

        // Light of the place: time of day, shade of the crowns, lamps, fires and the lantern.
        ground { if (MapLight.needed(map, game.daylight)) drawMapLight(game, map, clock, camX, camY, scale, heroX, heroY, viewW, viewH) }
        if (map.kind == MapKind.INTERIOR) drawHearthSmoke(game, map, clock, cam, camX, camY, scale)
        if (map.kind == MapKind.CAVE) drawCaveShaft(game, map, clock, cam, camX, camY, scale)
        if (map.kind == MapKind.CAVE) drawCaveTorches(game, map, clock, cam, camX, camY, scale)
        if (map.kind == MapKind.TOWN) drawTownSmoke(map, clock, cam, camX, camY, scale, game.daylight)
        if (map.kind == MapKind.FOREST || map.kind == MapKind.CAVE) drawCampSmoke(game, map, clock, cam, camX, camY, scale)
        if (map.kind != MapKind.INTERIOR && MapLight.needed(map, game.daylight)) drawRisingLife(game, map, clock, cam, camX, camY, scale)
        if (map.kind == MapKind.CAVE) drawCaveDrops(game, map, clock, cam, camX, camY, scale)
        // what shines by itself (25.1: a lamp's glass; 25b: lit windows) is drawn over the light of the place, so the source is the brightest
        // spot around it, waking with the dusk like the light it throws; a small warm halo around it
        val night = MapLight.strength(map, MapLight.When.NIGHT, game.daylight).toFloat()
        if (night > 0.02f) for ((i, entry) in glowing.withIndex()) {
            val (o, a, own) = entry
            val g = o.glow ?: continue
            val seen = LightImage.seen(game, g.tx, g.ty, 0.4f, clock)
            val on = night * seen * a * (0.93f + 0.07f * kotlin.math.sin(clock / 140f + i))
            if (on <= 0.02f) continue
            val at = placeOf(o.img, o.x, o.y, o.density, o.corner)
            // test of 5.4 (temple at night): what stands in front of the shining thing (a tree, a house, a person) hides
            // its light, so the light is drawn in a layer of its own and what is in front cut out of it
            val gw = o.img.width * scale / o.density; val gh = o.img.height * scale / o.density
            val box = androidx.compose.ui.geometry.Rect(at.x.toFloat(), at.y.toFloat(), (at.x + gw).toFloat(), (at.y + gh).toFloat())
            if (box.right < 0 || box.bottom < 0 || box.left > size.width || box.top > size.height) continue
            val front = sprites.filter { it.cuts && it.depth > own.depth && (it.obj?.let { f -> (f.group == 0 || f.group != o.group) && overlaps(f, box) } ?: true) }
            if (front.isEmpty()) put(g.img, o.x, o.y, o.density, on, o.corner)
            else {
                drawContext.canvas.saveLayer(box, androidx.compose.ui.graphics.Paint())
                put(g.img, o.x, o.y, o.density, on, o.corner)
                cutting = true
                front.forEach { it.draw() }
                cutting = false
                drawContext.canvas.restore()
            }
            val c = Offset(at.x + g.cx * scale / o.density.toFloat(), at.y + g.cy * scale / o.density.toFloat())
            val r = T * 0.55f * scale * (0.5f + 0.5f * g.halo)
            if (g.halo > 0f) drawCircle(
                androidx.compose.ui.graphics.Brush.radialGradient(listOf(Color(0xFFFFD898).copy(alpha = 0.3f * on * g.halo), Color(0xFFFFB060).copy(alpha = 0.1f * on * g.halo), Color.Transparent), c, r),
                r, c, blendMode = androidx.compose.ui.graphics.BlendMode.Plus,
            )
        }
        // a torch carried about throws a warm, flickering glow around it, the stronger the darker it is
        for ((tx, ty) in torches) {
            val flick = 0.85f + 0.15f * kotlin.math.sin(clock / 70f) * kotlin.math.sin(clock / 113f)
            // D3.5: seen diagonally, through the camera's turn like the figure, then about a tile and a half up
            val mx = ((tx - camX) * scale).toFloat(); val my = ((ty - camY) * scale).toFloat()
            val c = Offset(cam.toScreenX(mx, my), cam.toScreenY(mx, my) - T * 1.4f * scale)
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
            // 27m.2 (test of 0.1.729: hens on the crowns at the edge): a small creature behind a tree or a house, where a
            // picture standing further down the diagonal really covers its spot, is not drawn, like a figure would be hidden
            fun covered(mx: Float, my: Float): Boolean {
                val sx = cam.toScreenX((mx - camX) * scale, (my - camY) * scale); val sy = cam.toScreenY((mx - camX) * scale, (my - camY) * scale)
                // asked while the ground is drawn: where the upright pictures stand is measured as outside it
                val wasFlat = flat; flat = false
                try { for (sp in sprites) {
                    val o = sp.obj ?: continue
                    if (!sp.cuts || sp.depth <= mx + my) continue
                    val at = placeOf(o.img, o.x, o.y, o.density, o.corner)
                    if (o.img.opaque(((sx - at.x) * o.density / scale).toInt(), ((sy - at.y) * o.density / scale).toInt())) return true
                } } finally { flat = wasFlat }
                return false
            }
            ground { drawCritters(game, map, clock, camX, camY, scale, heroX, heroY, viewW, viewH, ::covered) }
            if (de.bornim.core.art.PondLife.draft) drawPondLife(game, map, clock, cam)
            drawRain(game, clock, scale)
            ground { drawRainSplashes(game, map, clock, camX, camY, scale, viewW, viewH) }
            ground { drawWaterOver(game, map, clock, camX, camY, scale, heroX, heroY, viewW, viewH, ::covered) }
        }

        // Fog of war over wild areas: black where unexplored, dimmed where not in sight.
        // Where the map has a light image, the fog is already part of it (soft edges).
        ground { if (game.fogged && !MapLight.needed(map, game.daylight)) drawFog(game, camX, camY, scale, viewW, viewH) }
        // draft (idea 11): the colour mood of the place and the hour over everything, the edges a little darker
        val grade = de.bornim.core.art.MapGrade.of(map, game.daylight)
        if (grade.amount > 0f) drawRect(
            Color(grade.red, grade.green, grade.blue).copy(alpha = grade.amount),
            blendMode = androidx.compose.ui.graphics.BlendMode.Multiply,
        )
        if (grade.vignette > 0f) {
            val mid = Offset(size.width / 2f, size.height / 2f)
            val reach = kotlin.math.hypot(size.width / 2f, size.height / 2f)
            drawRect(androidx.compose.ui.graphics.Brush.radialGradient(
                0.5f to Color.Transparent, 0.78f to Color.Black.copy(alpha = grade.vignette * 0.45f), 1f to Color.Black.copy(alpha = grade.vignette),
                center = mid, radius = reach,
            ))
        }
        // 84.5: the spark of light hovers over the hero's head, drifting slowly round and bobbing; cool white with a halo.
        // 255: in a room it sinks to the shoulder, small and dim; outside it rises again ([SparkRise])
        if (game.state.spark) {
            val up = SparkRise.at(map.kind != MapKind.INTERIOR, clock)
            val fx = (heroX + T / 2f - camX) * scale; val fy = (heroY + T / 2f - camY) * scale
            val drift = 0.35f + 0.65f * up
            val sx = cam.toScreenX(fx, fy) + (6f * kotlin.math.sin(clock / 900f) + 2f * kotlin.math.sin(clock / 370f)) * drift * scale + (1f - up) * 5f * scale
            val sy = cam.toScreenY(fx, fy) - ((T * 0.62f) * (1f - up) + (T + 12f) * up + 2.5f * drift * kotlin.math.sin(clock / 620f)) * scale
            val glow = (0.85f + 0.15f * kotlin.math.sin(clock / 160f)) * (0.55f + 0.45f * up)
            val halo = (0.25f + 0.35f * (if (map.kind == MapKind.CAVE) 1f else night)) * (0.4f + 0.6f * up)
            val r = (5f + 4f * up) * scale
            drawCircle(androidx.compose.ui.graphics.Brush.radialGradient(
                listOf(Color(0xFFDCE8FF).copy(alpha = halo * glow), Color(0x00DCE8FF)), center = Offset(sx, sy), radius = r),
                radius = r, center = Offset(sx, sy))
            drawCircle(Color(0xFFF4F8FF).copy(alpha = glow), radius = (1.0f + 0.6f * up) * scale, center = Offset(sx, sy))
        }
        for ((ax, ay) in alerts) {
            // "!" above a monster that has seen the hero; D3.5: over its feet on the tile's middle, through the camera's
            // turn like the figure, as high above them as before (62 map pixels to the top of the sign)
            val fx = (ax - camX) * scale; val fy = (ay + T / 2f - camY) * scale
            val bx = cam.toScreenX(fx, fy) - 4 * scale
            val by = cam.toScreenY(fx, fy) - (T + 30f) * scale
            drawRoundRect(Color.White, Offset(bx, by), androidx.compose.ui.geometry.Size(9f * scale, 12f * scale), androidx.compose.ui.geometry.CornerRadius(2f * scale))
            drawRect(Color(0xFFD83030), Offset(bx + 3.5f * scale, by + 2f * scale), androidx.compose.ui.geometry.Size(2f * scale, 5f * scale))
            drawRect(Color(0xFFD83030), Offset(bx + 3.5f * scale, by + 8.5f * scale), androidx.compose.ui.geometry.Size(2f * scale, 1.5f * scale))
        }
        for ((ax, ay) in hails) {
            // 134.1: a golden "!" without the white card of the monsters (D3.5), with a dark rim to stand out on any ground
            val fx = (ax - camX) * scale; val fy = (ay + T / 2f - camY) * scale
            val bx = cam.toScreenX(fx, fy) - 1.5f * scale
            val by = cam.toScreenY(fx, fy) - (T + 30f) * scale
            val rim = Color(0xB0201408)
            val gold = Color(0xFFF0C850)
            drawRect(rim, Offset(bx - scale, by - scale), androidx.compose.ui.geometry.Size(5f * scale, 8f * scale))
            drawRect(rim, Offset(bx - scale, by + 8.5f * scale), androidx.compose.ui.geometry.Size(5f * scale, 4.5f * scale))
            drawRect(gold, Offset(bx, by), androidx.compose.ui.geometry.Size(3f * scale, 6f * scale))
            drawRect(gold, Offset(bx, by + 9.5f * scale), androidx.compose.ui.geometry.Size(3f * scale, 2.5f * scale))
        }


    }
}

/** Something standing on the map, drawn in order of its feet: the row ([y]) seen straight, the diagonal (x + y) seen diagonally. */
private class Sprite(val y: Float, val x: Float, val obj: WorldArt.Obj? = null, val cuts: Boolean = true, val draw: () -> Unit) {
    val depth: Float get() = x + y
}

/** 255: how high the spark of light floats, 0 at the hero's shoulder (in a room) to 1 over the head (outside), easing over [MS]. */
private object SparkRise {
    const val MS = 700f
    private var high = true
    private var from = 1f
    private var since = Long.MIN_VALUE

    fun at(outside: Boolean, clock: Long): Float {
        // the first time, it is already where it belongs
        if (since == Long.MIN_VALUE) high = outside
        val now = value(clock)
        if (outside != high) { from = now; high = outside; since = clock }
        return value(clock)
    }

    private fun value(clock: Long): Float {
        val goal = if (high) 1f else 0f
        if (since == Long.MIN_VALUE) return goal
        val t = ((clock - since) / MS).coerceIn(0f, 1f)
        val e = t * t * (3f - 2f * t)
        return from + (goal - from) * e
    }
}

/** The way the hero faces on the map, turning smoothly towards where it walks instead of snapping round. */
private object HeroTurn : Turn()

/** Where the hero is in its stride (245). */
private val HeroStride = MapFigure.Stride()

/** How long the hero has stood on the same spot of the map. */
private val HeroStill = MapFolk.Stillness()

/** 17 (draft): when the hero last walked, for the cloak swinging on after a stop. */
object HeroSwing {
    @Volatile var walkedAt = Long.MIN_VALUE / 2
    /** The previews: draw the swung pictures at once instead of in the background. */
    @Volatile var now = false
}

/** How far a boss has bared its fangs at the hero, eased in and out one step of [MapFoe.LEVELS] at a time (9h). */
private object BossMood {
    private class M(var level: Double, var last: Long)
    private val all = HashMap<String, M>()
    fun level(id: String, near: Boolean, now: Long): Int {
        val m = all.getOrPut(id) { M(if (near) MapFoe.LEVELS.toDouble() else 0.0, now) }
        val dt = (now - m.last).coerceIn(0L, 200L)
        m.last = now
        val step = dt * MapFoe.LEVELS / MapFoe.EASE_MS.toDouble()
        m.level = if (near) minOf(MapFoe.LEVELS.toDouble(), m.level + step) else maxOf(0.0, m.level - step)
        return Math.round(m.level).toInt()
    }
}

/** How each of the folk drawn as dolls faces, turning smoothly like the hero. */
private object FolkTurn {
    private val turns = HashMap<String, Turn>()
    fun of(id: String, start: Double): Turn = turns.getOrPut(id) { Turn().also { it.yaw = start } }
}

private open class Turn {
    var yaw = 0.0
    private var last = 0L

    /** Turns towards [target] (degrees) by the shortest way, settling softly as it comes round (245, [MapFigure.turnStep]). */
    fun update(target: Double, now: Long) {
        val dt = if (last == 0L) 1000L else (now - last).coerceIn(0L, 200L)
        last = now
        yaw = if (dt >= 1000L) target else MapFigure.turnStep(yaw, target, dt)
    }
}

/**
 * Draws the fog in half-tile cells; each cell blends the fog of its tile with the neighbours
 * on that side, so the edges of the sight cone are soft instead of blocky.
 */
/**
 * Traces on the ground (idea 7, draft), under the turned mapping when seen diagonally: blood darkening as it dries,
 * the prints of boots pointing the way walked (a sole and a heel), puffs of dust widening and thinning.
 */
private fun DrawScope.drawTracks(marks: List<de.bornim.core.Tracks.Mark>, clock: Long, camX: Int, camY: Int, scale: Int) {
    val T = WorldArt.T
    fun at(x: Double, y: Double) = Offset(((x * T - camX) * scale).toFloat(), ((y * T - camY) * scale).toFloat())
    fun oval(c: Offset, w: Float, h: Float, color: Color) =
        drawOval(color, Offset(c.x - w * scale / 2f, c.y - h * scale / 2f), androidx.compose.ui.geometry.Size(w * scale, h * scale))
    for (m in marks) {
        val a = m.alpha(clock)
        if (a <= 0.01f) continue
        val c = at(m.x, m.y)
        when (m.kind) {
            de.bornim.core.Tracks.Kind.BLOOD -> {
                // fresh red, drying to a dark brown within the first minutes
                val dry = (m.age(clock) / 0.4f).coerceIn(0f, 1f)
                val col = androidx.compose.ui.graphics.lerp(Color(0xFF8E1A12), Color(0xFF5A1C14), dry).copy(alpha = 0.85f * a)
                val rnd = kotlin.random.Random(m.seed)
                // the pool: a few overlapping blobs, longer one way, then the splashes round it
                val lean = rnd.nextFloat() * 6.28f
                repeat(4 + rnd.nextInt(3)) {
                    val d = rnd.nextFloat() * 6f; val w = 6f + rnd.nextFloat() * 6f
                    val o = Offset(c.x + kotlin.math.cos(lean) * d * scale * (if (it % 2 == 0) 1 else -1), c.y + kotlin.math.sin(lean) * d * scale * 0.7f)
                    oval(o, w, w * (0.55f + rnd.nextFloat() * 0.3f), col)
                }
                repeat(5 + rnd.nextInt(4)) {
                    val ang = rnd.nextFloat() * 6.28f; val d = 9f + rnd.nextFloat() * 9f; val r = 1.2f + rnd.nextFloat() * 1.6f
                    oval(Offset(c.x + kotlin.math.cos(ang) * d * scale, c.y + kotlin.math.sin(ang) * d * scale), r, r, col)
                }
            }
            de.bornim.core.Tracks.Kind.PRINT -> {
                // mud pressed down outdoors; carried in on the boots, a pale smear of dried mud (shows on dark boards and rugs)
                val col = (if (m.strength >= 1f) Color(0xFF231810) else Color(0xFF9A8262)).copy(alpha = 0.7f * a)
                withTransform({ rotate(-m.yaw.toFloat(), c) }) {
                    // the foot points down the map before turning: the sole ahead, the heel behind
                    oval(Offset(c.x, c.y + 1.5f * scale), 3.4f, 5f, col)
                    oval(Offset(c.x, c.y - 2.8f * scale), 3f, 2.6f, col)
                }
            }
            de.bornim.core.Tracks.Kind.DUST -> {
                val age = m.age(clock)
                val rnd = kotlin.random.Random(m.seed)
                repeat(3) {
                    val ang = rnd.nextFloat() * 6.28f; val d = 1.5f + age * 3f
                    val r = 2f + age * 5f + rnd.nextFloat() * 1.5f
                    oval(Offset(c.x + kotlin.math.cos(ang) * d * scale, c.y + kotlin.math.sin(ang) * d * scale), r, r * 0.8f,
                        Color(0xFFE2D2AE).copy(alpha = 0.55f * (1f - age)))
                }
            }
        }
    }
}

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
    heroX: Int, heroY: Int, viewW: Float, viewH: Float, covered: (Float, Float) -> Boolean = { _, _ -> false },
) {
    val T = WorldArt.T
    val day = game.daylight
    fun px(x: Float, y: Float, w: Float, h: Float, c: Color) =
        drawRect(c, Offset((x - camX) * scale, (y - camY) * scale), androidx.compose.ui.geometry.Size(w * scale, h * scale))
    val tx0 = (camX / T) - 1; val ty0 = (camY / T) - 1
    val tx1 = ((camX + viewW) / T).toInt() + 1; val ty1 = ((camY + viewH) / T).toInt() + 1

    if (day > 0.4f && !game.raining) {
        // Butterflies over flowers
        for (ty in ty0..ty1) for (tx in tx0..tx1) {
            if (map.tile(tx, ty) != Tile.FLOWERS || hash(tx, ty) % 4 != 0) continue
            val seed = hash(tx, ty, 7) % 1000
            val x = tx * T + 16 + kotlin.math.sin(clock / 700f + seed) * 12f
            val y = ty * T + 8 + kotlin.math.cos(clock / 530f + seed * 0.7f) * 7f
            val open = (clock / 90 + seed) % 2 == 0L
            if (covered(x, y)) continue
            val v = sight(game, x, y, clock)
            if (v <= 0.02f) continue
            faded(v, (x - camX) * scale, (y - camY) * scale, 4f * scale) {
            val c = listOf(Color.White, Color(0xFFF8E060), Color(0xFFF0A040), Color(0xFF80B8F8))[seed % 4]
            if (open) {
                px(x - 2, y, 2f, 2f, c); px(x + 1, y, 2f, 2f, c)
            } else {
                px(x - 1, y - 1, 1f, 2f, c); px(x + 1, y - 1, 1f, 2f, c)
            }
            px(x, y, 1f, 2f, Color(0xFF302020))
            }
        }
        // Birds pecking on the grass fly off when the hero comes close (none in the deep forest, D3.2; heard: 84)
        if (de.bornim.core.art.MapBirds.out(map, day, game.raining)) for (ty in ty0..ty1) for (tx in tx0..tx1) {
            if (!de.bornim.core.art.MapBirds.at(map, tx, ty)) continue
            val bx = de.bornim.core.art.MapBirds.x(tx, ty)
            val by = de.bornim.core.art.MapBirds.y(tx, ty)
            val flee = de.bornim.core.art.MapBirds.flee(tx, ty, heroX, heroY)
            val fx = bx + flee * 70f
            val fy = by - flee * 90f
            if (flee >= 1f || covered(fx, fy)) continue
            val v = sight(game, fx, fy, clock)
            if (v <= 0.02f) continue
            faded(v, (fx - camX) * scale, (fy - camY) * scale, 6f * scale) {
            val brown = Color(0xFF7A5030)
            val hop = if (flee == 0f && de.bornim.core.art.MapBirds.hopping(tx, ty, clock)) 1f else 0f
            px(fx, fy - hop, 3f, 2f, brown)
            px(fx + 3, fy - 1 - hop, 1f, 1f, brown)
            px(fx + 4, fy - 1 - hop, 1f, 1f, Color(0xFFE0A030))
            if (flee > 0f) {
                val wing = if ((clock / 70) % 2 == 0L) -2f else 1f
                px(fx - 1, fy + wing, 2f, 1f, brown); px(fx + 2, fy + wing, 2f, 1f, brown)
            }
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
            val glow = f.glow(clock) * fade * sight(game, x, y, clock)
            if (glow <= 0.02f || covered(x, y)) continue
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
 * Life at the forest pond (27.6): frogs on the bank and dragonflies over the water, upright on the
 * screen (seen diagonally they stand on the mapped point, not lying flat), dull colours dimmed with the light.
 */
/**
 * 248 (Chef 20.10., 13:57 „die Frösche und Libellen sind außerhalb meines Sichtkreises“): how much of a small creature at map
 * pixel ([x], [y]) shows. The light of the place, which carries the fog, is drawn under the creatures, so out of sight
 * they fade away with the fog instead of shining over the dark.
 */
private fun sight(game: Game, x: Float, y: Float, clock: Long): Float =
    if (!game.fogged) 1f else LightImage.seen(game, floor(x / WorldArt.T).toInt(), floor(y / WorldArt.T).toInt(), 0f, clock)

/** 248: draws [block] at [v] of its strength, inside [r] pixels around ([cx], [cy]) on the screen. */
private inline fun DrawScope.faded(v: Float, cx: Float, cy: Float, r: Float, block: () -> Unit) {
    if (v >= 0.99f) { block(); return }
    drawContext.canvas.saveLayer(androidx.compose.ui.geometry.Rect(cx - r, cy - r, cx + r, cy + r), androidx.compose.ui.graphics.Paint().apply { alpha = v })
    block()
    drawContext.canvas.restore()
}

private fun DrawScope.drawPondLife(game: Game, map: de.bornim.core.MapDef, clock: Long, cam: Cam) {
    val life = de.bornim.core.art.PondLife.of(map)
    if (life.frogs.isEmpty() && life.flies.isEmpty()) return
    val s = cam.scale.toFloat()
    val day = game.daylight
    val dim = (0.35f + 0.65f * ((day - 0.15f) / 0.5f)).coerceIn(0.35f, 1f)
    fun tone(c: Color, a: Float = 1f) = Color(c.red * dim, c.green * dim, c.blue * dim, a)
    fun sx(x: Float, y: Float) = cam.toScreenX((x - cam.x) * s, (y - cam.y) * s)
    fun sy(x: Float, y: Float) = cam.toScreenY((x - cam.x) * s, (y - cam.y) * s)
    fun dot(ox: Float, oy: Float, x: Float, y: Float, w: Float, h: Float, c: Color) =
        drawRect(c, Offset(ox + x * s, oy + y * s), androidx.compose.ui.geometry.Size(w * s, h * s))
    // a ring on the water, flat: twice as wide as high
    fun ring(ox: Float, oy: Float, r: Float, a: Float) {
        if (a <= 0.01f) return
        drawOval(
            Color(0xFFB8C4BC).copy(alpha = a * dim), Offset(ox - r * s, oy - r * s * 0.5f),
            androidx.compose.ui.geometry.Size(2 * r * s, r * s), style = androidx.compose.ui.graphics.drawscope.Stroke(width = 0.6f * s),
        )
    }
    val w = size.width; val h = size.height
    val dusk = day < 0.55f
    for (f in life.frogs) {
        val a = f.at(clock, cam.heroX.toFloat(), cam.heroY.toFloat(), dusk)
        val ox = sx(a.x, a.y); val oy = sy(a.x, a.y)
        if (ox < -40 * s || oy < -40 * s || ox > w + 40 * s || oy > h + 40 * s) continue
        val v = sight(game, a.x, a.y, clock)
        if (v <= 0.02f) continue
        faded(v, ox, oy, 14 * s) {
        val back = tone(Color(0xFF4C5530)); val top = tone(Color(0xFF65703E)); val belly = tone(Color(0xFF9A9468))
        val dark = tone(Color(0xFF22261A)); val eye = tone(Color(0xFFB09A48))
        val d = if (a.faceLeft) -1f else 1f
        // x offsets mirrored for the way it faces: dx is towards its nose
        fun part(dx: Float, y: Float, wd: Float, ht: Float, c: Color) = dot(ox, oy, if (d > 0) dx else -dx - wd, y, wd, ht, c)
        when (a.mood) {
            de.bornim.core.art.PondLife.Mood.UNDER -> {
                ring(ox, oy, 2f + a.ring * 9f, 0.55f * (1f - a.ring).coerceIn(0f, 1f))
                ring(ox, oy, 1f + a.ring * 5f, 0.4f * (1f - a.ring * 1.4f).coerceIn(0f, 1f))
            }
            de.bornim.core.art.PondLife.Mood.SURFACE, de.bornim.core.art.PondLife.Mood.SWIM -> {
                // only the eyes and the top of the head above the water, a faint wake behind
                ring(ox, oy, 2f + (a.ring % 1f) * 5f, 0.35f * (1f - a.ring % 1f))
                part(-1f, -1f, 3f, 1f, top)
                part(1f, -2f, 1f, 1f, dark); part(-1f, -2f, 1f, 1f, dark)
            }
            else -> {
                val lift = a.lift
                if (lift > 0f) drawOval(Color.Black.copy(alpha = 0.18f * dim), Offset(ox - 3 * s, oy - 1 * s), androidx.compose.ui.geometry.Size(6 * s, 2 * s))
                else drawOval(Color.Black.copy(alpha = 0.25f * dim), Offset(ox - 3.5f * s, oy - 1 * s), androidx.compose.ui.geometry.Size(7 * s, 2 * s))
                val y0 = -lift
                if (lift > 0f) {
                    // stretched out in the leap: long body, hind legs trailing
                    part(-3f, y0 - 3f, 6f, 2f, back); part(-2f, y0 - 4f, 4f, 1f, top)
                    part(-6f, y0 - 2f, 3f, 1f, dark); part(3f, y0 - 3f, 1f, 1f, dark)
                } else {
                    // crouched: a low, rounded body rising to the haunch at the back, the head low and flat at the
                    // front with the eye on top, the throat pulsing under it
                    fun oval(dx: Float, y: Float, wd: Float, ht: Float, c: Color) = drawOval(
                        c, Offset(ox + (if (d > 0) dx else -dx - wd) * s, oy + y * s), androidx.compose.ui.geometry.Size(wd * s, ht * s),
                    )
                    oval(-4.5f, -3.2f, 3.6f, 3.2f, dark) // the folded hind leg, a dark curve at the back
                    oval(-4f, -4f, 6.5f, 3.6f, back) // body
                    oval(-3f, -4.3f, 4f, 1.6f, top) // the light back
                    oval(1.2f, -3.4f, 3.2f, 2.4f, back) // head
                    oval(1.4f, -1.6f, 2.8f, 1.2f + 0.8f * a.throat.coerceIn(0f, 1.2f), belly.copy(alpha = 0.55f + 0.45f * a.throat.coerceIn(0f, 1f))) // throat
                    oval(1.8f, -4.4f, 1.5f, 1.5f, back) // eye bump
                    part(2.2f, -4.1f, 0.8f, 0.8f, eye); part(2.5f, -3.9f, 0.4f, 0.4f, dark)
                    part(-0.5f, -0.6f, 0.8f, 0.8f, dark); part(2.5f, -0.6f, 0.7f, 0.7f, dark) // feet
                }
            }
        }
        }
    }
    if (day > 0.4f && !game.raining) for (fly in life.flies) {
        val a = fly.at(clock)
        val ox = sx(a.x, a.y); val oy = sy(a.x, a.y)
        if (ox < -40 * s || oy < -40 * s || ox > w + 40 * s || oy > h + 40 * s) continue
        val v = sight(game, a.x, a.y, clock)
        if (v <= 0.02f) continue
        faded(v, ox, oy - a.h * s, (12 + a.h) * s) {
        // its shadow on the water, then the insect above it
        drawOval(Color.Black.copy(alpha = 0.16f * dim), Offset(ox - 2 * s, oy - 0.5f * s), androidx.compose.ui.geometry.Size(4 * s, 1 * s))
        val cy = oy - a.h * s
        // the heading on the screen: the map direction under the view
        var hx = cam.toScreenX(a.dx, a.dy) - cam.toScreenX(0f, 0f); var hy = cam.toScreenY(a.dx, a.dy) - cam.toScreenY(0f, 0f)
        val hl = kotlin.math.hypot(hx, hy).coerceAtLeast(1e-3f); hx /= hl; hy /= hl
        val body = tone(if (fly.dark) Color(0xFF3C5A64) else Color(0xFF6A5E36))
        val head = tone(if (fly.dark) Color(0xFF2A3E46) else Color(0xFF4A4026))
        val beat = a.wings > 0.5f
        val wing = Color(0xFFD8E2E6).copy(alpha = (if (beat) 0.22f else 0.12f) * dim)
        val vein = Color(0xFFE8F0F2).copy(alpha = (if (beat) 0.3f else 0.18f) * dim)
        // four narrow wings from the thorax, the front pair swept forward, the hind pair back; they shimmer
        // rather than show a shape
        val px = -hy; val py = hx
        for (side in listOf(1f, -1f)) for ((sweep, len) in listOf(0.35f to 5f, -0.3f to 4.6f)) {
            val ex = px * side + hx * sweep; val ey = (py * side + hy * sweep) * 0.7f
            val el = kotlin.math.hypot(ex, ey)
            val root = Offset(ox + hx * 0.3f * s, cy + hy * 0.3f * s)
            val tip = Offset(root.x + ex / el * len * s, root.y + ey / el * len * s)
            drawLine(wing, root, tip, strokeWidth = 1.1f * s)
            drawLine(vein, root, tip, strokeWidth = 0.35f * s)
        }
        // the long, slender tail behind, a little thicker at the root; the thorax; the head with its big eyes
        drawLine(body, Offset(ox - hx * 8f * s, cy - hy * 8f * s), Offset(ox - hx * 1f * s, cy - hy * 1f * s), strokeWidth = 0.55f * s)
        drawLine(body, Offset(ox - hx * 2f * s, cy - hy * 2f * s), Offset(ox + hx * 0.8f * s, cy + hy * 0.8f * s), strokeWidth = 0.95f * s)
        drawCircle(head, 0.75f * s, Offset(ox + hx * 1.5f * s, cy + hy * 1.5f * s))
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
    class Fly(private val cx: Float, private val cy: Float, private val seed: Int, private val period: Long, private val offset: Long, private val partner: Long?,
              private val spread: Float = 1f) {
        /** Where it is at [clock], in map pixels. */
        fun at(clock: Long): Pair<Float, Float> {
            val t = clock / 1000f
            val s = seed % 997 / 997f * 6.28f
            // drifting, with pauses: the speed itself swells and dies away
            // 4 (Nutzer 13.10., 21:1x: zu hektisch): slower, a lazy wander; the swarm's [spread] sets how far it roams
            val pace = 0.5f + 0.5f * kotlin.math.sin(t * 0.13f + s)
            val u = t * (0.16f + 0.12f * pace)
            val x = cx + (kotlin.math.sin(u * 0.9f + s) * 14f + kotlin.math.sin(u * 2.3f + s * 2) * 3f) * spread
            val y = cy + (kotlin.math.cos(u * 0.7f + s * 1.3f) * 9f) * spread + kotlin.math.sin(t * 0.25f + s) * 4f
            return x to y
        }

        /** How bright it is at [clock]: a short flash, then long dark. */
        fun glow(clock: Long): Float {
            // sometimes this one answers its neighbour's flash a moment later instead of keeping its own time
            val p = partner
            val answering = p != null && Math.floorMod(hash(((clock + p) / period).toInt(), seed), 3) == 0
            val c = if (answering) clock + p!! - 650 else clock + offset
            val since = Math.floorMod(c, period)
            // 4 (21:1x: zu schnell an und aus): a slow swell and a long fade, each its own length
            val len = 1300L + seed % 900
            if (since >= len) return 0f
            val u = since / len.toFloat()
            val k = if (u < 0.35f) u / 0.35f else (1 - u) / 0.65f
            return k * k * (3 - 2 * k)
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
                // 4 (21:1x: Schwärme gleich groß): some only one or two, some a crowd, near or wide apart
                val r = hash(x, y, 89) % 100
                val n = when { r < 30 -> 1 + r % 2; r < 75 -> 3 + r % 3; else -> 6 + r % 4 }
                val spread = 0.5f + (hash(x, y, 91) % 100) / 100f * (if (n > 5) 1.4f else 0.9f)
                List(n) { k ->
                    val seed = hash(x * 31 + k, y, 90)
                    // pairs share a rhythm, so the second can answer the first
                    val lead = hash(x * 31 + k / 2 * 2, y, 90)
                    val period = 5200L + lead % 6000
                    Fly(x * T + T / 2f + (seed % 20 - 10) * spread, y * T + T / 2f + (seed / 20 % 16 - 8) * spread, seed,
                        period = period, offset = (seed / 7 % 9000).toLong(), partner = if (k % 2 == 1) (lead / 7 % 9000).toLong() else null, spread = spread)
                }
            }
        }
    }
}

/** The light image of the current view, redrawn only when hero, view or daylight change. */
private object LightImage {
    var key = ""
    /** The light of the place without the fog of war, and with it ([img], what is drawn). */
    var base: de.bornim.core.art.PixelImage? = null
    var img: de.bornim.core.art.PixelImage? = null
    var fogKey = ""
    var fogAt = 0L

    /** How long a tile takes to come fully into sight or to fall out of it. */
    private const val FADE_MS = 450f
    private var fadeMap = ""
    private var shown = FloatArray(0)
    private var lastMs = 0L
    /** Counts the frames of a fade, so the fogged image is made again while it runs. */
    var fadeStep = 0
        private set

    /**
     * How much of a light or a smoke at tile ([tx], [ty]) shows: 0 never seen, [dim] out of sight, 1 in sight; fading
     * along with the fog while the light of the place is drawn, else straight from the fog of war.
     */
    fun seen(game: Game, tx: Int, ty: Int, dim: Float, clock: Long): Float {
        val map = game.map
        if (map.id != fadeMap || !map.inside(tx, ty) || clock - lastMs > 200) return when (game.fog(tx, ty)) {
            de.bornim.core.Fog.HIDDEN -> 0f
            de.bornim.core.Fog.SEEN -> dim
            de.bornim.core.Fog.VISIBLE -> 1f
        }
        val sh = shown[ty * map.width + tx]
        val sd = seenDimOf(map)
        return if (sh >= sd) dim * (1f - sh) / (1f - sd) else dim + (1f - dim) * (sd - sh) / sd
    }

    // 13e.6 (draft): in the cave what was seen once does not stay bright; out of sight it sinks into the dark
    private fun seenDimOf(map: de.bornim.core.MapDef) = if (map.kind == MapKind.CAVE) de.bornim.core.art.MapLight.CAVE_SEEN_DIM else 0.5f

    /** Each tile is split into SUB × SUB parts for the fog, so the edge of the cone is round (13e, test 13.10.). */
    const val SUB = 4
    private var sub = FloatArray(0)
    /** Where the parts of the tiles head for, worked out again only when the hero moves or turns. */
    private var subGoal = FloatArray(0)
    private var goalKey = ""

    /** How dark the fog makes part ([sx], [sy]) (in [SUB]ths of a tile) right now: 1 unknown, 0 in sight. */
    fun shadeSub(map: de.bornim.core.MapDef, sx: Int, sy: Int): Float {
        val tx = Math.floorDiv(sx, SUB); val ty = Math.floorDiv(sy, SUB)
        // beyond the edge the wood goes on (27m): it is as known as the edge next to it, or as the ground up to three
        // tiles further in (t732: behind a row of trees at the edge the hero never sees the edge itself, and the wood
        // beyond stayed black)
        if (de.bornim.core.art.MapEdge.applies(map) && !map.inside(tx, ty)) {
            if (map.id != fadeMap) return 1f
            val w = map.width * SUB; val h = map.height * SUB
            val cx = sx.coerceIn(0, w - 1); val cy = sy.coerceIn(0, h - 1)
            val dx = Integer.signum(cx - sx); val dy = Integer.signum(cy - sy)
            var best = 1f
            for (k in 0..3 * SUB) best = minOf(best, sub[(cy + dy * k).coerceIn(0, h - 1) * w + (cx + dx * k).coerceIn(0, w - 1)])
            // nothing to find out there (t732, north edge: the ground before it lay behind a row of trees, never seen,
            // and the wood beyond stayed black): never darker than what is known but out of sight; not in a cave, where
            // the rock beyond the edge shows only as far as the hero has been
            return if (map.kind == MapKind.CAVE) best else minOf(best, seenDimOf(map))
        }
        return if (map.id == fadeMap && map.inside(tx, ty)) sub[sy * map.width * SUB + sx] else 1f
    }

    /** How dark the fog makes tile ([tx], [ty]) right now: 1 unknown, 0 in sight. */
    fun shade(map: de.bornim.core.MapDef, tx: Int, ty: Int): Float =
        if (map.id == fadeMap && map.inside(tx, ty)) shown[ty * map.width + tx] else 1f

    /** Moves every tile's fog a step towards what the hero sees now; true while some tile is still fading. */
    fun fade(game: Game, map: de.bornim.core.MapDef, clock: Long): Boolean {
        // test of 0.1.667 (13e): seen diagonally one looks over the low walls into rooms explored already, and
        // the dimmed fog lay over them like a dark cloth; there what is known but out of sight dims only a little
        val seenDim = seenDimOf(map)
        val fresh = map.id != fadeMap || shown.size != map.width * map.height
        if (fresh) { fadeMap = map.id; shown = FloatArray(map.width * map.height); sub = FloatArray(map.width * map.height * SUB * SUB) }
        val step = if (fresh) 1f else minOf(1f, (clock - lastMs).coerceIn(0L, 100L) / FADE_MS * 3f)
        lastMs = clock
        var moving = false
        val sw = map.width * SUB
        val p = game.state.place
        val gk = "${map.id}/${p.x}/${p.y}/${Math.round(game.freeWalk.lookYaw() / 5.0)}/${game.isNight}/${de.bornim.core.Game.seeAll}"
        val newGoals = fresh || gk != goalKey
        if (newGoals) { goalKey = gk; if (subGoal.size != sub.size) subGoal = FloatArray(sub.size) }
        for (ty in 0 until map.height) for (tx in 0 until map.width) {
            val fog = game.fog(tx, ty)
            val goal = when (fog) {
                de.bornim.core.Fog.HIDDEN -> 1f
                de.bornim.core.Fog.SEEN -> seenDim
                de.bornim.core.Fog.VISIBLE -> 0f
            }
            val i = ty * map.width + tx
            val now = shown[i]
            if (now != goal) {
                // eases in: each change takes about as long, however big (unknown to clear, or out of sight to clear)
                val next = now + (goal - now) * step
                shown[i] = if (kotlin.math.abs(goal - next) < 0.01f) goal else next
                moving = true
            }
            // the parts of the tile: in sight by the cone's own edge, else as the tile (never seen, or out of sight)
            val out = if (fog == de.bornim.core.Fog.HIDDEN) 1f else seenDim
            for (v in 0 until SUB) for (u in 0 until SUB) {
                val j = (ty * SUB + v) * sw + tx * SUB + u
                if (newGoals) subGoal[j] = if (game.inSight(tx + (u + 0.5) / SUB, ty + (v + 0.5) / SUB)) 0f else out
                val g = subGoal[j]
                val n = sub[j]
                if (n == g) continue
                val next = n + (g - n) * step
                sub[j] = if (kotlin.math.abs(g - next) < 0.01f) g else next
                moving = true
            }
        }
        if (moving) fadeStep++
        return moving
    }
}

/**
 * Light on the map: the light image multiplied over it (dark where nothing shines), a glow around
 * every light that flickers (fire) or pulses (mushrooms), and small life: sparks over fires, spores
 * over mushrooms, dust in daylight; under the open sky and in caves sparks and spores stand upright on the screen
 * ([drawRisingLife]), drops in caves fall straight down ([drawCaveDrops]).
 */
/**
 * Seen diagonally (5.1): smoke rising from the mouth of each house's chimney, upright on the screen, drifting
 * a little with the wind and thinning as it climbs.
 */
private fun DrawScope.drawTownSmoke(map: de.bornim.core.MapDef, clock: Long, cam: Cam, camX: Int, camY: Int, scale: Int, daylight: Float = 1f) {
    // by day a pale grey that stands out against the dark crowns, at night a dim one that does not glow
    val tone = androidx.compose.ui.graphics.lerp(Color(0xFF4E4B48), Color(0xFFB3AEA7), daylight.coerceIn(0f, 1f))
    val dense = 0.45f + 0.25f * daylight.coerceIn(0f, 1f)
    for ((i, top) in de.bornim.core.art.MapTownIso.chimneyTops(map).withIndex()) {
        val (gx, gy, z) = top
        val mx = ((gx - camX) * scale).toFloat(); val my = ((gy - camY) * scale).toFloat()
        val bx = cam.toScreenX(mx, my); val by = cam.toScreenY(mx, my) - (z * scale).toFloat()
        // a thin column of many soft wisps (test of 0.1.590: five hard grey discs looked like floating balls): each
        // rises from the mouth, swells, is carried off with the wind as it climbs and thins to nothing; soft at its rim
        // 73 (Meldung 13.10., 19:4x: "kein Kamin raucht"): the column was so small and pale it vanished before the dark
        // crowns; now taller, broader, denser and a lighter grey, still soft wisps that thin to nothing. Each chimney
        // smokes in its own way (Nutzer: "nicht synchron"): its own pace, sway and lean, and a fire that draws harder
        // and weaker in slow puffs of its own
        val h = (i * 7919 + 1237) % 1000 / 1000f
        val period = 5200L + (h * 2600).toLong()
        val lean = 14f + h * 12f
        val draw = 0.65f + 0.35f * kotlin.math.sin(clock / (5300f + h * 4100f) + h * 6.3f) * kotlin.math.sin(clock / (1900f + h * 900f) + i * 2.1f)
        val n = 18
        for (k in 0 until n) {
            val ph = (((clock + (h * period).toLong()) + k * period / n) % period) / period.toFloat()
            val sway = kotlin.math.sin(ph * (3.4f + h * 1.8f) + h * 9f + clock / (2000f + h * 900f)) * (0.8f + ph * 3f)
            val x = bx + (sway + ph * ph * lean) * scale
            val y = by - (ph * (50f + h * 16f) + 1f) * scale
            val r = (2.4f + ph * (8.5f + h * 3f)) * scale
            val a = dense * draw * (1f - ph) * kotlin.math.sqrt(1f - ph) * kotlin.math.min(1f, ph * 7f)
            val c = Offset(x, y)
            drawCircle(Brush.radialGradient(listOf(tone.copy(alpha = a), tone.copy(alpha = a * 0.5f), tone.copy(alpha = 0f)), c, r), r, c)
        }
    }
}

/**
 * Seen diagonally (27.6c, draft): smoke rising from the camp fires in the woods, a loose column of soft wisps like
 * the chimneys' (drawTownSmoke), carried off with the wind as it climbs; over Morwen's herb fire in the deep woods
 * paler and faintly green. Only over fires the hero has seen. In the cave (D1.7) the goblins' fire smokes too, straight
 * up in the still air, warmed by the flames below and thinner, for it hangs in the dark.
 */
private fun DrawScope.drawCampSmoke(game: Game, map: de.bornim.core.MapDef, clock: Long, cam: Cam, camX: Int, camY: Int, scale: Int) {
    val T = WorldArt.T
    val herbs = map.id == "deep_forest"
    val cave = map.kind == MapKind.CAVE
    // pale against the dark woods (dark grey like the chimneys' was lost against the ground)
    val col = if (cave) Color(0xFFA89C8E) else if (herbs) Color(0xFFC2CAB6) else Color(0xFFB4B0A8)
    val lean = if (cave) 2f else 18f
    for (ty in 0 until map.height) for (tx in 0 until map.width) {
        if (map.tile(tx, ty) != de.bornim.core.Tile.CAMPFIRE) continue
        val seen = LightImage.seen(game, tx, ty, 0.5f, clock)
        if (seen <= 0f) continue
        val mx = (((tx + 0.5f) * T - camX) * scale); val my = (((ty + 0.5f) * T - camY) * scale)
        // from just above the flames
        val bx = cam.toScreenX(mx, my); val by = cam.toScreenY(mx, my) - 12f * scale
        if (bx < -60f * scale || bx > size.width + 60f * scale || by < -10f || by > size.height + 60f * scale) continue
        val n = 16
        val seed = tx * 31 + ty * 7
        for (k in 0 until n) {
            val period = 6400L
            val ph = (((clock + seed * 211) + k * period / n) % period) / period.toFloat()
            val sway = kotlin.math.sin(ph * 3.6f + seed + clock / 2700f) * (0.8f + ph * 3f)
            val x = bx + (sway + ph * ph * lean) * scale
            val y = by - (ph * 56f) * scale
            val r = (2.2f + ph * 9f) * scale
            val a = (if (cave) 0.26f else if (herbs) 0.42f else 0.34f) * seen * (1f - ph) * (1f - ph) * kotlin.math.min(1f, ph * 8f)
            val c = Offset(x, y)
            drawCircle(Brush.radialGradient(listOf(col.copy(alpha = a), col.copy(alpha = a * 0.5f), col.copy(alpha = 0f)), c, r), r, c)
        }
    }
}

/**
 * D1.7, 27n: the small life over fires and mushrooms, seen diagonally (it was drawn on the tilted floor, so it drifted
 * aslant): sparks leaving a camp fire and spores leaving the glowing mushrooms rise upright on the screen, in the
 * cave as in the woods. Only where the hero has seen.
 */
private fun DrawScope.drawRisingLife(game: Game, map: de.bornim.core.MapDef, clock: Long, cam: Cam, camX: Int, camY: Int, scale: Int) {
    val T = WorldArt.T
    val px = scale.toFloat()
    val zs = de.bornim.core.art.MapRoomIso.ZS.toFloat()
    fun foot(x: Double, y: Double): Offset {
        val mx = ((x - camX) * scale).toFloat(); val my = ((y - camY) * scale).toFloat()
        return Offset(cam.toScreenX(mx, my), cam.toScreenY(mx, my))
    }
    for ((i, src) in MapLight.sources(map).withIndex()) {
        val seen = LightImage.seen(game, floor(src.x / T).toInt(), floor(src.y / T).toInt(), 0.4f, clock)
        if (seen <= 0f) continue
        val o = foot(src.x, src.y)
        when (src.kind) {
            MapLight.Kind.FIRE -> for (k in 0 until 5) {
                // sparks rising from the flames, swaying, fading before about a man's height
                val period = 1400 + k * 230
                val ph = ((clock + k * 517 + i * 131) % period) / period.toFloat()
                val sx = kotlin.math.sin(ph * 6f + k) * 3f + (k - 2) * 2f
                val h = (14f + ph * 44f) * zs
                drawRect(Color(0xFFFFC060).copy(alpha = (1 - ph) * 0.9f * seen), Offset(o.x + sx * px, o.y - h * px), androidx.compose.ui.geometry.Size(px, px))
            }
            MapLight.Kind.SHROOM -> for (k in 0 until 3) {
                // spores drifting up from the caps, slow and wavering, a little to either side
                val period = 3200 + k * 700
                val ph = ((clock + k * 1100 + i * 377) % period) / period.toFloat()
                val sx = (k - 1) * 6f + kotlin.math.sin(ph * 9f + i) * 2.5f
                val h = (4f + ph * 36f) * zs
                drawRect(Color(0xFFA8FFF0).copy(alpha = kotlin.math.sin(ph * Math.PI.toFloat()) * 0.8f * seen), Offset(o.x + sx * px, o.y - h * px), androidx.compose.ui.geometry.Size(px, px))
            }
            else -> {}
        }
    }
}

/**
 * D1.7: drops fall straight down from the dark of the cave onto the floor near the hero and leave a ring lying flat
 * on it. Only where the hero has seen.
 */
private fun DrawScope.drawCaveDrops(game: Game, map: de.bornim.core.MapDef, clock: Long, cam: Cam, camX: Int, camY: Int, scale: Int) {
    val T = WorldArt.T
    val px = scale.toFloat()
    val zs = de.bornim.core.art.MapRoomIso.ZS.toFloat()
    fun foot(x: Double, y: Double): Offset {
        val mx = ((x - camX) * scale).toFloat(); val my = ((y - camY) * scale).toFloat()
        return Offset(cam.toScreenX(mx, my), cam.toScreenY(mx, my))
    }
    // drops: a few at a time on the floor round the middle of the view, each on a tile of its own
    val cx = floor(cam.mapX(size.width / 2, size.height / 2) / T).toInt(); val cy = floor(cam.mapY(size.width / 2, size.height / 2) / T).toInt()
    for (k in 0 until 7) {
        val period = 2600L + k * 410
        val cycle = (clock + k * 777) / period
        val ph = ((clock + k * 777) % period) / period.toFloat()
        val tx = cx - 6 + Math.floorMod(hash(k, cycle.toInt()), 13); val ty = cy - 6 + Math.floorMod(hash(cycle.toInt(), k + 50), 13)
        if (!map.inside(tx, ty) || !map.tile(tx, ty).walkable) continue
        val seen = LightImage.seen(game, tx, ty, 0.4f, clock)
        if (seen <= 0f) continue
        val o = foot(tx * T + 6.0 + Math.floorMod(hash(k, 9), 20), ty * T + 6.0 + Math.floorMod(hash(k, 11), 20))
        if (ph < 0.25f) {
            // falling ever faster out of the dark, a short streak
            val q = ph / 0.25f
            val h = (1 - q * q) * 64f * zs
            drawRect(Color(0xFFB8D8F0).copy(alpha = 0.8f * seen * kotlin.math.min(1f, q * 4f)), Offset(o.x - px / 2, o.y - (h + 1.5f + q * 2f) * px), androidx.compose.ui.geometry.Size(px, (1.5f + q * 2f) * px))
        } else if (ph < 0.6f) {
            // the ring spreading on the floor, an ellipse as the floor is seen
            val q = (ph - 0.25f) / 0.35f
            val w = (3 + q * 9) * px
            drawOval(
                Color(0xFFB8D8F0).copy(alpha = (1 - q) * 0.6f * seen), Offset(o.x - w / 2, o.y - w / 4), androidx.compose.ui.geometry.Size(w, w / 2),
                style = androidx.compose.ui.graphics.drawscope.Stroke(0.8f * px),
            )
        }
    }
}

/**
 * Seen diagonally (13n): the sparks and the smoke of a room's hearth, rising upright on the screen from the
 * fire in the fire box (0.2 tiles back in the wall) and drawn up into the flue, gone where the mouth ends.
 * Heights are map pixels above the floor.
 */
private fun DrawScope.drawHearthSmoke(game: Game, map: de.bornim.core.MapDef, clock: Long, cam: Cam, camX: Int, camY: Int, scale: Int) {
    val T = WorldArt.T
    val px = scale.toFloat()
    for ((i, src) in MapLight.sources(map).withIndex()) {
        if (src.kind != MapLight.Kind.FIRE) continue
        val seen = LightImage.seen(game, floor(src.x / T).toInt(), floor(src.y / T).toInt(), 0.4f, clock)
        if (seen <= 0f) continue
        // the fire: the light sits 4 pixels in front of the wall, the fire 0.2 tiles inside it
        val mx = ((src.x - camX) * scale).toFloat(); val my = ((src.y - 4 - T * 0.2 - camY) * scale).toFloat()
        val bx = cam.toScreenX(mx, my); val by = cam.toScreenY(mx, my)
        // heights as drawn in the room, lowered to the hero's scale (13p.6)
        fun at(dx: Double, h: Double) = Offset(bx + (dx * scale).toFloat(), by - (h * de.bornim.core.art.MapRoomIso.ZS * scale).toFloat())
        for (k in 0 until 5) {
            // sparks rising and fading before the top of the mouth
            val period = 1400 + k * 230
            val ph = ((clock + k * 517 + i * 131) % period) / period.toFloat()
            val sx = kotlin.math.sin(ph * 6f + k) * 3.0 + (k - 2) * 2
            drawRect(Color(0xFFFFC060).copy(alpha = (1 - ph) * 0.9f * seen), at(sx, 5.0 + ph * 22), androidx.compose.ui.geometry.Size(px, px))
        }
        for (k in 0 until 4) {
            // steam from the kettle, smoke from the embers, thinning towards the flue
            val period = 2200 + k * 410
            val ph = ((clock + k * 830 + i * 97) % period) / period.toFloat()
            val steam = k < 2
            val sx = (if (steam) (k - 0.5) * 3 else (k - 2.5) * 8 * (1 - ph)) + kotlin.math.sin(ph * 5f + k) * (1.5 + ph * 2)
            val h = (if (steam) 16.0 else 4.0) + ph * (if (steam) 9.0 else 21.0)
            val rr = (1.5f + ph * (if (steam) 2.5f else 4f)) * px
            val a = kotlin.math.sin(ph * Math.PI.toFloat() * 0.5f + 0.4f).coerceAtLeast(0f) * (1 - ph) * (if (steam) 0.26f else 0.22f)
            drawCircle(Color(if (steam) 0xFFC8C4BC else 0xFF5A524A).copy(alpha = a * seen), rr, at(sx, h))
        }
    }
}

/**
 * 13e.3 (11): seen diagonally, the daylight falling through a hole in the cave's roof stands upright on the screen:
 * a slanted column, narrow at the hole and widening onto the floor, soft at its edges (several layers on top of each
 * other), the dust drifting slowly down in it. The pool of light on the floor stays in [drawMapLight].
 */
/** 27o: how bright the shaft is by moonlight, against full daylight. */
private const val MOON_BEAM = 0.55f

private fun DrawScope.drawCaveShaft(game: Game, map: de.bornim.core.MapDef, clock: Long, cam: Cam, camX: Int, camY: Int, scale: Int) {
    val T = WorldArt.T
    val px = scale.toFloat()
    // 27o: by day a white beam, at night a fainter one of cool moonlight, fading into each other at dawn and dusk
    val sun = MapLight.strength(map, MapLight.When.SUN, game.daylight).toFloat()
    val moon = MapLight.strength(map, MapLight.When.MOON, game.daylight).toFloat()
    val beam = androidx.compose.ui.graphics.lerp(Color(0xFF000000 or MapLight.MOON_RGB.toLong()), Color(0xFFE8F0FF), sun / (sun + moon).coerceAtLeast(0.01f))
    val strength = (sun + MOON_BEAM * moon).coerceAtMost(1f)
    for ((i, src) in MapLight.sources(map).withIndex()) {
        // one beam per shaft: the moonlight is the same shaft at night
        if (src.kind != MapLight.Kind.SKY || src.shines == MapLight.When.MOON) continue
        val seen = LightImage.seen(game, floor(src.x / T).toInt(), floor(src.y / T).toInt(), 0.4f, clock) * strength
        if (seen <= 0f) continue
        val mx = ((src.x - camX) * scale).toFloat(); val my = ((src.y - camY) * scale).toFloat()
        val bx = cam.toScreenX(mx, my); val by = cam.toScreenY(mx, my)
        // heights as drawn in the rooms, lowered to the hero's scale (13p.6); the sun comes from the upper left
        val top = 120.0
        fun at(dx: Double, h: Double) = Offset(bx + ((dx - h * 0.28) * scale).toFloat(), by - (h * de.bornim.core.art.MapRoomIso.ZS * scale).toFloat())
        val bottom = at(0.0, 0.0).y; val upper = at(0.0, top).y
        // soft edges: four layers, the narrower the brighter
        for (l in 0 until 4) {
            val w = 1.0 - l * 0.2
            val path = androidx.compose.ui.graphics.Path().apply {
                val a = at(-7 * w, top); val b = at(7 * w, top); val c = at(19 * w, 0.0); val d = at(-19 * w, 0.0)
                moveTo(a.x, a.y); lineTo(b.x, b.y); lineTo(c.x, c.y); lineTo(d.x, d.y); close()
            }
            // lost in the dark up top, strongest low down, fading into the pool on the floor
            val base = 0.07f * seen
            drawPath(
                path,
                androidx.compose.ui.graphics.Brush.verticalGradient(
                    0f to beam.copy(alpha = 0f), 0.25f to beam.copy(alpha = base * 0.15f),
                    0.55f to beam.copy(alpha = base * 0.6f), 0.8f to beam.copy(alpha = base),
                    // test of 0.1.667: the beam ended in a straight edge on the floor; now it runs out into the pool
                    1f to beam.copy(alpha = 0f),
                    startY = upper, endY = bottom,
                ),
                blendMode = androidx.compose.ui.graphics.BlendMode.Plus,
            )
        }
        // where it falls: a soft oval of light on the floor (a circle seen at the slant, 2:1), brightest in the middle,
        // breathing a little as clouds pass far above
        val pool = at(0.0, 0.0)
        val breathe = 0.92f + 0.08f * kotlin.math.sin(clock / 2300f + i)
        val rx = 24f * scale; val ry = 12f * scale
        drawContext.canvas.save()
        drawContext.canvas.translate(pool.x, pool.y)
        drawContext.canvas.scale(1f, ry / rx)
        drawCircle(
            androidx.compose.ui.graphics.Brush.radialGradient(
                0f to beam.copy(alpha = 0.16f * seen * breathe), 0.45f to beam.copy(alpha = 0.09f * seen * breathe),
                1f to beam.copy(alpha = 0f), center = Offset.Zero, radius = rx,
            ),
            radius = rx, center = Offset.Zero, blendMode = androidx.compose.ui.graphics.BlendMode.Plus,
        )
        drawContext.canvas.restore()
        for (k in 0 until 10) {
            // motes sinking slowly through the light, glinting as they turn
            val period = 6000 + k * 730
            val ph = ((clock + k * 1170 + i * 313) % period) / period.toFloat()
            val h = top * (0.9 - ph * 0.85)
            val w = 5 + 11 * (1 - h / top)
            val dx = (((k * 37) % 21) / 10.0 - 1.0) * w + kotlin.math.sin(ph * 5f + k) * 2.5
            val glint = 0.55f + 0.45f * kotlin.math.sin(clock / 260f + k * 1.9f)
            drawRect(androidx.compose.ui.graphics.lerp(beam, Color(0xFFFFFFF0), sun).copy(alpha = kotlin.math.sin(ph * Math.PI.toFloat()) * 0.75f * glint * seen), at(dx, h), androidx.compose.ui.geometry.Size(px, px))
        }
    }
}

/**
 * 13e.3 (10): seen diagonally, a torch on a back face of the cave's rock is drawn live: iron bracket, stick, charred
 * head and a flame of three soft tongues (deep red, orange, pale core) that flickers and leans continuously instead of
 * switching between two pictures, a few sparks rising from it.
 */
private fun DrawScope.drawCaveTorches(game: Game, map: de.bornim.core.MapDef, clock: Long, cam: Cam, camX: Int, camY: Int, scale: Int) {
    val T = WorldArt.T
    val u = scale.toFloat()
    for (ty in 0 until map.height) for (tx in 0 until map.width) {
        if (map.tile(tx, ty) != Tile.TORCH) continue
        val (fx, fy) = de.bornim.core.art.MapCaveIso.torchFace(map, tx, ty) ?: continue
        val seen = LightImage.seen(game, floor(fx / T + 0.3).toInt(), floor(fy / T + 0.3).toInt(), 0.4f, clock)
        if (seen <= 0f) continue
        val mx = ((fx - camX) * scale).toFloat(); val my = ((fy - camY) * scale).toFloat()
        // the head of the torch about 1.1 m up the face, lowered to the hero's scale like the rooms' heights (13p.6)
        val bx = cam.toScreenX(mx, my); val by = cam.toScreenY(mx, my) - (62 * de.bornim.core.art.MapRoomIso.ZS * scale).toFloat()
        val t = (clock + tx * 397 + ty * 211).toFloat()
        // bracket and stick, leaning out of the rock; three looks (D1.11): a flat bracket, a ring on a longer arm, wedged in a crack
        when (de.bornim.core.art.MapCaveIso.torchLook(map, tx, ty)) {
            0 -> drawRect(Color(0xFF2A2624).copy(alpha = seen), Offset(bx - 2.5f * u, by + 9 * u), androidx.compose.ui.geometry.Size(5 * u, 1.6f * u))
            1 -> { drawLine(Color(0xFF2A2624).copy(alpha = seen), Offset(bx - 3.5f * u, by + 12 * u), Offset(bx, by + 7 * u), strokeWidth = 1.4f * u)
                drawOval(Color(0xFF34302C).copy(alpha = seen), Offset(bx - 1.8f * u, by + 6.2f * u), androidx.compose.ui.geometry.Size(3.6f * u, 1.8f * u), style = androidx.compose.ui.graphics.drawscope.Stroke(1.1f * u)) }
            else -> for (k in 0..1) drawOval(Color(0xFF2E2A26).copy(alpha = seen), Offset(bx - (2.6f - k * 2.4f) * u, by + (12.2f - k * 0.8f) * u), androidx.compose.ui.geometry.Size(2.6f * u, 1.8f * u))
        }
        drawLine(Color(0xFF3E2C1E).copy(alpha = seen), Offset(bx - 0.6f * u, by + 13 * u), Offset(bx + 0.6f * u, by + 1 * u), strokeWidth = 2.2f * u)
        drawOval(Color(0xFF1C1612).copy(alpha = seen), Offset(bx - 2.2f * u, by - 0.4f * u), androidx.compose.ui.geometry.Size(4.4f * u, 3 * u))
        // the flame: frames of a living flame (MapCaveIso.flame), each torch at its own point of the loop
        val fk = ((clock / 80) + tx * 7 + ty * 13).toInt()
        val img = de.bornim.core.art.MapCaveIso.flame(fk)
        val base = by + 1.2f * u
        val fl = Offset(bx - de.bornim.core.art.MapCaveIso.FLAME_X * u / 2, base - de.bornim.core.art.MapCaveIso.FLAME_Y * u / 2)
        drawImage(
            image = Bitmaps.of(img), srcOffset = IntOffset.Zero, srcSize = IntSize(img.width, img.height),
            dstOffset = IntOffset(fl.x.toInt(), fl.y.toInt()), dstSize = IntSize(img.width * scale / 2, img.height * scale / 2),
            alpha = seen, filterQuality = FilterQuality.None,
        )
        val f = 0.9f + 0.1f * kotlin.math.sin(fk * 0.6f)
        val h = 12 * u
        val lean = 0f
        // a warm halo, breathing with the flame
        drawCircle(
            androidx.compose.ui.graphics.Brush.radialGradient(listOf(Color(0xFFFFA850).copy(alpha = 0.2f * f * seen), Color.Transparent), Offset(bx, base - h * 0.4f), 14 * u),
            14 * u, Offset(bx, base - h * 0.4f), blendMode = androidx.compose.ui.graphics.BlendMode.Plus,
        )
        for (k in 0 until 3) {
            // sparks leaving the tip
            val period = 900 + k * 260
            val ph = ((clock + k * 431 + tx * 97 + ty * 53) % period) / period.toFloat()
            val sx = bx + lean + kotlin.math.sin(ph * 7f + k * 2) * 2.5f * u + (k - 1) * u
            val sy = base - h * 0.8f - ph * 16 * u
            drawRect(Color(0xFFFFC060).copy(alpha = (1 - ph) * 0.85f * seen), Offset(sx, sy), androidx.compose.ui.geometry.Size(u, u))
        }
    }
}

/**
 * Seen diagonally (13, step 3): the light image lies on the ground, and a wall or a tall thing standing up
 * from the floor covers, on the screen, the ground behind it (up the diagonal). There the image is given the
 * light of the floor where that thing stands, a little less the higher up it is: the back walls are lit by
 * the hearth and the windows at their foot, fading upwards, instead of lying in the dark of the ground
 * outside the room. Heights in map pixels on the screen; the walls stand about 52 high ([de.bornim.core.art.MapRoomIso.WALL] × [de.bornim.core.art.MapRoomIso.ZS]).
 */
private fun uprightLight(img: de.bornim.core.art.PixelImage, map: de.bornim.core.MapDef, x0: Int, y0: Int, res: Int) {
    val T = WorldArt.T
    val k = MapSight.K
    val wallTop = (de.bornim.core.art.MapRoomIso.WALL * de.bornim.core.art.MapRoomIso.ZS / de.bornim.core.art.MapRoomIso.D).toFloat()
    val src = img.pixels.copyOf()
    fun room(px: Float, py: Float): Boolean {
        val tx = floor(px / T).toInt(); val ty = floor(py / T).toInt()
        if (!map.inside(tx, ty)) return false
        val t = map.tile(tx, ty)
        return t != Tile.WALL && t != Tile.WINDOW && t != Tile.HEARTH
    }
    // on the screen, going up by h means going back on the map by h / K along both axes
    val maxD = wallTop / k
    val step = res / 2f
    for (yy in 0 until img.height) for (xx in 0 until img.width) {
        val px = x0 + xx * res + res / 2f; val py = y0 + yy * res + res / 2f
        if (room(px, py)) continue
        var d = step
        while (d <= maxD && !room(px + d, py + d)) d += step
        if (d > maxD) continue
        // the floor at the foot, a little inside the room
        val sx = ((px + d + 2 - x0) / res).toInt(); val sy = ((py + d + 2 - y0) / res).toInt()
        if (sx !in 0 until img.width || sy !in 0 until img.height) continue
        val c = src[sy * img.width + sx]
        val f = 1.0f - 0.32f * (k * d / wallTop)
        val r = (((c shr 16) and 0xFF) * f).toInt().coerceIn(0, 255)
        val g = (((c shr 8) and 0xFF) * f).toInt().coerceIn(0, 255)
        val b = ((c and 0xFF) * f).toInt().coerceIn(0, 255)
        img.pixels[yy * img.width + xx] = (0xFF shl 24) or (r shl 16) or (g shl 8) or b
    }
}

/**
 * Seen diagonally outdoors (27l, user 14.10.): a standing stone, a sign or a boulder covers, on the screen, the ground
 * behind it, and took that ground's light: half in the shade of the crowns, half in the clearing, with a hard edge
 * across. Such a thing now takes the light at its foot, over its whole height. Heights in map pixels on the screen.
 */
private fun footLight(img: de.bornim.core.art.PixelImage, map: de.bornim.core.MapDef, x0: Int, y0: Int, res: Int) {
    val T = WorldArt.T
    val k = MapSight.K
    // height and width of the thing's picture on the screen, in map pixels; 0 for everything else
    fun size(t: Tile): Pair<Float, Float> = when (t) {
        Tile.MENHIR -> 44f to 12f
        Tile.SIGN -> 40f to 10f
        Tile.ROCK -> 24f to 28f
        else -> 0f to 0f
    }
    val src = img.pixels.copyOf()
    for (yy in 0 until img.height) for (xx in 0 until img.width) {
        val px = x0 + xx * res + res / 2f; val py = y0 + yy * res + res / 2f
        val fx = floor(px / T).toInt(); val fy = floor(py / T).toInt()
        // a thing standing on a tile in front covers this ground on the screen if it lies inside its outline:
        // up by its height (going back on the map by h / K along both axes), and half its width to either side
        var foot: Pair<Int, Int>? = null; var front = Int.MIN_VALUE; var weight = 0f
        for (dy in 0..2) for (dx in 0..2) {
            val tx = fx + dx; val ty = fy + dy
            if (!map.inside(tx, ty) || tx + ty <= front) continue
            val (h, w) = size(map.tile(tx, ty))
            if (h <= 0f) continue
            val a = px - (tx * T + T / 2f); val b = py - (ty * T + T / 2f)
            val up = -k / 2 * (a + b); val side = k * (a - b)
            // full inside, fading out over a few pixels at the sides and the top, so no box of light shows round it
            val wt = ((w / 2 - kotlin.math.abs(side)) / 4f).coerceIn(0f, 1f) * ((h - up) / 8f).coerceIn(0f, 1f) * ((up + 4f) / 4f).coerceIn(0f, 1f)
            if (wt > 0f) { foot = tx to ty; front = tx + ty; weight = wt }
        }
        val (tx, ty) = foot ?: continue
        // the ground in the middle of the thing's tile
        val sx = ((tx * T + T / 2f - x0) / res).toInt(); val sy = ((ty * T + T / 2f - y0) / res).toInt()
        if (sx !in 0 until img.width || sy !in 0 until img.height) continue
        val c = src[sy * img.width + sx]; val o = src[yy * img.width + xx]
        fun mix(sh: Int) = ((((o shr sh) and 0xFF) * (1 - weight) + ((c shr sh) and 0xFF) * weight).toInt()).coerceIn(0, 255)
        img.pixels[yy * img.width + xx] = (0xFF shl 24) or (mix(16) shl 16) or (mix(8) shl 8) or mix(0)
    }
}

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
    // 84.1/84.5: the light the hero carries
    val carried = when {
        game.torchBurns -> MapLight.Carried.TORCH
        // 255: in a room the spark sits small and dim on the shoulder and lights nothing
        game.state.spark && map.kind != MapKind.INTERIOR -> MapLight.Carried.SPARK
        else -> MapLight.Carried.NONE
    }
    val key = "${map.id}/$x0/$y0/$w/$h/${hx / 3}/${hy / 3}/${(day * 64).toInt()}/$carried"
    if (LightImage.key != key) {
        LightImage.base = MapLight.lightmap(map, day, hx, hy, x0, y0, w, h, carried)
        LightImage.key = key
        LightImage.fogKey = ""
    }
    // the fog of war over it: what comes into sight or goes out of it fades over a moment instead of switching
    // (test 13.10.: turning round in the cave was "almost like a light switch")
    val fade = if (fog) LightImage.fade(game, map, clock) else false
    val fogKey = if (fog) "${game.state.place.x},${game.state.place.y},${Math.round(game.freeWalk.lookYaw() / 5.0)}/${LightImage.fadeStep}" else "-"
    if (LightImage.fogKey != fogKey && (!fade || clock - LightImage.fogAt >= 40 || LightImage.fogKey == "")) {
        LightImage.fogKey = fogKey
        LightImage.fogAt = clock
        val base = LightImage.base ?: return
        val img = if (fog) de.bornim.core.art.PixelImage(base.width, base.height, base.pixels.copyOf()) else base
        if (fog) {
            // darken by the fog of war, smoothly between tile centres: unexplored black, out of sight dim
            // in parts of a tile (LightImage.SUB): the edge of the cone follows the hero's view, not the tiles
            val S = LightImage.SUB
            val tx0 = (Math.floorDiv(x0, T) - 1) * S; val ty0 = (Math.floorDiv(y0, T) - 1) * S
            val tw = (w / T + 4) * S; val th = (h / T + 4) * S
            // test of 0.1.667 (13e): seen diagonally one looks over the low walls into rooms explored already, and
            // the dimmed fog lay over them like a dark cloth; there what is known but out of sight dims only a little
            val raw = FloatArray(tw * th) { i -> LightImage.shadeSub(map, tx0 + i % tw, ty0 + i / tw) }
            // softened over about a tile (test 13.10.: the edge of the cone hard and "square"), once along and once
            // across; what is in sight stays clear
            val kern = floatArrayOf(1f, 3f, 6f, 8f, 6f, 3f, 1f)
            val kr = kern.size / 2
            val half = FloatArray(tw * th) { i ->
                val cx = i % tw; val cy = i / tw
                var sum = 0f; var n = 0f
                for (k in kern.indices) { val x = (cx + k - kr).coerceIn(0, tw - 1); sum += raw[cy * tw + x] * kern[k]; n += kern[k] }
                sum / n
            }
            val fa = FloatArray(tw * th) { i ->
                val cx = i % tw; val cy = i / tw
                var sum = 0f; var n = 0f
                for (k in kern.indices) { val y = (cy + k - kr).coerceIn(0, th - 1); sum += half[y * tw + cx] * kern[k]; n += kern[k] }
                if (raw[i] == 0f) minOf(sum / n, 0.35f) else sum / n
            }
            for (yy in 0 until img.height) for (xx in 0 until img.width) {
                val fx = (x0 + xx * res + res / 2f) * S / T - 0.5f - tx0; val fy = (y0 + yy * res + res / 2f) * S / T - 0.5f - ty0
                val ix = floor(fx).toInt().coerceIn(0, tw - 2); val iy = floor(fy).toInt().coerceIn(0, th - 2)
                val ux = (fx - ix).coerceIn(0f, 1f); val uy = (fy - iy).coerceIn(0f, 1f)
                val a = (fa[iy * tw + ix] * (1 - ux) + fa[iy * tw + ix + 1] * ux) * (1 - uy) + (fa[(iy + 1) * tw + ix] * (1 - ux) + fa[(iy + 1) * tw + ix + 1] * ux) * uy
                if (a <= 0f) continue
                // black only where nothing is known, reached without a step (it showed as a line round the unknown)
                val k = 1f - a * (0.92f + 0.08f * ((a - 0.85f) / 0.15f).coerceIn(0f, 1f))
                val c = img.pixels[yy * img.width + xx]
                val r = (((c shr 16) and 0xFF) * k).toInt(); val g = (((c shr 8) and 0xFF) * k).toInt(); val b = ((c and 0xFF) * k).toInt()
                img.pixels[yy * img.width + xx] = (0xFF shl 24) or (r shl 16) or (g shl 8) or b
            }
        }
        // seen diagonally, the walls and the tall things of a room stand where the light image has the ground behind them
        if (map.kind == MapKind.INTERIOR) uprightLight(img, map, x0, y0, res)
        else footLight(img, map, x0, y0, res)
        // beyond the edge the wood fades into the dark (27m)
        if (de.bornim.core.art.MapEdge.applies(map)) for (yy in 0 until img.height) for (xx in 0 until img.width) {
            val f = de.bornim.core.art.MapEdge.fade(map, x0 + xx * res + res / 2f, y0 + yy * res + res / 2f)
            if (f >= 1f) continue
            val c = img.pixels[yy * img.width + xx]
            val r = (((c shr 16) and 0xFF) * f).toInt(); val g = (((c shr 8) and 0xFF) * f).toInt(); val b = ((c and 0xFF) * f).toInt()
            img.pixels[yy * img.width + xx] = (0xFF shl 24) or (r shl 16) or (g shl 8) or b
        }
        LightImage.img = img
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
    fun visible(o: Offset, r: Float) = true
    for ((i, src) in MapLight.sources(map).withIndex()) {
        val c = at(src.x, src.y)
        val r = (src.reach * 0.75 * scale).toFloat()
        // a light the hero has never seen stays dark, one out of sight shines dimmed: it must not light up what the
        // fog of war hides
        val seen = LightImage.seen(game, floor(src.x / T).toInt(), floor(src.y / T).toInt(), 0.4f, clock)
        // a light standing behind a house throws no glow over its roof (D3.13a)
        val on = MapLight.strength(map, src.shines, day).toFloat() * seen * (1f - MapLight.behindHouse(map, src.x, src.y))
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
            // 27o: at night the open sky lets in cool moonlight instead of white daylight
            MapLight.Kind.SKY -> if (src.shines == MapLight.When.MOON) Color(0xFF000000 or MapLight.MOON_RGB.toLong()) to 0.16f else Color(0xFFE8F0FF) to 0.32f
            MapLight.Kind.EXIT -> if (src.shines == MapLight.When.MOON) Color(0xFF000000 or MapLight.MOON_RGB.toLong()) to 0.09f else Color(0xFFFFF4D8) to 0.18f
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
            // seen diagonally, a hearth's sparks and smoke rise upright on the screen (drawHearthSmoke)
            // a camp fire's sparks rise upright on the screen (drawRisingLife, D1.7, 27n), a cave torch's too (drawCaveTorches)
            MapLight.Kind.FIRE, MapLight.Kind.TORCH -> { if (src.kind == MapLight.Kind.TORCH && map.kind != MapKind.CAVE) for (k in 0 until 2) {
                // sparks rising and fading
                val period = 1400 + k * 230
                val ph = ((clock + k * 517 + i * 131) % period) / period.toFloat()
                val sx = src.x + kotlin.math.sin(ph * 6f + k) * 4 + (k - 2) * 2
                val sy = src.y - 6 - ph * 26
                drawRect(Color(0xFFFFC060).copy(alpha = (1 - ph) * 0.9f * seen), at(sx, sy.toDouble()), androidx.compose.ui.geometry.Size(px, px))
            }
                // in a hearth: steam from the kettle, and smoke rising from the embers and drawn up into the flue,
                // gone where the mouth ends (6.11; 10.10., 16:15: it rose out of the wall above the hearth)
                if (src.kind == MapLight.Kind.FIRE && indoor) for (k in 0 until 4) {
                    val period = 2200 + k * 410
                    val ph = ((clock + k * 830 + i * 97) % period) / period.toFloat()
                    val steam = k < 2
                    val sx = src.x + (if (steam) (k - 0.5) * 3 else (k - 2.5) * 9 * (1 - ph)) + kotlin.math.sin(ph * 5f + k) * (1.5 + ph * 2)
                    val sy = src.y - (if (steam) 14 else 4) - ph * (if (steam) 7 else 17)
                    val rr = (1.5f + ph * (if (steam) 2.5f else 4f)) * px
                    // strongest low down, thinning towards the flue
                    val a = kotlin.math.sin(ph * Math.PI.toFloat() * 0.5f + 0.4f).coerceAtLeast(0f) * (1 - ph) * (if (steam) 0.26f else 0.22f)
                    drawCircle(Color(if (steam) 0xFFC8C4BC else 0xFF5A524A).copy(alpha = a * seen), rr, at(sx, sy.toDouble()))
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
            MapLight.Kind.SHROOM -> if (indoor) for (k in 0 until 3) {
                // spores drifting up from the mushrooms
                val period = 3200 + k * 700
                val ph = ((clock + k * 1100 + i * 377) % period) / period.toFloat()
                val sx = src.x + (k - 1) * 7 + kotlin.math.sin(ph * 9f + i) * 3
                val sy = src.y + 4 - ph * 30
                drawRect(Color(0xFFA8FFF0).copy(alpha = kotlin.math.sin(ph * Math.PI.toFloat()) * 0.8f * seen), at(sx, sy.toDouble()), androidx.compose.ui.geometry.Size(px, px))
            }
            // the shaft of light stands upright in the cave (drawCaveShaft)
            else -> {}
        }
    }
    // 176: the light the hero carries glows warm (torch) or cool (spark) over the ground about him like the torches on
    // the walls, flickering; the light image alone only shows the dark ground as it is drawn
    MapLight.carriedSource(carried, hx.toDouble(), hy.toDouble())?.let { src ->
        val dark = if (map.kind == MapKind.CAVE) 1f else MapLight.strength(map, MapLight.When.NIGHT, day).toFloat()
        if (dark <= 0.02f) return@let
        val t = clock.toFloat()
        val (color, a) = if (carried == MapLight.Carried.TORCH)
            Color(0xFFFFA850) to 0.3f * (0.8f + 0.12f * kotlin.math.sin(t / 83f) + 0.08f * kotlin.math.sin(t / 37f))
        else Color(0xFFDCE8FF) to 0.2f * (0.9f + 0.1f * kotlin.math.sin(t / 160f))
        val c = at(src.x, src.y); val r = (src.reach * 0.75 * scale).toFloat()
        drawCircle(
            androidx.compose.ui.graphics.Brush.radialGradient(listOf(color.copy(alpha = a * dark), color.copy(alpha = a * dark * 0.35f), Color.Transparent), c, r),
            r, c, blendMode = androidx.compose.ui.graphics.BlendMode.Plus,
        )
    }
}

/**
 * Rain over the view (10.10., 1.2): it thickens and thins ([Game.rainLevel]), comes in gusts that
 * also bend it in the wind, falls in three layers (far: fine, faint and slow; near: few, long and
 * fast), each drop its own length and brightness; the light goes grey under it, drops splash on
 * the ground and ring the water. Now and then, far off, sheet lightning ([Game.flashAt]).
 */
private fun DrawScope.drawRain(game: Game, clock: Long, scale: Int) {
    val level = game.rainLevel
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


/**
 * Splashes on the ground, drawn under the turned mapping like the ground itself (D3.5): each lives
 * a moment at its own spot of the part of the map in view ([viewW] × [viewH] map pixels from [camX], [camY]).
 */
private fun DrawScope.drawRainSplashes(game: Game, map: de.bornim.core.MapDef, clock: Long, camX: Int, camY: Int, scale: Int, viewW: Float, viewH: Float) {
    val level = game.rainLevel
    if (level <= 0.01f) return
    val T = WorldArt.T
    val gust = 0.5f + 0.5f * kotlin.math.sin(clock / 6100f) * kotlin.math.sin(clock / 2300f + 1.3f)
    val k = level * (0.7f + 0.3f * gust)
    val viewTx = camX / T; val viewTy = camY / T
    val tw = (viewW / T).toInt() + 2; val th = (viewH / T).toInt() + 2
    // as many to a tile as on the screen before
    val screenTiles = ((size.width / scale / T).toInt() + 2) * ((size.height / scale / T).toInt() + 2)
    for (d in 0 until (60 * k * tw * th / screenTiles).toInt()) {
        val life = 380L + hash(d, 50) % 300
        val cycle = (clock + hash(d, 51) % 997) / life
        val ph = ((clock + hash(d, 51) % 997) % life) / life.toFloat()
        val wx = (viewTx + Math.floorMod(hash(d, cycle.toInt(), 52), tw)) * T + Math.floorMod(hash(cycle.toInt(), d, 53), T)
        val wy = (viewTy + Math.floorMod(hash(cycle.toInt(), d, 54), th)) * T + Math.floorMod(hash(d, cycle.toInt(), 55), T)
        val tile = map.tile(wx / T, wy / T)
        val o = Offset(((wx - camX) * scale).toFloat(), ((wy - camY) * scale).toFloat())
        // the rings on the water are drawn with the rest of its life (221, [drawWaterOver])
        if (tile != de.bornim.core.Tile.WATER && tile.walkable && ph < 0.45f) {
            // a drop striking the ground: a tiny flat spray that spreads and is gone
            val q = ph / 0.45f; val r = (0.7f + q * 1.8f) * scale
            drawOval(Color(0xFFC8D4E0).copy(alpha = (1 - q) * 0.32f), Offset(o.x - r, o.y - r * 0.8f), androidx.compose.ui.geometry.Size(r * 2, r * 1.6f), style = androidx.compose.ui.graphics.drawscope.Stroke(0.5f * scale))
        }
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
    val mageArmor: Boolean = false,
) {
    companion object {
        fun of(game: de.bornim.core.Game): HudInfo {
            val h = game.hero
            val from = de.bornim.core.Rules.xpForLevel[h.level]
            val xp = if (de.bornim.core.Story.capped(game.state)) 1f else de.bornim.core.Rules.xpToNext(h.level)?.let { to -> ((h.xp - from).toFloat() / (to - from)).coerceIn(0f, 1f) }
            val ailments = de.bornim.core.Status.entries.filter { game.state.ailment(it) > 0 || (it == de.bornim.core.Status.DRUNK && game.state.drunk) }
            return HudInfo(h.hp, h.maxHp, h.sp, h.maxSp, h.level, xp, h.unspentPoints, game.state.day, game.state.minutes, game.isNight, ailments, game.state.wellFed,
                game.state.mageArmorOn && (h.item(de.bornim.core.GearSlot.CHEST)?.def?.armor ?: 0) == 0)
        }
    }
}

@Composable
private fun HudChip(info: HudInfo, lang: de.bornim.core.Lang, modifier: Modifier, bar: Boolean = false, onMap: (() -> Unit)? = null, onMenu: () -> Unit) {
    val german = lang == de.bornim.core.Lang.DE
    // Compact: bars on the left, level, points and time on the right, so the map stays visible.
    Row(
        (if (bar) modifier.background(Color.Black).drawBehind {
            // a thin gold line below, like the frame of the dialog box (60, 77.1)
            drawLine(Veil.rim, Offset(0f, size.height - 0.5f), Offset(size.width, size.height - 0.5f), 1.dp.toPx())
        } else modifier.clip(RoundedCornerShape(8.dp)).background(Color(0xAA000000)))
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
                (if (info.wellFed) listOf((if (german) "Satt" else "Fed") to Color(0xFFB07A30)) else emptyList()) +
                (if (info.mageArmor) listOf((if (german) "Schutz" else "Ward") to Colors.sp) else emptyList())
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
        // 86.2: the map sign of the menu tab opens the map at once; a finger wide, well apart from the bag
        if (onMap != null) {
            Box(Modifier.size(44.dp, 40.dp).tap(onMap), contentAlignment = Alignment.Center) {
                Canvas(Modifier.size(28.dp)) { glyph(TabSign.MAP, Veil.gold) }
            }
            Spacer(Modifier.width(14.dp))
        }
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
fun DialogBox(speaker: String?, text: String, done: Boolean, modifier: Modifier = Modifier, full: String = text) {
    if (DialogLook.draft) { DialogBoxVeil(speaker, text, done, modifier, full); return }
    val time = rememberTime()
    Column(modifier.fillMaxWidth()) {
        if (speaker != null) {
            Panel(Modifier.offset(y = 6.dp)) { Txt(speaker, size = 15.sp, bold = true, color = Colors.accent) }
        }
        Panel(
            Modifier
                .fillMaxWidth()
                .heightIn(min = 120.dp)
        ) {
            Box { Txt(full, size = 18.sp, color = Color.Transparent); Txt(text, size = 18.sp) }
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

/** Test tab (27m): counts the map's frames, so the rate can be read on the phone where the edge of the wood is drawn. */
object FrameMeter {
    var on by mutableStateOf(false)
    var text by mutableStateOf("")
        private set
    private var since = 0L; private var last = 0L; private var count = 0; private var worst = 0L

    fun tick(now: Long) {
        if (last != 0L) worst = maxOf(worst, now - last)
        last = now; count++
        if (since == 0L) since = now
        if (now - since >= 1_000_000_000L) {
            text = "${(count * 1e9 / (now - since)).roundToInt()} B/s · max ${worst / 1_000_000} ms"
            since = now; count = 0; worst = 0L
        }
    }
}
