class_name Shop extends InteractionEvent

@export var _intro : String
@export var _outro : String
@export var markup : float = 10
@export var stock : Array[Item]

func run_event(em : EventManager):
	await em.dialog.display_line(_intro)
	await em.inventory.open_as_shop(self)
	await em.dialog.display_line(_outro)
	$/root/Game.end_event()
