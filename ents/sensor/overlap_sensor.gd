extends Node

var overlaps: int = 0

func _on_Area_body_entered(body):
	overlaps += 1


func _on_Area_body_exited(body):
	overlaps -= 1
