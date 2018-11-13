extends Node

var TetrisCanvas = preload("res://scripts/canvas.gd")

var canvas
var ghost_block
var animated_block

var next_type

func _ready():
	randomize()
	
	canvas = TetrisCanvas.new()
	add_child(canvas)
	
	var canvas_size = canvas.get_size()
	var canvas_pos = Vector2()
	
	canvas_pos.x = tetrout.WINDOW_WIDTH - canvas_size.x
	canvas_pos.y = (tetrout.WINDOW_HEIGHT - canvas_size.y) / 2
	
	canvas.set_global_position(canvas_pos)
	
	$Player.canvas_top = canvas_pos.y
	$Player.canvas_bottom = canvas_pos.y + canvas.height
	
	next_block()
	next_block()
	
	print(next_type)

	
func next_block():
	if next_type:
		$Player.set_current_block(next_type)
	
		ghost_block = blocks.new_ghost_block(next_type)
		add_child(ghost_block)
	
	# skip first element (EMPTY)
	next_type = int(1 + (len(tetrout.TETRIS_BLOCK_TYPES) - 1) * randf())
	
func turn_block():
	if ghost_block:
		ghost_block.turn()
		

func _process(delta):	
	var player_velocity = Vector2()
	if Input.is_action_pressed('game_move_player_up'):
		player_velocity.y -= 1
	
	if Input.is_action_pressed('game_move_player_down'):
		player_velocity.y += 1
	
	$Player.set_velocity(player_velocity)
	
	# check if timer is running to tell whether the player is allowed to shoot a block right now
	if $NextBlockTimer.is_stopped():
		
		if Input.is_action_just_pressed('game_rotate_block'):
			$Player.turn_block()
			turn_block()
	
		if ghost_block:
			# update ghost block's position if the player is allowed to shoot a block
			var ghost_block_pos = canvas.get_ghost_block_position($Player.get_current_block())
			ghost_block.set_global_position(ghost_block_pos)
		
		
		if Input.is_action_just_pressed('game_shoot_block'):
			# start timer that permits the player to shoot new blocks for the next 750 ms
			$NextBlockTimer.start()
			
			animated_block = blocks.new_animated_block($Player.current_block.type)
			animated_block.set_rotation($Player.current_block.rotation)
			animated_block.set_animation($Player.current_block.get_global_position(), ghost_block.get_global_position(), 0.6)
			animated_block.connect("animation_end", self, "_on_AnimatedBlock_animation_end")
			
			add_child(animated_block)
			
			$Player.kill_current_block()					



func _on_AnimatedBlock_animation_end():
	canvas.add_block(ghost_block)
	
	
	# remove ghost from node tree ghost
	ghost_block.queue_free()
	ghost_block = null
	# remove animated block from screen
	animated_block.queue_free()
	animated_block = null
	
	



func _on_NextBlockTimer_timeout():
	$NextBlockTimer.stop()
	# generate next block
	next_block()
	
