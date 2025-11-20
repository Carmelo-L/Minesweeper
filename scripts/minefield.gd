class_name Minefield

extends Node2D

signal flags_edited(edit)
signal game_state_changed(state)

const LEFT_CLICK: int 		= 1
const RIGHT_CLICK: int 		= 2
const NO_SPRITE: int 		= -1
const EMPTY: int			= 0
const BOMB: int 			= 1
const GAINED_FLAG: int 		= 1
const USED_FLAG: int 		= -1
const EMPTY_TILE_SPR 		= {
	"id": 0,
	"atlas": Vector2i(0,0),
}
const TILE_SPR: Dictionary 				= {
	"id": 1,
	"atlas": Vector2i(0,0),
}
const FLAG_SPR: Dictionary 				= {
	"id": 2,
	"atlas": Vector2i(0,0),
}
const CHECKED_SPR: Dictionary 			= {
	"id": 2,
	"atlas": Vector2i(0,0),
}
const BOMB_SPR: Dictionary				= {
	"id": 3,
	"atlas": Vector2i(0,0),
}
const BOMB_BACKGROUND_SPR: Dictionary	= {
	"id": 4,
	"atlas": Vector2i(0,0),
}
# atlas coordinates of number sprites from 1-8
const NUMBER_SPRITES: Array[Vector2i] = [Vector2i(1,2), Vector2i(0,0), 
		Vector2i(1,0), Vector2i(2,0), Vector2i(0,1), Vector2i(1,1), 
		Vector2i(2,1), Vector2i(0,2)]
const NUM_ID: int = 13
const GAME_STOPPED: bool = false
const GAME_STARTED: bool = true

@export var rows: int
@export var cols: int
@export var bombs: int

var first_click: bool
var game_ongoing: bool = true
var flags: int

@onready var minefield_checked: TileMapLayer 	= $"Minefield - Checked"
@onready var minefield_background: TileMapLayer = $"Minefield - Background"
@onready var minefield_contents: TileMapLayer 	= $"Minefield - Contents"
@onready var minefield_tile: TileMapLayer 		= $"Minefield - Tile"
@onready var minefield_flag: TileMapLayer 		= $"Minefield - Flag"


## Clears all sprites then ets minefield background, tile, and contents layer to appropriate sprites
func _initialise_minefield() -> void:
	minefield_checked.clear()
	minefield_background.clear()
	minefield_contents.clear()
	minefield_tile.clear()
	minefield_flag.clear()
	
	for c in cols:
		for r in rows:
			var coords:= Vector2i(c, r)
			minefield_background.set_cell(coords, EMPTY_TILE_SPR.id, EMPTY_TILE_SPR.atlas)
			minefield_tile.set_cell(coords, TILE_SPR.id, TILE_SPR.atlas)


func _is_checked(coords: Vector2i) -> bool:
	return minefield_checked.get_cell_source_id(coords) == CHECKED_SPR.id


func _flag_signal(quantity: int) -> void:
	flags += quantity
	flags_edited.emit(flags)


## Adds a flag to a given tile if there is an untouched tile, removes flag on given tile 
## 	if flag is present or adjacently checked
## coords: coordinates of the given tilemap cell
func _add_or_remove_flag(coords: Vector2i) -> void:
	var flag_cell_id: int = minefield_flag.get_cell_source_id(coords)
	var tile_cell_id: int = minefield_tile.get_cell_source_id(coords)

	if (flag_cell_id == NO_SPRITE and 
			tile_cell_id == TILE_SPR.id and 
			not _is_checked(coords) and 
			flags > 0):

		minefield_flag.set_cell(coords, FLAG_SPR.id, FLAG_SPR.atlas)
		_flag_signal(USED_FLAG)
		
	elif flag_cell_id == FLAG_SPR.id:
		minefield_flag.erase_cell(coords)
		_flag_signal(GAINED_FLAG)


func _is_bomb(coords: Vector2i) -> bool:
	return minefield_contents.get_cell_source_id(coords) == BOMB_SPR.id


func _get_bombs() -> Array[Vector2i]:
	var bomb_list: Array[Vector2i] = []
	for cell in minefield_contents.get_used_cells():
		if _is_bomb(cell):
			bomb_list.append(cell)
	return bomb_list


## Shows all bombs present on map
func _expose_bombs() -> void:
	for tile in _get_bombs():
		minefield_tile.erase_cell(tile)


func _game_over() -> void:
	game_ongoing = GAME_STOPPED
	game_state_changed.emit(GAME_STOPPED)


