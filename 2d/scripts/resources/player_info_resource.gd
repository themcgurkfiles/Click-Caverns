extends Resource
class_name PlayerInfo

@export var damage: float = 2
@export var damage_mult: float = 1:
	set(value):
		damage_mult = max(1, value)

@export var mana: float = 100

@export var treasure: float = 0
@export var treasure_range: float = 50

# Here's how encumbrance works:
# The max encumberance is 1.5 under the hood.
# It is multiplied to the speed of the nav npc, but the get() only returns 1 as max.
# Every enemy will subtract this value by some amount when on screen, and when it gets less than 1,
# that value starts to multiply the speed lower and lower until it reaches the floor of half speed (0.5).
@export var _encumbrance: float = 1.5  # Internal value

var encumbrance: float:
	get:
		if _encumbrance >= 1.0:
			return 1.0
		elif _encumbrance <= 0.1:
			return 0.1
		else:
			return _encumbrance

func get_total_damage() -> float:
	return damage * damage_mult

func subtract_encumbrance(enemyWeight: float) -> void:
	_encumbrance -= enemyWeight
