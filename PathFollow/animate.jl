# This code aims to animate the data provided by the codes of this folder


begin
	# using Pkg
	# Pkg.activate()
	# using Images
	# using Symbolics
	using LinearAlgebra
	# using Rotations
	# using PlutoUI
	using RigidBodyDynamics
	using MeshCatMechanisms
	# using StaticArrays
	using Plots
end


include("..\\GeneralFunctions\\file_read_write.jl")
include("..\\GeneralFunctions-PincherX\\visualize_pro.jl")


# Adatok visszaolvasása:
path = "PathFollow\\results\\test4"
data_qs = Read_In(path*"_qs.txt"; first_line = true)
data_xs = Read_In(path*"_xs.txt"; first_line = true)

# Simulate(data_qs,delay = 0.002, i_max = 3020)
Simulate(data_qs,delay = 0.002, i_max = 0)
println("Done")



plotly() 
plt = plot([data_xs[:, 1]], [data_xs[:, 2]], [data_xs[:, 3]], title = "Numerikus inverz kinematika adatai", label = "Pozíciók")
savefig(plt, path*"res_xs.pdf")
