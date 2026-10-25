// Tusche nach Licht: Kanten aus der Tiefe (Umriss und Knick), im Schatten dick, im Licht duenner (Chef 25.10.: „Tusche dicke“).
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix, fog_disabled;
stencil_mode read, compare_equal, 0;   // nur, wo nichts markiert ist (main.gd: 1 Blueten, 2 Held mit eigener Flaeche)
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float px = 1.3;            // Linienbreite in Bildpunkten bei 540 Punkten Bildbreite, waechst mit der Aufloesung
uniform float dick = 1.25;         // Faktor im Schatten (Build 11: 1,5 zu dick am Helden)
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
	vec2 e = px * mix(dick, 1.0, hell) * max(1.0, min(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y) / 540.0) / VIEWPORT_SIZE;
	float z = lz(SCREEN_UV, INV_PROJECTION_MATRIX);
	float zl = lz(SCREEN_UV - vec2(e.x, 0), INV_PROJECTION_MATRIX), zr = lz(SCREEN_UV + vec2(e.x, 0), INV_PROJECTION_MATRIX);
	float zd = lz(SCREEN_UV - vec2(0, e.y), INV_PROJECTION_MATRIX), zu = lz(SCREEN_UV + vec2(0, e.y), INV_PROJECTION_MATRIX);
	float lap = abs(zl + zr + zd + zu - 4.0 * z);
	float edge = smoothstep(knick, knick * 2.5, lap);
	ALBEDO = ink;
	ALPHA = edge * mix(1.0, 0.85, hell);
}
