using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL= ViewerGL
using PointClouds

include("../viewfunction.jl")
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CASALETTO"
allfile = PointClouds.filelevel(fname,0)

#fname = "examples/fit/CASALETTO/r.las"
Vtot,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Vtot)
GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

p = 0.4 #spacing cupola 0.4, spacing casaletto 0.27404680848121645,

W,(WW,EW,FW,CW) = PointClouds.pointclouds2cubegrid(V,p,0)
model = W,(WW,EW,FW,CW)
W, ∂FW = PointClouds.extractsurfaceboundary(model)

GL.VIEW(
	[
		#GL.GLGrid(W,∂FW,GL.COLORS[2],1)
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
