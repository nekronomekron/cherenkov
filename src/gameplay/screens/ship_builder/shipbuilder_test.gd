extends BaseScene

@onready var ship_builder = %ShipBuilder

var panning := false
var pan_last := Vector2.ZERO

const ZOOM_STEP := 1.12

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
func _process(_delta: float) -> void:
	pass

func _over_ship_builder(gpos: Vector2) -> bool:
	return ship_builder.get_global_rect().has_point(gpos)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var gpos: Vector2 = event.global_position
		
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					if _over_ship_builder(gpos):
						panning = true
						pan_last = gpos
				else:
					panning = false
			MOUSE_BUTTON_MIDDLE:
				if event.pressed and _over_ship_builder(gpos):
					panning = true
					pan_last = gpos
				elif not event.pressed:
					panning = false
			MOUSE_BUTTON_RIGHT:
				pass
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed and _over_ship_builder(gpos):
					ship_builder.zoom_at(gpos - ship_builder.global_position, ZOOM_STEP)
					get_viewport().set_input_as_handled()
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed and _over_ship_builder(gpos):
					ship_builder.zoom_at(gpos - ship_builder.global_position, 1.0 / ZOOM_STEP)
					get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		if panning:
			ship_builder.pan_by(event.global_position - pan_last)
			pan_last = event.global_position
