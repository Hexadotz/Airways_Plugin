@tool
extends EditorPlugin

const airWay3D_node = preload("res://addons/airways_plugin/Airway3D.gd")
const gizmo_handle_scene = preload("res://addons/airways_plugin/gizmo_script.gd")

var gizmo_handle = gizmo_handle_scene.new()
var air_node_ref: WeakRef = weakref(null) # the reference to the air node in the scene
var editor_UI: Control = null

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	editor_UI = _create_Airways_control()
	
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, editor_UI)
	add_custom_type("AirWays3D", "MeshInstance3D", preload("res://addons/airways_plugin/Airway3D.gd"), preload("res://icon.svg"))
	add_node_3d_gizmo_plugin(gizmo_handle)
	
	_make_visible(false)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	if editor_UI:
		remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, editor_UI)
		editor_UI.queue_free()
	else:
		push_error("Couldn't find the editor UI when exiting the tree")
	
	remove_node_3d_gizmo_plugin(gizmo_handle)
	remove_custom_type("AirWays3D")

func _handles(object: Object) -> bool:
	return object is AirWays3D

func _edit(object: Object) -> void:
	air_node_ref = weakref(object)

func _get_plugin_name() -> String:
	return "AirWays3D"

func _make_visible(visible: bool) -> void:
	if editor_UI:
		editor_UI.set_visible(visible)
#-----------------------------------------------------#
func set_control_disabled(visible: bool) -> void:
	if not editor_UI:
		return
	
	for child in editor_UI.get_children():
		if child is Button:
			child.set_disabled(visible)

#creating a UI in the viewport editor, it's just a button for now
func _create_Airways_control() -> HBoxContainer:
	var Vert_sep: VSeparator = VSeparator.new()
	
	var build_btn: Button = Button.new()
	build_btn.text = "Build Navigation Area"
	build_btn.icon = preload("res://addons/airways_plugin/icons/build.svg")
	build_btn.flat = true
	build_btn.connect("pressed", Callable(self, "_on_build_button_pressed"))
	
	var clear_btn: Button = Button.new()
	clear_btn.text = "Clear Navigation Area"
	clear_btn.icon = preload("res://addons/airways_plugin/icons/Clear.svg")
	clear_btn.flat = true
	clear_btn.connect("pressed", Callable(self, "_on_clear_button_pressed"))
	
	var container: HBoxContainer = HBoxContainer.new()
	container.add_child(build_btn)
	container.add_child(Vert_sep)
	container.add_child(clear_btn)
	
	return container

func _on_build_button_pressed() -> void:
	#_set_control_disabled(true) #disable the user from spamming the button after pressing it
	var air_node = air_node_ref.get_ref()
	#if there's no airway nodes in the scene don't bother
	if not air_node is AirWays3D:
		push_error("Couldn't find an air node in scene")
		return
	
	air_node._spawn_points()

func _on_clear_button_pressed() -> void:
	var air_node = air_node_ref.get_ref()
	#if there's no airway nodes in the scene don't bother
	if not air_node is AirWays3D:
		push_error("Couldn't find an air node in scene")
		return
	
	air_node._clear_debg_points()
