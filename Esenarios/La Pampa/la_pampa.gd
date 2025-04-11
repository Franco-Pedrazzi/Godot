extends Node2D

func _ready() -> void:
	for i in range(10):
		var smoke_scene = preload("res://objetos/effecs/smoke.tscn")
		var smoke = smoke_scene.instantiate()  
		smoke.position = position
		smoke.position.x = position.x+i*170
		get_tree().root.add_child(smoke)
		
