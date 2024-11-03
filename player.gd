extends CharacterBody3D

# Constants and variables
const SIDE_SPEED = 5.0
const JUMP_FORCE = 15.0
const GRAVITY = 50.0

@export var lane_width: float = 1.0
@export var max_lanes: int = 1
var current_lane: int = 0
var target_x_position: float = 0.0
var switch_duration: float = 0.3
var switch_time: float = 0.0
var is_switching: bool = false
var can_move: bool = false
var elapsed_time: float = 0.0

var terrain_distance_moved: float = 0.0  # Tracks terrain movement along z-axis

# Countdown and score variables
var countdown_label: Label
var score_label: Label
var rows_passed: int = 0  # Tracking rows passed

func _ready() -> void:
	current_lane = 0
	update_position()
	start_countdown()

	# Score label setup
	score_label = Label.new()
	score_label.position = Vector2(50, 50)  # Adjust to top-left
	score_label.text = "Score: 0"

	add_child(score_label)
	
	# Easing function for smooth acceleration and deceleration
func ease_in_out_quad(t: float) -> float:
	if t < 0.5: 
		return 2 * t * t 
	else: 
		return -1 + (4 - 2 * t) * t


func start_countdown() -> void:
	elapsed_time = 0.0
	can_move = false
	await get_tree().create_timer(3.0).timeout
	can_move = true


func _physics_process(_delta: float) -> void:
	if can_move:
		# Handle side movement and jumping as before
		if Input.is_action_just_pressed("ui_left") and current_lane > -max_lanes and not is_switching:
			current_lane -= 1
			start_lane_switch()
		elif Input.is_action_just_pressed("ui_right") and current_lane < max_lanes and not is_switching:
			current_lane += 1
			start_lane_switch() 
		
		# Track terrain movement and update score
		terrain_distance_moved += _delta * 20  # Replace with your terrain movement speed
		if terrain_distance_moved >= 1.0:  # Assuming 1 unit per row
			rows_passed += 1
			score_label.text = "Score: " + str(rows_passed)
			terrain_distance_moved = 0.0  # Reset for the next row
			
		if not is_on_floor():
			velocity.y -= GRAVITY * _delta
		else:
			velocity.y = 0
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_FORCE
	if is_switching:
		switch_time += _delta
		var t = min(switch_time / switch_duration, 1.0)
		position.x = lerp(position.x, target_x_position, ease_in_out_quad(t))
		if t >= 1.0:
			is_switching = false

	

	move_and_slide()
	update_score()  # Call to update the score

func update_score() -> void:
	# Check if terrain blocks have moved past the player and update the score
	for block in get_tree().get_nodes_in_group("terrain_blocks"):
		if block.translation.z < position.z:
			rows_passed += 1
			score_label.text = "Score: " + str(rows_passed)
			block.translation.z += 10  # Move the block to the front for an endless effect

func start_lane_switch() -> void:
	target_x_position = current_lane * lane_width
	switch_time = 0.0
	is_switching = true

func update_position() -> void:
	target_x_position = current_lane * lane_width
	switch_time = 0.0
