extends CanvasLayer

onready var viewport = get_viewport()

func _ready():
	viewport.connect('size_changed', self, '_on_viewport_size_changed')
	_on_viewport_size_changed()

func _on_viewport_size_changed():
	var window_size = viewport.get_size_override()
	
	# adapt background size, so that it covers the whole screen
	$Particles2D.set_position(window_size)