extends Node

export var m_hp: int = 100
export var m_team = 0
var ent = null

var m_isDead: bool = false

signal signal_death
signal signal_hit

# Returns true if a hit was accepted, false if not
func take_hit(_dmg: int, _attackerTeamId: int, _dir: Vector3):
	if _attackerTeamId == m_team:
		return false
	m_hp -= _dmg
	if m_hp < 0 && !m_isDead:
		m_isDead = true
		emit_signal("signal_death")
		#get_parent().queue_free()
	else:
		emit_signal("signal_hit")
	return true
