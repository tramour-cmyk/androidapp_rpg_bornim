// 505 Nebel des Krieges wie alt (WorldScreen.drawFog, Fog.kt): ueber das ganze Bild, je Bildpunkt die Lage in der Welt aus der Tiefe,
// daraus die Stelle in der Nebelkarte (nebel.gd: je Kachel 4 x 4 Teile, 1 nie gesehen, 0,5 gesehen, 0 in Sicht); Farbe 0x080A12,
// gedaempft mit 92 % Deckung, schwarz voll. Jenseits des Kartenrands so bekannt wie der Rand, nie dunkler als gesehen (MapEdge, t732).
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, blend_mix, fog_disabled, shadows_disabled;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform sampler2D nebel : filter_linear, repeat_disable;
uniform vec2 groesse = vec2(1.0);   // Karte in Metern (Breite, Hoehe)
uniform float rand_hoechstens = 0.5; // jenseits des Rands hoechstens so dunkel (Hoehle: 1)
uniform vec3 farbe : source_color = vec3(0.031, 0.039, 0.071);
void vertex() { POSITION = vec4(VERTEX.xy, 1.0, 1.0); }
void fragment() {
	float d = texture(depth_tex, SCREEN_UV).r;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	d = d * 2.0 - 1.0;
#endif
	vec4 v = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, d, 1.0);
	vec3 w = (INV_VIEW_MATRIX * vec4(v.xyz / v.w, 1.0)).xyz;
	vec2 uv = w.xz / groesse;
	float a = texture(nebel, clamp(uv, vec2(0.0), vec2(1.0))).r;
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) a = min(a, rand_hoechstens);
	ALBEDO = farbe;
	ALPHA = a * (a > 0.95 ? 1.0 : 0.92);
}
