extends Node3D

var bottle_power_up_scene: PackedScene = preload('res://power_ups.tscn')
var banana_power_up_scene: PackedScene = preload('res://power_ups/banana_power_up.tscn')
var barrel_power_up_scene: PackedScene = preload('res://power_ups/barrel.tscn')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var rng = randi_range(1,3)
	
	var power_up_type
	
	match rng:
		1:
			power_up_type = bottle_power_up_scene
		2:
			power_up_type = banana_power_up_scene
		_:
			power_up_type = barrel_power_up_scene
	
	if Global.power_up_available:
		var power_up = power_up_type.instantiate()
		add_child(power_up)
		power_up.position.y += 1
		Global.power_up_available = false
		print('Created new power up')
