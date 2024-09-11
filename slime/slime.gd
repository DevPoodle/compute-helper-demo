extends Sprite2D

#region Simulation Parameters
var screen_size := Vector2i(1280, 720)
var working_screen_size := screen_size

var simulation_speed := 1.0
var blur_speed := 6.0
var decay_speed := 0.5

var agent_speed := 30.0
var agent_turn_speed := 4.0
var agent_lookahead := 40.0
var agent_fov := deg_to_rad(30.0)
var agent_trail := 2.0
var agent_sensor_extend := 1.0

var player_enabled := false
var player_trail := 2.0
var player_trail_radius := 50.0
#endregion

var agent_compute_shader : ComputeHelper
var texture_compute_shader : ComputeHelper

var agent_shader_groups : Vector3i
var texture_shader_groups : Vector3i

var input_texture : ImageUniform
var halfway_texture : SharedImageUniform
var output_texture : SharedImageUniform

var agent_parameters_buffer : StorageBufferUniform
var agent_buffer : StorageBufferUniform
var texture_parameters_buffer : StorageBufferUniform

func _ready() -> void:
	RenderingServer.call_on_render_thread(initialize_compute_shaders)

func _process(delta : float) -> void:
	RenderingServer.call_on_render_thread(update_compute_shaders.bind(delta * simulation_speed))

func _exit_tree() -> void:
	RenderingServer.call_on_render_thread(end_compute_shaders)

func initialize_compute_shaders() -> void:
	var screen_radius := minf(screen_size.x, screen_size.y) / 2.0
	var screen_center := screen_size / 2.0
	$player.position = screen_center
	$agents.start_agent_creation(screen_radius, screen_center, screen_size)
	
	var agent_params := PackedFloat32Array([0.0]).to_byte_array()
	var texture_params := PackedFloat32Array([0.0]).to_byte_array()
	
	var image := Image.create(screen_size.x, screen_size.y, false, Image.FORMAT_RGBAF)
	image.fill(Color.BLACK)
	
	agent_compute_shader = ComputeHelper.create("res://slime/agent-compute.glsl")
	texture_compute_shader = ComputeHelper.create("res://slime/texture-compute.glsl")
	
	input_texture = ImageUniform.create(image)
	halfway_texture = SharedImageUniform.create(input_texture)
	output_texture = SharedImageUniform.create(input_texture)
	texture.texture_rd_rid = input_texture.texture
	
	agent_shader_groups = Vector3i($agents.number_of_agents / 64, 1, 1)
	texture_shader_groups = Vector3i(screen_size.x / 16, screen_size.y / 16, 1)
	
	agent_parameters_buffer = StorageBufferUniform.create(agent_params)
	texture_parameters_buffer = StorageBufferUniform.create(texture_params)
	agent_buffer = StorageBufferUniform.create($agents.get_created_agents())
	
	agent_compute_shader.add_uniform_array([agent_parameters_buffer, agent_buffer, input_texture, halfway_texture])
	texture_compute_shader.add_uniform_array([texture_parameters_buffer, halfway_texture, output_texture])
	
	var sampler := SamplerUniform.create(image)
	print(sampler is SamplerUniform)

func update_compute_shaders(delta : float) -> void:
	if player_enabled:
		$player.movement(delta)
	
	var agent_params := PackedFloat32Array([
		randf(), working_screen_size.x, working_screen_size.y, agent_speed * delta, agent_turn_speed * delta, agent_lookahead, agent_fov, agent_trail * delta, agent_sensor_extend
	]).to_byte_array()
	agent_parameters_buffer.update_data(agent_params)
	
	agent_compute_shader.run(agent_shader_groups)
	ComputeHelper.sync()
	
	var texture_params := PackedFloat32Array([
		blur_speed * delta, decay_speed * delta, player_trail_radius, player_trail * float(player_enabled), $player.position.x, $player.position.y
	]).to_byte_array()
	texture_parameters_buffer.update_data(texture_params)
	
	texture_compute_shader.run(texture_shader_groups)

func reset_simulation() -> void:
	var screen_radius := minf(screen_size.x, screen_size.y) / 2.0
	var screen_center := screen_size / 2.0
	$player.position = screen_center
	$agents.start_agent_creation(screen_radius, screen_center, screen_size)
	
	var image := Image.create(screen_size.x, screen_size.y, false, Image.FORMAT_RGBAF)
	image.fill(Color.BLACK)
	
	texture.texture_rd_rid = RID()
	
	input_texture.update_image(image)
	
	agent_shader_groups = Vector3i($agents.number_of_agents / 64, 1, 1)
	texture_shader_groups = Vector3i(screen_size.x / 16, screen_size.y / 16, 1)
	working_screen_size = screen_size
	
	texture.texture_rd_rid = input_texture.texture
	
	agent_buffer.update_data($agents.get_created_agents())

func end_compute_shaders() -> void:
	agent_compute_shader.free()
	texture_compute_shader.free()
