extends Node

const TETRIS_BLOCK_SIZE = 16
enum TETRIS_BLOCK_TYPES { EMPTY, GREEN, CYAN, BLUE, RED, VIOLET, MAGENTA, YELLOW }

const TETRIS_ROWS = 12
const TETRIS_COLUMNS = 16


const INTERPOLATION_FLAG = 0
const TEXTURE_FLAG = 0

var block_texture

func _ready():
	block_texture = ImageTexture.new()
	
	var img = Image.new()
	img.load("res://assets/blocks/single_block.png")
	img.resize(TETRIS_BLOCK_SIZE, TETRIS_BLOCK_SIZE, INTERPOLATION_FLAG)
	# create texture
	block_texture.create_from_image(img, TEXTURE_FLAG)


# color scheme
const GREEN_COLOR = Color(0.2, 1, 0.2)
const CYAN_COLOR = Color(0.2, 0.8, 0.9)
const BLUE_COLOR = Color(0.2, 0.2, 1)
const RED_COLOR = Color(1, 0.2, 0.2)
const VIOLET_COLOR = Color(0.7, 0.2, 0.9)
const MAGENTA_COLOR = Color(0.9, 0.2, 0.8)
const YELLOW_COLOR = Color(0.9, 1, 0.2)

# block matrixes, where first dimension is y (bottom first) and second dimension is x (left first)
const GREEN_MATRIX = [[1, 1], [1, 1]] # 2x2
const CYAN_MATRIX = [[1, 1, 1], [0, 1, 0]] #3x2
const BLUE_MATRIX = [[1], [1], [1], [1]] #1x4
const RED_MATRIX = [[1, 1, 0], [0, 1, 1]] #3x2
const VIOLET_MATRIX = [[0, 1, 1], [1, 1, 0]] #3x2
const MAGENTA_MATRIX = [[1, 1], [0, 1], [0, 1]] #2x3
const YELLOW_MATRIX = [[1, 1], [1, 0], [1, 0]] #2x3

static func get_block_matrix(type):
	match type:
		TETRIS_BLOCK_TYPES.GREEN:
			return GREEN_MATRIX
		TETRIS_BLOCK_TYPES.CYAN:
			return CYAN_MATRIX
		TETRIS_BLOCK_TYPES.BLUE:
			return BLUE_MATRIX
		TETRIS_BLOCK_TYPES.RED:
			return RED_MATRIX
		TETRIS_BLOCK_TYPES.VIOLET:
			return VIOLET_MATRIX
		TETRIS_BLOCK_TYPES.MAGENTA:
			return MAGENTA_MATRIX
		TETRIS_BLOCK_TYPES.YELLOW:
			return YELLOW_MATRIX

static func get_block_color(type):
	match type:
		TETRIS_BLOCK_TYPES.GREEN:
			return GREEN_COLOR
		TETRIS_BLOCK_TYPES.CYAN:
			return CYAN_COLOR
		TETRIS_BLOCK_TYPES.BLUE:
			return BLUE_COLOR
		TETRIS_BLOCK_TYPES.RED:
			return RED_COLOR
		TETRIS_BLOCK_TYPES.VIOLET:
			return VIOLET_COLOR
		TETRIS_BLOCK_TYPES.MAGENTA:
			return MAGENTA_COLOR
		TETRIS_BLOCK_TYPES.YELLOW:
			return YELLOW_COLOR
		_:
			return Color(0, 0, 0, 0)