extends Node

###########################################################################
# imports
###########################################################################
var projectile_def_t = load("res://ents/projectile/projectile_def.gd")
var projectile_t = preload("res://ents/projectile/ent_projectile_3d.tscn")

var point_projectile_t = preload("res://ents/projectile/ent_point_projectile.tscn")

var mob_t = preload("res://ents/mobs/ent_mob.tscn")

var fx_impact_t = preload("res://fx/fx_bullet_impact.tscn")

var fx_debris_t = preload("res://fx/fx_debris.tscn")

var prj_disc_t = preload("res://ents/projectile/prj_throw_disc.tscn")

###########################################################################
# factory
###########################################################################
func create_projectile_def():
	return projectile_def_t.new()

func create_disc_projectile():
	return prj_disc_t.instance()	

func create_projectile():
	return projectile_t.instance()

func get_free_point_projectile():
	return point_projectile_t.instance()
	
func create_mob():
	return mob_t.instance()

func create_fx_bullet_impact():
	return fx_impact_t.instance()

func create_debris():
	return fx_debris_t.instance()
	
func add_to_scene_root(obj: Spatial, pos: Vector3):
	get_tree().get_root().add_child(obj)
	obj.transform.origin = pos

func spawn_blocks_explosion(origin: Vector3, count: int):
	for i in range(0, 15):
		var debris = create_debris()
		var pos = origin
		pos.x += rand_range(-0.5, 0.5)
		pos.y += rand_range(-1, 1)
		pos.z += rand_range(-0.5, 0.5)
		factory.add_to_scene_root(debris, pos)
		debris.throw_randomly()
