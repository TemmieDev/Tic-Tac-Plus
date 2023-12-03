extends CanvasLayer

signal backToMenu

func _on_button_pressed():
	emit_signal("backToMenu")
