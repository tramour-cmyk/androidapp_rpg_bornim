extends SceneTree
# 1215: worauf ragdoll.gd sich beim Gelenk des Physikservers (6 Freiheitsgrade, Jolt) verlässt, gemessen statt angenommen:
#   Vorzeichen: mit Grenzen [unten, oben] dreht das Kind um +x des Gelenkrahmens zwischen −oben und −unten (ragdoll.gd gibt
#   darum −hinten/−vorn weiter; falsch herum knickten die Knie nach vorn)
#   Lage fest: das Kind bleibt am Gelenk (Abstand)
#   Spannung: ein Motor mit Zielgeschwindigkeit 0 und begrenztem Moment bremst wie Reibung (damit erschlafft der Körper allmählich)
# Ohne Modelle, ohne Bild, Sekunden. Aufruf: im Ordner godot mit -s res://tests/gelenk_1215.gd   (Exit 0 = gut)

var fehler := 0


func _initialize() -> void:
	_run.call_deferred()


func _pruef(name: String, gut: bool, wert: String) -> void:
	print("GELENK1215 %s: %s (%s)" % [name, "gut" if gut else "FALSCH", wert])
	if not gut:
		fehler += 1


## ein festes und ein freies Kügelchen, das 0,5 m darunter am Gelenk hängt (ohne Schwerkraft)
func _paar(unten: float, oben: float, motor: float) -> Array:
	var a := StaticBody3D.new()
	var b := RigidBody3D.new()
	for k in [a, b]:
		var cs := CollisionShape3D.new()
		var s := SphereShape3D.new()
		s.radius = 0.05
		cs.shape = s
		k.add_child(cs)
		root.add_child(k)
	a.global_position = Vector3(0, 2, 0)
	b.global_position = Vector3(0, 1.5, 0)
	b.mass = 2.0
	b.gravity_scale = 0.0
	b.angular_damp = 0.0
	b.linear_damp = 0.0
	var j := PhysicsServer3D.joint_create()
	var f := Transform3D(Basis.IDENTITY, Vector3(0, 2, 0))
	PhysicsServer3D.joint_make_generic_6dof(j, a.get_rid(), a.global_transform.affine_inverse() * f, b.get_rid(), b.global_transform.affine_inverse() * f)
	for ax in 3:
		PhysicsServer3D.generic_6dof_joint_set_flag(j, ax, PhysicsServer3D.G6DOF_JOINT_FLAG_ENABLE_LINEAR_LIMIT, true)
		PhysicsServer3D.generic_6dof_joint_set_param(j, ax, PhysicsServer3D.G6DOF_JOINT_LINEAR_LOWER_LIMIT, 0.0)
		PhysicsServer3D.generic_6dof_joint_set_param(j, ax, PhysicsServer3D.G6DOF_JOINT_LINEAR_UPPER_LIMIT, 0.0)
		PhysicsServer3D.generic_6dof_joint_set_flag(j, ax, PhysicsServer3D.G6DOF_JOINT_FLAG_ENABLE_ANGULAR_LIMIT, true)
		PhysicsServer3D.generic_6dof_joint_set_param(j, ax, PhysicsServer3D.G6DOF_JOINT_ANGULAR_LOWER_LIMIT, unten if ax == 0 else 0.0)
		PhysicsServer3D.generic_6dof_joint_set_param(j, ax, PhysicsServer3D.G6DOF_JOINT_ANGULAR_UPPER_LIMIT, oben if ax == 0 else 0.0)
	if motor > 0.0:
		PhysicsServer3D.generic_6dof_joint_set_flag(j, 0, PhysicsServer3D.G6DOF_JOINT_FLAG_ENABLE_MOTOR, true)
		PhysicsServer3D.generic_6dof_joint_set_param(j, 0, PhysicsServer3D.G6DOF_JOINT_ANGULAR_MOTOR_TARGET_VELOCITY, 0.0)
		PhysicsServer3D.generic_6dof_joint_set_param(j, 0, PhysicsServer3D.G6DOF_JOINT_ANGULAR_MOTOR_FORCE_LIMIT, motor)
	return [a, b, j]


## Drehung von b um +x des Gelenks (Grad): das hängende Ende (0, −1, 0) geht nach (0, −cos, −sin)
func _winkel(b: RigidBody3D) -> float:
	var d := b.global_position - Vector3(0, 2, 0)
	return rad_to_deg(atan2(-d.z, -d.y))


func _lauf(unten: float, oben: float, motor: float, dreh: float) -> Array:
	var p := _paar(unten, oben, motor)
	var b: RigidBody3D = p[1]
	b.angular_velocity = Vector3(dreh, 0, 0)
	b.linear_velocity = Vector3(dreh, 0, 0).cross(b.global_position - Vector3(0, 2, 0))
	var mn := 0.0
	var mx := 0.0
	var ab := 0.0
	var w20 := 0.0
	for i in 90:
		await physics_frame
		mn = minf(mn, _winkel(b))
		mx = maxf(mx, _winkel(b))
		ab = maxf(ab, absf((b.global_position - Vector3(0, 2, 0)).length() - 0.5))
		if i == 20:
			w20 = absf(b.angular_velocity.x)
	PhysicsServer3D.free_rid(p[2])
	p[0].queue_free()
	p[1].queue_free()
	return [mn, mx, ab, w20]


func _run() -> void:
	_pruef("Physik Jolt", String(ProjectSettings.get_setting("physics/3d/physics_engine")) == "Jolt Physics", String(ProjectSettings.get_setting("physics/3d/physics_engine")))
	# Grenzen [−0,3; 1,0] rad = [−17°, 57°]: gemessen wird die Drehung zwischen −57° und +17° (mit etwas Überschwingen)
	var r: Array = await _lauf(-0.3, 1.0, 0.0, 3.0)
	var r2: Array = await _lauf(-0.3, 1.0, 0.0, -3.0)
	var mn: float = minf(r[0], r2[0])
	var mx: float = maxf(r[1], r2[1])
	_pruef("Vorzeichen der Grenzen", mn < -45.0 and mn > -75.0 and mx > 10.0 and mx < 35.0, "Grenzen −17° bis 57° gegeben, gedreht von %.0f° bis %.0f°" % [mn, mx])
	_pruef("Lage fest", maxf(r[2], r2[2]) < 0.01, "Abstand vom Gelenk ändert sich um %.4f m" % maxf(r[2], r2[2]))
	var frei: Array = await _lauf(-3.0, 3.0, 0.0, 3.0)
	var reib: Array = await _lauf(-3.0, 3.0, 0.5, 3.0)
	# Trägheit 2 kg · (0,5 m)² = 0,5; Moment 0,5 Nm bremst 1 rad/s², nach 21 Bildern 0,35 rad/s
	_pruef("Motor als Reibung", frei[3] - reib[3] > 0.2 and frei[3] - reib[3] < 0.6, "nach 21 Bildern %.2f statt %.2f rad/s" % [reib[3], frei[3]])
	print("GELENK1215 %s" % ("gut" if fehler == 0 else "FALSCH %d" % fehler))
	quit(1 if fehler else 0)
