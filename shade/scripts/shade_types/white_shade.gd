@icon( "res://general/icons/shade.svg" )
class_name WhiteShade
extends Shade

@export var max_hp_white: float = 30.0

@onready var fade_animation_player: AnimationPlayer = %FadeAnimationPlayer

func _ready() -> void:
	max_hp = max_hp_white

	super._ready()

func play_fade(anim_name: String) -> void:
	if fade_animation_player:
		fade_animation_player.play(anim_name)
