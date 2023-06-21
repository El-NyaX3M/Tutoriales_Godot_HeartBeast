extends CharacterBody2D

#se mueven las variables a un nuevo recurso para tomarlo como objeto
#luego se crea una variable que pueda obtener esos datos y siendo de tipó del nuevo recurso
@export var movement_data : PlayerMovementData
var air_jump = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
#Se obtiene el valor de la gravedad por medio de una llamada de los settings de godot.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

#El método _physics_process estará corriendo 60* veces por segundo.
#* este valor puede cambiarse en los ajustes del proyecto.
#La variable delta funciona como un contador de tiempo entre los frames y un segundo.
#aquí la variable delta tiene un valor de 1/60
func _physics_process(delta):
	# Add the gravity.
	#is_on_floor valida que hayan nodos estáticos en el lado opuesto a la propiedad Up Direction
	#en este caso, Up Direction tiene valor 0,-1 (arriba) asi que el suelo debe estar en 0,1 (abajo)
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta
	
	else:
		air_jump = true
	# Handle Jump.
	#Input hace referencia a lo que se ingrese por medio del teclado
	#Se valida si se presiona la barra espaciadora y si se está en el suelo.
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("btn_jump"):
			velocity.y = movement_data.jump_velocity
	else:
		if Input.is_action_just_released("btn_jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
		if Input.is_action_just_pressed("btn_jump") and air_jump:
			velocity.y = movement_data.jump_velocity * 0.8
			air_jump = false
	
	handle_wall_jump()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#La dirección se obtendrá de acuerdo a la tecla que se presione
	#flecha izquierda (-1) o flecha derecha (1)
	#Input.get_axis(<left>, <right>)
	var direction = Input.get_axis("ui_left", "ui_right")
	#Si hay valor en la variable direction entonces le asigna a la propiedad x de velocity una velocidad
	#esta velocidad es obtenida multiplicando la direction (-1 o 1) por SPEED (definido como 200 al inicio).
	#En caso contrario entonces se le asigna 0.
	if direction:
		if is_on_floor():
		#velocity.x = direction * SPEED
		#move_toward hace que el objeto se mueva, ingresando su posición inicial, su velocidad final y 
		#el cambio de velocidad respecto a delta
			velocity.x = move_toward(velocity.x, movement_data.speed * direction, delta * movement_data.acceleration)
		else:
			velocity.x = move_toward(velocity.x, movement_data.speed * direction, movement_data.air_acceleration * delta)
	else:
		#velocity.x = 0
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, movement_data.air_friction * delta)
		
	#if Input.is_action_just_pressed("ui_accept"):
		#movement_data = load("res://FastMovementData.tres")
	
	update_animations(direction)
	
	#guarda la comprobación de que el personaje está en el suelo antes de moverse con move_and_slide()
	var was_on_floor = is_on_floor()
	#move_and_slide permite hacer el movimiento del objeto validando colisiones con nodos estáticos
	#este toma la variable velocity y hace el resto del trabajo.
	move_and_slide()
	
	#valida que antes del movimiento se estuvo en el suelo y luego del movimiento se encuentra en el suelo
	#SOLO es TRUE cuando se estuvo en el suelo antes de move_and_slide() y no se encuentra después en el suelo
	#también si el personaje se encuentra bajando
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	
func update_animations(direction):
	if direction:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")

func handle_wall_jump():
	if is_on_floor(): return
	#get_wall_normal() obtiene el último punto de choque con una superficie
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("ui_left") and wall_normal == Vector2.LEFT and is_on_wall():
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
	if Input.is_action_just_pressed("ui_right") and wall_normal == Vector2.RIGHT and is_on_wall():
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
	
