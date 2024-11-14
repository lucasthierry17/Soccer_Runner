class_name MainMenu
extends Control
@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/Play as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Play2 as Button
@onready var start_game = preload("res://world.tscn") as PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.button_down.connect(on_start_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	pass # Replace with function body.

func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_game)

func on_exit_pressed() -> void:
	get_tree().quit()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
