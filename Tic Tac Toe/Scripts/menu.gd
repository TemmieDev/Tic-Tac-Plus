extends Node



func _on_local_play_pressed():
	LoadManager.load_scene("res://Scenes/local_play.tscn")


func _on_easy_pressed():
	LoadManager.load_scene("res://Scenes/easy.tscn")


func _on_quit_pressed():
	get_tree().quit()
