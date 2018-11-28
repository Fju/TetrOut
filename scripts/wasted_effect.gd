extends CanvasLayer

onready var viewport = get_viewport()

signal restart

var is_playing = false

func _ready():
	viewport.connect("size_changed", self, "_on_viewport_size_changed")

	# reset all values
	$TextureRect.set_visible(false)
	$Text.set_visible(false)
	$RestartLabel.set_visible(false)
	
	_on_viewport_size_changed()
	
	$TextureRect.connect("gui_input", self, "_on_TextureRect_gui_input")
	

func play():
	$SoundEffect.play()
	$AnimationPlayer.seek(0.0, true)
	$AnimationPlayer.play('Appear')
	$TextureRect.set_visible(true)
	$Text.set_visible(true)
	$RestartLabel.set_visible(true)
	
	is_playing = true

func stop():
	$SoundEffect.stop()
	$AnimationPlayer.stop()
	
	# hide all items
	$TextureRect.set_visible(false)
	$Text.set_visible(false)
	$RestartLabel.set_visible(false)
	
	
	is_playing = false


func _process(delta):
	if Input.is_action_just_pressed('game_accept') and is_playing:
		emit_signal('restart')

func _on_viewport_size_changed():
	var window_size = viewport.get_size_override()
	
	$TextureRect.set_size(window_size)
	$Text.set_position(window_size * 0.5)
	
	$RestartLabel.set_size(Vector2(window_size.x, 20))
	$RestartLabel.set_position(Vector2(0, window_size.y-20))

func _on_TextureRect_gui_input(ev):
	# for touch screens
	if ev.is_pressed() and is_playing:
		emit_signal('restart')
