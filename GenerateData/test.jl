
include("..\\GeneralFunctions\\file_read_write.jl")


begin
    
    # Read in the training data
    data = Read_In("GenerateData\\datasets\\data_DoublePendulum.txt"; first_line = true)
    x_teach = data[:, 1:2] .*1 # coordinates
    y_teach = data[:, 3:4] # joint values    
    
    # kell egy plot a tanítási adatokról a térben
    ind = 6000
    scatter(x_teach[1:ind, 1], x_teach[1:ind, 2], 
     xlims=(-4, 4), ylims=(-3, 3), 
    framestyle=:origin, aspect_ratio=:equal, 
     )     
end