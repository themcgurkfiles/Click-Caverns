extends Area3D

@export var player: CharacterBody3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	player.position.x = position.x
	player.position.z = position.z
