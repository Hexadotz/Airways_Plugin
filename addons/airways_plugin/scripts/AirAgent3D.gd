@icon("res://addons/airways_plugin/icons/icon_navAgent.svg")
class_name AirAgent3D extends Node3D
## @experimental

@export_subgroup("Debugging")
@export var debug_on: bool = false


#TODO:shit refrencing right here, for now it works but i HAVE to change it
@onready var navNode: AirWays3D = owner.navMap ##the navigation node this agent belongs to
#-------------------------------#
var target_position: Vector3 = Vector3.INF: 
	set(new_target_position):
		target_position = new_target_position
	get:
		return target_position

var navPath: PackedVector3Array = []
var navPathIndex: int = 0

signal target_reached()##Emitted once the target reaches the final point

#----------Debug shit-------------#
var shape_inst: MeshInstance3D = MeshInstance3D.new()
var boxshape: BoxMesh = BoxMesh.new()
#--------------------------------------------------#
func _ready() -> void:
	#boxshape.size = Vector3(0.25, 0.25, 0.25)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.BLUE_VIOLET
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	boxshape.material = mat
	
	shape_inst.mesh = boxshape
	add_child(shape_inst)
	
	print(shape_inst.global_position)
	pass

func _physics_process(delta: float) -> void:
	_build_path()
	if navPathIndex < navPath.size():
		shape_inst.global_position = navPath[navPathIndex]

#------------------------------------------------------------------------------#
##Returns the next position in global coordinates that can be moved to
func get_next_point() -> Vector3:
	#if we don't have a target to move to, push a warning
	if target_position == Vector3.INF:
		push_warning("There is no target point set")
		return global_position
	else:
		#if the Airway node failed to return a path push an error
		if navPath.is_empty():
			push_error("The AirWay Node failed to return a valid path")
			return global_position
		else:
			#if the index reached the end of an array, we have reached our target
			if navPathIndex < navPath.size():
				#if we are very close to the next target increment to the next point
				var distance: float = abs(global_position.distance_to(navPath[navPathIndex]))
				if 0.2 > distance:
					navPathIndex += 1
				
				return navPath[navPathIndex] if navPathIndex < navPath.size() else global_position
			else:
				emit_signal("target_reached")
				return global_position


##Checks if the target position can be reached by following the navigatin array, returns false if there is no target to follow
func is_target_reachable() -> bool:
	if not navPath.is_empty():
		var distance: float = abs(target_position.distance_to(navPath[navPath.size() - 1]))
		if distance <= navNode.cell_size:
			return true
		else:
			return false
	else:
		push_warning("The navPath is empty")
		return false

##Returns the last position in the array node, returns the parent position if there is no path designated
func get_last_position() -> Vector3:
	if not navPath.is_empty():
		return navPath[navPath.size() - 1]
	else:
		push_warning("The navPath is empty")
		return global_position

#TODO: now this is a whole ass new problem, since the target position updates every frame we get a new path every frame as well lol
func _build_path() -> void:
	await get_tree().create_timer(10).timeout
	print("setting path")
	if target_position != Vector3.INF:
		navPath = navNode.find_path(global_position, target_position)
		navPathIndex = 0
	else:
		push_warning("No target position set")
