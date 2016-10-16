extends Camera

var input_states = preload("res://scripts/button_state.gd")

# Camera panning buttons
var btn_mov_forward = input_states.new("camera_pan_forward")
var btn_mov_back = input_states.new("camera_pan_back")
var btn_mov_left = input_states.new("camera_pan_left")
var btn_mov_right = input_states.new("camera_pan_right")

# Camera rotation buttons
var btn_rot_cw = input_states.new("camera_rot_cw")
var btn_rot_ccw = input_states.new("camera_rot_ccw")

# Camera height adjustment
var btn_zom_up = input_states.new("camera_zoom_up")
var btn_zom_down = input_states.new("camera_zoom_down")

var desired_angle = 0
var desired_height = 0

export var rotation_speed = 5.0
export var move_speed = 10.0
export var top_down_angle = 60.0

export var min_height = 5
export var max_height = 20

func pan_camera(mouse, direction, delta):
	var trans = get_translation()

	if !mouse:
		var angle = desired_angle % 4

		if angle < 0:
			angle += 4

		if angle == 0:
			trans.x += direction.y * move_speed * delta
			trans.z -= direction.x * move_speed * delta
		elif angle == 1:
			trans.x -= direction.x * move_speed * delta
			trans.z -= direction.y * move_speed * delta
		elif angle == 2:
			trans.x -= direction.y * move_speed * delta
			trans.z += direction.x * move_speed * delta
		elif angle == 3:
			trans.x += direction.x * move_speed * delta
			trans.z += direction.y * move_speed * delta

		set_translation(trans)
	else:
		set_translation(Vector3(direction.y * move_speed * delta, 0, -direction.x * move_speed * delta))

func rot_camera(direction, delta):
	var rot = get_rotation()

	if direction == "":
		var rot_speed = rotation_speed * delta
		var angle = desired_angle % 4

		if(angle < 0):
			angle += 4

		if angle == 0:
			var x = lerp(rot.x, -top_down_angle / 180.0 * PI, rot_speed)
			var y = lerp(rot.y, 0, rot_speed)
			var z = lerp(rot.z, desired_angle * 0.5 * PI, rot_speed)
			set_rotation(Vector3(x, y, z))
		elif angle == 1:
			var x = lerp(rot.x, -0.5 * PI, rot_speed)
			var y = lerp(rot.y, (90 - top_down_angle) / 180.0 * PI, rot_speed)
			var z = lerp(rot.z, desired_angle * 0.5 * PI, rot_speed)
			set_rotation(Vector3(x, y, z))
		elif angle == 2:
			var x = lerp(rot.x, -(180 - top_down_angle) / 180.0 * PI, rot_speed)
			var y = lerp(rot.y, 0, rot_speed)
			var z = lerp(rot.z, desired_angle * 0.5 * PI, rot_speed)
			set_rotation(Vector3(x, y, z))
		elif angle == 3:
			var x = lerp(rot.x, -0.5 * PI, rot_speed)
			var y = lerp(rot.y, -(90 - top_down_angle) / 180.0 * PI, rot_speed)
			var z = lerp(rot.z, desired_angle * 0.5 * PI, rot_speed)
			set_rotation(Vector3(x, y, z))
	else:
		if direction == "cw":
			desired_angle += 1
		elif direction == "ccw":
			desired_angle -= 1

func adjust_camera_height(delta):
	var pos = get_translation()
	var new_y = lerp(pos.y, desired_height, move_speed * delta)
	pos.y = new_y

	set_translation(pos)

func process_rotation(delta):
	if btn_rot_cw.check() == input_states.ON_DOWN:
		rot_camera("cw", delta)

	if btn_rot_ccw.check() == input_states.ON_DOWN:
		rot_camera("ccw", delta)

	rot_camera("", delta)

func process_panning(delta):
	var mov_x = 0
	var mov_y = 0
	if btn_mov_forward.check() == input_states.IS_DOWN:
		mov_x += 1

	if btn_mov_back.check() == input_states.IS_DOWN:
		mov_x -= 1

	if btn_mov_left.check() == input_states.IS_DOWN:
		mov_y -= 1

	if btn_mov_right.check() == input_states.IS_DOWN:
		mov_y += 1

	pan_camera(false, Vector2(mov_x, mov_y), delta)

func process_height(delta):
	# Handle scroll wheel for zoom
	if btn_zom_up.check() == input_states.ON_DOWN && desired_height < max_height:
		desired_height += 1

	if btn_zom_down.check() == input_states.ON_DOWN && desired_height > min_height:
		desired_height -= 1

	adjust_camera_height(delta)

func _process(delta):
	process_rotation(delta)
	process_panning(delta)
	process_height(delta)

func _ready():
	desired_height = self.get_translation().y
	set_process(true)
