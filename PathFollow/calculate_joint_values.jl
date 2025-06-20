#=
This code aims to generate joint values for the robotic arm, with multiple use of 
inverse kinematics, using an orientation of pointing vertically downward thw whole time.


=#

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

function switch_nonzero_z_to_constant!(A::Matrix{Float64}, new_z::Float64)
    for i in 1:size(A, 1)
        if A[i, 3] != 0.0
            A[i, 3] = new_z
        end
    end
    return A
end

begin
	file_path = "PathFollow\\results\\test19"


	# measure time
    time1 = time()
	
	# Orientáció meghatározása:
	a_vec1 = [0, 0, -1]
	o_vec1 = [1, 0, 0] # legyen az x tengely, amire ráfog
	full_orientation,_,_ = Define_goal_orientation(a_vec1, o_vec1)
	
	# General data:
	used_index = 314
	# used_index = 87
	
	# Work with data
	data = Read_In("PathFollow\\inputData\\coordinates4.txt"; first_line = true)
	println(size(data))
	data = data[1:used_index, :]
	# scale data for the robot:
	# ------------------------------------------------------------------
	x_central = minimum(data[:, 1]) # find minimum of x data
	data[:, 1] = data[:, 1] .- x_central

    # norm data
	norm_scale =  maximum(data[:, 1])
	data[:, 1] = data[:, 1] ./ norm_scale
	data[:, 2] = data[:, 2] ./ norm_scale
    
    # scale data
	xy_scale = 70
    data[:, 1] = data[:, 1] .* xy_scale
	data[:, 2] = data[:, 2] .* xy_scale
	

    # translate data
	x_translation = 110.0 # mm
	y_translation = (maximum(data[:, 2]) + minimum(data[:, 2])) /2
	z_translation = 87.0
	data[:, 1] = data[:, 1] .+ x_translation
	data[:, 2] = data[:, 2] .- y_translation
	data[:, 2] = -data[:, 2] # flippeljük az y tengelyt, mert még így maradt a tabletes feldolgozásból az adat
	switch_nonzero_z_to_constant!(data, 30.) # 30 mm-rel megemeli, amikor el kell vegye a papírtól
	data[:, 3] = data[:, 3] .+ z_translation
	# ------------------------------------------------------------------
	
	# save the used data as a pdf
	plt = scatter([data[:, 1]], [data[:, 2]], [data[:, 3]], aspect_ratio = 1, ms = 1, xlabel = "x irány (mm)", ylabel = "y irány (mm)", zlabel = "z irány (mm)", 
	title = "Az inverzkinematikától megkért pontok halmaza", label = "index = $(used_index); xy_scale = $(xy_scale); x_translation = $(x_translation); z_translation = $(z_translation)", legend =:topright)
	plot!(plt, [data[:, 1]], [data[:, 2]], [data[:, 3]], label ="")
	savefig(plt, file_path*"_dataUsed.pdf")

	data_format = [vec(row) for row in eachrow(data[1:used_index, :])]
	path = Define_goal.(data_format, fill(full_orientation, length(data_format)))

	# Follow_path(path; filename = file_path, α = 0.01, param = 20000, d_p = 1 ,d_r = 0.05, i_max = 250)
	
	# measure time
	elapsed_time = time()-time1;
    println("Elapsed time: $(elapsed_time) sec ($(elapsed_time/60) min)")
	plt
end



plotly()
gr()

plt