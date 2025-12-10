extends Sprite2D

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.start()
	
func create_big_stain():
	rotation = randf_range(-360, 360)
	scale = Vector2(randf_range(0.2,0.35), randf_range(0.1,0.35))
	timer.wait_time = randf_range(1, 1.5)


func _on_timer_timeout() -> void:
	queue_free()
