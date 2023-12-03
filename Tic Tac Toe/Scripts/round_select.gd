extends CanvasLayer

signal RoundSelectPressed

func _on_button_pressed():
	emit_signal("RoundSelectPressed")
