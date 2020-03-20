extends "../ent.gd"

onready var body = $body
onready var hp = $body/health

func _ready():
	# base class call
	print("Ent Player type " + str(self) + " ready")
	hp.ent = self
	#._ready()
	sys.broadcast(common.EVENT_PLAYER_SPAWN, self, common.EVENT_BIT_ENTITY_SPAWN)

func _process(_delta:float):
	var selfPos = global_transform.origin
	var bodyPos = body.global_transform.origin
	sys.playerDebugText = "Player ent pos " + str(selfPos) + "\nPlayer body pos: " + str(bodyPos)
	pass

func get_world_position():
	return self.body.transform.origin
