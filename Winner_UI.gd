extends CanvasLayer


onready var win_timer = $Control/Winner_label/Win_timer
onready var winner_label = $Control/Winner_label

func _ready() -> void:
	winner_label.hide()

func _process(_delta: float) -> void:
	if Global.alive_players.size() == 1:
		if Global.alive_players[0].name == str(get_tree().get_network_unique_id()):
			winner_label.show()
