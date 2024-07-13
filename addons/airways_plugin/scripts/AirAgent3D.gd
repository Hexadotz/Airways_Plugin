@icon("res://addons/airways_plugin/icons/icon_navAgent.svg")
class_name AirAgent3D extends Node

##the navigation node this agent belongs to
@onready var navNode: AirWays3D = owner.navMap
@onready var parent_position: Vector3 = owner.global_position

var target_desired_distance: float = 0.1

var target_position: Vector3:
	set(new_target_position):
		target_position = new_target_position
	get:
		return target_position

var navPath: PackedVector3Array = []
var navPathIndex: int = 0

signal target_reached()##emitted once the target reaches the final point
#--------------------------------------------------#
func _ready() -> void:
	#target_desired_distance = navNode.cell_size
	#print("SEXXX: ",target_desired_distance)
	await get_tree().create_timer(0.1).timeout
	navPath = navNode.find_path(parent_position, target_position)
	navPathIndex = 0
	print(navPath)

func _physics_process(delta: float) -> void:
	print(get_next_point())

func get_next_point() -> Vector3:
	#if we don't have a target to move to, push a warning
	if target_position == null:
		push_warning("There is no target point set")
		return parent_position
	else:
		#if the Airway node failed to return a path push an error
		if navPath.is_empty():
			push_error("Failed to return a valid path")
			return parent_position
		else:
			#if the index reached the end of an array, we have reached our target
			if navPathIndex >= navPath.size():
				emit_signal("target_reached")
				return parent_position
			else:
				#if we are very close to the next target increment to the next point
				var distance: float = abs(parent_position.distance_to(navPath[navPathIndex]))
				if distance < 0.1:
					navPathIndex += 1
					print("going to: ", navPath[navPathIndex])
				
				#this should always return t he next point regadless if we increment it or not
				#NOTE: it should work because 
				return navPath[navPathIndex + 1]

##Returns the next position in global coordinates that can be moved to
func get_next_point_test() -> Vector3:
	if target_position != null:
		#TODO: fix this shit
		
		if not navPath.is_empty():
			#print(navPathIndex)
			if navPathIndex < navPath.size():
				#if we are close enough, switch to the next point
				var distance: float = abs(parent_position.distance_to(navPath[navPathIndex]))
				
				if distance < target_desired_distance:
					print("going to next point ",navPath[navPathIndex],", distance is: ", distance)
					navPathIndex += 1
					
					return navPath[navPathIndex + 1]
					
				else:
					return navPath[navPathIndex + 1]
			else:
				emit_signal("target_reached")
				print("Target reached!")
				navPathIndex = 0
				
				return parent_position
		else:
			push_error("Failed to return a valid path")
			return parent_position
	else:
		push_warning("There is no target point set")
		navPathIndex = 0
	
		return parent_position


