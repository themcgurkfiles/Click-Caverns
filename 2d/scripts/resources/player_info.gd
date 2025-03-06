extends Node

var player_data: PlayerInfo

func _ready():
	load_or_create_player_info()
	
	# TODO: Make some sort of enemy manager and retrieve current encumbrance
	# so that it doesn't bug out and this line can be removed, which
	# CURRENTLY BREAKS THE ENCUMBRANCE SYSTEM, PLEASE DON'T FORGET!
	player_data.reset_encumbrance()
	
	# Uncomment line to delete and make a new player info:
	#revert_player_info()
	
	read_out_player_info()
	set_hud_player_info()

func revert_player_info():
	delete_player_info()
	load_or_create_player_info()


func read_out_player_info():
	if player_data:
		print("Total Damage: ", player_info.player_data.get_total_damage())
		print("Encumbrance: ", player_info.player_data.encumbrance)
		print("Mana: ", player_info.player_data.mana)
		print("Treasure: ", player_info.player_data.treasure)
		print("Treasure Range: ", player_info.player_data.treasure_range)

func set_hud_player_info():
	var hud = get_tree().get_first_node_in_group("HUD")
	if player_data and hud:
			hud.update_mana(player_info.player_data.mana)
			hud.update_enc(player_info.player_data.encumbrance)
			hud.update_tre(player_info.player_data.treasure)
			hud.update_dmg(player_info.player_data.damage)
			hud.update_rad(player_info.player_data.treasure_range)

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
