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
	#bl.rotate(1)
	
	add_block(bl, Vector2(0, 0))
	
	bl.rotate(1)
	add_block(bl, Vector2(3, 0))
	
	add_block(bt, Vector2(5, 1))

func clear_area():
	for column in range(tetrout.TETRIS_COLUMNS):
		area.append([])
		for row in range(tetrout.TETRIS_ROWS):
			area[column].append(tetrout.TETRIS_BLOCK_TYPES.EMPTY)

func add_block(block, pos):
	for y in range(block.height):
		for x in range(block.width):
			if block.matrix[y][x] == 1:
				area[pos.x+x][pos.y+y] = block.type

# TODO
#func get_global_pos_of_block(block_pos):
	

func _draw():
	if !redraw:
		return
	
	redraw = false
	
	draw_rect(Rect2(Vector2(0, 0), Vector2(TETRIS_CANVAS_WIDTH, TETRIS_CANVAS_HEIGHT)), Color(1, 1, 1, 0.15), true)
	
	for column in range(tetrout.TETRIS_COLUMNS):
		var y = tetrout.TETRIS_BLOCK_SIZE * column
		for row in range(tetrout.TETRIS_ROWS):
			var x = TETRIS_CANVAS_WIDTH - tetrout.TETRIS_BLOCK_SIZE * (row + 1)
			var type = area[column][row]
			# draw blocks
			draw_texture(tetrout.block_texture, Vector2(x, y), tetrout.get_block_color(type))
	
	
	