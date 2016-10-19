extends Node

export(Material) var floor_material = null
export(Material) var wall_material = null
export(Texture) var select_arrow_texture = preload("res://sprites/fast-arrow.png")

export var level_iterations = 6
export var level_seed = 1
export var level_width = 128
export var level_depth = 128
export var level_height = 1
export var wall_height = 3
export var tile_size = 1

var input_states = preload("res://scripts/button_state.gd")
var map_generator = preload("res://scripts/map_generator.gd")
var level_builder = preload("res://scripts/level_builder.gd")
var unit = preload("res://scripts/unit.gd")
var map = preload("res://scripts/level.gd")

var btn_refresh = input_states.new("refresh")

var select_sprite = null
var level = null
var units = []
var selected_unit_index = 0

var mouse_click = null
var mouse_pos = null
var mouse_tile = null

func _input(ev):
	if ev.type == InputEvent.KEY:
		mouse_tile = null

	if ev.type == InputEvent.MOUSE_MOTION:
		mouse_pos = ev.pos

	if ev.type==InputEvent.MOUSE_BUTTON && ev.pressed && ev.button_index==1:
		mouse_click = ev.pos

func _process(delta):
	pass

func _fixed_process(delta):
	if mouse_pos != null:
		var camera = get_node("Camera")
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * camera.get_zfar()

		var world = camera.get_world()
		var space_state = world.get_direct_space_state()
		var result = space_state.intersect_ray(camera.get_translation(), to).position

		var x = floor(result.x / level.tile_size)
		var z = floor(result.z / level.tile_size)
		var y = floor(result.y / level.wall_height)

		var idx = level.get_floor_index(x, y, z)
		var tile = 0

		if idx >= 0 && idx < level.level_floor.size():
			tile = level.level_floor[idx]

		if tile > 0:
			mouse_tile = Vector3(x + 0.5, y, z + 0.5)

		select_sprite.set_rotation(camera.get_rotation())

		mouse_pos = null

	if mouse_click != null:
		var camera = get_node("Camera")
		var from = camera.project_ray_origin(mouse_click)
		var to = from + camera.project_ray_normal(mouse_click) * camera.get_zfar()

		var world = camera.get_world()
		var space_state = world.get_direct_space_state()
		var result = space_state.intersect_ray(camera.get_translation(), to).position

		var x = floor(result.x / level.tile_size)
		var z = floor(result.z / level.tile_size)
		var y = floor(result.y / level.wall_height)
		
		var idx = level.get_floor_index(x, y, z)
		var tile = 0

		if idx >= 0 && idx < level.level_floor.size():
			tile = level.level_floor[idx]

		if tile > 0:
			units[selected_unit_index].set_move_target(level.tile_size, level.wall_height, Vector3(x, y, z))

		mouse_click = null

	if mouse_tile != null:
		select_sprite.set_translation(mouse_tile)
		select_sprite.show()

	else:
		select_sprite.hide()

func _ready():
	select_sprite = Sprite3D.new()
	select_sprite.set_texture(select_arrow_texture)
	select_sprite.set_vframes(1)
	select_sprite.set_hframes(1)
	select_sprite.set_centered(false)
	select_sprite.set_flip_h(true)
	select_sprite.set_pixel_size(0.002)
	select_sprite.hide()

	level = map.new()
	level.level_seed = level_seed
	level.width = level_width
	level.depth = level_depth
	level.height = level_height
	level.wall_height = wall_height
	level.tile_size = tile_size
	level.floor_materials = [floor_material]
	level.wall_materials = [wall_material]

	level = map_generator.gen_noise(level)

	for i in range(level_iterations):
		level = map_generator.gen_cellular_automata(level)

	level = map_generator.gen_walls(level)

	level = level_builder.build_mesh(level)
	level = level_builder.build_static_body(level)
	level.combine_mesh_and_body()

	var new_unit = unit.new({
		position = Vector3(20, 0, 20)
	})

	units.append(new_unit)

	for b in level.static_body:
		self.add_child(b)

	self.add_child(new_unit)
	self.add_child(select_sprite)

	set_process(true)
	set_fixed_process(true)
	set_process_input(true)
