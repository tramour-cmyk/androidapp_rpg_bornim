// 348.7a: Tafeln der Zauber und Pfeile (tafel.gd). Ecke = (x, y in Bildpunkten, Tiefe in Metern); zur Kamera gedreht in
// dieser Tiefe, Figuren davor verdecken sie. Keine Ecke liegt hinter dem Boden unter ihr (Glut am Boden sinkt nicht ein).
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled;
uniform vec3 r0;   // Sicht: Strahl zum Bildpunkt (0, 0) in Tiefe 1
uniform vec3 rx;   // je Bildpunkt nach rechts
uniform vec3 ry;   // je Bildpunkt nach unten
uniform float boden = 0.08;   // so weit vor dem Boden (m)
uniform float soft_gamma = 1.8;

void vertex() {
	vec3 ray = r0 + VERTEX.x * rx + VERTEX.y * ry;
	float d = VERTEX.z;
	vec3 wr = mat3(INV_VIEW_MATRIX) * ray;
	float eye = INV_VIEW_MATRIX[3].y;
	if (wr.y < -0.0001) {
		d = min(d, eye / -wr.y - boden);
	}
	POSITION = PROJECTION_MATRIX * vec4(ray * max(d, 0.2), 1.0);
}

void fragment() {
	vec4 c = COLOR;
	if (UV2.x > 0.5) {
		float r = clamp(length(UV), 0.0, 1.0);
		c.a *= UV2.y < 0.0 ? 1.0 - r : (r < 0.5 ? mix(1.0, UV2.y, r * 2.0) : UV2.y * (2.0 - r * 2.0));
	}
	// Farben wie im Bild gemeint (sRGB), die Szene rechnet linear
	vec3 lo = c.rgb / 12.92;
	vec3 hi = pow((c.rgb + 0.055) / 1.055, vec3(2.4));
	ALBEDO = mix(hi, lo, step(c.rgb, vec3(0.04045)));
	// 348.7a Prüfer 1b (Heilung übernebelte den Kleriker, Segen 3–4-mal so hell wie alt): weiche Tafeln mischen im linearen Raum,
	// ihr dünner Rand deckte so wie im Bild weit mehr Deckkraft; über dunklem Grund gleicht a^soft_gamma das sRGB-Mischen aus
	ALPHA = UV2.x > 0.5 ? pow(c.a, soft_gamma) : c.a;
}
