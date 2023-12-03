extends Area2D

@onready var main = $Main
var player = 1
var computer = false

func _ready():
	$Cross_Transparent.hide()
	$Circle_Transparent.hide()
	
	
	
func new_game():
	player = 1

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





func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and player == 1:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hide()


func _on_main_new_game_started():
	player = 1


func _on_main_player_change():
	player *= -1


func _on_easy_computer_mode():
	computer = true
