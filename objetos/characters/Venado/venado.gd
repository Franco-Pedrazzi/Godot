extends CharacterBody2D

@export var DamageType = "normalDamage"
@export var action = "terminada"
@export var type = "evilNpc"
@export var charge = 0.8

@onready var PhysicsAnimations = $AnimationPlayer
@onready var animations = $AnimatedSprite2D

var playersLives=3
var targetPlayer = null
var attaking = false
var SPEED = 3
var isColliding = false
var stop = false
var lives = 3
var isMoving = true
var move = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	#Si tiene su objetivo definido, va a caminar en direccion a este
	if targetPlayer != null  and isMoving and !attaking:
		move=position.direction_to(targetPlayer.position)
		animations.play("Run")
		animations.scale.x=((targetPlayer.position.x - position.x)/abs(targetPlayer.position.x - position.x))*-1
	else:
		
		move = Vector2.ZERO
		if !attaking:
			animations.play("default")

	#Se elimina su nodo si se queda sin vidas
	if lives <= 0:
		PhysicsAnimations.play("Dead")
		await get_tree().create_timer(0.2).timeout
		queue_free()
	else:
		move = move.normalized()*SPEED
		move = move_and_collide(move)
		
	move_and_slide()
	

#Chequea si el jugador entro en el area de deteccion
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != self and "type" in body:
		if body.type == "player" :
			playersLives=body.lives
			targetPlayer = body
			animations.play("Run")


func _on_area_2d_2_body_entered(body):
	stop = false
	isColliding = true
	
	if body == targetPlayer and playersLives>0:

		await get_tree().create_timer(0.3).timeout
		isMoving=false

		if body.attacking and ((targetPlayer.position.x - position.x)/abs(targetPlayer.position.x - position.x))*-1==body.ExportDirectionX:		
			hurt(body)
		else:		
			isMoving=false 
			if isColliding and !stop:
				
				attaking=true
				animations.play("Attack")
				if animations.get_animation() == "Attack" :
					while animations.is_playing():
						if body.attacking:
							attaking=false
							hurt(body)
							return
						else:
							await get_tree().create_timer(0.2).timeout
					attaking=false
					animations.play("default")
					await get_tree().create_timer(0.1).timeout
				if isColliding:
					_on_area_2d_2_body_entered(body)
	

	await get_tree().create_timer(0.25).timeout
	if isColliding:
		_on_area_2d_2_body_entered(body)
	else:
		isMoving=true
		
func hurt(body):
	if stop == false:
		lives -= 1
		animations.play("default")
		PhysicsAnimations.play("Hurt")
		var angle=(body.position - position).angle()
		var direction = Vector2.RIGHT.rotated(angle)  # Mueve hacia la rotación actual
		velocity = direction * SPEED*-1*300
		isMoving=false
		await get_tree().create_timer(0.25).timeout
		PhysicsAnimations.play("Default")
		velocity = Vector2i(0,0)
		await get_tree().create_timer(0.3).timeout
		isMoving=true
	
func _on_interaction_area_body_exited(body: Node2D) -> void:
	stop = true
	isColliding = false
	isMoving=true
