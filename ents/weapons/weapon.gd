extends Node

var primaryOn: bool = false
var secondaryOn: bool = false

var m_launchNode: Spatial = null;

func init(_launchNode: Spatial):
	pass

func can_attack():
	return true

func can_equip():
	return true

func shoot():
	pass
