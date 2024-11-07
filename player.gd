extends CharacterBody3D

const SIDE_SPEED = 500.0
const JUMP_FORCE = 13.0       
const GRAVITY = 50.0

@export var lane_width = 1.0
@export var max_lanes = 1
var current_lane = 0

@onready var animated_sprite = get_node("AnimatedSprite3D")
var game_over = false

# Define the obstacle collision layer (Layer 2)
const OBSTACLE_LAYER = 1 << 1  # Layers are zero-indexed (Layer 2)

# Score variables
var score_label: Label
var rows_passed = 0  # Tracks rows passed as a score
var terrain_distance_moved = 0.0  # Tracks terrain movement along the z-axis

# Countdown variables
var countdown_label: Label
var countdown_time = 3  # Countdown starts from 3
var can_move = false

func _ready():
	current_lane = 0
	update_position()
	animated_sprite.play("move")

	# Initialize score label
	score_label = Label.new()
	score_label.position = Vector2(10, 10)  # Position at the top-left corner
	score_label.text = "Score: 0"
	add_child(score_label)  # Add the score label to the scene      

	# Reference the existing countdown label in the scene
	countdown_label = get_node("StopWatch/Label")
	countdown_label = get_node("../StopWatch/Label")
	_update_countdown_position()  # Center the countdown label

	# Start countdown timer
	var countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0  # 1 second intervals
	countdown_timer.one_shot = false
	countdown_timer.connect("timeout", Callable(self, "_on_countdown_timeout"))
	add_child(countdown_timer)
	countdown_timer.start()

func _update_countdown_position() -> void:
	# Calculate the center of the viewport and position the label
	var screen_center = get_viewport().get_visible_rect().size / 2
	var label_size = countdown_label.get_minimum_size() / 2
	countdown_label.position = screen_center - label_size



func _on_countdown_timeout() -> void:
	if countdown_time > 1:
		countdown_time -= 1
		countdown_label.text = str(countdown_time)
	elif countdown_time == 1:
		countdown_time = 0
		countdown_label.text = "GO!"
		can_move = true  # Allow player to start moving

		# Enable movement in the TerrainController
		var terrain_controller = get_parent().get_node("TerrainController")  # Adjust the path as needed
		if terrain_controller:
			terrain_controller.can_move = true
	else:
		countdown_label.visible = false  # Hide countdown label once it's "GO!"

func _physics_process(_delta: float) -> void:
	# If the game is over or countdown hasn't finished, stop updating
	if game_over or not can_move:
		return

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
		animated_sprite.play("jump")  # Play jump animation while in the air
	else:
		# Reset Y velocity when on the floor and prepare for jump
		velocity.y = 0

		# Handle jump input when on the floor
		if Input.is_action_just_pressed("ui_accept"):  # "ui_accept" is the default for space
			velocity.y = JUMP_FORCE  # Apply jump force
			animated_sprite.play("jump")  # Play jump animation
		else:
			# Play "move" animation when grounded and not jumping
			animated_sprite.play("move")

	# Move the player using built-in velocity and detect collisions
	move_and_slide()

	# Track terrain movement and update score
	terrain_distance_moved += _delta * 20  # Replace with your terrain movement speed
	if terrain_distance_moved >= 1.0:  # Assuming 1 unit per row
		rows_passed += 1
		score_label.text = "Score: " + str(rows_passed)
		terrain_distance_moved = 0.0  # Reset for the next row

	# Check for collisions with obstacles
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		# Check if the collider is on the obstacle layer
		if collider.collision_layer & OBSTACLE_LAYER != 0:
			_handle_collision(collider)

# Function to update the player's position based on the current lane
func update_position():
	var target_x_position = current_lane * lane_width
	position.x = target_x_position

# Function to handle collisions
func _handle_collision(collider) -> void:
	game_over = true
	print("Game Over! Player collided with an obstacle:", collider.name)
	animated_sprite.stop()

	# Call a function to show the Game Over screen
	show_game_over_screen()

func show_game_over_screen() -> void:
	# Display Game Over message and close the game window
	print("Displaying Game Over Screen")
	get_tree().quit()  # This will close the game window
