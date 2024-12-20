extends CharacterBody3D

#constants
const SIDE_SPEED = 500.0
const JUMP_FORCE = 13.0       
const GRAVITY = 50.0
<<<<<<< HEAD

@export var lane_width = 1.0
@export var max_lanes = 1
var current_lane = 0

var target_x_position: float = 0.0
var switch_duration: float = 0.3
var switch_time: float = 0.0
var is_switching: bool = false

@onready var animated_sprite = get_node("AnimatedSprite3D")
@onready var jump_sound = $JumpSound as AudioStreamPlayer
@onready var death_sound = $DeathSound as AudioStreamPlayer
@onready var background_sound = $BackgroundMusic as AudioStreamPlayer


var game_over = false

var swipe_start_position: Vector2 = Vector2.ZERO
var swipe_threshold: float = 100.0
var jump_swipe_threshold: float = 100.0  # Higher value for clearer distinction
var jump_requested: bool = false  # Track jump requests

const OBSTACLE_LAYER = 1 << 1  # Layers are zero-indexed (Layer 2)

var score_label: Label
var rows_passed = 0  # Tracks rows passed as a score
var terrain_distance_moved = 0.0  # Tracks terrain movement along the z-axis

=======
const OBSTACLE_LAYER = 1 << 1  # Layers are zero-indexed (Layer 2)

# variables
@export var lane_width = 1.0
@export var max_lanes = 1
@onready var animated_sprite = get_node("AnimatedSprite3D")
@onready var PauseMenu = get_node("../PauseMenu") 
@onready var jump_sound = $JumpSound as AudioStreamPlayer
@onready var background_music = $BackgroundMusic as AudioStreamPlayer
@onready var countdownsound = $CountDownSound as AudioStreamPlayer


var pause_button
var current_lane = 0 # starting in the middle lane
var target_x_position: float = 0.0 
var switch_duration: float = 0.3 # duration of the switch from one lane to another
var switch_time: float = 0.0 # start of the switch time
var is_switching: bool = false # on when player is switching lanes
var game_over = false # if game is on or off
var swipe_start_position: Vector2 = Vector2.ZERO
var swipe_threshold: float = 100.0 
var jump_swipe_threshold: float = 100.0  # higher value for better distiction
var jump_requested: bool = false # to handle the jump
var score_label: Label
var rows_passed = 0  # Tracks rows passed as a score
var terrain_distance_moved = 0.0  # Tracks terrain movement along the z-axis
>>>>>>> pause
var countdown_label: Label
var countdown_time = 3  # Countdown starts from 3
var can_move = false
var current_score = 0
var high_score = 0


func ease_in_out_quad(t: float) -> float:
	if t < 0.5: 
		return 2 * t * t 
	else: 
		return -1 + (4 - 2 * t) * t

func _ready() -> void:
	# connect to GameSettings signals
	GameSettings.connect("settings_changed", Callable(self, "_apply_settings"))
	PauseMenu.visible = false
	_center_pause_menu()
	_apply_settings() # Apply initial settings
	
func _apply_settings():
	if GameSettings.music_enabled:
		$BackgroundMusic.play() # Assuming you have a MusicPlayer as a child 
	else: 
		background_music.volume_db = -80
		$BackgroundMusic.stop()
	if GameSettings.sound_enabled: 
		jump_sound.volume_db = 0
		countdownsound.volume_db = 0
	else: 
		jump_sound.volume_db = -80
		countdownsound.volume_db = -80
		
	high_score = load_high_score()
	current_lane = 0
	update_position()
	animated_sprite.play("move")

	# Additional initialization for the game
	score_label = Label.new()
<<<<<<< HEAD
	score_label.position = Vector2(80, 80)
	score_label.text = "Score: 0"
	score_label.scale = Vector2(3, 3)
	add_child(score_label)
=======
	score_label.position = Vector2(80, 80)  # Position at the top-left corner
	score_label.text = "Score: 0 "
	score_label.scale = Vector2(3, 3)
	add_child(score_label)  # Add the score label to the scene      
	
	pause_button = Button.new()
	pause_button.text = "||"
	pause_button.size = Vector2(100, 50)
	pause_button.position = Vector2(-200, 200)
	pause_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	PauseMenu.position = get_viewport().get_visible_rect().size / 2 - PauseMenu.size / 2
	
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	canvas_layer.add_child(pause_button)
	pause_button.connect("pressed", Callable(self, "_on_pause_button_pressed"))
>>>>>>> pause

	countdown_label = get_node("../StopWatch/Label")
	_update_countdown_position()

	var countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.one_shot = false
	countdown_timer.connect("timeout", Callable(self, "_on_countdown_timeout"))
	add_child(countdown_timer)
	countdown_timer.start()
<<<<<<< HEAD

=======
	# Lade den gespeicherten Highscore aus den Einstellungen
	score_label.text = "Score: 0  "
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		
func toggle_pause():
	GameSettings.is_paused = !GameSettings.is_paused
	if GameSettings.is_paused:
		# Manually stop game logic, but don't pause the entire scene tree
		get_tree().paused = false  # Keep the scene running, but we'll manage pausing
		PauseMenu.visible = true
		animated_sprite.stop()
		
		# Disable player movement and other game logic that should be paused
		can_move = false
		#game_over = true  # Stop any further gameplay logic

	else:
		# Resume gameplay
		PauseMenu.visible = false
		# Re-enable player movement and gameplay logic
		can_move = true
		game_over = false  # Allow gameplay to continue


func _on_music_toggle_changed(enabled: bool) -> void:
	if enabled:
		background_music.play()
		background_music.volume_db = 0
	else: 
		background_music.stop()
		background_music.volume_db = -80 # Mute it entirely
		
