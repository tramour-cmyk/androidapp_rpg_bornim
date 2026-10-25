// Grasbueschel und Korn (MultiMesh): gemalte Halme auf Durchsicht, wiegen im Wind, Toenung je Bueschel (INSTANCE_CUSTOM).
shader_type spatial;
render_mode cull_disabled, specular_disabled, depth_draw_never;   // ohne Tiefe keine Tusche am Gras; werfen keinen Schatten (gebiet.gd), empfangen ihn (Runde 11: Gras im Schatten blieb hell)
uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_disable;
uniform float cut_on = 0.0;
uniform vec3 cut_pos = vec3(0.0);
uniform vec4 inseln[64];           // 348.6: Lichtinseln wie boden.gdshader, sonst nachts schwarze Halme im hellen Boden
uniform int inseln_n = 0;
uniform float night = 0.0;
uniform float korn = 0.0;          // Runde 11: Kornfeld mit eigener Textur (tex.py korn)
uniform vec3 insel_farbe : source_color = vec3(1.0, 0.66, 0.3);
uniform float insel_kraft = 1.5;
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
	// Runde 11 (Urteil Chef 12:11: unten nur wenig dunkler): Korn unten im eigenen Schatten deutlich dunkel
	float fuss = korn > 0.5 ? 0.3 + 0.7 * smoothstep(0.05, 0.8, 1.0 - UV.y) : 0.82 + 0.18 * (1.0 - UV.y);
	ALBEDO = c.rgb * tint * fuss * mix(1.0, 0.45, night * korn);   // Runde 11 (Helfer: Korn nachts weiss wie Schnee)
	if (night > 0.0) {
		float k = 0.0;
		for (int i = 0; i < inseln_n; i++) {
			vec2 d = (wpos.xz - inseln[i].xy) / inseln[i].z;
			k += inseln[i].w * exp(-3.5 * dot(d, d));
		}
		EMISSION = (ALBEDO + vec3(0.05, 0.03, 0.008)) * insel_farbe * min(k, 1.6) * insel_kraft * night;
	}
	ROUGHNESS = 1.0; SPECULAR = 0.0; METALLIC = 0.0;
}
void light() {
	float l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
	float b;
	if (LIGHT_IS_DIRECTIONAL) b = 0.55 + 0.45 * smoothstep(0.38, 0.5, l);
	else b = l;
	DIFFUSE_LIGHT += b * LIGHT_COLOR / PI;
}
