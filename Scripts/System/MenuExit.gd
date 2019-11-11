extends Node2D

signal menu_closed

#var active := false
var parent_menu: Menu = null

onready var button1 = $CanvasLayer/Button1 as ButtonUF
onready var button2 = $CanvasLayer/Button2 as ButtonUF
onready var button3 = $CanvasLayer/Button3 as ButtonUF

# =====================================================================

func _ready():
	$AnimationPlayer.play("Appear")
	
# =====================================================================

func set_parent_menu(menu: Menu):
	parent_menu = menu

# =====================================================================

func _on_Button_clicked():
	button1.anim_selected()
	button2.anim_not_selected()
	button3.anim_not_selected()
	yield(get_tree().create_timer(1.5), "timeout")
	Controller.fade(1, true, Color(0, 0, 0), true)
	yield(get_tree().create_timer(1.8), "timeout")
	Controller.goto_scene("res://Scenes/Title/Title.tscn", Vector2.ZERO, 0, false)
	Controller.draw_overlay(false)
	Controller.draw_overlay_map(false)
	Player.hide()
	Controller.fade(1, false, Color(0, 0, 0), true)
	Controller.set_menu_open(false)
	parent_menu.queue_free()
	queue_free()


func _on_Button2_clicked():
	button1.anim_not_selected()
	button2.anim_selected()
	button3.anim_not_selected()
	yield(get_tree().create_timer(1.5), "timeout")
	Controller.fade(true, 1.5, Color(0, 0, 0), true)
	yield(get_tree().create_timer(1.8), "timeout")
	get_tree().quit()

func _on_Button3_clicked():
	button1.anim_not_selected()
	button2.anim_not_selected()
	button3.anim_selected()
	yield(get_tree().create_timer(1.5), "timeout")
	emit_signal("menu_closed")
	queue_free()
