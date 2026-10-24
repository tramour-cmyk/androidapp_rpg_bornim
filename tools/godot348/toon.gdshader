// Drei Lichtstufen (hell, halb, Schatten = nur Umgebung), Farbe aus den Eckfarben (Blender 'albedo', linear).
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform float glow = 0.0;          // Glas: nachts leuchtend
uniform vec3 glow_col : source_color = vec3(1.0, 0.72, 0.38);
void fragment() {
	ALBEDO = COLOR.rgb;
	ROUGHNESS = 1.0;
	EMISSION = glow_col * glow;
}
void light() {
	float ndl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float l = ndl * ATTENUATION;
	float b = l > 0.45 ? 1.0 : (l > 0.08 ? 0.55 : 0.0);
	if (!LIGHT_IS_DIRECTIONAL) b *= smoothstep(0.0, 0.08, l);   // Lampen laufen weich aus, sonst harte Kreise
	DIFFUSE_LIGHT += b * LIGHT_COLOR / PI;
}
