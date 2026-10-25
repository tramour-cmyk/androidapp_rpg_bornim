// Grasbueschel und Korn (MultiMesh): gemalte Halme auf Durchsicht, wiegen im Wind, Toenung je Bueschel (INSTANCE_CUSTOM).
shader_type spatial;
render_mode cull_disabled, specular_disabled, shadows_disabled, depth_draw_never;   // eigene Schatten der Halme waren schwarze Flecken; ohne Tiefe keine Tusche am Gras
uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_disable;
uniform float cut_on = 0.0;
uniform vec3 cut_pos = vec3(0.0);
varying vec3 tint;
varying vec3 wpos;
void vertex() {
	tint = INSTANCE_CUSTOM.rgb;
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float h = clamp(1.0 - UV.y, 0.0, 1.0);
	float t = TIME * 1.7 + wpos.x * 0.6 + wpos.z * 0.45;
	vec3 d = vec3(sin(t) + 0.5 * sin(t * 2.3), 0.0, cos(t * 1.1) * 0.5) * 0.05 * h * h;
	VERTEX += (inverse(MODEL_MATRIX) * vec4(d, 0.0)).xyz;
	NORMAL = (inverse(MODEL_MATRIX) * vec4(0.0, 1.0, 0.0, 0.0)).xyz;   // Licht wie der Boden
}
void fragment() {
	vec4 c = texture(tex, UV);
	if (c.a < 0.5) discard;
	if (!FRONT_FACING) NORMAL = -NORMAL;   // Rueckseite wie Vorderseite beleuchten (Build 11: nachts halbe Bueschel schwarz)
	// grüner und etwas dunkler wie der Boden (wald_boden.gdshader, Prüfer Lauf 14)
	ALBEDO = c.rgb * tint * (0.82 + 0.18 * (1.0 - UV.y)) * vec3(0.64, 0.80, 0.62);
	ROUGHNESS = 1.0; SPECULAR = 0.0; METALLIC = 0.0;
}
void light() {
	float l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
	float b;
	if (LIGHT_IS_DIRECTIONAL) b = 0.55 + 0.45 * smoothstep(0.38, 0.5, l);
	else b = l;
	DIFFUSE_LIGHT += b * LIGHT_COLOR / PI;
}
