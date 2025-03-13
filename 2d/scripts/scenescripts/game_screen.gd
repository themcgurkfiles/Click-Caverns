extends CanvasGroup

var sucking_node: Node2D = null
var is_sucking: bool = false
var objects_in_radius: Array = []

var force: float = 500
var radius: float = 500
var delete_radius: float = 20
var suck_grav_scale: float = 0.5

# Called when the scene is ready
func _ready():
	# Create the main suction node
	sucking_node = Node2D.new()
	add_child(sucking_node)
	
	# --- Suction Area ---
	var suction_area = Area2D.new()
	sucking_node.add_child(suction_area)
	
	var suction_collision = CollisionShape2D.new()
	suction_collision.shape = CircleShape2D.new()
	suction_collision.shape.radius = radius
	suction_area.add_child(suction_collision)

	suction_area.connect("body_entered", Callable(self, "_on_body_entered"))
	suction_area.connect("body_exited", Callable(self, "_on_body_exited"))

	# --- Delete Area ---
	var delete_area = Area2D.new()
	sucking_node.add_child(delete_area)

	var delete_collision = CollisionShape2D.new()
	delete_collision.shape = CircleShape2D.new()
	delete_collision.shape.radius = delete_radius
	delete_area.add_child(delete_collision)

	delete_area.connect("body_entered", Callable(self, "_on_body_deleted"))

# Detect mouse input
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_sucking = event.pressed  # Start or stop sucking
	elif event is InputEventMouseMotion and is_sucking:
		sucking_node.global_position = event.position  # Follows the mouse

# Only sucks up treasure components and adds them to radius
func _on_body_entered(body):
	if body is RigidBody2D and body not in objects_in_radius:
		if body.treasure_data is TreasureResource:
			objects_in_radius.append(body)

# Remove object from radius when exit
func _on_body_exited(body):
	objects_in_radius.erase(body)

# Delete object when it enters the small delete radius
func _on_body_deleted(body):
	if body in objects_in_radius and is_sucking and player_info.player_data.mana > 0 and body.treasure_data is TreasureResource:
		player_info.player_data.treasure += body.treasure_data.value
		objects_in_radius.erase(body)
		body.queue_free()

# Apply suction force continuously
func _process(_delta):
	if is_sucking:
		if player_info.player_data.mana > 0:
			player_info.player_data.mana -= 1
			print(player_info.player_data.mana)
			for body in objects_in_radius:
				if body is RigidBody2D:
					var direction = (sucking_node.global_position - body.global_position).normalized()
					body.apply_central_force((direction * force) / 0.8)
