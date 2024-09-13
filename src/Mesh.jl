function read_Gmsh_file(file_name)
	str = ""
	res = Dict()

	open(file_name) do file
		while !eof(file)
			line = readline(file)
			
			if length(str) == 0 && line[1] == '$'
				str = lstrip(line, '$')
				res[str] = []
			elseif length(str) > 0 && line[1] == '$'
				str = ""
			else
				splt = split(line, ' ')
				push!(res[str], splt)
			end
		end
	end
	
	return res
end