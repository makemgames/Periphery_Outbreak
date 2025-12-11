extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"../Player"
@onready var healthbar: TextureProgressBar = $Healthbar
@onready var attack_timer: Timer = $Attack_timer
@onready var walking_sfx: AudioStreamPlayer2D = $Walking_sfx

var walking_sounds := [preload("res://assets/audio/zombie_walking_sfx_1.mp3"), preload("res://assets/audio/zombie_death_sound_2.mp3")]
var random_sound

const BLOOD_HIT = preload("uid://fxt3fbsv6536")
const BLOOD_DEATH = preload("uid://divkwpemyobhk")

@export var max_hp: int = 100

var direction: Vector2
var speed = 200
var current_hp: int = max_hp
var attack_range = 150

signal damage_dealt(damage)
signal enemy_dead

func damage_received(dmg):
	current_hp = current_hp - dmg
	current_hp = max(current_hp,0)
	healthbar.value = current_hp
	healthbar.visible = true

func play_walk_sfx():
	await get_tree().create_timer(randf_range(2,6)).timeout
	if walking_sfx.playing:
		return
	walking_sfx.volume_db = randf_range(-14,-7)
	walking_sfx.pitch_scale = randf_range(0.85,1.15)
	walking_sfx.stream = random_sound
	walking_sfx.play()
	
func _ready() -> void:
	healthbar.visible = false
	random_sound = walking_sounds.pick_random()

func _process(delta: float) -> void:
	var distance_to_player = position.distance_to(player.position)
	look_at(player.position)
	if distance_to_player > attack_range:
		direction = player.position - position
		speed = randi_range(200,300)
		position += direction.normalized() * speed * delta
		if direction != Vector2.ZERO:
			animated_sprite.play("move")
			play_walk_sfx()
			
	else:
		direction = Vector2.ZERO
		animated_sprite.play("attack")
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bullet":
		body.queue_free()
		var damage = randi_range(25,55)
		damage_received(damage)
		if current_hp <= 0:
			var blood_render = BLOOD_DEATH.instantiate()
			blood_render.position = position
			get_parent().add_child(blood_render)
			blood_render.create_big_stain()
			queue_free()
			enemy_dead.emit()
		else:
			var blood_render = BLOOD_HIT.instantiate()
			blood_render.position = position
			get_parent().add_child(blood_render)
			blood_render.create_small_stain()
	if body.name == "Player":
		var zombie_damage = randi_range(15,20)
		damage_dealt.emit(zombie_damage)
		attack_timer.start()
		walking_sfx.stop()
	if not is_instance_valid(player):
		attack_timer.stop()
		return
func _on_enemy_dead() -> void:
	pass # Replace with function body.
	
func _on_damage_dealt(damage: Variant) -> void:
	pass # Replace with function body.


func _on_attack_timer_timeout() -> void:
		var zombie_damage = randi_range(15,20)
		damage_dealt.emit(zombie_damage)
	


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		attack_timer.stop()
