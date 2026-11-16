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
uniform float insel_kraft = 0.6;   // 348.9 nachts wie alt
// 1022 (Chef 12.11., 08:26; 20:07 „sanfter Übergang und dann dunkel“; alt MapEdge.fade, 27m „super“): hinter dem Kartenrand laeuft
// alles weich ins Schwarz, Boden, Wasser, Halme und alles darauf gleich (gebiet.gd rand_karte). Gemessen im Bild, nicht am Boden: alt war
// der Boden im Bild unverkuerzt (eine Kachel tief = eine Kachel hoch), bei 30 Grad Blick ist eine Kachel in Blickrichtung nur halb so
// hoch; 3,4 Bodenkacheln Verlauf waren am Gerät 1,6 Kacheln Bildhoehe (Build 280, Bilder 17:59: harte Kante). Darum zaehlt der Abstand
// hinter dem Rand so, wie er im Bild erscheint (quer zum Blick voll, laengs halb), hell bis RAND_HELL, schwarz nach RAND_WEICH mehr;
// Bildbreite 7,8 Kacheln (kamera.gd FERN)
const float RAND_HELL = 1.5;    // Kacheln im Bild hinter dem Rand voll hell (alt 2 von 6,75 Bildbreite)
const float RAND_WEICH = 4.0;   // Kacheln im Bild bis schwarz (alt 3,4); in Blickrichtung 11 Bodenkacheln, Boden und Wasser reichen 12 (dorf.py AUS)
uniform vec3 rand_karte = vec3(0.0);   // Breite, Hoehe der Karte in Metern, an (1); aus: ueberall hell (Held, Leute, Kampfort)
float rand_licht(vec3 w, mat4 iv) {
	if (rand_karte.z < 0.5) return 1.0;
	float ox = max(max(-w.x, w.x - rand_karte.x), 0.0) * length(vec2(iv[0].x, iv[1].x));   // Weltachse x im Bild (rechts, oben)
	float oz = max(max(-w.z, w.z - rand_karte.y), 0.0) * length(vec2(iv[0].z, iv[1].z));   // Ecke rund (mit max hell als Keil)
	float u = clamp(1.0 - (length(vec2(ox, oz)) / 1.16 - RAND_HELL) / RAND_WEICH, 0.0, 1.0);
	// alt nahm den Bildpunkt (sRGB) mal f; hier ist die Farbe linear, mal f sah bis kurz vor schwarz fast hell aus und fiel dann ab
	return pow(u * u * (3.0 - 2.0 * u), 2.2);
}
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
	float rl = rand_licht(wpos, INV_VIEW_MATRIX);   // 1022: Halme hinter dem Rand schimmerten hell im Dunkel (Bilder 17:59)
	ALBEDO *= rl; EMISSION *= rl;
	ROUGHNESS = 1.0; SPECULAR = 0.0; METALLIC = 0.0;
}
void light() {
	float l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
	float b;
	if (LIGHT_IS_DIRECTIONAL) b = 0.55 + 0.45 * smoothstep(0.38, 0.5, l);
	else b = l;
	DIFFUSE_LIGHT += b * LIGHT_COLOR / PI;
}
