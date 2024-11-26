extends Node2D

# Variablen für die Tore, Farben und das Score-Label
@onready var red_gate = $RedGoal
@onready var green_gate = $GreenGoal
@onready var blue_gate = $BlueGoal
@onready var target_color_rect = $TargetColorRect
@onready var score_label = $ScoreLabel  # Score-Label für die Anzeige des Scores
@onready var timer_label = $TimerLabel

var game_time: float = 10.0

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
	timer.start()  # Timer starten
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

	# Setze die Textfarbe des Score-Labels auf Weiß, falls es unsichtbar ist
	score_label.modulate = Color(1, 1, 1)
	
	# Starte das Spiel
	change_color()
	
	timer_label.text = "Time: "+ str(game_time)
	
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
			get_tree().change_scene_to_file("res://main_menu.tscn")
		else:
			timer.stop()
			print("Game Over!")
			get_tree().change_scene_to_file("res://game_over.tscn")
			
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
