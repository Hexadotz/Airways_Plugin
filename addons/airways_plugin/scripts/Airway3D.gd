@tool
@icon("res://addons/airways_plugin/icons/icon_AW.svg")
class_name AirWays3D extends Node3D
## @experimental

##The size of the bounding box the nodes are going to spawn in NOTE: the size will snap acording to the cell size
@export var size: Vector3 = Vector3(1, 1, 1)
##the distance between each node in the navigation area
@export var cell_size: float = 1.0
##if the agent can tracel both ways (need to to rebake the points)
@export var bidirectional: bool = true
##The physics layer the node scans, use this to execlude objects you don't want the node to consider "terrain"
##For an example you don't want this node to collide with props in the level
@export_flags_3d_physics var collision_mask

@export var y_level: float = 0

@onready var _editor_viewport: Viewport = null
@onready var _viewport_cam: Camera3D = null

@onready var _space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

var _DEBUG_SCRIPT = preload("res://addons/airways_plugin/scripts/visual_debug.gd").new()

var _visible_points: bool = true
var _toggled: bool = false
#-------------points meshes-------------------------#

var _bounding_box: MeshInstance3D = null
var _insert_box: MeshInstance3D = null

#--------------------------------------------------------------#
func _ready() -> void:
	_DEBUG_SCRIPT.prep_debug_points()
	
	_bounding_box = _DEBUG_SCRIPT.prep_boundingBox()
	add_child(_bounding_box)
	
	#NOTE: finish working on this in the future, it's for the stupid node adding/deletion feature
	#insert_box = _DEBUG_SCRIPT.prep_insert_point()
	#add_child(insert_box)
	
	_load()
	if Engine.is_editor_hint():
		_editor_viewport = EditorInterface.get_editor_viewport_3d()
		_viewport_cam = EditorInterface.get_editor_viewport_3d().get_camera_3d()
		_load_points()
	else:
		_connect_points(true)
		_bounding_box.mesh.size = size

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		#this is for clamping size andcell size, where the user shouldn't put a negative number, but can and will inevitably fuck the whole system which is already glued by hopes and dreams
		size = snapped(size, Vector3(cell_size, cell_size, cell_size))
		size = clamp(size, Vector3.ZERO, Vector3.INF)
		cell_size = clamp(cell_size, 0, INF)
		
		_bounding_box.mesh.size = size
		
		#TODO: implement this shit
		if _toggled:
			#_get_mouse_position_in_world()
			pass

func _clear_debg_points() -> void:
	_DEBUG_SCRIPT.clear_points()
	#also clear out the point dict
	_point_dict.clear()

func _set_point_visible(value: bool) -> void:
	_DEBUG_SCRIPT.set_visibility(value)
	_visible_points = value

##spawns all points in the designated area and also spawn the debug cubes for visuals
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
	
	#spawning the nodes, each for loop represent an axis we fill z then y than x
	for x: float in x_steps:
		for y: float in y_steps:
			for z: float in z_steps:
				#the location the next point is going to spawn in
				var _next_step: Vector3 = -(start_point + Vector3(x * cell_size, y * cell_size, z * cell_size))
				#var _rounded_step = Vector3 = snapped(_next_step, Vector3())
				
				if not _is_overlapping(_next_step):
					#spawn the debug points
					var point_mesh: MeshInstance3D = _DEBUG_SCRIPT.spawn_debug_point()
					add_child(point_mesh)
					point_mesh.visible = _visible_points
					point_mesh.global_position = _next_step
					#adding the point to our _Astar map
					var id: int = _Astar.get_available_point_id()
					_Astar.add_point(id, _next_step)
					
					#add the point id to the dictionary with it's position being the key
					_point_dict[_vector3_to_key(_next_step)] = id
	
	_connect_points()


#NOTE: creating the objects here so we don't have to create a new one each cal of the is_ovelapping method
var _point_param = PhysicsPointQueryParameters3D.new()
var _shape_param = PhysicsShapeQueryParameters3D.new()
var _collision_shape: BoxShape3D = BoxShape3D.new()
func _is_overlapping(check_position: Vector3) -> bool: ##Returns true if the location we gave is occupied by another physics object
	#we first try a point intersection test if it's true then we don't spawn the node
	#but if it dosen't report anyting we make a second check using a whole shape to see if it intersect
	
	#for the point intersection setup
	_point_param.set_position(check_position)
	_point_param.collide_with_bodies = true
	_point_param.collide_with_areas = false
	
	var poin_resault: Array = _space_state.intersect_point(_point_param)
	if poin_resault.size() != 0:
		return true
	else:
		#if the point didn't intersect, do a shape check
		_collision_shape.set_size(Vector3(cell_size, cell_size, cell_size))
		
		_shape_param.shape = _collision_shape
		_shape_param.collide_with_bodies = true
		_shape_param.collide_with_areas = false
		_shape_param.transform.origin = check_position
		
		var shape_resault: Array[Dictionary] = _space_state.intersect_shape(_shape_param)
		#if the collision shape collides with a wall, don't spawn point
		if shape_resault.size() != 0:
			return true
	
	return false

