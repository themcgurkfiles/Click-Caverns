extends Area3D

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	player.position.x = position.x
	player.position.z = position.z
