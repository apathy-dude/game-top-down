# TODO: Handle verical

const CA_DIAG = 1
const CA_ADJ = 3
const CA_SELF = 6
const CA_SCORE = 9

static func gen_noise(level):
	var floor_size = level.get_floor_size()
	var level_floor = IntArray()
	level_floor.resize(floor_size)

	seed(level.level_seed)
	for idx in range(floor_size):
		var r = randf() > 0.5

		if(r):
			level_floor.set(idx, 1)
		else:
			level_floor.set(idx, 0)

	level.level_floor = level_floor
	return level

static func gen_cellular_automata(level):


	var new_floor = IntArray()
	new_floor.resize(level.get_floor_size())

	for x in range(level.width):
		for y in range(level.depth):
			var score = 0
			var top = y == 0
			var bot = y == level.depth - 1
			var lef = x == 0
			var rig = x == level.width - 1

			var u = (y - 1) * level.width
			var m = (y + 0) * level.width
			var d = (y + 1) * level.width

			var l = x - 1
			var c = x
			var r = x + 1

			if !lef:
				if !top && level.level_floor[u+l] == 1:
					score += CA_DIAG

				if level.level_floor[m+l] == 1:
					score += CA_ADJ

				if !bot && level.level_floor[d+l] == 1:
					score += CA_DIAG

			if !top && level.level_floor[u+c] == 1:
				score += CA_ADJ

			if level.level_floor[m+c] == 1:
				score += CA_SELF

			if !bot && level.level_floor[d+c] == 1:
				score += CA_ADJ

			if !rig:
				if !top && level.level_floor[u+r] == 1:
					score += CA_DIAG

				if level.level_floor[m+r] == 1:
					score += CA_ADJ

				if !bot && level.level_floor[d+r] == 1:
					score += CA_DIAG

			if score > CA_SCORE:
				new_floor[y * level.width + x] = 1
			else:
				new_floor[y * level.width + x] = 0

	level.level_floor = new_floor

	return level

static func gen_walls(level):
	var level_wall_x = IntArray()
	level_wall_x.resize(level.get_wall_size(true))

	var level_wall_z = IntArray()
	level_wall_z.resize(level.get_wall_size(false))

	for i in range(level_wall_x.size()):
		level_wall_x[i] = 0

	for i in range(level_wall_z.size()):
		level_wall_z[i] = 0

	for y in range(level.height):
		for z in range(level.depth):
			for x in range(level.width):
				var tile_idx = y * level.width * level.depth + z * level.depth + x
				var tile = level.level_floor[tile_idx]

				if tile == 0:
					continue

				# NEG X
				var wall_neg_x = y * level.width * (level.depth + 1) + z * level.depth + x
				if z == 0 || level.level_floor[tile_idx - level.width] == 0:
					level_wall_x[wall_neg_x] = 1

				# POS X
				var wall_pos_x = y * level.width * (level.depth + 1) + z * level.depth + x + level.width
				if z == level.width - 1 || level.level_floor[tile_idx + level.width] == 0:
					level_wall_x[wall_pos_x] = 1

				# NEG Z
				var wall_neg_z = y * (level.width + 1) * level.depth + z * level.depth + x
				if x == 0 || level.level_floor[tile_idx - 1] == 0:
					level_wall_z[wall_neg_z] = 1

				# POS Z
				var wall_pos_z = y * (level.width + 1) * level.depth + z * level.depth + x + 1
				if x == level.depth - 1 || level.level_floor[tile_idx + 1] == 0:
					level_wall_z[wall_pos_z] = 1

	level.level_wall_x = level_wall_x
	level.level_wall_z = level_wall_z

	return level
