class_name Ship

var _modules: Array = []

func add_module(type: String, cells: Array[Vector2i], locked: bool) -> void:
	_modules.append({
		"type": type,
		"cells": cells.duplicate(),
		"locked": locked
	})

func get_modules() -> Array:
	return _modules
