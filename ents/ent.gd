# Base class for all game objects in world
# eg player, mobs, items, projectiles, triggers
# Extends Interactor
extends "res://ents/interactor_base/spatial_interactor_base.gd"

export var isPlayer: bool = false
export var entName: String = ""
export var targets: PoolStringArray = []

# if true, do not broadcast death events
var culled: bool = false

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
	g_ents.trigger_entities(targets)

########################################
# Life cycle
########################################

# constructor
func _init():
	# TODO: Replace id allocation/assignment with calls in factory.
	id = g_ents.allocate_ids(1, false)
	g_ents.register_remote_ent(self, id)
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
		if !culled:
			var eventType = common.EVENT_MOB_DIED
			if isPlayer:
				eventType = common.EVENT_PLAYER_DIED
			sys.broadcast(eventType, self, common.EVENT_BIT_ENTITY_SPAWN)
		# clean up
		sys.remove_observer(self)
		g_ents.deregister_ent(self)
		on_ent_destroy()

########################################
# Query
########################################
# override this if the entity's position is a child node!
func ent_get_world_position():
	return global_transform.origin

func ent_get_transform():
	return global_transform.origin
