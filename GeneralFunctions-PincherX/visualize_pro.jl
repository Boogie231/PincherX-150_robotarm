begin
	px150 = parse_urdf(Float64, "px150.urdf")
	mvis_px150 = MechanismVisualizer(px150, URDFVisuals("px150.urdf", package_path=["interbotix_ros_manipulators/interbotix_ros_xsarms"]))
	state = MechanismState(px150)

	bodies(px150)
	joints_px150 = joints(px150) # jointok: 2, 3, 4, 5, ??
	render(mvis_px150)
end

function Teszt(q)
	set_configuration!(state, joints(px150)[2], q[1]) # waist
	set_configuration!(state, joints(px150)[3], q[2]) # shoulder
	set_configuration!(state, joints(px150)[4], q[3]) # elbow
	set_configuration!(state, joints(px150)[5], q[4]) # wrist angle
	set_configuration!(state, joints(px150)[6], q[5]) # wrist rotate

	# set_configuration!(state, joints(px150)[11], -0.033) # gripper
	# set_configuration!(state, joints(px150)[12], 0.033) # gripper
	set_configuration!(state, joints(px150)[11], -0.0) # gripper
	set_configuration!(state, joints(px150)[12], 0.0) # gripper

	MeshCatMechanisms._render_state!(mvis_px150,state)
end
q0 = [0 0 0 0 0]
function Simulate(data; delay = 0.1, i_max = 10)
	# data: rows with 5 elements (joint angles) 
	Teszt(q0)
	sleep(0.1)
	
	for (i, q) in enumerate(eachrow(data))
		Teszt(q)
		if i < i_max
			sleep(delay)
		end
	end

	println("Done")
end

# function Simulate(data; delay_start = 0.1, delay_end = 0.01)
# 	Teszt(q0)
# 	delay = delay_start
# 	# data: rows with 5 elements (joint angles) 
	
# 	for q in eachrow(data)
# 		Teszt(q)
# 		sleep(delay)
# 		if delay > delay_end
# 			delay -= 0.002
# 		end
# 	end

# 	println("Done")
# end