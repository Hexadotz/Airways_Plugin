@tool
@icon("res://icon.svg")
class_name AirWays3D extends Node3D

##The size of the bounding box the nodes are going to spawn in NOTE: the size will snap acording to the cell size
@export var size: Vector3 = Vector3(1, 1, 1)
##the distance between each node in the navigation area
@export var cell_size: float = 1.0 
##the bounding box color
@export var bounding_box_color: Color = Color(1, 1, 0, 0.08)
##disable the visibilty of the debug cubes that represent a node in the A* grip
@export var show_debug_nodes: bool = true

@onready var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

var _point_material: StandardMaterial3D = StandardMaterial3D.new()
var _point_mesh: BoxMesh = BoxMesh.new()

var _bounding_box_meshInstance: MeshInstance3D = MeshInstance3D.new()
var _bounding_box_material: StandardMaterial3D = StandardMaterial3D.new()
var _bounding_box_mesh: BoxMesh = BoxMesh.new()
#--------------------------------------------------------------#
func _ready() -> void:
	_point_mesh.size = Vector3(0.25, 0.25, 0.25)
	_point_material.albedo_color = Color.RED
	
	_bounding_box_material.albedo_color = bounding_box_color
	_bounding_box_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_bounding_box_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_bounding_box_mesh.material = _bounding_box_material
	_bounding_box_mesh.size = size
	
	_bounding_box_meshInstance.mesh = _bounding_box_mesh
	add_child(_bounding_box_meshInstance)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		size = snapped(size, Vector3(cell_size, cell_size, cell_size))
		_bounding_box_meshInstance.mesh.size = size
		
		_bounding_box_material.albedo_color = bounding_box_color
		
		#if cell_size <= 0.5:
		#	push_warning("Warning: cell sizes less than 0.5 causes unexpected behaviour")

func _spawn_points() -> void:
	var offset: Vector3 = Vector3(cell_size / 2, cell_size / 2, cell_size / 2) #this variables is made to set the offset so all of nodes are within the box
	var aabb: AABB = AABB(-size / 2, size) * global_transform
	var start_point: Vector3 = aabb.position + offset
	
	#we get the amount of points we will spawn by dividing the length of an axis by the length of one node
	#Example: if the size of aabb on the x axis is 10 and the grid step is one that means we will spawn 10 nodes aross that axis
	var x_steps: float = aabb.size.x / cell_size
	var y_steps: float = aabb.size.y / cell_size
	var z_steps: float = aabb.size.z / cell_size
	
	_clear_debg_points()
	
	print("children count before spawning: ", get_children().size() - 1)
	#spawning the nodes, each for loop represent an axis we fill z then y than x
	for x: float in x_steps:
		for y: float in y_steps:
			for z: float in z_steps:
				#the location the next point is going to spawn in
				var _next_step: Vector3 = -(start_point + Vector3(x * cell_size, y * cell_size, z * cell_size))
				
				if not is_overlapping(_next_step):
					_spawn_debug_point(_next_step)
				
				#add_child(_point_meshInstance)
				#_point_meshInstance.global_position = -next_step 
	
	print("children count after spawning: ", get_children().size() - 1)


#NOTE creating the objects here so we don't have to create a new one each cal of the is_ovelapping method
var point_param = PhysicsPointQueryParameters3D.new()
var shape_param = PhysicsShapeQueryParameters3D.new()
var collision_shape: BoxShape3D = BoxShape3D.new()
func is_overlapping(check_position: Vector3) -> bool: ##Returns true if the location we gave is occupied by another physics object
	#we first try a point intersection test if it's true then we don't spawn the node
	#but if it dosen't report anyting we make a second check using a whole shape to see if it intersect
	
	#for the point intersection setup
	point_param.set_position(check_position)
	point_param.collide_with_bodies = true
	point_param.collide_with_areas = false
	
	var poin_resault: Array = space_state.intersect_point(point_param)
	if poin_resault.size() != 0:
		return true
	else:
		#if the point didn't intersect, do a shape check
		collision_shape.set_size(Vector3(cell_size, cell_size, cell_size))
		
		shape_param.shape = collision_shape
		shape_param.collide_with_bodies = true
		shape_param.collide_with_areas = false
		shape_param.transform.origin = check_position
		
		var shape_resault: Array[Dictionary] = space_state.intersect_shape(shape_param)
		#if the collision shape collides with a wall, don't spawn point
		if shape_resault.size() != 0:
			return true
	
	return false

#-------------------------------------------------------------------#
func _spawn_debug_point(location: Vector3) -> void:
	if show_debug_nodes:
		var _point_meshInstance: MeshInstance3D = MeshInstance3D.new()
		
		_point_meshInstance.mesh = _point_mesh
		_point_meshInstance.material_override = _point_material
		
		add_child(_point_meshInstance)
		_point_meshInstance.global_position = location

func _clear_debg_points() -> void:
	#delete any existing node before spawning
	for child in get_children():
		if child != _bounding_box_meshInstance:
			child.queue_free()
