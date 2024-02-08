extends CanvasLayer

signal restart
signal backtoMenu


func _on_restart_button_pressed():
	restart.emit()
	


func _on_backto_menu_pressed():
	backtoMenu.emit()
