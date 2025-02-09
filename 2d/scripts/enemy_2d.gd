extends CharacterBody2D

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("Player")
@export var health: int = 5
@export var speed: float = 100
@export var anim: String = "tboi-del-plum"

var direction := Vector2(1, 1)
var screen_bounds: Rect2
var ogScale: Vector2

func _ready() -> void:
	# Obtains screen bounds and stores them for use in da bouncy func
	var viewport_rect = get_viewport_rect()
	screen_bounds = Rect2(Vector2.ZERO, viewport_rect.size)
	
	# VERY important bool for sprites being clicked on
	input_pickable = true
	
	# Animates the current enemy sprite
	var spriteAnim = $AnimatedSprite2D
	spriteAnim.play(anim)
	ogScale = spriteAnim.scale

func _process(_delta: float) -> void:
	_movement_process_diagonal(_delta)

func _movement_process_diagonal(_delta: float) -> void: # DVD Screensaver Moment
	# Get collider the smarty pants way
	var collision_size = $CollisionShape2D.shape.extents
	
	# Times 50 is remnant from a hack that didn't work well, kept it for nostalgia sake I guess
	var next_position = position + (direction * speed * _delta) # * 50
	
	# We commit the bouncy here
	# KNOWN BUG: Resizing window can leave enemies "stuck" on the size of the screen (most apparent when speed = 1000)
	# TODO: Investigate window resize stuff, especially for mobile and all the headaches that'll cause
	if next_position.x - collision_size.x / 2 <= screen_bounds.position.x or \
	next_position.x + collision_size.x / 2 >= screen_bounds.end.x:
		direction.x *= -1
	if next_position.y - collision_size.y / 2 <= screen_bounds.position.y or \
	next_position.y + collision_size.y / 2 >= screen_bounds.end.y:
		direction.y *= -1
		
	position = next_position

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
	
	# TODO: Change to be player dependant later
	health -= player.damage
	
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
		queue_free()
		return
	
	# Recovers back to normal size from OUCH! state
	tween = get_tree().create_tween()
	tween.tween_property(spriteAnim, "scale", ogScale, 0.05)
