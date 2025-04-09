extends CharacterBody2D
var player=null
var SPEED=2.5
@export var DamageType="null"
@export var type="evilNpc"
@onready var animations=$AnimationPlayer
var move=Vector2.ZERO
var scapeTime=false
var Shooting=false
var firstShoot=false
var stop=false
var lives=3
var notStop=true
func _physics_process(delta: float) -> void:
	if Shooting:
		if player!=null:
			if "lives" in player:
				if player.lives>0:	
					animations.play("Shoot")
					Shooting=false
					await get_tree().create_timer(1).timeout
					if firstShoot==true:
						Shooting=true
	if player!=null:
		if scapeTime:
			var distanceX=(position.x-player.position.x)
			var distanceY=(position.y-player.position.y)
			var directionX=distanceX/distanceX
			var directionY=distanceY/distanceY
			move=position.direction_to(Vector2i(position.x+directionX*distanceX,position.y+directionY*distanceY))
		
		else:
			
			if abs(position.x-player.position.x)-122<1 and abs(position.y-player.position.y)-122<1:
				move=Vector2.ZERO
				
			else:
				if Shooting:
					await get_tree().create_timer(1.5).timeout
				move=position.direction_to(player.position)
				
	else:
		move=Vector2.ZERO
	
	if lives<=0:
		queue_free()
	else:
		move=move.normalized()*SPEED
		move=move_and_collide(move)
	move_and_slide()
	

	


	
func disparar():
	var bullet_scene = preload("res://objetos/items/bullet/bullet.tscn")
	var bullet = bullet_scene.instantiate()
	var angle = (player.position - position).angle()
	bullet.player = player  
	bullet.position = position  
	bullet.rotation = angle
	get_parent().add_child(bullet)
	


func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body!=self and "type" in body and player==null:
		if body.type=="player":
			player=body
			animations.play("caminar")

func _on_distance_body_entered(body: Node2D) -> void:
	if body!=self and "type" in body:
		if body.type=="player":
			scapeTime=true
			
func _on_distance_body_exited(body: Node2D) -> void:
	if body!=self and "type" in body:
		if body.type=="player":
			scapeTime=false
			


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body!=self and "type" in body:
		if body.type=="player" and !firstShoot:
			await get_tree().create_timer(1).timeout
			Shooting=true
			firstShoot=true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body!=self and "type" in body:
		if body.type=="player":
			Shooting=false
			firstShoot=false
			

func _on_hurt_box_body_entered(body: Node2D) -> void:
	stop=false
	if body==player:
		await get_tree().create_timer(0.3).timeout
		if body.attacking:				
			if stop==false:
				lives-=1
				var angle=(body.position - position).angle()
				var direction = Vector2.RIGHT.rotated(angle)  # Mueve hacia la rotación actual
				velocity = direction * SPEED*-1*120
				
				notStop=false
				await get_tree().create_timer(0.25).timeout
				velocity = Vector2i(0,0)
				await get_tree().create_timer(0.3).timeout
				notStop=true
