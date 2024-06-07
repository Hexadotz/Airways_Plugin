extends CharacterBody3D

@export var navMap: AirWays3D
@export var target_distance: float = 0.1

var navPath: Array = []
var path_index: int = 0

const speed = 5
#----------------------------------------------------#
func _physics_process(delta: float) -> void:
	if path_index < navPath.size():
		var direction: Vector3 = global_position.direction_to(navPath[path_index])
		if global_position.distance_to(navPath[path_index]) < target_distance:
			path_index += 1
		else:
			velocity = direction * speed
		
		move_and_slide()

func move_to(to_point: Vector3) -> void:
	navPath = navMap.find_path(global_position, to_point)
	path_index = 0
