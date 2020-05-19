extends Node

export var healthPoints: int = 100
export var team = 0
var m_hp:int = 100

var m_isDead: bool = false
#var m_hitResponse: Dictionary = com.create_hit_response(Enums.InteractHitResult.None, 0)

signal signal_death
signal signal_hit

func _ready():
	m_hp = healthPoints

func respawn():
	m_isDead = false
	m_hp = healthPoints

# Returns true if a hit was accepted, false if not
func take_hit(_dmg: int, _attackerTeamId: int, _dir: Vector3):
	if _attackerTeamId == team:
		return false
	m_hp -= _dmg
	if m_hp < 0 && !m_isDead:
		m_isDead = true
		emit_signal("signal_death")
		#get_parent().queue_free()
	else:
		emit_signal("signal_hit")
	return true

func take_hit_data(_hitData: Dictionary):
	if (m_isDead):
		return com.create_hit_response(Enums.InteractHitResult.None, 0)
	m_hp -= _hitData.dmg
	var taken:int = _hitData.dmg
	var responseType = Enums.InteractHitResult.Damaged
	if m_hp <= 0:
		taken += m_hp
		m_isDead = true
		responseType = Enums.InteractHitResult.Killed
	return com.create_hit_response(responseType, taken)
