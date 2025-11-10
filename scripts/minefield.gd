extends Node2D

const LEFT_CLICK: int 	= 1
const RIGHT_CLICK: int 	= 2
const NO_SPRITE: int 	= -1
const EMPTY: int		= 0
const BOMB: int 		= 1
const EMPTY_TILE_SPR 	= {
	"id": 0,
	"atlas": Vector2i(0,0),
}
const TILE_SPR 			= {
	"id": 1,
	"atlas": Vector2i(0,0),
}
const FLAG_SPR 			= {
	"id": 2,
	"atlas": Vector2i(0,0),
}
const BOMB_SPR			= {
	"id": 3,
	"atlas": Vector2i(0,0),
}
# atlas coordinates of number sprites from 1-8
const NUMBER_SPRITES: Array[Vector2i] = [ Vector2i(1,2), Vector2i(0,0), Vector2i(1,2), 
		Vector2i(1,0), Vector2i(2,0), Vector2i(0,1), Vector2i(1,1), 
		Vector2i(2,1), Vector2i(1,2), Vector2i(0,2)]
const NUM_ID: int = 13

@onready var minefield_bottom: TileMapLayer = $"Minefield - Bottom"
@onready var minefield_middle: TileMapLayer = $"Minefield - Middle"
@onready var minefield_top: TileMapLayer = $"Minefield - Top"

@export var rows: int 	= 8
@export var cols: int 	= 8
@export var bombs: int	= 8

var minefield: Array[Array] = []

func _initialise_minefield() -> void:
	var left_x: int		= -(rows / 2)
	var right_x: int	= rows / 2
	var top_y: int		= -(cols / 2)
	var bottom_y: int	= cols / 2
	
	var h: int = top_y
	while h != bottom_y:

		var row: Array[Dictionary] = []
		var r: int = left_x
		while r != right_x:
			var tile: Dictionary = {"bomb": false, "checked": false}
			row.append(tile)
			minefield_bottom.set_cell(Vector2i(r,h), EMPTY_TILE_SPR.id, EMPTY_TILE_SPR.atlas)
			minefield_middle.set_cell(Vector2i(r,h), TILE_SPR.id, TILE_SPR.atlas)
			r += 1

		minefield.append(row)
		h += 1


## coords: coordinates of the given tilemap cell
func _add_or_remove_flag(coords: Vector2i) -> void:
	var top_cell_id: int = minefield_top.get_cell_source_id(coords)
	var mid_cell_id: int = minefield_middle.get_cell_source_id(coords)
	
	if top_cell_id == NO_SPRITE and mid_cell_id != NO_SPRITE:
		minefield_top.set_cell(coords, FLAG_SPR.id, FLAG_SPR.atlas)
	elif top_cell_id == FLAG_SPR.id:
		minefield_top.erase_cell(coords)


## coords: coordinates of the given matrix index
func _matrix_coords_to_tile(coords: Vector2i) -> Vector2i:
	var x_coord: int = coords.y - (cols / 2)
	var y_coord: int = coords.x - (rows / 2)
	return Vector2i(x_coord,y_coord)


func _expose_bombs() -> void:
	for r in rows:
		for c in cols:
			if minefield[r][c].bomb == true:
				var a_coords: Vector2i = _matrix_coords_to_tile(Vector2i(r, c))
				minefield_top.set_cell(a_coords, BOMB_SPR.id, BOMB_SPR.atlas)


## coords: coordinates of the given tilemap cell
func _tile_coords_to_matrix(coords: Vector2i) -> Vector2i:
	var row: int = coords.y + (rows / 2)
	var col: int = coords.x + (cols / 2)
	return Vector2i(row,col)


## coords: coordinates of the given tilemap cell
func _remove_tile(coords: Vector2i) -> void:
	var m_coords: Vector2i = _tile_coords_to_matrix(coords)
	
	if minefield[m_coords.x][m_coords.y].bomb == true:
		minefield_middle.set_cell(coords, BOMB_SPR.id, BOMB_SPR.atlas)
		_expose_bombs()
	elif minefield[m_coords.x][m_coords.y].bomb == false:
		minefield_middle.erase_cell(coords)


## coords: coordinates of the given tilemap cell
# @tutorial: https://tait.tech/2020/09/12/minesweeper/
func _clear_adj_tiles(coords: Vector2i) -> int:
	var m_coords: Vector2i 	= _tile_coords_to_matrix(coords)
	var adj_bombs: int 		= EMPTY
	
	if (m_coords.x <= -1 or m_coords.x >= rows or 
			m_coords.y <= -1 or m_coords.y >= cols):
		return EMPTY
	
	# avoids checking already cleared tiles
	if minefield[m_coords.x][m_coords.y].checked == true:
		return EMPTY
	
	if minefield[m_coords.x][m_coords.y].bomb == true:
		return BOMB
	
	_remove_tile(coords)
	minefield[m_coords.x][m_coords.y].checked = true
		
	for x in range(m_coords.x - 1, m_coords.x + 2):
		for y in range(m_coords.y - 1, m_coords.y + 2):
			adj_bombs += _clear_adj_tiles(_matrix_coords_to_tile(Vector2i(x,y)))
	
	if adj_bombs > 0:
		minefield_middle.set_cell(coords, NUM_ID, NUMBER_SPRITES[adj_bombs - 1])
	
	return EMPTY


## coords: coordinates of the given tilemap cell
func _click_tile(coords: Vector2i) -> void:
	var cell_id: int = minefield_top.get_cell_source_id(coords)
	
	if cell_id != FLAG_SPR.id:
		_remove_tile(coords)
		_clear_adj_tiles(coords)

# @tutorial: https://tait.tech/2020/09/12/minesweeper/
func _generate_bombs() -> void:
	var random = RandomNumberGenerator.new()
	var bomb_count: int = 0
	
	while bomb_count < bombs:
		var r: int = random.randi_range(1, rows * cols) - 1
		var x_coord: int = r % cols
		var y_coord: int = r / rows
		
		if minefield[x_coord][y_coord].bomb == false:
			minefield[x_coord][y_coord].bomb = true
			bomb_count += 1


func _ready():
	_initialise_minefield()
	_generate_bombs()
	
	

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or not event.pressed:
		return
	
	var coords: Vector2i = minefield_top.local_to_map(get_local_mouse_position())
	
	match event.button_index:
		RIGHT_CLICK:
			_add_or_remove_flag(coords)
		LEFT_CLICK:
			_click_tile(coords)
