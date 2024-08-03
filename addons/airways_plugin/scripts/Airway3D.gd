@tool
@icon("res://addons/airways_plugin/icons/icon_AW.svg")
class_name AirWays3D extends Node3D
## @experimental
##A 3D navigation agent designed for the AirWays node facilitates navigation throughout the generated area.

@export var navigation_space: AirWaysNavigationSpace ##the navigation resource required  to bake and store the information of the nodes
var y_level: float = 0 ## nuh uh

@onready var _editor_viewport: Viewport = null
@onready var _viewport_cam: Camera3D = null

var _DEBUG_SCRIPT = preload("res://addons/airways_plugin/scripts/visual_debug.gd").new()
var _Astar: AStar3D = AStar3D.new()
var _toggled: bool = false
#-------------points meshes-------------------------#
var _bounding_box: MeshInstance3D = null
var _insert_box: MeshInstance3D = null

var point_positions: PackedVector3Array = [] #NOTE: remeber to removo this if thing gets fucked up

var multiMeshNode: MultiMeshInstance3D = MultiMeshInstance3D.new()

#FIXME: VERY IMPORTANT, the reason why the path fails to return a path is due to the area being segmented (sometimes a whole reagion won't connect to another)
#--------------------------------------------------------------#
func _get_configuration_warnings():
	if navigation_space == null:
		return ["A Navigation Space must be set for this node to work"]
	else:
		return []

func _enter_tree() -> void:
	add_to_group("AirNav", true)

func _ready() -> void:
	_bounding_box = _DEBUG_SCRIPT.prep_boundingBox()
	add_child(_bounding_box)
	
	add_child(multiMeshNode)
	
	if Engine.is_editor_hint():
		_editor_viewport = EditorInterface.get_editor_viewport_3d()
		_viewport_cam = EditorInterface.get_editor_viewport_3d().get_camera_3d()
		#_load_points()
	else:
		_connect_points(true)
		_bounding_box.mesh.size = navigation_space.size

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()
		
		# _get_mouse_position_in_world() #TODO: implement this later
		
		# this is for clamping navigation_space.size andcell navigation_space.size, where the user shouldn't put a negative number, but can and will inevitably fuck the whole system which is already glued by hopes and dreams
		if navigation_space != null:
			navigation_space.size = snapped(navigation_space.size, Vector3(navigation_space.cell_size, navigation_space.cell_size, navigation_space.cell_size))
			navigation_space.size = clamp(navigation_space.size, Vector3.ZERO, Vector3.INF)
			
			_bounding_box.mesh.size = navigation_space.size
			global_position = snapped(global_position, Vector3.ONE)

func _clear_debg_points() -> void:
	if multiMeshNode.multimesh == null:
		push_warning("No points to clear")
		return
	
	multiMeshNode.multimesh = null
	point_positions.clear()
	
	# also clear out the point dict
	navigation_space.point_dict.clear()

func _set_point_visible(value: bool) -> void:
	multiMeshNode.visible = value

##spawns all points in the designated area and also spawn the debug cubes for visuals
func _spawn_points() -> void:
	var offset: Vector3 = Vector3(navigation_space.cell_size / 2, navigation_space.cell_size / 2, navigation_space.cell_size / 2) #this variables is made to set the offset so all of nodes are within the box
	var aabb: AABB = AABB(-navigation_space.size / 2, navigation_space.size) * global_transform
	var start_point: Vector3 = aabb.position + offset
	
	# we get the amount of points we will spawn by dividing the length of an axis by the length of one node
	# Example: if the navigation_space.size of aabb on the x axis is 10 and the grid step is one that means we will spawn 10 nodes aross that axis
	var x_steps: int = aabb.size.x / navigation_space.cell_size
	var y_steps: int = aabb.size.y / navigation_space.cell_size
	var z_steps: int = aabb.size.z / navigation_space.cell_size
	
	_clear_debg_points()
	
	# spawning the nodes, each for loop represent an axis we fill z then y than x
	for x: int in x_steps:
		for y: int in y_steps:
			for z: int in z_steps:
				# the location the next point is going to spawn in
				var _next_step: Vector3 = -(start_point + Vector3(x * navigation_space.cell_size, y * navigation_space.cell_size, z * navigation_space.cell_size))
				
				if not _is_overlapping(_next_step):
					# adding the point to our _Astar map
					var id: int = _Astar.get_available_point_id()
					_Astar.add_point(id, _next_step)
					
					# add the point id to the dictionary with it's position being the key
					navigation_space.point_dict[_vector3_to_key(_next_step)] = id
	
	_connect_points()

