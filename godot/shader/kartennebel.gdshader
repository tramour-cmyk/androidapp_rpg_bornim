// 505 Nebel auf der Karte im Menü (62c, MapInk.render): vom Wald zeigt das Blatt nur, was der Held gesehen hat, der Rest bleibt
// leeres Pergament, die Kante dazwischen ausgefranst. Wie MapInk: je Bildpunkt die Kachel (u, v), „bekannt“ weich zwischen den
// Kachelmitten (smoothstep), dazu das Rauschen der Kante (karte-<id>-rand.bild, Zelle 3); k = ((bekannt − 0,5 + (Rauschen − 0,5)·0,5)·4 + 0,5)
// mischt das ganz bekannte Blatt (TEXTURE) mit dem leeren.
shader_type canvas_item;
uniform sampler2D leer : filter_linear;
uniform sampler2D rand : filter_linear;
uniform sampler2D bekannt : filter_nearest;   // je Kachel 1 gesehen (nebel.gd erkundet), sonst 0
uniform vec2 kacheln = vec2(1.0);             // Karte in Kacheln
uniform float kachel = 8.0;                   // MapSheet.C
uniform float rahmen = 10.0;                  // MapSheet.PAD

float kenne(int x, int y) {
	if (x < 0 || y < 0 || x >= int(kacheln.x) || y >= int(kacheln.y)) return 0.0;
	return texelFetch(bekannt, ivec2(x, y), 0).r > 0.5 ? 1.0 : 0.0;
}

void fragment() {
	vec2 einheit = kacheln * kachel + 2.0 * rahmen;      // Blatt in Einheiten (ein Drittel der Bildpunkte)
	vec2 m = UV * einheit;
	vec2 uv = (m - rahmen) / kachel;
	float k = 0.0;
	if (uv.x >= 0.0 && uv.y >= 0.0 && uv.x < kacheln.x && uv.y < kacheln.y) {
		vec2 f = uv - 0.5;
		vec2 i = floor(f);
		vec2 a = f - i;
		a = a * a * (3.0 - 2.0 * a);
		int ix = int(i.x); int iy = int(i.y);
		float kf = mix(mix(kenne(ix, iy), kenne(ix + 1, iy), a.x), mix(kenne(ix, iy + 1), kenne(ix + 1, iy + 1), a.x), a.y);
		float n = texture(rand, UV).r;
		k = clamp((kf - 0.5 + (n - 0.5) * 0.5) * 4.0 + 0.5, 0.0, 1.0);
	}
	COLOR = mix(texture(leer, UV), texture(TEXTURE, UV), k);
}
