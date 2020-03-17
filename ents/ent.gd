# Base class for all game objects in world
# eg player, mobs, items, projectiles, triggers
# 
extends Spatial

export var isPlayer: bool = false
export var entName: String = ""
export var targets: PoolStringArray = []

var event_mask: int = 0

# general entity fields
var id: int = 0
var rootNode = get_parent()

########################################
# Entity Triggering
########################################
func ent_trigger():
	pass

func ent_trigger_targets():
	for i in range(0, targets.size()):
		var tarName: String = targets[i]
		sys.broadcast(common.EVENT_ENTITY_TRIGGER, tarName, common.EVENT_BIT_ENTITY_TRIGGER)
	pass

########################################
# Life cycle
########################################

func _init():
	id = g_ents.register_remote_ent(self)
	sys.add_observer(self)
	#print("Ent init id " + str(id))

func _ready():
	print("Ent type " + str(self) + " ready")
	pass

# customer destructor stuff
func on_ent_destroy():
	pass

########################################
# Event response
########################################
func observe_event(_msg: String, _params):
	if _msg == common.EVENT_ENTITY_TRIGGER:
		if str(_params) == entName:
			ent_trigger()
	pass

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# destructor logic
		# inform interested parties
		var eventType = common.EVENT_MOB_DIED
		if isPlayer:
			eventType = common.EVENT_PLAYER_DIED
		sys.broadcast(eventType, self, common.EVENT_BIT_ENTITY_SPAWN)
		# clean up
		sys.remove_observer(self)
		g_ents.deregister_ent(self)
		on_ent_destroy()
