class_name Ship

var type: String

var _modules: Array[ShipModule] = []

func add_module(type: String, cells: Array[Vector2i], is_core_module: bool) -> void:
	var module: ShipModule = ShipModule.new()
	
	module.is_core_module = is_core_module
	module.cells = cells.duplicate()
	module.type = type
	
	_modules.append(module)

func get_modules() -> Array:
	return _modules
