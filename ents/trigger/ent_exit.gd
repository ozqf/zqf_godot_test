extends Area

func _on_exit_area_entered(_area):
	pass


func _on_exit_body_entered(body):
	if body.name == "ent_actor_3d":
		print("Entered exit area")
		sys.broadcast("level_complete", null, com.EVENT_BIT_GAME_STATE)
