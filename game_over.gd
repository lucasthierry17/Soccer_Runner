class_name GameOver
extends Control

@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/PlayAgain as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Quit as Button
@onready var score_button = $MarginContainer/HBoxContainer/VBoxContainer/ScoreButton as Button
@onready var high_score_button = $MarginContainer/HBoxContainer/VBoxContainer/HighScoreButton as Button

var current_score: int = 0
var high_score: int = 0

func _ready() -> void:
	
	GameSettings.connect("settings_changed", Callable(self, "_apply_settings"))
	GameSettings.times_died = 0
	
	start_button.button_down.connect(_on_start_pressed)
	exit_button.button_down.connect(_on_exit_pressed)

	# Zeige die Punktestände an
	score_button.text = "Score: %d" % current_score
	high_score_button.text = "High Score: %d" % high_score

	# Deaktiviere die Interaktivität der Score-Buttons
	score_button.disabled = true
	high_score_button.disabled = true

func set_score(score: int) -> void:
	self.current_score = score
	
func set_high_score(high_score: int) -> void:
	self.high_score = high_score
	high_score_button.text = "High Score: %d" % self.high_score

func _on_start_pressed() -> void:
	save_current_score(0)
	print("Restarting game...")
	self.hide()

	# Lade die Welt-Szene neu
	get_tree().change_scene_to_file("res://world.tscn")

func _on_exit_pressed() -> void:
	self.hide()
	# Gehe zurück ins Hauptmenü
	get_tree().change_scene_to_file("res://main_menu.tscn")
	print("Returning to main menu")

func save_current_score(score: int) -> void:
	var file = FileAccess.open("user://current_score.save", FileAccess.WRITE)
	file.store_32(score)
	file.close()
