extends CharacterBody3D

# Player's side movement speed (left/right)
const SIDE_SPEED = 500.0
const JUMP_FORCE = 15.0  # Jump force
const GRAVITY = 50.0  # Gravity strength

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

	# Apply gravity when not on the floor
	if not is_on_floor():
		velocity.y -= GRAVITY * _delta  # Apply gravity while in the air
	else:
		# Reset Y velocity when on the floor and prepare for jump
		velocity.y = 0

		# Handle jump input when on the floor
		if Input.is_action_just_pressed("ui_accept"):  # "ui_accept" is the default for space
			velocity.y = JUMP_FORCE  # Apply jump force

	# Move the player using built-in velocity
	move_and_slide()

# Function to update the player's position based on the current lane
func update_position() -> void:
	var target_x_position = current_lane * lane_width
	# Move smoothly towards the target lane
	position.x = move_toward(position.x, target_x_position, SIDE_SPEED * get_physics_process_delta_time())
