extends Level

func _on_door_area_body_entered(body: Node3D) -> void:
	switch_level('overworld')
