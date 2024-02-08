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
	$NameSelectMenuComputer.show()
	$NameSelectMenuComputer/PlayButton.show()
	get_tree().paused = true
	playerO_score = 0
	playerX_score = 0
	bestOfChoice = 1
	emit_signal("computer_mode")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	playerX_name = $NameSelectMenuComputer.get_node("PlayerX").get_text()
	if playerX_name == "":
		playerX_name = "Player 1"
	playerO_name = "Computer"
	$"Player1 Score".text = playerX_name+": "+str(playerX_score)
	$"Player2 Score".text = playerO_name+": "+str(playerO_score)
	$"Best Of".text = "First to "+str(bestOfChoice)

	
	

func _input(event):
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
					if check_win() != 0:
						get_tree().paused = true
						$GameOverMenu.show()
						$GameOverMenu/AnimationPlayer.play("show")
						$"CRT Filter".show()
						if winner == 1:
							playerX_score += 1
							if playerX_score == bestOfChoice:
								$WinScreen.show()
								$WinScreen/AnimationPlayer.play("show")
								$WinScreen.get_node("Label").text = playerX_name
							else:
								$GameOverMenu.get_node("Sprite2D/ResultLabel").text = playerX_name+" Wins!"
						elif winner == -1:
							playerO_score += 1
							if playerO_score == bestOfChoice:
								$WinScreen.show()
								$WinScreen/AnimationPlayer.play("show")
								$WinScreen.get_node("Label").text = playerO_name
							else:
								$GameOverMenu.get_node("Sprite2D/ResultLabel").text = playerO_name+" Wins!"
					#check if the board has been filled
					elif moves == 9:
						get_tree().paused = true
						$GameOverMenu.show()
						$GameOverMenu/AnimationPlayer.play("show")
						$"CRT Filter".show()
						$GameOverMenu.get_node("Sprite2D/ResultLabel").text = "It's a Tie!"

					if check_win() == 0 and moves < 9:
						#toggle the player
						player *= -1
						
						#check if the current player is the computer
						if player == -1:
							computer_move()
					#update the panel marker
					temp_marker.queue_free()
					create_marker(player, player_panel_pos + Vector2i(cell_size / 2.07, cell_size / 2.1), true)
					print(grid_data)

