extends Area

var m_velocity: Vector3 = Vector3()

# these are default values but should be overridden in prepare_for_launch
var m_tickTime: float = 1
var m_teamId: int = 0
var m_damage: int = 20

#func _ready():
#	var _foo = self.connect("body_entered", self, "_on_projectile_body_entered")

func _physics_process(_delta: float):
	var pos = transform.origin
	pos += (m_velocity * _delta)
	transform.origin = pos

func _process(delta: float):
	m_tickTime -= delta
	if m_tickTime <= 0:
		queue_free()

func _on_projectile_body_entered(body):
	if body.has_node("health"):
		var hp: Node = body.get_node("health")
		var hitDir: Vector3 = Vector3(0, 1, 0)
		if hp.take_hit(m_damage, m_teamId, hitDir):
			m_tickTime = 0
	else:
		#print("Prj hit but no hp")
		m_tickTime = 0

func prepare_for_launch(teamId: int, damage: int, lifeTime: float):
	m_teamId = teamId
	m_damage = damage
	m_tickTime = lifeTime

func launch(pos: Vector3, forward: Vector3, speed: int):
	transform.origin = pos;
	m_velocity = forward * speed
	pass
