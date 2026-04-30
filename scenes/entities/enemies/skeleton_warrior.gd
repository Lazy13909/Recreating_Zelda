extends Enemy

func _ready() -> void:
	attack_radius = 2.0

func _physics_process(delta: float) -> void:
	move_to_player(delta)

func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(2.0, 4.0)
	if position.distance_to(player.position) < attack_radius:
		$AnimationTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func can_damge(value: bool) -> void:
	$Skin/Rig/Skeleton3D/BoneAttachment3D/Bone.can_damage = value
