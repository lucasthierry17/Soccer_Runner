extends CharacterBody3D

# Player's side movement speed (left/right)
const SIDE_SPEED = 5.0
const JUMP_FORCE = 15.0  # Jump force
const GRAVITY = 50.0  # Gravity strength

# Lane width
@export var lane_width: float = 1.0
# Max lane boundaries (0 is middle, -1 is left, 1 is right)
@export var max_lanes: int = 1
# Current lane (0 = middle, -1 = left, 1 = right)
var current_lane: int = 0
var target_x_position: float = 0.0
var switch_duration: float = 0.3  # Duration of the lane switch
var switch_time: float = 0.0
var is_switching: bool = false  # Whether the player is currently switching lanes

# Easing function for smooth acceleration and deceleration
func ease_in_out_quad(t: float) -> float:
	if t < 0.5: 
		return 2 * t * t 
	else: 
		return -1 + (4 - 2 * t) * t

func _ready() -> void:
	# Initialize player in the middle lane
	current_lane = 0
	update_position()

func _physics_process(_delta: float) -> void:
	# Detect lane switching input
	if Input.is_action_just_pressed("ui_left") and current_lane > -max_lanes and not is_switching:
		current_lane -= 1
		start_lane_switch()
	elif Input.is_action_just_pressed("ui_right") and current_lane < max_lanes and not is_switching:
		current_lane += 1
		start_lane_switch()

	# Smooth lane transition using easing if switching lanes
	if is_switching:
		switch_time += _delta
		var t = min(switch_time / switch_duration, 1.0)  # Normalized time (0 to 1)
		position.x = lerp(position.x, target_x_position, ease_in_out_quad(t))
		
		# Check if switch is complete
		if t >= 1.0:
			is_switching = false  # Stop switching

	# Apply gravity when not on the floor
	if not is_on_floor():
		velocity.y -= GRAVITY * _delta  # Apply gravity while in the air
	else:
		# Reset Y velocity when on the floor and prepare for jump
		velocity.y = 0

		# Handle jump input when on the floor
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_FORCE # Apply jump force

	# Move the player using built-in velocity
	move_and_slide()

# function to start lane switch and initialize parameters
func start_lane_switch() -> void:
	target_x_position = current_lane * lane_width
	switch_time = 0.0  # Reset timer for each switch
	is_switching = true  # Set flag to indicate lane switching
	
# Function to update the player's target X position based on the current lane
func update_position() -> void:
	target_x_position = current_lane * lane_width
	switch_time = 0.0  # Reset timer for each switch
