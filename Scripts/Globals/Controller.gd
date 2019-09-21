extends Node

const DialogueRef := preload("res://Instances/Dialogue.tscn")
const DiscourseStartRef := preload("res://Scenes/DiscourseStart.tscn")
const CosmoSprite := preload("res://Resources/Sprite Frames/SpriteFrames_Cosmo.tres")
const CosmoSprite2 := preload("res://Resources/Sprite Frames/SpriteFrames_Cosmo2.tres")
const DiscourseScene := "res://Scenes/Discourse.tscn"

var inventory := {}

var money: int = 20
var money_disp: int = 20

#enum PlayerState { Move, NoInput }

#var player_state: int = PlayerState.Move

onready var money_text: Label = $Overlay/Money
onready var anim_player: AnimationPlayer = $AnimationPlayer

# =====================================================================

func _process(delta):
	if Input.is_action_just_pressed("debug_1"):
		start_discourse("res://Discourses/d_1_rhona.txt", "Rhona", CosmoSprite2)
		
	if money_disp != money:
		money_disp = lerp(money_disp, money, 0.15)
	
	money_text.text = str(money_disp)

# =====================================================================

func goto_scene(path: String, pos: Vector2, direction: int, relative_coords: bool = true):
	Player.set_state(Player.PlayerState.NoInput)
	var current_scene := get_tree().get_root().get_node("Scene")
	var scn: PackedScene = load(path)
	var scn_i := scn.instance()
	
	var target: Vector2
	var player_offset: Vector2
	match direction:
		Player.Direction.Up:
			target = Vector2(0, -144)
			player_offset = Vector2(0, -6)
		Player.Direction.Down:
			target = Vector2(0, 144)
			player_offset = Vector2(0, 6)
		Player.Direction.Left:
			target = Vector2(-160, 0)
			player_offset = Vector2(-6, 0)
		Player.Direction.Right:
			target = Vector2(160, 0)
			player_offset = Vector2(6, 0)
	scn_i.set_position(target)
	get_tree().get_root().add_child(scn_i)
	
	anim_player.get_animation("CameraScroll").track_set_key_value(0, 1, target)
	anim_player.play("CameraScroll")
	Player.scroll_offset(player_offset)
	yield(anim_player, "animation_finished")
	
	current_scene.set_name("__temp")
	scn_i.set_name("Scene")
	current_scene.queue_free()
	
	Player.position -= target
	scn_i.set_position(Vector2.ZERO)
	$MainCamera.set_offset(Vector2.ZERO)
	#Player.position += player_offset
	
	Player.set_state(Player.PlayerState.Move)


#func get_player_state() -> int:
#	return get_tree().get_root().get_node("Scene").get_node("Player").get_state()


#func set_player_state(value: int):
#	get_tree().get_root().get_node("Scene").get_node("Player").set_state(value)
	

func get_money() -> int:
	return money
	
	
func add_money(amount: int):
	money += amount
	
	
func dialogue(file: String) -> Dialogue:
	var dlg: Dialogue = DialogueRef.instance() as Dialogue
	dlg.start(file)
	get_tree().get_root().add_child(dlg)
	return dlg


func start_discourse(file: String, right_name: String, right_sprite: SpriteFrames, left_name: String = "Cosmo", left_sprite: SpriteFrames = CosmoSprite):
	var start := DiscourseStartRef.instance()
	start.set_position(Vector2.ZERO)
	get_tree().get_root().add_child(start)
	yield(get_tree().create_timer(4.5), "timeout")
	draw_overlay(false)
	get_tree().change_scene(DiscourseScene)
	yield(get_tree().create_timer(0.02), "timeout")
	get_tree().get_root().get_node("Discourse").run_discourse(file, right_name, right_sprite, left_name, left_sprite)
	
	
func draw_overlay(draw: bool):
	$Overlay/Sprite.set_visible(draw)
	$Overlay/Money.set_visible(draw)

# =====================================================================

func goto_scene_post(pos: Vector2, direction: int):
	yield(get_tree(), "idle_frame")
	var p := Player
	p.set_position(pos)
	p.set_direction(direction)
