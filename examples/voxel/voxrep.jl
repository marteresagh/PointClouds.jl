using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL= ViewerGL
using PointClouds

include("../viewfunction.jl")
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CAVA"
allfile0 = PointClouds.filelevel(fname,0)
allfile1 = PointClouds.filelevel(fname,1)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)
#fname = "examples/fit/CASALETTO/r.las"
allfile=union(allfile0,allfile1)
Vtot,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Vtot)
GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);


p = 3.
W,CW = PointClouds.pointclouds2cubegrid(V,p,0)
#W, ∂FW = PointClouds.extractsurfaceboundary(W,CW)

GL.VIEW(
	[
		#colorview(V,VV,rgb)
		#GL.GLGrid(W,∂FW,GL.COLORS[2],0.8)
		#GL.GLGrid(W,∂FW,GL.COLORS[1],0.8)
		GL.GLLar2gl(W,CW)
	]
)


#=

open("V0.jl", "w") do f
	n=size(W,2)
	write(f, "[ ")
	for i in 1:n
		x = W[1,i]
		write(f, "$x ")
	end
	write(f, ";\n")
	for i in 1:n
		y = W[2,i]
		write(f, "$y ")
	end
	write(f, ";\n")
	for i in 1:n
		z = W[3,i]
		write(f, "$z ")
	end
	write(f, "]")
end



open("CV0.jl", "w") do f
	write(f, "[")
	for simplex in CW
		write(f, "[")
		for i in simplex
    		write(f, "$i,")
		end
		write(f, "],")
	end
	write(f, "]")
end
=#
