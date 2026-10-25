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
	col = mix(col, glint_c, glint * 0.3);
	col = col * mix(1.0, 0.5, night) + vec3(0.008, 0.016, 0.03) * night;
	if (night > 0.0) {
		vec2 tv = normalize(INV_VIEW_MATRIX[2].xz);       // auf dem Boden zum Betrachter (alt: Karte (1, 1), den Schirm hinab)
		vec2 qv = vec2(-tv.y, tv.x);
		float zeile = fract(dot(p, tv) * 4.0);             // Querlinien, 2,5 Bildpunkte alt = gut 0,25 m
		float linie = smoothstep(0.0, 0.2, zeile) * smoothstep(0.6, 0.35, zeile);
		vec3 add = vec3(0.0);
		for (int i = 0; i < inseln_n; i++) {
			vec2 d = p - inseln[i].xy;
			float s_ = dot(d, tv), q = dot(d, qv), r = inseln[i].z * 0.9;
			if (s_ < 0.3 || s_ > r || abs(q) > 0.5) continue;
			float fade = 1.0 - s_ / r;
			float wob = sin(TIME * 5.3 + s_ * 6.8 + inseln[i].x) * 0.5 + sin(TIME * 13.0 + s_ * 12.4) * 0.25;
			float half_ = 0.18 * (0.6 + 0.4 * fade) * (0.75 + 0.35 * wob);
			float a = 0.55 * inseln[i].w * fade * (0.55 + 0.45 * wob);
			add += insel_farbe * a * smoothstep(half_, half_ * 0.5, abs(q + sin(TIME * 3.8 + s_ * 4.0) * 0.03));
		}
		// Mond: ein Streifen durch die ganze Sicht, eine Spalte rechts der Bildmitte (alt: durch die Mondspalte)
		float qm = dot(p - INV_VIEW_MATRIX[3].xz, qv) - 1.6;
		float s2 = dot(p, tv);
		float wob2 = sin(TIME * 5.3 + s2 * 6.8 + 7.0) * 0.5 + sin(TIME * 13.0 + s2 * 12.4) * 0.25;
		// Helfer Lauf 21: Leiter aus gleichen harten Strichen; jetzt je Strich eigene Laenge, Lage und Helligkeit, manche fehlen
		float k2 = floor(s2 * 4.0);
		float hk = h21(vec2(k2, 7.0)), hk2 = h21(vec2(k2, 19.0));
		float hm = 0.24 * (0.45 + 0.75 * hk) * (0.75 + 0.35 * wob2);
		float an = step(0.3, hk2) * (0.4 + 0.6 * hk2);
		add += mond * 0.2 * an * (0.55 + 0.45 * wob2) * smoothstep(hm, hm * 0.3, abs(qm + (hk - 0.5) * 0.2 + sin(TIME * 3.8 + s2 * 4.0) * 0.03));
		col += add * linie * night;
		col = mix(col, mond * 0.6, glint * 0.25 * night);   // Wellenlinien im Mondlicht
	}
	ALBEDO = col;
}
