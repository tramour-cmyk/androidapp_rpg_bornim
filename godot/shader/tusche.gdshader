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
		float ls = smoothstep(0.0, 0.6, s) * smoothstep(0.02, 0.1, lum);   // im tiefen Schatten keine Lichtseite
		// Helfer an Lauf 96 (blind schlechter als 94): Lichtseite als Luecke und Sprenkel (Bank, Pfosten, Kirchenkante); unter
		// einem Bildpunkt Abstand greift die Tiefe (filter_nearest) denselben Punkt, die Kante faellt aus: nicht unter 1 Bildpunkt
		// Helfer am Rechner in 1080 (zwei Runden blind, knapp vor 94 und 97): 1 echter Bildpunkt, nicht 1 Punkt bei 540 (in 1080 waren es 2)
		f = mix(dick, max(duenn, 1.05 / (px * max(1.0, min(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y) / 540.0))), ls);
		a_licht = mix(1.0, 0.45, ls);
	}
	vec2 e = e1 * f;
	float zl = lz(SCREEN_UV - vec2(e.x, 0), INV_PROJECTION_MATRIX), zr = lz(SCREEN_UV + vec2(e.x, 0), INV_PROJECTION_MATRIX);
	float zd = lz(SCREEN_UV - vec2(0, e.y), INV_PROJECTION_MATRIX), zu = lz(SCREEN_UV + vec2(0, e.y), INV_PROJECTION_MATRIX);
	float lap = abs(zl + zr + zd + zu - 4.0 * z);
	float edge = smoothstep(knick, knick * 2.5, lap);
	ALBEDO = ink;
	ALPHA = edge * a_licht;
}
