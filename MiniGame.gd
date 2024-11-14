extends Node2D

# Variablen für die Tore, Farben und das Score-Label
@onready var red_gate = $RedGoal
@onready var green_gate = $GreenGoal
@onready var blue_gate = $BlueGoal
@onready var target_color_label = $TargetColorLabel
@onready var score_label = $ScoreLabel  # Score-Label für die Anzeige des Scores

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
	
	# Initialisiere das Spiel mit der ersten Runde
	start_new_round()

	# Verbinde das Signal für jedes Tor mit der Funktion für die Erkennung von Klicks
	red_gate.connect("gui_input", Callable(self, "_on_Gate_pressed_red"))
	green_gate.connect("gui_input", Callable(self, "_on_Gate_pressed_green"))
	blue_gate.connect("gui_input", Callable(self, "_on_Gate_pressed_blue"))
	
	# Timer erstellen und konfigurieren
	timer = Timer.new()
	add_child(timer)  # Den Timer als Kind des aktuellen Nodes hinzufügen
	timer.wait_time = 1.0  # Jede Sekunde
	timer.one_shot = false  # Wiederholt sich
	timer.start()  # Timer starten

	# Starte das Spiel
	_start_game_loop()

# Startet eine neue Runde
func start_new_round():
	# Wähle zufällig eine der Farben und aktualisiere das Label
	target_color = colors[randi() % colors.size()]
	
	# Setze das Label auf die Ziel-Farbe
	match target_color:
		"red":
			target_color_label.text = "Red"
			target_color_label.modulate = Color(1, 0, 0)  # Rot
		"green":
			target_color_label.text = "Green"
			target_color_label.modulate = Color(0, 1, 0)  # Grün
		"blue":
			target_color_label.text = "Blue"
			target_color_label.modulate = Color(0, 0, 1)  # Blau

	# Setze die Textfarbe des Score-Labels auf Weiß, falls es unsichtbar ist
	score_label.modulate = Color(1, 1, 1)

# Event-Handler für Tore
func _on_Gate_pressed_red(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_check_gate("red")

func _on_Gate_pressed_green(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_check_gate("green")

func _on_Gate_pressed_blue(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_check_gate("blue")

# Prüft, ob die angeklickte Farbe korrekt ist
func _check_gate(gate_color: String) -> void:
	# Prüfen, ob die Farbe korrekt ist
	if gate_color == target_color:
		score += 1  # Erhöhe den Score bei richtiger Auswahl
		print("Correct! Score:", score)
		score_label.text = "Score: " + str(score)  # Score im Label aktualisieren
	else:
		print("Wrong!")

	# Starte eine neue Runde
	start_new_round()

# Startet die Hauptspiellogik und wartet mit `await` auf den Timer
func _start_game_loop():
	# Immer wieder eine neue Runde starten, nachdem der Timer abgelaufen ist
	while true:
		# Warten auf den Timeout des Timers (1 Sekunde)
		await timer.timeout
		start_new_round()
