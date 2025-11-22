extends Control

signal settings_chosen(cols, rows, bombs)

@onready var col_select: SpinBox = $MarginContainer/Panel/MarginContainer/VBoxContainer/ColSelect
@onready var row_select: SpinBox = $MarginContainer/Panel/MarginContainer/VBoxContainer/RowSelect
@onready var bomb_select: SpinBox = $MarginContainer/Panel/MarginContainer/VBoxContainer/BombSelect


func _on_submit_button_pressed() -> void:
	_clamp_bombs()
	settings_chosen.emit(col_select.value, row_select.value, bomb_select.value)


func _clamp_bombs() -> void:
	var max_bombs: int = (col_select.value * row_select.value) - 1
	if bomb_select.value > max_bombs:
		bomb_select.value = max_bombs
