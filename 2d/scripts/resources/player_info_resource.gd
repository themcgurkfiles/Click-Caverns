extends Resource
class_name PlayerInfo

@export var damage: float = 1
@export var damage_mult: float = 1:
	set(value):
		damage_mult = max(1, value)

@export var mana: float = 100 
@export var treasure_range: float = 50

# Here's how encumbrance works: the max encumberance is 1.5 under the hood.
# It is multiplied to the speed of the nav npc, but the get() only returns 1 as max.
# Every enemy will subtract this value by some amount when on screen, and when it gets less than 1,
# that value starts to multiply the speed lower and lower until it reaches the floor of half speed (0.5).
@export var encumbrance: float = 1.5:
	set(value):
		encumbrance = max(0.5, value)
		encumbrance = min(1.5, encumbrance)
	get():
		if (encumbrance >= 1):
			return 1
		elif (encumbrance <= 0.5):
			return 0.5
		else:
			return encumbrance

func get_total_damage() -> float:
	return damage * damage_mult

func subtract_encumbrance(enemyWeight: float) -> void:
	encumbrance -= enemyWeight
