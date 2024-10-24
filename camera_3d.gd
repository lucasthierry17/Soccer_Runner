extends Camera3D

# Reference to the player
@export var player: NodePath

func _ready():
	set_process(true)

func _process(delta: float):
	# Ensure camera follows the player's X position only
	var player_node = get_node(player)
	if player_node:
		# Adjust the camera position to follow the player's X position
		position.x = lerp(position.x, player_node.translation.x, 5 * delta)
