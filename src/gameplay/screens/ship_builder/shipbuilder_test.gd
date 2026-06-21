extends BaseScene

@onready var ship_builder = $PanelContainer/ShipBuilder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ship = Ship.new()
	ship.type = "basic"
	
	ship.add_module("core_module", [Vector2i(0, 0)], false)
	ship.add_module("core_module", [Vector2i(0, 1)], false)
	ship.add_module("core_module", [Vector2i(0, 2)], false)
	ship.add_module("core_module", [Vector2i(1, 2)], false)
	
	ship_builder.load_from_ship(ship)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
