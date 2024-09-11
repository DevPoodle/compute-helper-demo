extends Node2D

var gradient: GradientTexture1D

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("HIDE"):
		$UI.visible = !$UI.visible
	elif event.is_action_pressed("RESET"):
		$Slime/Camera.zoom = %RunTime/General/HBox/RightVBox/Zoom/Slider.value * Vector2(get_viewport().size) / Vector2($Slime.screen_size)
		$Slime.reset_simulation()

func _ready() -> void:
	gradient = $Slime.material.get_shader_parameter("gradient")

func reset_pressed() -> void:
	$Slime/Camera.zoom = %RunTime/General/HBox/RightVBox/Zoom/Slider.value * Vector2(get_viewport().size) / Vector2($Slime.screen_size)
	$Slime.reset_simulation()

#region Starting Parameters
func screen_size_changed(value: float) -> void:
	var height := int(value) if value != 0.0 else int(value) + 180
	var new_screen_size := Vector2i(height * 16 / 9, height)
	%Starting/ScreenSize/Resolution.text = "%d x %d" % [new_screen_size.x, new_screen_size.y]
	$Slime.screen_size = new_screen_size

func number_of_agents_changed(value: float) -> void:
	var new_amount := int(pow(2.0, value))
	%Starting/Agents/Amount.text = str(new_amount)
	$Slime/Agents.number_of_agents = new_amount

func start_position_option_selected(index: int) -> void:
	$Slime/Agents.start_positions = index

func start_angle_option_selected(index: int) -> void:
	$Slime/Agents.start_angles = index
#endregion

#region General Parameters
func simulation_speed_changed(value: float) -> void:
	$Slime.simulation_speed = value

func zoom_changed(value: float) -> void:
	$Slime/Camera.zoom = value * Vector2(get_viewport().size) / Vector2($Slime.screen_size)

func blur_speed_changed(value: float) -> void:
	$Slime.blur_speed = value

func decay_speed_changed(value: float) -> void:
	$Slime.decay_speed = value

func bg_color_changed(color: Color) -> void:
	gradient.gradient.colors[0] = color
	$Slime.material.set_shader_parameter("gradient", gradient)

func fg_color_changed(color: Color) -> void:
	gradient.gradient.colors[1] = color
	$Slime.material.set_shader_parameter("gradient", gradient)
#endregion

#region Player Parameters
func player_switch_toggled(toggled_on: bool) -> void:
	$Slime.player_enabled = toggled_on

func player_trail_radius_changed(value: float) -> void:
	$Slime.player_trail_radius = value

func player_trail_weight_changed(value: float) -> void:
	$Slime.player_trail = value

func player_speed_changed(value: float) -> void:
	$Slime/Player.speed_multiplier = value / 300.0
#endregion

#region Agent Parameters
func agent_speed_changed(value: float) -> void:
	$Slime.agent_speed = value

func agent_trail_weight_changed(value: float) -> void:
	$Slime.agent_trail = value

func agent_turn_speed_changed(value: float) -> void:
	$Slime.agent_turn_speed = value

func agent_lookahead_changed(value: float) -> void:
	$Slime.agent_lookahead = value

func agent_fov_changed(value: float) -> void:
	$Slime.agent_fov = deg_to_rad(value)

func agent_sensor_size_changed(value: float) -> void:
	$Slime.agent_sensor_extend = value
#endregion
