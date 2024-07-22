extends CharacterBody3D

@export var navMap: AirWays3D
@export var navAgent: AirAgent3D
@export var player: CharacterBody3D

const speed: int = 15
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
	velocity = lerp(velocity, direction * speed, 3 * delta)

func _on_air_agent_3d_target_reached() -> void:
	print("got you fucker")
