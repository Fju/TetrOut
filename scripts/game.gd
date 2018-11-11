extends Node

var TetrisCanvas = preload("res://scripts/canvas.gd")
var Block = preload("res://scripts/block.gd")

var canvas

func _ready():
	canvas = TetrisCanvas.new()
	add_child(canvas)
	
	var canvas_size = canvas.get_size()
	var canvas_pos = Vector2()
	
	canvas_pos.x = tetrout.WINDOW_WIDTH - canvas_size.x
	canvas_pos.y = (tetrout.WINDOW_HEIGHT - canvas_size.y) / 2
	
	canvas.set_global_position(canvas_pos)
	
	$Player.canvas_top = canvas_pos.y
	$Player.canvas_bottom = canvas_pos.y + canvas.height
	
	$Player.set_current_block(tetrout.TETRIS_BLOCK_TYPES.BLUE)


func _process(delta):	
	var player_velocity = Vector2()
	if Input.is_action_pressed('game_move_player_up'):
		player_velocity.y -= 1
	
	if Input.is_action_pressed('game_move_player_down'):
		player_velocity.y += 1
	
	$Player.set_velocity(player_velocity)
	
	if Input.is_action_just_pressed('game_rotate_block'):
		$Player.rotate_block()
