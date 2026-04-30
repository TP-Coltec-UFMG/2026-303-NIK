class_name GeradorParede extends Node

@export var cena_parede : PackedScene;
var MIN_WALL : int = 10;
var MAX_WALL : int = 20 + 1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var larg = randi_range(MIN_WALL, MAX_WALL);
	var comp = randi_range(MIN_WALL, MAX_WALL);

	for i in range(larg):
		var parede = cena_parede.instantiate();
		add_child(parede);
		parede.rotation.y = 0.5 * PI;
		var parede_mesh_instance = parede.get_node("MeshInstance3D");
		var quad = parede_mesh_instance.mesh as QuadMesh;
		parede.position.x = i * quad.size.y;

	for j in range(comp):
		var parede = cena_parede.instantiate();
		add_child(parede);
		var parede_mesh_instance = parede.get_node("MeshInstance3D");
		var quad = parede_mesh_instance.mesh as QuadMesh;
		parede.position.z = j * quad.size.y;