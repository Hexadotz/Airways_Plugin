extends Node3D

@onready var debugger_mesh: MeshInstance3D = $Misc/debugger_mesh

#----------------------------------------#
func _ready() -> void:
	debugger_mesh.global_position = Vector3(-2.5, 1.7, -14)
	#	sdget_tree().call_group("drone", "move_to", Vector3(-2.5, 1.7, -14))
	print(Vector3(-30, 20, 3) + Vector3(5,2,3))
