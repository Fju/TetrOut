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

var width = tetrout.TETRIS_BLOCK_SIZE * tetrout.TETRIS_ROWS
var height = tetrout.TETRIS_BLOCK_SIZE * tetrout.TETRIS_COLUMNS

# two dimensional array containing every item that should be displayed
# each entry contains a specific type (e.g. red, yellow, etc. or empty)
var area = []
var rows_to_clear = []

onready var ClearTimer = Timer.new()

signal ready

func _init():
	# start with blank grid
	clear_area()

func _ready():
	# adjust size of control
	set_size(Vector2(width, height))

	# don't draw content out of the canvas rectangle area
	set_clip_contents(true)
	
	#ClearTimer.set_timer_process_mode(Timer.TIMER_PROCESS_IDLE) 
	ClearTimer.set_wait_time(0.15)
	add_child(ClearTimer)
	ClearTimer.connect('timeout', self, '_on_ClearTimer_timeout')
	
	

func clear_area():
	""" utility function for clearing and re-initializing the 2d-array """
	area = []
	for row in range(tetrout.TETRIS_ROWS):
		area.append([])
		for column in range(tetrout.TETRIS_COLUMNS):
			area[row].append(tetrout.TETRIS_BLOCK_TYPES.EMPTY)

func add_block(block):
	""" adds each brick to the area according the block's matrix
	Args:
		block:	block object
	"""		
	var anchor = get_global_position()
	var block_pos = block.get_global_position()
	
	var pos = Vector2(tetrout.TETRIS_ROWS - (block_pos.y - anchor.y) / tetrout.TETRIS_BLOCK_SIZE, \
						tetrout.TETRIS_COLUMNS - (block_pos.x - anchor.x) / tetrout.TETRIS_BLOCK_SIZE)					

	for y in range(block.height):
		for x in range(block.width):
			# update area according to the area
			if block.matrix[y][x] == 1:
				area[pos.y - block.height + y][pos.x + block.width - x - 1] = block.type
	
	update()	
	check_full_rows()

	
func check_full_rows():
	# start from the top
	var h = tetrout.TETRIS_ROWS
	while h:
		h -= 1
		
		var full = true
		for x in range(tetrout.TETRIS_COLUMNS):
			if area[h][x] == tetrout.TETRIS_BLOCK_TYPES.EMPTY:
				# there is a gap, row is not completely full
				full = false
				break
		
		if full:
			# row is full, add to array
			rows_to_clear.append(h)
	
	if len(rows_to_clear) > 0:
		# start timer for animation if there are rows to be cleared
		ClearTimer.start()
	else:
		emit_signal('ready')
	
func clear_rows():
	
	for row in rows_to_clear:
		# pull down rows one-by-one starting from the top
		# not very efficient, but it works for now			
		for y in range(row, tetrout.TETRIS_ROWS):
			# set current row to the row above, except last row
			# last row is set to be completely empty
			for x in range(tetrout.TETRIS_COLUMNS):			
				area[y][x] = area[y+1][x] if y < tetrout.TETRIS_ROWS - 1 else tetrout.TETRIS_BLOCK_TYPES.EMPTY
	
	# reset array
	rows_to_clear = []
			
		
func get_collision_row(block, column):
	""" check at which row/height a block collides with other blocks or the ground
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
				if area[h+y][column+x] != tetrout.TETRIS_BLOCK_TYPES.EMPTY and block.matrix[y][block.width-x-1] == 1:
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

func get_ghost_block_position(block):
	var anchor = get_global_position()
	var block_pos = block.get_global_position()
	
	var block_column = tetrout.TETRIS_COLUMNS - floor((block_pos.y - anchor.y) / tetrout.TETRIS_BLOCK_SIZE)
	var block_row = get_collision_row(block, block_column)
	
	var pos = Vector2(width - tetrout.TETRIS_BLOCK_SIZE * (block_row + block.height), \
						height - tetrout.TETRIS_BLOCK_SIZE * (block_column))
	
	# transform to the canvas' origin
	pos.x += anchor.x
	pos.y += anchor.y
	
	return pos
	

func _draw():
	# highlight canvas area decently, for debugging
	draw_rect(Rect2(Vector2(0, 0), Vector2(width, height)), Color(1, 1, 1, 0.1), true)
	
	for row in range(tetrout.TETRIS_ROWS):
		for column in range(tetrout.TETRIS_COLUMNS):
			var type = area[row][column]

			var x = height - tetrout.TETRIS_BLOCK_SIZE * (row + 1)
			var y = width - tetrout.TETRIS_BLOCK_SIZE * (column + 1)

			# draw blocks
			draw_texture(tetrout.block_texture, Vector2(x, y), tetrout.get_block_color(type))
	
	for row in rows_to_clear:
		var color = Color(1, 1, 1, 0.8) if clear_animation_t % 2 == 0 else Color(0, 0, 0, 0)
		
		draw_rect(Rect2(width - (row + 1) * tetrout.TETRIS_BLOCK_SIZE, 0, tetrout.TETRIS_BLOCK_SIZE, height), color)

var clear_animation_t = 0
func _on_ClearTimer_timeout():
	if clear_animation_t == 5:
		ClearTimer.stop()
		clear_animation_t = 0
		clear_rows()
		emit_signal('ready')
	else:
		clear_animation_t += 1
	
	update()	
	
	
		
	
