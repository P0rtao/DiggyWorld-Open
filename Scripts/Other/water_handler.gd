extends TileMapLayer

func _process(_delta: float) -> void:
	detect_water()

func detect_water() -> void :
	var player = get_tree().get_first_node_in_group("Player")
	var player_pos = local_to_map(player.position)
	var tile_data_player = get_cell_tile_data(player_pos)
	
	if tile_data_player :
		if tile_data_player.get_custom_data("Water") == "Surface" :
			player.water_surface = true
		else :
			player.water_surface = false
			
		if player.game_state != player.PlayerState.Swim and player.game_state != player.PlayerState.Die :
			player.velocity.y /= 2
			player.game_state = player.PlayerState.Swim
			if player.carried_body == null :
				player.animation_sprite.play("SwimIdle")
			else :
				player.animation_sprite.play("SwimIdleCarry")
	else :
		if player.game_state == player.PlayerState.Swim and player.game_state != player.PlayerState.Die :
			player.game_state = player.PlayerState.Default
	for enemy in get_tree().get_nodes_in_group("Enemy") :
		var tile_data_enemy = get_cell_tile_data(local_to_map(enemy.position))
		if tile_data_enemy :
			if !enemy.in_water :
				enemy.in_water = true
		else :
			enemy.in_water = false