>>>>>>> pause
func load_high_score() -> int:
	var file = FileAccess.open("user://high_score.save", FileAccess.READ)
	if file:
		high_score = file.get_32()
		file.close()
	return high_score

func save_high_score(new_score: int) -> void:
	var file = FileAccess.open("user://high_score.save", FileAccess.WRITE)
	file.store_32(new_score)
	file.close()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			swipe_start_position = event.position
	elif event is InputEventScreenDrag:
		var swipe_end_position = event.position
		var swipe_distance = swipe_end_position - swipe_start_position

		if swipe_distance.length() > swipe_threshold:
			if abs(swipe_distance.x) > abs(swipe_distance.y):  
				if swipe_distance.x > 0 and current_lane < max_lanes and not is_switching:
					current_lane += 1
					start_lane_switch()
				elif swipe_distance.x < 0 and current_lane > -max_lanes and not is_switching:
					current_lane -= 1
					start_lane_switch()
			elif swipe_distance.y < -jump_swipe_threshold and is_on_floor():
				jump_requested = true

			swipe_start_position = swipe_end_position  # Reset swipe
	elif event is InputEventKey:
		if event.is_pressed():
			match event.keycode:
				KEY_RIGHT, KEY_D:
					if current_lane < max_lanes and not is_switching:
						current_lane += 1
						start_lane_switch()
				KEY_LEFT, KEY_A:
					if current_lane > -max_lanes and not is_switching:
						current_lane -= 1
						start_lane_switch()
				KEY_SPACE:
					if is_on_floor():
						jump_requested = true
						jump_sound.play()  # Play the jump sound

func _update_countdown_position() -> void:
	var screen_center = get_viewport().get_visible_rect().size / 2
	var label_size = countdown_label.get_minimum_size() / 2
	countdown_label.position = screen_center - label_size

func _on_countdown_timeout() -> void:
	if countdown_time > 1:
		if countdown_time == 3: 
			countdownsound.play()
		countdown_time -= 1
		countdown_label.text = str(countdown_time)
	elif countdown_time == 1:
		countdown_time = 0
		countdown_label.text = "GO!"
		can_move = true  # Allow player to start moving

		var terrain_controller = get_parent().get_node("TerrainController")
		if terrain_controller:
			terrain_controller.can_move = true
			background_music.play()
	else:
		countdown_label.visible = false

<<<<<<< HEAD
func _physics_process(delta: float) -> void:
	if game_over or not can_move:
=======
func _physics_process(_delta: float) -> void:
		# If the game is over or countdown hasn't finished, stop updating
	if game_over or not can_move or GameSettings.is_paused:
>>>>>>> pause
		return

	if is_switching:
		switch_time += delta
		var t = min(switch_time / switch_duration, 1.0)
		position.x = lerp(position.x, target_x_position, ease_in_out_quad(t))
		if t >= 1.0:
			is_switching = false

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
		animated_sprite.play("jump")
	else:
		velocity.y = 0
		if jump_requested:
			velocity.y = JUMP_FORCE
			jump_requested = false
			animated_sprite.play("jump")
		else:
			animated_sprite.play("move")

	move_and_slide()

	terrain_distance_moved += delta * 20
	if terrain_distance_moved >= 1.0:
		rows_passed += 1
		current_score = rows_passed
		score_label.text = "Score: " + str(current_score)
		terrain_distance_moved = 0.0

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.collision_layer & OBSTACLE_LAYER != 0:
			_handle_collision(collider)

func start_lane_switch() -> void:
	target_x_position = current_lane * lane_width
	switch_time = 0.0
	is_switching = true

	# Notify the ball to switch to the same lane
	var ball = get_node("Ball")  # Adjust the path if necessary
	if ball:
		ball.update_lane(current_lane)
		print("Player switched lane to:", current_lane)



func update_position():
	var target_x_position = current_lane * lane_width
	position.x = target_x_position
	switch_time = 0.0

func _handle_collision(collider) -> void:
<<<<<<< HEAD
	game_over = true
	print("Game Over! Player collided with an obstacle:", collider.name)
	animated_sprite.stop()
=======

	game_over = true
	print("Game Over! Player collided with an obstacle:", collider.name)
	animated_sprite.stop()
	# Call a function to show the Game Over screen
>>>>>>> pause
	show_game_over_screen()

func show_game_over_screen() -> void:
	var game_over_scene = preload("res://game_over.tscn").instantiate()
<<<<<<< HEAD
=======
	# Ensure high_score is updated before displaying the GameOver screen
>>>>>>> pause
	if current_score > high_score:
		high_score = current_score
		save_high_score(high_score)
	game_over_scene.set_score(current_score)
	game_over_scene.high_score = high_score
	get_tree().root.add_child(game_over_scene)
<<<<<<< HEAD
	queue_free()
=======
	queue_free()  # Remove the player from the scene
	
func _on_pause_button_pressed():
	GameSettings.is_paused = !GameSettings.is_paused # Toggle zwishcen pause und play
	get_tree().paused = GameSettings.is_paused
	PauseMenu.visible = GameSettings.is_paused
		
func _center_pause_menu():
	var viewport_size = get_viewport().get_visible_rect().size
	PauseMenu.position = (viewport_size - PauseMenu.size) / 2

func _on_resume_pressed() -> void:
	if GameSettings.is_paused:
		toggle_pause()  # Resume the game by toggling pause state
		PauseMenu.visible = false  # Hide the pause menu

func _on_quit_pressed():
	get_tree().paused = false  # Ensure the game is unpaused before switching scenes
	save_high_score(current_score)  # Save the current score if needed
	get_tree().change_scene_to_file("res://game_over.tscn")  # Load the Game Over scene
>>>>>>> pause
