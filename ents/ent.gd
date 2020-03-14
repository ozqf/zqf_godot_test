extends Node

var id: int = 0
var obj = get_parent()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# destructor logic
		globals.broadcast(common.EVENT_PLAYER_DIED, self, common.EVENT_BIT_ENTITY_SPAWN)
		g_ents.deregister_ent(self)

func _init():
	id = g_ents.register_remote_ent(self)
	print("Ent init id " + str(id))
