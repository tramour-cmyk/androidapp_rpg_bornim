// Fluss wie MapGround.kt/WaterLife.kt: graugruen am Rand, fast schwarz in der Tiefe, wandernde Lichtfunken.
shader_type spatial;
render_mode specular_disabled, unshaded;
uniform float night = 0.0;
varying vec3 wpos;
void vertex() { wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
float h21(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
	vec2 i = floor(p), f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1, 0)), f.x), mix(h21(i + vec2(0, 1)), h21(i + vec2(1, 1)), f.x), f.y);
}
void fragment() {
	vec2 p = wpos.xz;
	float flow = TIME * 0.45;
	float n = vnoise(vec2(p.x * 0.8 - flow, p.y * 2.2)) * 0.6 + vnoise(vec2(p.x * 2.5 - flow * 2.0, p.y * 6.0)) * 0.4;
	vec3 deep = vec3(0.055, 0.1, 0.118), rim = vec3(0.165, 0.227, 0.235);
	vec3 col = mix(deep, rim, n * 0.7);
	float glint = smoothstep(0.86, 0.95, vnoise(vec2(p.x * 3.0 - flow * 3.0, p.y * 9.0)));
	col += vec3(0.48, 0.56, 0.56) * glint * 0.55;
	col *= mix(1.0, 0.35, night);
	col += vec3(0.85, 0.89, 0.96) * glint * night * 0.25;
	ALBEDO = col;
}
