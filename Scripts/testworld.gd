extends Node

@export var txtscene: PackedScene
var lastemote
var opacity = 1.0

func _ready():
	for i in get_tree().get_nodes_in_group("Terrain"):
		i.get_child(1).set_polygon(i.get_child(0).get_polygon())
		print(i.name)
	get_tree().get_first_node_in_group("Flag").get_child(0).play()


func _on_guy_checkpoint(pin):
	for i in get_tree().get_nodes_in_group("pin"):
		i.get_child(1).animation = "unchecked"
	pin.get_child(1).animation = "checked"

func _emote(import):
	var spawnpoint = get_node("Guy").position
	#get_node("Emote").name = "previous"
	var bulb = txtscene.instantiate()
	bulb.position = spawnpoint - Vector2(0, 200)
	lastemote = bulb
	add_child(bulb)
	lastemote.get_child(1).get_child(0).text = str("[center]", import ,"[/center]")


func _on_guy_win(delta, time, jumps, deaths):
	time = snapped(time,0.1)
	if time >= 999*60 + 59.9:
		time = 999*60 + 59.9
	var seconds = snapped(fmod(time, 60), 0.1)
	var minutes = snapped((time - seconds) / 60, 1)
	
	get_tree().get_first_node_in_group("Wintext").text = str(
"Congratulations! You did it! \n\nThank you for playing!\n\nCheck out your statistics:
Time since first move:				", minutes, " min ", seconds, " sec
Total jumps:									", jumps, "
Times returned to last pin:		", deaths, "
\n\nUse Shift + R to reset your progress, \nthen use Esc to close the game.
	")
	get_tree().get_first_node_in_group("Wintext").visible = true
	opacity -= 0.1 * delta
	get_tree().get_first_node_in_group("BG").self_modulate = Color(opacity, opacity, opacity, opacity)
