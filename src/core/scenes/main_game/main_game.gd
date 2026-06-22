class_name MainGame
extends Node

const SHIP_BUILDER: String = "uid://d3pr3lkswe1u7"

@onready var levelRoot: Node2D = %LevelRoot

var _current_screen: BaseScene = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_screen(SHIP_BUILDER)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func load_screen(screen_uid: String) -> void:
	_load_screen.call_deferred(screen_uid)
	
func _load_screen(screen_uid: String) -> void:
	if _current_screen != null:
		_current_screen.queue_free()
		_current_screen = null
		
	await get_tree().process_frame
	
	var new_screen_packed: PackedScene = ResourceLoader.load(screen_uid, "PackedScene")
	
	if new_screen_packed == null:
		push_error("Could not load screen as PackedScene: " + screen_uid)
		return
		
	_current_screen = new_screen_packed.instantiate() as BaseScene
	if _current_screen == null:
		push_error("Loaded screen is not of type ScreenBase or does not exist")
		return

	levelRoot.add_child(_current_screen)
	
	await get_tree().process_frame

	if _current_screen is ShipScene:
		# _current_screen.setup(_get_test_ship())
		pass
