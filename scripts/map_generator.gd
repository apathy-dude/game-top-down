# TODO: Handle verical
# TODO: Separate mesh builder, collider builder, and mesh collider combiner out of generator into level_builder 

const SA_DIAG = 1
const SA_ADJ = 3
const SA_SELF = 6
const SA_SCORE = 9

static func get_wall_size(level, long_x):
	if long_x:
		return (level.width + 1) * level.depth * level.height
	else:
		return level.width * (level.depth + 1) * level.height

static func get_floor_size(level):
	return level.width * level.depth * level.height

static func get_floor_index(level, x, y, z):
	return y * level.depth * level.width + z * level.depth + x

static func get_wall_index(level, long_x, x, y, z):
	var val = 0
	if long_x:
		val = y * level.depth * (level.width + 1) + z * level.depth + x
	else:
		val = y * (level.depth + 1) * level.width + z * level.depth + x
	return val

static func combine_mesh_and_body(level):
	var total_materials = level.floor_materials.size() + level.wall_materials.size()
	for y in range(level.height):
		var body = level.static_body[y]
		var inc = total_materials * y

		for f in range(level.floor_materials.size()):
			body.add_child(level.mesh[inc + f])

		for w in range(level.wall_materials.size()):
			body.add_child(level.mesh[inc + w + level.floor_materials.size()])

		level.static_body[y] = body

	return level

static func build_wall_body(level, long_x, x, y, z):
	pass

static func build_static_body(level):
	level.static_body = []
	level.static_body.resize(level.height)

	for i in range(0, level.height):
		var body = StaticBody.new()
		var floor_shape = PlaneShape.new()
		var height = i * level.wall_height
		floor_shape.set_plane(Plane(Vector3(0, height, 0), Vector3(level.width, height, 0), Vector3(level.width, height, level.depth)))
		body.add_shape(floor_shape, Transform(Matrix3(Vector3(0, 0, 0), 0), Vector3(0, 0, 0)))

		# TODO: For each floor
		# TODO: Move each floor into seperate mesh_instance to allow for show & hide

		level.static_body[i] = body

	return level

static func build_floor_mesh(level, surf_tool, x, y, z):
	var tile_size = level.tile_size
	var x_off = x * tile_size
	var y_off = y * level.wall_height
	var z_off = z * tile_size

	var uv_x = 0
	var uv_z = 0

	if x % 2 == 0: 
		uv_x = 0.5

	if z % 2 == 0:
		uv_z = 0.5

	var vec = [
		Vector3(x_off, y_off, z_off),
		Vector3(x_off + tile_size, y_off, z_off),
		Vector3(x_off, y_off, z_off + tile_size),
		Vector3(x_off + tile_size, y_off, z_off + tile_size)
	]

	var uv = [
		Vector2(uv_x, uv_z),
		Vector2(uv_x + 0.5, uv_z),
		Vector2(uv_x, uv_z + 0.5),
		Vector2(uv_x + 0.5, uv_z + 0.5)
	]

	for i in [0, 1, 2]:
		surf_tool.add_uv(uv[i])
		surf_tool.add_vertex(vec[i])

	for i in [3, 2, 1]:
		surf_tool.add_uv(uv[i])
		surf_tool.add_vertex(vec[i])

static func build_wall_mesh(level, surf_tool, long_x, x, y, z):
	var add_x = 0
	var add_y = level.wall_height
	var add_z = 0

	if long_x:
		add_x = level.tile_size
	else:
		add_z = level.tile_size

	var x_off = x * level.tile_size
	var y_off = y * level.wall_height
	var z_off = z * level.tile_size

	var uv_x = 0
	var uv_z = 0

	if x % 2 == 0: 
		uv_x = 0.5

	if z % 2 == 0:
		uv_z = 0.5

	var vec = [
		Vector3(x_off, y_off, z_off),
		Vector3(x_off, y_off + add_y, z_off),
		Vector3(x_off + add_x, y_off, z_off + add_z),
		Vector3(x_off + add_x, y_off + add_y, z_off + add_z)
	]

	var uv = [
		Vector2(uv_x, uv_z), # 0 
		Vector2(uv_x, uv_z + 0.5), # 1
		Vector2(uv_x + 0.5, uv_z), # 2
		Vector2(uv_x + 0.5, uv_z + 0.5) # 3
	]

	for i in [0, 1, 2]:
		surf_tool.add_uv(uv[i])
		surf_tool.add_vertex(vec[i])

	for i in [3, 2, 1]:
		surf_tool.add_uv(uv[i])
		surf_tool.add_vertex(vec[i])

	for i in [2, 1, 0]:
		surf_tool.add_uv(uv[i])
		surf_tool.add_vertex(vec[i])

	for i in [1, 2, 3]:
		surf_tool.add_uv(uv[i])
		surf_tool.add_vertex(vec[i])

