extends Area2D

@export_enum("weapon", "health", "ammo_9mm", "ammo_rifle") var pickup_type : String
@export var amount := 0

signal picked_up(pickup_type,amount)

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("picked_up", pickup_type, amount)
		print("PICKUP FIRED:", pickup_type, amount)
		queue_free()
