extends CharacterBody2D


@onready var body_sprite: AnimatedSprite2D = $Body
@onready var legs_sprite: AnimatedSprite2D = $Legs
@onready var reload_animator: AnimationPlayer = $Reload_animator
@onready var walking_sound: AudioStreamPlayer2D = $SFX/Walking_sound
@onready var pistol_shooting_sound: AudioStreamPlayer2D = $SFX/Pistol_shooting_sound
@onready var pistol_shot_timer: Timer = $Pistol_shot
@onready var pistol_reload: AudioStreamPlayer2D = $SFX/Pistol_reload

var move_speed := 200
var is_reloading := false
var is_shot := false
var is_running := false:
	set(value):
		is_running = value 
		move_speed = 400 if value else 200

func start_reload_anim():
	is_reloading = true
	body_sprite.play("reload_pistol")

func end_reload_anim():
	is_reloading = false

func _physics_process(delta: float) -> void:
	#Movement
	is_running = Input.is_action_pressed("run")
	var direction: Vector2 = Input.get_vector("move_left","move_right","move_up","move_down")
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * move_speed
		# Run faster
		if is_running:
			walking_sound.pitch_scale = 2.2
			walking_sound.volume_db = -4.0
		else:
			walking_sound.pitch_scale = randf_range(1,1.7)
			walking_sound.volume_db = -8.0
		if not walking_sound.playing:
			walking_sound.play()
	else:	
		velocity = Vector2.ZERO
		walking_sound.stop()
	
	#Rotation after mouse
	look_at(get_global_mouse_position())
	rotation_degrees -= 15
	
	#Animation body
	if Input.is_action_just_pressed("reload") and not is_reloading:
		is_reloading = true
		pistol_reload.pitch_scale = 2.6
		pistol_reload.play()
	if is_reloading:
		reload_animator.play("reload_logic")
	elif Input.is_action_pressed("shoot") and not is_shot and not is_reloading:
		pistol_shot_timer.start()
		is_shot = true
		body_sprite.play("shoot_pistol")
		pistol_shooting_sound.play()
	elif direction != Vector2.ZERO:
		body_sprite.play("pistol_move")
	else:
		body_sprite.play("pistol_idle")

	#Animations legs
	if direction != Vector2.ZERO and is_running == true:
		legs_sprite.play("legs_run")
	elif direction != Vector2.ZERO:
		legs_sprite.play("legs_walk")
	else:
		legs_sprite.play("legs_idle")

	move_and_slide()


func _on_pistol_shot_timeout() -> void:
	is_shot = false
