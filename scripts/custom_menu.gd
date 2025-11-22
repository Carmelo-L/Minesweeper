extends Window

signal settings_finalised(cols, rows, bombs)

@onready var menu_gui: Control = $MenuGui


func _reveal() -> void:
	show()


func _on_settings_chosen(cols: int, rows: int, bombs: int) -> void:
	hide()
	settings_finalised.emit(cols, rows, bombs)


func _on_close_requested() -> void:
	hide()
