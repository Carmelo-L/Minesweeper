extends Control

@onready var final_time: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/FinalTime

func _game_won(background_dimensions: Vector2i, time: float) -> void:
	position.x = (background_dimensions.x / 2) - (size.x / 2)
	position.y = (background_dimensions.y / 2) - (size.y / 2)
	
	final_time.text = "Time: " + str(int(time)) + " seconds"
	show()

func _hide_win_screen() -> void:
	hide()
