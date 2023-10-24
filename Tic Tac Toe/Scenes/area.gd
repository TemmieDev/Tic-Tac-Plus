extends Area2D

var player = 1

func _ready():
	$Cross_Transparent.hide()
	$Circle_Transparent.hide()


func _on_mouse_entered():
	if player == 1:
		$Circle_Transparent.hide()
		$Cross_Transparent.show()
	if player == -1:
		$Cross_Transparent.hide()
		$Circle_Transparent.show()

func _on_mouse_exited():
	$Cross_Transparent.hide()
	$Circle_Transparent.hide()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and event.position.x < 1080:
			player *= -1



func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			queue_free()
