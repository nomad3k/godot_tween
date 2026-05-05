extends Node3D

var red_arrow: Node3D
var green_arrow: Node3D
var blue_arrow: Node3D
var active_tween: Tween


func _ready() -> void:
	_setup_environment()
	_setup_camera()
	_setup_lighting()
	_setup_ground()
	_setup_arrows()
	_setup_ui()


func _setup_environment() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.08, 0.08, 0.12)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.6, 0.6, 0.6)
	env.ambient_light_energy = 1.0
	world_env.environment = env
	add_child(world_env)


func _setup_camera() -> void:
	var cam := Camera3D.new()
	add_child(cam)
	cam.fov = 80.0
	cam.global_position = Vector3(50.0, 90.0, 150.0)
	cam.look_at(Vector3(50.0, 0.0, 50.0))


func _setup_lighting() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50.0, 30.0, 0.0)
	light.shadow_enabled = true
	light.light_energy = 1.2
	add_child(light)


func _setup_ground() -> void:
	var ground := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(110.0, 110.0)
	ground.mesh = mesh
	ground.position = Vector3(50.0, -0.05, 50.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.22, 0.28, 0.22)
	ground.material_override = mat
	add_child(ground)


func _setup_arrows() -> void:
	red_arrow = _create_arrow(Color(0.9, 0.15, 0.15))
	green_arrow = _create_arrow(Color(0.15, 0.85, 0.15))
	blue_arrow = _create_arrow(Color(0.15, 0.4, 0.95))
	add_child(red_arrow)
	add_child(green_arrow)
	add_child(blue_arrow)

	red_arrow.position = Vector3(randf_range(5.0, 95.0), 0.0, randf_range(5.0, 95.0))
	red_arrow.rotation.y = randf_range(0.0, TAU)
	green_arrow.position = Vector3(randf_range(5.0, 95.0), 0.0, randf_range(5.0, 95.0))
	green_arrow.rotation.y = randf_range(0.0, TAU)

	# Blue starts at Red's transform
	blue_arrow.position = red_arrow.position
	blue_arrow.rotation.y = red_arrow.rotation.y


func _setup_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	var btn := Button.new()
	btn.text = "Tween Blue Arrow"
	btn.custom_minimum_size = Vector2(180.0, 48.0)
	btn.position = Vector2(20.0, 20.0)
	btn.pressed.connect(_on_tween_button_pressed)
	canvas.add_child(btn)

	var label := Label.new()
	label.text = "Red & Green: random  |  Blue tweens Red → Green"
	label.position = Vector2(20.0, 76.0)
	canvas.add_child(label)


# Arrow points in local -Z direction. Shaft from z=0 (tail) to z=-5, cone tip at z=-7.5.
func _create_arrow(color: Color) -> Node3D:
	var arrow := Node3D.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color

	# Shaft: CylinderMesh rotated 90° around X so it lies along Z
	var shaft := MeshInstance3D.new()
	var shaft_mesh := CylinderMesh.new()
	shaft_mesh.top_radius = 0.5
	shaft_mesh.bottom_radius = 0.5
	shaft_mesh.height = 5.0
	shaft.mesh = shaft_mesh
	shaft.rotation.x = PI / 2.0
	shaft.position.z = -2.5
	shaft.material_override = mat
	arrow.add_child(shaft)

	# Head: cone, top_radius=1.5 (base) at +Z, bottom_radius=0 (tip) at -Z after rotation
	var head := MeshInstance3D.new()
	var head_mesh := CylinderMesh.new()
	head_mesh.top_radius = 1.5
	head_mesh.bottom_radius = 0.0
	head_mesh.height = 2.5
	head.mesh = head_mesh
	head.rotation.x = PI / 2.0
	head.position.z = -6.25
	head.material_override = mat
	arrow.add_child(head)

	return arrow


func _on_tween_button_pressed() -> void:
	if active_tween != null:
		active_tween.kill()

	# Snap blue to red, then tween to green
	blue_arrow.position = red_arrow.position
	blue_arrow.rotation.y = red_arrow.rotation.y

	active_tween = create_tween().set_parallel(true)
	active_tween.tween_property(blue_arrow, "position", green_arrow.position, 5.0)
	active_tween.tween_property(blue_arrow, "rotation:y", green_arrow.rotation.y, 5.0)
