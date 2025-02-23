extends RigidBody2D

@export var treasure_data: TreasureResource
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if treasure_data:
		sprite.texture = treasure_data.texture