# connects all the point to each others
func _connect_points(loaded: bool = false) -> void:
	if loaded:
		_load_points()
	
	for pnt in navigation_space.point_dict:
		# since the key for the dict is a string  we wplit each number and put all of them in an array
		var node_pos_str: Array = pnt.split(",")
		# we make a vector3 out of the points cordinate in the dictionary
		var world_position: Vector3 = Vector3(float(node_pos_str[0]), float(node_pos_str[1]), float(node_pos_str[2]))
		# an array that holds the distance the node is going to look for
		var offset_cord: Array = [-navigation_space.cell_size, 0, navigation_space.cell_size]
		
		point_positions.append(world_position)
		
		#each axis can go -1 0 1 so this gives all the possible direction a node can point to
		for y in offset_cord:
			for z in offset_cord:
				for x in offset_cord:
					#the position in which we're looking for the nrighbouring node
					var search_offset: Vector3 = Vector3(x, y, z)
					if search_offset == Vector3.ZERO:
						continue
					
					# we put the point in a string, this point might or might not exist in our dictionary
					var possible_point: String = _vector3_to_key(world_position + search_offset)
					# if the nrighbouring point actually do exist in the dictionary we connect them
					if navigation_space.point_dict.has(possible_point):
						# the current point we're going to connect from
						var cur_id: int = navigation_space.point_dict[pnt]
						# the point id we're connecting to
						var next_id: int = navigation_space.point_dict[possible_point]
						
						# if the poitns aren't connected we connect them
						if not _Astar.are_points_connected(cur_id, next_id):
							_Astar.connect_points(cur_id, next_id, navigation_space.bidirectional)
	
	multiMeshNode.multimesh = _DEBUG_SCRIPT._update_MultiMesh(global_position, point_positions)
	
	print_rich("[color=green]Nodes baked succesfully! Total points baked: ", str(navigation_space.point_dict.size()))

#NOTE: creating the objects here so we don't have to create a new one each cal of the is_ovelapping method
var _point_param = PhysicsPointQueryParameters3D.new()
var _shape_param = PhysicsShapeQueryParameters3D.new()
var _collision_shape: BoxShape3D = BoxShape3D.new()
# Returns true if the location we gave is occupied by another physics object
func _is_overlapping(check_position: Vector3) -> bool:
	var _space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	# we first try a point intersection test if it's true then we don't spawn the node
	# but if it dosen't report anyting we make a second check using a whole shape to see if it intersect
	
	# for the point intersection setup
	_point_param.set_position(check_position)
	_point_param.collide_with_bodies = true
	_point_param.collide_with_areas = false
	
	var poin_resault: Array = _space_state.intersect_point(_point_param)
	if poin_resault.size() != 0:
		return true
	else:
		# if the point didn't intersect, do a shape check
		_collision_shape.set_size(Vector3(navigation_space.cell_size, navigation_space.cell_size, navigation_space.cell_size))
		
		_shape_param.shape = _collision_shape
		_shape_param.collide_with_bodies = true
		_shape_param.collide_with_areas = false
		_shape_param.transform.origin = check_position
		
		var shape_resault: Array[Dictionary] = _space_state.intersect_shape(_shape_param)
		# if the collision shape collides with a wall, don't spawn point
		if shape_resault.size() != 0:
			return true
	
	return false



# turn the vector 3 to a string for the point_dict by taking each axis and joing them all into a single string being seperated by a ,
func _vector3_to_key(vect: Vector3) -> String:
	var x_string: String = str(snapped(vect.x, 0.01))
	var y_string: String = str(snapped(vect.y, 0.01))
	var z_string: String = str(snapped(vect.z, 0.01))
	
	return x_string + "," + y_string + "," + z_string

# loads the points if we launch the scene or quite the editor to maintain consisentcy
func _load_points() -> void:
	for point in navigation_space.point_dict:
		var node_pos_str: Array = point.split(",")
		var world_position: Vector3 = Vector3(float(node_pos_str[0]), float(node_pos_str[1]), float(node_pos_str[2]))
		
		_Astar.add_point(navigation_space.point_dict[point], world_position)

func find_path(from_point: Vector3, to_point: Vector3) -> PackedVector3Array:
	var start_id: int = _Astar.get_closest_point(from_point)
	var end_id: int = _Astar.get_closest_point(to_point)
	return _Astar.get_point_path(start_id, end_id)

#-----------------------------point insertion-------------------------------#
#TODO: implement this shit but once i unfuck my brain i will go back to this
var _ray_length: float = 20
func _get_mouse_position_in_world() -> void:
	if _toggled:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			var from_point: Vector3 = _editor_viewport.project_ray_origin(_editor_viewport.navigation_space.size / 2)
			var to_point: Vector3 = from_point + _editor_viewport.project_ray_normal(_editor_viewport.get_mouse_position()) * _viewport_cam.global_position.y
			
			to_point = snapped(to_point, Vector3(navigation_space.cell_size, y_level, navigation_space.cell_size))
			y_level = snappedf(y_level, navigation_space.cell_size)
			to_point.y = y_level
			
			_insert_box.global_position = to_point

#*--------------------------------------------------------------*#
func test() -> void:
	navigation_space.point_dict = navigation_space.point_dict

func test2() -> void:
	_print_large("point data: ", navigation_space.point_dict)

#function to print to a text file instead of the console since that is making the engine bitch a lot
func _print_large(console_text: String = "", data = null) -> void:
	var file = FileAccess.open("res://addons/airways_plugin/debugs/debug_print.txt", FileAccess.WRITE)
	
	if file:
		print(console_text)
		file.store_string(data)
		file.close()
	else:
		push_error("error trying to print to file")
