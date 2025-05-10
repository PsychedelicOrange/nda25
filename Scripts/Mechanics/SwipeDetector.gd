extends Node2D

# Configuration
const MIN_SWIPE_DISTANCE = 80  # Minimum pixels for valid swipe

# Signals
signal swipe_detected(direction)

# State tracking
var swipe_start_position = Vector2.ZERO
var is_swiping = false

func _input(event):
	if not visible:  # Only active when visible
		return
	
	if event is InputEventScreenTouch:
		handle_touch_event(event)
	elif event is InputEventScreenDrag:
		handle_drag_event(event)

func handle_touch_event(event):
	if event.pressed:  # Touch started
		start_swipe(event.position)
	else:  # Touch ended
		end_swipe(event.position)

func handle_drag_event(event):
	if is_swiping:
		update_swipe_feedback(event.position)

func start_swipe(position):
	swipe_start_position = position
	is_swiping = true
	# Visual feedback setup
	if $ColorRect:
		$ColorRect.size = Vector2.ZERO
		$ColorRect.position = swipe_start_position
		$ColorRect.visible = true

func update_swipe_feedback(current_position):
	# Visual feedback during swipe
	if $ColorRect:
		var direction_vector = current_position - swipe_start_position
		$ColorRect.size = Vector2(direction_vector.length(), 4)
		$ColorRect.rotation = direction_vector.angle()

func end_swipe(end_position):
	is_swiping = false
	if $ColorRect:
		$ColorRect.visible = false
	
	var swipe_vector = end_position - swipe_start_position
	if swipe_vector.length() >= MIN_SWIPE_DISTANCE:
		var normalized_direction = swipe_vector.normalized()
		emit_signal("swipe_detected", normalized_direction)
		# Debug output
		if $Label:
			$Label.text = "Swipe detected!\nDirection: %.2f, %.2f" % [normalized_direction.x, normalized_direction.y]
	else:
		if $Label:
			$Label.text = "Swipe too short!"
