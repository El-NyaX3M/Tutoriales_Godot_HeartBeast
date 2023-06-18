extends CharacterBody2D


const SPEED = 100.0
const ACCELERATION = 800.0
const FRICTION = 1000.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
#Se obtiene el valor de la gravedad por medio de una llamada de los settings de godot.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d = $AnimatedSprite2D

#El método _physics_process estará corriendo 60* veces por segundo.
#* este valor puede cambiarse en los ajustes del proyecto.
#La variable delta funciona como un contador de tiempo entre los frames y un segundo.
#aquí la variable delta tiene un valor de 1/60
func _physics_process(delta):
	# Add the gravity.
	#is_on_floor valida que hayan nodos estáticos en el lado opuesto a la propiedad Up Direction
	#en este caso, Up Direction tiene valor 0,-1 (arriba) asi que el suelo debe estar en 0,1 (abajo)
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	#Input hace referencia a lo que se ingrese por medio del teclado
	#Se valida si se presiona la barra espaciadora y si se está en el suelo.
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
	else:
		if Input.is_action_just_released("ui_accept") and velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2

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
		#velocity.x = direction * SPEED
		#move_toward hace que el objeto se mueva, ingresando su posición inicial, su velocidad final y 
		#el cambio de velocidad respecto a delta
		velocity.x = move_toward(velocity.x, SPEED * direction, delta * ACCELERATION)
	else:
		#velocity.x = 0
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	update_animations(direction)
	#move_and_slide permite hacer el movimiento del objeto validando colisiones con nodos estáticos
	#este toma la variable velocity y hace el resto del trabajo.
	move_and_slide()
	
func update_animations(direction):
	if direction:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")
