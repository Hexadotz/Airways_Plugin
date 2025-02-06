extends Node

var _point_material: StandardMaterial3D = StandardMaterial3D.new()
var _point_mesh: BoxMesh = BoxMesh.new()

var debug_box_ins: MeshInstance3D = MeshInstance3D.new()
var debug_box_mat: StandardMaterial3D = StandardMaterial3D.new()
var debug_mesh: BoxMesh = BoxMesh.new()

var green_mat = StandardMaterial3D.new()

#hold all the refrences to the points meshes
var point_list: Array[MeshInstance3D] = []
#---------------multimesh preperatin-----------#
var multiMesher: MultiMeshInstance3D = MultiMeshInstance3D.new()
var mesher: MultiMesh = MultiMesh.new()

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

func prep_debug_points() -> BoxMesh:
	_point_mesh.size = Vector3(0.25, 0.25, 0.25)
	_point_material.albedo_color = Color.RED
	_point_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_point_mesh.material = _point_material
	
	return _point_mesh

#---------------------------------------------------------------------#
func _update_MultiMesh(meshOrigin: Vector3, list: PackedVector3Array) -> MultiMesh:
	if mesher.instance_count > 0:
		mesher.instance_count = 0
	
	mesher.transform_format = MultiMesh.TRANSFORM_3D
	mesher.mesh = prep_debug_points()
	mesher.use_colors = true
	
	mesher.instance_count = list.size()
	
	for indx: int in list.size():
		var local_position: Vector3 = list[indx] - meshOrigin # convert those position to local
		mesher.set_instance_transform(indx, Transform3D(Basis(), local_position)) #NOTE: this is probably fucking things up
	
	return mesher 
