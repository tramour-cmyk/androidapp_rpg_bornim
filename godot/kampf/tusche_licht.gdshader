// Tusche nach Licht: Kanten aus der Tiefe (Umriss und Knick), im Schatten dick, im Licht duenner (Chef 25.10.: „Tusche dicke“).
// 348.13 (Chef 26.10., 11:20): nach der Lichtrichtung: Kanten, deren Aussenseite zur Sonne zeigt, duenn bis weg, abgewandte kraeftig
// (wie die Busch-Tusche in toon.gdshader); richtung = 0: alt, nur nach Helligkeit
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_mix, fog_disabled;
stencil_mode read, compare_equal, 0;   // nur, wo nichts markiert ist (main.gd: 1 Blueten, 2 Held mit eigener Flaeche)
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float px = 1.3;            // Linienbreite in Bildpunkten bei 540 Punkten Bildbreite, waechst mit der Aufloesung
uniform float dick = 1.25;         // Faktor im Schatten (Build 11: 1,5 zu dick am Helden)
uniform float duenn = 0.25;        // 348.13: Faktor auf der Lichtseite (0 = keine Linie)
uniform float richtung = 1.0;      // 348.13: 1 nach der Lichtrichtung, 0 alt (nur Helligkeit)
uniform vec3 licht_dir = vec3(0.0, 1.0, 0.0);   // zur Sonne, Welt (Licht.richtung, licht.gd)
uniform float umriss_licht = 1.0;  // 348.13: Umriss auf der Lichtseite deckend (0 = wie Lauf 100, blass wie die Knicke)
uniform float innen = 1.0;         // 348.13: Umriss nur auf der vorderen Flaeche (0 = beidseits der Kante wie d08456e7d)
uniform float breite_m = 3.4;      // 348.13: Bildbreite in Metern (Kamera.size)
uniform float zoomdick = 1.0;      // 348.13: 1 Schattenseite weiter weg duenner (Wurzel aus Nah/Bildbreite, hoechstens 0,6-fach), 0 wie 832ad3959
uniform float hinten_ab = 0.25;   // 348.13: Meter, ab denen die hintere Seite einer Stufe keine Tusche bekommt (Boden hinter dem Umriss)
uniform float umriss_dick = 1.0;   // 348.13a (Chef 27.10., 09:41): Schattenseite im Kampf kraeftiger; nur am Umriss, Knicke im Gesicht bleiben
uniform float sprung_max = 2.5;   // 348.13a: Meter; groessere Spruenge (Laubdach vor dem Boden) bekommen keine breite Linie
uniform float nah_bis = 19.0;     // 348.13a: Meter vor der Kamera; dahinter (Kronen am Waldrand) keine breite Linie (kampfort.gd: d0 + 5)
uniform float nah_ab = 8.0;       // 348.13a: Meter; davor (Rahmeneiche vorn links) keine breite Linie (kampfort.gd: d0 - 6)
uniform float fuss_bis = 0.3;     // 348.13a Runde 6 (Helfer 17:13: Stiefel fransen unten aus): darunter keine breite Linie
uniform float hoch_bis = 2.6;     // 348.13a: Meter ueber dem Boden; darueber (Kronen am Rand der Lichtung) keine breite Linie
uniform float knick = 0.06;        // Meter: Krümmung der Tiefe, ab der eine Linie entsteht
uniform vec3 ink : source_color = vec3(0.07, 0.05, 0.04);
uniform float dbg = 0.0;          // 348.13a Runde 9: Messlauf (probe.gd TUSCHE_TEIL)
void vertex() { POSITION = vec4(VERTEX.xy, 1.0, 1.0); }
float lz(vec2 uv, mat4 ip) {
	float d = texture(depth_tex, clamp(uv, vec2(0.0005), vec2(0.9995))).r;   // am Bildrand nicht ueber den Rand greifen
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	d = d * 2.0 - 1.0;   // OpenGL: Tiefe -1..1 (Rechnerbilder), Vulkan am Handy: 0..1
#endif
	vec4 v = ip * vec4(uv * 2.0 - 1.0, d, 1.0);
	return -v.z / v.w;
}
void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float lum = dot(c, vec3(0.2126, 0.7152, 0.0722));
	float hell = smoothstep(0.1, 0.6, lum);
	vec2 e1 = px * max(1.0, min(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y) / 540.0) / VIEWPORT_SIZE;
	float z = lz(SCREEN_UV, INV_PROJECTION_MATRIX);
	float f = mix(dick, 1.0, hell), a_licht = mix(1.0, 0.85, hell), breit = 0.0;
	if (richtung > 0.5) {
		// Aussenseite der Kante = Richtung, in der die Tiefe waechst (zum Hintergrund); Sonne auf den Bildschirm (UV: y nach unten)
		vec2 g = vec2(lz(SCREEN_UV + vec2(e1.x * dick, 0), INV_PROJECTION_MATRIX) - lz(SCREEN_UV - vec2(e1.x * dick, 0), INV_PROJECTION_MATRIX),
			lz(SCREEN_UV + vec2(0, e1.y * dick), INV_PROJECTION_MATRIX) - lz(SCREEN_UV - vec2(0, e1.y * dick), INV_PROJECTION_MATRIX));
		vec3 lv = (VIEW_MATRIX * vec4(licht_dir, 0.0)).xyz;
		// Helfer an Lauf 94 (blind nur knapp besser): Lichtseite kaum duenner, Held gar nicht; die Sonne steht hoch, lv.xy war kurz
		// (s hoechstens etwa 0,3), und dunkle Kleidung galt als tiefer Schatten: Sonne auf dem Bild normiert, Schattengrenze tiefer
		vec2 sl = vec2(lv.x, -lv.y);
		float s = length(sl) > 0.05 ? dot(g / max(length(g), 1e-4), normalize(sl)) : 0.0;
		// Held dreht morgens nicht mit (nachgestellt 26.10.): s stimmte, aber die Sperre 0,02 bis 0,1 hielt 94 bis 98 % der Kantenpunkte
		// zurueck; screen_tex ist dunkel (Sonne 0,02 bis 0,05, Schatten unter 0,015): Sperre 0,008 bis 0,02
		float ls = smoothstep(0.0, 0.6, s) * smoothstep(0.008, 0.02, lum);   // im tiefen Schatten keine Lichtseite
		// Helfer an Lauf 96 (blind schlechter als 94): Lichtseite als Luecke und Sprenkel (Bank, Pfosten, Kirchenkante); unter
		// einem Bildpunkt Abstand greift die Tiefe (filter_nearest) denselben Punkt, die Kante faellt aus: nicht unter 1 Bildpunkt
		// Helfer am Rechner in 1080 (zwei Runden blind, knapp vor 94 und 97): 1 echter Bildpunkt, nicht 1 Punkt bei 540 (in 1080 waren es 2)
		// Helfer 23:1x (blind, 22 Paare): Schattenseite in Grundansicht und weit zu dick, treppig, an Mantel und Schild doppelt;
		// nachgestellt (Magenta-Tusche): Schattenseite Grund 4,2 bis 4,7 Bildpunkte, nah 2,2 bis 2,4, obwohl der Held dort 2,6-mal
		// kleiner ist; die Verdoppelung unten aendert daran nichts (ausgeschaltet gleich), die Breite folgt px und dick. Darum dick mit
		// dem Zoom: nah voll, weiter weg Wurzel aus Nah/Bildbreite (hoechstens 0,6-fach), nie duenner als die Lichtseite
		float l1 = max(duenn, 1.05 / (px * max(1.0, min(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y) / 540.0)));
		float zs = mix(1.0, clamp(sqrt(3.4 / max(breite_m, 0.1)), 0.6, 1.0), zoomdick);
		f = mix(max(dick * zs, l1), l1, ls);
		// Helfer Runde 2 (21:00): weit herausgezoomt verliert der Held links und oben fast den Umriss, das Kirchdach verschwimmt mit dem
		// Pflaster; 1 Bildpunkt mit 0,45 Deckung ist auf hellem Grund kaum zu sehen: am Umriss (Tiefensprung ueber 0,4 m, Knick und
		// schraeger Boden bleiben auch weit unter 0,25 m) bleibt die Lichtseite duenn, aber deckend; Knicke im Licht weiter blass
		float umriss = smoothstep(0.4, 1.0, length(g)) * umriss_licht;
		a_licht = mix(1.0, mix(0.45, 0.85, umriss), ls);
		// Helfer Runde 3 (21:20): Schattenband steht vom Helden ab wie eine zweite Figur; nachgestellt: 60 bis 80 % der Tusche am Helden
		// lag aussen auf dem Boden, gezeichnet vom breiteren Durchgang der Welt; am Umriss nur auf der vorderen Flaeche, doppelt so tief
		// Helfer 22:1x: Heldenlinie wechselt die Seite nicht; nachgestellt (Magenta-Tusche, Breite je Bildpunkt): ls kippt richtig, aber
		// die Verdoppelung galt auch auf der Lichtseite (2 x 1 Bildpunkt), und tiefer als dick sieht g keinen Rand mehr: Lichtseite 2,1,
		// Schattenseite 2,4 Bildpunkte, kaum verschieden. Verdoppeln nur im Schatten, die Lichtseite bleibt 1 Bildpunkt
		f *= mix(1.0, 2.0, smoothstep(0.4, 1.0, length(g)) * innen * (1.0 - ls));
		// 348.13a: Helfer am Blatt (dick 1,4 und 1,8 auf alle Kanten): linke Gesichtshaelfte der Goblins schwarz, Hand am Griff Klumpen,
		// Streifen an den Beinen; kraeftiger darum nur am Umriss und nur im Schatten. Runde 2 (Faktor auf f, wo g den Rand sieht) wirkte
		// kaum (Goblins +18 % bei 3,0): g greift nur dick Bildpunkte weit, weiter innen sah der Punkt keinen Rand und blieb duenn.
		// Runde 3 (f auf die Zielbreite, wo im Umkreis Hintergrund liegt): +104 %, aber Helfer 16:59: Gesichtshaelften, Handklumpen,
		// Stiefelringe, rundum dick; der breite Abstand liess auch die Knicke greifen, und schmale Teile sahen beidseits Hintergrund.
		// Jetzt ohne Knicke: der Punkt wird direkt Tusche, wenn in einer der 8 Richtungen bis zur Zielbreite Hintergrund liegt
		// (mehr als 0,25 m tiefer) und diese Richtung von der Sonne weg zeigt; Knicke bleiben wie im Dorf
		// Runde 5 (Helfer 17:07: Goblins gefuellt, Helden rundum dick): an jeder Kante sah eine Schraegrichtung von der Sonne weg
		// auch Hintergrund, und duenne Teile (Beine, Arme, Klingen) sahen ihn beidseits. Jetzt zaehlt die Summe der Richtungen zum
		// Hintergrund (Aussenseite der Kante) gegen die Sonne, und wo gegenueberliegende Richtungen beide Hintergrund sehen, bleibt
		// das Teil bei der Dorflinie
		if (umriss_dick > 1.0) {
			vec2 r = e1 * max(dick * zs, l1) * 2.0 * umriss_dick;
			vec2 sn = length(sl) > 0.05 ? normalize(sl) : vec2(0.0);
			float sp[8];
			vec2 aussen = vec2(0.0);
			for (int i = 0; i < 8; i++) {
				vec2 d = vec2(cos(float(i) * 0.7853982), sin(float(i) * 0.7853982));
				float dz = lz(SCREEN_UV + d * r, INV_PROJECTION_MATRIX) - z;
				sp[i] = smoothstep(0.25, 0.4, dz) * (1.0 - smoothstep(sprung_max, sprung_max * 1.5, dz));
				aussen += d * sp[i];
				breit = max(breit, sp[i]);
			}
			float duenn_teil = 0.0;
			for (int i = 0; i < 4; i++) duenn_teil = max(duenn_teil, min(sp[i], sp[i + 4]));
			// seitliche Kanten (Sonne hoch, Skalarprodukt um 0,4) galten mit 0..0,6 nur halb als Lichtseite und blieben halb deckend
			float lw = length(aussen) > 1e-3 ? smoothstep(-0.1, 0.3, dot(aussen / length(aussen), sn)) * smoothstep(0.008, 0.02, lum) : 0.0;
			breit *= (1.0 - lw) * (1.0 - duenn_teil);
			// Runde 6 (Helfer 17:13: Goblin-Gesichter, -Arme, -Beine laufen zu): Abstand zur Kante t und Breite des Teils quer zur
			// Kante (beides in Zielbreiten); Teile unter 4 Zielbreiten bekommen nur ein Viertel ihrer Breite als Band
			if (breit > 0.0 && length(aussen) > 1e-3) {
				vec2 n = aussen / length(aussen);
				float t = 1.0, w = 5.0;
				for (int k = 4; k >= 1; k--) {
					float dz = lz(SCREEN_UV + n * r * float(k) * 0.25, INV_PROJECTION_MATRIX) - z;
					if (dz > 0.25 && dz < sprung_max * 1.5) t = float(k) * 0.25;
				}
				for (int k = 4; k >= 1; k--) {
					float dz = lz(SCREEN_UV - n * r * float(k), INV_PROJECTION_MATRIX) - z;
					if (dz > 0.25 && dz < sprung_max * 1.5) w = t + float(k);
				}
				breit *= 1.0 - smoothstep(0.0, 0.25, t - min(w * 0.25, 1.0));
			}
			float d0 = texture(depth_tex, SCREEN_UV).r;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
			d0 = d0 * 2.0 - 1.0;
#endif
			vec4 vp = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, d0, 1.0);
			float hy = (INV_VIEW_MATRIX * vec4(vp.xyz / vp.w, 1.0)).y;   // Hoehe ueber dem Boden der Lichtung (y = 0)
			breit *= innen * (1.0 - smoothstep(nah_bis, nah_bis + 2.0, z)) * smoothstep(nah_ab - 2.0, nah_ab, z) * (1.0 - smoothstep(hoch_bis, hoch_bis + 0.6, hy))
				* smoothstep(fuss_bis * 0.5, fuss_bis, hy);
		}
	}
	vec2 e = e1 * f;
	float zl = lz(SCREEN_UV - vec2(e.x, 0), INV_PROJECTION_MATRIX), zr = lz(SCREEN_UV + vec2(e.x, 0), INV_PROJECTION_MATRIX);
	float zd = lz(SCREEN_UV - vec2(0, e.y), INV_PROJECTION_MATRIX), zu = lz(SCREEN_UV + vec2(0, e.y), INV_PROJECTION_MATRIX);
	float lap = abs(zl + zr + zd + zu - 4.0 * z);
	float hinten = smoothstep(hinten_ab, hinten_ab * 1.6, z - min(min(zl, zr), min(zd, zu))) * innen * step(0.5, richtung);   // hinter der Kante: Boden
	float edge = smoothstep(knick, knick * 2.5, lap);
	// Runde 9 (Helfer an Runde 8: Langschwert „ganz schwarz“): nachgestellt, die Klinge ist von der Schneide her 1 Bildpunkt
	// breit, die Kante 2 bis 3 Bildpunkte, der Stahl verschwand. Liegt 2 echte Bildpunkte beidseits Hintergrund, ist das Teil
	// hoechstens 3 Bildpunkte schmal und bekommt keine Linie (der Boden daneben hat schon keine, hinten)
	vec2 p2 = 2.0 / VIEWPORT_SIZE;
	float sl_x = min(lz(SCREEN_UV - vec2(p2.x, 0), INV_PROJECTION_MATRIX), lz(SCREEN_UV + vec2(p2.x, 0), INV_PROJECTION_MATRIX)) - z;
	float sl_y = min(lz(SCREEN_UV - vec2(0, p2.y), INV_PROJECTION_MATRIX), lz(SCREEN_UV + vec2(0, p2.y), INV_PROJECTION_MATRIX)) - z;
	edge *= 1.0 - smoothstep(hinten_ab, hinten_ab * 1.6, max(sl_x, sl_y)) * innen * step(0.5, richtung);
	ALBEDO = ink;
	ALPHA = max(edge * a_licht * (1.0 - hinten), breit);
	if (dbg > 0.5) {   // 348.13a Runde 9 Messlauf: Farbe je Durchgang, hell = breites Band, halb = Kante; deckend ab 0,3
		ALBEDO = ink * (breit > 0.01 && breit >= edge * a_licht * (1.0 - hinten) ? 1.0 : 0.5);
		ALPHA = step(0.3, ALPHA);
	}
}
