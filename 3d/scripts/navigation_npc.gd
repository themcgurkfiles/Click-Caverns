extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var navRegion: NavigationRegion3D = get_parent()
@export var speed: float = 5
@export var slowdown: float = 1
@export var isLoop: bool = false

var posArray = []

var exploreIndex: int
var dungeonClearCount: int = 0

var dungeonCleared: bool = false
var isRandomMove: bool = false

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("MovementNodes"):
		posArray.append(node.global_position)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Space"):
		_rand_move() # Demoted to dev tool, it's a sad life for rand move.

func _physics_process(_delta: float) -> void:
	# TODO: Check and make sure movement never gets stuck
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	velocity = direction * (speed * slowdown);
	move_and_slide()
	
	if (destination - local_destination).length() > 0.1:  # To prevent jittering
		_rotate(local_destination)
	
	# Ensures movement from checkpoint to checkpoint
	# 0.53 is the magic number for whatever reason, uncomment the following when next to node to see why:
	# var test = global_position.distance_to(navigation_agent_3d.get_final_position())
	if global_position.distance_to(navigation_agent_3d.get_final_position()) < 0.6:
		if not isRandomMove and not dungeonCleared:
			exploreIndex += 1
		_sequence_move()
	
	# Initiates move to first checkpoint
	if local_destination == navigation_agent_3d.get_final_position() and not local_destination:
		_sequence_move()

func _sequence_move():
	isRandomMove = false
	if exploreIndex < posArray.size():
		navigation_agent_3d.target_position = posArray[exploreIndex]
	elif isLoop: # Particularly a debug / screensaver option for testing pathing stuff
		exploreIndex = 0
		navigation_agent_3d.target_position = posArray[exploreIndex]
	else: # TODO: Add more logic for this at some point
		dungeonCleared = true
		get_tree().change_scene_to_file("res://3d/navigation_level.tscn")

func _rand_move():
	# random_position = Vector3(randf_range(-15.0, 15.0), 0, randf_range(-5.0, 5.0))
	isRandomMove = true
	navigation_agent_3d.target_position = NavigationServer3D.region_get_random_point(navRegion, 1, false)

func _rotate(localDest: Vector3):
	# Fun rotation stuff that I'm sure that I understood when I wrote it
	var target_rotation = global_transform.basis.get_euler()
	target_rotation.y = atan2(localDest.x, localDest.z)
	global_transform.basis = Basis().rotated(Vector3.UP, 
		lerp_angle(global_transform.basis.get_euler().y, 
		target_rotation.y, 0.1))
