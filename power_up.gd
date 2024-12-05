extends Area3D
class_name PowerUp

@export_range(0,100) var stamina_value = 20  # Stamina value for this power-up
#@onready var animated_sprite = get_node("AnimatedSprite3D")

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is Player: 
		body.add_stamina(stamina_value)
		print('Stamina after power up pickup: ', body.current_stamina)
		queue_free()  # Remove power-up after collection
