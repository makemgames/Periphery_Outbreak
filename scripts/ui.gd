extends CanvasLayer

@onready var new_game: Button = $Main_menu/VBoxContainer/New_game
@onready var quit: Button = $Main_menu/VBoxContainer/Quit
@onready var main_menu: Control = $Main_menu
@onready var pause_menu: Control = $Pause_menu
@onready var death_menu: Control = $Death_menu
@onready var loading_menu: Control = $Loading
@onready var win_menu: Control = $Win_menu
@onready var loading_container: VBoxContainer = $Loading/VBoxContainer
@onready var loading_bar: ProgressBar = $Loading/VBoxContainer/Loading_bar
@onready var loading_timer: Timer = $Loading_timer
@onready var best_number: Label = $Win_menu/Stats_container/Best_row/Best_number
@onready var kills_number: Label = $Win_menu/Stats_container/Kills_row/Kills_number


var loading_action := ""

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if pause_menu.visible:
			get_tree().paused = false
			hide_all_menus()
			get_viewport().set_input_as_handled()

func show_state(state: String) -> void:
	main_menu.visible = (state == "main")
	pause_menu.visible = (state == "pause")
	death_menu.visible = (state == "death")
	loading_menu.visible = (state == "loading")
	win_menu.visible = (state == "win")

func hide_all_menus() -> void:
	main_menu.visible = false
	pause_menu.visible = false
	death_menu.visible = false
	loading_menu.visible = false
	
func _on_player_dead():
	get_tree().paused = true
	show_state("death")
	
func player_wins():
	get_tree().paused = true
	hide_all_menus()
	show_state("win")
	kills_number.text = "Score " + str(Game.last_score)
	best_number.text = str(Game.highscore)
	

func _ready() -> void:
	hide_all_menus()
	if Game.start_mode == "menu":
		get_tree().paused = true
		show_state("main")
	else: # "game"
		get_tree().paused = false
		hide_all_menus()
	
	var vp = get_viewport().get_visible_rect().size
	loading_container.position = Vector2(
		vp.x * 0.85,
		vp.y - 120
	)

func _process(_delta):
	if !loading_menu.visible:
		return
	if loading_timer.is_stopped():
		return
	var time = 1.0 - (loading_timer.time_left / loading_timer.wait_time)
	loading_bar.value = time * 100

#Main menu buttons
func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_new_game_pressed() -> void:
	hide_all_menus()
	show_state("loading")
	loading_action = "new_game"
	loading_timer.wait_time = randf_range(3.0, 6.0)
	loading_bar.value = 0
	loading_timer.start()
#Death scene buttons
func _on_retry_pressed() -> void:
	Game.start_mode = "game"
	hide_all_menus()
	show_state("loading")
	loading_action = "retry"
	loading_timer.wait_time = randf_range(3.0, 6.0)
	loading_bar.value = 0
	loading_timer.start()

func _on_main_menu_pressed() -> void:
	hide_all_menus()
	Game.start_mode = "menu"
	get_tree().reload_current_scene()

func _on_continue_pressed() -> void:
	get_tree().paused = false
	hide_all_menus()


func _on_loading_timer_timeout() -> void:
	hide_all_menus()
	get_tree().paused = false
	loading_bar.value = 100

	match loading_action:
		"new_game":
			Game.start_mode = "game"
			get_tree().reload_current_scene()

		"retry":
			Game.start_mode = "game"
			get_tree().reload_current_scene()
			
		_:
			pass
