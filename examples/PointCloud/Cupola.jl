using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds

include("../viewfunction.jl")

fname = "examples/PointCloud/pointCloud/CUPOLA/r.las"
Vtot,VV,rgb = PointClouds.loadlas(fname)
_,V = PointClouds.subtractaverage(Vtot)

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
