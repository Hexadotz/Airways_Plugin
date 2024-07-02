@icon("res://addons/airways_plugin/icons/icon_navAgent.svg")
class_name AirAgent3D extends Node

##the navigation node this agent belongs to
@export var navNode: AirWays3D 
##The desired distance before a point is considered to be reached
@export var target_desired_distance: float = 5.0
@onready var parent: Node3D = owner

var target: Node3D:
	set(new_target):
		target = new_target
	get:
		return target

var navPath: PackedVector3Array = []
var navPathIndex: int = 0

signal target_reached
#--------------------------------------------------#
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	#if we have a target to go to, then go to him... fuck
	if target != null:
		pass

##Returns the next position in global coordinates that can be moved to
func get_next_point() -> Vector3:
	if navPathIndex < navPath.size():
		if parent.global_position.distance_to(navPath[navPathIndex]) < target_desired_distance:
			navPathIndex += 1
	else:
		emit_signal("target_reached")
	
	return navPath[navPathIndex]
