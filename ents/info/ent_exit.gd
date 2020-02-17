extends Area

func _on_exit_area_entered(area):
	pass
	#print("Entered exit area")
	#globals.broadcast("exit", 1)


func _on_exit_body_entered(body):
	print("Entered exit area")
	globals.broadcast("exit", 1)
