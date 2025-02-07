extends Camera3D

@export var player: CharacterBody3D

func _process(_delta: float) -> void:
	if player:
		var target_rotation = player.global_rotation
		target_rotation.y += PI  # Offset rotation
		global_rotation.y = lerp_angle(global_rotation.y, target_rotation.y, 0.1)
