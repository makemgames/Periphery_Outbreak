extends CanvasLayer

@onready var player = get_node("../Player")
@onready var ammo_label: Label = $Control/Ammo_container/Ammo
@onready var weapon_icon: TextureRect = $Control/Weapon

func ui_update_ammo(current,reserve):
	ammo_label.text = "Ammo " + str(current) + "/" + str(reserve)

func update_weapon_icon():
	weapon_icon.texture = load("res://assets/sprites/UI/AKM.png")
		

func _ready() -> void:
	player.connect("ammo_updated", Callable(self,"ui_update_ammo"))
	player.connect("weapon_changed", Callable(self,"update_weapon_icon"))
	var current = player.current_ammo
	var reserve = player.current_weapon.reserve_ammo
# Called every frame. 'delta' is the elapsed time since the previous frame.
