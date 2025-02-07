extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@export var speed: float = 5
@export var slowdown: float = 1
@export var navRegion: NavigationRegion3D
@export var isLoop: bool = false

var exploreIndex: int
var posArray = []

var dungeonCleared: bool = false
var dungeonClearCount: int = 0

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("MovementNodes"):
		posArray.append(node.global_position)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Space"):
		_rand_move() # Demoted to dev tool, it's a sad life for rand move.

func _physics_process(_delta: float) -> void:
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	velocity = direction * (speed * slowdown);
	move_and_slide()
	
	if (destination - local_destination).length() > 0.1:  # To prevent jittering
		_rotate(local_destination)
	
	# 0.53 is the magic number for whatever reason, uncomment the following when next to node to see why:
	# var test = global_position.distance_to(navigation_agent_3d.get_final_position())
	# TODO: Check and make sure movement never gets stuck
	# First line (if...) here ensures movement from checkpoints, while second line (or...) initiates first move.
	if global_position.distance_to(navigation_agent_3d.get_final_position()) < 0.6 \
	or local_destination == navigation_agent_3d.get_final_position() and not local_destination:
		_sequence_move()

func _sequence_move():
	if exploreIndex < posArray.size():
		navigation_agent_3d.target_position = posArray[exploreIndex]
		exploreIndex += 1
	elif isLoop: # Particularly a debug / screensaver option for testing pathing stuff
		exploreIndex = 0
	else: # TODO: Add more logic for this at some point
		dungeonCleared = true

func _rand_move():
	# random_position = Vector3(randf_range(-15.0, 15.0), 0, randf_range(-5.0, 5.0))
	navigation_agent_3d.target_position = NavigationServer3D.region_get_random_point(navRegion, 1, false)

func _rotate(localDest: Vector3):
	# Fun rotation stuff that I'm sure that I understood when I wrote it
	var target_rotation = global_transform.basis.get_euler()
	target_rotation.y = atan2(localDest.x, localDest.z)
	global_transform.basis = Basis().rotated(Vector3.UP, 
		lerp_angle(global_transform.basis.get_euler().y, 
		target_rotation.y, 0.1))
