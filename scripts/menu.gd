extends Control

onready var viewport = get_viewport()

func _ready():
	viewport.connect('size_changed', self, '_on_viewport_size_changed')

func _on_Start_pressed():
	get_tree().change_scene('res://scenes/main.tscn')
	


func _on_Exit_pressed():
	get_tree().quit()


func _on_viewport_size_changed():
	var window_size = viewport.get_size_override()
	
	# adapt background size, so that it covers the whole screen
	$BackgroundLayer/Background.region_rect.size = window_size