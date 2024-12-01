# GameSettings.gd
extends Node

signal settings_changed

# Game settings
var mode: String = "Easy"
var music_enabled: bool = true
var sound_enabled: bool = true

# Default values for Easy mode
var velocity: float = 5.0
var acceleration_rate: float = 1.0
var is_paused = false
# Load settings on startup 
func _ready():
	load_settings()
	update_mode_settings() # Apply the loaded mode settings immediately
	
# Save settings to file
func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_on", music_enabled)
	config.set_value("audio", "sound_on", sound_enabled)
	config.set_value("gameplay", "mode", mode)
	config.save("user://settings.cfg")
	print("Settings saved: Music: ", music_enabled, ", Sound: ", sound_enabled) # Debug print statements
	emit_signal("settings_changed") # Notify listeners when settings change
	
# Load settigns from file
func load_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_enabled = config.get_value("audio", "music_on", true)
		sound_enabled = config.get_value("audio", "sound_on", true)
		mode = config.get_value("gameplay", "mode", "Easy")
		
func update_mode_settings():
	if mode == "Easy":
		velocity = 10.0
		acceleration_rate = 1.005
	elif mode == "Hard":
		velocity = 15.0
		acceleration_rate = 1.01
	print("Mode updated to: ", mode, " | Velocity: ", velocity, " | Acceleration Rate: ", acceleration_rate)  # Debug print
	emit_signal("settings_changed")  # Notify other scripts of the change
