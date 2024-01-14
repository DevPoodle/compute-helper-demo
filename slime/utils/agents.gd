extends Node

enum START_POSITIONS {
	DISK, RECTANGLE, POINT
}

enum START_ANGLES {
	TOWARDS_CENTER, AWAY_CENTER, RANDOM
}

var start_positions := START_POSITIONS.DISK
var start_angles := START_ANGLES.TOWARDS_CENTER
var number_of_agents := 1048576

var agent_creation_thread : Thread

func start_agent_creation(screen_radius : float, screen_center : Vector2, screen_size : Vector2) -> void:
	agent_creation_thread = Thread.new()
	agent_creation_thread.start(create_agent_array.bind(screen_radius, screen_center, screen_size))

func get_created_agents() -> PackedByteArray:
	return agent_creation_thread.wait_to_finish()

func create_agent_array(screen_radius : float, screen_center : Vector2, screen_size : Vector2) -> PackedByteArray:
	var agents := PackedFloat32Array()
	match start_positions:
		START_POSITIONS.DISK:
			match start_angles:
				START_ANGLES.TOWARDS_CENTER:
					for i in number_of_agents:
						var angle := randf_range(0.0, TAU)
						var start_position := screen_center + Vector2.from_angle(angle + PI) * randf_range(0.0, screen_radius)
						agents.append(start_position.x)
						agents.append(start_position.y)
						agents.append(angle)
						agents.append(0.0)
				START_ANGLES.AWAY_CENTER:
					for i in number_of_agents:
						var angle := randf_range(0.0, TAU)
						var start_position := screen_center + Vector2.from_angle(angle) * randf_range(0.0, screen_radius)
						agents.append(start_position.x)
						agents.append(start_position.y)
						agents.append(angle)
						agents.append(0.0)
				START_ANGLES.RANDOM:
					for i in number_of_agents:
						var angle := randf_range(0.0, TAU)
						var start_position := screen_center + Vector2.from_angle(randf_range(0.0, TAU)) * randf_range(0.0, screen_radius)
						agents.append(start_position.x)
						agents.append(start_position.y)
						agents.append(angle)
						agents.append(0.0)
		START_POSITIONS.RECTANGLE:
			match start_angles:
				START_ANGLES.TOWARDS_CENTER:
					for i in number_of_agents:
						var start_position := Vector2(randf_range(0.0, screen_size.x), randf_range(0.0, screen_size.y))
						var angle := start_position.angle_to_point(screen_center)
						agents.append(start_position.x)
						agents.append(start_position.y)
						agents.append(angle)
						agents.append(0.0)
				START_ANGLES.AWAY_CENTER:
					for i in number_of_agents:
						var start_position := Vector2(randf_range(0.0, screen_size.x), randf_range(0.0, screen_size.y))
						var angle := start_position.angle_to_point(screen_center) + PI
						agents.append(start_position.x)
						agents.append(start_position.y)
						agents.append(angle)
						agents.append(0.0)
				START_ANGLES.RANDOM:
					for i in number_of_agents:
						var angle := randf_range(0.0, TAU)
						var start_position := Vector2(randf_range(0.0, screen_size.x), randf_range(0.0, screen_size.y))
						agents.append(start_position.x)
						agents.append(start_position.y)
						agents.append(angle)
						agents.append(0.0)
		START_POSITIONS.POINT:
			for i in number_of_agents:
				var angle := randf_range(0.0, TAU)
				var start_position := screen_center
				agents.append(start_position.x)
				agents.append(start_position.y)
				agents.append(angle)
				agents.append(0.0)
	return agents.to_byte_array()
