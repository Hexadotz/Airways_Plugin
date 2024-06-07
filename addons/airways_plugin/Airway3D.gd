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
##if the agent can tracel both ways (need to to rebake the points)
@export var bidirectional: bool = true

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
	_point_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_point_material.disable_receive_shadows = true
	
	_bounding_box_material.albedo_color = bounding_box_color
	_bounding_box_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_bounding_box_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_bounding_box_mesh.material = _bounding_box_material
	_bounding_box_mesh.size = size
	
	_bounding_box_meshInstance.mesh = _bounding_box_mesh
	add_child(_bounding_box_meshInstance)
	
	_spawn_points()

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
	
	#print("children count before spawning: ", get_children().size() - 1)
	#spawning the nodes, each for loop represent an axis we fill z then y than x
	for x: float in x_steps:
		for y: float in y_steps:
			for z: float in z_steps:
				#the location the next point is going to spawn in
				var _next_step: Vector3 = -(start_point + Vector3(x * cell_size, y * cell_size, z * cell_size))
				
				if not _is_overlapping(_next_step):
					#spawn the debug points
					_spawn_debug_point(_next_step)
				
					#we add the point location to an array for AStar poin connection
					point_list.append(_next_step)
	
	_add_points()
	_connect_points()
	#print("Points spawned in point list: ",point_list.size())
	#print("children count after spawning: ", get_children().size() - 1)


#NOTE creating the objects here so we don't have to create a new one each cal of the is_ovelapping method
var point_param = PhysicsPointQueryParameters3D.new()
var shape_param = PhysicsShapeQueryParameters3D.new()
var collision_shape: BoxShape3D = BoxShape3D.new()
func _is_overlapping(check_position: Vector3) -> bool: ##Returns true if the location we gave is occupied by another physics object
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
	
	#also clear out the point list
	point_list.clear()
	point_dict.clear()

#---------------------AStar logic (aka get ready for ass pounding)----------------------#
var point_dict: Dictionary = {}
# holds the position of the nodes that got generated
#NOTE: still unsure if the position need to be local or global
var point_list: Array[Vector3] = [] 
var Astar: AStar3D = AStar3D.new()

func _add_points() -> void:
	for point: Vector3 in point_list:
		#get the availabe point id to use it when adding points
		var id: int = Astar.get_available_point_id()
		#adding the point to our AStar map
		Astar.add_point(id, point) #NOTE: the second paramater might be wrong
		#add the point id to the dictionary with it's position being the key
		point_dict[_vector3_to_key(point)] = id
	
	#print(point_dict)

#turn the vector 3 to a string for the point_dict
func _vector3_to_key(vect: Vector3) -> String:
	return str(int(round(vect.x))) + "," + str(int(round(vect.y))) + "," + str(int(round(vect.z)))

func _connect_points() -> void:
	for pnt in point_dict:
		#since the key for the dict is a string  we wplit each number and put all of them in an array
		var node_pos_str: Array = pnt.split(",")
		#we make a vector3 out of the points cordinate in the dictionary
		var world_position: Vector3 = Vector3(float(node_pos_str[0]), float(node_pos_str[1]), float(node_pos_str[2]))
		#an array that holds the distance the node is going to look for
		var offset_cord: Array = [-cell_size, 0, cell_size]
		
		#each axis can go -1 0 1 so this gives all the possible direction a node can point to
		for y in offset_cord:
			for z in offset_cord:
				for x in offset_cord:
					#the position in which we're looking for the nrighbouring node
					var search_offset: Vector3 = Vector3(x, y, z)
					if search_offset == Vector3.ZERO:
						continue
					
					#we put the point in a string, this point might or might not exist in our dictionary
					var _possible_point: String = _vector3_to_key(world_position + search_offset)
					#if the nrighbouring point actually do exist in the dictionary we connect them
					if point_dict.has(_possible_point):
						#the current point we're going to connect from
						var cur_id: int = point_dict[pnt]
						#the point id we're connecting to
						var next_id: int = point_dict[_possible_point]
						
						#if the poitns aren't connected we connect them
						if not Astar.are_points_connected(cur_id, next_id):
							Astar.connect_points(cur_id, next_id, bidirectional)

func find_path(from_point: Vector3, to_point: Vector3) -> Array:
	var start_id: int = Astar.get_closest_point(from_point)
	var end_id: int = Astar.get_closest_point(to_point)
	var res: Array = Astar.get_point_path(start_id, end_id)
	return res
