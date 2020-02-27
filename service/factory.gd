extends Node

###########################################################################
# imports
###########################################################################
var projectile_def_t = load("res://ents/projectile/projectile_def.gd")
var projectile_t = preload("res://ents/projectile/ent_projectile_3d.tscn")


###########################################################################
# factory
###########################################################################
func create_projectile_def():
	return projectile_def_t.new()

func create_projectile():
	return projectile_t.instance()
