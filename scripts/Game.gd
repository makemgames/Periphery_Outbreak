extends Node

var start_mode := "menu" # "menu" | "game"

var last_score: int = 0
var highscore: int = 0

var time_survived : float = 0
var is_run_active : bool = false

func _ready() -> void:
	load_highscore()

func _process(delta: float) -> void:
	if is_run_active == true:
		time_survived += delta

func start_run():
	is_run_active = true
	time_survived = 0.0
func stop_run():
	is_run_active = false
	
func get_time_mm_ss() -> String:
	var total := int(time_survived)
	var min := total / 60
	var sec := total % 60

	var min_str := str(min).pad_zeros(2)
	var sec_str := str(sec).pad_zeros(2)

	return min_str + ":" + sec_str

	
func submit_score(score: int) -> void:
	last_score = score

	if score > highscore:
		highscore = score
		save_highscore()

func save_highscore() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("score", "highscore", highscore)
	cfg.save("user://highscore.cfg")

func load_highscore() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://highscore.cfg") == OK:
		highscore = cfg.get_value("score", "highscore", 0)
