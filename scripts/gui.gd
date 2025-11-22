extends Control

signal difficulty_selected(index)

const TILEMAP_SQUARE_LENGTH: int = 16
const BACKGROUND_SPR_OFFSET: int = 7

@onready var flag_count: Label = $MarginContainer/MainGame/Top/MarginContainer/Infobar/Flags/FlagInfo/FlagCount
@onready var time: Label = $MarginContainer/MainGame/Top/MarginContainer/Infobar/Stopwatch/Time


func item_selected(index: int) -> void:
	difficulty_selected.emit(index)


func _display_flag_count(count: int) -> void:
	flag_count.text = str(count)


func _display_stopwatch_time(seconds: int) -> void:
	time.text = str(seconds)


func _resize(width: int, height: int, minefield_pos: Vector2) -> void:
	size.x = (width * TILEMAP_SQUARE_LENGTH) + minefield_pos.x + BACKGROUND_SPR_OFFSET
	size.y = (height * TILEMAP_SQUARE_LENGTH) + minefield_pos.y + BACKGROUND_SPR_OFFSET
	
