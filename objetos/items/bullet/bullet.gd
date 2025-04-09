extends CharacterBody2D

#Designa el tipo de daño
@export var DamageType = "instantDamage"
#Designa el tipo de cuerpo
@export var type = "bullet"
#Designa la velocidad
@export var vel = Vector2i(0,0)
#Designa si es un jugador?
@export var player = null

#Designa la velocidad
var SPEED = 250

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)  # Mueve hacia la rotación actual
	velocity = direction * SPEED  # Aplica la velocidad

	move_and_slide()
	
func _on_interaction_area_body_entered(body: Node2D) -> void:
	#Elimina el proyectil tan pronto entra en contacto con un cuerpo
	queue_free()
