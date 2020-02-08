extends KinematicBody

var lastMouseSample: Vector2 = Vector2(0, 0)
var physTick: float = 0

func _ready():
	print("Player 3D ready")

func _process(delta):
	var mMove: Vector2 = Input.get_last_mouse_speed()
	globals.debugText = "Mouse move " + str(mMove.x) + ", " + str(mMove.y)
	if lastMouseSample.x != mMove.x || lastMouseSample.y != mMove.y:
		lastMouseSample = mMove
		var rotY: float = (mMove.x * globals.DEG2RAD) * delta
		rotate_y(rotY)
		print(str(physTick) + ": Rotate " + str(rotY))
	physTick += 1
