extends BaseEnemy2D

var tookDamage = false
var delt: float

func _movement(_delta: float) -> void:
	_movement_process_random_launch(_delta)
	

func _take_damage() -> void:
	super()
	tookDamage = true
	hasStopped = true
	_movement_process_random_launch(delt)
