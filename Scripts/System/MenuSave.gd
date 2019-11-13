extends Node2D

signal menu_closed

var active := false
var load_mode := false

var files_present: Array = [false, false, false, false]

onready var anim_player := $AnimationPlayer as AnimationPlayer

onready var button1 = $CanvasLayer/Button1 as ButtonUF
onready var button2 = $CanvasLayer/Button2 as ButtonUF
onready var button3 = $CanvasLayer/Button3 as ButtonUF
onready var button4 = $CanvasLayer/Button4 as ButtonUF
onready var button_cancel = $CanvasLayer/Button5 as ButtonUF

onready var buttons: Array = [button1, button2, button3, button4, button_cancel]

# =====================================================================

func _ready():
	_load_save_info()

# =====================================================================

func start(use_background: bool):
	if not use_background:
		$CanvasLayer/ColorRect.hide()
	
	var player := $AnimationPlayer as AnimationPlayer
	player.play("Appear")
	if not use_background:
		player.seek(0.9)
	

func set_load_mode(value: bool):
	load_mode = value
	if value:
		$CanvasLayer/Polygon2D/Label.set_text("Load Game")
		
# =====================================================================

func _get_info_str(day: int, month: int, year: int, money: int, hour: int, minute: int, playtime: float) -> String:
	return str(day) + " " + Controller.get_month_str(int(month)) + ", " + str(year) + " " \
				+ "                $" + str(money) + "\n" + str(hour) + ":" + str(minute).pad_zeros(2) \
				+ "                " + Controller.get_playtime_str(playtime)

func _load_save_info():
	for slot in range(4):
		var f := File.new()
		var fname := "user://data_s" + str(slot + 1) + ".uf"
		if f.file_exists(fname):
			f.open(fname, File.READ)
	
			var slot_datetime = parse_json(f.get_line())
			var slot_playtime := float(f.get_line())
			
			# Skip unnecessary lines
			# warning-ignore:unused_variable
			var buffer: String
			# warning-ignore:unused_variable
			for i in range(4):
				buffer = f.get_line()

			var slot_money := int(f.get_line())
			
			if f.is_open():
				f.close()
			
			var info_str := _get_info_str(slot_datetime.day, slot_datetime.month, slot_datetime.year, slot_money, slot_datetime.hour, slot_datetime.minute, slot_playtime)
			
			(buttons[slot] as ButtonUF).set_button_text(info_str)
			files_present[slot] = true
		else:
			(buttons[slot] as ButtonUF).set_button_text("EMPTY")
			
			
func _click_slot(slot: int):
	if not load_mode: # Save game
		var dt := OS.get_datetime()
		Controller.save_game(slot, dt)
		(buttons[slot] as ButtonUF).set_button_text(_get_info_str(dt.day, dt.month, dt.year, Controller.get_money(), dt.hour, dt.minute, Controller.get_playtime()))
		$AnimationPlayerText.play("Disappear")
		yield(get_tree().create_timer(2.5), "timeout")
		anim_player.play("Disappear")
	else: # Load game
		$AnimationPlayerText.play("Disappear")
		yield(get_tree().create_timer(2.5), "timeout")
		anim_player.play("Disappear Load")
		yield(anim_player, "animation_finished")
		Controller.fade(0.5, true, Color(0, 0, 0), true)
		yield(get_tree().create_timer(0.5), "timeout")
		Controller.load_game(slot)
		Controller.fade(0.1, false, Color(0, 0, 0), true)
		yield(get_tree().create_timer(0.5), "timeout")
		$CanvasLayer/ColorRect.hide()
		anim_player.play("Finish Load")
		yield(anim_player, "animation_finished")
		Player.set_state(Player.PlayerState.Move)
		queue_free()
		
# =====================================================================

func _on_Button1_clicked():
	if files_present[0] or not load_mode:
		Controller.select_menu_button(buttons, button1.get_name())
		_click_slot(0)


func _on_Button2_clicked():
	if files_present[1] or not load_mode:
		Controller.select_menu_button(buttons, button2.get_name())
		_click_slot(1)


func _on_Button3_clicked():
	if files_present[2] or not load_mode:
		Controller.select_menu_button(buttons, button3.get_name())
		_click_slot(2)


func _on_Button4_clicked():
	if files_present[3] or not load_mode:
		Controller.select_menu_button(buttons, button4.get_name())
		_click_slot(3)
		
		
func _on_Button5_clicked():
	Controller.select_menu_button(buttons, button_cancel.get_name())
	$AnimationPlayerText.play("Disappear")
	yield(get_tree().create_timer(2.5), "timeout")
	anim_player.play("Disappear")


func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Appear":
		active = true
	elif anim_name == "Disappear":
		emit_signal("menu_closed")
		queue_free()
