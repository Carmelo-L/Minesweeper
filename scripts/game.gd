extends Node2D

const EASY = {
	"rows": 8,
	"cols": 8,
	"bombs": 10,
}
const MEDIUM = {
	"rows": 16,
	"cols": 16,
	"bombs": 40,
}
const HARD = {
	"rows": 16,
	"cols": 30,
	"bombs": 99,
}

@onready var minefield: Minefield = $Minefield


func _ready() -> void:
	minefield.rows = 8
	minefield.cols = 8
	minefield.bombs = 8
	minefield._ready()
	
	
func _on_minefield_flags_edited(edit: int) -> void:
	print(edit)
