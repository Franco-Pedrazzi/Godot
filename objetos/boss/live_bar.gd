extends Node2D
func _ready() -> void:
	scale.x=get_parent().lives*0.01
	position.x--scale.x/2
	
func _process(delta: float) -> void:
	scale.x=get_parent().lives*0.01
