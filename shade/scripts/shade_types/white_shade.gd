@icon( "res://general/icons/shade.svg" )
class_name WhiteShade
extends Shade

@export var max_hp_white: float = 30.0

func _ready() -> void:
	max_hp = max_hp_white

	super._ready()
