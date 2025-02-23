extends Node

var player_data: PlayerInfo

func _ready():
	load_or_create_player_info()
	print("Total Damage:", player_info.player_data.get_total_damage())
	print("Encumbrance:", player_info.player_data.encumbrance)

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
	print("PlayerInfo saved!")
