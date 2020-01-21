using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using PointClouds
using ViewerGL
GL=ViewerGL
include("../viewfunction.jl")

# from my local repository
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\DIGA"
allfile = PointClouds.filelevel(fname,0)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)

Voriginal,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Voriginal)

GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

DT = PointClouds.mat3DT(V)
filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.23 #da variare
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
