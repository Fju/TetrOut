""" Player sprite that can be controlled with keys
Author: 		Max Schönleben (Zombiefleischer), Florian Winkler (Fju)
Created:		08.11.2018
Description:
"""

extends Node2D

var Block = preload("res://scripts/block.gd")

# export variable can be edited in the edit
export (float) var speed 
export (float) var max_angle
export (float) var angular_velocity

var desired_angle = 0
var angle = 0

var current_block

func spawn_block(type):
	current_block = Block.new(type)	
	
	add_child(current_block)
	current_block.set_position($BlockPosition.get_position())

func _process(delta):
	var velocity = Vector2() # The player's movement vector.
	
	# change angle incremantally, nice transition
	if angle != desired_angle:
		var angle_delta = sign(desired_angle - angle) * angular_velocity * delta
		if angle_delta < 0:
			# clamp angle to desired angle
			angle = clamp(angle + angle_delta, desired_angle, max_angle)
		else:
			# clamp angle to desired angle
			angle = clamp(angle + angle_delta, -max_angle, desired_angle)
	
	$AnimatedSprite.set_rotation_degrees(90 + angle)
	
	# no rotation by default
	desired_angle = 0
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
		# turn right
		desired_angle = max_angle
		
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		# turn left
		desired_angle = -max_angle
        
	if velocity.length() > 0:
		# player is moving
		$AnimatedSprite.play('fly')
	else:
		$AnimatedSprite.play('idle')
	
	position += velocity * speed * delta
	position = position.round()
	
	
	
	if Input.is_action_just_pressed("game_shoot_block") and $Timer.is_stopped():
		# use timer for cool down, player can't fire a block within the next 500 ms
		$Timer.start()
		
		if !current_block:
			# spawn new block, if there is no current block present
			spawn_block(tetrout.TETRIS_BLOCK_TYPES.MAGENTA)
		
	if Input.is_action_just_pressed("game_rotate_block"):
		if current_block:
			current_block.rotate()
		
	
	# TODO: player can only move inbetween the vertical height of the TetrisCanvas
	#position.x = clamp(position.x, 0, screensize.x)
	#position.y = clamp(position.y, 0, screensize.y)

func _on_Timer_timeout():
	$Timer.stop()
