extends Node3D
class_name TerrainController

## Holds the catalog of loaded terrain block scenes
var TerrainBlocks: Array = []
## The set of terrain blocks which are currently rendered to viewport
var terrain_belt: Array[MeshInstance3D] = []
@export var terrain_velocity: float = 10.0  # Should be faster than player's speed to simulate movement
@export var num_terrain_blocks = 3
@export var lane_width: float = 1.0 # Define the lane of each lane
## Delay before blocks appear (in seconds)
@export var start_delay: float = 3.0
@export_dir var terrian_blocks_path = "res://terrain_blocks"
var can_move: bool = false

@export var left_wall: StaticBody3D  # Reference the left wall in the scene
@export var right_wall: StaticBody3D  # Reference the right wall in the scene

@export var player: Node3D


func _ready() -> void:
	_load_terrain_scenes(terrian_blocks_path)
	_init_blocks(num_terrain_blocks)
	# Create a timer to delay the start of the movement
	var delay_timer = Timer.new()
	delay_timer.wait_time = start_delay
	delay_timer.one_shot = true
	delay_timer.connect("timeout", Callable(self, "_on_delay_finished"))
	add_child(delay_timer)
	delay_timer.start()

func _physics_process(delta: float) -> void:
	if can_move:
		_progress_terrain(delta)
		
	var player_z = player.position.z
	
	# Set the walls to the player's z position
	left_wall.position = Vector3(-2 * lane_width, left_wall.position.y, player_z)
	right_wall.position = Vector3(2 * lane_width, right_wall.position.y, player_z)


## Called when the timer finishes and the terrain should start moving
func _on_delay_finished() -> void:
	can_move = true

func _init_blocks(number_of_blocks: int) -> void:
	for block_index in range(number_of_blocks):
		var block = TerrainBlocks.pick_random().instantiate()
		if block_index == 0:
			block.position.z = block.get_mesh().get_size().y/2
		else:
			_append_to_far_edge(terrain_belt[block_index-1], block)
		add_child(block)
		terrain_belt.append(block)


func _progress_terrain(delta: float) -> void:
	for block in terrain_belt:
		block.position.z += terrain_velocity * delta
		
	# If the first block has moved far enough, replace it
	if terrain_belt[0].position.z >= terrain_belt[0].get_mesh().get_size().y/2:
		var last_terrain = terrain_belt[-1]
		var first_terrain = terrain_belt.pop_front()

		var block = TerrainBlocks.pick_random().instantiate()
		_append_to_far_edge(last_terrain, block)
		add_child(block)
		terrain_belt.append(block)
		first_terrain.queue_free()

func _append_to_far_edge(target_block: MeshInstance3D, appending_block: MeshInstance3D) -> void:
	# Randomly select a lane: -1 (left), 0 (middle), 1 (right)
	var lane = randi() % 3 - 1
	
	# Set the X position of the block based on the lane (left, middle, or right)
	appending_block.position.x = lane * lane_width
	
	# Set the Z position to continue the conveyor movement
	appending_block.position.z = target_block.position.z - target_block.get_mesh().get_size().y/2 - appending_block.get_mesh().get_size().y/2
	
	# Optional: Adjust the block scale to fit within the lane
	# You can modify the scale if necessary to ensure blocks don't overlap between lane
	var block_scale = lane_width * 0.9  # Make the block a little smaller than the lane width
	appending_block.scale = Vector3(block_scale, appending_block.scale.y, appending_block.scale.z)



func _load_terrain_scenes(target_path: String) -> void:
	var dir = DirAccess.open(target_path)
	for scene_path in dir.get_files():
		print("Loading terrain block scene: " + target_path + "/" + scene_path)
		TerrainBlocks.append(load(target_path + "/" + scene_path))
