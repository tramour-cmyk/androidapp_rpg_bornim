// Drei Lichtstufen (hell, halb, Schatten = nur Umgebung); Farbe = gemalte Textur (tex.py) mal Toenung aus den Eckfarben.
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform sampler2D tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float glow = 0.0;
uniform float glut = 0.0;          // 348.7 Grimmzahn: Eckfarbe mit Alpha 0 glüht (Augen, wolf.py)
uniform float fill = 0.0;          // Held: Mindesthelligkeit im Schatten
uniform float sway = 0.0;          // Laub: im Wind wiegen
uniform float cut_on = 0.0;        // Durchsicht (DESIGN-STIL „Karte und Räume“, 353a): Laub vor dem Helden weich ausblenden
uniform vec3 cut_pos = vec3(0.0);  // Brust des Helden
uniform float cut_ab = 0.0;        // Rinde: erst ab dieser Hoehe (Stamm in der Krone), Laub: ganz
uniform vec3 glow_col : source_color = vec3(1.0, 0.72, 0.38);          // Glas: nachts leuchtend
uniform float vorrang = 0.0;       // 463 wie shader/toon.gdshader: Umhang (UV2.x > 0,5) so viele Meter zur Kamera
uniform float rueck = 0.0;         // 463: Rueckseiten (Normale von der Kamera weg) so viele Meter laengs des Blickstrahls zurueck; Lagen in Falten
uniform float nach = 0.0;          // 463: Aermel (UV2.y > 0,5, held_klassen.py vorrang_marke) so viele Meter zurueck; verlieren gegen Umhang und Kette
uniform float weg = 0.0;           // 348.7: Ausblenden des Toten (0 da, 1 weg), als Raster, damit Tiefe und Tusche bleiben
uniform float schnitt = 0.0;       // 506 Grabhund: Haarkarten (glTF MASK) unter diesem Alpha ausgeschnitten, auch im Schatten
varying vec3 wpos;
void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	if (sway > 0.0) {
		float h = clamp((wpos.y - 1.6) / 2.5, 0.0, 1.0);
		float t = TIME * 1.3 + wpos.x * 0.35 + wpos.z * 0.27;
		vec3 d = vec3(sin(t) + 0.4 * sin(t * 2.7), 0.0, cos(t * 0.8) * 0.6) * 0.045 * h * sway;
		VERTEX += (inverse(MODEL_MATRIX) * vec4(d, 0.0)).xyz;
	}
	// 518 (Build 248, Chef 20:47: Dorf ohne Haeuser): schreibt der Shader POSITION irgendwo, nimmt Godot es fuer jede Ecke; ungeschrieben
	// fielen alle Ecken auf einen Punkt (Haeuser, Baeume, Haar, Waffe unsichtbar, nur Tusche und Schatten blieben). Darum immer setzen,
	// zuletzt (nach dem Wiegen), ohne Versatz genau wie Godot selbst
	vec4 vv = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	if (rueck > 0.0 || (nach > 0.0 && UV2.y > 0.5) || (vorrang > 0.0 && UV2.x > 0.5)) {   // laengs des Blickstrahls: Lage im Bild bleibt, nur die Tiefe
		vec3 blick = PROJECTION_MATRIX[3][3] > 0.5 ? vec3(0.0, 0.0, -1.0) : normalize(vv.xyz);   // Dorf orthogonal (kamera.gd), Kampfort perspektivisch
		if (vorrang > 0.0 && UV2.x > 0.5) vv.xyz -= blick * vorrang;
		// 463 (pruef_flecken RUECK): Innenseite einer Lage verliert gegen eine Vorderseite bis rueck dahinter; Vorderseiten bleiben
		if (rueck > 0.0) vv.xyz += blick * rueck * smoothstep(0.0, 0.2, dot(normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz), blick));
		if (nach > 0.0 && UV2.y > 0.5) vv.xyz += blick * nach;
	}
	POSITION = PROJECTION_MATRIX * vv;
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
#ifdef DURCH
	if (deck < 0.5) discard;
#ifdef TIEFE
	ALPHA = 0.0;
#else
	ALPHA = 1.0 - 0.85 * durch;
#endif
#else
	if (loch > 0.5 && !IN_SHADOW_PASS) discard;
#endif
	if (weg > 0.0 && fract(sin(dot(floor(FRAGCOORD.xy), vec2(12.9898, 78.233))) * 43758.5453) < weg) discard;
	vec4 t = texture(tex, UV);
	if (schnitt > 0.0 && t.a < schnitt) discard;
	ALBEDO = t.rgb * COLOR.rgb;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;      // kein Glanz aus der Umgebung (sonst Plastik)
	METALLIC = 0.0;
	EMISSION = glow_col * glow + COLOR.rgb * (1.0 - COLOR.a) * glut;
}
void light() {
	float ndl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float l = ndl * ATTENUATION;
	float b;
	if (LIGHT_IS_DIRECTIONAL) b = smoothstep(0.38, 0.5, l) * 0.45 + smoothstep(0.04, 0.12, l) * 0.55;   // Sonne, Mond: drei Stufen, weiche Kante
	else b = ndl * smoothstep(0.0, 1.0, ATTENUATION);                                                     // Lampen, Fackel: weicher Schein
	if (LIGHT_IS_DIRECTIONAL) b = max(b, fill);
	DIFFUSE_LIGHT += b * LIGHT_COLOR / PI;
}
