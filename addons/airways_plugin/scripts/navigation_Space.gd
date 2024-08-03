@icon("res://addons/airways_plugin/icons/icon_resource.svg")
class_name AirWaysNavigationSpace extends Resource
##A Resource used by [AirWays3D] that defines certain aspects of the navigation mesh.

##The size of the bounding box the nodes are going to spawn in. [br][b]NOTE:[/b] the size will snap acording to the cell size
@export var size: Vector3 = Vector3.ONE

##The distance between each node in the navigation area[br]
##[b]NOTE:[/b] it is highly recommended that you avoid values below 1 or floating values in general as they sometimes cause unexpected behaviour (in short i'm too lazy to account for floating values)
@export_range(0, 100, 0.1) var cell_size: float = 1 

##if [code]True[/code] the agent can travel both ways.[br][b]NOTE:[/b] need to to rebake the points after changing the value for it to take effect
@export var bidirectional: bool = true 

@export_subgroup("Collsion")
## @experimental
##[b]WIP Does not work currently... yet[/b] [br]The physics layer of the node scans the environment, allowing for the exclusion of specific objects that are not considered 'terrain' This feature ensures that the node avoids collisions with non-essential elements such as props within the level
##[br]For an example you don't want the node to consider object that are breakable or move to block node generation simply remove them from the layer
@export_flags_3d_physics var collision_mask 

##The agent size that will be used to cast a shape to check if the point location is valid or not (i.e wether it's inside geometry or not) 
@export var agent_size: Vector3 = Vector3(1, 1, 1)

#--------------------------------------------------------------#
@export_subgroup("misc")
@export var point_dict: Dictionary = {} ##the dictionary that will hold all of the points position along with their ids.[br][b]Don't fucking thouch this i'm already holding this whole plugin by glue and hope[/b]
