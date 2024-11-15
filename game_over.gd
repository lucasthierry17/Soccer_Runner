class_name GameOver
extends Control

@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/PlayAgain as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Quit as Button
@onready var score_label = $MarginContainer/HBoxContainer/VBoxContainer/ScoreLabel as Label
@onready var high_score_label = $MarginContainer/HBoxContainer/VBoxContainer/HighScoreLabel as Label
@onready var start_game = preload("res://world.tscn") as PackedScene

var current_score: int = 0
var high_score: int = 0

func _ready() -> void:
	start_button.button_down.connect(on_start_pressed)
	exit_button.button_down.connect(on_exit_pressed)

	# Aktualisiere die Labels
	score_label.text = "Score: %d" % current_score
	high_score_label.text = "High Score: %d" % high_score

func set_score(score: int) -> void:
	current_score = score

func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_game)

func on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
