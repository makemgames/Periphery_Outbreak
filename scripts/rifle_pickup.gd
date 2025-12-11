extends Area2D


signal rifle_picked_up

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		rifle_picked_up.emit()
		queue_free()


func _on_rifle_picked_up() -> void:
	pass
