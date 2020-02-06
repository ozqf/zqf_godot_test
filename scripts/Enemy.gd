extends KinematicBody2D

var screen_size:Rect2
var velocity:Vector2 = Vector2(256, 128)

func _ready():
	screen_size = get_viewport_rect()
	screen_size.position.x = -256
	screen_size.position.y = -150
	screen_size.end.x = 256
	screen_size.end.y = 150
	print("Type of screen size: " + str(typeof(screen_size)))

func _physics_process(_delta):
	var _pos:Vector2 = position
	_pos.x += velocity.x * _delta
	_pos.y += velocity.y * _delta
	if _pos.x > screen_size.end.x:
		_pos.x = screen_size.end.x
		velocity.x = -velocity.x
	if _pos.x < screen_size.position.x:
		_pos.x = screen_size.position.x
		velocity.x = -velocity.x
	
	if _pos.y > screen_size.end.y:
		_pos.y = screen_size.end.y
		velocity.y = -velocity.y
	if _pos.y < screen_size.position.y:
		_pos.y = screen_size.position.y
		velocity.y = -velocity.y
	
	position = _pos
