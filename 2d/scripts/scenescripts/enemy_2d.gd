extends CharacterBody2D
class_name BaseEnemy2D

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("Player")
@onready var timer:= $Timer
@onready var collision_size = $CollisionShape2D.shape.extents

@export var health: float = 5
@export var speed: float = 100
@export var weight: float = 0.1
@export var anim: String = "tboi-del-plum"
@export var doesShrink = false


var direction := Vector2(1, 1)
var screen_bounds: Rect2
var ogScale: Vector2
var hasStopped = true

func _ready() -> void:
	# Connect the timeout signal
	timer.connect("timeout", _on_Timer_timeout)  
	
	# VERY important bool for sprites being clicked on
	input_pickable = true
	
	# Animates the current enemy sprite
	var spriteAnim = $AnimatedSprite2D
	spriteAnim.play(anim)
	ogScale = spriteAnim.scale
	
	# Obtains screen bounds and stores them for use in da bouncy func
	get_viewport().connect("size_changed", _on_viewport_resized)
	_update_screen_bounds()
	
	# Lessens player encumbrance based on weight
	player_info.player_data.subtract_encumbrance(weight)
	# print(player_info.player_data.encumbrance)

func _update_screen_bounds() -> void:
	var viewport_rect = get_viewport_rect()
	screen_bounds = Rect2(Vector2.ZERO, viewport_rect.size)

func _on_viewport_resized() -> void:
	_update_screen_bounds()

func _on_Timer_timeout() -> void:
	hasStopped = true

func _process(_delta: float) -> void:
	_movement(_delta)

func _movement(_delta: float) -> void:
	_movement_process_diagonal(_delta)

func _movement_process_diagonal(_delta: float) -> void: # DVD Screensaver Moment
	velocity = direction * speed
	var collision = move_and_collide(velocity * _delta)
	if collision:
		direction = direction.bounce(collision.get_normal())  # Proper bounce
		velocity = direction * velocity.length()  # Maintain speed after bounce

func _movement_process_random(_delta: float) -> void: # Overrides passed direction variable
	if hasStopped:
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		timer.start()
		hasStopped = false
	
	velocity = direction * speed
	var collision = move_and_collide(velocity * _delta)
	if collision:
		direction = direction.bounce(collision.get_normal())  # Proper bounce
		velocity = direction * velocity.length()  # Maintain speed after bounce
	
func _movement_process_random_launch(_delta: float) -> void:
	if hasStopped:
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		velocity = direction * speed
		timer.start()
		hasStopped = false
	velocity *= 0.98
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var collision = move_and_collide(velocity * _delta)
	if collision:
		direction = direction.bounce(collision.get_normal())  # Proper bounce
		velocity = direction * velocity.length()  # Maintain speed after bounce

func _input_event(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("Click") and event.is_pressed():
		_take_damage()

func _take_damage() -> void:
	# Prevents clicking and doing stuff on death
	if (health <= 0):
		return
	# A bunch of tweeny nonsense coming up that I did my best with, coming right up!
	var spriteAnim = $AnimatedSprite2D
	var tween = get_tree().create_tween()
	# TODO: Test damage and make sure it works properly
	health -= player_info.player_data.get_total_damage()
	# On-Hit Shrink (OUCH!)
	if health >= 0:
		tween.tween_property(spriteAnim, "scale", spriteAnim.scale * 0.8, 0.05)
		await tween.finished
	# On-Death Events
	if health <= 0:
		# OH LAWD HE SHRINKIN
		tween = get_tree().create_tween()
		tween.tween_property(spriteAnim, "scale", spriteAnim.scale * 0.0, 0.15)
		# Cute post-mortem swirl
		var rotateTween = get_tree().create_tween()
		rotateTween.tween_property(self, "rotation_degrees", rotation_degrees + 180, 0.2)
		# Free us from this mortal coil
		await tween.finished
		await rotateTween.finished
		# Adds the enemy weight back to the player before deleting the enemy
		player_info.player_data.subtract_encumbrance(-weight)
		# print(player_info.player_data.encumbrance)
		queue_free()
		return
	
	# Recovers back to normal size from OUCH! state
	if (!doesShrink): # If fails, the size won't go back to normal leading to gradually smaller enemies.
		tween = get_tree().create_tween()
		tween.tween_property(spriteAnim, "scale", ogScale, 0.05)

# Experimental function (WIP)
func _return_collide_shape(delta: float) -> Rect2:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider_node = collision.get_collider() # Node
		var shape_idx = collision.get_collider_shape_index() # Shape index
		if collider_node is CollisionObject2D:
			var shape_owner_id = collider_node.shape_find_owner(shape_idx) # Shape owner id
			var shape = collider_node.shape_owner_get_shape(shape_owner_id, 0) # Assuming first shape
			if shape is RectangleShape2D:
				return Rect2(shape.get_rect().position, shape.get_rect().size)
	return Rect2()
