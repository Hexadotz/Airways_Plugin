extends EditorNode3DGizmoPlugin


func _get_gizmo_name() -> String:
	return "Airways3D Handels"

func _has_gizmo(node: Node3D) -> bool:
	return node is AirWays3D

func _init() -> void:
	create_material("main", Color(1, 0, 0))
	create_handle_material("handles")

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	
	var node3d = gizmo.get_node_3d()
	var handles: PackedVector3Array = PackedVector3Array()
	
	#top_handel
	handles.push_back(Vector3(0, node3d._bounding_box.mesh.size.y / 2, 0))
	#side handel
	handles.push_back(Vector3(0, 0, node3d._bounding_box.mesh.size.z / 2))
	handles.push_back(Vector3(node3d._bounding_box.mesh.size.z / 2, 0, 0))
	
	gizmo.add_handles(handles, get_material("handles", gizmo), [0,1,2])

func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2) -> void:
	pass
