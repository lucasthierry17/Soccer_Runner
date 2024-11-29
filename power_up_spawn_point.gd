extends Node3D

var power_up_scene: PackedScene = preload('res://power_ups.tscn')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.power_up_available:
		var power_up = power_up_scene.instantiate()
		add_child(power_up)
		power_up.position.y += 1
		Global.power_up_available = false
		print('Created new power up')
