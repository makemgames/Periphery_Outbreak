# Effect.gd
# Base class for effects (auras/status)
class_name Test
extends Node

@onready var uniqueid = %UniqueID

var party = [
	"Godot",
	"Godette",
	"Steve",
]

var character_dict = {
	"Name": "Bob",
	"Age": 27,
	"Job": "Mechanic",
}

var test:= """
	%s %d %f
"""

enum Tiles {
	TILE_BRICK,
	TILE_FLOOR,
	TILE_SPIKE,
	TILE_TELEPORT,
}


func testFunc():
	if true:
		var a = 1 * 2
	elif true:
		var a = 1 * 2 - 3
	else:
		var a = 1 * (2 - 3)
