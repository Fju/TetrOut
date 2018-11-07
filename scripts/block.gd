extends Node

const SIZE = 16
enum TYPES { EMPTY, GREEN, CYAN, BLUE, RED, VIOLET, MAGENTA, YELLOW }

var width
var height

var type
var matrix

func _init(t):
	type = t
	matrix = get_matrix(t)
	update_size()

func update_size():
	height = len(matrix)
	width = len(matrix[0])


func rotate(angle):
	""" rotates source matrix by 90/180/270 degrees clock-wise
	Args:
		matrix: input matrix
		rot:rotation angle = rot * 90 degrees (clock wise)
	"""
	matrix = get_matrix(type)
	
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

static func get_matrix(type):
	match type:
		TYPES.GREEN:
			return GREEN_MATRIX
		TYPES.CYAN:
			return CYAN_MATRIX
		TYPES.BLUE:
			return BLUE_MATRIX
		TYPES.RED:
			return RED_MATRIX
		TYPES.VIOLET:
			return VIOLET_MATRIX
		TYPES.MAGENTA:
			return MAGENTA_MATRIX
		TYPES.YELLOW:
			return YELLOW_MATRIX

static func get_color(type):
	match type:
		TYPES.GREEN:
			return GREEN_COLOR
		TYPES.CYAN:
			return CYAN_COLOR
		TYPES.BLUE:
			return BLUE_COLOR
		TYPES.RED:
			return RED_COLOR
		TYPES.VIOLET:
			return VIOLET_COLOR
		TYPES.MAGENTA:
			return MAGENTA_COLOR
		TYPES.YELLOW:
			return YELLOW_COLOR
		_:
			return Color(0, 0, 0, 0)