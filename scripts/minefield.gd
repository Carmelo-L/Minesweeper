extends Node2D

const LEFT_CLICK: int 	= 1
const RIGHT_CLICK: int 	= 2
const NO_SPRITE: int 	= -1
const EMPTY_TILE 		= {
	"id": 0,
	"atlas": Vector2i(0,0),
}
const TILE 				= {
	"id": 1,
	"atlas": Vector2i(0,0),
}
const FLAG 				= {
	"id": 2,
	"atlas": Vector2i(0,0),
}

@onready var minefield_bottom: TileMapLayer = $"Minefield - Bottom"
@onready var minefield_middle: TileMapLayer = $"Minefield - Middle"
@onready var minefield_top: TileMapLayer = $"Minefield - Top"

@export var rows: int = 8
@export var cols: int = 8


func _initialise_minefield(rows: int, cols: int) -> void:
	var left_x: int		= -(rows/2)
	var right_x: int	= rows/2
	var top_y: int		= -(cols/2)
	var bottom_y: int	= cols/2
	
	var h: int = top_y
	while h != bottom_y:
		
		var r: int = left_x
		while r != right_x:
			minefield_bottom.set_cell(Vector2i(r,h), EMPTY_TILE.id, EMPTY_TILE.atlas)
			minefield_middle.set_cell(Vector2i(r,h), TILE.id, TILE.atlas)
			r += 1
		h += 1


func _add_or_remove_flag(coords: Vector2i) -> void:
	var top_cell_id: int = minefield_top.get_cell_source_id(coords)
	var mid_cell_id: int = minefield_middle.get_cell_source_id(coords)
	
	if top_cell_id == NO_SPRITE and mid_cell_id != NO_SPRITE:
		minefield_top.set_cell(coords, FLAG.id, FLAG.atlas)
	elif top_cell_id == FLAG.id:
		minefield_top.erase_cell(coords)


func _clear_tile(coords: Vector2i) -> void:
	var cell_id: int = minefield_top.get_cell_source_id(coords)
	
	if cell_id != FLAG.id:
		minefield_middle.erase_cell(coords)


func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or not event.pressed:
		return
	
	var coords: Vector2i = minefield_top.local_to_map(get_local_mouse_position())
	
	match event.button_index:
		RIGHT_CLICK:
			_add_or_remove_flag(coords)
		LEFT_CLICK:
			_clear_tile(coords)


func _ready():
	_initialise_minefield(rows, cols)