#-------------------------------------------------------------------#
#once i unfuck my brain i will go back to this
var _ray_length: float = 20
func _get_mouse_position_in_world() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		var from_point: Vector3 = _editor_viewport.project_ray_origin(_editor_viewport.size / 2)
		var to_point: Vector3 = from_point + _editor_viewport.project_ray_normal(_editor_viewport.get_mouse_position()) * _viewport_cam.global_position.y
		
		to_point = snapped(to_point, Vector3(cell_size, y_level, cell_size))
		y_level = snappedf(y_level, cell_size)
		to_point.y = y_level
		
		_insert_box.global_position = to_point

#---------------------Astar logic (aka get ready for ass pounding)----------------------#
var _point_dict: Dictionary = {}
var _Astar: AStar3D = AStar3D.new()

#turn the vector 3 to a string for the _point_dict
func _vector3_to_key(vect: Vector3) -> String:
	var x_string: String = str(int(round(vect.x)))
	var y_string: String = str(int(round(vect.y)))
	var z_string: String = str(int(round(vect.z)))
	
	return x_string + "," + y_string + "," + z_string

func _connect_points(loaded: bool = false) -> void:
	if loaded:
		_load_points()
	
	for pnt in _point_dict:
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
					var possible_point: String = _vector3_to_key(world_position + search_offset)
					#if the nrighbouring point actually do exist in the dictionary we connect them
					if _point_dict.has(possible_point):
						#the current point we're going to connect from
						var cur_id: int = _point_dict[pnt]
						#the point id we're connecting to
						var next_id: int = _point_dict[possible_point]
						
						#if the poitns aren't connected we connect them
						if not _Astar.are_points_connected(cur_id, next_id):
							_Astar.connect_points(cur_id, next_id, bidirectional)
	
	
	#var dt = ""
	#for pat in _point_dict:
		#dt += "id: " + str(_point_dict[pat]) + str(_Astar.get_point_connections(_point_dict[pat])) + " / "
	#
	#_print_large("points saved to file", dt)
	print_rich("[color=green]Points baked![b][/b][/color]")
	_save()

func _load_points() -> void:
	for point in _point_dict:
		var node_pos_str: Array = point.split(",")
		var world_position: Vector3 = Vector3(float(node_pos_str[0]), float(node_pos_str[1]), float(node_pos_str[2]))
		
		var point_mesh: MeshInstance3D = _DEBUG_SCRIPT.spawn_debug_point()
		add_child(point_mesh)
		
		point_mesh.global_position = world_position
		_Astar.add_point(_point_dict[point], world_position)

func find_path(from_point: Vector3, to_point: Vector3) -> PackedVector3Array:
	var start_id: int = _Astar.get_closest_point(from_point)
	var end_id: int = _Astar.get_closest_point(to_point)
	#print("Start point id: ", start_id, " - End point id: ", end_id)
	
	#print("Start poin is connected to: ", _Astar.get_point_connections(start_id))
	#print("End poin is connected to: ", _Astar.get_point_connections(end_id))
	
	var resault: PackedVector3Array = _Astar.get_point_path(start_id, end_id)
	return resault

func test() -> void:
	_save()

func test2() -> void:
	_load()

#-------------------Saving/Loading----------------------#
#NOTE: the idea here is to save the points to a file then load them whenever the node enters the tree or the editor quits
const save_path: String = "res://addons/airways_plugin/save_data/saved_data.save"

func _save() -> void:
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	
	if file != null:
		#storing the point data to a file
		file.store_var(_point_dict)
		print_rich("[color=green][b]File saved to: [/b][/color]", save_path)
	else:
		push_error("Error saving file: ", save_path)
	
	file.close()

func _load() -> void:
	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	
	if FileAccess.file_exists(save_path):
		if file != null:
			var data: Dictionary = file.get_var()
			_print_large("text printed", str(data))
			#putting the data we loaded back the the dictionary
			_point_dict = data
			
			print_rich("[color=green][b]File loaded from: [/b][/color]", save_path)
		else:
			push_error("Error loading file: ", save_path)
	else:
		push_error("Couldn't file file: ", save_path)
	
	file.close()

#function to print to a text file instead of the console since that is making the engine bitch a lot
func _print_large(console_text: String = "", data = null) -> void:
	var file = FileAccess.open("res://addons/airways_plugin/debugs/debug_print.txt", FileAccess.WRITE)
	
	if file:
		print(console_text)
		file.store_string(data)
		file.close()
	else:
		push_error("error trying to print to file")
