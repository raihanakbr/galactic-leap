extends CPUParticles2D

@onready var time_created = Time.get_ticks_msec()
@onready var sfx = $AudioStreamPlayer2D

func _ready() -> void:
	sfx.play()

func _process(delta):
	if Time.get_ticks_msec() - time_created > 5000:
		queue_free()
