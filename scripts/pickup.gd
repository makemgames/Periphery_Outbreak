extends Area2D

@export_enum("weapon", "health", "ammo") var pickup_type : String


signal picked_up(pickup_type)

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("picked_up", pickup_type)
		queue_free()
