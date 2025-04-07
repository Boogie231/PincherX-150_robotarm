begin
	using Pkg
	Pkg.activate()
	# using Images
	# using Symbolics
	using LinearAlgebra
	# using Rotations
	# using PlutoUI
	# using RigidBodyDynamics
	# using MeshCatMechanisms
	# using StaticArrays
	using Plots
end

include("..\\GeneralFunctions\\file_read_write.jl")
include("..\\GeneralFunctions-PincherX\\goal_and_orientation.jl")
include("..\\GeneralFunctions-PincherX\\direct_kinematics.jl")
include("followpath.jl")


begin
    
	
	# Orientáció meghatározása:
	a_vec1 = [0, 0, -1]
	o_vec1 = [0, 1, 0]
	full_orientation,_,_ = Define_goal_orientation(a_vec1, o_vec1)
	
	
	# Work with data
	data = Read_In("PathFollow\\coordinates-bogi.txt"; first_line = true)
	
	# scale data for the robot:
	norm_scale =  maximum(data[:, 1])
	xy_scale = 250
	z_scale = 1
	data[:, 1] = data[:, 1] ./ norm_scale .*xy_scale
	data[:, 2] = data[:, 2] ./ norm_scale .*xy_scale
	data[:, 2] = data[:, 2] .- maximum(data[:, 2]) ./2
	data[:, 2] = -data[:, 2]
	data[:, 3] = data[:, 3] ./ z_scale


	data_format = [vec(row) for row in eachrow(data)]
	path = Define_goal.(data_format, fill(full_orientation, length(data_format)))

	Follow_path(path; filename = "test1", α = 0.01, param = 20000, d_p = 1 ,d_r = 0.05, i_max = 250)

end


# Setting up data scaleing

# plot([data[:, 1]], [data[:, 2]], [data[:, 3]])
plot([data[:, 1]], [data[:, 2]], [data[:, 3]], aspect_ratio = 1)
# data[:, 2] = data[:, 2] * 100

# data[:, 1]
# data[:, 2]