static func build_mesh(level):
	level.mesh = []
	level.mesh.resize(level.floor_materials.size() + level.wall_materials.size())

	var total_materials = level.floor_materials.size() + level.wall_materials.size()
	for y in range(level.height):
		var inc = total_materials * y

		for t in range(level.floor_materials.size()):
			var surf_tool = SurfaceTool.new()
			surf_tool.set_material(level.floor_materials[t])
			surf_tool.begin(VS.PRIMITIVE_TRIANGLES)

			for x in range(level.width):
				for z in range(level.depth):
					if level.level_floor[get_floor_index(level, x, y, z)] == t + 1:
						build_floor_mesh(level, surf_tool, x, y, z)

			surf_tool.generate_normals()
			surf_tool.index()

			var mesh_instance = MeshInstance.new()
			mesh_instance.set_mesh(surf_tool.commit())

			level.mesh[inc + t] = mesh_instance

		for t in range(level.wall_materials.size()):
			var surf_tool = SurfaceTool.new()
			surf_tool.set_material(level.wall_materials[t])
			surf_tool.begin(VS.PRIMITIVE_TRIANGLES)

			for z in range(level.depth):
				for x in range(level.width + 1):
					var idx = get_wall_index(level, false, x, y, z)
					var tile = level.level_wall_z[idx]
					if tile == t + 1:
						build_wall_mesh(level, surf_tool, false, x, y, z)

			for z in range(level.depth + 1):
				for x in range(level.width):
					var idx = get_wall_index(level, true, x, y, z)
					var tile = level.level_wall_x[idx]
					if tile == t + 1:
						build_wall_mesh(level, surf_tool, true, x, y, z)

			surf_tool.generate_normals()
			surf_tool.index()

			var mesh_instance = MeshInstance.new()
			mesh_instance.set_mesh(surf_tool.commit())

			level.mesh[inc + t + level.floor_materials.size()] = mesh_instance

	return level

static func gen_noise(level):
	var floor_size = get_floor_size(level)
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

static func gen_sa(level):
	var new_floor = IntArray()
	new_floor.resize(get_floor_size(level))

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
					score += SA_DIAG

				if level.level_floor[m+l] == 1:
					score += SA_ADJ

				if !bot && level.level_floor[d+l] == 1:
					score += SA_DIAG

			if !top && level.level_floor[u+c] == 1:
				score += SA_ADJ

			if level.level_floor[m+c] == 1:
				score += SA_SELF

			if !bot && level.level_floor[d+c] == 1:
				score += SA_ADJ

			if !rig:
				if !top && level.level_floor[u+r] == 1:
					score += SA_DIAG

				if level.level_floor[m+r] == 1:
					score += SA_ADJ

				if !bot && level.level_floor[d+r] == 1:
					score += SA_DIAG

			if score > SA_SCORE:
				new_floor[y * level.width + x] = 1
			else:
				new_floor[y * level.width + x] = 0

	level.level_floor = new_floor

	return level

static func gen_walls(level):
	var level_wall_x = IntArray()
	level_wall_x.resize(get_wall_size(level, true))

	var level_wall_z = IntArray()
	level_wall_z.resize(get_wall_size(level, false))

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

static func generate(level):
	if !level.has('level_floor'):
		level = gen_noise(level)
		level = gen_walls(level)
		return level

	level = gen_sa(level)
	level = gen_walls(level)
	return level
