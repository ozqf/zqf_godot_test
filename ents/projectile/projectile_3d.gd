extends Area

onready var mesh = $mesh

var m_velocity: Vector3 = Vector3()

# these are default values but should be overridden in prepare_for_launch
var m_tickTime: float = 1
var m_teamId: int = 0
var m_damage: int = 20

var m_visibilityTick: float = 0.02

func _ready():
	mesh.hide()
	var _foo = self.connect("body_entered", self, "_on_projectile_body_entered")

func _physics_process(_delta: float):
	var pos = transform.origin
	pos += (m_velocity * _delta)
	transform.origin = pos

func _process(delta: float):
	m_tickTime -= delta
	if m_tickTime <= 0:
		var impact = factory.create_fx_bullet_impact()
		factory.add_to_scene_root(impact, transform.origin)
		#print("Spawn fx at " + str(transform.origin))
		queue_free()
	
	m_visibilityTick -= delta
	if m_visibilityTick < 0:
		m_visibilityTick = 9999999
		mesh.show()

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
	#var lookPos: Vector3 = pos + forward
	#look_at(lookPos, Vector3.UP)
	m_velocity = forward * speed
	pass
