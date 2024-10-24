extends CharacterBody3D

# Player's side movement speed (left/right)
const SIDE_SPEED = 500.0
# Lane width
@export var lane_width: float = 1.0
# Max lane boundaries (0 is middle, -1 is left, 1 is right)
@export var max_lanes: int = 1
# Current lane (0 = middle, -1 = left, 1 = right)
var current_lane: int = 0

func _ready() -> void:
	# Initialize player in the middle lane
	current_lane = 0
	update_position()

func _physics_process(_delta: float) -> void:
	# Detect lane switching input
	if Input.is_action_just_pressed("ui_left") and current_lane > -max_lanes:
		current_lane -= 1
		update_position()
	elif Input.is_action_just_pressed("ui_right") and current_lane < max_lanes:
		current_lane += 1
		update_position()

	# Side movement
	move_and_slide()

	# Collision detection (optional)
	var collision = get_last_slide_collision()
	if collision:
		print("Collided with: ", collision.get_collider())
		get_tree().quit()

# Function to update the player's position based on the current lane
func update_position() -> void:
	var target_x_position = current_lane * lane_width
	position.x = move_toward(position.x, target_x_position, SIDE_SPEED * get_process_delta_time())
