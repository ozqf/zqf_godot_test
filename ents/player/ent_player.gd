extends "../ent.gd"

onready var body = $body
onready var hp = $body/health

func _ready():
	# base class call
    print("Ent Player type " + str(self) + " ready")
    hp.ent = self
	#._ready()

func getTransform():
	return self.body.transform
