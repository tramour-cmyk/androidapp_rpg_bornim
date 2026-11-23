// 1155: was unser Wasser (wasser.gdshader) kann und das Wasser des Kits (R10 „Teich klar“, lake.gdshader) nicht: Rand der Karte
// weich ins Schwarz (1022), nachts die Lichtinseln der Laternen und Fenster und die Mondspur als Glitzern (348.6 Runde 2c–11).
// gebiet.gd kit_wasser haengt diese Datei in den Shader des Kits und ruft am Ende von fragment() kit_rand und kit_nacht.
uniform float night = 0.0;
uniform sampler2D maske : filter_linear, repeat_disable;
uniform vec2 karte = vec2(41.76, 37.12);
uniform float rand_m = 0.0;
uniform vec4 inseln[64];
uniform int inseln_n = 0;
uniform vec3 insel_farbe : source_color = vec3(1.0, 0.66, 0.3);
uniform vec3 mond : source_color = vec3(0.847, 0.894, 0.957);
uniform vec3 rand_karte = vec3(0.0);
uniform float kit_selbst = 0.0;   // 1155 Hoehle: so viel leuchtet das Wasser selbst (unser Teich war unbeleuchtet; die Hoehle hat kaum Licht)
// 1566 (Chef 17.11., 14:50 „Warum sehe ich da das Wasser durch, obwohl das ja nicht in meiner Sichtlinie ist?“; Messlauf 22.11., 21:05
// unter Mobile: der Teich funkelt unter dem Nebel, auch rot gefärbt und mit Wasser vor dem Nebel sortiert): in der Höhle liest das Wasser
// die Nebelkarte (nebel.gd) selbst und wird, wo sie schwarz ist (nie gesehen, gesehen außer Sicht), schwarz und ohne Glanz
uniform sampler2D kit_nebel : filter_linear, repeat_disable;
uniform vec2 kit_nebel_groesse = vec2(0.0);   // Karte in Metern; 0: aus (draußen, Testmenü „Sichtlinie aus“)
const float KIT_RAND_HELL = 1.5;
const float KIT_RAND_WEICH = 4.0;

float kit_rand(vec3 w, mat4 iv) {
	if (rand_karte.z < 0.5) return 1.0;
	float ox = max(max(-w.x, w.x - rand_karte.x), 0.0) * length(vec2(iv[0].x, iv[1].x));
	float oz = max(max(-w.z, w.z - rand_karte.y), 0.0) * length(vec2(iv[0].z, iv[1].z));
	float u = clamp(1.0 - (length(vec2(ox, oz)) / 1.16 - KIT_RAND_HELL) / KIT_RAND_WEICH, 0.0, 1.0);
	return pow(u * u * (3.0 - 2.0 * u), 2.2);
}

float kit_sicht(vec3 w) {
	if (kit_nebel_groesse.x <= 0.0) return 1.0;
	return 1.0 - texture(kit_nebel, clamp(w.xz / kit_nebel_groesse, vec2(0.0), vec2(1.0))).r;
}

float kit_h21(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float kit_vnoise(vec2 p) {
	vec2 i = floor(p), f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(kit_h21(i), kit_h21(i + vec2(1, 0)), f.x), mix(kit_h21(i + vec2(0, 1)), kit_h21(i + vec2(1, 1)), f.x), f.y);
}

// das Licht auf dem Wasser bei Nacht, wie wasser.gdshader (dort ALBEDO, hier EMISSION dazu)
vec3 kit_nacht(vec3 wp, mat4 iv, float t) {
	if (night <= 0.0) return vec3(0.0);
	vec2 p = wp.xz;
	float w = texture(maske, (p + rand_m) / (karte + 2.0 * rand_m)).a;
	vec2 tv = normalize(iv[2].xz);
	vec2 qv = vec2(-tv.y, tv.x);
	vec2 g = vec2(dot(p, qv) * 18.0, dot(p, tv) * 28.0 - t * 2.4);
	float funkeln = smoothstep(0.7, 0.9, kit_vnoise(g)) * (0.6 + 0.4 * kit_vnoise(g * 0.37 + t * 0.7));
	vec3 add = vec3(0.0);
	for (int i = 0; i < inseln_n; i++) {
		vec2 d = p - inseln[i].xy;
		float s_ = dot(d, tv), q = dot(d, qv), r = inseln[i].z * 0.9;
		if (s_ < 0.3 || s_ > r || abs(q) > 0.5) continue;
		float fade = 1.0 - s_ / r;
		add += insel_farbe * 0.8 * inseln[i].w * fade * smoothstep(0.3 + 0.12 * fade, 0.0, abs(q));
	}
	float qm = dot(p - iv[3].xz, qv) - 1.6 + sin(dot(p, tv) * 1.3 + t * 0.5) * 0.06 + (kit_vnoise(vec2(dot(p, tv) * 4.0, t)) - 0.5) * 0.08;
	float spur = smoothstep(0.42, 0.0, abs(qm)); spur *= spur;
	float ufer = smoothstep(0.5, 1.1, w);
	return add * funkeln * smoothstep(0.52, 0.7, w) * night + mond * 0.22 * spur * (0.12 + 0.88 * funkeln) * ufer * night;
}
