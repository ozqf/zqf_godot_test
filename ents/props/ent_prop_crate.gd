extends "res://ents/interactor_base/kinematicbody_interactor_base.gd"

var m_health: int = 200;

func die():
	var origin = get_global_transform().origin
	#origin.y += 1
	factory.spawn_blocks_explosion(origin, 15)
	queue_free()

func interaction_take_hit(_hitData: Dictionary):
	if m_health <= 0:
		return com.create_hit_response(Enums.InteractHitResult.None)
	print("CRATE take hit")
	m_health -= _hitData.dmg
	if (m_health <= 0):
		die()
		return com.create_hit_response(Enums.InteractHitResult.Killed)
	return com.create_hit_response(Enums.InteractHitResult.Damaged)
	#return com.create_hit_response(Enums.InteractHitResult.None)
