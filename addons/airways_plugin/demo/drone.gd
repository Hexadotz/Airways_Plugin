extends CharacterBody3D

@export var navMap: AirWays3D
@export var player: CharacterBody3D
@export var target_distance: float = 0.1

var navPath: Array = []
var path_index: int = 0
var follow_target: bool = false

const speed = 5
#----------------------------------------------------#
func _ready() -> void:
	await get_tree().create_timer(5).timeout
	follow_target = true

func _physics_process(delta: float) -> void:
	if follow_target:
		#move_to(player.global_position)
		pass
	
	if path_index < navPath.size():
		var direction: Vector3 = global_position.direction_to(navPath[path_index])
		if global_position.distance_to(navPath[path_index]) < target_distance:
			path_index += 1
		else:
			velocity = direction * speed
		
		move_and_slide()

func move_to(to_point: Vector3) -> void:
	navPath = navMap.find_path(global_position, to_point)
	print(navPath)
	path_index = 0
