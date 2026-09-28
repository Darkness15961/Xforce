extends Node

# Posición y persistencia entre dimensiones
var posicionJugador: Vector2 = Vector2.ZERO
var deberRestaurarPosicion: bool = false

# Música y persistencia de audio
var posicionAudio: float = 0.0
var deberRestaurarAudio: bool = false

# Estado del jugador y vida
var vidaJugador: int = 10
var EstadodoVivo: bool = true
var gameoveractivo: bool = false

# Ajustes generales y pausa
var pantallaCompleta: bool = false
var bloquear_pausa: bool = false
