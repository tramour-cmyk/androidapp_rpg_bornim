// Fluss wie MapGround.kt/WaterLife.kt: graugruen am Rand, fast schwarz in der Tiefe, duenne Lichtstreifen.
// 348.6 (Befund 4b): Farben sind sRGB wie im alten Spiel (vorher linear gelesen: 2,5-fach zu hell, „helles Brett“);
// Tiefe aus dem Alpha der Bodenmaske (dorf.py: Wasserfeld w, Wasser ab 0,5, alt (w - 0,5) * 3,2); ohne Tusche (Schablone 1).
shader_type spatial;
render_mode specular_disabled, unshaded;
stencil_mode write, compare_always, 1;
uniform float night = 0.0;
uniform sampler2D maske : filter_linear, repeat_disable;
uniform vec2 karte = vec2(41.76, 37.12);   // Kartengroesse in Metern
uniform vec3 rim : source_color = vec3(0.165, 0.227, 0.235);     // WATER_S 0x2A3A3C
uniform vec3 deep : source_color = vec3(0.055, 0.102, 0.118);    // WATER_D 0x0E1A1E
uniform vec3 glint_c : source_color = vec3(0.478, 0.557, 0.565); // GLINT 0x7A8E90
// 348.6 (Runde 2c: nachts fast schwarz, nicht als Wasser zu lesen): wie WaterLife.streaks liegen Laternen, Fenster und Mond
// als zitternde Streifen aus kurzen Querlinien zum Betrachter hin auf dem Wasser; Inseln wie boden.gdshader (x, z, Reichweite, Staerke)
uniform vec4 inseln[64];
uniform int inseln_n = 0;
uniform vec3 insel_farbe : source_color = vec3(1.0, 0.66, 0.3);
uniform vec3 mond : source_color = vec3(0.847, 0.894, 0.957);   // MOON 0xD8E4F4
varying vec3 wpos;
void vertex() { wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
float h21(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
	vec2 i = floor(p), f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1, 0)), f.x), mix(h21(i + vec2(0, 1)), h21(i + vec2(1, 1)), f.x), f.y);
}
void fragment() {
	vec2 p = wpos.xz;
	float w = texture(maske, p / karte).a;
	float flow = TIME * 0.45;
	float n = vnoise(vec2(p.x * 0.8 - flow, p.y * 2.2)) * 0.6 + vnoise(vec2(p.x * 2.5 - flow * 2.0, p.y * 6.0)) * 0.4;
	vec3 col = mix(rim, deep, clamp((w - 0.5) * 2.2 + (n - 0.5) * 0.25, 0.0, 1.0));
	// alt: duenne Streifen (|sin| > 0,985 und Rauschen), 45 % zum Glanz; hier wandernd
	float s = abs(sin(p.y * 6.0 + vnoise(vec2(p.x * 1.4 - flow, p.y * 1.4)) * 6.0));
	float glint = smoothstep(0.985, 0.997, s) * smoothstep(0.68, 0.8, vnoise(vec2(p.x * 1.1 - flow * 1.5, p.y * 1.1)));   // Helfer: Wellenlinien zu grell und zu viele
	col = mix(col, glint_c, glint * 0.3 * (1.0 - 0.4 * night));   // nachts matter (Helfer: harte helle Striche; ganz ohne flach wie ein nasser Weg)
	col = col * mix(1.0, 0.4, night) + vec3(0.006, 0.012, 0.024) * night;   // Runde 4 (2): nachts heller als die Wiese; dunkler
	col *= 1.0 + night * (n - 0.5) * 0.7;   // Runde 3 (2): nachts flach: Stroemung als hellere und dunklere Zuege
	if (night > 0.0) {
		vec2 tv = normalize(INV_VIEW_MATRIX[2].xz);       // auf dem Boden zum Betrachter (alt: Karte (1, 1), den Schirm hinab)
		vec2 qv = vec2(-tv.y, tv.x);
		// Helfer Lauf 21/22: Querlinien lasen sich als Leiter; jetzt Glitzern: feines, wanderndes Rauschen in der Spur des Lichts
		vec2 g = vec2(dot(p, qv) * 18.0, dot(p, tv) * 28.0 - TIME * 2.4);   // Lauf 23: Flecken wie Schnee; feiner
		float funkeln = smoothstep(0.7, 0.9, vnoise(g)) * (0.6 + 0.4 * vnoise(g * 0.37 + TIME * 0.7));
		vec3 add = vec3(0.0);
		for (int i = 0; i < inseln_n; i++) {
			vec2 d = p - inseln[i].xy;
			float s_ = dot(d, tv), q = dot(d, qv), r = inseln[i].z * 0.9;
			if (s_ < 0.3 || s_ > r || abs(q) > 0.5) continue;
			float fade = 1.0 - s_ / r;
			add += insel_farbe * 0.8 * inseln[i].w * fade * smoothstep(0.3 + 0.12 * fade, 0.0, abs(q));
		}
		// Mond: eine Spur durch die ganze Sicht, rechts der Bildmitte (alt: durch die Mondspalte)
		// Runde 3 (2): Spur fleckig, schmal, hart am Ufer: weicher Kern mit Schimmer darunter, breiter auslaufend, zum Ufer hin aus
		// Runde 4 (2): bei 0,9 m Halbbreite war die ganze Flussbreite hell (kein Band); alt WaterLife.streaks: 4,5 px halb
		// (0,16 m), nur auf offenem Wasser (w > 0,72); hier 0,22 m mit zitterndem Rand, Glitzer innen, zum Ufer weich aus
		float qm = dot(p - INV_VIEW_MATRIX[3].xz, qv) - 1.6 + sin(dot(p, tv) * 1.3 + TIME * 0.5) * 0.06 + (vnoise(vec2(dot(p, tv) * 4.0, TIME)) - 0.5) * 0.08;
		float spur = smoothstep(0.42, 0.0, abs(qm)); spur *= spur;   // Runde 11 (Urteil Chef 12:11: Streifen neben der Laterne zu hart und hell): weicher Rand, schwaecher
		float ufer = smoothstep(0.5, 1.1, w);   // Runde 5 (4): 0,6..0,86 begann 8 px unter dem Nordufer mit harter Kante; weiter auslaufen
		col += add * funkeln * smoothstep(0.52, 0.7, w) * night + mond * 0.22 * spur * (0.12 + 0.88 * funkeln) * ufer * night;
	}
	ALBEDO = col;
}
