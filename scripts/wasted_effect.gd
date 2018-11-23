extends CanvasLayer

onready var viewport = get_viewport()

func _ready():
	viewport.connect("size_changed", self, "_on_viewport_size_changed")

	# reset all values
	$AnimationPlayer.stop(false)
	
	_on_viewport_size_changed()
	

func play():
	$SoundEffect.play()
	$Text.set_visible(true)
	$AnimationPlayer.play('Appear')
	

func _on_viewport_size_changed():
	var window_size = viewport.get_size_override()
	
	$TextureRect.set_size(window_size)
	$Text.set_position(window_size * 0.5)
