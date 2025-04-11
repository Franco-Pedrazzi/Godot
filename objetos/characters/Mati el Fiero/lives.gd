extends HBoxContainer

#Varible auxiliar usada para chequear cuando la cantidad de
#vidas ha cambiado
var aux=0

func _process(delta):

	var rico = $".."
	var parent = $"."
	#Extra la cantidad de vidas del jugador
	var lifeCount = rico.lives
	
	#Cheque si la cantidad de vidas a cambiado
	if lifeCount != aux:
		aux = lifeCount
		
		#Elimina todos los Sprite2d de las vidas para generarlas de vuelta
		for child in parent.get_children():
			child.queue_free()
			
		#Crea un sprite con el icono de vidas por cada vida que hay
		for i in range(lifeCount):
			var life = Sprite2D.new()
			life.texture = preload("res://icon.svg")
			life.position=Vector2i(100 * i, 100)
			add_child(life)
