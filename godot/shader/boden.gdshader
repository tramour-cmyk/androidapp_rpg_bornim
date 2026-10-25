// Boden wie MapGround.kt: Gras, Erde (Wege, Hoefe, kahle Stellen), Pflaster nach der Maske (16 px je Kachel),
// Feinheit aus gemalten Texturen in Weltgroesse; zwei versetzte Gras-Lagen gegen sichtbare Wiederholung.
shader_type spatial;
render_mode specular_disabled;
uniform sampler2D maske : filter_linear, repeat_disable;
uniform sampler2D gras : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D erde : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D pflaster : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec2 karte = vec2(41.76, 37.12);   // Kartengroesse in Metern
// 348.6 (Befund 2): Lichtinseln nachts wie MapLight.add (Laterne Reichweite 2,6 Kacheln, Fenster 1,6; Abfall steiler als exp(-2 (d/r)^2), am Rechner gegen alt gemessen);
// hier statt Lampen, weil der Mobile-Renderer je Netz nur 8 Lampen nimmt (Kirchenlaternen blieben dunkel). x, z, Reichweite, Staerke
uniform vec4 inseln[64];
uniform int inseln_n = 0;
uniform float night = 0.0;
uniform vec3 insel_farbe : source_color = vec3(1.0, 0.82, 0.58);
uniform float insel_kraft = 2.0;
varying vec3 wpos;
void vertex() { wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
float h21(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
	vec2 i = floor(p), f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1, 0)), f.x), mix(h21(i + vec2(0, 1)), h21(i + vec2(1, 1)), f.x), f.y);
}
void fragment() {
	vec4 m = texture(maske, wpos.xz / karte);
	vec2 p = wpos.xz;
	float nz = vnoise(p * 0.35) * 0.65 + vnoise(p * 1.1) * 0.35;
	vec3 g = mix(texture(gras, p / 2.32).rgb, texture(gras, vec2(p.y, -p.x) / 3.07 + 0.37).rgb, smoothstep(0.35, 0.65, nz));
	g *= 0.9 + 0.2 * vnoise(p * 0.18);
	vec3 e = texture(erde, p / 2.32 + 0.11).rgb;
	vec3 c = texture(pflaster, p / 1.16).rgb;
	float el = dot(e, vec3(0.33));
	float earth = smoothstep(0.42, 0.62, m.r + (el - 0.38) * 0.6 + (nz - 0.5) * 0.12);
	float verge = smoothstep(0.08, 0.4, m.r) * (1.0 - earth);                   // plattgetretener Rand am Weg
	vec3 col = mix(g * (1.0 - 0.22 * verge) + vec3(0.03, 0.02, 0.0) * verge, e, earth);
	float cl = dot(c, vec3(0.33));
	float cob = smoothstep(0.42, 0.58, m.g + (cl - 0.3) * 0.5);
	col = mix(col, c, cob);
	col *= 1.0 - m.b * 0.42;
	ALBEDO = col;
	if (night > 0.0) {
		float k = 0.0;
		for (int i = 0; i < inseln_n; i++) {
			vec2 d = (wpos.xz - inseln[i].xy) / inseln[i].z;
			k += inseln[i].w * exp(-3.5 * dot(d, d));
		}
		EMISSION = col * insel_farbe * min(k, 1.6) * insel_kraft * night;
	}
	ROUGHNESS = 1.0; SPECULAR = 0.0; METALLIC = 0.0;
}
void light() {
	float ndl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float l = ndl * ATTENUATION;
	float b;
	if (LIGHT_IS_DIRECTIONAL) b = smoothstep(0.38, 0.5, l) * 0.45 + smoothstep(0.04, 0.12, l) * 0.55;
	else b = ndl * smoothstep(0.0, 1.0, ATTENUATION);
	DIFFUSE_LIGHT += b * LIGHT_COLOR / PI;
}
