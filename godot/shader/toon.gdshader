// Drei Lichtstufen (hell, halb, Schatten = nur Umgebung); Farbe = gemalte Textur (tex.py) mal Toenung aus den Eckfarben.
shader_type spatial;
render_mode cull_disabled, specular_disabled;
uniform sampler2D tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float glow = 0.0;
uniform float fill = 0.0;          // Held: Mindesthelligkeit im Schatten
uniform float sway = 0.0;          // Laub: im Wind wiegen
uniform float cut_on = 0.0;        // 1 Nahstufe: Hohes vor dem Helden wegschneiden, Boden bleibt; 2 Fern: nur Laub, weich
uniform vec3 cut_pos = vec3(0.0);
uniform vec3 glow_col : source_color = vec3(1.0, 0.72, 0.38);          // Glas: nachts leuchtend
varying vec3 wpos;
void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	if (sway > 0.0) {
		float h = clamp((wpos.y - 1.6) / 2.5, 0.0, 1.0);
		float t = TIME * 1.3 + wpos.x * 0.35 + wpos.z * 0.27;
		vec3 d = vec3(sin(t) + 0.4 * sin(t * 2.7), 0.0, cos(t * 0.8) * 0.6) * 0.045 * h * sway;
		VERTEX += (inverse(MODEL_MATRIX) * vec4(d, 0.0)).xyz;
	}
}
void fragment() {
	if (cut_on > 0.5 && wpos.y > 1.3) {           // nur Hohes zwischen Kamera und Held (Saeule um die Blickachse); Baenke, Theken bleiben
		vec3 d = wpos - cut_pos;
		float along = dot(d, CAMERA_DIRECTION_WORLD);
		float side = length(d - CAMERA_DIRECTION_WORLD * along);
		if (along > 0.6 && side < 1.5) discard;   // CAMERA_DIRECTION_WORLD zeigt zur Kamera (nachgestellt 25.10.)
	}
	if (cut_on > 1.5 && sway > 0.5 && wpos.y > 1.3) {   // Fern: weiches Loch nur im Laub vor dem Helden (wie 353a im alten Spiel), Staemme bleiben
		vec3 d = wpos - cut_pos;
		float along = dot(d, CAMERA_DIRECTION_WORLD);
		float side = length(d - CAMERA_DIRECTION_WORLD * along);
		float h = fract(sin(dot(floor(FRAGCOORD.xy), vec2(12.9898, 78.233))) * 43758.5453);
		if (along > 0.6 && smoothstep(1.0, 1.7, side) < h) discard;
	}
	ALBEDO = texture(tex, UV).rgb * COLOR.rgb;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;      // kein Glanz aus der Umgebung (sonst Plastik)
	METALLIC = 0.0;
	EMISSION = glow_col * glow;
}
void light() {
	float ndl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float l = ndl * ATTENUATION;
	float b;
	if (LIGHT_IS_DIRECTIONAL) b = smoothstep(0.38, 0.5, l) * 0.45 + smoothstep(0.04, 0.12, l) * 0.55;   // Sonne, Mond: drei Stufen, weiche Kante
	else b = ndl * smoothstep(0.0, 1.0, ATTENUATION);                                                     // Lampen, Fackel: weicher Schein
	if (LIGHT_IS_DIRECTIONAL) b = max(b, fill);
	DIFFUSE_LIGHT += b * LIGHT_COLOR / PI;
}
