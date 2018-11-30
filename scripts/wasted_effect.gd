extends CanvasLayer

onready var viewport = get_viewport()

signal restart

var is_playing = false

func _ready():
	viewport.connect("size_changed", self, "_on_viewport_size_changed")
	_on_viewport_size_changed()
	
	stop()
	$TextureRect.connect("gui_input", self, "_on_TextureRect_gui_input")	
	start_background_music()

func start_background_music():
	$BackgroundMusic.set_volume_db(0.0)
	$BackgroundMusic.play()

func play():
	$SoundEffect.play()
	
	$AnimationPlayer.play('Appear')
	$TextureRect.set_visible(true)
	$Text.set_visible(true)
	$RestartLabel.set_visible(true)
	$ScoreLabel.set_visible(true)
	
	is_playing = true

func stop():
	$BackgroundMusic.stop()
	
	$SoundEffect.stop()
	$AnimationPlayer.stop()
	# go back to beginning to reset all key-values to their initial state
	$AnimationPlayer.seek(0, true)
	
	# hide all items
	$TextureRect.set_visible(false)
	$Text.set_visible(false)
	$RestartLabel.set_visible(false)
	$ScoreLabel.set_visible(false)
	
	is_playing = false

func set_score(score):
	$ScoreLabel.set_text('Your score: %d' % score)

func _process(delta):
	if Input.is_action_just_pressed('game_accept') and is_playing:
		emit_signal('restart')

func _on_viewport_size_changed():
	var window_size = viewport.get_size_override()
	
	$TextureRect.set_size(window_size)
	$Text.set_position(window_size * 0.5)
	

func _on_TextureRect_gui_input(ev):
	# for touch screens
	if ev.is_pressed() and is_playing:
		emit_signal('restart')


func _on_AnimationPlayer_animation_finished(anim_name):
	$SoundEffect.stop()
	$BackgroundMusic.stop()
