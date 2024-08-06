class_name Progress extends Resource

@export var coins : int:
	set(new_value):
		if coins != new_value:
			coins = new_value
			Global.coins_updated.emit(coins)

@export var inventory : Array = []

func _init():
	coins = 0
	inventory = [
		{"name" : "Health Potion", "quantity" : 98},
		{"name" : "Axe"},
		{"name" : "Axe"}
	]
