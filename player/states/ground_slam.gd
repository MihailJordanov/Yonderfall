class_name PlayerStateGroundSlam extends PlayerState

const DASH_AUDIO = preload("uid://v2ic7cwnffp5")
const BOOM_AUDIO = preload("uid://cimbhb3k0p4ph")
const BREAK_WOOD_AUDIO = preload("uid://cdapc6k6wj5at")
const HIT_WOOD_LARGE = preload("uid://jn8vxc23ms21")
const HIT_WOOD_MEDIUM = preload("uid://dsc1dwedvm103")
const HIT_WOOD_SMALL = preload("uid://gctqmre6q7un")

@export var velocity : float = 400
@export var effect_delay : float = 0.075
var effect_timer : float = 0

@onready var damage_area: DamageArea = %DamageArea
@onready var ground_slam_shape_cast: ShapeCast2D = $"../../GroundSlamShapeCast2D"
@onready var ground_slam_attack_area: AttackArea = %GroundSlamAttackArea

func init() -> void:
	pass
	
func enter() -> void:
	player.animation_player.play( "ground_slam" )
	player.sprite.tween_color()
	Audio.play_spatial_sound( DASH_AUDIO, player.global_position, false, true, 0.75 )
	damage_area.start_invulnerable()
	ground_slam_attack_area.set_active()
	pass
	
func exit() -> void:
	VisualEffects.camera_shake( 10.0 )
	VisualEffects.land_dust( player.global_position )
	VisualEffects.hit_dust( player.global_position )
	Audio.play_spatial_sound( BOOM_AUDIO, player.global_position, false, true, 1.0 )
	damage_area.end_invulnerable()
	ground_slam_attack_area.set_active( false )
	pass
	
	
func handle_input( _event : InputEvent ) -> PlayerState:
	
	return null


func process( _delta: float ) -> PlayerState:
	check_collisions( _delta )
	effect_timer -= _delta
	if effect_timer < 0:
		effect_timer = effect_delay
		player.sprite.ghost()
	return next_state
	
func physics_process( _delta: float) -> PlayerState:
	player.velocity.x = 0
	player.velocity = Vector2( 0, velocity )
	if player.is_on_floor():
		if not check_collisions( _delta ):
			return idle
	return next_state
	
func check_collisions( _delta: float ) -> bool:
	
	ground_slam_shape_cast.target_position.y = velocity * _delta
	ground_slam_shape_cast.force_shapecast_update()
	if ground_slam_shape_cast.is_colliding():
		for i in ground_slam_shape_cast.get_collision_count():
			var c = ground_slam_shape_cast.get_collider( i )
			var pos : Vector2 = ground_slam_shape_cast.get_collision_point( i )
			
			VisualEffects.hit_dust( pos )
			VisualEffects.camera_shake( 5.0 )
			
			if c.get_parent() is Breakable:
				var b : Breakable = c.get_parent()

				if b.get_parent() is AbilityPickUp:
					continue

				b.queue_free()
				Audio.play_spatial_sound( b.destroy_audio, pos, false, true, 0.75 )

				for p in b.destroy_particles:
					VisualEffects.hit_particles( pos, Vector2.DOWN, p )
			else:
				c.queue_free()
				VisualEffects.hit_particles( pos, Vector2.DOWN, HIT_WOOD_LARGE )
				VisualEffects.hit_particles( pos, Vector2.DOWN, HIT_WOOD_MEDIUM )
				VisualEffects.hit_particles( pos, Vector2.UP, HIT_WOOD_SMALL )
				Audio.play_spatial_sound( BREAK_WOOD_AUDIO, pos, false, true, 0.75 )
				
		return true
	return false
	
