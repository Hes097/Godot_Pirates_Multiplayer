extends KinematicBody2D

var speed = 0
var is_speeding_up = false

puppet var rotation_velocity = 0
puppet var ship_turn_right = false
puppet var ship_turn_left = false

var velocity = Vector2(0, 0)
var rotation_dir = 0

var cannon_ball = load("res://Cannon_ball.tscn")
var can_shoot = true
var is_reloading = false

export (float) var rotation_speed = 1.5

onready var tween = $Tween
onready var sprite = $Sprite
onready var reload_timer = $Reload_timer
onready var shoot_point_left = $Shoot_point_left
onready var shoot_point_right = $Shoot_point_right
onready var hit_timer = $Hit_timer



puppet var puppet_position = Vector2(0, 0) setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0



#Neue Bewegungssteuerung: Es gann durch rechts und links rotiert werden und durch UP vorwärtsgefahren werden
func get_input():
	is_speeding_up = is_speeding_up
	rotation_dir = 0
	velocity = Vector2()
	if Input.is_action_pressed("up"):
		is_speeding_up = true
	elif Input.is_action_just_released("up"):
		is_speeding_up = false
		ship_turn_right = false
		ship_turn_left = false
	if Input.is_action_pressed("right") and Input.is_action_pressed("up"):
		ship_turn_right = true
	elif Input.is_action_just_released("right"):
		ship_turn_right = false
	if Input.is_action_pressed("left") and Input.is_action_pressed("up"):
		ship_turn_left = true
	elif Input.is_action_just_released("left"):
		ship_turn_left = false

func _process(delta: float) -> void:
	if is_network_master():
		
	#Bewegungssteuerung über WASD direkt
		#var x_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		#var y_input = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		#velocity = Vector2(x_input, y_input).normalized()
		#look_at(get_global_mouse_position())
		
	# Mit Q oder E schießen
		if Input.is_action_pressed("click") and can_shoot and not is_reloading:
				rpc("instance_cannon_ball", get_tree().get_network_unique_id())
				is_reloading = true
				reload_timer.start()
	#Bewegungssteurung relativ zur Rotation
		get_input()
		rotation += rotation_dir * rotation_speed * delta
		is_speeding_up = is_speeding_up
		
	# Gleichmäßige Beschleunigung und Abbremsen
		if is_speeding_up:
			speed = speed+1
			if speed > 250:
				speed = 250
		else:
			speed = speed-3
			if speed < 0:
				speed = 0
	# Gleichmäßge Schiffswendung
		if ship_turn_right:
			rotation_velocity = rotation_velocity+0.006
			rotate(rotation_velocity)
			if rotation_velocity > 1.5:
				rotation_velocity = 1.5
		else:
			rotation_velocity = rotation_velocity-0.005
			rotate(rotation_velocity)
			if rotation_velocity < 0:
				rotation_velocity = 0
		if ship_turn_left:
			rotation_velocity = rotation_velocity-0.006
			rotate(rotation_velocity)
			if rotation_velocity < -1.5:
				rotation_velocity = -1.5
		else:
			rotation_velocity = rotation_velocity+0.005
			rotate(rotation_velocity)
			if rotation_velocity > 0:
				rotation_velocity = 0
		
		velocity = Vector2(speed, 0).rotated(rotation)
		velocity = move_and_slide(velocity)
	
# KP, war vorher schon drin 
	#else:
		#rotation_degrees = lerp(rotation_degrees, puppet_rotation, delta * 8)
		
		#if not tween.is_active():
			#move_and_slide(puppet_velocity * speed)
#Wird wahrscheinlich nicht mehr gebraucht, das das Objekt jetzt über die get_input() bewegt und rotiert wird
func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()
		
		
func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_velocity", velocity)
		rset_unreliable("puppet_rotation", rotation_degrees)
		
sync func instance_cannon_ball(id):
	var player_cannon_ball_instance_left_front = Global.instance_node_at_location(cannon_ball, Persistent_nodes, shoot_point_left.global_position)
	player_cannon_ball_instance_left_front.name = "Cannonball_Left_Front" + name + str(Network.networked_object_name_index)
	player_cannon_ball_instance_left_front.set_network_master(id)
	player_cannon_ball_instance_left_front.player_rotation = rotation-rand_range(1, 2)
	player_cannon_ball_instance_left_front.player_owner = id
	
	var player_cannon_ball_instance_left_mid = Global.instance_node_at_location(cannon_ball, Persistent_nodes, shoot_point_left.global_position)
	player_cannon_ball_instance_left_mid.name = "Cannonball_Left_Middle" + name + str(Network.networked_object_name_index)
	player_cannon_ball_instance_left_mid.set_network_master(id)
	player_cannon_ball_instance_left_mid.player_rotation = rotation-rand_range(1, 2)
	player_cannon_ball_instance_left_mid.player_owner = id
	
	var player_cannon_ball_instance_left_back = Global.instance_node_at_location(cannon_ball, Persistent_nodes, shoot_point_left.global_position)
	player_cannon_ball_instance_left_back.name = "Cannonball_Left_Back" + name + str(Network.networked_object_name_index)
	player_cannon_ball_instance_left_back.set_network_master(id)
	player_cannon_ball_instance_left_back.player_rotation = rotation-rand_range(1, 2)
	player_cannon_ball_instance_left_back.player_owner = id
	
	var player_cannon_ball_instance_right_top = Global.instance_node_at_location(cannon_ball, Persistent_nodes, shoot_point_right.global_position)
	player_cannon_ball_instance_right_top.name = "Cannonball_Right_Top" + name + str(Network.networked_object_name_index)
	player_cannon_ball_instance_right_top.set_network_master(id)
	player_cannon_ball_instance_right_top.player_rotation = rotation+rand_range(1, 2)
	player_cannon_ball_instance_right_top.player_owner = id
	
	var player_cannon_ball_instance_right_mid = Global.instance_node_at_location(cannon_ball, Persistent_nodes, shoot_point_right.global_position)
	player_cannon_ball_instance_right_mid.name = "Cannonball_Right_Middle" + name + str(Network.networked_object_name_index)
	player_cannon_ball_instance_right_mid.set_network_master(id)
	player_cannon_ball_instance_right_mid.player_rotation = rotation+rand_range(1, 2)
	player_cannon_ball_instance_right_mid.player_owner = id
	
	var player_cannon_ball_instance_right_back = Global.instance_node_at_location(cannon_ball, Persistent_nodes, shoot_point_right.global_position)
	player_cannon_ball_instance_right_back.name = "Cannonball_Right_Back" + name + str(Network.networked_object_name_index)
	player_cannon_ball_instance_right_back.set_network_master(id)
	player_cannon_ball_instance_right_back.player_rotation = rotation+rand_range(1, 2)
	player_cannon_ball_instance_right_back.player_owner = id
	
	Network.networked_object_name_index += 1


func _on_Reload_timer_timeout():
	is_reloading = false
