extends BaseEnemy2D

@export var onHitSpeedMult = 2

var tookDamage = false

func _movement(_delta: float) -> void:
	if (tookDamage):
		if velocity.length() >= 5:
			_movement_process_random_launch(_delta)
		if velocity.length() < 5:
			tookDamage = false
	else:
		_movement_process_random(_delta)

func _take_damage() -> void:
	super()
	tookDamage = true
	speed *= onHitSpeedMult
