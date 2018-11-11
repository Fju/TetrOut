""" TetrisCanvas class
Author:			Florian Winkler (Fju)
Created:		08.11.2018
Description:
	Custom Control that renders tetris blocked that can be added to the canvas with the `add_block` function.
	It automatically resizes according to the defined amount of columns and rows (see `tetrout.gd`).
	Also it contains utility functions for checking the height where a new block would be placed and converting a
	grid position insde the 2d array/grid (`area`) to a global position (useful for placing blocks as ghosts)	
"""

extends Control

const Block = preload("res://scripts/block.gd")


var width = tetrout.TETRIS_BLOCK_SIZE * tetrout.TETRIS_COLUMNS
var height = tetrout.TETRIS_BLOCK_SIZE * tetrout.TETRIS_ROWS

# two dimensional array containing every item that should be displayed
# each entry contains a specific type (e.g. red, yellow, etc. or empty)
var area = []

func _init():
	# start with blank grid
	clear_area()

func _ready():
	# adjust size of control
	set_size(Vector2(width, height))

	# don't draw content out of the canvas rectangle area
	set_clip_contents(true) 

	
	var bl = Block.new(tetrout.TETRIS_BLOCK_TYPES.RED)
	var bt = Block.new(tetrout.TETRIS_BLOCK_TYPES.YELLOW)
	var br = Block.new(tetrout.TETRIS_BLOCK_TYPES.MAGENTA)
	#bl.rotate(1)
	
	add_block(bl, Vector2(0, 0))
	
	bl.rotate()
	add_block(bl, Vector2(3, 0))
	
	add_block(bt, Vector2(5, 1))
	
	add_block(br, Vector2(4, 4))

func clear_area():
	""" utility function for clearing and re-initializing the 2d-array """
	area = []
	for row in range(tetrout.TETRIS_ROWS):
		area.append([])
		for column in range(tetrout.TETRIS_COLUMNS):
			area[row].append(tetrout.TETRIS_BLOCK_TYPES.EMPTY)

func add_block(block, pos):
	""" adds each brick to the area according the block's matrix
	Args:
		block:	block object
		pos:	Vector2 containing row and column where the block should be placed
	"""
	for y in range(block.height):
		for x in range(block.width):
			# update area according to the area
			if block.matrix[y][x] == 1:
				area[pos.y+y][pos.x+x] = block.type

func get_collision_row(block):
	""" check at which column/height a block collides with other blocks or the ground
	Args:
		block:	block object
	Returns:
		h:		column/height of collision (0 if it collides with the ground)
	"""
	
	# TODO: starting at this height can cause a bug, where a block slides through another block, fix this!!
	var h = tetrout.TETRIS_ROWS - 1 - block.height
	while h >= 0:
		var valid = true
		for y in range(block.height):
			for x in range(block.width):
				# whoever needs to debug this, have fun! :D
				if area[h+y][block.pos.x+x] != tetrout.TETRIS_BLOCK_TYPES.EMPTY and block.matrix[y][block.width-x-1] == 1:
					valid = false
					break

			# since breaking only affects the inner-most for-loop in the first place we need to check again
			# which looks ugly (eye-candy: combined for-loop instead of nested for-loop)
			if !valid:
				break
		
		if !valid:
			break # can't go no deeper
		else:
			h -= 1 # go deeper

	# return column/height where the block would be placed
	return h + 1

func get_global_pos_of_block(block):
	""" convert grid coordinates (row, column) to screen coordinates (global-x, global-y)
	Args:
		block:	block object (containing position and size information)
	Returns:
		pos:	converted position coordinates (Vector2)
	"""
	
	# top-left point of canvas
	var anchor = get_global_position()
	
	# converted coordinates, note that row index is equal to x-axis position not y-axis!!
	var pos = Vector2(width - tetrout.TETRIS_BLOCK_SIZE * (block.pos.y + block.height), \
						height - tetrout.TETRIS_BLOCK_SIZE * (block.pos.x + block.width))
	
	# transform to the canvas' origin
	pos.x += anchor.x
	pos.y += anchor.y
	return pos
	
var redraw = true
func _draw():
	# don't redraw every time
	if !redraw:
		return
	
	redraw = false
	# highlight canvas area decently
	draw_rect(Rect2(Vector2(0, 0), Vector2(width, height)), Color(1, 1, 1, 0.1), true)
	
	for row in range(tetrout.TETRIS_ROWS):
		for column in range(tetrout.TETRIS_COLUMNS):
			var type = area[row][column]

			var x = height - tetrout.TETRIS_BLOCK_SIZE * (row + 1)
			var y = width - tetrout.TETRIS_BLOCK_SIZE * (column + 1)

			# draw blocks
			draw_texture(tetrout.block_texture, Vector2(x, y), tetrout.get_block_color(type))
	
	
	
