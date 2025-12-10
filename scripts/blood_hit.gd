extends Node2D

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.start()
	
func create_small_stain():
	rotation = randf_range(-360, 360)
	scale = Vector2(randf_range(0.1,0.25), randf_range(0.1,0.25))
	timer.wait_time = randf_range(0.5, 0.8)



func _on_timer_timeout() -> void:
	queue_free()
