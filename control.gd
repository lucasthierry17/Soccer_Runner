# Control.gd (attached to the Control node in control.tscn)
extends Control

# Path to the main game scene
@export var game_scene_path = "res://world.tscn"  # Adjust this to the path of your main game scene

func _ready():
	# Connect the Play button's "pressed" signal to the function that loads the main game
	var play_button = get_node("PlayButton")
	if play_button:
		play_button.connect("pressed", Callable(self, "_on_play_button_pressed"))
	else:
		print("Error: PlayButton not found in control.tscn.")

func _on_play_button_pressed():
	# Load and start the main game scene
	get_tree().change_scene_to_file(game_scene_path)
	
# Function to restore the game state after the minigame
func restore_game_state(state: Dictionary) -> void:
	var player = $Player  # Adjust the path if necessary
	if player:
		player.restore_state(state)
		print("Game state restored in control.gd!")
