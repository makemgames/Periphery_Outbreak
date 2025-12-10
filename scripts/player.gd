extends CharacterBody2D


@onready var body_sprite: AnimatedSprite2D = $Body
@onready var legs_sprite: AnimatedSprite2D = $Legs
@onready var reload_animator: AnimationPlayer = $Reload_animator
@onready var walking_sound: AudioStreamPlayer = $SFX/Walking_sound
@onready var pistol_shooting_sound: AudioStreamPlayer = $SFX/Pistol_shooting_sound
@onready var pistol_reload_sfx: AudioStreamPlayer = $SFX/Pistol_reload
@onready var bullet = preload("res://scenes/bullet.tscn")
@onready var empty_gun: AudioStreamPlayer = $SFX/Empty_gun
@onready var rifle_shooting_sound: AudioStreamPlayer = $SFX/Rifle_shooting_sound
@onready var pistol_muzzle_flash: Sprite2D = $Gunshot_point/Pistol_muzzle_flash
@onready var rifle_muzzle_flash: Sprite2D = $Gunshot_point/Rifle_muzzle_flash
@onready var shooting_timer: Timer = $Shooting_timer

signal ammo_updated(current,reserve)
signal weapon_changed

var move_speed := 250
var is_reloading := false
var is_shot := false

var pistol_data = {
	"name": "pistol",
	"max_ammo": 28,
	"max_mag_ammo": 7,
	"reserve_ammo": 21,
	"idle": "pistol_idle",
	"reload": "pistol_reload",
	"shoot": "pistol_shoot",
	"move": "pistol_move",
	"fire_rate": 0.33,
}

var rifle_data = {
	"name": "rifle",
	"max_ammo": 120,
	"max_mag_ammo": 30,
	"reserve_ammo": 90,
	"idle": "rifle_idle",
	"reload": "rifle_reload",
	"shoot": "rifle_shoot",
	"move": "rifle_move",
	"fire_rate": 0.1,
}

var current_weapon = pistol_data
var current_ammo = current_weapon.max_mag_ammo

func weapon_switch():
	current_weapon = rifle_data
	current_ammo = rifle_data.max_mag_ammo
	ammo_updated.emit(current_ammo,current_weapon["reserve_ammo"])
	weapon_changed.emit()
	
var is_running := false:
	set(value):
		is_running = value 
		move_speed = 450 if value else 250
	
func start_reload_anim():
	is_reloading = true
	body_sprite.play(current_weapon.reload)

func end_reload_anim():
	is_reloading = false

func ammo_counter():
	current_ammo = current_ammo - 1

func fire_weapon():
	shooting_timer.start()
	shooting_timer.wait_time = current_weapon.fire_rate
	body_sprite.play(current_weapon.shoot)
	if current_weapon == pistol_data:
		pistol_shooting_sound.play()
	else:
		rifle_shooting_sound.play()
	is_shot = true
	var bullet = bullet.instantiate()
	var mouse_position = get_global_mouse_position()
	var gunshot_pos = $Gunshot_point.global_position
	bullet.dir = rotation
	bullet.pos = gunshot_pos
	bullet.rot = global_rotation
	get_parent().add_child(bullet)
	
func reload_weapon():
	var needed_ammo = current_weapon["max_mag_ammo"] - current_ammo
	if current_ammo == current_weapon["max_mag_ammo"]:
		return
	elif current_weapon["reserve_ammo"] == 0:
		return
	if current_weapon["reserve_ammo"] >= needed_ammo:
		current_ammo = current_weapon["max_mag_ammo"]
		current_weapon["reserve_ammo"] = current_weapon["reserve_ammo"] - needed_ammo
	else:
		current_ammo += current_weapon["reserve_ammo"]
		current_weapon["reserve_ammo"] = 0
	ammo_updated.emit(current_ammo,current_weapon["reserve_ammo"])
	
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
	rotation_degrees -= 6
	
	#Animation body
	pistol_muzzle_flash.visible = false
	rifle_muzzle_flash.visible = false
	
	if Input.is_action_just_pressed("reload") and not is_reloading:
		if current_ammo == current_weapon["max_mag_ammo"]:
			pass
		elif current_weapon.reserve_ammo == 0:
			pass
		else:
			is_reloading = true
			pistol_reload_sfx.play()
			reload_animator.play("reload_logic")
			reload_weapon()
			
	if is_reloading:
		reload_animator.play("reload_logic")
	
	elif Input.is_action_pressed("shoot") and not is_shot and not is_reloading and current_ammo >= 1:
		fire_weapon()
		print(current_ammo)
		if current_weapon == pistol_data:
			pistol_muzzle_flash.visible = true
		else:
			rifle_muzzle_flash.visible = true
		ammo_counter()
		if current_ammo <= 0:
			current_ammo = 0
		ammo_updated.emit(current_ammo,current_weapon["reserve_ammo"])

	elif Input.is_action_just_pressed("shoot") and current_ammo == 0:
		empty_gun.play()
	elif direction != Vector2.ZERO:
		body_sprite.play(current_weapon.move)
	else:
		body_sprite.play(current_weapon.idle)

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


func _on_ammo_updated(current: Variant, reserve: Variant) -> void:
	pass # Replace with function body.


func _on_weapon_changed() -> void:
	pass # Replace with function body.
