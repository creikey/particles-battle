tool
extends Control

class_name DottedCircle

export var color := Color(1, 1, 1)
export var dash_size: float = 3.0
export var dash_gap: float = 2.0
export var radius: float = 100.0
export var width: float = 3.0
export var rotation_speed: float = 180.0
export var inner_circle: bool = false
export var inner_cirlce_color := Color(0.2, 0.2, 0.2)
#export var polyline_resolution: int = 12

var _redraw_timer: float = 0.0

func _process(delta: float):
	rect_rotation += delta*rotation_speed
	if Engine.editor_hint:
		_redraw_timer += delta
		if _redraw_timer > (1.0 / 6.0):
			_redraw_timer = 0.0
			update()

func _draw():
	if inner_circle:
		draw_circle(Vector2(), radius, inner_cirlce_color)
	var cur_angle: float = 0.0
	var circumference: float = 2.0 * radius * PI
	var dash_size_angle: float = (dash_size / circumference) * 2.0 * PI
	var dash_gap_angle: float = (dash_gap / circumference) * 2.0 * PI
	while cur_angle < 2.0*PI:
		_draw_circle_arc(Vector2(), rad2deg(cur_angle), rad2deg(cur_angle + dash_size_angle))
		cur_angle += dash_size_angle + dash_gap_angle
#		draw_line(_get_pos_from_angle(angle), _get_pos_from_angle(angle + dash_size_angle), color, width)

func _draw_circle_arc(center: Vector2, angle_from: float, angle_to: float):
	var nb_points: int = int(max(2.0, (6.0 / 200.0) * dash_size))
	var points_arc := PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	draw_polyline(points_arc, color, width, true)
#	for index_point in range(nb_points):
#		draw_line(points_arc[index_point], points_arc[index_point + 1], color, width, true)

func _get_pos_from_angle(angle: float) -> Vector2:
	return Vector2(sin(angle)*radius, cos(angle)*radius)
