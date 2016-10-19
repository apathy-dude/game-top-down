export(int) var level_seed = 0
export(int) var width = 1
export(int) var depth = 1
export(int) var height = 1
export(int) var wall_height = 3
export(int) var tile_size = 1
export var floor_materials = []
export var wall_materials = []
export var level_floor = IntArray()
export var level_wall_x = IntArray()
export var level_wall_z = IntArray()

export var mesh = []
export var static_body = []

func get_wall_size(long_x):
	if long_x:
		return (self.width + 1) * self.depth * self.height
	else:
		return self.width * (self.depth + 1) * self.height

func get_floor_size():
	return self.width * self.depth * self.height

func get_floor_index(x, y, z):
	return y * self.depth * self.width + z * self.depth + x

func get_wall_index(long_x, x, y, z):
	if long_x:
		return y * self.depth * (self.width + 1) + z * self.depth + x
	else:
		return y * (self.depth + 1) * self.width + z * self.depth + x

func combine_mesh_and_body():
	var total_materials = self.floor_materials.size() + self.wall_materials.size()
	for y in range(self.height):
		var body = self.static_body[y]
		var inc = total_materials * y

		for f in range(self.floor_materials.size()):
			body.add_child(self.mesh[inc + f])

		for w in range(self.wall_materials.size()):
			body.add_child(self.mesh[inc + w + self.floor_materials.size()])

		self.static_body[y] = body

func _init():
	pass
