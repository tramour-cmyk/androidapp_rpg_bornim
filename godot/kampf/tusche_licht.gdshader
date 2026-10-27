// Tusche nach Licht: Kanten aus der Tiefe (Umriss und Knick), im Schatten dick, im Licht duenner (Chef 25.10.: „Tusche dicke“).
// 348.13 (Chef 26.10., 11:20): nach der Lichtrichtung: Kanten, deren Aussenseite zur Sonne zeigt, duenn bis weg, abgewandte kraeftig
// (wie die Busch-Tusche in toon.gdshader); richtung = 0: alt, nur nach Helligkeit
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix, fog_disabled;
stencil_mode read, compare_equal, 0;   // nur, wo nichts markiert ist (main.gd: 1 Blueten, 2 Held mit eigener Flaeche)
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float px = 1.3;            // Linienbreite in Bildpunkten bei 540 Punkten Bildbreite, waechst mit der Aufloesung
uniform float dick = 1.25;         // Faktor im Schatten (Build 11: 1,5 zu dick am Helden)
uniform float duenn = 0.25;        // 348.13: Faktor auf der Lichtseite (0 = keine Linie)
uniform float richtung = 1.0;      // 348.13: 1 nach der Lichtrichtung, 0 alt (nur Helligkeit)
uniform vec3 licht_dir = vec3(0.0, 1.0, 0.0);   // zur Sonne, Welt (Licht.richtung, licht.gd)
uniform float umriss_licht = 1.0;  // 348.13: Umriss auf der Lichtseite deckend (0 = wie Lauf 100, blass wie die Knicke)
uniform float innen = 1.0;         // 348.13: Umriss nur auf der vorderen Flaeche (0 = beidseits der Kante wie d08456e7d)
uniform float breite_m = 3.4;      // 348.13: Bildbreite in Metern (Kamera.size)
uniform float zoomdick = 1.0;      // 348.13: 1 Schattenseite weiter weg duenner (Wurzel aus Nah/Bildbreite, hoechstens 0,6-fach), 0 wie 832ad3959
uniform float hinten_ab = 0.25;   // 348.13: Meter, ab denen die hintere Seite einer Stufe keine Tusche bekommt (Boden hinter dem Umriss)
uniform float umriss_dick = 1.0;   // 348.13a (Chef 27.10., 09:41): Schattenseite im Kampf kraeftiger; nur am Umriss, Knicke im Gesicht bleiben
uniform float knick = 0.06;        // Meter: Krümmung der Tiefe, ab der eine Linie entsteht
uniform vec3 ink : source_color = vec3(0.07, 0.05, 0.04);
void vertex() { POSITION = vec4(VERTEX.xy, 1.0, 1.0); }
float lz(vec2 uv, mat4 ip) {
	float d = texture(depth_tex, clamp(uv, vec2(0.0005), vec2(0.9995))).r;   // am Bildrand nicht ueber den Rand greifen
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	d = d * 2.0 - 1.0;   // OpenGL: Tiefe -1..1 (Rechnerbilder), Vulkan am Handy: 0..1
#endif
	vec4 v = ip * vec4(uv * 2.0 - 1.0, d, 1.0);
	return -v.z / v.w;
}
void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float lum = dot(c, vec3(0.2126, 0.7152, 0.0722));
	float hell = smoothstep(0.1, 0.6, lum);
	vec2 e1 = px * max(1.0, min(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y) / 540.0) / VIEWPORT_SIZE;
	float z = lz(SCREEN_UV, INV_PROJECTION_MATRIX);
	float f = mix(dick, 1.0, hell), a_licht = mix(1.0, 0.85, hell);
	if (richtung > 0.5) {
		// Aussenseite der Kante = Richtung, in der die Tiefe waechst (zum Hintergrund); Sonne auf den Bildschirm (UV: y nach unten)
		vec2 g = vec2(lz(SCREEN_UV + vec2(e1.x * dick, 0), INV_PROJECTION_MATRIX) - lz(SCREEN_UV - vec2(e1.x * dick, 0), INV_PROJECTION_MATRIX),
			lz(SCREEN_UV + vec2(0, e1.y * dick), INV_PROJECTION_MATRIX) - lz(SCREEN_UV - vec2(0, e1.y * dick), INV_PROJECTION_MATRIX));
		vec3 lv = (VIEW_MATRIX * vec4(licht_dir, 0.0)).xyz;
		// Helfer an Lauf 94 (blind nur knapp besser): Lichtseite kaum duenner, Held gar nicht; die Sonne steht hoch, lv.xy war kurz
		// (s hoechstens etwa 0,3), und dunkle Kleidung galt als tiefer Schatten: Sonne auf dem Bild normiert, Schattengrenze tiefer
		vec2 sl = vec2(lv.x, -lv.y);
		float s = length(sl) > 0.05 ? dot(g / max(length(g), 1e-4), normalize(sl)) : 0.0;
		// Held dreht morgens nicht mit (nachgestellt 26.10.): s stimmte, aber die Sperre 0,02 bis 0,1 hielt 94 bis 98 % der Kantenpunkte
		// zurueck; screen_tex ist dunkel (Sonne 0,02 bis 0,05, Schatten unter 0,015): Sperre 0,008 bis 0,02
		float ls = smoothstep(0.0, 0.6, s) * smoothstep(0.008, 0.02, lum);   // im tiefen Schatten keine Lichtseite
		// Helfer an Lauf 96 (blind schlechter als 94): Lichtseite als Luecke und Sprenkel (Bank, Pfosten, Kirchenkante); unter
		// einem Bildpunkt Abstand greift die Tiefe (filter_nearest) denselben Punkt, die Kante faellt aus: nicht unter 1 Bildpunkt
		// Helfer am Rechner in 1080 (zwei Runden blind, knapp vor 94 und 97): 1 echter Bildpunkt, nicht 1 Punkt bei 540 (in 1080 waren es 2)
		// Helfer 23:1x (blind, 22 Paare): Schattenseite in Grundansicht und weit zu dick, treppig, an Mantel und Schild doppelt;
		// nachgestellt (Magenta-Tusche): Schattenseite Grund 4,2 bis 4,7 Bildpunkte, nah 2,2 bis 2,4, obwohl der Held dort 2,6-mal
		// kleiner ist; die Verdoppelung unten aendert daran nichts (ausgeschaltet gleich), die Breite folgt px und dick. Darum dick mit
		// dem Zoom: nah voll, weiter weg Wurzel aus Nah/Bildbreite (hoechstens 0,6-fach), nie duenner als die Lichtseite
		float l1 = max(duenn, 1.05 / (px * max(1.0, min(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y) / 540.0)));
		float zs = mix(1.0, clamp(sqrt(3.4 / max(breite_m, 0.1)), 0.6, 1.0), zoomdick);
		f = mix(max(dick * zs, l1), l1, ls);
		// Helfer Runde 2 (21:00): weit herausgezoomt verliert der Held links und oben fast den Umriss, das Kirchdach verschwimmt mit dem
		// Pflaster; 1 Bildpunkt mit 0,45 Deckung ist auf hellem Grund kaum zu sehen: am Umriss (Tiefensprung ueber 0,4 m, Knick und
		// schraeger Boden bleiben auch weit unter 0,25 m) bleibt die Lichtseite duenn, aber deckend; Knicke im Licht weiter blass
		float umriss = smoothstep(0.4, 1.0, length(g)) * umriss_licht;
		a_licht = mix(1.0, mix(0.45, 0.85, umriss), ls);
		// Helfer Runde 3 (21:20): Schattenband steht vom Helden ab wie eine zweite Figur; nachgestellt: 60 bis 80 % der Tusche am Helden
		// lag aussen auf dem Boden, gezeichnet vom breiteren Durchgang der Welt; am Umriss nur auf der vorderen Flaeche, doppelt so tief
		// Helfer 22:1x: Heldenlinie wechselt die Seite nicht; nachgestellt (Magenta-Tusche, Breite je Bildpunkt): ls kippt richtig, aber
		// die Verdoppelung galt auch auf der Lichtseite (2 x 1 Bildpunkt), und tiefer als dick sieht g keinen Rand mehr: Lichtseite 2,1,
		// Schattenseite 2,4 Bildpunkte, kaum verschieden. Verdoppeln nur im Schatten, die Lichtseite bleibt 1 Bildpunkt
		f *= mix(1.0, 2.0, smoothstep(0.4, 1.0, length(g)) * innen * (1.0 - ls));
		// 348.13a: Helfer am Blatt (dick 1,4 und 1,8 auf alle Kanten): linke Gesichtshaelfte der Goblins schwarz, Hand am Griff Klumpen,
		// Streifen an den Beinen; kraeftiger darum nur am Umriss (Tiefensprung ueber 0,4 m) und nur im Schatten
		f *= mix(1.0, umriss_dick, smoothstep(0.04, 0.12, length(g)) * (1.0 - ls));
	}
	vec2 e = e1 * f;
	float zl = lz(SCREEN_UV - vec2(e.x, 0), INV_PROJECTION_MATRIX), zr = lz(SCREEN_UV + vec2(e.x, 0), INV_PROJECTION_MATRIX);
	float zd = lz(SCREEN_UV - vec2(0, e.y), INV_PROJECTION_MATRIX), zu = lz(SCREEN_UV + vec2(0, e.y), INV_PROJECTION_MATRIX);
	float lap = abs(zl + zr + zd + zu - 4.0 * z);
	float hinten = smoothstep(hinten_ab, hinten_ab * 1.6, z - min(min(zl, zr), min(zd, zu))) * innen * step(0.5, richtung);   // hinter der Kante: Boden
	float edge = smoothstep(knick, knick * 2.5, lap);
	ALBEDO = ink;
	ALPHA = edge * a_licht * (1.0 - hinten);
}
