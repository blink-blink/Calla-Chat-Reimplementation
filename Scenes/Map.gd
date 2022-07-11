extends Node2D

var other_player = preload("res://Scenes/OtherPlayer.tscn")
var last_world_state_time = 0

func spawn_new_player(player_id, player_state):
	if get_tree().get_network_unique_id() == player_id:
		return
	
	print("spawning ", player_id, "'s character")
	print("player state: ", player_state)
	
	var new_player = other_player.instance()
	get_node("YSort/OtherPlayers").add_child(new_player)
	new_player.name = str(player_id)
	new_player.update_player_state(player_state)

func despawn_player(player_id):
	get_node("YSort/OtherPlayers/"+str(player_id)).queue_free()

func start_emote_for_player(player_id, emote_type: String):
	if get_tree().get_network_unique_id() == player_id:
		return
	
	print("emote request from ",player_id," recieved")
	
	get_node("YSort/OtherPlayers/"+str(player_id)).show_emote(emote_type)
	
#Server calls this func to update world_state on the map
func update_world_state(world_state):
	
	#interpolation
	#extrapolation
	
	if world_state["T"] > last_world_state_time:
		last_world_state_time = world_state["T"]
		
		# erase unnecessary keys
		world_state.erase("T") # erase T for key search
		world_state.erase(get_tree().get_network_unique_id()) # erase this player's entry for now...
		
		for player in world_state.keys():
			if get_node("YSort/OtherPlayers").has_node(str(player)):
				get_node("YSort/OtherPlayers/"+str(player)).update_player_state(world_state[player])
			else:
				spawn_new_player(player, world_state[player])
