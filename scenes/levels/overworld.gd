extends Level

func _on_castle_area_body_entered(body: Node3D) -> void:
	switch_level('dungeon')
