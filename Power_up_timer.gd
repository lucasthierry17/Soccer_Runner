extends Timer

func _ready():
	timeout.connect(_on_timeout)

func _on_timeout() -> void:
	Global.power_up_available = true
	print("Power up timed out")
