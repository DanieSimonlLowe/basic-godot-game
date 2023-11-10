extends Node

var mat;
var wall;
var oil;
var goop;
var fire;
var black;
var viewPos;
var viewSize;

# Called when the node enters the scene tree for the first time.
func _ready():
	viewPos = Vector2(0.2,0.2);
	viewSize = Vector2(0.6,0.4);
	wall = []
	oil = []
	fire = []
	black = []
	goop = []
	for i in range(2500):
		if i % 30 == 0:
			wall.append(100.0)
		else:
			wall.append(0.0)
		if i % 2 == 0:
			oil.append(0.0)
		else:
			oil.append(0.0)
		if i % 27 < 6:
			fire.append(7.51)
		else:
			fire.append(0.0)
		if i % 7 == 0:
			black.append(0.0)
		else:
			black.append(0.0)
		if i % 13 == 0:
			goop.append(0.0)
		else:
			goop.append(0.0)
	
	mat = $".".get_material();
	

func update_screen():
	var scaleY = float(get_viewport().size.y)
	var scaleX = scaleY * (16.0 / 9.0)
	if scaleX < get_viewport().size.x:
		scaleX = float(get_viewport().size.x)
		scaleY = scaleX * (9.0 / 16.0)
	$".".position.y = get_viewport().size.y / 2
	$".".scale.y =  scaleY
	$".".position.x = get_viewport().size.x / 2
	$".".scale.x = scaleX 
	
	mat.set_shader_parameter("viewPos",viewPos)
	mat.set_shader_parameter("viewSize",viewSize)



func run_compute_shader():
	mat.set_shader_parameter("wall",wall)
	mat.set_shader_parameter("oil",oil)
	mat.set_shader_parameter("goop",goop)
	mat.set_shader_parameter("fire",fire)
	mat.set_shader_parameter("black",black)


var time_since_last = 1.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_since_last += delta
	if time_since_last > 0.05:
		run_compute_shader()
		time_since_last = 0
	
	update_screen()
	
	
	
