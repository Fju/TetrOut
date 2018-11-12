extends Node

var TetrisCanvas = preload("res://scripts/canvas.gd")
var Block = preload("res://scripts/block.gd")

var canvas
var ghost_block

var next_type

func _ready():
	canvas = TetrisCanvas.new()
	add_child(canvas)
	
	next_block()
	$NextBlockTimer.start()
	
	var canvas_size = canvas.get_size()
	var canvas_pos = Vector2()
	
	canvas_pos.x = tetrout.WINDOW_WIDTH - canvas_size.x
	canvas_pos.y = (tetrout.WINDOW_HEIGHT - canvas_size.y) / 2
	
	canvas.set_global_position(canvas_pos)
	
	$Player.canvas_top = canvas_pos.y
	$Player.canvas_bottom = canvas_pos.y + canvas.height
	
	print(next_type)

	
func next_block():
	if next_type:
		$Player.set_current_block(next_type)
	
		ghost_block = Block.new(next_type, true)
		add_child(ghost_block)
	
	# skip first element (EMPTY)
	next_type = int(1 + (len(tetrout.TETRIS_BLOCK_TYPES) - 1) * randf())
	
func rotate_block():
	if ghost_block:
		ghost_block.rotate()
		

func _process(delta):	
	var player_velocity = Vector2()
	if Input.is_action_pressed('game_move_player_up'):
		player_velocity.y -= 1
	
	if Input.is_action_pressed('game_move_player_down'):
		player_velocity.y += 1
	
	$Player.set_velocity(player_velocity)
	
	
	# TODO: can't rotate block any longer
	if Input.is_action_just_pressed('game_rotate_block'):
		$Player.rotate_block()
		rotate_block()
	
	if ghost_block:
		var ghost_block_pos = canvas.get_ghost_block_position($Player.get_current_block())

		ghost_block.set_global_position(ghost_block_pos)
	
	if Input.is_action_just_pressed('game_shoot_block') and $NextBlockTimer.is_stopped():
		
		canvas.add_block(ghost_block)
		
		$Player.kill_current_block()
		
		ghost_block.queue_free()
		ghost_block = null	
		
		
		$NextBlockTimer.start()
		


		


func _on_NextBlockTimer_timeout():
	$NextBlockTimer.stop()
	next_block()
	
