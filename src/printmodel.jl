# TODO dovrei stampare i modelli nei VARI FORMATI ply obj e LAS
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



#=
open("toro4.ply", "w") do f
	for i=1:size(V,2)
		x=V[1,i]
		y=V[2,i]
		z=V[3,i]
		write(f, "$x $y $z \n")
	end
end
=#
