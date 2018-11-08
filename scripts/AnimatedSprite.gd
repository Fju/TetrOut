extends AnimatedSprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	screensize = get_viewport_rect().size
	pass

export (int) var speed  # How fast the player will move (pixels/sec).
var screensize  # Size of the game window.


func _process(delta):
    var velocity = Vector2() # The player's movement vector.
    if Input.is_action_pressed("ui_down"):
        velocity.y += 1
        #rotation_degrees.set_rotation_degrees(115)
    if Input.is_action_pressed("ui_up"):
        velocity.y -= 1
        #rotation_degrees.set_rotation_degrees(65)
    if velocity.length() > 0:
        velocity = velocity.normalized() * speed
    position += velocity * delta
    position.x = clamp(position.x, 0, screensize.x)
    position.y = clamp(position.y, 0, screensize.y)
    pass
