open("ET.jl", "w") do f
	write(f, "ET=[")
	for simplex in CT
		write(f, "[")
		for i in simplex
			write(f, "$i,")
		end
		write(f, "],")
	end
	write(f, "]")
end

open("T.jl", "w") do f
	n=size(T,2)
	write(f, "T=[")
	for i in 1:n
		x=T[1,i]
		write(f, "$x ")
	end
	write(f, "; ")
	for i in 1:n
		y=T[2,i]
		write(f, "$y ")
	end
	write(f, "; ")
	for i in 1:n
		z=T[3,i]
		write(f, "$z ")
	end
	write(f, "]")
end
