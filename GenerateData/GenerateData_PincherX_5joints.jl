#=
This code aims to generate training data for the PincherX-150's neural network (5 joint version) - orientation and positions.
2025.03.22
Boogie
=#

# Parameters for the code
begin
    n_samples = 500000  # minták száma 
end


include("..\\GeneralFunctions\\file_read_write.jl")
include("..\\GeneralFunctions-PincherX\\direct_kinematics.jl")

# Adatok generálása
function generate_data(n_samples)
    x = zeros(n_samples, 6)
    y = zeros(n_samples, 5)
    
    for i in 1:n_samples
        q1 = rand() * π -π/2
        q2 = rand() * π -π/2
        q3 = rand() * π -π/2
        q4 = rand() * π -π/2
        q5 = rand() * π -π/2
        pos = f([q1 q2 q3 q4 q5])
        
        println("$(i/n_samples*100)%")

        x[i, :] .= pos
        y[i, :] .= [q1, q2, q3, q4, q5]
    end
    
    return x, y
end

# Not yet tested:

# function generate_data(n_samples)    
#     q1 = rand(n_samples) * π -π/2
#     q2 = rand(n_samples) * π -π/2
#     q3 = rand(n_samples) * π -π/2
#     q4 = rand(n_samples) * π -π/2
#     q5 = rand(n_samples) * π -π/2

#     pos = f.(hcat(q1, q2, q3, q4, q5))
#     y = hcat(q1, q2, q3, q4, q5)
    
#     return pos, y
# end


begin
    time1 = time()
    println("Generating $(n_samples) data...")
    x, y = generate_data(n_samples)

    println("Saving data...")
    Print_Matrix(hcat(x, y); filename = "GenerateData\\datasets\\data_Pincher_5joint.txt", header = "x, y, z, orientation1, orientation2, orientation3, q1, q2, q3, q4, q5")

    println("Generating $(n_samples) data --> Completed")
    elapsed_time = time()-time1;
    println("Elapsed time: $(elapsed_time) sec (= $(elapsed_time/60) perc)")


end