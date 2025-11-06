class_name Tile

extends TextureButton

const LEFT_CLICK: int 	= 1
const RIGHT_CLICK: int 	= 2
const VISIBLE: bool		= true
const INVISIBLE: bool	= false

@onready var flag: Sprite2D = $Flag
var clickable: bool = true

func _button_press() -> void:
	if clickable:
		disabled = true

func _add_or_remove_flag() -> void:
	if flag.visible:
		flag.visible = INVISIBLE
		clickable = true
	else:
		flag.visible = VISIBLE
		clickable = false

func _on_gui_input(event: InputEvent) -> void:
	if event.button_mask == LEFT_CLICK:
		_button_press()
	if event.button_mask == RIGHT_CLICK:
		_add_or_remove_flag()
