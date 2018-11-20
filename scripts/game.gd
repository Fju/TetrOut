extends Node

var TetrisCanvas = preload("res://scripts/canvas.gd")

var canvas
var ghost_block
var animated_block

onready var viewport = get_viewport()

var next_type
var can_shoot = false

var level = 0

func _ready():
	randomize()
	
	viewport.connect("size_changed", self, "_on_viewport_size_changed")	
	
	$Player.connect('level_completed', self, '_on_Player_level_completed')
	$Player.connect('dead', self, '_on_Player_dead')
	new_level()
	start_game()


func new_level():
	level += 1

	canvas = TetrisCanvas.new()
	add_child(canvas)
	
	canvas.generate_level(0.1)	
	canvas.connect('block_set', self, '_on_canvas_block_set')
	
	$Player.new_level()
	
	# call this function, so that the canvas' position is set correctly 
	_on_viewport_size_changed()
	
	
func start_game():
	next_block()
	$NextBlockTimer.start()
	
	
func next_block():
	if next_type:
		$Player.set_current_block(next_type)
	
		ghost_block = blocks.new_ghost_block(next_type)
		add_child(ghost_block)
		can_shoot = true
	
	# skip first element (which is tetrout.BLOCK_TYPES.EMPTY)
	next_type = int(1 + (len(tetrout.BLOCK_TYPES) - 1) * randf())

	
func _process(delta):	
	var player_velocity = Vector2()
	if Input.is_action_pressed('game_move_player_up'):
		player_velocity.y -= 1
	
	if Input.is_action_pressed('game_move_player_down'):
		player_velocity.y += 1
		
	if Input.is_action_pressed('debug_player_move_right'):
		player_velocity.x += 2.5
		#can_shoot = false
	
	$Player.set_velocity(player_velocity)
	
	# check if timer is running to tell whether the player is allowed to shoot a block right now
	if can_shoot:
		if Input.is_action_just_pressed('game_rotate_block'):
			$Player.turn_block()
			ghost_block.turn()
	
		if ghost_block:
			# update ghost block's position if the player is allowed to shoot a block
			var ghost_block_pos = canvas.get_ghost_block_position($Player.get_current_block())
			ghost_block.set_global_position(ghost_block_pos)
		
		
		if Input.is_action_just_pressed('game_shoot_block'):
			can_shoot = false
			animated_block = blocks.new_animated_block($Player.current_block.type)
			animated_block.set_rotation($Player.current_block.rotation)
			animated_block.set_animation($Player.current_block.get_global_position(), ghost_block.get_global_position(), 0.4)
			animated_block.connect("animation_end", self, "_on_AnimatedBlock_animation_end")
			
			add_child(animated_block)			
			$Player.kill_current_block()
	
	if Input.is_action_just_pressed('game_escape'):
		get_tree().quit()

func _on_AnimatedBlock_animation_end():
	canvas.add_block(ghost_block)
	
	# remove ghost from node tree ghost
	ghost_block.queue_free()
	ghost_block = null
	# remove animated block from screen
	animated_block.queue_free()
	animated_block = null

func _on_canvas_block_set():
	# block has been set, start timer for next timer
	$NextBlockTimer.start()


func _on_Player_dead():
	print('wasted')

func _on_Player_level_completed():
	# delete completed canvas
	canvas.queue_free()
	canvas = null
	
	# next level
	new_level()

func _on_NextBlockTimer_timeout():
	# generate next block
	next_block()
	
func _on_viewport_size_changed():
	if !canvas:
		return
	
	var window_size = viewport.get_size_override()
	
	#$Background.region_rect.end = window_size
	
	var canvas_size = canvas.get_size()	
	var canvas_pos = Vector2()
	
	# TODO: make 400 a constant with a reasonable name
	canvas_pos.x = (level - 1) * 400 + window_size.x - canvas_size.x
	canvas_pos.y = (window_size.y - canvas_size.y) / 2
	
	canvas.set_global_position(canvas_pos)
	
	$Player.canvas_top = canvas_pos.y
	$Player.canvas_bottom = canvas_pos.y + canvas.virtual_height
	$Player.canvas_right = canvas_pos.x + canvas.virtual_width
	
	# bounds of canvas may have change, adapt player position accordingly
	$Player.clamp_vertically()
