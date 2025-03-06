extends Node

var player_data: PlayerInfo
@onready var hud = get_tree().get_first_node_in_group("HUD")


func _ready():
	load_or_create_player_info()
	
	# TODO: Make some sort of enemy manager and retrieve current encumbrance
	# so that it doesn't bug out and this line can be removed, which
	# CURRENTLY BREAKS THE ENCUMBRANCE SYSTEM, PLEASE DON'T FORGET!
	player_data.reset_encumbrance()
	
	# Uncomment line to delete and make a new player info:
	# revert_player_info()
	
	read_out_player_info()
	update_hud()

func revert_player_info():
	delete_player_info()
	load_or_create_player_info()

func _process(_delta: float) -> void:
	if (player_info.player_data.mana < 500): # TODO: At some point, we'll move this to an actual game manager 
		player_info.player_data.mana = round_to_dec(player_info.player_data.mana + 0.1, 1) # and delete the process from this script.
	update_hud()

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func read_out_player_info():
	if player_data:
		print("Total Damage: ", player_info.player_data.get_total_damage())
		print("Encumbrance: ", player_info.player_data.encumbrance)
		print("Mana: ", player_info.player_data.mana)
		print("Treasure: ", player_info.player_data.treasure)
		print("Treasure Range: ", player_info.player_data.treasure_range)

func update_hud():
	if player_data and hud:
		hud.update_mana(player_info.player_data.mana)
		hud.update_enc(player_info.player_data.encumbrance)
		hud.update_tre(player_info.player_data.treasure)
		hud.update_dmg(player_info.player_data.damage)
		hud.update_rad(player_info.player_data.treasure_range)
	else: # TODO: Possible temp solution here, attempt to fix this
		hud = get_tree().get_first_node_in_group("HUD")

func load_or_create_player_info():
	var save_path = "user://player_info.tres"
	
	if FileAccess.file_exists(save_path):
		player_data = ResourceLoader.load(save_path) as PlayerInfo
		print("Loaded existing PlayerInfo")
	else:
		player_data = PlayerInfo.new()
		save_player_info()  # Save default data
		print("Created new PlayerInfo")

func save_player_info():
	ResourceSaver.save(player_data, "user://player_info.tres")
	print("PlayerInfo Saved!")
	
func delete_player_info():
	DirAccess.remove_absolute("user://player_info.tres")
	print("PlayerInfo Deleted!")

# Saves player info on quit
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_player_info()
		get_tree().quit() # default behavior
