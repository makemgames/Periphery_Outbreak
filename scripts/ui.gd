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
@onready var time_number: Label = $Win_menu/Stats_container/Time_row/Time_number

@onready var you_died_theme: AudioStreamPlayer = $SFX/YouDiedTheme
@onready var main_menu_theme: AudioStreamPlayer = $SFX/MainMenuTheme
@onready var game_won_theme: AudioStreamPlayer = $SFX/GameWonTheme
@onready var game_sounds: AudioStreamPlayer = $SFX/GameSounds

var loading_action := ""
var death_triggered := false


func _set_music(mode: String) -> void:
	# "menu" / "game" / "death" / "win"
	match mode:
		"menu":
			if game_sounds.playing: game_sounds.stop()
			if you_died_theme.playing: you_died_theme.stop()
			if game_won_theme.playing: game_won_theme.stop()
			if !main_menu_theme.playing: main_menu_theme.play()

		"game":
			if main_menu_theme.playing: main_menu_theme.stop()
			if you_died_theme.playing: you_died_theme.stop()
			if game_won_theme.playing: game_won_theme.stop()
			if !game_sounds.playing: game_sounds.play()

		"death":
			if main_menu_theme.playing: main_menu_theme.stop()
			if game_sounds.playing: game_sounds.stop()
			if game_won_theme.playing: game_won_theme.stop()
			if !you_died_theme.playing: you_died_theme.play()

		"win":
			if main_menu_theme.playing: main_menu_theme.stop()
			if game_sounds.playing: game_sounds.stop()
			if you_died_theme.playing: you_died_theme.stop()
			if !game_won_theme.playing: game_won_theme.play()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if main_menu.visible or death_menu.visible or win_menu.visible or loading_menu.visible:
			return

		if pause_menu.visible:
			# закрываем паузу -> назад в игру
			get_tree().paused = false
			hide_all_menus()
			game_sounds.play()
			main_menu_theme.stop()
		else:
			# ОТКРЫВАЕМ ПАУЗУ -> глушим игру, включаем меню
			get_tree().paused = true
			show_state("pause")

			game_sounds.stop()
			main_menu_theme.play()

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
	win_menu.visible = false


func _ready() -> void:
	hide_all_menus()

	# стартовая музыка/состояние
	if Game.start_mode == "menu":
		get_tree().paused = true
		show_state("main")
		_set_music("menu")
	else: # "game"
		get_tree().paused = false
		hide_all_menus()
		_set_music("game")

	var vp = get_viewport().get_visible_rect().size
	loading_container.position = Vector2(vp.x * 0.85, vp.y - 120)


func _process(_delta: float) -> void:
	if !loading_menu.visible:
		return
	if loading_timer.is_stopped():
		return

	var t := 1.0 - (loading_timer.time_left / loading_timer.wait_time)
	loading_bar.value = t * 100.0


func _on_player_dead() -> void:
	if death_triggered:
		return
	death_triggered = true

	Engine.time_scale = 0.15
	await get_tree().create_timer(0.6).timeout
	Engine.time_scale = 1.0

	get_tree().paused = true
	show_state("death")
	_set_music("death")
	Game.stop_run()


func player_wins() -> void:
	get_tree().paused = true
	show_state("win")
	_set_music("win")

	kills_number.text = str(Game.last_score)
	best_number.text = str(Game.highscore)
	time_number.text = Game.get_time_mm_ss()
	Game.stop_run()


# Main menu buttons
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_new_game_pressed() -> void:
	hide_all_menus()
	show_state("loading")
	_set_music("menu") # чтобы на лоадинге не лупил game_sounds

	loading_action = "new_game"
	loading_timer.wait_time = randf_range(3.0, 6.0)
	loading_bar.value = 0
	loading_timer.start()

	Game.start_run()


# Death scene buttons
func _on_retry_pressed() -> void:
	hide_all_menus()
	show_state("loading")
	_set_music("menu") # на лоадинге меню-тема

	loading_action = "retry"
	loading_timer.wait_time = randf_range(3.0, 6.0)
	loading_bar.value = 0
	loading_timer.start()

	Game.start_run()


func _on_main_menu_pressed() -> void:
	hide_all_menus()
	Game.start_mode = "menu"
	get_tree().paused = false
	_set_music("menu")
	get_tree().reload_current_scene()


func _on_continue_pressed() -> void:
	get_tree().paused = false
	hide_all_menus()
	_set_music("game")


func _on_loading_timer_timeout() -> void:
	hide_all_menus()
	get_tree().paused = false
	loading_bar.value = 100

	match loading_action:
		"new_game":
			Game.start_mode = "game"
			# при перезагрузке _ready сам включит game
			get_tree().reload_current_scene()
		"retry":
			Game.start_mode = "game"
			get_tree().reload_current_scene()
		_:
			pass
