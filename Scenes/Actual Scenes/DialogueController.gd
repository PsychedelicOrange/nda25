extends Node2D

var window:bool = false

func _ready() -> void:
	pass

func run_dialogue(dialogue_string:String):
	Dialogic.start(dialogue_string)

func _on_plant_pressed() -> void:
	run_dialogue("Day1Opening")

func _on_window_pressed() -> void:
	Dialogic.VAR.Day1.set("window", true)
	print(Dialogic.VAR.Day1.window)
	run_dialogue("Day1Opening")

func _on_plant_watered() -> void:
	Dialogic.VAR.Day1.set("water", true)
	print(Dialogic.VAR.Day1.water)
	run_dialogue("Day1Opening")
