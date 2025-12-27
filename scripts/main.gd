extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var zombie_scene: PackedScene = preload("res://scenes/zombie.tscn")
@onready var zombie_spawn_timer: Timer = $Zombie_spawn_timer
@onready var ui: CanvasLayer = $UI
@onready var rifle_pickup_scene = preload("res://scenes/pickups/rifle_pickup.tscn")
@onready var ammo_7_62_mm_pickup_scene = preload("res://scenes/pickups/ammo_7_62_mm_pickup.tscn")
@onready var ammo_9_mm_pickup_scene = preload("res://scenes/pickups/ammo_9_mm_pickup.tscn")
@onready var health_pickup_scene = preload("res://scenes/pickups/health_pickup.tscn")

@onready var zombie_death_sound_1: AudioStreamPlayer = $SFX_manager/ZombieDeathSound1
@onready var zombie_death_sound_2: AudioStreamPlayer = $SFX_manager/ZombieDeathSound2
@onready var zombie_death_sound_3: AudioStreamPlayer = $SFX_manager/ZombieDeathSound3


@onready var zombie_death_sounds = [zombie_death_sound_1,zombie_death_sound_2, zombie_death_sound_3]

var rifle_pickup
var ammo_762_pickup
var ammo_9mm_pickup
var health_pickup

var kill_count := 0
var zombie_spawn := true
var distance

func change_weapon():
	player.weapon_switch()
	player.rifle_reload_sfx.play()
	print("signal chancge weapon sent")
	
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
		zombie.connect("damage_dealt", Callable(self,"player_received_damage"))
		

func _ready() -> void:
	randomize()
	#Pickups
	
	rifle_pickup = rifle_pickup_scene.instantiate()
	add_child(rifle_pickup)
	rifle_pickup.connect("picked_up", Callable(self,"_on_picked_up"))
	
	ammo_762_pickup = ammo_7_62_mm_pickup_scene.instantiate()
	add_child(ammo_762_pickup)
	ammo_762_pickup.position.x = 150
	ammo_762_pickup.connect("picked_up", Callable(self,"_on_picked_up"))
	
	ammo_9mm_pickup = ammo_9_mm_pickup_scene.instantiate()
	add_child(ammo_9mm_pickup)
	ammo_9mm_pickup.position.x = 250
	ammo_9mm_pickup.connect("picked_up", Callable(self,"_on_picked_up"))
	
	health_pickup = health_pickup_scene.instantiate()
	add_child(health_pickup)
	health_pickup.position.x = 350
	health_pickup.connect("picked_up", Callable(self,"_on_picked_up"))
	
func _process(delta: float) -> void:
	spawn_zombie()

func _on_zombie_spawn_timer_timeout() -> void:
	zombie_spawn = true
	
func detect_killcount():
	kill_count += 1
	ui.update_killcount(kill_count)
	var random_zdeath_sound = zombie_death_sounds.pick_random()
	random_zdeath_sound.play()
	
func player_received_damage(damage):
	player.damage_received(damage)

func _on_picked_up(pickup_type):
		match pickup_type:
			"weapon":
				player.weapon_switch()
				player.rifle_reload_sfx.play()
				player.rifle_data["owned"] = true
			"ammo":
				player.add_ammo()
			"health":
				player.heal()
