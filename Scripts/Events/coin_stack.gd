extends ProximityEvent

@export_range(1, 9999999) var _value : int = 10
@onready var _mesh : MeshInstance3D = $MeshInstance3D
@onready var _sfx : AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var _particles : CPUParticles3D = $CPUParticles3D
var _tween

func run_event(_em : EventManager):
	disable()
	File.progress.coins += _value
	_shrink()
	_sfx.play()
	_particles.emitting = true
	await _particles.finished
	queue_free()

func _shrink() -> Signal:
	_tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	_tween.tween_property(_mesh, "scale", Vector3.ZERO, 1)
	return _tween.finished

func _on_body_entered(_body : Node3D):
	$/root/Game.start_event(self, false)
