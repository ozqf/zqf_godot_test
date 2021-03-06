extends Spatial

enum GameState { loading, ready, playing, over, complete }

var game_state = GameState.loading

var event_mask = com.EVENT_BIT_GAME_STATE | com.EVENT_BIT_ENTITY_SPAWN

var players = []
var player = null

var m_starts = []

# Id sequence for replicated, server side entities. Range 1, 2, 3...
var nextRemoteId: int = 1
# Id sequence for non-replicated, client side only entities. Range -1, -2, -3...
# Local entities should not be involved in any server side logic!
var nextLocalId: int = -1

# Master entity list for searches etc.
var ents = []

var m_orphanNodes = []
var m_updatableOrphanNodes = []

###########################################################################
# Init
###########################################################################
func _ready():
	print("Global entity server init")
	sys.add_observer(self)
	console.register_text_command(com.CMD_TRIGGER_ENTS, self, "cmd_trigger", "", "Trigger specified entity names")
	console.register_text_command(com.CMD_SPAWN, self, "cmd_spawn", "", "Spawn specified entity type at aim position")
	console.register_text_command(com.CMD_LIST_ENTS, self, "cmd_ents", "", "List current entities")
	pass

func cmd_spawn(tokens: PoolStringArray):
	var numTokens = tokens.size()
	if numTokens <= 1:
		print("Must specify an entity type \neg 'mob'")
		return
	var typeName = tokens[1]
	var result: Spatial = null
	# Grab debug position global
	var pos = com.debugSpawnPosition
	# spawn
	if typeName == "mob":
		result = factory.create_mob()
	else:
		print("Unrecognised spawn type '" + typeName + "'")
		return
	# add to scene
	factory.add_to_scene_root(result, pos)
	result.transform.origin = pos
	pass

func cmd_trigger(tokens: PoolStringArray):
	var numTokens = tokens.size()
	if numTokens <= 1:
		print("Must specify entity names to trigger\neg trigger ent1 ent2 ent3")
		return
	print("Triggering " + str(numTokens - 1) + "entities")
	# skip first token natch.
	for i in range(1, numTokens):
		print("Force triggering of " + tokens[i])
		trigger_entity(tokens[i])
	pass

func cmd_ents(_tokens: PoolStringArray):
	var numEnts = ents.size()
	print("--- List Entities (" + str(numEnts) + ") ---")
	for i in range(0, numEnts):
		print(str(ents[i].id) + ": " + ents[i].name)


###########################################################################
# Entity utilities
###########################################################################
func get_enemy_target(_currentTarget, _selfPos:Vector3):
	return player

func register_player(_plyr):
	player = _plyr
	#print("Registered player")

func deregister_player(_plyr):
	player = null
	#print("Deregistered player")

func register_start(_start):
	print("Ents register start " + _start.name)
	m_starts.push_back(_start)

###########################################################################
# Node tree utilities
###########################################################################
# 
# if a node removes itself from the tree to deactivate, record a reference
# here!
func add_orphan_node(node: Node, _updater: Node):
	print("Add orphan node " + node.name)
	var item = {
		node = node,
		updater = _updater
	}
	m_orphanNodes.push_back(item)

func remove_orphan_node(node: Node):
	print("Remove orphan node " + node.name)
	var l:int = m_orphanNodes.size()
	for i in range(l - 1, -1, -1):
		if m_orphanNodes[i].node == node:
			m_orphanNodes.remove(i)
			return

###########################################################################
# scene list
###########################################################################
func add_scene_object(obj: Node):
	# TODO: add this object to a more specific node for grouping objects
	#get_tree().root.add_child(obj)
	self.add_child(obj)

func _process(_delta: float):
	var l: int
	# go in reverse - nodes may remove themselves
	# TODO: Make this safer, if one orphan triggers some event that removes another...
	l = m_orphanNodes.size()
	for i in range(l - 1, -1, -1):
		var item = m_orphanNodes[i]
		if item.updater != null:
			item.updater.orphan_process(_delta)
	pass

###########################################################################
# Entity list
###########################################################################

# Returns first Id in the block registered.
# Ids must be specifically requested from the register
# This process is not done automatically within the entity to
# A: Split remote (server side, replicated) and local (client side, not-replicated)
# B: Allow Ids to be allocated in linear blocks
func allocate_ids(numIds: int, isLocal: bool):
	if numIds < 1:
		print("Cannot request no Ids!")
		return 0
	if isLocal:
		var first = nextLocalId
		nextLocalId -= numIds
	else:
		# If not a server, this should never be called!
		var first = nextRemoteId
		nextRemoteId += numIds
		return first

# Adds the given entity and Id combination to the entity register
func register_remote_ent(ent, id: int):
	if id < 1:
		print("Cannot register remote ent with id " + str(id))
		return
	ents.push_back(ent)

func register_local_ent(ent, id: int):
	if id > -1:
		print("Cannot register local ent with id " + str(id))
		return
	ents.push_back(ent)

func deregister_ent(ent):
	var i = ents.find(ent)
	if i >= 0:
		ents.remove(i)

###########################################################################
# Broadcast triggering
###########################################################################
func trigger_entity(entName: String):
	sys.broadcast(com.EVENT_ENTITY_TRIGGER, entName, com.EVENT_BIT_ENTITY_TRIGGER)

func trigger_entities(targets: PoolStringArray):
	for i in range(0, targets.size()):
		trigger_entity(targets[i])

###########################################################################
# Event response
###########################################################################
func observe_event(msg: String, _params):
	if msg == com.EVENT_LEVEL_LOADING:
		var l: int = ents.size()
		print("ENTS - freeing " + str(l) + " ents")
		var i: int = l - 1
		while i >= 0:
			ents[i].culled = true
			ents[i].free()
			i -= 1
		ents.clear()
		m_starts.clear()
		pass
	elif msg == com.EVENT_LEVEL_START:
		pass
	elif msg == com.EVENT_LEVEL_COMPLETE:
		pass
	elif msg == com.EVENT_PLAYER_SPAWN:
		register_player(_params)
	elif msg == com.EVENT_PLAYER_DIED:
		deregister_player(_params)
