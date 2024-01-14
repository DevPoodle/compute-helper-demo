@tool
extends StyleBox
class_name StyleBoxBlur

@export var bg_color := Color(Color.BLACK, 0.5) : set = set_bg_color
@export_range(0.0, 10.0) var blur_amount := 2.0 : set = set_blur_amount

static var material := RID()
static var shader := RID()

func set_bg_color(new_bg_color : Color) -> void:
	bg_color = new_bg_color
	emit_changed()

func set_blur_amount(new_blur_amount : float) -> void:
	blur_amount = new_blur_amount
	emit_changed()

func _draw(to_canvas_item : RID, rect : Rect2) -> void:
	if !material.is_valid():
		material = RenderingServer.material_create()
		shader = preload("res://resources/theme/blur.gdshader").get_rid()
		RenderingServer.material_set_shader(material, shader)
	RenderingServer.material_set_param(material, "bg_color", bg_color)
	RenderingServer.material_set_param(material, "blur_amount", blur_amount)
	
	RenderingServer.canvas_item_set_material(to_canvas_item, material)
	RenderingServer.canvas_item_add_rect(to_canvas_item, rect, bg_color)
