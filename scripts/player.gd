""" Player sprite that can be controlled with keys
Author: 		Max Schönleben (Zombiefleischer), Florian Winkler (Fju)
Created:		08.11.2018
Description:
"""

extends AnimatedSprite

func _ready():
	screensize = get_viewport_rect().size


export (int) var speed  # How fast the player will move (pixels/sec).
var screensize  # size of the game window.

# decent turn angle
const MAX_ANGLE = 5
# speed of angular change per tick
const ANGULAR_VELOCITY = 100

var desired_angle = 0
var angle = 0

func _process(delta):
	var velocity = Vector2() # The player's movement vector.
	
	# change angle incremantally, nice transition
	if angle != desired_angle:
		var angle_delta = sign(desired_angle - angle) * ANGULAR_VELOCITY * delta
		if angle_delta < 0:
			# clamp angle to desired angle
			angle = clamp(angle + angle_delta, desired_angle, MAX_ANGLE)
		else:
			# clamp angle to desired angle
			angle = clamp(angle + angle_delta, -MAX_ANGLE, desired_angle)
	
	set_rotation_degrees(90 + angle)
	
	# no rotation by default
	desired_angle = 0
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
		# turn right
		desired_angle = MAX_ANGLE
		
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		# turn left
		desired_angle = -MAX_ANGLE
        
	if velocity.length() > 0:
		velocity = velocity * speed

	position += velocity * delta
	
	# TODO: player can only move inbetween the vertical height of the TetrisCanvas
	position.x = clamp(position.x, 0, screensize.x)
	position.y = clamp(position.y, 0, screensize.y)
