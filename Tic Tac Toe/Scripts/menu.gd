extends Node


func _ready():
	$LocalPlayPopup.hide()
	$EasyPopup.hide()
	$HardPopup.hide()
	$FrenzyPopup.hide()
	$QuitPopup.hide()


func _on_local_play_pressed():
	LoadManager.load_scene("res://Scenes/local_play.tscn")


func _on_easy_pressed():
	LoadManager.load_scene("res://Scenes/easy.tscn")


func _on_hard_pressed():
	LoadManager.load_scene("res://Scenes/hard.tscn")


func _on_frenzy_pressed():
	LoadManager.load_scene("res://Scenes/frenzy.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_local_play_mouse_entered():
	$LocalPlayPopup.show()


func _on_local_play_mouse_exited():
	$LocalPlayPopup.hide()


func _on_easy_mouse_entered():
	$EasyPopup.show()


func _on_easy_mouse_exited():
	$EasyPopup.hide()


func _on_hard_mouse_entered():
	$HardPopup.show()


func _on_hard_mouse_exited():
	$HardPopup.hide()


func _on_frenzy_mouse_entered():
	$FrenzyPopup.show()


func _on_frenzy_mouse_exited():
	$FrenzyPopup.hide()


func _on_quit_mouse_entered():
	$QuitPopup.show()


func _on_quit_mouse_exited():
	$QuitPopup.hide()