func computer_move():
	await get_tree().create_timer(1).timeout
	if moves == 1:
		var center = Vector2i(1, 1)
		var corners = [Vector2i(0, 0), Vector2i(0, 2), Vector2i(2, 0), Vector2i(2, 2)]

		if grid_data[center.y][center.x] == 0:
			grid_data[center.y][center.x] = -1
			create_marker(-1, center * cell_size + Vector2i(cell_size / 2, cell_size / 2))
			moves += 1
			player *= -1
		else:
			var availableCorners = []
			for corner in corners:
				if grid_data[corner.y][corner.x] == 0:
					availableCorners.append(corner)
			if len(availableCorners) > 0:
				var cornerIndex = randi() % availableCorners.size()
				grid_data[availableCorners[cornerIndex].y][availableCorners[cornerIndex].x] = -1
				create_marker(-1, availableCorners[cornerIndex] * cell_size + Vector2i(cell_size / 2, cell_size / 2))
				moves += 1
				player *= -1
		# Update the panel marker
		temp_marker.queue_free()
		create_marker(player, player_panel_pos + Vector2i(cell_size / 2.07, cell_size / 2.1), true)
	# Move 2 logic
	if moves == 3:
		# Check for potential winning moves by the player (Player 'X')
		for y in range(3):
			for x in range(3):
				# Check each empty cell for a winning move
				if grid_data[y][x] == 0:
					grid_data[y][x] = 1  # Simulate player's move
					if check_win() == 1:
						# Block the winning move and switch player's turn
						grid_data[y][x] = -1
						create_marker(-1, Vector2i(x, y) * cell_size + Vector2i(cell_size / 2, cell_size / 2))
						moves += 1
						player *= -1
						temp_marker.queue_free()
						create_marker(player, player_panel_pos + Vector2i(cell_size / 2.07, cell_size / 2.1), true)
						return
					grid_data[y][x] = 0  # Reset the cell after simulation

		# If no winning move, proceed to an available cell
		for y in range(3):
			for x in range(3):
				# Check each empty cell
				if grid_data[y][x] == 0:
					# Place the marker in a free square
					grid_data[y][x] = -1
					create_marker(-1, Vector2i(x, y) * cell_size + Vector2i(cell_size / 2, cell_size / 2))
					moves += 1
					player *= -1
					temp_marker.queue_free()
					create_marker(player, player_panel_pos + Vector2i(cell_size / 2.07, cell_size / 2.1), true)
					return


	# Move 3 logic
	if moves == 5:
		# Check for potential winning moves by the computer (Player 'O')
		for y in range(3):
			for x in range(3):
				# Check each empty cell for a winning move
				if grid_data[y][x] == 0:
					grid_data[y][x] = -1  # Simulate computer's move
					if check_win() == -1:
						# Complete the winning move
						grid_data[y][x] = -1
						create_marker(-1, Vector2i(x, y) * cell_size + Vector2i(cell_size / 2, cell_size / 2))
						moves += 1
						if check_win() != 0:
							get_tree().paused = true
							$GameOverMenu.show()
							$GameOverMenu/AnimationPlayer.play("show")
							$"CRT Filter".show()
							if winner == 1:
								playerX_score += 1
								if playerX_score == bestOfChoice:
									$WinScreen.show()
									$WinScreen/AnimationPlayer.play("show")
									$WinScreen.get_node("Label").text = playerX_name
								else:
									$GameOverMenu.get_node("Sprite2D/ResultLabel").text = playerX_name+" Wins!"
							elif winner == -1:
								playerO_score += 1
								if playerO_score == bestOfChoice:
									$WinScreen.show()
									$WinScreen/AnimationPlayer.play("show")
									$WinScreen.get_node("Label").text = playerO_name
								else:
									$GameOverMenu.get_node("Sprite2D/ResultLabel").text = playerO_name+" Wins!"
						#check if the board has been filled
						elif moves == 9:
							get_tree().paused = true
							$GameOverMenu.show()
							$GameOverMenu/AnimationPlayer.play("show")
							$"CRT Filter".show()
							$GameOverMenu.get_node("Sprite2D/ResultLabel").text = "It's a Tie!"
						# Return to Player 1's turn
						player *= -1
						return
					grid_data[y][x] = 0  # Reset the cell after simulation
		
		# Check for potential winning moves by the player (Player 'X')
		for y in range(3):
			for x in range(3):
				# Check each empty cell for a winning move
				if grid_data[y][x] == 0:
					grid_data[y][x] = 1  # Simulate player's move
					if check_win() == 1:
						# Block the winning move and switch player's turn
						grid_data[y][x] = -1
						create_marker(-1, Vector2i(x, y) * cell_size + Vector2i(cell_size / 2, cell_size / 2))
						moves += 1
						temp_marker.queue_free()
						create_marker(player, player_panel_pos + Vector2i(cell_size / 2.07, cell_size / 2.1), true)
						if check_win() != 0:
							get_tree().paused = true
							$GameOverMenu.show()
							$GameOverMenu/AnimationPlayer.play("show")
							$"CRT Filter".show()
							if winner == 1:
								playerX_score += 1
								if playerX_score == bestOfChoice:
									$WinScreen.show()
									$WinScreen/AnimationPlayer.play("show")
									$WinScreen.get_node("Label").text = playerX_name
								else:
									$GameOverMenu.get_node("Sprite2D/ResultLabel").text = playerX_name+" Wins!"
							elif winner == -1:
								playerO_score += 1
								if playerO_score == bestOfChoice:
									$WinScreen.show()
									$WinScreen/AnimationPlayer.play("show")
									$WinScreen.get_node("Label").text = playerO_name
								else:
									$GameOverMenu.get_node("Sprite2D/ResultLabel").text = playerO_name+" Wins!"
						#check if the board has been filled
						elif moves == 9:
							get_tree().paused = true
							$GameOverMenu.show()
							$GameOverMenu/AnimationPlayer.play("show")
							$"CRT Filter".show()
							$GameOverMenu.get_node("Sprite2D/ResultLabel").text = "It's a Tie!"
						# Return to Player 1's turn
						player *= -1
						return
					grid_data[y][x] = 0  # Reset the cell after simulation

		# If no winning move, proceed to an available cell
		for y in range(3):
			for x in range(3):
				# Check each empty cell
				if grid_data[y][x] == 0:
					# Place the marker in a free square
					grid_data[y][x] = -1
					create_marker(-1, Vector2i(x, y) * cell_size + Vector2i(cell_size / 2, cell_size / 2))
					moves += 1
					if check_win() != 0:
						get_tree().paused = true
						$GameOverMenu.show()
						$GameOverMenu/AnimationPlayer.play("show")
						$"CRT Filter".show()
						if winner == 1:
							playerX_score += 1
							if playerX_score == bestOfChoice:
								$WinScreen.show()
								$WinScreen/AnimationPlayer.play("show")
								$WinScreen.get_node("Label").text = playerX_name
							else:
								$GameOverMenu.get_node("Sprite2D/ResultLabel").text = playerX_name+" Wins!"
						elif winner == -1:
							playerO_score += 1
							if playerO_score == bestOfChoice:
								$WinScreen.show()
								$WinScreen/AnimationPlayer.play("show")
								$WinScreen.get_node("Label").text = playerO_name
							else:
								$GameOverMenu.get_node("Sprite2D/ResultLabel").text = playerO_name+" Wins!"
					#check if the board has been filled
					elif moves == 9:
						get_tree().paused = true
						$GameOverMenu.show()
						$GameOverMenu/AnimationPlayer.play("show")
						$"CRT Filter".show()
						$GameOverMenu.get_node("Sprite2D/ResultLabel").text = "It's a Tie!"
					# Return to Player 1's turn
					player *= -1
					temp_marker.queue_free()
					create_marker(player, player_panel_pos + Vector2i(cell_size / 2.07, cell_size / 2.1), true)
					return
		


	# After Move 3
	elif moves > 3:  
		var winningMoves = [
			[[-1, -1, 0], [0, -1, -1], [-1, 0, -1]],
			[[1, 1, 0], [0, 1, 1], [1, 0, 1]]
		]

		var moveMade = false

		# Check if there are two X's and a space in a line for the player
		for winMove in winningMoves:
			for i in range(3):
				if grid_data[i] == winMove[0] or [grid_data[0][i], grid_data[1][i], grid_data[2][i]] == winMove[0]:
					for j in range(3):
						if grid_data[i][j] == 0 and winMove[1][j] == -1:
							grid_data[i][j] = -1
							create_marker(-1, Vector2i(j * cell_size + cell_size / 2, i * cell_size + cell_size / 2))
							moveMade = true
							break
					if moveMade:
						break
			if moveMade:
				break

		# If no winning move found, check for potential win for the computer
		if not moveMade:
			for winMove in winningMoves:
				for i in range(3):
					if grid_data[i] == winMove[1] or [grid_data[0][i], grid_data[1][i], grid_data[2][i]] == winMove[1]:
						for j in range(3):
							if grid_data[i][j] == 0 and winMove[0][j] == -1:
								grid_data[i][j] = -1
								create_marker(-1, Vector2i(j * cell_size + cell_size / 2, i * cell_size + cell_size / 2))
								moveMade = true
								break
						if moveMade:
							break
				if moveMade:
					break

		# If no potential win for the computer, block any potential win for the player
		if not moveMade:
			for winMove in winningMoves:
				for i in range(3):
					if grid_data[i] == winMove[0] or [grid_data[0][i], grid_data[1][i], grid_data[2][i]] == winMove[0]:
						for j in range(3):
							if grid_data[i][j] == 0 and winMove[1][j] == 1:
								grid_data[i][j] = -1
								create_marker(-1, Vector2i(j * cell_size + cell_size / 2, i * cell_size + cell_size / 2))
								moveMade = true
								break
						if moveMade:
							break
				if moveMade:
					break

		# If no winning or blocking move, choose a free square for the computer
		if not moveMade:
			var emptyCells = []
			for y in range(3):
				for x in range(3):
					if grid_data[y][x] == 0:
						emptyCells.append(Vector2i(x, y))

			if emptyCells.size() > 0:
				var randomIndex = randi() % emptyCells.size()
				var randomCell = emptyCells[randomIndex]
				grid_data[randomCell.y][randomCell.x] = -1
				create_marker(-1, randomCell * cell_size + Vector2i(cell_size / 2, cell_size / 2))
				moveMade = true

		moves += 1
		if check_win() != 0:
			get_tree().paused = true
			$GameOverMenu.show()
			$GameOverMenu/AnimationPlayer.play("show")
			$"CRT Filter".show()
			if winner == 1:
				playerX_score += 1
				if playerX_score == bestOfChoice:
					$WinScreen.show()
					$WinScreen/AnimationPlayer.play("show")
					$WinScreen.get_node("Label").text = playerX_name
				else:
					$GameOverMenu.get_node("Sprite2D/ResultLabel").text = playerX_name+" Wins!"
			elif winner == -1:
				playerO_score += 1
				if playerO_score == bestOfChoice:
					$WinScreen.show()
					$WinScreen/AnimationPlayer.play("show")
					$WinScreen.get_node("Label").text = playerO_name
				else:
					$GameOverMenu.get_node("Sprite2D/ResultLabel").text = playerO_name+" Wins!"
		#check if the board has been filled
		elif moves == 9:
			get_tree().paused = true
			$GameOverMenu.show()
			$GameOverMenu/AnimationPlayer.play("show")
			$"CRT Filter".show()
			$GameOverMenu.get_node("Sprite2D/ResultLabel").text = "It's a Tie!"
		# Return to Player 1's turn
		player *= -1


	

	# Update the panel marker
	temp_marker.queue_free()
	create_marker(player, player_panel_pos + Vector2i(cell_size / 2.07, cell_size / 2.1), true)
	print(grid_data)

