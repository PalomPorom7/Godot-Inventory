extends Menu

const PREFAB : PackedScene = preload("res://Scenes/UI/item.tscn")

@onready var _character : CharacterBody3D = %Barbarian
@onready var player : Node = %Player
@onready var _container : Container = $ScrollContainer/GridContainer
@onready var _item_name : Label = $"VBoxContainer/Item Name"
@onready var _item_description : Label = $"VBoxContainer/Item Description"
@onready var _auxiliary : Button = $VBoxContainer/HBoxContainer/Auxiliary
@onready var _drop : Button = $VBoxContainer/HBoxContainer/Drop
var is_open : bool
var _selected_item : Item
var _selected_button : Button
var _previously_selected_button : Button

func _ready():
	for item in File.progress.inventory:
		_add_item_button(load("res://Scripts/Custom Resources/Items/" + item.name + ".tres"), item.quantity if item.has("quantity") else 1)
	for equipped in File.progress.equipment:
		if equipped != -1:
			_container.get_child(equipped).grab_focus()
			_equip_selected_item()

func open(breadcrumb : Menu = null):
	player.enabled = false
	super.open(breadcrumb)
	if _container.get_child_count() > 0:
		_container.get_child(0).grab_focus()
	else:
		_display_item_information(null)
	is_open = true

func add_item(item : Item, quantity : int = 1):
	if item is Stackable:
		_add_stackable_item(item, quantity)
	else:
		for i in quantity:
			_add_single_item(item)

func _add_single_item(item : Item):
	File.progress.inventory.push_back({"name" : item.name})
	_add_item_button(item)

func _add_stackable_item(item : Stackable, quantity : int):
	# search through inventory to find stacks of this item
	for i in File.progress.inventory.size():
		if File.progress.inventory[i].name == item.name:
			# check if there is any room in this stack
			if File.progress.inventory[i].quantity < item.stack_limit:
				# add quantity and check if stack limit was exceeded
				File.progress.inventory[i].quantity += quantity
				# reduce quantity
				quantity = File.progress.inventory[i].quantity - item.stack_limit
				if quantity > 0:
					File.progress.inventory[i].quantity = item.stack_limit
					_update_quantity(_container.get_child(i), item.stack_limit)
				else:
					_update_quantity(_container.get_child(i), File.progress.inventory[i].quantity)
					break
	# and repeat until all quantity is added to stacks or all stacks are full
	if quantity <= 0:
		return
	# if any quantity remains, create new stacks
	while quantity > 0:
		if quantity <= item.stack_limit:
			File.progress.inventory.push_back({"name" : item.name, "quantity" : quantity})
			_add_item_button(item, quantity)
			quantity = 0
		else:
			File.progress.inventory.push_back({"name" : item.name, "quantity" : item.stack_limit})
			_add_item_button(item, item.stack_limit)
			quantity -= item.stack_limit

func _add_item_button(item : Item, quantity : int = 1):
	var new_item_button : Button = PREFAB.instantiate()
	new_item_button.get_node("Icon").texture = item.icon
	_update_quantity(new_item_button, quantity)
	_container.add_child(new_item_button)
	new_item_button.focus_entered.connect(_display_item_information.bind(item, new_item_button))
	new_item_button.focus_exited.connect(_display_item_information.bind(null, null))

func _update_quantity(button : Button, quantity : int):
	if quantity != 1:
		button.get_node("Label").text = str(quantity)
	else:
		button.get_node("Label").visible = false

func _display_item_information(item : Item = null, button : Button = null):
	_item_name.text = item.name if item else ""
	_item_description.text = item.description if item else ""
	_selected_item = item
	_previously_selected_button = _selected_button
	_selected_button = button
	if item is Equipment:
		_auxiliary.disabled = false
		if _selected_item_is_equipped():
			_auxiliary.text = "X Unequip"
			_drop.disabled = true
		else:
			_auxiliary.text = "X Equip"
			_drop.disabled = false
	elif item && item.is_usable:
		_auxiliary.text = "X Use"
		_auxiliary.disabled = false
		_drop.disabled = false
	else:
		_auxiliary.disabled = true
		_drop.disabled = true

func _selected_item_is_equipped() -> bool:
	return File.progress.equipment[_selected_item.type] == _container.get_children().find(_selected_button)

