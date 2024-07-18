@tool
extends EditorPlugin

const airWay3D_node = preload("res://addons/airways_plugin/scripts/Airway3D.gd")
const airAgent3D_node = preload("res://addons/airways_plugin/scripts/AirAgent3D.gd")
const gizmo_handle_scene = preload("res://addons/airways_plugin/gizmo_script.gd")

const node_icon: CompressedTexture2D = preload("res://addons/airways_plugin/icons/icon_AW.svg")
const agentIcon: CompressedTexture2D = preload("res://addons/airways_plugin/icons/icon_navAgent.svg")

var gizmo_handle = gizmo_handle_scene.new()
var air_node_ref: WeakRef = weakref(null) # the reference to the air node in the scene
var editor_UI: Control = null

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	editor_UI = _create_Airways_control()
	
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, editor_UI)
	add_custom_type("AirWays3D", "Node3D", airWay3D_node, node_icon)
	add_custom_type("AirAgent3D", "Node3D", airAgent3D_node, agentIcon)
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
	remove_custom_type("AirAgent3D")

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

var del_btn_ref: Button
var add_btn_ref: Button
var check_box_ref: CheckBox
#creating a UI in the viewport editor, it's just a button for now
func _create_Airways_control() -> HBoxContainer:
	var Vert_sepA: VSeparator = VSeparator.new()
	var Vert_sepB: VSeparator = VSeparator.new()
	
	var build_btn: Button = Button.new()
	build_btn.text = "Build Navigation Area"
	build_btn.icon = preload("res://addons/airways_plugin/icons/icon_build.svg")
	build_btn.tooltip_text = "Construct the navigation area by verifying that each node point is not obstructed by geometry."
	build_btn.flat = true
	build_btn.connect("pressed", Callable(self, "_on_build_button_pressed"))
	
	var clear_btn: Button = Button.new()
	clear_btn.text = "Clear Navigation Area"
	clear_btn.icon = preload("res://addons/airways_plugin/icons/icon_clear.svg")
	clear_btn.flat = true
	clear_btn.connect("pressed", Callable(self, "_on_clear_button_pressed"))
	
	var add_btn: Button = Button.new()
	add_btn.icon = preload("res://addons/airways_plugin/icons/icon_add.svg")
	add_btn.tooltip_text = "Include a new node within the selected region (WIP)."
	add_btn.toggle_mode = true
	add_btn.flat = true
	add_btn.connect("toggled", Callable(self, "_on_add_node_button_toggled"))
	add_btn_ref = add_btn
	
	var delete_btn: Button = Button.new()
	delete_btn.icon = preload("res://addons/airways_plugin/icons/icon_remove.svg")
	delete_btn.tooltip_text = "Remove a node from those currently in the region (WIP)."
	delete_btn.toggle_mode = true
	delete_btn.flat = true
	delete_btn.connect("toggled", Callable(self, "_on_delete_node_button_toggled"))
	del_btn_ref = delete_btn
	
	#NOTE: disabling these two for now until i get the camera ray to work
	add_btn.disabled = true 
	delete_btn.disabled = true
	
	var test_btn: Button = Button.new()
	test_btn.text = "test"
	test_btn.connect("pressed", Callable(self, "_on_test_btn_pressed"))
	
	var test_btn2: Button = Button.new()
	test_btn2.text = "test2"
	test_btn2.connect("pressed", Callable(self, "_on_test_btn2_pressed"))
	
	var options: OptionButton = OptionButton.new()
	options.add_item("option A")
	
	var visible_box: CheckBox = CheckBox.new()
	visible_box.text = "Visible point"
	visible_box.tooltip_text = "Toggle visibility of nodes in space."
	visible_box.button_pressed = true
	check_box_ref = visible_box
	visible_box.connect("pressed", Callable(self, "_on_visible_btn_pressed"))
	
	var container: HBoxContainer = HBoxContainer.new()
	container.add_child(build_btn)
	container.add_child(clear_btn)
	
	container.add_child(Vert_sepA)
	
	container.add_child(add_btn)
	container.add_child(delete_btn)
	
	container.add_child(Vert_sepB)
	
	container.add_child(visible_box)
	container.add_child(test_btn)
	container.add_child(test_btn2)
	#container.add_child(options)
	
	return container

func _apply_node_change(method: String, arg: Array = []) -> void:
	var air_node = air_node_ref.get_ref()
	#if there's no airway nodes in the scene don't bother
	if not air_node is AirWays3D:
		push_error("Couldn't find an air node in scene")
		return 
	
	if air_node.has_method(method):
		air_node.callv(method, arg)
	elif air_node.get(method) != null:
		air_node.set(method)
	else:
		push_error("Method/property does not exist")

func _on_build_button_pressed() -> void:
	#_set_control_disabled(true) #disable the user from spamming the button after pressing it
	_apply_node_change("_spawn_points")

func _on_clear_button_pressed() -> void:
	_apply_node_change("_clear_debg_points")

func _on_delete_node_button_toggled(toggled_on: bool) -> void:
	add_btn_ref.button_pressed = false
	_apply_node_change("toggled", [del_btn_ref.button_pressed])

func _on_add_node_button_toggled(toggled_on: bool) -> void:
	del_btn_ref.button_pressed = false
	_apply_node_change("toggled", [add_btn_ref.button_pressed])

func _on_visible_btn_pressed() -> void:
	_apply_node_change("_set_point_visible", [check_box_ref.button_pressed])

func _on_test_btn_pressed() -> void:
	_apply_node_change("test")

func _on_test_btn2_pressed() -> void:
	_apply_node_change("test2")
