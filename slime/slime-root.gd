extends Node2D

var gradient : GradientTexture1D

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("HIDE"):
		$ui.visible = !$ui.visible
	elif event.is_action_pressed("RESET"):
		$slime/camera.zoom = $ui/runtime_panel/margin/vbox/general/hbox/right_vbox/zoom/slider.value * Vector2(get_viewport().size) / Vector2($slime.screen_size)
		$slime.reset_simulation()

func _ready() -> void:
	gradient = $slime.material.get_shader_parameter("gradient")

func reset_pressed() -> void:
	$slime/camera.zoom = $ui/runtime_panel/margin/vbox/general/hbox/right_vbox/zoom/slider.value * Vector2(get_viewport().size) / Vector2($slime.screen_size)
	$slime.reset_simulation()

#region Starting Parameters
func screen_size_changed(value : float) -> void:
	var height := int(value) if value != 0.0 else int(value) + 180
	var new_screen_size := Vector2i(height * 16 / 9, height)
	$ui/starting_panel/margin/vbox/screen_size/resolution.text = "%d x %d" % [new_screen_size.x, new_screen_size.y]
	$slime.screen_size = new_screen_size

func number_of_agents_changed(value : float) -> void:
	var new_amount := int(pow(2.0, value))
	$ui/starting_panel/margin/vbox/agents/amount.text = str(new_amount)
	$slime/agents.number_of_agents = new_amount

func start_position_option_selected(index : int) -> void:
	$slime/agents.start_positions = index

func start_angle_option_selected(index : int) -> void:
	$slime/agents.start_angles = index
#endregion

#region General Parameters
func simulation_speed_changed(value : float) -> void:
	$slime.simulation_speed = value

func zoom_changed(value : float) -> void:
	$slime/camera.zoom = value * Vector2(get_viewport().size) / Vector2($slime.screen_size)

func blur_speed_changed(value : float) -> void:
	$slime.blur_speed = value

func decay_speed_changed(value : float) -> void:
	$slime.decay_speed = value

func bg_color_changed(color : Color) -> void:
	gradient.gradient.colors[0] = color
	$slime.material.set_shader_parameter("gradient", gradient)

func fg_color_changed(color : Color) -> void:
	gradient.gradient.colors[1] = color
	$slime.material.set_shader_parameter("gradient", gradient)
#endregion

#region Player Parameters
func player_switch_toggled(toggled_on : bool) -> void:
	$slime.player_enabled = toggled_on

func player_trail_radius_changed(value : float) -> void:
	$slime.player_trail_radius = value

func player_trail_weight_changed(value : float) -> void:
	$slime.player_trail = value

func player_speed_changed(value : float) -> void:
	$slime/player.speed_multiplier = value / 300.0
#endregion

#region Agent Parameters
func agent_speed_changed(value : float) -> void:
	$slime.agent_speed = value

func agent_trail_weight_changed(value : float) -> void:
	$slime.agent_trail = value

func agent_turn_speed_changed(value : float) -> void:
	$slime.agent_turn_speed = value

func agent_lookahead_changed(value : float) -> void:
	$slime.agent_lookahead = value

func agent_fov_changed(value : float) -> void:
	$slime.agent_fov = deg_to_rad(value)

func agent_sensor_size_changed(value : float) -> void:
	$slime.agent_sensor_extend = value
#endregion
