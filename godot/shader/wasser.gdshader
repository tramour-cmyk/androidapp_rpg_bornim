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
	vec3 col = mix(rim, deep, clamp((w - 0.5) * 3.2 + (n - 0.5) * 0.25, 0.0, 1.0));
	// alt: duenne Streifen (|sin| > 0,985 und Rauschen), 45 % zum Glanz; hier wandernd
	float s = abs(sin(p.y * 6.0 + vnoise(vec2(p.x * 1.4 - flow, p.y * 1.4)) * 6.0));
	float glint = smoothstep(0.975, 0.995, s) * step(0.55, vnoise(vec2(p.x * 1.1 - flow * 1.5, p.y * 1.1)));
	col = mix(col, glint_c, glint * 0.45);
	col *= mix(1.0, 0.35, night);
	col += vec3(0.6, 0.65, 0.72) * glint * night * 0.12;
	ALBEDO = col;
}
