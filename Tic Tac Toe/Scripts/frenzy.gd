extends Node

@export var circle_scene : PackedScene
@export var cross_scene : PackedScene

signal new_game_started
signal player_change
signal computer_mode

var player : int
var player_1 : bool
var playerX_name : String
var playerO_name : String
var playerX_score : int
var playerO_score : int
var bestOfChoice : int
var moves : int
var winner : int
var temp_marker
var player_panel_pos : Vector2i
var grid_data : Array
var grid_pos : Vector2i
var board_size : int
var cell_size : int
var row_sum : int
var col_sum : int
var diagonal1_sum : int
var diagonal2_sum : int
var game_start : bool
var starting_time : float
var time : float

# Called when the node enters the scene tree for the first time.
func _ready():
	board_size = 1080
	# divide board size by 3 to get the size of individual cell
	cell_size = board_size / 3
	#get coordinates of small panel on right side of window
	player_panel_pos = $PlayerPanel.get_position()
	new_game()
	if player == 1:
		player_1 = true
	$FrenzyTutorial.show()
	$NameSelectMenuComputer.show()
	$NameSelectMenuComputer/PlayButton.show()
	get_tree().paused = true
	playerO_score = 0
	playerX_score = 0
	emit_signal("computer_mode")
	starting_time = 31
	time = 31

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	playerX_name = $NameSelectMenuComputer.get_node("PlayerX").get_text()
	if playerX_name == "":
		playerX_name = "Player 1"
	playerO_name = "Computer"
	$"Player1 Score".text = playerX_name+": "+str(playerX_score)
	$Score.text = "Score: "+str(playerX_score)
	$TimeLeft.text = "Time left: "+str(floor(starting_time))

func _input(event):
	if starting_time > 0:
		if event is InputEventMouseButton and player == 1:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				#check if mouse is on the game board
				if event.position.x < board_size:
					#convert mouse position into grid location
					grid_pos = Vector2i(event.position / cell_size)
					if grid_data[grid_pos.y][grid_pos.x] == 0:
						moves += 1
						grid_data[grid_pos.y][grid_pos.x] = player
						#place that player's marker
						create_marker(player, grid_pos * cell_size + Vector2i(cell_size / 2, cell_size / 2))
						starting_time = time
						player *= -1
						if check_win() != 0:
							get_tree().paused = true
							$"CRT Filter".show()
							if winner == 1:
								playerX_score += 1
								if time > 1:
									time -= 2
								new_game()
							elif winner == -1:
								$YouLose.show()
								$YouLose/AnimationPlayer.play("show")
								$YouLose.get_node("TotalScore").text = "Your total score was:  "+str(playerX_score)
						#check if the board has been filled
						elif moves == 9:
							new_game()
						
							#check if the current player is the computer
						if player == -1:
							computer_move()
						#update the panel marker
						temp_marker.queue_free()
						create_marker(player, player_panel_pos + Vector2i(cell_size / 2.07, cell_size / 2.1), true)
						print(grid_data)
	if starting_time <= 0:
		get_tree().paused = true
		$YouLose.show()
		$YouLose/AnimationPlayer.play("show")
		$YouLose.get_node("TotalScore").text = "Your total score was:  "+str(playerX_score)

# Function for the computer to make a move
func computer_move():
	#choose a random empty cell
	var empty_cells = []
	for y in range(3):
		for x in range(3):
			if grid_data[y][x] == 0:
				empty_cells.append(Vector2i(x, y))
	
	#check if there are no more empty cells
	if empty_cells.size() == 0:
		return
	
	#choose a random empty cell from the available ones
	var random_index = randi() % empty_cells.size()
	var random_cell = empty_cells[random_index]
	
	#place the computer's marker in the chosen cell
	grid_data[random_cell.y][random_cell.x] = player
	moves += 1
	create_marker(player, random_cell * cell_size + Vector2i(cell_size / 2, cell_size / 2))
	if check_win() != 0:
		get_tree().paused = true
		$"CRT Filter".show()
		if winner == 1:
			playerX_score += 1
			new_game()
		elif winner == -1:
			$YouLose.show()
			$YouLose/AnimationPlayer.play("show")
			$YouLose.get_node("TotalScore").text = "Your total score was:  "+str(playerX_score)
	#check if the board has been filled
	elif moves == 9:
		new_game()
	player *= -1
	#update the panel marker
	temp_marker.queue_free()
	create_marker(player, player_panel_pos + Vector2i(cell_size / 2.07, cell_size / 2.1), true)
	print(grid_data)

func new_game():
	$Area.show()
	$Area2.show()
	$Area3.show()
	$Area4.show()
	$Area5.show()
	$Area6.show()
	$Area7.show()
	$Area8.show()
	$Area9.show()
	if starting_time >= 1:
		starting_time = time
	player = 1
	moves = 0
	winner = 0
	grid_data = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
		]
	row_sum = 0
	col_sum = 0
	diagonal1_sum = 0
	diagonal2_sum = 0
	#clear existing markers
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	#create a marker to show starting player's turn
	create_marker(player, player_panel_pos + Vector2i(cell_size / 2.07, cell_size / 2.1), true)
	$GameOverMenu.hide()
	$"CRT Filter".hide()
	get_tree().paused = false
	emit_signal("new_game_started")

func _physics_process(delta):
	if starting_time >= 0:
		starting_time -= delta

func create_marker(player, position, temp=false):
	#create a marker node and add it as a child
	if player == -1:
		var circle = circle_scene.instantiate()
		circle.position = position
		add_child(circle)
		if temp: temp_marker = circle
	else:
		if cross_scene:
			var cross = cross_scene.instantiate()
			cross.position = position
			add_child(cross)
			if temp: temp_marker = cross

func check_win():
	#add up the markers in each ros, column and diagonal
	for i in len(grid_data):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diagonal1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diagonal2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]
	
		#check if either player has all of the markers in one line
		if row_sum == 3 or col_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3:
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3:
			winner = -1
	return winner


func _on_game_over_menu_restart():
	new_game()


func _on_play_button_pressed():
	$NameSelectMenuComputer.hide()
	$NameSelectMenuComputer/PlayButton.hide()


func _on_frenzy_tutorial_round_select_pressed():
	$FrenzyTutorial.hide()
	get_tree().paused = false


func _on_game_over_menu_backto_menu():
	LoadManager.load_scene("res://Scenes/menu.tscn")


func _on_you_lose_back_to_menu():
	get_tree().paused = false
	LoadManager.load_scene("res://Scenes/menu.tscn")