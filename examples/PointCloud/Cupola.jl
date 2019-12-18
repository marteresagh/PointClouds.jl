using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using Tesi

include("./viewfunction.jl")

fname = "examples/PointCloud/pointCloud/CUPOLA/r.las"
Vtot,VV,rgb = Tesi.loadlas(fname)
V,VV = Lar.apply(Lar.t(-min(Vtot[1,:]...),-min(Vtot[2,:]...),-min(Vtot[3,:]...)),[Vtot,VV])


GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

include("./pointCloud/CUPOLA/DT.jl")
#Equivalent to =>
#DT = AlphaStructures.delaunayTriangulation(V);
filtration = AlphaStructures.alphaFilter(V, DT);

α = 1.5 #0.7
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α);

GL.VIEW(
	[
		colorview(V,FV,rgb)
	]
);

#=
open("DT.jl", "w") do f
	write(f, "[")
	for simplex in DT
		write(f, "[")
		for i in simplex
    		write(f, "$i,")
		end
		write(f, "],")
	end
	write(f, "]")
end
=#
