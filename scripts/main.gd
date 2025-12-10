extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var zombie_scene: PackedScene = preload("res://scenes/zombie.tscn")
@onready var zombie_spawn_timer: Timer = $Zombie_spawn_timer

var kill_count := 0
var zombie_spawn := true
var distance

func detect_killcount():
	kill_count += 1

func _ready() -> void:
	randomize()

func spawn_zombie():
	if zombie_spawn == true:
		zombie_spawn_timer.start()
		zombie_spawn = false
		var zombie = zombie_scene.instantiate()
		zombie.position = Vector2(
			randi_range(player.position.x - 1200, player.position.x + 1200),
			randi_range(player.position.y - 1200, player.position.y + 1200)
		)
		if zombie.position.distance_to(player.position) > 600:
			add_child(zombie)
		else:
			return
		
		zombie.connect("enemy_dead",Callable(self,"detect_killcount"))
		
func _process(delta: float) -> void:
	spawn_zombie()
	if kill_count == 1:
		player.weapon_switch()
		
func _on_zombie_spawn_timer_timeout() -> void:
	zombie_spawn = true
