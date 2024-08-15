extends Label

@onready var game = get_node("/root/Game")

func _process(delta):
	self.text = "Pearls: " + str(game.pearls_collected)

