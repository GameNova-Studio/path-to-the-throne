extends RigidBody2D

func _physics_process(delta: float) -> void:
	linear_velocity = linear_velocity*0.6
