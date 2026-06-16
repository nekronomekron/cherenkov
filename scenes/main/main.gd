extends Node2D

func _ready() -> void:
	var player_ship = Ship.new()
	player_ship.add_module("core_module", [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)], true)
	player_ship.add_module("core_module", [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)], false)
	
	%ShipBuilder.setup(player_ship)
