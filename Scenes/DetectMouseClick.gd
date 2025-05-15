extends Area2D

var cardtexture1 = ResourceLoader.load("res://assets/sprites/InstructionCard1.png")
var cardtexture2 = ResourceLoader.load("res://assets/sprites/InstructionCard2.png")

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		self.on_click()

func on_click():
	if $Sprite2D.texture == cardtexture1:
		$Sprite2D.texture = ResourceLoader.load("res://assets/sprites/InstructionCard2.png")
	elif $Sprite2D.texture == cardtexture2:
		$Sprite2D.texture = ResourceLoader.load("res://assets/sprites/InstructionCard1.png")
	else:
		return
