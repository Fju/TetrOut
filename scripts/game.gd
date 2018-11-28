extends Node

var TetrisCanvas = preload("res://scripts/canvas.gd")

var canvas
var ghost_block
var animated_block

onready var viewport = get_viewport()

var next_type
var can_shoot = false
var can_go_right = true

var desired_x = 0
var level = 0
var score = 0

func _ready():
	randomize()
	viewport.connect("size_changed", self, "_on_viewport_size_changed")
	$Player.connect('dead', self, '_on_Player_dead')
	$WastedEffect.connect('restart', self, '_on_WastedEffect_restart')
	set_player_initial_position()
	new_level()
	

func restart():
	score = 0
	level = 0
	
	if ghost_block:
		ghost_block.queue_free()
		ghost_block = null
	
	$Player.restart()
	can_go_right = true
	can_shoot = false
	
	set_player_initial_position()
	new_level()
	
	$WastedEffect.start_background_music()
	

func new_level():
	if level > 0:
		# add 100 points to the score except it's the first level, that is generated
		_on_canvas_scored(100)
	
	# TODO: sort and documentate!
	can_go_right = true
	
	# show current level number
	level += 1
	$GUI/LevelLabel.set_text("Level: %d" % level)
	
	if canvas:
		# delete completed canvas
		canvas.queue_free()
		canvas = null
	
	canvas = TetrisCanvas.new()
	add_child(canvas)
	
	canvas.generate_level(0.1)
	canvas.connect('block_set', self, '_on_canvas_block_set')
	canvas.connect('scored', self, '_on_canvas_scored')
	
	# call this function, so that the canvas' position is set correctly 
	_on_viewport_size_changed()
	
	# after this interval the player gets a random block that can be placed
	$NextBlockTimer.start()
	
func next_block():
	# TODO: make separate function for randomly choosing a block
	if !next_type:
		next_type = int(1 + (len(tetrout.BLOCK_TYPES) - 1) * randf())
	
	$Player.set_current_block(next_type)

	ghost_block = blocks.new_ghost_block(next_type)
	add_child(ghost_block)
	can_shoot = true
	
	# skip first element (which is tetrout.BLOCK_TYPES.EMPTY)
	next_type = int(1 + (len(tetrout.BLOCK_TYPES) - 1) * randf())

func start_go_right():
	can_go_right = false
	can_shoot = false
	
	ghost_block.queue_free()
	ghost_block = null
	
	$Player.kill_current_block()
	_on_viewport_size_changed()

func set_player_initial_position():
	var window_size = viewport.get_size_override()
	
	# before setting the player's position, we disable camera smoothing to prevent unwanted transitions
	$Player/Camera2D.smoothing_enabled = false
	# set player to start position
	$Player.set_global_position(Vector2(60, window_size.y / 2))
	
	# force camera to update it's position before re-enabling camera smoothing
	$Player/Camera2D.force_update_scroll()
	$Player/Camera2D.smoothing_enabled = true


func _process(delta):
	if Input.is_action_just_pressed('game_move_player_right') and can_go_right and can_shoot:
		start_go_right()

	var player_velocity = Vector2()
	if Input.is_action_pressed('game_move_player_up'):
		player_velocity.y -= 1
	
	if Input.is_action_pressed('game_move_player_down'):
		player_velocity.y += 1
		
	if !can_go_right:
		if desired_x > $Player.get_global_position().x:
			player_velocity.x += 3.2
		else:
			# fix Player's position to the desired x position
			_on_viewport_size_changed()
			new_level()
		
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

func _on_canvas_scored(s):
	score += s
	$GUI/ScoreLabel.set_text("Score: %d" % score)

func _on_Player_dead():
	$WastedEffect.play()

func _on_WastedEffect_restart():
	$WastedEffect.stop()
	restart()

func _on_NextBlockTimer_timeout():
	# generate next block
	next_block()
	
func _on_viewport_size_changed():
	if !canvas:
		return
	
	var window_size = viewport.get_size_override()
	
	# adapt background size, so that it covers the whole screen
	$BackgroundLayer/Background.region_rect.size = window_size
	
	var canvas_size = canvas.get_size()
	var canvas_pos = Vector2()
	
	canvas_pos.x = level * window_size.x - canvas_size.x
	canvas_pos.y = (window_size.y - canvas_size.y) / 2
	
	canvas.set_global_position(canvas_pos)
	
	if can_go_right:
		$Player.global_position.x = (level-1) * window_size.x + 60
	else:
		desired_x = level * window_size.x + 60
	
	$Player.set_camera_offset(window_size.x / 2 - 60)
	
	$Player.canvas_top = canvas_pos.y
	$Player.canvas_bottom = canvas_pos.y + canvas.virtual_height
	$Player.canvas_right = canvas_pos.x + canvas.virtual_width
	
	# bounds of canvas may have change, adapt player position accordingly
	$Player.clamp_vertically()
