extends Control

var width
var height

var box_width
var box_height

var type
var matrix
var color
var pos = Vector2()

func _init(t, ghost=false):
	# store type
	type = t
	# obtain original matrix
	matrix = tetrout.get_block_matrix(t)
	
	# make transparent if it's a ghost block
	# note: this has no effect on blocks that have been added to the TetrisCanvas
	color = tetrout.get_block_color(t) if !ghost else Color(1, 1, 1, 0.25)

	update_size()

func update_size():
	redraw = true
	
	print(matrix)
	height = len(matrix)
	width = len(matrix[0])
	
	box_width = width * tetrout.TETRIS_BLOCK_SIZE
	box_height = height * tetrout.TETRIS_BLOCK_SIZE
	
	set_size(Vector2(box_width, box_height))

func set_position(pos):
	""" override function, centers the object """
	pos.x -= box_height / 2
	pos.y -= box_width / 2
	
	# call super function of inherited class
	.set_position(pos)

func rotate():
	""" rotates matrix by 90 degrees """	
	var m = []
	for x in range(width):
		var row = []
		for y in range(height):
			var item = matrix[height-y-1][x]
			# add item to row
			row.append(item)
		# add row to matrix
		m.append(row)

	# update matrix
	matrix = m
	update_size()

func kill():
	queue_free()


var redraw = false
func _draw():
	""" draw function, renders all blocks """
	if !redraw:
		return
		
	redraw = false
	
	for y in range(height):
		for x in range(width):
			var _x = (height - y - 1) * tetrout.TETRIS_BLOCK_SIZE
			var _y = x * tetrout.TETRIS_BLOCK_SIZE
			
			if matrix[y][x] == 1:
				draw_texture(tetrout.block_texture, Vector2(_x, _y), color)


