extends Label

# Countdown start number
var countdown_time: int = 3

# Start the countdown when the node is ready
func _ready() -> void:
	# Start the countdown coroutine
	start_countdown()

# Coroutine function for countdown
func start_countdown() -> void:
	while countdown_time > 0:
		text = str(countdown_time)  # Update label text to show countdown
		await get_tree().create_timer(1.0).timeout  # Wait for 1 second
		countdown_time -= 1  # Decrease the countdown number

	text = "GO!"  # Display "GO!" after countdown ends
	await get_tree().create_timer(1.0).timeout  # Wait for 1 more second
	hide()  # Hide the label after displaying "GO!"
