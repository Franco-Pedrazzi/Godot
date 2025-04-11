extends CharacterBody2D

# Referencia al jugador, se asigna cuando lo detecta
var player = null

# Velocidad de movimiento del NPC
var SPEED = 2.5

# Variables exportables (se pueden editar desde el editor)
@export var DamageType = "null"
@export var type = "evilNpc"
@export var mapa_limite = Rect2(Vector2(0, 0), Vector2(1024, 768))  # Límites del mapa

# Acceso directo al AnimatedSprite2D
@onready var sprite = $AnimatedSprite2D

# Variables de estado
var move = Vector2.ZERO
var scapeTime = false
var Shooting = false
var firstShoot = false
var stop = false
var lives = 20
var notStop = true
var evading = false

func _physics_process(delta: float) -> void:
	if Shooting and player != null and "lives" in player and player.lives > 0:
		Shooting = false
		sprite.play("disparo")
		await get_tree().create_timer(1).timeout
		if firstShoot:
			Shooting = true

	if player != null and not evading:
		if scapeTime:
			var distance = position - player.position
			var direction = distance.normalized()
			move = direction
		else:
			if abs(position.x - player.position.x) - 122 < 1 and abs(position.y - player.position.y) - 122 < 1:
				move = Vector2.ZERO
			else:
				if Shooting:
					await get_tree().create_timer(1.5).timeout
				move = position.direction_to(player.position)
	else:
		move = Vector2.ZERO
	
	if lives <= 0:
		queue_free()
	else:
		move = move.normalized() * SPEED
		if notStop and not evading:
			move_and_collide(move)

	move_and_slide()

	# Animaciones
	if evading:
		if sprite.animation != "salto":
			sprite.play("salto")
	elif Shooting:
		move = Vector2.ZERO
		if sprite.animation != "disparo":
			sprite.play("disparo")
	elif move.length() > 0.1:
		if sprite.animation != "caminar":
			sprite.play("caminar")
	else:
		if sprite.animation != "quieto":
			sprite.play("quieto")

	# Flip horizontal
	if player != null:
		sprite.flip_h = player.position.x < position.x

	# Salto evasivo automático si tiene menos de 10 vidas
	if lives < 10 and not evading and not sprite.is_playing("salto"):
		hacer_salto_evasion()


func hacer_salto_evasion():
	if player == null:
		return

	evading = true
	Shooting = false
	notStop = false

	sprite.play("salto")

	var direccion_contraria = (position - player.position).normalized()
	var fuerza_salto = 100
	var destino = position + direccion_contraria * fuerza_salto
	destino.x = clamp(destino.x, mapa_limite.position.x, mapa_limite.position.x + mapa_limite.size.x)
	destino.y = clamp(destino.y, mapa_limite.position.y, mapa_limite.position.y + mapa_limite.size.y)

	var duracion_salto = 1.7
	var tween = create_tween()
	tween.tween_property(self, "position", destino, duracion_salto).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(duracion_salto).timeout
	evading = false
	notStop = true


func disparar():
	var bullet_scene = preload("res://objetos/items/bullet/bullet.tscn")
	var bullet = bullet_scene.instantiate()
	var angle = (player.position - position).angle()
	bullet.player = player
	bullet.position = position
	bullet.rotation = angle
	get_parent().add_child(bullet)


func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body != self and "type" in body and player == null:
		if body.type == "player":
			player = body


func _on_distance_body_entered(body: Node2D) -> void:
	if body != self and "type" in body and body.type == "player":
		scapeTime = true


func _on_distance_body_exited(body: Node2D) -> void:
	if body != self and "type" in body and body.type == "player":
		scapeTime = false


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body != self and "type" in body:
		if body.type == "player" and !firstShoot:
			await get_tree().create_timer(1).timeout
			Shooting = true
			firstShoot = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body != self and "type" in body and body.type == "player":
		Shooting = false
		firstShoot = false


func _on_hurt_box_body_entered(body: Node2D) -> void:
	stop = false
	if body == player:
		await get_tree().create_timer(0.3).timeout
		if body.attacking and stop == false:
			lives -= 1
			var angle = (body.position - position).angle()
			var direction = Vector2.RIGHT.rotated(angle)
			velocity = direction * SPEED * -1 * 120
			notStop = false
			await get_tree().create_timer(0.25).timeout
			velocity = Vector2.ZERO
			await get_tree().create_timer(0.3).timeout
			notStop = true
