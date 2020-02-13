function printmodel(filename, V, CV)

	open(filename*".jl", "w") do f
		n=size(V,2)
		write(f, "V=[")
		for i in 1:n
			x=V[1,i]
			write(f, "$x ")
		end
		write(f, "; ")
		for i in 1:n
			y=V[2,i]
			write(f, "$y ")
		end
		write(f, "; ")
		for i in 1:n
			z=V[3,i]
			write(f, "$z ")
		end
		write(f, "]\n")

		write(f, "\n ")
		write(f, "CV=[")

		for simplex in CV
			write(f, "[")
			for i in simplex
				write(f, "$i,")
			end
			write(f, "],")
		end
		write(f, "]")
	end
end
