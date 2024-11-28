extends Node2D

# Variablen für die Tore, Farben und das Score-Label
@onready var red_gate = $RedGoal
@onready var green_gate = $GreenGoal
@onready var blue_gate = $BlueGoal
@onready var target_color_rect = $TargetColorRect
@onready var score_label = $ScoreLabel  # Score-Label für die Anzeige des Scores
@onready var timer_label = $TimerLabel
@onready var countdown_label = $Countdown # Countdown-Label

var game_time: float = 10.0
var main_game_state: Dictionary # store the passed Game State

var gates = {}
var colors = ["red", "green", "blue"]
var target_color: String = ""
var score: int = 0
var timer: Timer


func _ready():
	# Speichere die Tore im Dictionary für den schnellen Zugriff
	gates = {
		"red": red_gate,
		"green": green_gate,
		"blue": blue_gate
	}

	# Verbinde das Signal für jedes Tor mit der Funktion für die Erkennung von Klicks
	red_gate.connect("input_event", Callable(self, "_on_Gate_pressed").bind("red"))
	green_gate.connect("input_event", Callable(self, "_on_Gate_pressed").bind("green"))
	blue_gate.connect("input_event", Callable(self, "_on_Gate_pressed").bind("blue"))

	# Timer erstellen und konfigurieren
	timer = Timer.new()
	add_child(timer)  # Den Timer als Kind des aktuellen Nodes hinzufügen
	timer.wait_time = 1.0  # Jede Sekunde
	timer.one_shot = false  # Wiederholt sich
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

	# Setze die Textfarbe des Score-Labels auf Weiß, falls es unsichtbar ist
	score_label.modulate = Color(1, 1, 1)

	# Countdown anzeigen und dann das Spiel starten
	await start_countdown()
	start_game()


func start_countdown() -> void:
	countdown_label.modulate = Color(0, 0, 0)
	var countdown_time = 3
	countdown_label.show()

	while countdown_time > 0:
		countdown_label.text = str(countdown_time)  # Update label text to show countdown
		await get_tree().create_timer(1.0).timeout  # Wait for 1 second
		countdown_time -= 1  # Decrease the countdown number

	countdown_label.text = "GO!"  # Display "GO!" after countdown ends
	await get_tree().create_timer(1.0).timeout  # Wait for 1 more second
	countdown_label.hide()  # Hide the label after displaying "GO!"


func start_game():
	# Timer starten
	timer.start()
	timer_label.text = "Time: " + str(game_time)
	
	# Starte das Spiel
	change_color()


# Wechselt die Farbe
func change_color():
	# Wähle zufällig eine der Farben und aktualisiere das Label
	target_color = colors[randi() % colors.size()]
	
	# Setze das Label auf die Ziel-Farbe
	match target_color:
		"red":
			target_color_rect.color = Color(1, 0, 0)  # Rot
		"green":
			target_color_rect.color = Color(0, 1, 0)  # Grün
		"blue":
			target_color_rect.color = Color(0, 0, 1)  # Blau


func _on_Timer_timeout():
	game_time -= 1
	if game_time <= 0:
		if score >= 7:
			timer.stop()
			print("Congrats! You successfully won the MiniGame.")
			# reload the main game with the saved state
			var main_game_scene = preload("res://world.tscn").instantiate()
			get_tree().root.add_child(main_game_scene)
			
			# restore saved state 
			var player = main_game_scene.get_node("Player")
			
			if player and player.has_method("restore_state"):
				player.restore_state(main_game_state)
			# get_tree().change_scene_to_file("res://main_menu.tscn")
			queue_free()
		else:
			timer.stop()
			print("Game Over!")
			get_tree().change_scene_to_file("res://game_over.tscn")
			queue_free()
	else:
		timer_label.text = "Time: " + str(game_time)
		
	change_color()


# Event-Handler für Tore
func _on_Gate_pressed(viewport: Object, event: InputEvent, shape_idx: int, gate_color: String):
	if event is InputEventMouseButton and event.pressed:
		_check_gate(gate_color)
		

# Prüft, ob die angeklickte Farbe korrekt ist
func _check_gate(gate_color: String) -> void:
	if gate_color == target_color:
		score += 1 # Erhöhe den Score bei richtiger Auswahl
		score_label.text = "Score: " + str(score) # Score im Label aktualisieren
		print("Correct! Score: ", score)
	else:
		print("Wrong!")
		timer.stop()
		print("Game Over! You clicked on the wrong goal.")
		get_tree().change_scene_to_file("res://game_over.tscn")
		

func set_game_state(state: Dictionary) -> void:
	main_game_state = state
