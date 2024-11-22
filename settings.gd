extends Control

@onready var easy_mode_button = $VBoxContainer/Mode_Easy as Button
@onready var hard_mode_button = $VBoxContainer/Mode_Hard as Button
@onready var music_toggle = $VBoxContainer/Music as CheckButton
@onready var sound_toggle = $VBoxContainer/Sounds as CheckButton
@onready var back_button = $VBoxContainer/Menu as Button

# Called when the node enters the scene tree
func _ready() -> void:
	# Connect buttons to functions
	back_button.button_down.connect(on_back_pressed)
	easy_mode_button.button_down.connect(on_easy_mode_selected)
	hard_mode_button.button_down.connect(on_hard_mode_selected)
	music_toggle.toggled.connect(on_music_toggle)
	sound_toggle.toggled.connect(on_sound_toggle)
	
	# Load existing settings
	music_toggle.set_pressed(GameSettings.music_enabled)  # Use set_pressed()
	sound_toggle.set_pressed(GameSettings.sound_enabled)  # Use set_pressed()

	# Set default mode highlighting
	update_mode_visuals()

func on_easy_mode_selected() -> void:
	GameSettings.mode = "Easy"
	GameSettings.update_mode_settings()
	update_mode_visuals()

func on_hard_mode_selected() -> void:
	GameSettings.mode = "Hard"
	GameSettings.update_mode_settings()
	update_mode_visuals()

func on_music_toggle(enabled: bool) -> void:
	GameSettings.music_enabled = enabled
	GameSettings.save_settings() # Save and emit signal

func on_sound_toggle(enabled: bool) -> void:
	GameSettings.sound_enabled = enabled
	GameSettings.save_settings() # Save and emit signal

func on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

# Updates the visual appearance of the mode buttons
func update_mode_visuals() -> void:
	if GameSettings.mode == "Easy":
		easy_mode_button.modulate = Color(1, 1, 1, 1)  # Fully visible
		hard_mode_button.modulate = Color(1, 1, 1, 0.5)  # Dimmed
	elif GameSettings.mode == "Hard":
		easy_mode_button.modulate = Color(1, 1, 1, 0.5)  # Dimmed
		hard_mode_button.modulate = Color(1, 1, 1, 1)  # Fully visible
		
