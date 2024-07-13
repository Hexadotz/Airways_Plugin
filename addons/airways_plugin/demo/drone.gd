extends CharacterBody3D

@export var navMap: AirWays3D
@export var target_distance: float = 0.1
@export var navAgent: AirAgent3D


var navPath: Array = []
var path_index: int = 0
var follow_target: bool = false

const speed = 5
#----------------------------------------------------#
func _ready() -> void:
	navAgent.target_position = to_global(Vector3(-2.5, 1.7, -14))
	await get_tree().create_timer(5).timeout

func _physics_process(delta: float) -> void:
	
	_new_move(delta)
	#_old_move()
	move_and_slide()

func _new_move(delta: float) -> void:
	
	var direction: Vector3 = global_position.direction_to(navAgent.get_next_point())
	velocity = lerp(velocity, direction * speed, 5 * delta)

func _old_move() -> void:
	if follow_target:
		#move_to(player.global_position)
		pass
	
	if path_index < navPath.size():
		var direction: Vector3 = global_position.direction_to(navPath[path_index])
		if global_position.distance_to(navPath[path_index]) < target_distance:
			path_index += 1
		else:
			velocity = direction * speed
		

func move_to(to_point: Vector3) -> void:
	navPath = navMap.find_path(global_position, to_point)
	path_index = 0
