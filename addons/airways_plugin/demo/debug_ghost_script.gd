extends CharacterBody3D

@onready var cam: Camera3D = $head/Camera3D
const mouse_sen: float = 0.1

var dir: Vector3 = Vector3.ZERO
var speed: float = 20.0
var levitaion_speed: float = 5.0

var mouse_cap: bool = true
#---------------------------------------------------#
var ray_param = PhysicsRayQueryParameters3D.new()
@onready var space_state = get_world_3d().direct_space_state
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sen))
			cam.rotate_x(deg_to_rad(-event.relative.y * mouse_sen))
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-85), deg_to_rad(85))
		
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var from_point = cam.project_ray_origin(event.position)
		ray_param.from = from_point
		ray_param.to = from_point + cam.project_ray_normal(event.position) * 2000
		
		var resault = space_state.intersect_ray(ray_param)
		
		if not resault.is_empty():
			var pos: Vector3 = snapped(resault["position"], Vector3(0.1, 0.1, 0.1))
			print("go to: ", pos)
			get_tree().call_group("drone", "move_to", pos)


func capture_mouse() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		mouse_cap = !mouse_cap
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) if mouse_cap else Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta: float) -> void:
	capture_mouse()
	
	if Input.is_action_just_pressed("restart_scene"):
		get_tree().reload_current_scene()
	
	dir = Vector3.ZERO
	
	#yandre simulator
	if Input.is_action_pressed("forward"):
		dir -= cam.global_transform.basis.z
	if Input.is_action_pressed("backwards"):
		dir += cam.global_transform.basis.z
	if Input.is_action_pressed("left"):
		dir -= global_transform.basis.x
	if Input.is_action_pressed("right"):
		dir += global_transform.basis.x
	
	if Input.is_action_pressed("up"):
		dir.y += levitaion_speed * delta
	if Input.is_action_pressed("down"):
		dir.y -= levitaion_speed * delta
	
	dir = dir.normalized()
	
	if Input.is_action_pressed("sprint"):
		speed = 50
	else:
		speed = 25
	
	velocity = dir * speed
	
	move_and_slide()
