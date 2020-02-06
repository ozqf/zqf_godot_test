extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var screen_size
var velocity = Vector2(256, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect()
	
	print("Type of screen size: " + str(typeof(screen_size)))

func _physics_process(_delta):
	var _pos = position
	_pos.x += velocity.x * _delta
	_pos.y += velocity.y * _delta
	if _pos.x > screen_size.end.x:
		_pos.x = screen_size.end.x
		velocity.x = -velocity.x
	if _pos.x < screen_size.position.x:
		_pos.x = screen_size.position.x
		velocity.x = -velocity.x
	
	position = _pos