# Logic to select an adjacent square
func get_adjacent_empty_square():
	var emptyCells = []
	
	# Find all empty cells
	for y in range(3):
		for x in range(3):
			if grid_data[y][x] == 0:
				emptyCells.append(Vector2i(x, y))

	# Shuffle the list to randomize selection
	emptyCells.shuffle()

	# Choose an adjacent square from the shuffled list
	for cell in emptyCells:
		var x = cell.x
		var y = cell.y
		if grid_data[y][x] == 0:
			return Vector2i(x, y)
	
	# If no adjacent empty square found, return (-1, -1) or handle as needed
	return Vector2i(-1, -1)


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
	winner = 0  # Initialize winner
	# add up the markers in each row, column, and diagonal
	for i in range(len(grid_data)):
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]
		diagonal1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
		diagonal2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]

		# check if either player has all of the markers in one line
		if row_sum == 3 or col_sum == 3 or diagonal1_sum == 3 or diagonal2_sum == 3:
			winner = 1
		elif row_sum == -3 or col_sum == -3 or diagonal1_sum == -3 or diagonal2_sum == -3:
			winner = -1

	return winner  # Return the winner status



func _on_game_over_menu_restart():
	new_game()


func _on_play_button_pressed():
	$NameSelectMenuComputer.hide()
	$NameSelectMenuComputer/PlayButton.hide()
	get_tree().paused = false



func _on_win_screen_back_to_menu():
	LoadManager.load_scene("res://Scenes/menu.tscn")
	get_tree().paused = false





func _on_game_over_menu_backto_menu():
	LoadManager.load_scene("res://Scenes/menu.tscn")
