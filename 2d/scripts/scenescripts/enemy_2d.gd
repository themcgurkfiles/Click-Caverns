extends CharacterBody2D
class_name BaseEnemy2D

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("Player")
@onready var timer:= $Timer

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
	print(player_info.player_data.encumbrance)

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
	# Get collider the smarty pants way
	var collision_size = $CollisionShape2D.shape.extents
	
	# Times 50 is remnant from a hack that didn't work well, kept it for nostalgia sake I guess
	var next_position = position + (direction * speed * _delta) # * 50
	
	_collide(next_position, collision_size)

func _movement_process_random(_delta: float) -> void: # Overrides passed direction variable
	if hasStopped:
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		timer.start()
		hasStopped = false
	var next_position = position + (direction * speed * _delta)
	var collision_size = $CollisionShape2D.shape.extents
	_collide(next_position, collision_size)
	
func _movement_process_random_launch(_delta: float) -> void:
	if hasStopped:
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		velocity = direction * speed
		timer.start()
		hasStopped = false
	velocity *= 0.98
	
	if velocity.length() < 5:
		velocity *= 0
		
	var next_position = position + (velocity * _delta)
	var collision_size = $CollisionShape2D.shape.extents
	_collide(next_position, collision_size)

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
		print(player_info.player_data.encumbrance)
		queue_free()
		return
	
	# Recovers back to normal size from OUCH! state
	if (!doesShrink): # If fails, the size won't go back to normal leading to gradually smaller enemies.
		tween = get_tree().create_tween()
		tween.tween_property(spriteAnim, "scale", ogScale, 0.05)

# We commit the bouncy here:
# KNOWN BUG: Resizing window can leave enemies "stuck" on the size of the screen (most apparent when speed = 1000)
# TODO: Investigate window resize stuff, especially for mobile and all the headaches that'll cause.
func _collide(next_position: Vector2, collision_size: Vector2) -> void:
	
	if next_position.x - collision_size.x / 2 <= screen_bounds.position.x or \
	next_position.x + collision_size.x / 2 >= screen_bounds.end.x:
		direction.x *= -1
		velocity.x *= -1
	if next_position.y - collision_size.y / 2 <= screen_bounds.position.y or \
	next_position.y + collision_size.y / 2 >= screen_bounds.end.y:
		direction.y *= -1
		velocity.y *= -1
		
	position = next_position
