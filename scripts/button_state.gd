### class for input handling. Returns 4 button states
var input_name
var prev_state
var current_state
var input

### States
const IS_UP = 0
const ON_DOWN = 1
const IS_DOWN = 2
const ON_UP = 3

var output_state
var state_old

### Get the input name and store it
func _init(var input_name):
	self.input_name = input_name

### check the input and compare it with previous states
func check():
	input = Input.is_action_pressed(self.input_name)
	prev_state = current_state
	current_state = input

	state_old = output_state

	if not prev_state and not current_state:
		output_state = IS_UP
	if not prev_state and current_state:
		output_state = ON_DOWN
	if prev_state and current_state:
		output_state = IS_DOWN
	if prev_state and not current_state:
		output_state = ON_UP

	return output_state
