extends Control

@export_group("Ship Resources")
@export var ship_types: Array[ShipResource] = []

@export_group("Grid Settings")
@export var grid_rows: int = 40
@export var grid_cols: int = 40

@export var cell_size: int = 48

@export var grid_color := Color(0.32, 0.86, 1.0, 0.34)
@export var module_border := Color(0.55, 0.85, 1.0, 0.85)
@export var module_border_locked := Color(0.30, 0.97, 0.85, 0.95)

@export_group("Zoom & Pan")
@export var zoom_min: float = 0.45
@export var zoom_max: float = 2.5

@export var pan_pad: float = 70.0

@export var pan: Vector2 = Vector2.ZERO:
	get:
		return pan
	set(value):
		pan = value
		
@export var zoom: float = 1.0:
	get:
		return zoom
	set(value):
		zoom = value

@onready var _view_root: Node2D = %ViewRoot
@onready var _tiles_root: Node2D = %TilesRoot

var _view_initialized := false

var _ship_type: String
var _modules: Array[ShipModule] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_refresh()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _on_resized() -> void:
	if not _view_initialized:
		_ensure_view()
	else:
		_clamp_pan()
	_update_view()

func _storage_bbox() -> Rect2:
	if _modules.is_empty():
		return Rect2(0, 0, cell_size, cell_size)
		
	var min_x := 1.0e20
	var min_y := 1.0e20
	var max_x := -1.0e20
	var max_y := -1.0e20
	for module in _modules:
		for cell in module.cells:
			min_x = min(min_x, cell.x)
			min_y = min(min_y, cell.y)
			max_x = max(max_x, cell.x + 1)
			max_y = max(max_y, cell.y + 1)
		
	return Rect2(min_x * cell_size, min_y * cell_size, (max_x - min_x) * cell_size, (max_y - min_y) * cell_size)

func _ensure_view() -> void:
	if _view_initialized or size.x <= 0.0:
		return
		
	var bb := _storage_bbox()
	var center_world := bb.position + bb.size / 2.0
	
	pan = size / 2.0 - center_world * zoom
	_view_initialized = true

func _update_view() -> void:
	if _view_root != null:
		_view_root.position = pan
		_view_root.scale = Vector2(zoom, zoom)

func _clamp_pan() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	
	var bb := _storage_bbox()
	var center_world := bb.position + bb.size / 2.0
	var center_screen := center_world * zoom + pan
	
	var clamped := Vector2(
		clampf(center_screen.x, pan_pad, max(pan_pad, size.x - pan_pad)),
		clampf(center_screen.y, pan_pad, max(pan_pad, size.y - pan_pad)))
		
	pan += clamped - center_screen

func _get_module_resource_for_type(module_type: String) -> ModuleResource:
	for ship_type in ship_types:
		if ship_type.type_name != _ship_type:
			continue
			
		for module_resource in ship_type.modules:
			if module_resource.type_name == module_type:
				return module_resource
			
	return null

func _refresh() -> void:
	if _tiles_root == null || _ship_type == null:
		return
		
	for child in _tiles_root.get_children():
		_tiles_root.remove_child(child)
		child.queue_free()
		
	for module in _modules:
		var module_resource = _get_module_resource_for_type(module.type)
		
		if module_resource == null:
			continue
		
		var texture = module_resource.sprite_frames.get_frame_texture("default", 0)
		var frame_size = texture.get_size()
		var cell_scaling = Vector2(cell_size / frame_size.x, cell_size / frame_size.y)
			
		for cell in module.cells:
			var sprite = AnimatedSprite2D.new()
			sprite.sprite_frames = module_resource.sprite_frames
			sprite.play("default")
			sprite.scale = cell_scaling
			sprite.position = Vector2(cell.x * cell_size + cell_size / 2.0, cell.y * cell_size + cell_size / 2.0)
			_tiles_root.add_child(sprite)
			
func load_from_ship(ship: Ship) -> void:
	_ship_type = ship.type
	_modules = ship.get_modules().duplicate()
	
	_refresh()
