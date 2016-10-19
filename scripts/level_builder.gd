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
					if level.level_floor[level.get_floor_index(x, y, z)] == t + 1:
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
					var idx = level.get_wall_index(false, x, y, z)
					var tile = level.level_wall_z[idx]
					if tile == t + 1:
						build_wall_mesh(level, surf_tool, false, x, y, z)

			for z in range(level.depth + 1):
				for x in range(level.width):
					var idx = level.get_wall_index(true, x, y, z)
					var tile = level.level_wall_x[idx]
					if tile == t + 1:
						build_wall_mesh(level, surf_tool, true, x, y, z)

			surf_tool.generate_normals()
			surf_tool.index()

			var mesh_instance = MeshInstance.new()
			mesh_instance.set_mesh(surf_tool.commit())

			level.mesh[inc + t + level.floor_materials.size()] = mesh_instance

	return level
