function Print_Matrix(matrix; filename = "file.txt", header = "")
	
	# Fájlba írás
	open(filename, "w") do file
		println(file, header)
	    for row in eachrow(matrix)
	        println(file, join(row, " "))  # Minden sort szóközökkel elválasztva ír
			# println(typeof(row))
			# break
	    end
	end
end

function Print_Matrix2(matrix; filename = "file.txt", header = "")
    # Fájlba írás
    open(filename, "w") do file
		println(file, header)
        for row in matrix
            # Közvetlenül írjuk ki a sor elemeit zárójelek nélkül
            for element in row
                print(file, element, " ")  # Írjuk ki az elemet szóközzel
            end
            println(file)  # Új sor a következő sorhoz
        end
    end
end



function Read_In(filename; first_line = false)
	# Fájl olvasás
	data = []
	open(filename, "r") do file
	    for line in eachline(file)
			if first_line
				first_line = false
				continue
			end
	        # Sorok feldolgozása
	        push!(data, parse.(Float64, split(line)))  # Sorokat olvas be és konvertál
	    end
	end
	
	# Az olvasott adatok mátrixba konvertálása:
		# a data oszlop matrix lesz, transzponálással sorrá teszem, és függőlegesen összefüzöm
	A_read = vcat(data'...)  # Vízszintes összefűzés
	
	# Eredmény kiírása
	# println("A beolvasott mátrix:")
	# println(A_read)

	return A_read
	
end