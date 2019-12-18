using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using Tesi
include("./viewfunction.jl")

#fname = "examples/PointCloud/pointCloud/Cupolatotale/r.las"
fname0 = "examples/PointCloud/pointCloud/Cupolatotale/r0.las"
fname1 = "examples/PointCloud/pointCloud/Cupolatotale/r1.las"
fname2 = "examples/PointCloud/pointCloud/Cupolatotale/r2.las"
fname3 = "examples/PointCloud/pointCloud/Cupolatotale/r3.las"
fname4 = "examples/PointCloud/pointCloud/Cupolatotale/r4.las"

Vtot,VV,rgb = Tesi.loadlas(fname0,fname1,fname2,fname3,fname4)
#Vtot,VV,rgb = ReadLas.loadlas(fname)
V,VV = Lar.apply(Lar.t(-min(Vtot[1,:]...),-min(Vtot[2,:]...),-min(Vtot[3,:]...)),[Vtot,VV])


GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

# using Distributed
# addprocs(8)
#
# @everywhere using Pkg
# @everywhere Pkg.activate("./AlphaStructures")
#
# @everywhere using  AlphaStructures
# DT = AlphaStructures.delaunayTriangulation(V);

include("./pointCloud/Cupolatotale/DT0.jl")
include("./pointCloud/Cupolatotale/DT1.jl")
include("./pointCloud/Cupolatotale/DT2.jl")
include("./pointCloud/Cupolatotale/DT3.jl")
include("./pointCloud/Cupolatotale/DT4.jl")
include("./pointCloud/Cupolatotale/DT5.jl")

# #Equivalent to =>
# DT = AlphaStructures.delaunayTriangulation(V);
# DT = union(part0,part1,part2,part3,part4)

DT=union(DT0,DT1,DT2,DT3,DT4,DT5)
filtration = AlphaStructures.alphaFilter(V, DT);

α = 0.4
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		colorview(V,FV,rgb)
	]
);


#=
open("DT5.jl", "w") do f
	write(f, "[")
	for simplex in DT[500001:end]
		write(f, "[")
		for i in simplex
    		write(f, "$i,")
		end
		write(f, "],")
	end
	write(f, "]")
end
=#
