extends Node

@export var _character : CharacterBody3D
@export var _spring_arm : SpringArm3D
@onready var _gm : Node3D = $/root/Game
@onready var _pick_up_radius : Area3D = $"../Barbarian/Pick Up Radius"
var _nearest_item : Node3D
var _input_direction : Vector2
var _move_direction : Vector3
var enabled : bool = true:
	set(new_value):
		enabled = new_value
		# stop character from moving after player control is disabled
		if not enabled:
			_character.move(Vector3.ZERO)

func _input(event : InputEvent):
	if event.is_action_pressed("pause"):
		_gm.toggle_pause()
	if get_tree().paused:
		return
	if event.is_action_pressed("inventory"):
		_gm.toggle_inventory()
	if not enabled:
		return
	if event.is_action_pressed("run"):
		_character.run()
	elif event.is_action_released("run"):
		_character.walk()
	elif event.is_action_pressed("jump"):
		_character.start_jump()
	elif event.is_action_released("jump"):
		_character.complete_jump()
	elif event.is_action_pressed("interact"):
		_nearest_item = _pick_up_radius.get_nearest_item()
		if _nearest_item:
			File.progress.add_to_inventory(_nearest_item)
			_nearest_item.queue_free()
		else:
			_character.interact()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float):
	if get_tree().paused || not enabled:
		return
	_spring_arm.look(Input.get_vector("look_left", "look_right", "look_up", "look_down"))
	_input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	_move_direction = (_spring_arm.basis.x * Vector3(1, 0, 1)).normalized() * _input_direction.x
	_move_direction += (_spring_arm.basis.z * Vector3(1, 0, 1)).normalized() * _input_direction.y
	_character.move(_move_direction)
