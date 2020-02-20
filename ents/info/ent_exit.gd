extends Area

func _on_exit_area_entered(_area):
	pass
	#print("Entered exit area")
	#globals.broadcast("exit", 1)


func _on_exit_body_entered(body):
	if body.name == "ent_actor_3d":
		print("Entered exit area")
		globals.broadcast("level_complete", 1)
