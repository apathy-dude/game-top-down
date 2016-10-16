extends MeshInstance

const NORTH = 0
const EAST = 1
const SOUTH = 2
const WEST = 3

var facing = 0

var map_pos = Vector3(0, 0, 0)
var desired_global_pos = Vector3(0, 0, 0)

var model = preload("res://models/human_male.msh")

var stats = {
	# max values
	max_health = 1,
	max_armour = 1,
	max_speed = 1.0,
	max_strength = 1,
	max_attack_range = 1,

	# current values
	health = 1,
	armour = 1,
	speed = 1.0,
	strength = 1,
	attack_range = 1
}

func is_moving():
	# TODO: Link to pathfinding
	var pos = self.get_translation()
	return desired_global_pos.x == pos.x && desired_global_pos.y == pos.y && desired_global_pos.z == pos.z

func set_move_target(level_tile_size, level_wall_height, pos):
	map_pos = pos
	desired_global_pos.x = pos.x * level_tile_size + (level_tile_size * 0.5)
	desired_global_pos.z = pos.z * level_tile_size + (level_tile_size * 0.5)
	desired_global_pos.y = pos.y * level_wall_height

func _fixed_process(delta):
	var start = self.get_transform().origin
	var end = desired_global_pos
	var dist = start.distance_squared_to(end)

	if dist == 0:
		pass

	var direction = (start - end).normalized()

	var pos = start - direction * delta * 10

	if dist < start.distance_squared_to(pos):
		set_translation(end)
	else:
		set_translation(pos)
		if pos != end:
			look_at(start, Vector3(0, 1, 0))

func _init(constraints):
	if constraints.has('model'):
		model = constraints.model

	if constraints.has('position'):
		map_pos = constraints.position
		desired_global_pos = constraints.position
		desired_global_pos.x += 0.5
		desired_global_pos.z += 0.5
		set_translation(desired_global_pos)
		pass

	set_mesh(model)
	set_fixed_process(true)
