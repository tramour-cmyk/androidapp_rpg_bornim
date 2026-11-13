// 505 Nebel des Krieges wie alt (WorldScreen.drawFog, Fog.kt): ueber das ganze Bild, je Bildpunkt die Lage in der Welt aus der Tiefe,
// daraus die Stelle in der Nebelkarte (nebel.gd: je Kachel 4 x 4 Teile, 1 nie gesehen, GESEHEN gesehen, 0 in Sicht); Farbe 0x080A12,
// gedaempft mit 92 % Deckung, schwarz voll.
// 505c (Chef 04.11., 14:06, Zu 505 (Rand)): jenseits des Kartenrands kein Nebel (klingt in rand_nebel aus), dafuer laeuft der
// Randwald nach aussen ins Dunkel wie alt (MapEdge.fade, 27m): rand_hell Meter hell, bis rand_schwarz schwarz, weich; gilt fuer
// alles, was dort steht (Boden, Baeume, Fels), weil es nach der Lage jedes Bildpunkts geht. Der Gang aus der Hoehle bleibt hell.
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, blend_mix, fog_disabled, shadows_disabled;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform sampler2D nebel : filter_linear, repeat_disable;
uniform vec2 groesse = vec2(1.0);   // Karte in Metern (Breite, Hoehe)
uniform vec2 teile = vec2(1.0);     // Karte in Kacheln (Breite, Hoehe)
uniform float rand_hoechstens = 0.0; // jenseits des Rands hoechstens so dunkel (Vergleich alt: 0,5)
uniform float rand_nebel = 1.16;     // in so vielen Metern hinter dem Rand klingt der Nebel aus
uniform float rand_hell = 2.32;      // so weit hinter dem Rand bleibt das Licht
uniform float rand_schwarz = 1.0e6;  // ab hier schwarz (ohne Rand: weit weg)
uniform float hoehle = 0.0;
uniform vec4 licht_gang = vec4(0.0); // Hoehle: Mitte x, Rand z, halbe Breite, an (1)
// 505 Lauf 2 (Pruefer 16:01: „nie gesehen“ blaugrau 23,23,34, in der Hoehle 27,29,51): das Bild laeuft nach dem Nebel durch die
// Anpassung der Umgebung (licht.gd: Kontrast 0,87 am Tag hebt Schwarz auf etwa 14, Hoehle Helligkeit x2,1); 0x080A12 wurde so
// blaugrau. Schwarz wird dort zum dunkelsten Ton des Spiels (wie Tusche und Randdunkel, 14,14,14), in der Hoehle zu 0
uniform vec3 farbe : source_color = vec3(0.0);
uniform float ohne = 0.0;            // 555 Testmenue „Sichtlinie aus“: kein Nebel auf der Karte, der Rand bleibt
void vertex() { POSITION = vec4(VERTEX.xy, 1.0, 1.0); }
void fragment() {
	float d = texture(depth_tex, SCREEN_UV).r;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	d = d * 2.0 - 1.0;
#endif
	vec4 v = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, d, 1.0);
	vec3 w = (INV_VIEW_MATRIX * vec4(v.xyz / v.w, 1.0)).xyz;
	vec2 uv = w.xz / groesse;
	// Prüfer Lauf 2: die Kanten folgten den Feldern als Zickzack (gesehen/nie gesehen je Kachel); 3 x 3 Abgriffe im Abstand einer
	// halben Kachel (Zelt 1-2-1) runden die Ecken, so laufen die Kanten wie in drawFog weich und schräg
	vec2 st = 0.5 / max(teile, vec2(1.0));
	vec2 c = clamp(uv, vec2(0.0), vec2(1.0));
	float a = 0.0;
	for (int j = -1; j <= 1; j++) {
		for (int i = -1; i <= 1; i++) {
			float wgt = (i == 0 ? 2.0 : 1.0) * (j == 0 ? 2.0 : 1.0);
			a += wgt * texture(nebel, clamp(c + vec2(float(i), float(j)) * st, vec2(0.0), vec2(1.0))).r;
		}
	}
	a /= 16.0;
	// Meter hinter dem Kartenrand (0 auf der Karte)
	float aus = max(max(-w.x, w.x - groesse.x), max(-w.z, w.z - groesse.y));
	aus = max(aus, 0.0);
	if (aus > 0.0) a = mix(a, min(a, rand_hoechstens), smoothstep(0.0, rand_nebel, aus));
	a = a * (a > 0.95 ? 1.0 : 0.92);
	a *= 1.0 - ohne;
	// Randwald ins Dunkel (MapEdge.fade: Licht u * u * (3 - 2u)); in der Hoehle bleibt der Gang zum Ausgang hell
	float licht = 1.0 - smoothstep(rand_hell, rand_schwarz, aus);
	if (hoehle > 0.5) {
		licht = 1.0 - smoothstep(0.0, rand_hell, aus);
		if (licht_gang.w > 0.5 && w.z > licht_gang.y && abs(w.x - licht_gang.x) < licht_gang.z + 0.3) licht = 1.0;
	}
	a = max(a, 1.0 - licht);
	ALBEDO = farbe * licht;
	ALPHA = a;
}
