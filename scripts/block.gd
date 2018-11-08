extends Control

var width
var height

var box_width
var box_height

var type
var matrix
var color
var pos

var redraw = false

func _init(t):
	type = t
	matrix = tetrout.get_block_matrix(t)
	color = tetrout.get_block_color(t)
	pos = Vector2()
	update_size()

func update_size():
	redraw = true
	
	height = len(matrix)
	width = len(matrix[0])
	
	box_width = width * tetrout.TETRIS_BLOCK_SIZE
	box_height = height * tetrout.TETRIS_BLOCK_SIZE
	
	set_size(Vector2(box_width, box_height))

func rotate(angle):
	""" rotates source matrix by 90/180/270 degrees clock-wise
	Args:
		matrix: input matrix
		rot:rotation angle = rot * 90 degrees (clock wise)
	"""
	matrix = tetrout.get_block_matrix(type)
	
	var m = []
	var item = 0
	
	if angle % 2 == 1:
		for x in range(width):
			var row = []
			for y in range(height):
				item = matrix[height-y-1][x] if angle == 1 else matrix[y][x]
				# add item to row
				row.append(item)
			# add row to matrix
			m.append(row)
	elif angle == 2:
		for y in range(height):
			var row = []
			for x in range(width):
				item = matrix[height-y-1][x]
				# add item to row
				row.append(item)
			# add row to matrix
			m.append(row)
	
	# update source matrix
	matrix = m
	update_size()

func _draw():
	if !redraw:
		return
		
	redraw = false
	for y in range(height):
		for x in range(width):
			var _x = (height - y - 1) * tetrout.TETRIS_BLOCK_SIZE
			var _y = x * tetrout.TETRIS_BLOCK_SIZE
			
			if matrix[y][x] == 1:
				draw_texture(tetrout.block_texture, Vector2(_x, _y), color)


