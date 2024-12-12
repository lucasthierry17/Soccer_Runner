class_name Player
extends CharacterBody3D

#constants
const SIDE_SPEED = 500.0
const JUMP_FORCE = 13.0       
const GRAVITY = 50.0
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
var countdown_label: Label
var countdown_time = 3  # Countdown starts from 3
var can_move = false
var current_score: int
var high_score = 0
var is_paused # for the pause button
var game_state: Dictionary = {}
var score: int
var old_score: int
var rows_score: int
var times_died: int = 0


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
	old_score = load_current_score()
	
	if old_score == null:
		old_score = 0
		
	current_lane = 0
	update_position()
	animated_sprite.play("move")

	# Additional initialization for the game
	score_label = Label.new()
	score_label.position = Vector2(80, 80)  # Position at the top-left corner	
	score_label.text = "Score: " + str(old_score)
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

	countdown_label = get_node("../StopWatch/Label")
	_update_countdown_position()

	var countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.one_shot = false
	countdown_timer.connect("timeout", Callable(self, "_on_countdown_timeout"))
	add_child(countdown_timer)
	countdown_timer.start()
	
func _input(event):
	connect("pressed", Callable(self, "_on_pause_button_pressed"))
		
func toggle_pause():
	GameSettings.is_paused = !GameSettings.is_paused
	if GameSettings.is_paused:
		get_tree().paused = false  # Keep the scene running, but we'll manage pausing
		PauseMenu.visible = true
		animated_sprite.stop()
		can_move = false
		save_current_score(current_score)
		
	else:
		get_tree().paused = false
		PauseMenu.visible = false # disable the menu
		can_move = true # player can move again
		score_label.text = "Score: " + str(current_score)


func _on_music_toggle_changed(enabled: bool) -> void:
	if enabled:
		background_music.play()
		background_music.volume_db = 0
	else: 
		background_music.stop()
		background_music.volume_db = -80 # Mute it entirely
		
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
	
func save_current_score(score: int) -> void:
	var file = FileAccess.open("user://current_score.save", FileAccess.WRITE)
	file.store_32(score)
	file.close()
	
func load_current_score() -> int:
	var file = FileAccess.open("user://current_score.save", FileAccess.READ)
	if file:
		current_score = file.get_32()
		file.close()
	return current_score
	

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

func _physics_process(delta: float) -> void:
		# If the game is over or countdown hasn't finished, stop updating
	if game_over or not can_move or GameSettings.is_paused:
		stamina_bar.visible = false
		return
	
	else: 
		stamina_bar.visible = true

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
		current_score = rows_passed + old_score
		score_label.text = "Score: " + str(current_score)
		terrain_distance_moved = 0.0

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.collision_layer & OBSTACLE_LAYER != 0:
			_handle_collision(collider)
	
	if can_move:
		stamina_bar.visible = true
		deplete_stamina(delta)
		
	else:
		stamina_bar.visible = false

func start_lane_switch() -> void:
	target_x_position = current_lane * lane_width
	switch_time = 0.0
	is_switching = true

	# Notify the ball to switch to the same lane
	var ball = get_node("res://ball.tscn/RigidBody3D")  # Adjust the path if necessary
	if ball:
		ball.update_lane(current_lane)
		print("Player switched lane to:", current_lane)


func update_position():
	var target_x_position = current_lane * lane_width
	position.x = target_x_position
	switch_time = 0.0

func _handle_collision(collider) -> void:
	game_over = true
	can_move = false	
	if GameSettings.times_died == 0: 
		GameSettings.times_died += 1
		background_music.stop()
		pause_button.visible = false
		save_state()
		save_current_score(current_score)
		var minigame_scene = preload('res://MiniGame.tscn').instantiate()
		minigame_scene.set_game_state(self.game_state)
		get_tree().root.add_child(minigame_scene)
	
	else:
		show_game_over_screen()
		
	animated_sprite.stop()

func restore_state(saved_score: int) -> void:

	# Restore the score
	self.score = saved_score  # Update the current score variable
	
	score_label.text = "Score: " + str(current_score)
	update_position()
	game_over = false
	can_move = true
	animated_sprite.play("move")
	
func save_state() -> void:
	self.game_state = {
		"score": current_score
	}

func show_game_over_screen() -> void:
	var game_over_scene = preload("res://game_over.tscn").instantiate()
	if current_score > high_score:
		high_score = current_score
		save_high_score(high_score)
	game_over_scene.set_score(current_score)
	game_over_scene.high_score = high_score
	get_tree().root.add_child(game_over_scene)
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
	PauseMenu.visible = false
	get_tree().paused = false
	GameSettings.is_paused = false  # Ensure the game is unpaused before switching scenes
	
	if current_score > high_score:
		high_score = current_score
		save_high_score(current_score)  # Save the current score if needed
	show_game_over_screen()


# Stamina properties
@onready var stamina_bar: ProgressBar  = $UI/StaminaBar
@export var max_stamina = 100
var current_stamina = max_stamina
@export var stamina_depletion_rate = 3.0
@export var stamina_recovery_amount = 20  # Amount of stamina restored by power-up

# Function to reduce stamina
func deplete_stamina(delta):
	print(current_stamina)
	if current_stamina > 0:
		current_stamina -= stamina_depletion_rate * delta
		stamina_bar.value = current_stamina
	else:
		# If stamina is exhausted, limit movement or slow down character
		game_over = true  # Example action, adjust as needed
		print('Stamina ran out')
		show_game_over_screen()

# Function to increase stamina when power-up is collected
func add_stamina(stamina_value):
	print('stamina before: ', current_stamina)

	var stamina_recovered = stamina_value*0.01 * max_stamina
	current_stamina =  min(current_stamina + stamina_recovered, max_stamina)
	stamina_bar.value = current_stamina
