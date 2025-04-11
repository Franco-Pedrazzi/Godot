extends CharacterBody2D

@export var lives = 3
@export var type = "player"
@export var attacking = false
@export var ExportDirectionX=0
@onready var animations = $Animations
@onready var PhysicsAnimations=$AnimationPlayer
var SPEED = 600
var Dash=1200
var cantReceiveDamage = false
var isMoving = true
var isColliding = false

func _physics_process(delta):
	#Recibe el input del jugador y puede ser 1 (derecha), -1 (izquierda) o null
	
	var directionX := Input.get_axis("left", "right")
	#Recibe el input del jugador y puede ser 1 (derecha) o -1 (izquierda)
	var directionY := Input.get_axis("up", "down")

	#Si se da que directionX es 1 o -1, pone la velocidad en la direccion dada
	if directionX and isMoving and !attacking:
		ExportDirectionX=directionX
		velocity.x = directionX * SPEED
		if SPEED!=Dash and SPEED!=sqrt((Dash**2)/2):
			animations.play("Run")
		animations.scale.x=directionX
	
			
	elif isMoving:
		#Si no recibe input y se encuentra en movimiento, reduce la velocidad hasta llegar a 0
		velocity.x = move_toward(velocity.x, 0, SPEED/3)
		

	#Si se da que directionY es 1 o -1, pone la velocidad en la direccion dada
	if directionY and isMoving and !attacking:
		velocity.y = directionY* SPEED
		if SPEED!=Dash and SPEED!=sqrt((Dash**2)/2):
			animations.play("Run")
	elif isMoving:
		#Si no recibe input y se encuentra en movimiento, reduce la velocidad hasta llegar a 0
		velocity.y = move_toward(velocity.y, 0, SPEED/3)
		
	if 	directionX and directionY and (SPEED==600 or SPEED==700) :
		SPEED=sqrt((SPEED**2)/2)
		
	if 	!directionX and !directionY and !attacking and !Input.is_action_just_pressed("Dash"):
		animations.play("default")
		

	#Si se toca el boton de pegar, se declara la animacion como pegar
	#y attacking como true, y despues vuelve a la normalidad
	if Input.is_action_just_pressed("attack"):
		animations.play("Punch")
		attacking=true
		await get_tree().create_timer(0.27).timeout
		animations.play("default")
		attacking=false
		
	if Input.is_action_just_pressed("Dash"):
		SPEED=Dash
		animations.play("Dash")
		await get_tree().create_timer(0.15).timeout
		SPEED=600
		attacking=false	
	#Se encarga de permitir continuar moviendose incluso cuando se alcanza una pared
	if lives <= 0:
		cantReceiveDamage=true
		get_tree().reload_current_scene()
		return 
	move_and_slide()



func _on_interaction_area_body_entered(body):
	#Chequea cuando se entra en contacto con un cuerpo
	
	#Estado por default
	cantReceiveDamage=false
	isColliding = true
	
	#Cheque si el cuerpo en el que se esta en contacto es diferente al de Rico
	#y si la propiedad "type" existe en el cuerpo (player, enemigo, bullet,etc)
	if "type" in body and body != self:
		if "DamageType" in body:
			if body.DamageType=="normalDamage" or body.DamageType=="instantDamage":
				if body.DamageType!="instantDamage":
					await get_tree().create_timer(0.5).timeout
					if body:	
						if body.animations.get_animation() == "Attack" :
							while body.animations.is_playing():
								await get_tree().create_timer(0.2).timeout
					else:
						return
					await get_tree().create_timer(0.5).timeout
				if !cantReceiveDamage and !attacking:
					cantReceiveDamage = true
					lives -= 1
					if lives>0:
						PhysicsAnimations.play("Invulnerability")
						var angle=(body.position - position).angle()
						var direction = Vector2.RIGHT.rotated(angle)  # Mueve hacia la rotación actual
						velocity = direction * SPEED*-1
						isMoving = false
						await get_tree().create_timer(0.25).timeout
						PhysicsAnimations.play("default")
						isMoving = true
					
				#Chequea si se acabaron las vidas para recargar la escena actual
				#Simulando un GAME OVER
				else:
					return
				
		await get_tree().create_timer(0.25).timeout
		
		if isColliding == true:
			_on_interaction_area_body_entered(body)


func _on_interaction_area_body_exited(body: Node2D) -> void:
	cantReceiveDamage = true
	isColliding = false
