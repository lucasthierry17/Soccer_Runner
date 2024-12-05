extends Node3D
class_name TerrainController

## Holds the catalog of loaded terrain block scenes
var TerrainBlocks: Array = []
## The set of terrain blocks which are currently rendered to viewport
var terrain_belt: Array[MeshInstance3D] = []
@export var terrain_velocity: float = 10.0  # Should be faster than player's speed to simulate movement
@export var num_terrain_blocks = 3
@export var lane_width: float = 1.0 # Define the lane of each lane
@export var terrain_blocks_path: String = "res://terrain_blocks"

var velocity_increase_rate: float = 1.005
# Variable to control movement
var can_move = false  # Only move when this is true

func _ready() -> void:
	# Load terrain settings from GameSettings
	terrain_velocity = GameSettings.velocity
	velocity_increase_rate = GameSettings.acceleration_rate
	
	TerrainBlocks.append(load("res://terrain_blocks/terrain_block_0.tscn"))
	TerrainBlocks.append(load("res://terrain_blocks/terrain_block_1.tscn"))
	TerrainBlocks.append(load("res://terrain_blocks/terrain_block_2.tscn"))
	TerrainBlocks.append(load("res://terrain_blocks/terrain_block_3.tscn"))
	_init_blocks(num_terrain_blocks)
	
func _physics_process(delta: float) -> void:
	# Only progress terrain if can_move is true
	if GameSettings.is_paused:
		return
	if can_move:
		_progress_terrain(delta)
		# Increase the terrain_velocity by 0.2% per second
		terrain_velocity *= pow(velocity_increase_rate, delta)

@onready var grass_texture = load("res://wiese_11.png")

func _init_blocks(number_of_blocks: int) -> void:
	if TerrainBlocks.is_empty():
		print("No terrain blocks loaded.")
		return

	var grass_material = StandardMaterial3D.new()
	grass_material.albedo_texture = grass_texture

	for block_index in range(number_of_blocks):
		var block = TerrainBlocks.pick_random().instantiate()

		# Apply grass material to the entire block and any child MeshInstances
		_apply_material_to_block(block, grass_material)

		# Set initial block position based on alignment
		if block_index == 0:
			block.position.z = 0  # Start exactly at the origin or initial position
		else:
			_append_to_far_edge(terrain_belt[block_index - 1], block)

		add_child(block)
		terrain_belt.append(block)

# Helper function to apply material to block and its children
func _apply_material_to_block(block, material):
	if block is MeshInstance3D:
		block.material_override = material
	elif block.get_child_count() > 0:
		for child in block.get_children():
			_apply_material_to_block(child, material)
func _progress_terrain(delta: float) -> void:
	for block in terrain_belt:
		block.position.z += terrain_velocity * delta

	if terrain_belt[0].position.z >= terrain_belt[0].get_mesh().get_size().y / 2:
		var last_terrain = terrain_belt[-1]
		var first_terrain = terrain_belt.pop_front()
		var block = TerrainBlocks.pick_random().instantiate()
		_append_to_far_edge(last_terrain, block)
		add_child(block)
		terrain_belt.append(block)
		first_terrain.queue_free()

func _append_to_far_edge(target_block: MeshInstance3D, appending_block: MeshInstance3D) -> void:
	# Set lane to 0 for consistent alignment
	var lane = 0

	# Set the X position of the block based on the lane (centered for alignment)
	appending_block.position.x = lane * lane_width

	# Use the `y` dimension as the depth since `z` isn't available in Vector2
	var target_block_depth = target_block.get_mesh().get_size().y
	var appending_block_depth = appending_block.get_mesh().get_size().y
	appending_block.position.z = target_block.position.z - (target_block_depth + appending_block_depth) / 2

func _load_terrain_scenes(target_path: String) -> void:
	var dir = DirAccess.open(target_path)
	if dir:
		dir.list_dir_begin()
		var scene_path = dir.get_next()
		while scene_path != "":
			# Ensure it's a .tscn file and not a directory
			if !dir.current_is_dir() and scene_path.ends_with(".tscn"):
				print("Loading terrain block scene: " + target_path + "/" + scene_path)
				var scene = load(target_path + "/" + scene_path)
				if scene:
					TerrainBlocks.append(scene)
				else:
					print("Failed to load scene at path: " + target_path + "/" + scene_path)
			scene_path = dir.get_next()
		dir.list_dir_end()
	else:
		print("Failed to open directory: " + target_path)
	
	# Debug output to verify scenes were load
	if TerrainBlocks.is_empty():
		print("No terrain blocks were loaded. Check the directory path or file format.")

#Power Ups
@export var player: CharacterBody3D
var power_up_scene: PackedScene = preload("res://power_ups.tscn")
@export var power_up_interval = 30  # Distance interval to spawn power-ups


var distance_traveled = 0  # Track the distance covered by the player

# Function to spawn the power-up
func spawn_power_up():
	if power_up_scene and player:
		var power_up_instance = power_up_scene.instantiate()  # Create a new instance
		add_child(power_up_instance)  # Add to the scene tree
		power_up_instance.global_transform.origin = calculate_spawn_position()  # Set spawn position
		#print('spawned power up: ', power_up_instance.global_position)

func _process(delta):
	# Update distance based on player's speed (adjust based on your implementation)
	distance_traveled += delta * terrain_velocity
	
	# Spawn a power-up every time the interval is reached
	if distance_traveled >= power_up_interval:
		spawn_power_up()
		distance_traveled = 0  # Reset distance for the next interval

# Function to calculate a logical spawn position ahead of the player
func calculate_spawn_position() -> Vector3:
	if player:
		var spawn_distance_ahead = 10.0  # Distance in front of the player
		var x_random_offset = randf_range(-lane_width, lane_width)  # Randomize x-position within range
		var y_position = 1.0  # Set desired height for the power-up
		var z_position = player.global_transform.origin.z + spawn_distance_ahead
		
		return Vector3(x_random_offset, y_position, z_position)
	else:
		return Vector3(0, 1.0, 0)  # Default position if player is not available
