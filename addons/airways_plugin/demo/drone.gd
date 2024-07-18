extends CharacterBody3D

@export var navMap: AirWays3D
@export var target_distance: float = 0.1
@export var navAgent: AirAgent3D

@export var player: CharacterBody3D

var navPath: Array = []
var path_index: int = 0
var follow_target: bool = false

const speed = 2
#----------------------------------------------------#
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	navAgent.target_position = player.global_position
	
	#--------------------------#
	_new_move(delta)
	move_and_slide()

func _new_move(delta: float) -> void:
	var direction: Vector3 = global_position.direction_to(navAgent.get_next_point())
	velocity = direction * speed

func move_to(to_point: Vector3) -> void:
	navAgent.target_position = to_point
	#navAgent.navPath = navAgent.navNode.find_path(global_position, navAgent.target_position)
	#navAgent.navPathIndex = 0
	
	print("Size: ",navAgent.navPath.size(), " Path: ", navAgent.navPath)
