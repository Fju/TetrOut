""" overlay for drawing the clear animation of full rows
Author:			Florian Winkler (Fju)
Created:		16.11.2018
Description:
	Custom Control that draw a white stripe of the tetris canvas. This is a workaround, because the Tilemap that
	renders the blocks inside the TetrisCanvas is layered above the parents canvas, which means that it can't draw
	a rectangle over the blocks. This is why we need a custom node that is added as a child of TetrisCanvas, but
	after the Tilemap, so that it is rendered after it.
"""

extends Control

var t = 0
var rows = []
func _ready():
	# set size equal to the parent's (TetrisCanvas)
	set_size(get_parent().get_size())

func _draw():
	var size = get_size()
	for row in rows:
		# alternate between filled white rectangle and fully transparent
		var color = Color(1, 1, 1, 0.8) if t % 2 == 0 else Color(0, 0, 0, 0)		
		draw_rect(Rect2(size.x - (row + 1) * tetrout.BLOCK_SIZE, 0, tetrout.BLOCK_SIZE, size.y), color)

