 extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_spawn_location_instance_number = 1
var current_player_for_spawn_location_number = null


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().is_network_server():
		setup_players_positions()


func setup_players_positions() -> void:
	for player in Persistent_nodes.get_children():
		if player.is_in_group("Player"):
			for spawn_location in $Spawn_locations.get_children():
				if int(spawn_location.name) == current_spawn_location_instance_number and current_player_for_spawn_location_number != player:
					player.rpc("update_position", spawn_location.global_position)
					current_spawn_location_instance_number += 1
					current_player_for_spawn_location_number = player
