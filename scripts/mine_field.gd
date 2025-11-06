extends TileMapLayer

@export var height: int		= 8
@export var width: int		= 8
var minefield: Array[Array] = []

func _initialise_minefield(hieght: int, width: int) -> Array[Array]:
	var array: Array[Array] = []
	
	for h in height:
		var row: Array[Tile] = []
		for w in width:
			row.append(Tile.new())
		array.append(row)
	return array

func _ready():
	minefield = _initialise_minefield(height, width)
