extends Menu

const PREFAB : PackedScene = preload("res://Scenes/UI/item.tscn")

@onready var player : Node = %Player
@onready var _container : Container = $ScrollContainer/GridContainer
@onready var _item_name : Label = $"VBoxContainer/Item Name"
@onready var _item_description : Label = $"VBoxContainer/Item Description"
var is_open : bool

func _ready():
	for item in File.progress.inventory:
		_add_item_button(load("res://Scripts/Custom Resources/Items/" + item.name + ".tres"), item.quantity if item.has("quantity") else 1)

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
	new_item_button.focus_entered.connect(_display_item_information.bind(item))

func _update_quantity(button : Button, quantity : int):
	if quantity != 1:
		button.get_node("Label").text = str(quantity)
	else:
		button.get_node("Label").visible = false

func _display_item_information(item : Item = null):
	_item_name.text = item.name if item else ""
	_item_description.text = item.description if item else ""

func close():
	if not _breadcrumb:
		player.enabled = true
	super.close()
	is_open = false
