extends Control

#import classes
const Block = preload("res://scripts/block.gd")

const TEXTURE_FLAG = 0 # prevent interpolation filter

var columns = 16
var rows = 12

var box_height = rows * Block.SIZE
var box_width = columns * Block.SIZE


var block_texture
var area = []

func _init(r=12, c=16):
	rows = r
	columns = c
	clear_area()

func _ready():
	set_size(Vector2(box_width, box_height))
	
	var bl = Block.new(Block.TYPES.CYAN)
	var bt = Block.new(Block.TYPES.RED)
	#bl.rotate(1)
	
	add_block(bl, Vector2(0, 0))
	
	bl.rotate(1)
	add_block(bl, Vector2(3, 0))
	
	add_block(bt, Vector2(5, 1))
	load_textures()

func clear_area():
	for column in range(columns):
		area.append([])
		for row in range(rows):
			area[column].append(Block.TYPES.EMPTY)

func load_textures():
	block_texture = ImageTexture.new()
	var img = Image.new()
	img.load("res://assets/blocks/single_block.png")
	img.resize(Block.SIZE, Block.SIZE, 0)
	block_texture.create_from_image(img, TEXTURE_FLAG)

func add_block(block, pos):
	print(block.width)
	for y in range(block.height):
		for x in range(block.width):
			if block.matrix[y][x] == 1:
				area[pos.x+x][pos.y+y] = block.type


var needs_update = true
func _draw():
	if !needs_update:
		return
	
	# draw warning line
	draw_rect(Rect2(Vector2(0, 0), Vector2(box_width, box_height)), Color(1, 1, 1, 0.15), true)
	
	needs_update = false
	for column in range(columns):
		var y = Block.SIZE * column
		for row in range(rows):
			var x = box_width - Block.SIZE * (row + 1)
			var type = area[column][row]
			# draw blocks
			draw_texture(block_texture, Vector2(x, y), Block.get_color(type))
	
	
	