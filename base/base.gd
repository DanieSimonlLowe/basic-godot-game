extends Node

var mat;
var viewPos;
var viewSize;

# Called when the node enters the scene tree for the first time.
func _ready():
	viewPos = Vector2(0.0,0.0);
	viewSize = Vector2(1.0,1.0);
	
	mat = $".".get_material();
	#mat.set_shader_parameter("wallOilGoopFire", Image.new().load("res://test.png"));
	#mat.set_shader_parameter("toxicIce", Image.new().load("res://test.png"));
	

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


var time_since_last = 1.0
var total_time = 0.0;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	total_time += delta;
	time_since_last += delta
	if time_since_last > 0.05:
		time_since_last = 0
	
	mat.set_shader_parameter("time",total_time)
	update_screen()
	
	
	