## Handles logic results of clicking on a tile
## coords: coordinates of the given tilemap cell
func _remove_tile(coords: Vector2i) -> void:	
	if _is_bomb(coords):
		minefield_tile.set_cell(coords, BOMB_SPR.id, BOMB_SPR.atlas)
		minefield_background.set_cell(coords, BOMB_BACKGROUND_SPR.id, BOMB_BACKGROUND_SPR.atlas)
		_expose_bombs()
		_game_over()
	else:
		_clear_adj_tiles(coords)


## Handles visual results of cliking on a tile, as well as clearing flags
func _clear_tile(coords: Vector2i) -> void:
	var flag_cell_id: int = minefield_flag.get_cell_source_id(coords)
	
	if flag_cell_id == FLAG_SPR.id: 
		minefield_flag.erase_cell(coords)
		_flag_signal(GAINED_FLAG)
		
	minefield_tile.erase_cell(coords)
	minefield_checked.set_cell(coords, CHECKED_SPR.id, CHECKED_SPR.atlas)


### coords: coordinates of the given tilemap cell
func _get_adj_cells(coords: Vector2i) -> Array[Vector2i]:
	var adj_cells: Array[Vector2i] = minefield_contents.get_surrounding_cells(coords)
	adj_cells.append(Vector2i(coords.x - 1, coords.y - 1))
	adj_cells.append(Vector2i(coords.x - 1, coords.y + 1))
	adj_cells.append(Vector2i(coords.x + 1, coords.y - 1))
	adj_cells.append(Vector2i(coords.x + 1, coords.y + 1))
	return adj_cells


### coords: coordinates of the given tilemap cell
func _get_adj_bombs(adj_cells: Array[Vector2i]) -> int:
	var adj_bombs: int = 0
	for cell in adj_cells:
		if _is_bomb(cell):
			adj_bombs += 1
	return adj_bombs


## Removes adjacent empty tiles from given tile
## coords: coordinates of the given tilemap cell
# @tutorial: https://tait.tech/2020/09/12/minesweeper/
func _clear_adj_tiles(coords: Vector2i) -> int:
	var adj_bombs: int 		= 0

	if (coords.x < 0 or coords.x >= cols or 
			coords.y < 0 or coords.y >= rows):
		return EMPTY

	# avoids checking already cleared tiles
	if _is_checked(coords):
		return EMPTY

	if _is_bomb(coords):
		return BOMB

	_clear_tile(coords)

	var adj_cells: Array[Vector2i] = _get_adj_cells(coords)
	adj_bombs = _get_adj_bombs(adj_cells)
	
	if adj_bombs > 0:
		minefield_contents.set_cell(coords, NUM_ID, NUMBER_SPRITES[adj_bombs - 1])
	else:
		for cell in adj_cells:
			_clear_adj_tiles(cell)

	return EMPTY


## Determines if player can click given tile, clicks if so
## coords: coordinates of the given tilemap cell
func _click_tile(coords: Vector2i) -> void:
	var cell_id: int = minefield_flag.get_cell_source_id(coords)
	
	if cell_id != FLAG_SPR.id:
		_remove_tile(coords)
		_clear_adj_tiles(coords)


## Fills tilemap layer with bombs
func _generate_bombs() -> void:
	var random = RandomNumberGenerator.new()
	var bomb_count: int = 0
	
	while bomb_count < bombs:
		var r_x: int = random.randi_range(0, cols - 1)
		var r_y: int = random.randi_range(0, rows - 1)
		var coords:= Vector2i(r_x, r_y)

		if not _is_bomb(coords):
			minefield_contents.set_cell(coords, BOMB_SPR.id, BOMB_SPR.atlas)
			bomb_count += 1


## Regenerates map until the given coords are in an empty space
func _start_empty(coords: Vector2i) -> void:
	while (minefield_contents.get_cell_source_id(coords) != NO_SPRITE or
			_get_adj_bombs(_get_adj_cells(coords)) != 0):
				
		_start_game()
	first_click = false
	game_state_changed.emit(GAME_STARTED)


func _start_game() -> void:
	_initialise_minefield()
	_generate_bombs()

func _ready() -> void:
	flags = bombs
	first_click = true
	game_ongoing = true
	_start_game()


func _input(event: InputEvent) -> void:
	if (not event is InputEventMouseButton 
			or not event.pressed
			or game_ongoing == GAME_STOPPED):
		return
	
	var coords: Vector2i = minefield_tile.local_to_map(get_local_mouse_position())
	
	if ((coords.x < 0 or coords.x > cols or 
			coords.y < 0 or coords.y > rows)):
		return
	
	match event.button_index:
		RIGHT_CLICK:
			_add_or_remove_flag(coords)
		LEFT_CLICK:
			if first_click:
				_start_empty(coords)
			_click_tile(coords)
