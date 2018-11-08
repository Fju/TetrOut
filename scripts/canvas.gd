extends Control

#import classes
const Block = preload("res://scripts/block.gd")

var TETRIS_CANVAS_WIDTH = tetrout.TETRIS_BLOCK_SIZE * tetrout.TETRIS_COLUMNS
var TETRIS_CANVAS_HEIGHT = tetrout.TETRIS_BLOCK_SIZE * tetrout.TETRIS_ROWS

var area = []

var redraw = true

func _init():
	clear_area()

func _ready():
	set_size(Vector2(TETRIS_CANVAS_WIDTH, TETRIS_CANVAS_HEIGHT))
	
	var bl = Block.new(tetrout.TETRIS_BLOCK_TYPES.RED)
	var bt = Block.new(tetrout.TETRIS_BLOCK_TYPES.YELLOW)
	var br = Block.new(tetrout.TETRIS_BLOCK_TYPES.MAGENTA)
	#bl.rotate(1)
	
	add_block(bl, Vector2(0, 0))
	
	bl.rotate(1)
	add_block(bl, Vector2(3, 0))
	
	add_block(bt, Vector2(5, 1))
	
	add_block(br, Vector2(4, 4))

func clear_area():
	for row in range(tetrout.TETRIS_ROWS):
		area.append([])
		for column in range(tetrout.TETRIS_COLUMNS):
			area[row].append(tetrout.TETRIS_BLOCK_TYPES.EMPTY)

func add_block(block, pos):
	for y in range(block.height):
		for x in range(block.width):
			if block.matrix[y][x] == 1:
				area[pos.y+y][pos.x+x] = block.type

func get_collision_row(block):
	var bottom = block.matrix[0]
	
	var h = tetrout.TETRIS_ROWS - 1
	while h >= 0:
		var valid = true
		for x in range(len(bottom)):
			if area[h][block.pos.x+x] != tetrout.TETRIS_BLOCK_TYPES.EMPTY:
				valid = false
				break
		
		if !valid:
			break
		else:
			h -= 1

	return h + 1

func get_global_pos_of_block(block):
	# top-left point of canvas
	var anchor = get_global_position()
	
	var pos = Vector2()
	pos.x = TETRIS_CANVAS_WIDTH - tetrout.TETRIS_BLOCK_SIZE * (block.pos.y + block.height)
	pos.y = TETRIS_CANVAS_HEIGHT - tetrout.TETRIS_BLOCK_SIZE * (block.pos.x + block.width)
	
	pos.x += anchor.x
	pos.y += anchor.y
	return pos
	

func _draw():
	# don't redraw every time
	if !redraw:
		return
	
	redraw = false
	# highlight canvas area decently
	draw_rect(Rect2(Vector2(0, 0), Vector2(TETRIS_CANVAS_WIDTH, TETRIS_CANVAS_HEIGHT)), Color(1, 1, 1, 0.1), true)
	
	for row in range(tetrout.TETRIS_ROWS):
		for column in range(tetrout.TETRIS_COLUMNS):
			var type = area[row][column]

			var x = TETRIS_CANVAS_WIDTH - tetrout.TETRIS_BLOCK_SIZE * (row + 1)
			var y = TETRIS_CANVAS_HEIGHT - tetrout.TETRIS_BLOCK_SIZE * (column + 1)
			# draw blocks
			draw_texture(tetrout.block_texture, Vector2(x, y), tetrout.get_block_color(type))
	
	
	