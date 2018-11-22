""" Container for touch screen controls
Author:			Florian Winkler (Fju)
Created:		14.11.2018
Description:
	This is a container node that contains four touch screen buttons.
	It automatically sets their position and adapts to different screen sizes.
"""

extends Container

const PADDING = 8
const BUTTON_SIZE = 30

onready var viewport = get_viewport()

func _ready():
	viewport.connect("size_changed", self, "_on_viewport_size_changed")
	_on_viewport_size_changed()

func _on_viewport_size_changed():
	var window_size = viewport.get_size_override()

	$TouchButtonUp.set_position(Vector2(PADDING, window_size.y - 2*BUTTON_SIZE - 2*PADDING))
	$TouchButtonDown.set_position(Vector2(PADDING, window_size.y - BUTTON_SIZE - PADDING))
	$TouchButtonRight.set_position(Vector2(BUTTON_SIZE + 2*PADDING, window_size.y - BUTTON_SIZE - PADDING))

	$TouchButtonFire.set_position(Vector2(window_size.x - BUTTON_SIZE - PADDING, window_size.y - BUTTON_SIZE - PADDING))
	$TouchButtonRotate.set_position(Vector2(window_size.x - 2*BUTTON_SIZE - 3*PADDING, window_size.y - BUTTON_SIZE - PADDING))
