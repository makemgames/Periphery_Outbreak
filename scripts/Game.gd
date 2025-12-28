extends Node

var start_mode := "menu" # "menu" | "game"

var last_score: int = 0
var highscore: int = 0


func _ready() -> void:
	load_highscore()


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
