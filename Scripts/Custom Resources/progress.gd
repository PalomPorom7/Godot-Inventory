class_name Progress extends Resource

@export var coins : int:
	set(new_value):
		if coins != new_value:
			coins = new_value
			Global.coins_updated.emit(coins)

@export var inventory : Array = []
@export var equipment : Array = [1, 2, 3, 4]

func _init():
	coins = 0
	inventory = [
		{"name" : "Health Potion", "quantity" : 1},
		{"name" : "Axe"},
		{"name" : "Barbarian Round Shield"},
		{"name" : "Barbarian Hat"},
		{"name" : "Barbarian Cape"},
		{"name" : "Bomb"},
		{"name" : "Crossbow"},
		{"name" : "Greataxe"},
		{"name" : "Greatsword"},
		{"name" : "Heavy Crossbow"},
		{"name" : "Knife"},
		{"name" : "Knight Cape"},
		{"name" : "Knight Helmet"},
		{"name" : "Mage Cape"},
		{"name" : "Mage Hat"},
		{"name" : "Rogue Cape"},
		{"name" : "Spellbook"},
		{"name" : "Staff"},
		{"name" : "Sword"},
		{"name" : "Wand"}
	]
