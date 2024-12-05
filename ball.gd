extends RigidBody3D

# Ball properties
@export var forward_speed: float = -5.0  # Speed of the ball moving away from the player
@export var backward_speed: float = 5.0  # Speed of the ball rolling back to the player
@export var resistance: float = 0.98  # Resistance applied during rolling away
@export var lane_width: float = 1.0  # Width of a lane
@export var min_distance: float = 2.0  # Closest distance the ball gets to the player
@export var max_distance: float = 10.0  # Farthest distance the ball gets from the player

# State tracking
var moving_toward_player: bool = true  # Determines if the ball is rolling toward the player
var current_lane: int = 0  # Tracks which lane the ball is in

func _ready():
	# Stelle sicher, dass der Ball vor dem Spieler startet
	global_transform.origin.z = -max_distance  # Positioniere den Ball weit genug vom Spieler
	linear_velocity = Vector3(0, 0, backward_speed)  # Startbewegung: Richtung Spieler
	gravity_scale = 1
	align_with_lane()
	print("Ball ready, rolling toward player.")

func _physics_process(delta: float) -> void:
	if moving_toward_player:
		# Ball rollt Richtung Spieler
		linear_velocity.z = backward_speed
		check_for_collision_or_switch()
	else:
		# Ball rollt weg vom Spieler
		linear_velocity.z = forward_speed
		check_for_collision_or_switch()

	# Simuliere Rotation und halte die Position des Balls auf der Spur
	rotate_ball(delta)
	align_with_lane()

	# Stelle sicher, dass der Ball auf dem Boden bleibt
	if global_transform.origin.y < 0:
		global_transform.origin.y = 0

func check_for_collision_or_switch() -> void:
	# Prüfe, ob der Ball nah genug am Spieler ist, um die Richtung zu ändern
	if moving_toward_player and global_transform.origin.z >= -min_distance:
		print("Ball reached the player. Switching direction to forward.")
		reverse_direction()
	elif not moving_toward_player and global_transform.origin.z <= -max_distance:
		print("Ball reached the farthest point. Switching direction to backward.")
		reverse_direction()

func reverse_direction() -> void:
	# Schalte die Bewegungsrichtung des Balls um
	moving_toward_player = not moving_toward_player
	if moving_toward_player:
		linear_velocity.z = backward_speed
		print("Ball direction reversed: Rolling toward player.")
	else:
		linear_velocity.z = forward_speed
		print("Ball direction reversed: Rolling away from player.")

func rotate_ball(delta: float) -> void:
	# Simuliere Rotation des Balls basierend auf der Bewegung
	var distance_moved = abs(linear_velocity.z * delta)
	var ball_radius = $CollisionShape3D.shape.radius
	var rotation_amount = distance_moved / ball_radius
	rotate(Vector3(1, 0, 0), rotation_amount)

func align_with_lane() -> void:
	# Halte den Ball in der Mitte der aktuellen Spur
	var target_x_position = current_lane * lane_width
	global_transform.origin.x = target_x_position
	print("Ball aligned with lane:", current_lane)

func update_lane(new_lane: int) -> void:
	# Aktualisiere die Spur des Balls, um sie der des Spielers anzupassen
	current_lane = new_lane
	align_with_lane()
	print("Ball lane updated to:", current_lane)
