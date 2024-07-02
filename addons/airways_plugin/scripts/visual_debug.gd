extends Node

var _point_material: StandardMaterial3D = StandardMaterial3D.new()
var _point_mesh: BoxMesh = BoxMesh.new()

var debug_box_ins: MeshInstance3D = MeshInstance3D.new()
var debug_box_mat: StandardMaterial3D = StandardMaterial3D.new()
var debug_mesh: BoxMesh = BoxMesh.new()

var green_mat = StandardMaterial3D.new()

#hold all the refrences to the points meshes
var point_list: Array[MeshInstance3D] = []
#-----------------------------------------------#
func _ready() -> void:
	green_mat.albedo_color = Color.GREEN
	green_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

func prep_boundingBox() -> MeshInstance3D:
	var _bounding_box_meshInstance: MeshInstance3D = MeshInstance3D.new()
	var _bounding_box_material: StandardMaterial3D = StandardMaterial3D.new()
	var _bounding_box_mesh: BoxMesh = BoxMesh.new()
	
	_bounding_box_material.albedo_color = Color(1, 1, 0, 0.08)
	_bounding_box_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_bounding_box_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_bounding_box_mesh.material = _bounding_box_material
	_bounding_box_mesh.size = Vector3.ONE
	
	_bounding_box_meshInstance.mesh = _bounding_box_mesh
	
	return _bounding_box_meshInstance

func prep_insert_point() -> MeshInstance3D:
	debug_box_mat.albedo_color = Color.AQUA
	debug_mesh.size = Vector3(0.3, 0.3, 0.3)
	debug_mesh.material = debug_box_mat
	debug_box_ins.mesh = debug_mesh
	
	return debug_box_ins

func prep_debug_points() -> void:
	_point_mesh.size = Vector3(0.25, 0.25, 0.25)
	_point_material.albedo_color = Color.RED
	_point_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_point_material.disable_receive_shadows = true

func spawn_debug_point() -> MeshInstance3D:
	#if show_debug_nodes:
	var _point_meshInstance: MeshInstance3D = MeshInstance3D.new()
	
	_point_meshInstance.mesh = _point_mesh
	_point_meshInstance.material_override = _point_material
	
	point_list.append(_point_meshInstance)
	return _point_meshInstance

#this is ugly and stupid but it works
func set_visibility(is_visible: bool = true):
	if not point_list.is_empty():
		for mesh: MeshInstance3D in point_list:
			mesh.visible = is_visible
	else:
		if is_visible:
			push_warning("There are no points baked")

func clear_points() -> void:
	if not point_list.is_empty():
		for mesh: MeshInstance3D in point_list:
			mesh.queue_free()
