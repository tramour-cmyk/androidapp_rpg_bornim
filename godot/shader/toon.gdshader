// Drei Lichtstufen (hell, halb, Schatten = nur Umgebung); Farbe = gemalte Textur (tex.py) mal Toenung aus den Eckfarben.
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform sampler2D tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float glow = 0.0;
uniform float fill = 0.0;          // Held: Mindesthelligkeit im Schatten
uniform float sway = 0.0;          // Laub: im Wind wiegen
uniform float cut_on = 0.0;        // Durchsicht (DESIGN-STIL „Karte und Räume“, 353a): Laub vor dem Helden weich ausblenden
uniform vec3 cut_pos = vec3(0.0);  // Brust des Helden
uniform float cut_ab = 0.0;        // Rinde: erst ab dieser Hoehe (Stamm in der Krone), Laub: ganz
uniform float weg = 0.0;           // Durchsicht als Ganzes (gebiet.gd, Gruppe: Haus, Stand, Laterne verdeckt den Helden): deckend aus, nur DURCH
uniform float durch_a = 0.5;       // dabei Deckkraft (alt WorldScreen: zusammen halb)
uniform vec3 glow_col : source_color = vec3(1.0, 0.72, 0.38);          // Glas: nachts leuchtend
uniform float kontur = 0.0;        // Busch: Tusche im Zeichner nach dem Licht, Schattenseite kraeftig, Lichtseite keine (Chef 25.10., 10:16)
uniform vec3 licht_dir = vec3(0.0, 1.0, 0.0);   // zur Sonne, Welt (Licht.richtung)
uniform vec3 ink : source_color = vec3(0.07, 0.05, 0.04);              // wie tusche.gdshader
// 348.6 Glanz (Helfer: Kettenhemd fern wie Filz, Helm wie Wollmuetze): nur am Helden (held.gd), Metall aus der Deckkraft der Eckfarben
// (rig.py: 1 matt, 0,5 Kette, 0 blankes Eisen); Glanzpunkt nach Licht und Blick, hart abgestuft wie die Lichtstufen
uniform float metall = 0.0;
uniform float glanz_eisen = 0.9;
uniform float glanz_kette = 0.5;
// Kettenhemd fern (Helfer: grauer Filz mit Metallton): die Ringe sind kleiner als drei Bildpunkte und mitteln sich zu Grau; dort je
// Ring (Zelle im Bild, held.gd: Ring in UV) ein Glitzerpunkt nach einer zufaellig gekippten Normale, Grund etwas dunkler; nah aus
uniform float kette_zelle = 0.0;
uniform float glitzer = 1.0;
uniform float glitzer_kipp = 0.9;
uniform float glitzer_schwelle = 0.95;
uniform float glitzer_anteil = 0.35;
uniform float kette_dunkel = 0.8;
varying vec3 wpos;
varying float v_eisen;
varying float v_kette;
varying float v_fern;
varying vec2 v_zelle;
void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	if (sway > 0.0) {
		float h = clamp((wpos.y - 1.6) / 2.5, 0.0, 1.0);
		float t = TIME * 1.3 + wpos.x * 0.35 + wpos.z * 0.27;
		vec3 d = vec3(sin(t) + 0.4 * sin(t * 2.7), 0.0, cos(t * 0.8) * 0.6) * 0.045 * h * sway;
		VERTEX += (inverse(MODEL_MATRIX) * vec4(d, 0.0)).xyz;
	}
}
void fragment() {
	// Laub zwischen Kamera und Held: innen fast frei, nach aussen weich dicht. Der deckende Durchgang laesst das Loch aus (Schatten bleibt),
	// die Durchgaenge TIEFE und DURCH (gebiet.gd, nach der Tusche) malen es halbdurchsichtig, je Bildpunkt nur die vorderste Lage, und decken
	// ueber den Lochrand hinaus deckend, damit die Tusche an der Lochkante (beidseitig) verschwindet.
	float durch = 0.0, loch = 0.0, deck = 0.0;
	if (cut_on > 0.5 && wpos.y > cut_ab) {
		vec3 d = wpos - cut_pos;
		float along = dot(d, CAMERA_DIRECTION_WORLD);   // > 0: zur Kamera hin (nachgestellt 25.10.)
		float side = length(d - CAMERA_DIRECTION_WORLD * along);
		// weich nur ueber den Abstand quer zur Blickachse; die Tiefe (along) weit gestaffelt, sonst harte Kante, wo die Krone sich wegkruemmt
		durch = (1.0 - smoothstep(0.7, 1.6, side)) * smoothstep(-0.9, 0.3, along) * smoothstep(cut_ab, cut_ab + 0.8, wpos.y);
		loch = step(side, 1.65) * step(-0.95, along);
		deck = step(side, 2.0) * step(-1.15, along);
	}
	if (weg > 0.5) { loch = 1.0; deck = 1.0; }
#ifdef DURCH
	if (deck < 0.5) discard;
#ifdef TIEFE
	ALPHA = 0.0;
#else
	ALPHA = weg > 0.5 ? durch_a : 1.0 - 0.85 * durch;
#endif
#else
	if (loch > 0.5 && !IN_SHADOW_PASS) discard;
#endif
	ALBEDO = texture(tex, UV).rgb * COLOR.rgb;
	if (kontur > 0.0) {
		float rim = 1.0 - abs(dot(NORMAL, VIEW));
		float sch = 1.0 - smoothstep(-0.2, 0.35, dot(normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz), licht_dir));
		float w = mix(0.88, 0.62, sch);   // im Schatten breiter; Helfer Runde 9: schwarze Keile in den Naehten zwischen den Ballen -> schmaler, nur halb deckend
		ALBEDO = mix(ALBEDO, ink, smoothstep(w, w + 0.1, rim) * smoothstep(0.2, 0.7, sch) * 0.6 * kontur);
	}
	v_eisen = metall * (1.0 - smoothstep(0.15, 0.35, COLOR.a));
	v_kette = metall * smoothstep(0.15, 0.35, COLOR.a) * (1.0 - smoothstep(0.65, 0.85, COLOR.a));
	v_fern = 0.0;
	v_zelle = vec2(0.0);
	// Ring in Bildpunkten, in der feineren Richtung (Runde 2, Helfer nah: weisse Flecken am Kragen, dort schraeg und nur in einer
	// Richtung gestaucht); Ableitung ausserhalb der Verzweigung
	float px = kette_zelle / max(min(length(dFdx(UV)), length(dFdy(UV))), 1e-7);
	if (v_kette > 0.0 && kette_zelle > 0.0) {
		v_fern = (1.0 - smoothstep(3.0, 6.0, px)) * v_kette;
		v_zelle = floor(UV / kette_zelle);
		ALBEDO *= mix(1.0, kette_dunkel, v_fern);
	}
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;      // kein Glanz aus der Umgebung (sonst Plastik)
	METALLIC = 0.0;
	EMISSION = glow_col * glow;
}
void light() {
	float ndl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float l = ndl * ATTENUATION;
	float b;
	if (LIGHT_IS_DIRECTIONAL) b = smoothstep(0.38, 0.5, l) * 0.45 + smoothstep(0.04, 0.12, l) * 0.55;   // Sonne, Mond: drei Stufen, weiche Kante
	else b = ndl * smoothstep(0.0, 1.0, ATTENUATION);                                                     // Lampen, Fackel: weicher Schein
	if (LIGHT_IS_DIRECTIONAL) b = max(b, fill);
	DIFFUSE_LIGHT += b * LIGHT_COLOR / PI;
	if (v_eisen + v_kette > 0.0) {
		float nh = clamp(dot(NORMAL, normalize(LIGHT + VIEW)), 0.0, 1.0);
		// Runde 2 (Helfer blind: weisser, ausgebrannter Fleck wie Plastik, Kragen wie Waesche): Glanz in der Farbe des Metalls, schmaler
		float s = smoothstep(0.88, 0.93, nh) * glanz_eisen * v_eisen + smoothstep(0.8, 0.92, nh) * glanz_kette * v_kette;
		vec3 lc = LIGHT_COLOR / max(1.0, max(LIGHT_COLOR.r, max(LIGHT_COLOR.g, LIGHT_COLOR.b)));   // Fackel nah: nicht ausbrennen
		SPECULAR_LIGHT += s * min(ndl * ATTENUATION, 1.0) * lc * ALBEDO;
		if (v_fern > 0.0) {
			vec3 h3 = fract(sin(vec3(dot(v_zelle, vec2(127.1, 311.7)), dot(v_zelle, vec2(269.5, 183.3)), dot(v_zelle, vec2(419.2, 371.9)))) * 43758.5453);
			// Runde 2 (Helfer: Kragen wie Schnee, Punkte wie Pailletten): stark gekippt, damit die Punkte verstreut statt im Glanzfleck
			// gehaeuft liegen; nur jeder dritte Ring; in der Farbe des Metalls
			vec3 n2 = normalize(NORMAL + (h3 - 0.5) * 2.0 * glitzer_kipp);
			float g = step(glitzer_schwelle, dot(n2, normalize(LIGHT + VIEW))) * step(0.05, ndl) * step(fract(h3.x * 7.31 + h3.z * 3.17), glitzer_anteil);
			SPECULAR_LIGHT += g * glitzer * v_fern * min(ATTENUATION, 1.0) * lc * ALBEDO * 1.4;
		}
	}
}
