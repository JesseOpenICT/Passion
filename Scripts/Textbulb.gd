extends Node2D

var speed = 0

func _process(delta):
	speed = speed + 1.8 * delta
	position.y -= pow(speed, 3.5)

func _on_notifier_screen_exited():
	queue_free()
