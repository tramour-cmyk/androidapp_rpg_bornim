// Drei Lichtstufen (hell, halb, Schatten = nur Umgebung), Farbe aus den Eckfarben (Blender 'albedo', linear).
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform float glow = 0.0;          // Glas: nachts leuchtend
uniform vec3 glow_col : source_color = vec3(1.0, 0.72, 0.38);
varying vec3 wpos;
void vertex() { wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
float h21(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
// Pflaster (Alpha 0 in den Eckfarben): Steine in versetzten Reihen, 23 cm, Fugen dunkel, jeder Stein eigene Helligkeit
vec3 cobble(vec3 base, vec2 p) {
	vec2 q = p / 0.23;
	q.x += 0.5 * mod(floor(q.y), 2.0);
	vec2 id = floor(q); vec2 f = fract(q);
	vec2 d = min(f, 1.0 - f);
	float e = min(d.x * 1.4, d.y);
	float fw = fwidth(q.y) * 1.5;
	float joint = 1.0 - smoothstep(0.06, 0.06 + fw, e);
	float k = 0.78 + 0.4 * h21(id);
	return mix(base * k, base * 0.38, joint);
}
void fragment() {
	ALBEDO = COLOR.a < 0.5 ? cobble(COLOR.rgb, wpos.xz) : COLOR.rgb;
	ROUGHNESS = 1.0;
	EMISSION = glow_col * glow;
}
void light() {
	float ndl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float l = ndl * ATTENUATION;
	float b;
	if (LIGHT_IS_DIRECTIONAL) b = l > 0.45 ? 1.0 : (l > 0.08 ? 0.55 : 0.0);   // Sonne, Mond: drei Stufen
	else b = ndl * smoothstep(0.0, 1.0, ATTENUATION);                         // Lampen, Fackel: weicher Schein
	DIFFUSE_LIGHT += b * LIGHT_COLOR / PI;
}
