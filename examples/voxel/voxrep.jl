using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL= ViewerGL
using PointClouds

include("../viewfunction.jl")
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\SCALE"
allfile = PointClouds.filelevel(fname,2)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)

Vtot,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Vtot)
GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);


p = 0.1
W,CW = PointClouds.pointclouds2cubegrid(V,p,0)
W, ∂FW = PointClouds.extractsurfaceboundary(W,CW)

GL.VIEW(
	[
		#colorview(V,VV,rgb)
		#GL.GLGrid(W,∂FW,GL.Point4d(1,1,1,1))
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
