extends Node2D

const MAX_SCORE = 7
const MAX_MISTAKES = 2

@onready var score_icons = $ScoreIcons
@onready var mistake_icons = $MistakeIcons


# Variablen für die Tore, Farben und das Score-Label
@onready var red_gate = $RedGoal
@onready var green_gate = $GreenGoal
@onready var blue_gate = $BlueGoal
@onready var target_color_rect = $TargetColorRect
@onready var timer_label = $TimerLabel
@onready var countdown_label = $Countdown # Countdown-Label

var game_time: float = 10.0
var main_game_state: Dictionary # store the passed Game State

var gates = {}
var colors = ["red", "green", "blue"]
var target_color: String = ""
var score: int = 0
var mistakes: int = 0
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
	
	for i in range(MAX_SCORE):
		var icon = score_icons.get_child(i)
		icon.modulate = Color(0.5, 0.5, 0.5)
		
	for i in range(MAX_MISTAKES):
		var icon = mistake_icons.get_child(i)
		icon.modulate = Color(0.5, 0.5, 0.5)

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
	# Reset game state
	score = 0
	mistakes = 0
	update_score_icons()
	update_mistake_icons()
	
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
			print("Congrats! You successfully won the MiniGame.")
			win_game()
			
		else:
			lose_game()
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
		correct_choice()

	else:
		wrong_choice()
		
func correct_choice():
	score += 1
	update_score_icons()
	
func wrong_choice():
	mistakes += 1
	update_mistake_icons()
	if mistakes >= MAX_MISTAKES:
		lose_game()
		
func update_score_icons():
	for i in range(MAX_SCORE):
		var icon = score_icons.get_child(i)
		icon.modulate = Color(1, 1, 1) if i < score else Color(0.5, 0.5, 0.5)
		
func update_mistake_icons():
	for i in range(MAX_MISTAKES):
		var icon = mistake_icons.get_child(i)
		icon.modulate = Color(1, 1, 1) if i < mistakes else Color(0.5, 0.5, 0.5)
		
func win_game():
	timer.stop()
	
	var main_game_scene = preload("res://world.tscn").instantiate()
	main_game_scene.set("game_state", main_game_state)
	get_tree().root.add_child(main_game_scene)
	# get_tree().change_scene_to_file(main_game_scene)
	#var main_game_scene = preload("res://world.tscn").instantiate()
	#get_tree().root.add_child(main_game_scene)
	
	# restore saved state 
	var player = main_game_scene.get_node("Player")
	
	if player and player.has_method("restore_state"):
		player.restore_state(main_game_state)
	get_tree().change_scene_to_file("res://main_menu.tscn")
	queue_free()
	
func lose_game():
	timer.stop()
	get_tree().change_scene_to_file("res://game_over.tscn")


func set_game_state(state: Dictionary) -> void:
	main_game_state = state
	