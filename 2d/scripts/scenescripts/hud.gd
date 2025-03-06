extends CanvasGroup
class_name HUD

@export var player_mana_label : Label
@export var player_enc_label : Label
@export var player_tre_label : Label
@export var player_dmg_label : Label
@export var player_rad_label : Label

func update_mana(number : float):
	player_mana_label.text = str(number)

func update_enc(number : float):
	player_enc_label.text = str(number)

func update_tre(number : float):
	player_tre_label.text = str(number)

func update_dmg(number : float):
	player_dmg_label.text = str(number)

func update_rad(number : float):
	player_rad_label.text = str(number)
