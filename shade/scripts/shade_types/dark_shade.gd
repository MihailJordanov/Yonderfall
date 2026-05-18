@icon( "res://general/icons/shade.svg" )
class_name DarkShade
extends Shade

@export var max_hp_dark: float = 10.0

func _ready() -> void:
	max_hp = max_hp_dark

	super._ready()
