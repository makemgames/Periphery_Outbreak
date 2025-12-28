extends CanvasLayer

@onready var player = get_node("../Player")
@onready var ammo_label: Label = $Control/Ammo_container/Ammo
@onready var weapon_icon: TextureRect = $Control/Weapon
@onready var ammo_icon: TextureRect = $Control/Ammo_container/Ammo_icon
@onready var stamina_bar: ProgressBar = $Control/Stamina_container/Stamina_bar
@onready var stamina_text: Label = $Control/Stamina_container/Stamina_bar/Stamina_text
@onready var health_text: Label = $Control/Health_container/Health_bar/Health_text
@onready var health_bar: ProgressBar = $Control/Health_container/Health_bar
@onready var kill_count_number: Label = $Control/Kill_count/Kill_count_number
@onready var health_container: HBoxContainer = $Control/Health_container
@onready var ammo_container: HBoxContainer = $Control/Ammo_container
@onready var stamina_container: HBoxContainer = $Control/Stamina_container
@onready var weapon_container: TextureRect = $Control/Weapon




func _ready() -> void:
	player.connect("ammo_updated", Callable(self,"ui_update_ammo"))
	player.connect("weapon_changed", Callable(self,"update_weapon_icon"))
	player.connect("stamina_updated", Callable(self,"update_stamina"))
	player.connect("health_updated", Callable(self,"update_health"))
	update_stamina(player.current_stamina)
	update_health(player.current_health)
	update_killcount(0)
	get_viewport().get_visible_rect().size
	var s := get_viewport().get_visible_rect().size
	var y := s.y - 40
	await get_tree().process_frame
	stamina_container.position = Vector2(s.x*0.25 - stamina_container.size.x*0.5, y - stamina_container.size.y*0.5)
	health_container.position  = Vector2(s.x*0.50 - health_container.size.x*0.5,  y - health_container.size.y*0.5)
	ammo_container.position = Vector2(s.x*0.75 - ammo_container.size.x*0.5, y - ammo_container.size.y*0.5)
	weapon_container.position = Vector2(s.x*.81 - weapon_container.size.x*0.5, y - weapon_container.size.y*0.5 )
	
func update_weapon_icon():
	weapon_icon.texture = load("res://assets/sprites/UI/AKM.png")
	ammo_icon.texture = load("res://assets/sprites/UI/ammo-rifle 32px.png")
	
func ui_update_ammo(current,reserve):
	ammo_label.text = "Ammo " + str(current) + "/" + str(reserve)
	
func update_stamina(stamina):
	stamina_bar.value = stamina
	stamina_text.text = str(stamina)
	#
func update_health(health):
	health_bar.value = health
	health_text.text = str(health)
	
func update_killcount(value):
	kill_count_number.text = str(value)
