#=
This code aims to generate training data for the double pendulum's neural network.
2025.03.22
Boogie
=#

include("..\\GeneralFunctions\\file_read_write.jl")

n_samples = 500000  # minták száma
l1, l2 = 1.0, 1.0  # inga karjainak hossza

# Adatok generálása
function generate_data(n_samples, L1, L2)
    X = zeros(n_samples, 2)
    Y = zeros(n_samples, 2)
    
    for i in 1:n_samples
        theta1 = rand() * π
        theta2 = rand() * π
        x = L1 * cos(theta1) + L2 * cos(theta1 + theta2)
        y_val = L1 * sin(theta1) + L2 * sin(theta1 + theta2)
        X[i, :] .= [x, y_val]
        Y[i, :] .= [theta1, theta2]
    end
    
    return X, Y
end


time1 = time()
println("Generating $(n_samples) data...")
x,y = generate_data(n_samples, l1, l2)

println("Saving data...")
Print_Matrix(hcat(x, y); filename = "GenerateData\\datasets\\data_DoublePendulum.txt", header = "x, y, theta1, theta2")

println("Generating $(n_samples) data --> Completed")
elapsed_time = time()-time1;
println("Elapsed time: $(elapsed_time) sec")


#=

n = 500000
Elapsed time: 4535 sec = 75 perc

=#