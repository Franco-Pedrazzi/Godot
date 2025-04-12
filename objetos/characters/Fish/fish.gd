extends CharacterBody2D
var player=null
var SPEED=2.5
@export var DamageType="null"
@export var type="evilNpc"
@onready var animations=$AnimatedSprite2D

var Shooting=false
var firstShoot=false

func _physics_process(delta: float) -> void:
	if player != null :
		animations.play("Run")
		animations.scale.x=((player.position.x - position.x)/abs(player.position.x - position.x))*-1
	if Shooting:
		if player!=null:
			if "lives" in player:
				if player.lives>0:	
					animations.play("Shoot")
					Shooting=false
					if animations.get_animation() == "Shoot" :
						while animations.frame!=4:
							await get_tree().create_timer(0.2).timeout
						disparar()
					await get_tree().create_timer(1).timeout
					if firstShoot==true:
						Shooting=true
		
	

	move_and_slide()
	

	
func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body!=self and "type" in body and player==null:
		if body.type=="player":
			player=body

	
func disparar():
	var bullet_scene = preload("res://objetos/items/bullet/bullet.tscn")
	var bullet = bullet_scene.instantiate()
	var angle = (player.position - position).angle()
	bullet.player = player  
	bullet.position = position  
	bullet.rotation = angle
	get_parent().add_child(bullet)
	

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
			
