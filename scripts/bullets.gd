extends CharacterBody2D

@onready var life_span_timer: Timer = $Life_span_timer
var speed := 4000
var dir : float
var pos : Vector2
var rot : float

func _ready() -> void:
	global_position = pos
	global_rotation = rot
	life_span_timer.start()
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(speed,0).rotated(dir)
	move_and_slide()
	
func _on_life_span_timer_timeout() -> void:
	queue_free()
