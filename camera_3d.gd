extends Camera3D

# Reference to the player
@export var player: NodePath
var initial_x_position: float = 0.0

func _ready() -> void:
	fov = 50
	# Make initial adjustments for camera position and tilt
	position.y = 1.7  # Camera height
	position.z = 4.0
	rotation_degrees.x = -5.0  # Angle toward the player
	initial_x_position = position.x

func _process(delta: float) -> void:
	# Ensure player reference is valid
	var player_node = get_node_or_null(player)
	if player_node:
		# Follow only the player's z-axis movement
		position.z = lerp(position.z, player_node.translation.z - 5.0, 5 * delta)  # Distance behind player
		# Fix camera in the center of the x-axis
		position.x = initial_x_position
