extends Node

var TetrisCanvas = preload("res://scripts/canvas.gd")
var Block = preload("res://scripts/block.gd")

var cyan_block
var canvas

func _ready():
	canvas = TetrisCanvas.new()
	add_child(canvas)
	
	var canvas_size = canvas.get_size()
	var canvas_pos = Vector2()
	
	canvas_pos.x = tetrout.WINDOW_WIDTH - canvas_size.x
	canvas_pos.y = (tetrout.WINDOW_HEIGHT - canvas_size.y) / 2
	
	print(canvas_pos)
	
	canvas.set_global_position(canvas_pos)
	
	
	cyan_block = Block.new(tetrout.TETRIS_BLOCK_TYPES.CYAN)
	add_child(cyan_block)
	
var b = 0
func _process(delta):
	if Input.is_action_just_pressed('ui_accept'):
		b = (b + 1) % 11
	
	cyan_block.pos.x = b
	cyan_block.pos.y = canvas.get_collision_row(cyan_block)

	var a = canvas.get_global_pos_of_block(cyan_block)
	cyan_block.set_global_position(a)