extends Node2D

const EASY: Dictionary		= {
	"rows": 8,
	"cols": 8,
	"bombs": 10,
}
const MEDIUM: Dictionary	= {
	"rows": 16,
	"cols": 16,
	"bombs": 40,
}
const HARD: Dictionary		= {
	"rows": 16,
	"cols": 30,
	"bombs": 99,
}
const EXTREME: Dictionary	= {
	"rows": 50,
	"cols": 150,
	"bombs": 2440,
}
const CUSTOM: Dictionary	= {
	"rows": 0,
	"cols": 0,
	"bombs": 0,
}
const CUSTOM_INDEX: int = 4
const DIFFICULTY: Array[Dictionary] = [EASY, MEDIUM, HARD, EXTREME]
const DEFAULT_DIFFICULTY: int = 0

@onready var minefield: Minefield = $Minefield
@onready var gui: Control = $GUI
@onready var custom_panel: Panel = $CustomPanel

var elapse_time: bool	= false
var time_elapsed: float	= 0.0


func _ready() -> void:
	_start_game(DEFAULT_DIFFICULTY)


func _process(delta: float) -> void:
	if elapse_time:
		time_elapsed += delta
		gui._display_stopwatch_time(int(time_elapsed))


func _start_minefield(diff: Dictionary) -> void:
	minefield.rows = diff.rows
	minefield.cols = diff.cols
	minefield.bombs = diff.bombs
	minefield._ready()


# Sets window and viewport to be same size as gui background
func _start_viewport():
	DisplayServer.window_set_size(gui.size * 2)
	get_tree().root.set_content_scale_size(gui.size)


func _start_gui(diff: Dictionary) -> void:
	_on_minefield_flags_edited(diff.bombs)
	gui._resize(diff.cols, diff.rows, minefield.position)
	gui._display_stopwatch_time(int(time_elapsed))


func _start_game(difficulty: int) -> void:
	time_elapsed = 0.0
	elapse_time = false
	var diff: Dictionary = DIFFICULTY[difficulty]
	_start_minefield(diff)
	_start_gui(diff)
	_start_viewport()


func _on_difficulty_selected(index: Variant) -> void:
	#if index == CUSTOM_INDEX:
		#
	#else:
		_start_game(index)


func _on_minefield_flags_edited(edit: int) -> void:
	gui._display_flag_count(edit)


func _on_minefield_game_state_changed(state: Variant) -> void:
	elapse_time = state
