extends Node

class_name Stopwatch

var time = 0.0

func _process(delta):
	time -= delta
	
func reset():
	time = 3.0
	
