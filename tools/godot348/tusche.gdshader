// Tusche nach Licht: Kanten aus der Tiefe (Umriss und Knick), im Dunkeln kraeftiger, im Licht duenner.
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix, fog_disabled;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float px = 1.6;            // Linienbreite in Bildpunkten
uniform float knick = 0.06;        // Meter: Krümmung der Tiefe, ab der eine Linie entsteht
uniform vec3 ink : source_color = vec3(0.07, 0.05, 0.04);
void vertex() { POSITION = vec4(VERTEX.xy, 1.0, 1.0); }
float lz(vec2 uv, mat4 ip) {
	float d = texture(depth_tex, uv).r;
	vec4 v = ip * vec4(uv * 2.0 - 1.0, d, 1.0);
	return -v.z / v.w;
}
void fragment() {
	vec2 e = px / VIEWPORT_SIZE;
	float z = lz(SCREEN_UV, INV_PROJECTION_MATRIX);
	float zl = lz(SCREEN_UV - vec2(e.x, 0), INV_PROJECTION_MATRIX), zr = lz(SCREEN_UV + vec2(e.x, 0), INV_PROJECTION_MATRIX);
	float zd = lz(SCREEN_UV - vec2(0, e.y), INV_PROJECTION_MATRIX), zu = lz(SCREEN_UV + vec2(0, e.y), INV_PROJECTION_MATRIX);
	float lap = abs(zl + zr + zd + zu - 4.0 * z);
	float edge = smoothstep(knick, knick * 2.5, lap);
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float lum = dot(c, vec3(0.2126, 0.7152, 0.0722));
	ALBEDO = ink;
	ALPHA = edge * mix(1.0, 0.45, smoothstep(0.05, 0.6, lum));
}
