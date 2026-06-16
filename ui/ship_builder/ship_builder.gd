extends Control

@export_group("Ship Resources")
@export var ship_modules: Array[ModuleResource] = []

@export_group("Grid Settings")
@export var grid_rows: int = 40
@export var grid_cols: int = 40

@export var cell_size: int = 48

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
		
var _view_initialized := false

var _storage_cells := {}

var _storage_pieces := []
# Platzierte Items: { uid, data, origin: Vector2i, local_cells: Array[Vector2i], rot: int }
var _items := []
# Belegung der Zellen durch Items: Vector2i -> uid
var _occupancy := {}

# Vorschau waehrend Drag & Drop
var _preview_cells := []
var _preview_valid := false
var _preview_active := false

func setup(ship: Ship) -> void:
	var origin := Vector2i(grid_cols / 2 - 1, grid_rows / 2 - 1)
	
	for module in ship.get_modules():
		var world_cell: Array = []
		for cell in module.cells:
			world_cell.append(origin + cell)
			
		_add_module(module.type, world_cell, module.locked)
		
	queue_redraw()

func _add_module(type: String, cells: Array, locked: bool) -> void:
	_storage_pieces.append({"type": type, "cells": cells.duplicate(), "locked": locked})
	for cell in cells:
		_storage_cells[cell] = true

func _on_resized() -> void:
	queue_redraw()

func _modules_bbox() -> Rect2:
	if _storage_cells.is_empty():
		return Rect2(0, 0, cell_size, cell_size)
	var min_x := 1.0e20
	var min_y := 1.0e20
	var max_x := -1.0e20
	var max_y := -1.0e20
	for cell in _storage_cells:
		min_x = min(min_x, cell.x)
		min_y = min(min_y, cell.y)
		max_x = max(max_x, cell.x + 1)
		max_y = max(max_y, cell.y + 1)
	return Rect2(min_x * cell_size, min_y * cell_size, (max_x - min_x) * cell_size, (max_y - min_y) * cell_size)

func in_bounds(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < grid_cols and c.y < grid_rows
	
func _ensure_view() -> void:
	if _view_initialized or size.x <= 0.0:
		return
	var bb := _modules_bbox()
	var center_world := bb.position + bb.size / 2.0
	pan = size / 2.0 - center_world * zoom
	_view_initialized = true

func _compute_halo() -> Dictionary:
	var halo := {}
	for sc in _storage_cells:
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				if dx == 0 and dy == 0:
					continue
				var cell: Vector2i = sc + Vector2i(dx, dy)
				if _storage_cells.has(cell) or not in_bounds(cell):
					continue
				var d := sqrt(float(dx * dx + dy * dy))
				var a := clampf((2.3 - d) / 1.3, 0.0, 1.0) * 0.5
				if a <= 0.01:
					continue
				halo[cell] = maxf(halo.get(cell, 0.0), a)
	return halo

func _cell_rect(cell: Vector2i, cs: float) -> Rect2:
	return Rect2(Vector2(cell.x * cell_size, cell.y * cell_size) * zoom + pan, Vector2(cs, cs))

func _resource_for_module_type(type: String) -> ModuleResource:
	for module_resource in ship_modules:
		if module_resource.type_name == type:
			return module_resource
	
	return null

func _draw() -> void:
	_ensure_view()
	
	var zoomed_cell_size := cell_size * zoom
	
	# Angedeutete freie Andock-Zellen rund um die Module (dezenter Geister-Slot).
	var halo := _compute_halo()
	for cell in halo:
		var a: float = halo[cell]
		var rect := _cell_rect(cell, zoomed_cell_size).grow(-2.0)
		draw_rect(rect, Color(0.20, 0.55, 0.65, a * 0.10), true)
		draw_rect(rect, Color(0.32, 0.82, 0.92, a * 0.5), false, maxf(1.0, zoom))

	# Stauraum-Zellen (Tile-Textur).
	for module in _storage_pieces:
		var module_resource = _resource_for_module_type(module.type)
		
		if module_resource == null:
			continue
		
		for cell in module.cells:
			draw_texture_rect(module_resource.texture, _cell_rect(cell, zoomed_cell_size), false)

	# Verankerten Start-Stauraum hervorheben.
	for pc in _storage_pieces:
		if pc.locked:
			for cell in pc.cells:
				var r := _cell_rect(cell, zoomed_cell_size)
				draw_rect(Rect2(r.position + Vector2(2, 2), r.size - Vector2(4, 4)), Color(0.28, 0.95, 0.85), false, maxf(1.5, 2.0 * zoom))

	# Platzierte Items (Sprite ueber die Bounding-Box, gedreht).
	# for it in items:
	# 	var top_left := Vector2(it.origin.x * CELL, it.origin.y * CELL) * zoom + pan
	# 	ItemArt.draw_piece(self, ItemDB.Kind.ITEM, it.data.tex, it.data.cells, it.local_cells, top_left, cs, it.rot)

	# Vorschau (gruen = moeglich, rot = nicht moeglich).
	# if preview_active:
	#	var col := Color(0.20, 0.90, 0.30, 0.45) if preview_valid else Color(0.95, 0.20, 0.20, 0.45)
	#	for wc in preview_cells:
	#		draw_rect(_cell_rect(wc, cs), col, true)
