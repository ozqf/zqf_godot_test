extends KinematicBody2D

var projectilePrefab = preload("res://Projectile.tscn")
var speed = 128;
var fireTick = 0

func _ready():
	print("Player init")
	
signal hit

func _fire_projectile():
	var prj = projectilePrefab.instance()
	var _pos = self.get_global_position()
	prj.set_global_position(_pos)
	var _mPos = get_global_mouse_position()
	var radians = _mPos.angle_to_point(_pos)
	
	var prjScript = prj.get_node("Area2D")
	var vx = cos(radians) * 512
	var vy = sin(radians) * 512
	prjScript.velocity.x = vx
	prjScript.velocity.y = vy
	
	# TODO Code smell below
	get_tree().get_root().get_node("scene").add_child(prj)

func _process(_delta):
	if fireTick > 0:
		fireTick -= _delta
	#var _mPos = get_viewport().get_mouse_position()
	var _mPos = get_global_mouse_position()
	
	var _pos = self.position
	var _txt = "";
	_txt += "MPos " + str(_mPos.x) + ", " + str(_mPos.y)
	_txt += "\nPos " + str(_pos.x) + ", " + str(_pos.y)
	globals.debugText = _txt

func _physics_process(_delta):
	var viewRect = get_viewport_rect()
	var topLeftX = viewRect.position.x - (viewRect.size.x)
	var topLeftY = viewRect.position.y - (viewRect.size.y)
	var mWorldPos = Vector2()
	mWorldPos.x += topLeftX
	mWorldPos.y += topLeftY
	
	var velocity = Vector2()
	if Input.is_action_pressed("move_right"):
		velocity.x += 1;
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1;
	if Input.is_action_pressed("move_backward"):
		velocity.y += 1;
	if Input.is_action_pressed("move_forward"):
		velocity.y -= 1;
	
	if fireTick <= 0 && Input.is_action_pressed("attack_1"):
		fireTick = 0.1
		_fire_projectile()
	
	if (velocity.length() > 0):
		velocity = velocity.normalized() * speed
	
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_released("ui_focus_next"):
		var currentScene = get_tree().get_current_scene().get_filename()
		get_tree().change_scene(currentScene)
	
	move_and_slide(velocity)
