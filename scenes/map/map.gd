class_name MapController extends Node2D

var map_nodes : Array[MapNode]
var npc_particles : Array[NPCParticles]
@onready var nikole : Nikole = $Nikole

func _ready() -> void:
	for node in $Path/Nodes.get_children():
		map_nodes.append(node as MapNode)
	load_nodes_data()
	load_props_data()

	nikole.changed_node.connect(update_node_position)
	
	if GameManager.is_first_dialogue:
		nikole.position = Vector2(1318.0, -598.0)
		nikole.visible = false
		$AnimatedProps/VovoMaria.visible = false
	else:
		nikole.can_move = true 
		go_to_node(int(GameManager.get_game_data("map_position")))

	find_particles(self)

func update_node_position(map_node : MapNode):
	GameManager.set_game_data("map_position", int(map_nodes.find(map_node)))

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

func load_nodes_data():
	var i : int = 0
	var data : Dictionary = GameManager.get_game_data("nodes")
	for node in map_nodes:
		node.can_interact = not data[str(i)].is_empty()
		node.dialogue_id = data[str(i)]
		i += 1

	print("loaded all nodes data")

func load_props_data():
	var data : Dictionary = GameManager.get_game_data("props")
	for prop in data.keys():
		var prop_node = $AnimatedProps.get_node_or_null(prop)
		if prop_node:
			print(data)
			prop_node.position.x = data[prop].position.x
			prop_node.position.y = data[prop].position.y

	print("loaded all props data")

func find_particles(node : Node):
	for child in node.get_children():
		find_particles(child)
		if child is NPCParticles: npc_particles.append(child)