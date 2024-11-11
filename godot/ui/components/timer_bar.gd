@tool
extends Node
@onready var timer = get_node("Timer")
@onready var time_out = false
signal timeout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = $".".value


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$".".value = timer.time_left


func _on_timer_timeout() -> void:
	timeout.emit()
	emit_signal("timeout")
	
