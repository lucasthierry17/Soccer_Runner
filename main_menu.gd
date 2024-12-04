class_name MainMenu
extends Control

@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/Play as Button
@onready var settings_button = $MarginContainer/HBoxContainer/VBoxContainer/Settings as Button  # Settings button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Quit as Button
@onready var start_game = preload("res://world.tscn") as PackedScene
@onready var settings_scene = preload("res://Settings.tscn") as PackedScene  # Preload settings scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.button_down.connect(on_start_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	settings_button.button_down.connect(on_settings_pressed)  # Connect settings button
	pass

func on_start_pressed() -> void:
	save_current_score(0)
	get_tree().change_scene_to_packed(start_game)

func on_settings_pressed() -> void:
	get_tree().change_scene_to_packed(settings_scene)  # Switch to settings scene

func on_exit_pressed() -> void:
	get_tree().quit()
	
func save_current_score(score: int) -> void:
	var file = FileAccess.open("user://current_score.save", FileAccess.WRITE)
	file.store_32(score)
	file.close()
