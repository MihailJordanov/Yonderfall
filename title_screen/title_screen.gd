extends CanvasLayer

#region // on ready variables
@onready var logo: Label = $Control/Logo
@onready var main_menu: VBoxContainer = %MainMenu
@onready var new_game_menu: VBoxContainer = %NewGameMenu
@onready var load_game_menu: VBoxContainer = %LoadGameMenu
@onready var are_you_sure_panel: Panel = %AreYouSurePanel

@onready var new_game_button: Button = %"New Game Button"
@onready var load_game_button: Button = %"Load Game Button"
@onready var quit_game_button: Button = %"Quit Game Button"

@onready var new_slot_1: Button = %NewSlot1
@onready var new_slot_2: Button = %NewSlot2
@onready var new_slot_3: Button = %NewSlot3

@onready var load_slot_1: Button = %LoadSlot1
@onready var load_slot_2: Button = %LoadSlot2
@onready var load_slot_3: Button = %LoadSlot3

@onready var keep_button: Button = %KeepButton
@onready var replace_button: Button = %ReplaceButton

@onready var are_you_sure_label: Label = $Control/AreYouSurePanel/AreYouSureMenu/Label
@onready var animation_player: AnimationPlayer = $Control/MainMenu/AnimationPlayer

var pending_new_game_slot: int = -1
#endregion


func _ready() -> void:
	new_game_button.pressed.connect( show_new_game_menu )
	load_game_button.pressed.connect( show_load_game_menu )
	quit_game_button.pressed.connect( quit_game )
	
	new_slot_1.pressed.connect( _on_new_game_pressed.bind( 0 ) ) 
	new_slot_2.pressed.connect( _on_new_game_pressed.bind( 1 ) ) 
	new_slot_3.pressed.connect( _on_new_game_pressed.bind( 2 ) ) 
	
	load_slot_1.pressed.connect( _on_load_game_pressed.bind( 0 ) ) 
	load_slot_2.pressed.connect( _on_load_game_pressed.bind( 1 ) ) 
	load_slot_3.pressed.connect( _on_load_game_pressed.bind( 2 ) ) 
	
	keep_button.pressed.connect( keep_save )
	replace_button.pressed.connect( replace_save )

	
	
	Audio.setup_button_audio( self )
	
	show_main_menu()
	animation_player.animation_finished.connect( _on_animation_finished )
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed( "ui_cancel" ):
		if are_you_sure_panel.visible:
			keep_save()
		elif main_menu.visible == false:
			show_main_menu()
	
	
func show_main_menu() -> void:
	main_menu.visible = true
	logo.visible = true
	new_game_menu.visible  = false
	load_game_menu.visible = false
	are_you_sure_panel.visible = false
	load_game_button.grab_focus()
	pass

func show_new_game_menu() -> void:
	main_menu.visible = false
	logo.visible = false
	new_game_menu.visible  = true
	load_game_menu.visible = false
	are_you_sure_panel.visible = false
	
	new_slot_1.text = "Begin Save 01"
	new_slot_2.text = "Begin Save 02"
	new_slot_3.text = "Begin Save 03"
	
	if SaveManager.save_file_exists( 0 ):
		new_slot_1.text = "Replace Save 01"
	if SaveManager.save_file_exists( 1 ):	
		new_slot_2.text = "Replace Save 02"
	if SaveManager.save_file_exists( 2 ):
		new_slot_3.text = "Replace Save 03"
	
	new_slot_1.grab_focus()
	
func show_load_game_menu() -> void:
	main_menu.visible = false
	logo.visible = false
	new_game_menu.visible  = false
	load_game_menu.visible = true
	are_you_sure_panel.visible = false
	
	load_slot_1.disabled = not SaveManager.save_file_exists( 0 )
	load_slot_2.disabled = not SaveManager.save_file_exists( 1 )
	load_slot_3.disabled = not SaveManager.save_file_exists( 2 )
	
	if SaveManager.save_file_exists( 0 ):
		load_slot_1.grab_focus()
	elif SaveManager.save_file_exists( 1 ):
		load_slot_2.grab_focus()
	elif SaveManager.save_file_exists( 2 ):
		load_slot_3.grab_focus()
	
func quit_game() -> void:
	get_tree().quit()
	pass
	
func show_are_you_sure_menu( slot: int ) -> void:
	pending_new_game_slot = slot
	
	new_game_menu.visible = false
	load_game_menu.visible = false
	main_menu.visible = false
	logo.visible = false
	
	are_you_sure_panel.visible = true
	
	are_you_sure_label.text = "Overwrite Save %02d?" % (slot + 1)
	keep_button.grab_focus()

func _on_new_game_pressed( slot: int ) -> void:
	if SaveManager.save_file_exists( slot ):
		show_are_you_sure_menu( slot )
	else:
		SaveManager.create_new_game_save( slot )
	
func _on_load_game_pressed( slot : int ) -> void:
	SaveManager.load_game( slot )
	pass
	
func _on_animation_finished( anim_name : String ) -> void:
	if anim_name == "start":
		animation_player.play("loop")
	pass
	
func keep_save() -> void:
	pending_new_game_slot = -1
	are_you_sure_panel.visible = false
	show_new_game_menu()
	
func replace_save() -> void:
	if pending_new_game_slot == -1:
		return
	
	SaveManager.create_new_game_save( pending_new_game_slot )
	pending_new_game_slot = -1
	
