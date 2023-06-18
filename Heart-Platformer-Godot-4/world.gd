extends Node2D
# Para comentar se usa el caracter Hash

#@onready indica que esa variable se inicializa al correr el programa
#para asignar un objeto nodo a una variable se ingresa la dirección del objeto como es a continuación:
@onready var polygon_2d = $Zone/CollisionPolygon2D/Polygon2D
#Esta último comando puede ahorrarse al arrastrar el objeto deseado + ctrl hacia el editor del codigo
@onready var collision_polygon_2d = $Zone/CollisionPolygon2D

#Las funciones se declaran con 'func' + <nombre_de_la_función> + ():
#La función _ready(): corre cuando carga el nodo al que pertenece se encuentra listo (cuando inicia el juego)
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	polygon_2d.polygon = collision_polygon_2d.polygon #asigna los poligonos del objeto a los poligonos de otro
