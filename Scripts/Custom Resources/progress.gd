class_name Progress extends Resource

@export var coins : int:
	set(new_value):
		if coins != new_value:
			coins = new_value
			Global.coins_updated.emit(coins)

func _init():
	coins = 0
