extends GridContainer

@export var height: int		= 8
@export var width: int		= 8

func _initialise_minefield(hieght: int, width: int):
	for h in height:
		for w in width:
			fit_child_in_rect(Tile.new(), Rect2(Vector2(w,h),Vector2(20,20)))
			

func _ready():
	columns = width
	_initialise_minefield(height, width)
