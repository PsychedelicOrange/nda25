extends Node2D
# Circular motion detector for root loosening

const POINTS_TO_ANALYZE = 30  # How many recent points to check
const CIRCLE_TOLERANCE = 0.35 # How perfect the circle must be (0-1)
const MIN_RADIUS = 50         # Minimum circle size in pixels

var touch_points := []
var is_active := false

signal circle_completed

func _input(event):
	if not visible: return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			start_circle(event.position)
		else:
			end_circle()
	elif event is InputEventScreenDrag and is_active:
		update_circle(event.position)

func start_circle(position: Vector2):
	# Reset line appearance
	$Line2D.width = 8
	$Line2D.default_color = Color.WHITE
	
	is_active = true
	touch_points = [position]
	$Line2D.clear_points()
	$Line2D.add_point(position)

func _calculate_current_completeness() -> float:
	if touch_points.size() < 10: 
		return 0.0
	
	var temp_center = _calculate_average_center()
	var temp_stats = _calculate_radius_stats(temp_center)
	# Convert radius to 0-1 range based on MIN_RADIUS
	return clamp(temp_stats.average / MIN_RADIUS, 0.0, 1.0)

func update_circle(position: Vector2):
	# Add width variation based on speed
	if touch_points.size() > 0:
		var speed = position.distance_to(touch_points[-1])
		$Line2D.width = lerp(6, 10, speed / 50.0)
	
	touch_points.append(position)
	$Line2D.add_point(position)
	
	# Keep only last X points
	if touch_points.size() > POINTS_TO_ANALYZE:
		touch_points.pop_front()
		$Line2D.remove_point(0)
	
	# Validation feedback
	var completeness = _calculate_current_completeness()
	$Line2D.default_color = Color(
		1.0 - completeness,  # Red decreases
		completeness,        # Green increases
		0.0,                 # No blue
		0.8                  # Alpha
	)

func end_circle():
	is_active = false
	if is_valid_circle():
		emit_signal("circle_completed")
		$Line2D.default_color = Color.GREEN_YELLOW
	else:
		$Line2D.default_color = Color.RED
		await get_tree().create_timer(0.5).timeout
	$Line2D.clear_points()

func is_valid_circle() -> bool:
	if touch_points.size() < 15: return false
	
	# Calculate center and radius variance
	var avg_center = _calculate_average_center()
	var radius_stats = _calculate_radius_stats(avg_center)
	
	# Check circle quality
	return (
		radius_stats.variance < MIN_RADIUS * CIRCLE_TOLERANCE and
		radius_stats.average > MIN_RADIUS and
		_check_angular_coverage(avg_center)
	)

# Helper functions for circle validation
func _calculate_average_center() -> Vector2:
	var sum = Vector2.ZERO
	for p in touch_points: 
		sum += p
	return sum / touch_points.size()

func _calculate_radius_stats(center: Vector2) -> Dictionary:
	var total = 0.0
	var radii := []
	
	# Calculate all radii
	for p in touch_points:
		var r = p.distance_to(center)
		radii.append(r)
		total += r
	
	# Calculate average
	var average = total / radii.size()
	
	# Calculate variance
	var variance = 0.0
	for r in radii:
		variance += abs(r - average)
	variance /= radii.size()
	
	return { "average": average, "variance": variance }

func _check_angular_coverage(center: Vector2) -> bool:
	var angles := []
	var total_change = 0.0
	
	# Calculate absolute angles
	for p in touch_points:
		var offset = p - center
		angles.append(atan2(offset.y, offset.x))
	
	# Calculate angular changes with wrapping
	for i in angles.size() - 1:
		var diff = angles[i+1] - angles[i]
		# Handle 2π wrap-around
		if diff > PI:
			diff -= TAU
		elif diff < -PI:
			diff += TAU
		total_change += abs(diff)
	
	return total_change >= TAU  # TAU = 2*PI
