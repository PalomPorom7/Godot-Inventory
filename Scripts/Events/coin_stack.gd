extends ProximityEvent

@export_range(1, 9999999) var _value : int = 10

func run_event(_em : EventManager):
	File.progress.coins += _value
	queue_free()

func _on_body_entered(_body : Node3D):
	$/root/Game.start_event(self, false)
