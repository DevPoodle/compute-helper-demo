extends Node

const max_speed := 300.0
const min_speed := 30.0
const acceleration := 2000.0

var speed_multiplier := 1.0
var velocity := Vector2.ZERO
var position := Vector2.ZERO

func movement(delta : float) -> void:
	var input := Input.get_vector("LEFT", "RIGHT", "UP", "DOWN")
	if input != Vector2.ZERO:
		velocity += input * acceleration * delta
		velocity.limit_length(max_speed)
	elif velocity != Vector2.ZERO:
		velocity -= velocity.normalized() * acceleration * delta
		if velocity.length() < min_speed:
			velocity = Vector2.ZERO
	position += velocity * speed_multiplier * delta