func _input(event : InputEvent):
	if not is_open:
		return
	if event.is_action_pressed("use_item"):
		if _auxiliary.disabled == false:
			_auxiliary.pressed.emit()
	if event.is_action_pressed("drop_item"):
		if _drop.disabled == false:
			_drop.pressed.emit()

func _on_action_button_focus_entered():
	if _previously_selected_button:
		_previously_selected_button.grab_focus()

func _on_auxiliary_pressed():
	if _selected_item:
		if _selected_item is Equipment:
			if _selected_item_is_equipped():
				_unequip_selected_item()
			else:
				_equip_selected_item()
		elif _selected_item.is_usable:
			_use_selected_item()

func _equip_selected_item():
	if File.progress.equipment[_selected_item.type] != -1:
		_character.doff(_selected_item.type)
		_container.get_child(File.progress.equipment[_selected_item.type]).get_node("Label").visible = false
	File.progress.equipment[_selected_item.type] = _container.get_children().find(_selected_button)
	_character.don(_selected_item)
	_selected_button.get_node("Label").visible = true
	_auxiliary.text = "X Unequip"
	_drop.disabled = true

func _unequip_selected_item():
	File.progress.equipment[_selected_item.type] = -1
	_character.doff(_selected_item.type)
	_selected_button.get_node("Label").visible = false
	_auxiliary.text = "X Equip"
	_drop.disabled = false

func _use_selected_item():
	if _character.is_on_floor() && _character._can_move:
		_character.use_item(_selected_item)
		if _selected_item.is_consumed_on_use:
			_remove_item(_selected_item, 1, _selected_button)
		close()

func _on_drop_pressed():
	if _selected_item:
		var instance : Node3D = load(_selected_item.scene).instantiate()
		var direction : float = randf_range(0, TAU)
		$/root/Game.add_child(instance)
		instance.global_position = _character.global_position + Vector3(sin(direction), 1, cos(direction))
		_remove_item(_selected_item, 1, _selected_button)

func _remove_item(item : Item, quantity : int = 1, button : Button = null):
	if item is Stackable:
		_remove_stackable_item(item, quantity, button)
	else:
		for i in quantity:
			_remove_single_item(item, button if i == 0 else null)

func _remove_single_item(item : Item, button : Button):
	if button:
		var index : int = _container.get_children().find(button)
		File.progress.inventory.remove_at(index)
		_remove_item_button(button, index)
		return
	for i in File.progress.inventory.size():
		if File.progress.inventory[i].name == item.name:
			File.progress.inventory.remove_at(i)
			_remove_item_button(_container.get_child(i), i)
			return

func _remove_stackable_item(item : Item, quantity : int = 1, button : Button = null):
	if button:
		var index : int = _container.get_children().find(button)
		File.progress.inventory[index].quantity -= quantity
		if File.progress.inventory[index].quantity <= 0:
			quantity = -File.progress.inventory[index].quantity
			File.progress.inventory.remove_at(index)
			_remove_item_button(button, index)
		else:
			_update_quantity(button, File.progress.inventory[index].quantity)
			return
	if quantity == 0:
		return
	for i in File.progress.inventory.size():
		if File.progress.inventory[i].name == item.name:
			File.progress.inventory[i].quantity -= quantity
			if File.progress.inventory[i].quantity <= 0:
				quantity = -File.progress.inventory[i].quantity
				File.progress.inventory.remove_at(i)
				_remove_item_button(_container.get_child(i), i)
			else:
				_update_quantity(_container.get_child(i), File.progress.inventory[i].quantity)
				return
		if quantity == 0:
			return

func _remove_item_button(button : Button, index : int):
	if button == _selected_button:
		_focus_next(button)
	if button == _previously_selected_button:
		_previously_selected_button = null
	button.free()
	for i in File.progress.equipment.size():
		if File.progress.equipment[i] > index:
			File.progress.equipment[i] -= 1

func _focus_next(button : Button = null):
	var children : int = _container.get_child_count()
	if children < 2:
		return
	if not button:
		_container.get_child(0).grab_focus()
		return
	var index : int = _container.get_children().find(button)
	_container.get_child(index + (1 if index + 1 < children else -1)).grab_focus()

func close():
	if not _breadcrumb:
		player.enabled = true
	super.close()
	is_open = false
