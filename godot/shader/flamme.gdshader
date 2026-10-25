// 348.6 Runde 5 (Helfer Runde 3: Flamme „wie Papier“, mattes Dreieck, schwarze Kontur, flackert nicht): Flamme leuchtet
// additiv, steht nicht in der Tiefe (keine Tuschekante) und markiert sich mit Schablone 1 (keine Linie darueber, wie Blueten).
// Kegel (glanz 0): zuengelt nach oben, unten orange, Kern hell, oben und am Rand durchsichtig; Schein (glanz 1): Billboard.
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;
stencil_mode write, compare_always, 1;
uniform float glanz = 0.0;
uniform float kraft = 1.0;
uniform float hoehe = 0.22;          // Kegelhoehe (CylinderMesh, Mitte im Ursprung)
uniform float saat = 0.0;
uniform vec3 aussen : source_color = vec3(1.0, 0.38, 0.06);
uniform vec3 innen : source_color = vec3(1.0, 0.86, 0.48);
varying float h;
void vertex() {
	if (glanz > 0.5) {
		// Billboard: Flaeche zur Kamera, Groesse aus der Modellmatrix
		float s = length(MODEL_MATRIX[0].xyz);
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
		VERTEX *= s;
		MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	} else {
		h = clamp(VERTEX.y / hoehe + 0.5, 0.0, 1.0);
		float t = TIME * 9.0 + saat;
		// Zuengeln: oben stark, unten ruhig; zwei Wellen gegeneinander
		VERTEX.x += h * h * 0.025 * (sin(t + h * 7.0) + 0.6 * sin(t * 1.7 - h * 11.0));
		VERTEX.z += h * h * 0.02 * sin(t * 1.3 + h * 5.0 + 1.7);
		VERTEX.y *= 1.0 + 0.18 * sin(t * 1.9) * sin(t * 0.7);
		// Rand wellig: drei Lappen wandern um die Flamme, oben am staerksten
		float ang = atan(VERTEX.z, VERTEX.x);
		VERTEX.xz *= 1.0 + 0.35 * h * sin(3.0 * ang + t * 1.4);
	}
}
void fragment() {
	if (glanz > 0.5) {
		float r = length(UV - 0.5) * 2.0;
		float a = pow(max(0.0, 1.0 - r), 2.2);
		ALBEDO = aussen * a * 0.55 * kraft;
	} else {
		float rand = pow(abs(dot(normalize(NORMAL), normalize(VIEW))), 0.8);
		float oben = 1.0 - smoothstep(0.45, 1.0, h);
		vec3 c = mix(aussen, innen, rand * (1.0 - h * 0.6));
		ALBEDO = c * (0.35 + 1.1 * rand) * oben * kraft;
	}
}
