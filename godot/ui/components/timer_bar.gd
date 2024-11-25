@tool
extends Node
@onready var timer = get_node("Timer")
@onready var time_out = false
signal timeout
var seconds: int = 0



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	$Label.text = "%.0f" % $Timer.time_left

func comenzar():
	print("COMENZAR")
	$Timer.start()

func _on_timer_timeout() -> void:
	
	timeout.emit()
	emit_signal("timeout")
	
	
