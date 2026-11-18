// 1613 (Chef 02.11., 11:28: „cool, wenn man da irgendwie noch eine Art Effekt draufkriegen“): Schein der Waffen episch und höher,
// als zweiter Durchgang über dem Toon-Material der Waffe (Staffel.glanz). Rand gegen das Licht der Kamera (Fresnel), dazu ein heller
// Streifen, der langsam vom Griff zur Spitze läuft, und ein schwacher Grundschein; atmet. Additiv, ohne Schatten, liest weder Tiefe noch Bild.
shader_type spatial;
render_mode blend_add, unshaded, depth_draw_never, cull_back, shadows_disabled;

uniform vec3 farbe = vec3(0.95, 0.62, 0.31);
uniform float kraft = 1.0;
uniform float laenge = 1.0;      // Abstand Griff -> Spitze (m), für den Streifen
uniform float streifen = 1.0;    // 0 = nur Rand

varying float v_weg;

void vertex() {
	v_weg = length(VERTEX) / max(laenge, 0.05);   // Griff im Ursprung (waffen_staffel.py)
}

void fragment() {
	float rand = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.2);
	float atem = 0.7 + 0.3 * sin(TIME * 2.1);
	float lauf = fract(TIME * 0.5);
	float band = streifen * (1.0 - smoothstep(0.0, 0.14, abs(v_weg - lauf * 1.3 + 0.15))) * smoothstep(0.15, 0.3, v_weg);
	ALBEDO = farbe * kraft * (0.3 * atem + rand * 0.9 * atem + band * 0.9);   // Grundschein, damit auch die flache Klinge leuchtet
}
