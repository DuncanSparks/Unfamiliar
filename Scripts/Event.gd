extends Area2D

class_name Event

signal event_ended

export(bool) var in_npc = false
export(bool) var autostart = false
export(bool) var destroy
export(String) var destroy_flag
export(bool) var auto_set_destroy = false
export(NodePath) var discourse_npc = null

var started := false

func _ready():
	if destroy and Controller.flag(destroy_flag) == 1:
		queue_free()
		
	if autostart:
		start_event()
	
# =====================================================================
	
func start_event(index: int = 0):
	if not started:
		Player.set_state(Player.PlayerState.NoInput)
		$AnimationPlayer.play("Event" + (str(index + 1) if index != 0 else ""))
		if discourse_npc != null:
			Controller.set_previous_npc(get_node(discourse_npc).get_path())
		if auto_set_destroy:
			Controller.set_flag(destroy_flag, 1)
		started = true
	
# =====================================================================

func _event_set_flag(key: String, value: int):
	Controller.set_flag(key, value)


func _event_show_player(show: bool):
	Player.set_visible(show)
	
	
func _event_set_player_direction(direction: int):
	Player.set_direction(direction)
	
	
func _event_move_player_to_position(pos: Vector2, time: float, direction: int):
	$AnimationPlayer.stop(false)
	Player.set_direction(direction)
	var dir = Player.get_position().direction_to(pos)
	if dir.x < 0:
		if dir.y < 0:
			match direction:
				Player.Direction.Up:
					Player.set_vel_override(Vector2(0, -1))
				Player.Direction.Left:
					Player.set_vel_override(Vector2(-1, 0))
				_:
					Player.set_vel_override(Vector2(0, -1))
		else:
			match direction:
				Player.Direction.Down:
					Player.set_vel_override(Vector2(0, 1))
				Player.Direction.Left:
					Player.set_vel_override(Vector2(-1, 0))
				_:
					Player.set_vel_override(Vector2(0, 1))
	else:
		if dir.y < 0:
			match direction:
				Player.Direction.Up:
					Player.set_vel_override(Vector2(0, -1))
				Player.Direction.Right:
					Player.set_vel_override(Vector2(1, 0))
				_:
					Player.set_vel_override(Vector2(0, -1))
		else:
			match direction:
				Player.Direction.Down:
					Player.set_vel_override(Vector2(0, 1))
				Player.Direction.Right:
					Player.set_vel_override(Vector2(1, 0))
				_:
					Player.set_vel_override(Vector2(0, 1))
					
	Player.set_speed_override(Player.get_position().distance_to(pos) / time)
	
	yield(get_tree().create_timer(time), "timeout")
	Player.set_speed_override(0)
	$AnimationPlayer.play()
	

func _event_dialogue(file: String, set: int):
	$AnimationPlayer.stop(false)
	yield(Controller.dialogue(file, set, false), "dialogue_ended")
	$AnimationPlayer.play()
	
	
func _event_flashback(file: String, texture: String):
	$AnimationPlayer.stop(false)
	yield(Controller.flashback(file, load(texture)), "flashback_finished")
	$AnimationPlayer.play()
	

func _event_discourse(file: String, right_name: String, right_sprite: String):
	$AnimationPlayer.stop(false)
	Controller.start_discourse(file, right_name, load(right_sprite) as SpriteFrames)
	

func _event_play_sound(sound_path: String):
	Controller.play_sound_oneshot_from_path(sound_path)

# =====================================================================

func _event_intro_replace_player(old_player: NodePath):
	Player.set_position(Vector2(208, 84))
	Player.show()
	get_node(old_player).queue_free()

# =====================================================================

func _on_Event_body_entered(body: PhysicsBody2D):
	if body != null:
		if body.is_in_group("Player") and Player.get_state() == Player.PlayerState.Move:
			start_event()
	

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name.substr(0, 5) == "Event":
		Player.set_state(Player.PlayerState.Move)
		emit_signal("event_ended")
		
		started = false
		if not in_npc:
			queue_free()
