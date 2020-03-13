extends Node

###########################################################################
# imports
###########################################################################
var projectile_def_t = load("res://ents/projectile/projectile_def.gd")
var projectile_t = preload("res://ents/projectile/ent_projectile_3d.tscn")

var mob_t = preload("res://ents/mobs/ent_mob.tscn")

var fx_impact_t = preload("res://fx/fx_bullet_impact.tscn")

###########################################################################
# factory
###########################################################################
func create_projectile_def():
	return projectile_def_t.new()

func create_projectile():
	return projectile_t.instance()

func create_mob():
	return mob_t.instance()

func create_fx_bullet_impact():
	return fx_impact_t.instance()

func add_to_scene_root(obj: Spatial, pos: Vector3):
	get_tree().get_root().add_child(obj)
	obj.transform.origin = pos
