extends CharacterBody2D

@export var DamageType = "normalDamage"
@export var action = "terminada"
@export var type = "evilNpc"

@onready var animations = $AnimationPlayer

var targetPlayer = null
var esperar = false
var SPEED = 2.5
var isColliding = false
var stop = false
var lives = 3
var isMoving = true
var move = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	#Si tiene su objetivo definido, va a caminar en direccion a este
	if targetPlayer != null and esperar == false and isMoving:
		move=position.direction_to(targetPlayer.position)
		
	else:
		move = Vector2.ZERO
	
	#Se elimina su nodo si se queda sin vidas
	if lives <= 0:
		queue_free()
		
	else:
		move = move.normalized()*SPEED
		move = move_and_collide(move)
		
	move_and_slide()
	


#Chequea si el jugador entro en el area de deteccion
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != self and "type" in body:
		if body.type == "player":
			targetPlayer = body
			animations.play("walk")


func _on_area_2d_2_body_entered(body):
	stop = false
	isColliding = true
	if body == targetPlayer:
		await get_tree().create_timer(0.3).timeout
		if body.attacking:		
			
			if stop == false:
				lives -= 1
				var angle=(body.position - position).angle()
				var direction = Vector2.RIGHT.rotated(angle)  # Mueve hacia la rotación actual
				velocity = direction * SPEED*-1*120
				
				isMoving = false
				await get_tree().create_timer(0.25).timeout
				velocity = Vector2i(0,0)
				await get_tree().create_timer(0.3).timeout
				isMoving = true

		elif esperar:
			animations.play("attack")
			esperar = true
			isColliding = true
			await get_tree().create_timer(0.2).timeout
			if isColliding:
				_on_area_2d_2_body_entered(body)

	await get_tree().create_timer(0.25).timeout
	if isColliding:
		_on_area_2d_2_body_entered(body)



func pegar():
	action = "efectivo"
	animations.play("default")
	await get_tree().create_timer(0.2).timeout
	action = "terminada"
	await get_tree().create_timer(0.75).timeout
	esperar = false
	
func _on_interaction_area_body_exited(body: Node2D) -> void:
	stop = true
	isColliding = false
