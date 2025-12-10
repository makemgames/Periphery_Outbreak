extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"../Player"
@onready var healthbar: TextureProgressBar = $Healthbar

const BLOOD_HIT = preload("uid://fxt3fbsv6536")
const BLOOD_DEATH = preload("uid://divkwpemyobhk")

@export var max_hp: int = 100

var direction: Vector2
var speed = 200
var current_hp: int = max_hp
signal enemy_dead
var attack_range = 150

func damage_dealt(dmg):
	current_hp = current_hp - dmg
	current_hp = max(current_hp,0)
	healthbar.value = current_hp
	healthbar.visible = true
	
func _ready() -> void:
	healthbar.visible = false

	
func _process(delta: float) -> void:
	var distance_to_player = position.distance_to(player.position)
	look_at(player.position)
	if distance_to_player > attack_range:
		direction = player.position - position
		speed = randi_range(200,300)
		position += direction.normalized() * speed * delta
		if direction != Vector2.ZERO:
			animated_sprite.play("move")
	else:
		direction = Vector2.ZERO
		animated_sprite.play("attack")
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bullet":
		body.queue_free()
		var damage = randi_range(25,55)
		damage_dealt(damage)
		print(current_hp)
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

func _on_enemy_dead() -> void:
	pass # Replace with function body.
