extends Menu

@onready var player : Node = %Player
var is_open : bool

func open(breadcrumb : Menu = null):
	player.enabled = false
	super.open(breadcrumb)
	is_open = true

func close():
	if not _breadcrumb:
		player.enabled = true
	super.close()
	is_open = false
