class_name MapNode extends Node2D

@export_group("Paths")
@export var path_up : Path2D
@export var path_left : Path2D
@export var path_right : Path2D
@export var path_down : Path2D

@export_group("Nodes")
@export var node_up : MapNode
@export var node_left : MapNode
@export var node_right : MapNode
@export var node_down : MapNode

@export_group("Interaction")
@export var dialogue_id : String
@export var can_interact : bool = false