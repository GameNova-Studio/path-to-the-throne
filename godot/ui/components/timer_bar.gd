@tool
extends Node
@onready var timer = get_node("Timer")
@onready var time_out = false
signal timeout
var seconds: int = 0

func start():
	$Timer.start()
	$Timer.paused = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Timer.paused:
		$Label.text = "0"
	else:
		$Label.text = "%.0f" % $Timer.time_left


func _on_timer_timeout() -> void:
	$Timeout_sound.play()
	timeout.emit()
	emit_signal("timeout")
	
	
