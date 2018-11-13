""" Player sprite that can be controlled with keys
Author: 		Max Schönleben (Zombiefleischer), Florian Winkler (Fju)
Created:		08.11.2018
Description:
"""

extends Node2D

# export variable can be edited in the edit
export (float) var speed 
export (float) var max_angle
export (float) var angular_velocity

var desired_angle = 0
var angle = 0

var canvas_top = 0
var canvas_bottom = 0

var velocity setget set_velocity, get_velocity
var current_block setget set_current_block, get_current_block

func _ready():
	# initialize variables with setters and getters
	velocity = Vector2()

func kill_current_block():
	if current_block:
		current_block.queue_free()
		current_block = null

func clamp_vertically():
	# clamp vertical position
	var half_block_width = 0 if !current_block else current_block.box_width / 2
	global_position.y = clamp(global_position.y, canvas_top + half_block_width, canvas_bottom - half_block_width)

func _process(delta):
	# go back to center position by default
	desired_angle = 0
	if velocity.length() > 0:
		# player is moving, play `fly` animation
		$AnimatedSprite.play('fly')
		# check whether player is moving up or down
		if velocity.y > 0:
			desired_angle = max_angle # turn right
		else:			
			desired_angle = -max_angle # turn left
	else:
		# player is not moving, play `idle` animation
		$AnimatedSprite.play('idle')
	
	# change variable directly, which simplifies code
	global_position += velocity * speed * delta
	clamp_vertically()
	
	# change angle incremantally, nice transition
	if angle != desired_angle:
		var angle_delta = sign(desired_angle - angle) * angular_velocity * delta
		if angle_delta < 0:
			# clamp angle to desired angle
			angle = clamp(angle + angle_delta, desired_angle, max_angle)
		else:
			# clamp angle to desired angle
			angle = clamp(angle + angle_delta, -max_angle, desired_angle)
	
	# set rotation of sprite
	$AnimatedSprite.set_rotation_degrees(90 + angle)

# define setters and getters
func set_velocity(val):
	velocity = val

func get_velocity():
	return velocity

func set_current_block(type):
	if current_block:
		current_block.queue_free()
	
	current_block = blocks.new_block(type)
	add_child(current_block)
	current_block.set_position($BlockPosition.get_position())
	
	clamp_vertically()

func get_current_block():
	return current_block

func turn_block():	
	if current_block:
		# rotate block
		current_block.turn()
		# update position
		current_block.set_position($BlockPosition.get_position())
		
		clamp_vertically()
		
	