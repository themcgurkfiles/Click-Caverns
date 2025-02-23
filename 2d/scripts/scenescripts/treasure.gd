@tool
extends RigidBody2D

@export var treasure_data: TreasureResource:
	set(value):
		treasure_data = value
		update_sprite()

@onready var sprite: Sprite2D = $Sprite2D
@onready var polygon: Polygon2D = $Polygon2D
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D

func _ready():
	update_sprite()

# This being a tool script allows changes in the editor, so this stuff is actually visible.
func update_sprite():
	if treasure_data and sprite:
		sprite.texture = treasure_data.texture
		polygon.texture = treasure_data.texture

		if treasure_data.texture:
			var generated_polygon = generate_polygon_from_texture(treasure_data.texture)
			if generated_polygon:
				# Offset polygon so it's centered properly (maybe a better solution?)
				var texture_size = treasure_data.texture.get_size() / 2
				for i in range(generated_polygon.size()):
					generated_polygon[i] -= texture_size

				collision.polygon = generated_polygon

# Actually pretty cool thingy I scraped together
func generate_polygon_from_texture(texture: Texture2D) -> PackedVector2Array:
	if not texture:
		return PackedVector2Array()

	# Get image data from texture
	var image: Image = texture.get_image()
	image.convert(Image.FORMAT_LA8)  # Ensure it's grayscale (alpha channel)

	var points: PackedVector2Array = []
	var width = image.get_width()
	var height = image.get_height()

	# Scan image pixels and detect edge points (basic outline detection)
	for x in range(width):
		for y in range(height):
			if image.get_pixel(x, y).a > 0.1:  # Consider any visible pixel
				points.append(Vector2(x, y))

	# Convert points to a simplified polygon shape
	return convex_hull(points)

# Use Godot's built-in convex hull to simplify the polygon
func convex_hull(points: PackedVector2Array) -> PackedVector2Array:
	if points.size() < 3:
		return points  # Case: Not enough points to form a shape

	var hull = Geometry2D.convex_hull(points)
	return hull
