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

# Load settings on startup 
func _ready():
	load_settings()
	
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
		mode = config.get_value("gameplay", "mode", "easy")
