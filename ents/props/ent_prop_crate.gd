extends "res://ents/interactor_base/kinematicbody_interactor_base.gd"

onready var m_hp = $health
onready var m_respawner = $respawner

var m_respawns: bool = true

func _ready():
	m_hp.team = com.TEAM_NONE
	m_hp.m_hp = 25

func die():
	var origin = get_global_transform().origin
	factory.spawn_blocks_explosion(origin, 15)
	if m_respawns:
		m_respawner.set_respawn_time(20)
		m_respawner.start_respawn(self)
	else:
		queue_free()

# called from respawner
func on_respawn():
	m_hp.respawn()

func interaction_take_hit(_hitData: Dictionary):
	var _response = m_hp.take_hit_data(_hitData)
	if _response.type == Enums.InteractHitResult.Killed:
		print("CRATE died to type " + _hitData.type)
		die()
	return _response
