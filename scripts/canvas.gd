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


var tileset_resource = preload("res://scenes/block_tilemap.res")
var clear_animation_overlay = preload("res://scripts/clear_animation_overlay.gd")

var virtual_width
var virtual_height

var rows_to_clear = []

onready var ClearTimer = Timer.new()
onready var Tilemap = TileMap.new()
onready var ClearAnimationOverlay = clear_animation_overlay.new()

signal block_set
signal scored


func _init():
	virtual_width = tetrout.ROWS * tetrout.BLOCK_SIZE
	virtual_height = tetrout.COLUMNS * tetrout.BLOCK_SIZE


func _ready():
	set_size(Vector2(virtual_width, virtual_height))
	
	ClearTimer.set_wait_time(0.15)
	ClearTimer.connect('timeout', self, '_on_ClearTimer_timeout')
	Tilemap.set_tileset(tileset_resource)
	Tilemap.set_cell_size(Vector2(tetrout.BLOCK_SIZE, tetrout.BLOCK_SIZE))
		
	add_child(ClearTimer)
	add_child(Tilemap)
	add_child(ClearAnimationOverlay)


func generate_level(difficulty=0.8):
	""" randomly places cells in the canvas, difficulty determines the probabilities
	Args:
		difficulty: a parameter that influences the probability for placing blocks
	Todo:
		- set difficulty levels as constants, e. g.: EASY = 0.6, MEDIUM = 0.7, ...
		- return amount blocks that are allowed to be used (player has more blocks in harder levels)
	"""
	randomize()
	# set block in only two lines	
	for r in range(2):
		# exponentially decreasing probability (higher rows are less likely to have blocks)
		# parameters were randomly chosen, no deeper meaning, can be tweaked
		var prob = exp(-r*1.25) * difficulty
		for c in range(tetrout.COLUMNS):
			if randf() > prob:
				# the probability for an item to be skiped is `1.0 - prob`
				# this results in a block being placed with a probability of `prob`
				continue
			# set cell with a random tile id (block type/color)
			var ids = Tilemap.tile_set.get_tiles_ids()
			set_cell(c, r, ids[int(randf() * len(ids))])

func set_cell(x, y, id):
	Tilemap.set_cell(tetrout.ROWS - y - 1, tetrout.COLUMNS - x - 1, id)
	
func get_cell(x, y):
	return Tilemap.get_cell(tetrout.ROWS - y - 1, tetrout.COLUMNS - x - 1)

func add_block(block):
	""" adds each brick to the area according the block's matrix
	Args:
		block:	block object
	"""		
	var anchor = get_global_position()
	var block_pos = block.get_global_position()
	
	var pos = Vector2(tetrout.COLUMNS - (block_pos.y - anchor.y) / tetrout.BLOCK_SIZE , \
						tetrout.ROWS - (block_pos.x - anchor.x) / tetrout.BLOCK_SIZE)

	for y in range(block.height):
		for x in range(block.width):
			# update area according to the area
			if block.matrix[y][x] == 1:
				var tile_id = Tilemap.tile_set.find_tile_by_name(block.get_block_name())
				set_cell(pos.x + block.width - x - 1, pos.y + y - block.height, tile_id)
	
	emit_signal('scored', block.get_block_score())
		
	check_full_rows()
	update()
	
	
func check_full_rows():
	# start from the top
	var h = tetrout.ROWS
	while h:
		h -= 1
		var full = true
		for x in range(tetrout.COLUMNS):
			if get_cell(x, h) == -1:
				# there is a gap, row is not completely full
				full = false
				break
		
		if full:
			# row is full, add to array
			rows_to_clear.append(h)
	
	if len(rows_to_clear) > 0:
		# start timer for animation if there are rows to be cleared
		ClearTimer.start()
		ClearAnimationOverlay.rows = rows_to_clear
	else:
		emit_signal('block_set')
		

	
func clear_rows():	
	for row in rows_to_clear:
		# pull down rows one-by-one starting from the top
		# not very efficient, but it works for now			
		for y in range(row, tetrout.ROWS):
			# set current row to the row above, except last row
			# last row is set to be completely empty
			for x in range(tetrout.COLUMNS):
				var tile_id = get_cell(x, y + 1)
				set_cell(x, y, tile_id if y < tetrout.ROWS - 1 else -1)

	# increase score for every row that will be cleared
	emit_signal('scored', tetrout.COLUMNS * len(rows_to_clear))
	
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
	var h = tetrout.ROWS - 1
	while h >= 0:
		var valid = true
		for y in range(block.height):
			for x in range(block.width):
				# whoever needs to debug this, have fun! :D				
				if get_cell(column + block.width - x - 1, h + y) != -1 and block.matrix[y][x]:
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
	
	var block_column = tetrout.COLUMNS - floor((block_pos.y - anchor.y) / tetrout.BLOCK_SIZE)
	
	
	var block_row = get_collision_row(block, block_column)
	
	var pos = Vector2(anchor.x + virtual_width - tetrout.BLOCK_SIZE * (block_row + block.height), \
						anchor.y + virtual_height - tetrout.BLOCK_SIZE * block_column)
	
	# transform to the canvas' origin
	return pos


func _draw():
	# highlight canvas area decently, for debugging
	draw_rect(Rect2(Vector2(0, 0), Vector2(virtual_width, virtual_height)), Color(1, 1, 1, 0.1), true)
	

var clear_animation_t = 0
func _on_ClearTimer_timeout():
	ClearAnimationOverlay.t = clear_animation_t
	ClearAnimationOverlay.update()
	if clear_animation_t == 5:
		ClearTimer.stop()
		clear_animation_t = 0
		clear_rows()
		emit_signal('block_set')
	else:
		clear_animation_t += 1

	
	
		
	
