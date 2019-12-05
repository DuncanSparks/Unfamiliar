extends KinematicBody2D

class_name PlayerClass

const Speed := 65

var vel := Vector2(0, 0)
var vel_override := Vector2(0, 0)
var speed_override: float = 0.0

enum PlayerState { Move, NoInput }
enum Direction { Up, Down, Left, Right }

var state: int = PlayerState.Move
var face: int = Direction.Down
var walking := false
var in_transition := false
var in_event := false

var sprite_override := false

onready var spr := $Sprite as AnimatedSprite
onready var interact := $Interact as Sprite
onready var sight := $Sight as Area2D
onready var anim_player := $AnimationPlayer as AnimationPlayer

# =====================================================================

func _ready():
	interact.hide()
	set_position(Vector2(176, 98))


func _physics_process(delta):
	set_z_index(int(get_position().y))
	
	match state:
		PlayerState.Move:
			var xx := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
			var yy := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
			
			vel.x = xx
			vel.y = yy
			
			walking = vel != Vector2.ZERO
			
			direction_management()
			
			if not sprite_override:
				sprite_management()
			
			move_and_slide(vel * Speed)
			
		PlayerState.NoInput:
			walking = speed_override > 0
			
			if not sprite_override:
				sprite_management()
			
			move_and_slide(vel_override * speed_override)
			
	if Input.is_action_just_pressed("debug_1"):
		#Controller.flashback("res://Flashbacks/fb_contract.txt", load("res://Splash.png"))
		#Controller.show_emote(Controller.Emote.Question, self)
		Controller.start_discourse("Ariad", "res://Discourses/d_ariad.txt", "Ariad", load("res://Resources/Sprite Frames/SpriteFrames_Ariad.tres") as SpriteFrames)

# =====================================================================

func get_state() -> int:
	return state


func set_state(value: int):
	state = value
	
	
func is_in_event() -> bool:
	return in_event
	
	
func set_in_event(value: bool):
	in_event = value
	
	
func get_direction() -> int:
	return face
	

func set_direction(value: int):
	face = value
	
	
func set_vel_override(value: Vector2):
	vel_override = value
	
	
func set_speed_override(value: float):
	speed_override = value
	
	
func set_in_transition(value: bool):
	in_transition = value
	
	
func show_interact(show: bool):
	interact.set_visible(show)
	
	
func stop_moving():
	walking = false
	if not sprite_override:
		match face:
			Direction.Up:
				spr.play("up")
			Direction.Down:
				spr.play("down")
			Direction.Left:
				spr.play("left")
			Direction.Right:
				spr.play("right")
	

func scroll_offset(offset: Vector2):
	anim_player.get_animation("ScrollOffset").track_set_key_value(0, 0, get_position())
	anim_player.get_animation("ScrollOffset").track_set_key_value(0, 1, get_position() + offset)
	anim_player.play("ScrollOffset")
	
	
func set_sprite_override(value: bool):
	sprite_override = value
	
	
func play_sprite_animation(anim: String):
	spr.play(anim)

# =====================================================================

func direction_management():
	if vel.x == 0:
		match vel.y:
			-1.0:
				face = Direction.Up
			1.0:
				face = Direction.Down
	elif vel.y == 0:
		match vel.x:
			-1.0:
				face = Direction.Left
			1.0:
				face = Direction.Right

	match face:
		Direction.Up:
			sight.set_rotation_degrees(180)
		Direction.Down:
			sight.set_rotation_degrees(0)
		Direction.Left:
			sight.set_rotation_degrees(90)
		Direction.Right:
			sight.set_rotation_degrees(270)
	

func sprite_management():
	match face:
		Direction.Up:
			spr.play("up_walk" if walking or in_transition else "up")
		Direction.Down:
			spr.play("down_walk" if walking or in_transition else "down")
		Direction.Left:
			spr.play("left_walk" if walking or in_transition else "left")
		Direction.Right:
			spr.play("right_walk" if walking or in_transition else "right")
