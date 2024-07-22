@icon("res://addons/airways_plugin/icons/icon_navAgent.svg")
class_name AirAgent3D extends Node3D
## @experimental

##A 3D agent that is used to avigate the space provided by [AirWays3D]

@export_subgroup("Debugging")
@export var debug_on: bool = false

#TODO:shit refrencing right here, for now it works but i HAVE to change it
@onready var navNode: AirWays3D = owner.navMap ##the navigation node this agent belongs to
#-------------------------------#
var target_position: Vector3 = Vector3.INF: 
	set(newtarget_position):
		target_position = newtarget_position
	get:
		return target_position

var _navPath: PackedVector3Array = []
var _navPathIndex: int = 0
var _all_clear: bool = true #the all clear signal which means this nde along with the navigation space (AirWays3D) are properly set

signal target_reached()##Emitted once the target reaches the final point

#----------Debug shit-------------#
var shape_inst: MeshInstance3D = MeshInstance3D.new()
var boxshape: BoxMesh = BoxMesh.new()
var mat = StandardMaterial3D.new()
#--------------------------------------------------#
func _ready() -> void:
	mat.albedo_color = Color.BLUE_VIOLET
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	boxshape.material = mat
	
	shape_inst.mesh = boxshape
	add_child(shape_inst)

func _physics_process(delta: float) -> void:
	if _all_clear:
		_build_path()
		if _navPathIndex < _navPath.size():
			shape_inst.global_position = _navPath[_navPathIndex]

#------------------------------------------------------------------------------#
##Returns the next position in global coordinates that can be moved to
func get_next_point() -> Vector3:
	#if we don't have a target to move to, push a warning
	if target_position == Vector3.INF:
		return global_position
	else:
		#if the Airway node failed to return a path push an error
		if _navPath.is_empty():
			push_error("The AirWay Node failed to return a valid path")
			return global_position
		else:
			#if the index reached the end of an array, we have reached our target
			if _navPathIndex < _navPath.size():
				#if we are very close to the next target increment to the next point
				var distance: float = abs(global_position.distance_to(_navPath[_navPathIndex]))
				if 0.2 > distance:
					_navPathIndex += 1
				
				return _navPath[_navPathIndex] if _navPathIndex < _navPath.size() else global_position
			else:
				emit_signal("target_reached")
				return global_position


##Checks if the target position can be reached by following the navigatin array, returns false if there is no target to follow
func is_target_reachable() -> bool:
	if not _navPath.is_empty():
		var distance: float = abs(target_position.distance_to(_navPath[_navPath.size() - 1]))
		if distance <= navNode.cell_size:
			return true
		else:
			return false
	else:
		push_warning("The _navPath is empty")
		return false

##Returns the last position in the array node, returns the parent position if there is no path designated
func get_last_position() -> Vector3:
	if not _navPath.is_empty():
		return _navPath[_navPath.size() - 1]
	else:
		push_warning("The _navPath is empty")
		return global_position

#TODO: now this is a whole ass new problem, since the target position updates every frame we get a new path every frame as well lol
#NOTE: ok somehow someway it works all i did was comment the line that sets the navpathIndex to 0 and the damn thing works now, just like that... shit
func _build_path() -> void:
	if navNode != null:
		if target_position != Vector3.INF:
			_navPath = navNode.find_path(global_position, target_position)
		else:
			push_warning("There is no target point set")
	else:
		push_warning("There is no navigation space")
