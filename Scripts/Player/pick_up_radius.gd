extends Area3D

@onready var _ray : RayCast3D = $RayCast3D
var _items_in_range : Array[Node3D] = []
var _nearest_index : int
var _nearest_distance : float
var _next_distance : float

func get_nearest_item() -> Node3D:
	if _items_in_range.size() == 0:
		return null
	elif _items_in_range.size() == 1:
		if not _obstructed(_items_in_range[0]):
			return _items_in_range[0]
		else:
			return null
	_nearest_index = 0
	_nearest_distance = 5
	for i in _items_in_range.size():
		_next_distance = global_position.distance_squared_to(_items_in_range[i].global_position)
		if _next_distance < _nearest_distance && not _obstructed(_items_in_range[i]):
			_nearest_index = i
			_nearest_distance = _next_distance
	return _items_in_range[_nearest_index]

func _obstructed(item : Node3D) -> bool:
	_ray.target_position = item.global_position - _ray.global_position
	_ray.force_raycast_update()
	return _ray.get_collider() != item

func _on_body_entered(body : Node3D):
	_items_in_range.append(body)

func _on_body_exited(body : Node3D):
	_items_in_range.erase(body)
