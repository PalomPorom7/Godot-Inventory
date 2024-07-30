class_name Progress extends Resource

@export var coins : int:
	set(new_value):
		if coins != new_value:
			coins = new_value
			Global.coins_updated.emit(coins)

@export var _inventory : Dictionary = {}

func _init():
	coins = 0

func add_to_inventory(item : Node3D, quantity : int = 1):
	if _inventory.has(item.display_name):
		_inventory[item.display_name] += quantity
	else:
		_inventory[item.display_name] = quantity
	print(_inventory)
