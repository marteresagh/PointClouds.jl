using LinearAlgebraicRepresentation, AlphaStructures
Lar = LinearAlgebraicRepresentation
using ViewerGL
GL= ViewerGL
using PointClouds

include("../viewfunction.jl")
fname = "C:\\Users\\marte\\Documents\\potreeDirectory\\pointclouds\\CASALETTO"
allfile = PointClouds.filelevel(fname,0)
_,_,_,_,_,spacing = PointClouds.readJSON(fname)

Vtot,VV,rgb = PointClouds.loadlas(allfile...)
_,V = PointClouds.subtractaverage(Vtot)

GL.VIEW(
	[
		colorview(V,VV,rgb)
	]
);

DT = PointClouds.delaunayMATLAB(V)
filtration = AlphaStructures.alphaFilter(V, DT);
α = 0.3 #0.03316948190331459
VV, EV, FV, TV = AlphaStructures.alphaSimplex(V, filtration, α)

GL.VIEW(
	[
		colorview(V,FV,rgb)
		GL.GLFrame
	]
);

N=18
par=0.02
shape="plane"
Vcurrent, FVcurrent,RGBcurrent,allshapes=PointClouds.findall(V,FV,rgb,N,par,shape;NOTSHAPE=100)
# GL.VIEW(
# 	[
# 		colorview(Vcurrent,FVcurrent,RGBcurrent)
# 		GL.GLFrame
# 	]
# );

PointClouds.flat(allshapes)
p = 0.5 #spacing cupola 0.4, spacing casaletto 0.27404680848121645,


W,CW = PointClouds.voxeloriented(allshapes,p,0)
#T,CT = PointClouds.pointclouds2cubegrid(Vcurrent2,p,0)
W, ∂FW = PointClouds.extractsurfaceboundary(W,CW)

GL.VIEW(
	[
		#colorview(V,[[i] for i in 1:size(V,2)],rgb,0.4)
		GL.GLLar2gl(W,CW)
		#GL.GLGrid(W,∂FW,GL.COLORS[1],0.8)
		#GL.GLLar2gl(T,CT)
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
