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




func _ready() -> void:
	player.connect("ammo_updated", Callable(self,"ui_update_ammo"))
	player.connect("weapon_changed", Callable(self,"update_weapon_icon"))
	player.connect("stamina_updated", Callable(self,"update_stamina"))
	player.connect("health_updated", Callable(self,"update_health"))
	update_stamina(player.current_stamina)
	update_health(player.current_health)
	update_killcount(0)
	
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
