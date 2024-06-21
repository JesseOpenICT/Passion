extends RigidBody2D

signal checkpoint
signal echo
signal win

var jumping : bool
@export var strength = 1000
@export var acceleration = 20
@export var speed = 500
var spinning : bool
var startposition = Vector2(0, 0)
var dead : bool
var holdESC = 0
var winning : bool

var time = 0
var timerOn : bool
var jumps = 0
var deaths = 0

func _ready():
	if FileAccess.file_exists("user://PassionSavedata.json"):
		var savetext = FileAccess.get_file_as_string("user://PassionSavedata.json")
		var savedata = JSON.parse_string(savetext)
		var startX = savedata['savelocationX']
		var startY = savedata['savelocationY']
		if not (startY == 0 and startX == 0):
			deaths = savedata['deaths']
			jumps = savedata['jumps']
			time = savedata['time']
		else:
			_save(0, 0)
		startposition = Vector2(startX, startY)
		print("loaded to coordinates " , startposition)
	else:
		print("error: your'e data is effed or just does not exist IG")
		
	_spawn()

func _process(delta):
	if winning:
		$AnimatedSprite2D.animation = "idle"
		angular_velocity = -100 * delta
		linear_velocity.y = -50000 * delta
		jumping = true
		spinning = true
		win.emit(delta, time, jumps, deaths)
	
	if Input.is_action_just_pressed("Psave"):
		echo.emit(Engine.get_frames_per_second())
#		_save(startposition.x, startposition.y)
#		echo.emit("Saved!")
	if Input.is_action_just_pressed("Rreset"):
		_save(0, 0)
		echo.emit("Save reset!")
	if Input.is_action_just_pressed("Back") and !winning:
		_die()
	if Input.is_action_pressed("Close") and false: #change to false for desktop version
		if holdESC == 0:
			echo.emit("Hold to quit")
		holdESC += 60 * delta
		if holdESC >= 100:
			get_tree().quit()
	else:
		holdESC = 0
	
	if dead:
		if $AnimatedSprite2D.frame < 9:
			$AnimatedSprite2D.animation = "splode"
			$AnimatedSprite2D.play()
			lock_rotation = true
		else:
			$AnimatedSprite2D.stop()
			$AnimatedSprite2D.animation = "idle"
			dead = false
			_spawn()
		return
	
	
	for i in get_colliding_bodies():
		if i.is_in_group("darkness"):
			_die()
		if i.is_in_group("Flag"):
			_win()
		if i.is_in_group("pin"):
			startposition = i.position + Vector2(-10, -160)
			checkpoint.emit(i)
			_save(startposition.x, startposition.y)
		
	if !jumping and !winning:
		$commitment.volume_db = -80
		$passion.volume_db = 1
		if spinning:
				_turnUp()
		
		else:
			rotation = 0
			if (Input.is_action_pressed("left") == Input.is_action_pressed("right")):
				$AnimatedSprite2D.animation = "idle"
			
			elif Input.is_action_pressed("left") and !dead:
				$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.animation = "walk"
				_timestart()
				
				if linear_velocity.x > -speed:
					linear_velocity += Vector2(-(acceleration*60*delta), 300*delta)
			elif Input.is_action_pressed("right") and !dead:
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.animation = "walk"
				_timestart()
				
				if linear_velocity.x < speed:
					linear_velocity += Vector2((acceleration*60*delta), 300*delta)
		
	
		if Input.is_action_pressed("click") and !dead:
			_jump()
	
	else:
		$commitment.volume_db = 1
		$passion.volume_db = -80
		if abs(linear_velocity.x) < 0.5 and abs(linear_velocity.y) < 0.5:
			jumping = false

func _jump():
	_timestart()
	jumps += 1
	lock_rotation = false
	jumping = true
	spinning = true
	$AnimatedSprite2D.animation = "jump"
	linear_velocity = global_position.direction_to(get_global_mouse_position()) * strength #set velocity towards angle
	
func _turnUp():
	if spinning:
		lock_rotation = true
		if rotation > 0.3:
			angular_velocity = -2
		elif rotation < -0.3:
			angular_velocity = 2
		else:
			angular_velocity = 0
			rotation = 0
			spinning = false

func _die():
	jumping = false
	linear_velocity = Vector2(0, 0)
	gravity_scale = 0
	angular_velocity = 0
	spinning = false
	rotation = 0
	if !dead:
		deaths += 1
		dead = true
		$CollisionShape2D.scale = Vector2(0.1, 0.1)

func _spawn():
	dead = false
	winning = false
	gravity_scale = 1
	position = startposition
	lock_rotation = true
	jumping = false
	rotation = 0
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	$CollisionShape2D.scale = Vector2(1, 1)
	
func _save(xloc, yloc):
	var path = "user://PassionSavedata.json"
	var savedata = {
		"savelocationX" = xloc,
		"savelocationY" = yloc,
		"deaths" = deaths,
		"jumps" = jumps,
		"time" = time
	}
	savedata = JSON.stringify(savedata)
	var save_game = FileAccess.open(path, FileAccess.WRITE)
	save_game.store_line(savedata)
	print('saved')
	
func _win():
	winning = true
	gravity_scale = 0
	$Timer.stop()

func _timestart():
	if !timerOn:
		$Timer.start()
		timerOn = true

func _on_timer_timeout():
	time += 0.1
