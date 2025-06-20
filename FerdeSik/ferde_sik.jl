#=
This code is for testing how much the robotic arm loses of its hight when aproching a spot, depending on how far is 
the spot from the middle axis.
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
	using Statistics
end

include("..\\GeneralFunctions\\file_read_write.jl")
include("..\\GeneralFunctions-PincherX\\goal_and_orientation.jl")
include("..\\GeneralFunctions-PincherX\\direct_kinematics.jl")



begin

	# measure time
    time1 = time()
	
    file_path = "FerdeSik/results/test5"

	# Orientáció meghatározása:
	a_vec1 = [0, 0, -1]
	o_vec1 = [1, 0, 0] # legyen az x tengely, amire ráfog
	full_orientation,_,_ = Define_goal_orientation(a_vec1, o_vec1)
	
	# data_formeasure = [100 0 87; 125 0 87]
	# data_formeasure = [100 0 87; 125 0 87; 150 0 87; 175 0 87; 200 0 87; 225 0 87; 250 0 87] # x axis
	data_formeasure = [0 110 87; 0 125 87; 0 150 87; 0 175 87; 0 200 87; 0 225 87; 0 250 87] # y axis

    # save the used data as a pdf
    plt = scatter([data_formeasure[:, 1]], [data_formeasure[:, 2]], [data_formeasure[:, 3]], aspect_ratio = 1, ms = 1, xlabel = "x irány (mm)", ylabel = "y irány (mm)", zlabel = "z irány (mm)", 
    title = "Az inverzkinematikától megkért pontok halmaza", label = "index = $(used_index)\nxy_scale = $(xy_scale)\nz_scale = $(z_scale)\nx_translation = $(x_translation)\nz_translation = $(z_translation)")
    # savefig(plt, file_path*"_dataUsed.pdf")

    data_format = [vec(row) for row in eachrow(data_formeasure)]
    path = Define_goal.(data_format, fill(full_orientation, length(data_format)))

	Follow_path(path; filename = file_path, α = 0.01, param = 20000, d_p = 1 ,d_r = 0.05, i_max = 250)

	
	
	
	# measure time
	elapsed_time = time()-time1;
    println("Elapsed time: $(elapsed_time) sec ($(elapsed_time/60) min)")
end


# kiertekeles:
# begin

	# Meresi eredményből:	
	Ox1 = [79, 77, 74, 66, 67, 64, 60]
	Ox2 = [79, 76, 72, 70, 67, 63, 59]
	Ox3 = [79, 77, 72, 66, 62, 64, 59]
	Ox4 = [79, 76, 73, 66, 63, 64, 58]
	Oy1 = [79, 76, 72, 64, 59, 60, 57]
	Oy2 = [79, 75, 71, 64, 59, 59, 57]

	D = [100, 125, 150, 175, 200, 225, 250]

	# Átlagos magasságok minden sorra
	# all_heights = [Ox1 Ox2 Ox3 Ox4 Oy1 Oy2]
	all_heights = [Ox1 Ox2 Ox3 Ox4]
	# all_heights = [Oy1 Oy2]
	avg_heights = [mean(row) for row in eachrow(all_heights)]


	# measure time
    time1 = time()
	
    file_path = "FerdeSik/results/test6"

	a_vec1 = [0, 0, -1]
	o_vec1 = [1, 0, 0] # legyen az x tengely, amire ráfog
	full_orientation,_,_ = Define_goal_orientation(a_vec1, o_vec1)
	
	# data_formeasure = [100 0 87; 125 0 87]
	# data_formeasure = [100 0 87; 125 0 87; 150 0 87; 175 0 87; 200 0 87; 225 0 87; 250 0 87] # x axis
	data_formeasure = [100. 0 87; 125 0 87; 150 0 87; 175 0 87; 200 0 87] # x axis
	# data_formeasure = [0 110 87; 0 125 87; 0 150 87; 0 175 87; 0 200 87; 0 225 87; 0 250 87] # y axis


	function ReSet_goal(x, y)
		return y + 87 - (96.7667 - 0.17*x) # a 87 az eredeti magasság, a zárójel az eltérés
		# return y + 87 - (92.3393 - 0.133571*x) # a 87 az eredeti magasság, a zárójel az eltérés
	end

	# data_formeasure[:,3]
	data_formeasure[:, 3] = ReSet_goal.(data_formeasure[:, 1], data_formeasure[:, 3])
    data_formeasure

				# scatter([data_formeasure[:, 1]], [data_formeasure[:, 3]], label = "A szükséges pontok",
				# 	xlabel = "Ox tengely (mm)", ylabel = "Oz tengely (mm)")
				# scatter!([data_formeasure[:, 1]], avg_heights, label = "A valóságban kapott pontok")
				# scatter!([data_formeasure[:, 1]], [ReSet_goal.(data_formeasure[:, 1], data_formeasure[:, 3])], title = "", label = "A lineáris illesztéssel módosított célpontok")
				# savefig("FerdeSik\\modell.pdf")

    plt = scatter([data_formeasure[:, 1]], [data_formeasure[:, 2]], [data_formeasure[:, 3]], aspect_ratio = 1, ms = 1, xlabel = "x irány (mm)", ylabel = "y irány (mm)", zlabel = "z irány (mm)", 
    title = "Az inverzkinematikától megkért pontok halmaza")
    # savefig(plt, file_path*"_dataUsed.pdf")

    data_format = [vec(row) for row in eachrow(data_formeasure)]
    path = Define_goal.(data_format, fill(full_orientation, length(data_format)))

	Follow_path(path; filename = file_path, α = 0.01, param = 20000, d_p = 1 ,d_r = 0.05, i_max = 250)

	
	
	
	# measure time
	elapsed_time = time()-time1;
    println("Elapsed time: $(elapsed_time) sec ($(elapsed_time/60) min)")
# end



file_path

deg2rad(30)
rad2deg(1.13)
