extends Node

const WINDOW_WIDTH = 360
const WINDOW_HEIGHT = 240

const BLOCK_SIZE = 12
enum BLOCK_TYPES { EMPTY, GREEN, CYAN, BLUE, RED, VIOLET, MAGENTA, YELLOW }

const ROWS = 14
const COLUMNS = 14

const INTERPOLATION_FLAG = 0
const TEXTURE_FLAG = 0

var block_texture = preload("res://assets/blocks/single_block.png")

func _ready():
	block_texture.set_flags(TEXTURE_FLAG)


# color scheme
const GREEN_COLOR = Color(0.2, 1, 0.2)
const CYAN_COLOR = Color(0.2, 0.8, 0.9)
const BLUE_COLOR = Color(0.2, 0.2, 1)
const RED_COLOR = Color(1, 0.2, 0.2)
const VIOLET_COLOR = Color(0.7, 0.2, 0.9)
const MAGENTA_COLOR = Color(1.0, 0.2, 0.7)
const YELLOW_COLOR = Color(0.9, 1, 0.2)

# block matrixes, where first dimension is y (bottom first) and second dimension is x (left first)
const GREEN_MATRIX = [[1, 1], [1, 1]] # 2x2
const CYAN_MATRIX = [[1, 1, 1], [0, 1, 0]] #3x2
const BLUE_MATRIX = [[1], [1], [1], [1]] #1x4
const RED_MATRIX = [[1, 1, 0], [0, 1, 1]] #3x2
const VIOLET_MATRIX = [[0, 1, 1], [1, 1, 0]] #3x2
const MAGENTA_MATRIX = [[1, 1], [0, 1], [0, 1]] #2x3
const YELLOW_MATRIX = [[1, 1], [1, 0], [1, 0]] #2x3

# score of placing a specific block
const GREEN_SCORE = 2
const CYAN_SCORE = 3
const BLUE_SCORE = 1
const RED_SCORE = 5
const VIOLET_SCORE = 5
const MAGENTA_SCORE = 4
const YELLOW_SCORE = 4

static func get_block_matrix(type):
	match type:
		BLOCK_TYPES.GREEN:
			return GREEN_MATRIX
		BLOCK_TYPES.CYAN:
			return CYAN_MATRIX
		BLOCK_TYPES.BLUE:
			return BLUE_MATRIX
		BLOCK_TYPES.RED:
			return RED_MATRIX
		BLOCK_TYPES.VIOLET:
			return VIOLET_MATRIX
		BLOCK_TYPES.MAGENTA:
			return MAGENTA_MATRIX
		BLOCK_TYPES.YELLOW:
			return YELLOW_MATRIX

static func get_block_color(type):
	match type:
		BLOCK_TYPES.GREEN:
			return GREEN_COLOR
		BLOCK_TYPES.CYAN:
			return CYAN_COLOR
		BLOCK_TYPES.BLUE:
			return BLUE_COLOR
		BLOCK_TYPES.RED:
			return RED_COLOR
		BLOCK_TYPES.VIOLET:
			return VIOLET_COLOR
		BLOCK_TYPES.MAGENTA:
			return MAGENTA_COLOR
		BLOCK_TYPES.YELLOW:
			return YELLOW_COLOR
		_:
			return Color(0, 0, 0, 0)

static func get_block_score(type):
	match type:
		BLOCK_TYPES.GREEN:
			return GREEN_SCORE
		BLOCK_TYPES.CYAN:
			return CYAN_SCORE
		BLOCK_TYPES.BLUE:
			return BLUE_SCORE
		BLOCK_TYPES.RED:
			return RED_SCORE
		BLOCK_TYPES.VIOLET:
			return VIOLET_SCORE
		BLOCK_TYPES.MAGENTA:
			return MAGENTA_SCORE
		BLOCK_TYPES.YELLOW:
			return YELLOW_SCORE
		_:
			return 0

static func get_block_name(type):
	match type:
		BLOCK_TYPES.GREEN:
			return 'GreenBlock'
		BLOCK_TYPES.CYAN:
			return 'CyanBlock'
		BLOCK_TYPES.BLUE:
			return 'BlueBlock'
		BLOCK_TYPES.RED:
			return 'RedBlock'
		BLOCK_TYPES.VIOLET:
			return 'VioletBlock'
		BLOCK_TYPES.MAGENTA:
			return 'MagentaBlock'
		BLOCK_TYPES.YELLOW:
			return 'YellowBlock'
		_:
			return ''

static func get_block_probability(type):
	match type:
		BLOCK_TYPES.GREEN:
			return 3
		BLOCK_TYPES.CYAN:
			return 3
		BLOCK_TYPES.BLUE:
			return 5
		BLOCK_TYPES.RED:
			return 2
		BLOCK_TYPES.VIOLET:
			return 2
		BLOCK_TYPES.MAGENTA:
			return 3
		BLOCK_TYPES.YELLOW:
			return 3
		_:
			return 0