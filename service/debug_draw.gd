extends ImmediateGeometry

var _colour:Color = Color.green

func _ready():
	print("Debug color " + str(_colour))

func _process(_delta:float):
	self.clear()
	#var c: Color = Color(1, 1, 1, 1)
	#self.set_color(_colour)
	self.begin(PrimitiveMesh.PRIMITIVE_LINES)
	self.set_color(_colour)
	self.add_vertex(Vector3(2, 0, 2))
	self.set_color(_colour)
	self.add_vertex(Vector3(8, 8, 8))
	self.end()
	pass
