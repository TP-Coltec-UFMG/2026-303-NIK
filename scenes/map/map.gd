class_name MapController extends Node2D

var map_nodes : Array[MapNode]
@onready var nikole : Nikole = $Nikole

func _ready() -> void:
	for node in $Path/Nodes.get_children():
		map_nodes.append(node as MapNode)

	nikole.changed_node.connect(update_node_position)
	
	go_to_node(GameManager.get_game_data("map_position"))

func update_node_position(map_node : MapNode):
	GameManager.set_game_data("map_position", map_nodes.find(map_node))

func go_to_node(idx):
	var node = map_nodes[idx]
	var path = null
	if node.path_left != null:
		path = node.path_left
	elif node.path_right != null:
		path = node.path_right
	elif node.path_up != null:
		path = node.path_up
	elif node.path_down != null:
		path = node.path_down
		
	nikole.move_to_node(node, path, true)
