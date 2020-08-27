extends Node2D

export(NodePath) var clive_npc: NodePath
export(NodePath) var ariad_npc: NodePath

func _ready():
	if Controller.flag("scn_lm_ariad") == 1:
		(get_node(clive_npc) as EventNPC).show()
		
	tween_fountain_sound(true)
	
	
func tween_fountain_sound(on: bool):
	var tween := $TweenFountain as Tween
	var sound := $SoundFountain as AudioStreamPlayer
	tween.interpolate_property(sound as AudioStreamPlayer, "volume_db", sound.get_volume_db(), 0.0 if on else -60.0, 1.0)
	tween.start()


func _on_Transition_transition_taken():
	tween_fountain_sound(false)
