@icon("res://addons/airways_plugin/icons/icon_navAgent.svg")
extends Node

@export var navNode: AirWays3D 
@export var parent: Node3D

##The desired distance before a point is considered to be reached
@export var target_distance_threshold: float = 5.0

var navPath: PackedVector3Array = []
var navPathIndex: int = 0
signal target_reached
#--------------------------------------------------#
func get_next_point(target: Vector3) -> Vector3:
	navPath = navNode.find_path(parent.global_position, target)
	
	if navPathIndex < navPath.size():
		if parent.global_position.distance_to(target) < target_distance_threshold:
			navPathIndex += 1
	
	return Vector3.ZERO
