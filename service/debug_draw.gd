extends ImmediateGeometry

var _colour:Color = Color.green
var lines = []

func add_line(a:Vector3, b:Vector3):
	var line =  {
		"a": a,
		"b": b
	}
	lines.push_back(line)
	pass

func _ready():
	print("Debug color " + str(_colour))

func _draw_lines():
	self.clear()
	self.begin(PrimitiveMesh.PRIMITIVE_LINES)
	self.set_color(_colour)
	for i in range(0, lines.size()):
		var line = lines[i]
		self.add_vertex(line.a)
		self.add_vertex(line.b)
	self.end()
	lines = []

func _draw_test_line():
	self.clear()
	#var c: Color = Color(1, 1, 1, 1)
	#self.set_color(_colour)
	self.begin(PrimitiveMesh.PRIMITIVE_LINES)
	self.set_color(_colour)
	self.add_vertex(Vector3(2, 0, 2))
	self.set_color(_colour)
	self.add_vertex(Vector3(8, 8, 8))
	self.end()

func _process(_delta:float):
	_draw_lines()
	pass
