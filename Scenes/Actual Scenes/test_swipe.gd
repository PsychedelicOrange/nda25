# TestScene.gd
extends Node2D

func _ready():
	$SwipeDetector.hide()
	$CircleDetector.hide()
	update_instructions()

func update_instructions():
	$InstructionsLabel.text = "Choose tool:\nShovel (swipe) or Claw (circles)"

func _on_shovel_button_pressed():
	$CircleDetector.hide()
	$SwipeDetector.show()
	$InstructionsLabel.text = "Swipe to dig out plant!"

func _on_claw_hand_button_pressed():
	$SwipeDetector.hide()
	$CircleDetector.show()
	$InstructionsLabel.text = "Circle to loosen roots!"

func _on_swipe_detected(_direction):
	handle_success("Swipe succeeded! Plant dug out.")

func _on_circle_completed():
	handle_success("Roots loosened! Plant ready for transfer.")

func handle_success(message: String):
	$SwipeDetector.hide()
	$CircleDetector.hide()
	$InstructionsLabel.text = message + "\n\nReset in 1 second..."
	await get_tree().create_timer(1.0).timeout
	update_instructions()
	reset_plant_visuals()

func reset_plant_visuals():
	# Add your plant reset logic here
	pass


func _on_circle_detector_item_rect_changed() -> void:
	pass # Replace with function body.
